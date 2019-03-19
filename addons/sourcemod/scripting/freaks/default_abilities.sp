#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <morecolors>
#include <freak_fortress_2>
#include <freak_fortress_2_subplugin>

#pragma newdecls required

#define PLUGIN_VERSION "1.11.0"

public Plugin myinfo=
{
	name		=	"Freak Fortress 2: Default Abilities",
	author		=	"RainBolt Dash",
	description	=	"FF2: Common abilities used by all bosses",
	version		=	PLUGIN_VERSION,
};

#define SPOOK "yikes_fx"

Handle OnHaleJump;
Handle OnHaleRage;
Handle OnHaleWeighdown;

Handle gravityDatapack[MAXPLAYERS+1];

Handle jumpHUD;

bool enableSuperDuperJump[MAXPLAYERS+1];
float UberRageCount[MAXPLAYERS+1];
float GoombaBlockedUntil[MAXPLAYERS+1];
int BossTeam=view_as<int>(TFTeam_Blue);
bool Outdated=false;

ConVar cvarOldJump;
ConVar cvarBaseJumperStun;
ConVar cvarSoloShame;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	OnHaleJump=CreateGlobalForward("VSH_OnDoJump", ET_Hook, Param_CellByRef);
	OnHaleRage=CreateGlobalForward("VSH_OnDoRage", ET_Hook, Param_FloatByRef);
	OnHaleWeighdown=CreateGlobalForward("VSH_OnDoWeighdown", ET_Hook);
	return APLRes_Success;
}

public void OnPluginStart2()
{
	new version[3];
	FF2_GetFF2Version(version);
	if(version[0]!=1)
	{
		SetFailState("This subplugin depends on FF2 V1");
	}
	/*new fversion[3];
	FF2_GetForkVersion(fversion);
	if(fversion[0]==1 && fversion[1]<18)
	{
		PrintToServer("[FF2] Warning: This subplugin depends on at least Unofficial FF2 v1.18.0");
		PrintToServer("[FF2] Warning: \"rage_stun\" args 20 and up are disabled");
		Outdated=true;
	}*/

	jumpHUD=CreateHudSynchronizer();

	HookEvent("object_deflected", OnDeflect, EventHookMode_Pre);
	HookEvent("teamplay_round_start", OnRoundStart);
	HookEvent("player_death", OnPlayerDeath);

	LoadTranslations("freak_fortress_2.phrases");
}

public void OnAllPluginsLoaded()
{
	cvarOldJump=FindConVar("ff2_oldjump");  //Created in freak_fortress_2.sp
	cvarBaseJumperStun=FindConVar("ff2_base_jumper_stun");
	if(!Outdated)
		cvarSoloShame=FindConVar("ff2_solo_shame");
}

public Action OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	for(int client; client<MaxClients; client++)
	{
		enableSuperDuperJump[client]=false;
		UberRageCount[client]=0.0;
		GoombaBlockedUntil[client]=0.0;
	}

	CreateTimer(0.3, Timer_GetBossTeam, _, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(9.11, StartBossTimer, _, TIMER_FLAG_NO_MAPCHANGE);  //TODO: Investigate.
	return Plugin_Continue;
}

public Action StartBossTimer(Handle timer)  //TODO: What.
{
	for(int boss; FF2_GetBossUserId(boss)!=-1; boss++)
	{
		if(FF2_HasAbility(boss, this_plugin_name, "charge_teleport"))
		{
			FF2_SetBossCharge(boss, FF2_GetAbilityArgument(boss, this_plugin_name, "charge_teleport", 0, 1), -1.0*FF2_GetAbilityArgumentFloat(boss, this_plugin_name, "charge_teleport", 2, 5.0));
		}
	}
}

public Action Timer_GetBossTeam(Handle timer)
{
	BossTeam=FF2_GetBossTeam();
	return Plugin_Continue;
}

public Action FF2_OnAbility2(int boss, const char[] plugin_name, const char[] ability_name, int status)
{
	int slot=FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 0);
	if(!slot)  //Rage
	{
		if(!boss)  //Boss indexes are just so amazing
		{
			float distance=view_as<float>(FF2_GetRageDist(boss, this_plugin_name, ability_name));
			float newDistance=distance;
			Action action=Plugin_Continue;

			Call_StartForward(OnHaleRage);
			Call_PushFloatRef(newDistance);
			Call_Finish(action);
			if(action!=Plugin_Continue && action!=Plugin_Changed)
			{
				return Plugin_Continue;
			}
			else if(action==Plugin_Changed)
			{
				distance=newDistance;
			}
		}
	}

	if(!strcmp(ability_name, "charge_weightdown"))
	{
		Charge_WeighDown(boss, slot);
	}
	else if(!strcmp(ability_name, "charge_bravejump"))
	{
		//char name[64];
		//FF2_GetBossSpecial(boss, name, sizeof(name));
		//PrintToServer("[FF2] Warning: \"charge_bravejump\" has been deprecated!  Please use ff2_dynamic_defaults for %s", name);
		Charge_BraveJump(ability_name, boss, slot, status);
	}
	else if(!strcmp(ability_name, "charge_teleport"))
	{
		//char name[64];
		//FF2_GetBossSpecial(boss, name, sizeof(name));
		//PrintToServer("[FF2] Warning: \"charge_teleport\" has been deprecated!  Please use ff2_dynamic_defaults for %s", name);
		Charge_Teleport(ability_name, boss, slot, status);
	}
	else if(!strcmp(ability_name, "rage_uber"))
	{
		int client=GetClientOfUserId(FF2_GetBossUserId(boss));
		TF2_AddCondition(client, TFCond_Ubercharged, view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 1, 5.0)));
		SetEntProp(client, Prop_Data, "m_takedamage", 0);
		CreateTimer(view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 1, 5.0)), Timer_StopUber, boss, TIMER_FLAG_NO_MAPCHANGE);
	}
	else if(!strcmp(ability_name, "rage_stun"))
	{
		CreateTimer(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 10, 0.0), Timer_Rage_Stun, boss);
	}
	else if(!strcmp(ability_name, "rage_stunsg"))
	{
		Rage_StunSentry(ability_name, boss);
	}
	else if(!strcmp(ability_name, "special_preventtaunt"))
	{
		PrintToServer("[FF2] Warning: \"special_preventtaunt\" is used on %s.  Future update will make this ability block %s from taunting.", name, name);
	}
	else if(!strcmp(ability_name, "rage_instant_teleport"))
	{
		int client=GetClientOfUserId(FF2_GetBossUserId(boss));
		float position[3];
		bool otherTeamIsAlive;
	// Stun Duration
		float stun=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 1, 2.0));
	// Friendly Teleport
		//bool friendly=view_as<bool>(FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 2, 1));
	// Stun Flags
		char flagOverrideStr[12];
		FF2_GetAbilityArgumentString(boss, this_plugin_name, ability_name, 3, flagOverrideStr, sizeof(flagOverrideStr));
		int flagOverride = ReadHexOrDecInt(flagOverrideStr);
		if(strlen(flagOverride)==0)
			flagOverride=TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT;
	// Slowdown
		float slowdown=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 4, 0.75));
	// Sound To Client
		bool sounds=view_as<bool>(FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 5, 1));
	// Particle Effect
		char particleEffect[48];
		FF2_GetAbilityArgumentString(boss, this_plugin_name, ability_name, 6, particleEffect, sizeof(particleEffect));

		for(int target=1; target<=MaxClients; target++)
		{
			if(IsClientInGame(target) && IsPlayerAlive(target) && target!=client && !(FF2_GetFF2flags(target) & FF2FLAG_ALLOWSPAWNINBOSSTEAM))
			{
				otherTeamIsAlive=true;
				break;
			}
		}

		if(!otherTeamIsAlive)
		{
			return Plugin_Continue;
		}

		int target, tries;
		do
		{
			tries++;
			target=GetRandomInt(1, MaxClients);
			if(tries==100)
			{
				return Plugin_Continue;
			}
		}
		while(!IsValidEntity(target) || target==client || (FF2_GetFF2flags(target) & FF2FLAG_ALLOWSPAWNINBOSSTEAM) || !IsPlayerAlive(target));

		if(strlen(particleEffect)>0)
		{
			CreateTimer(3.0, Timer_RemoveEntity, EntIndexToEntRef(AttachParticle(client, particleEffect)), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(3.0, Timer_RemoveEntity, EntIndexToEntRef(AttachParticle(client, particleEffect, _, false)), TIMER_FLAG_NO_MAPCHANGE);
		}

		if(IsValidEntity(target))
		{
			GetEntPropVector(target, Prop_Send, "m_vecOrigin", position);
			SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + 2.0);
			if(GetEntProp(target, Prop_Send, "m_bDucked"))
			{
				float temp[3]={24.0, 24.0, 62.0};  //Compiler won't accept directly putting it into SEPV -.-
				SetEntPropVector(client, Prop_Send, "m_vecMaxs", temp);
				SetEntProp(client, Prop_Send, "m_bDucked", 1);
				SetEntityFlags(client, GetEntityFlags(client)|FL_DUCKING);
				CreateTimer(0.2, Timer_StunBoss, boss, TIMER_FLAG_NO_MAPCHANGE); // TODO: Make this use new args
			}
			else
			{
				TF2_StunPlayer(client, stun, slowdown, flagOverride, sounds==1 ? target : 0);
			}
			TeleportEntity(client, position, NULL_VECTOR, NULL_VECTOR);
		}
	}
	else if(!strcmp(ability_name, "special_notripledamage"))
	{
		PrintToServer("[FF2] Warning: \"special_notripledamage\" is used on %s.  This ability was only present on BBG, use \"triple\" setting instead.", name);
	}
	return Plugin_Continue;
}

void Rage_Stun(const char[] ability_name, int boss)
{
	int client=GetClientOfUserId(FF2_GetBossUserId(boss));
	int victims=-1;
	bool solorage;
	float bossPosition[3], targetPosition[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", bossPosition);
 // Initial Duration
	float duration=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 1, 5.0));
 // Distance
	float distance=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 2, -1.0));
	if(distance<=0)
		distance=view_as<float>(FF2_GetRageDist(boss, this_plugin_name, ability_name));
 // Stun Flags
	char flagOverrideStr[12];
	FF2_GetAbilityArgumentString(boss, this_plugin_name, ability_name, 3, flagOverrideStr, sizeof(flagOverrideStr));
	int flagOverride = ReadHexOrDecInt(flagOverrideStr);
	if(strlen(flagOverride)==0)
		flagOverride=TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT;
 // Slowdown
	float slowdown=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 4, 0.75));
 // Sound To Boss
	bool sounds=view_as<bool>(FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 5, 1));
 // Particle Effect
	char particleEffect[48];
	FF2_GetAbilityArgumentString(boss, this_plugin_name, ability_name, 6, particleEffect, sizeof(particleEffect));
	if(strlen(particleEffect)==0)
		particleEffect=SPOOK;
 // Ignore
	int ignore=FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 7, 0);
 // Friendly Fire
	int friendly=FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 8, -1);
	if(friendly<0)
		friendly=GetConVarInt(FindConVar("mp_friendlyfire"));
 // Remove Parachute
	bool removeBaseJumperOnStun=view_as<bool>(FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 9, GetConVarInt(cvarBaseJumperStun)));
 // Max Duration
	float maxduration=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 11, -1.0));
 // Add Duration
	float addduration=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 12, 0.0));
	if(maxduration<=0)
	{
		maxduration=duration;
		addduration=0.0;
	}
 // Solo Rage Duration
	float soloduration=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 13, -1.0));
	if(soloduration<=0)
	{
		soloduration=duration;
	}

	if((addduration!=0 || soloduration!=duration) && !Outdated)
	{
		for(int target=1; target<=MaxClients; target++)
		{
			if(IsClientInGame(target) && IsPlayerAlive(target) && ((friendly==1 || GetClientTeam(target)!=BossTeam) || target!=client))
			{
				GetEntPropVector(target, Prop_Send, "m_vecOrigin", targetPosition);
				if((!TF2_IsPlayerInCondition(target, TFCond_Ubercharged) || (ignore>0 && ignore!=2)) && (!TF2_IsPlayerInCondition(target, TFCond_MegaHeal) || ignore>1) && GetVectorDistance(bossPosition, targetPosition)<=distance)
				{
					victims++;
				}
			}
		}
	}
	if(victims>=0)
	{
		if(victims==0 && (duration!=soloduration || GetConVarBool(cvarSoloShame)))
		{
			solorage=true;
			if(duration!=soloduration)
				duration=soloduration;
		}
		else if(victims>0 && duration<maxduration)
		{
			duration+=addduration*victims;
			if(duration>maxduration)
				duration=maxduration;
		}
	}
	for(int target=1; target<=MaxClients; target++)
	{
		if(IsClientInGame(target) && IsPlayerAlive(target) && ((friendly==1 || GetClientTeam(target)!=BossTeam) || target!=client))
		{
			GetEntPropVector(target, Prop_Send, "m_vecOrigin", targetPosition);
			if((!TF2_IsPlayerInCondition(target, TFCond_Ubercharged) || (ignore>0 && ignore!=2)) && (!TF2_IsPlayerInCondition(target, TFCond_MegaHeal) || ignore>1) && GetVectorDistance(bossPosition, targetPosition)<=distance)
			{
				if(removeBaseJumperOnStun)
				{
					TF2_RemoveCondition(target, TFCond_Parachute);
				}
				if(solorage)
				{
					CreateTimer(duration, Timer_SoloRageResult, target);
					CPrintToChatAll("{olive}[FF2]{default} %t", "Solo Rage", bossName);
				}
				TF2_StunPlayer(target, duration, slowdown, flagOverride, sounds ? client : 0);
				CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(AttachParticle(target, particleEffect, 75.0)), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}

public Action Timer_SoloRageResult(Handle timer, any client)
{
	if(!IsClientInGame(client) || FF2_GetRoundState()!=1)
		return Plugin_Continue;

	if(IsPlayerAlive(client))
		CPrintToChatAll("{olive}[FF2]{default} %t", "Solo Rage Fail");
	else
		CPrintToChatAll("{olive}[FF2]{default} %t", "Solo Rage Win");

	return Plugin_Continue;
}

public Action Timer_StopUber(Handle timer, any boss)
{
	SetEntProp(GetClientOfUserId(FF2_GetBossUserId(boss)), Prop_Data, "m_takedamage", 2);
	return Plugin_Continue;
}

void Rage_StunSentry(const char[] ability_name, int boss)
{
	int client=GetClientOfUserId(FF2_GetBossUserId(boss));
	float bossPosition[3], sentryPosition[3];
	GetEntPropVector(GetClientOfUserId(FF2_GetBossUserId(boss)), Prop_Send, "m_vecOrigin", bossPosition);

 // Duration
	float duration=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 1, 7.0));
 // Distance
	float distance=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 2, -1.0));
	if(distance<=0)
		distance=view_as<float>(FF2_GetRageDist(boss, this_plugin_name, ability_name));
 // Sentry Health
 	bool destory=false;
	float health=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 3, 1.0));
	if(health<=0)
		destory=true;
 // Sentry Ammo
	float ammo=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 4, 1.0));
 // Sentry Rockets
	float rockets=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 5, 1.0));
 // Particle Effect
	char particleEffect[48];
	FF2_GetAbilityArgumentString(boss, this_plugin_name, ability_name, 6, particleEffect, sizeof(particleEffect));
	if(strlen(particleEffect)==0)
		particleEffect=SPOOK;
 // Buildings
	int buildings=FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 7, 1);
	// 1: Sentry
	// 2: Dispenser
	// 3: Teleporter
	// 4: Sentry + Dispenser
	// 5: Sentry + Teleporter
	// 6: Dispenser + Teleporter
	// 7: ALL
 // Friendly Fire
	int friendly=FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 8, -1);
	if(friendly<0)
		friendly=GetConVarInt(FindConVar("mp_friendlyfire"));

	if(buildings>0 && buildings!=2 && buildings!=3 && buildings!=6)
	{
		int sentry;
		while((sentry=FindEntityByClassname(sentry, "obj_sentrygun"))!=-1)
		{
			if((((GetEntProp(sentry, Prop_Send, "m_nSkin") % 2)!=(GetClientTeam(client) % 2)) || friendly>0) && !GetEntProp(sentry, Prop_Send, "m_bCarried") && !GetEntProp(sentry, Prop_Send, "m_bPlacing"))
			{
				GetEntPropVector(sentry, Prop_Send, "m_vecOrigin", sentryPosition);
				if(GetVectorDistance(bossPosition, sentryPosition)<=distance)
				{
					if(destory)
						SDKHooks_TakeDamage(sentry, client, client, 9001.0, DMG_GENERIC, -1);
					else
					{
						if(health!=1)
							SDKHooks_TakeDamage(sentry, client, client, GetEntProp(sentry, Prop_Send, "m_iMaxHealth")*health, DMG_GENERIC, -1);
						if(ammo>=0 && ammo<=1 && ammo!=1)
							SetEntProp(sentry, Prop_Send, "m_iAmmoShells", GetEntProp(sentry, Prop_Send, "m_iAmmoShells")*ammo);
						if(rockets>=0 && rockets<=1 && rockets!=1)
							SetEntProp(sentry, Prop_Send, "m_iAmmoRockets", GetEntProp(sentry, Prop_Send, "m_iAmmoRockets")*rockets);
						if(duration>0)
						{
							SetEntProp(sentry, Prop_Send, "m_bDisabled", 1);
							CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(AttachParticle(sentry, particleEffect, 75.0)), TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(duration, Timer_EnableSentry, EntIndexToEntRef(sentry), TIMER_FLAG_NO_MAPCHANGE);
						}
					}
				}
			}
		}
	}
	if(buildings>1 && buildings!=3 && buildings!=5)
	{
		int dispenser;
		while((dispenser=FindEntityByClassname(dispenser, "obj_dispenser"))!=-1)
		{
			if((((GetEntProp(dispenser, Prop_Send, "m_nSkin") % 2)!=(GetClientTeam(client) % 2)) || friendly>0) && !GetEntProp(dispenser, Prop_Send, "m_bCarried") && !GetEntProp(dispenser, Prop_Send, "m_bPlacing"))
			{
				GetEntPropVector(dispenser, Prop_Send, "m_vecOrigin", sentryPosition);
				if(GetVectorDistance(bossPosition, sentryPosition)<=distance)
				{
					if(destory)
						SDKHooks_TakeDamage(dispenser, client, client, 9001.0, DMG_GENERIC, -1);
					else
					{
						if(health!=1)
							SDKHooks_TakeDamage(dispenser, client, client, GetEntProp(dispenser, Prop_Send, "m_iMaxHealth")*health, DMG_GENERIC, -1);
						if(duration>0)
						{
							SetEntProp(dispenser, Prop_Send, "m_bDisabled", 1);
							CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(AttachParticle(dispenser, particleEffect, 75.0)), TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(duration, Timer_EnableSentry, EntIndexToEntRef(dispenser), TIMER_FLAG_NO_MAPCHANGE);
						}
					}
				}
			}
		}
	}
	if(buildings>2 && buildings!=4)
	{
		int teleporter;
		while((teleporter=FindEntityByClassname(teleporter, "obj_teleporter"))!=-1)
		{
			if((((GetEntProp(teleporter, Prop_Send, "m_nSkin") % 2)!=(GetClientTeam(client) % 2)) || friendly>0) && !GetEntProp(teleporter, Prop_Send, "m_bCarried") && !GetEntProp(teleporter, Prop_Send, "m_bPlacing"))
			{
				GetEntPropVector(teleporter, Prop_Send, "m_vecOrigin", sentryPosition);
				if(GetVectorDistance(bossPosition, sentryPosition)<=distance)
				{
					if(destory)
						SDKHooks_TakeDamage(teleporter, client, client, 9001.0, DMG_GENERIC, -1);
					else
					{
						if(health!=1)
							SDKHooks_TakeDamage(teleporter, client, client, GetEntProp(teleporter, Prop_Send, "m_iMaxHealth")*health, DMG_GENERIC, -1);
						if(duration>0)
						{
							SetEntProp(teleporter, Prop_Send, "m_bDisabled", 1);
							CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(AttachParticle(teleporter, particleEffect, 75.0)), TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(duration, Timer_EnableSentry, EntIndexToEntRef(teleporter), TIMER_FLAG_NO_MAPCHANGE);
						}
					}
				}
			}
		}
	}
}

public Action Timer_EnableSentry(Handle timer, any sentryid)
{
	int sentry=EntRefToEntIndex(sentryid);
	if(FF2_GetRoundState()==1 && sentry>MaxClients)
	{
		SetEntProp(sentry, Prop_Send, "m_bDisabled", 0);
	}
	return Plugin_Continue;
}

int Charge_BraveJump(const char[] ability_name, int boss, int slot, int status)
{
	int client=GetClientOfUserId(FF2_GetBossUserId(boss));
	float charge=view_as<float>(FF2_GetBossCharge(boss, slot));
	float multiplier=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 3, 1.0));
	bool oldJump=view_as<bool>(FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 4, GetConVarInt(cvarOldJump)));

	switch(status)
	{
		case 1:
		{
			SetHudTextParams(-1.0, 0.88, 0.15, 255, 255, 255, 255);
			FF2_ShowSyncHudText(client, jumpHUD, "%t", "jump_status_2", -RoundFloat(charge));
		}
		case 2:
		{
			SetHudTextParams(-1.0, 0.88, 0.15, 255, 255, 255, 255);
			if(enableSuperDuperJump[boss])
			{
				SetHudTextParams(-1.0, 0.88, 0.15, 255, 64, 64, 255);
				FF2_ShowSyncHudText(client, jumpHUD, "%t", "super_duper_jump");
			}
			else
			{
				FF2_ShowSyncHudText(client, jumpHUD, "%t", "jump_status", RoundFloat(charge));
			}
		}
		case 3:
		{
			bool superJump=enableSuperDuperJump[boss];
			Action action=Plugin_Continue;
			Call_StartForward(OnHaleJump);
			Call_PushCellRef(superJump);
			Call_Finish(action);
			if(action!=Plugin_Continue && action!=Plugin_Changed)
			{
				return;
			}
			else if(action==Plugin_Changed)
			{
				enableSuperDuperJump[client]=superJump;
			}

			float position[3], velocity[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);

			if(oldJump)
			{
				if(enableSuperDuperJump[boss])
				{
					velocity[2]=(750+(charge/4)*13.0*multiplier)+2000;
					enableSuperDuperJump[boss]=false;
				}
				else
				{
					velocity[2]=750+(charge/4)*13.0*multiplier;
				}
				SetEntProp(client, Prop_Send, "m_bJumping", 1);
				velocity[0]*=(1+Sine((charge/4)*FLOAT_PI/50));
				velocity[1]*=(1+Sine((charge/4)*FLOAT_PI/50));
			}
			else
			{
				float angles[3];
				GetClientEyeAngles(client, angles);
				if(enableSuperDuperJump[boss])
				{
					velocity[0]+=Cosine(DegToRad(angles[0]))*Cosine(DegToRad(angles[1]))*500*multiplier;
					velocity[1]+=Cosine(DegToRad(angles[0]))*Sine(DegToRad(angles[1]))*500*multiplier;
					velocity[2]=(750.0+175.0*charge/70+2000)*multiplier;
					enableSuperDuperJump[boss]=false;
				}
				else
				{
					velocity[0]+=Cosine(DegToRad(angles[0]))*Cosine(DegToRad(angles[1]))*100*multiplier;
					velocity[1]+=Cosine(DegToRad(angles[0]))*Sine(DegToRad(angles[1]))*100*multiplier;
					velocity[2]=(750.0+175.0*charge/70)*multiplier;
				}
			}

			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
			char sound[PLATFORM_MAX_PATH];
			if(FF2_RandomSound("sound_ability", sound, PLATFORM_MAX_PATH, boss, slot))
			{
				EmitSoundToAll(sound, client, _, _, _, _, _, client, position);
				EmitSoundToAll(sound, client, _, _, _, _, _, client, position);

				for(int target=1; target<=MaxClients; target++)
				{
					if(IsClientInGame(target) && target!=client)
					{
						EmitSoundToClient(target, sound, client, _, _, _, _, _, client, position);
						EmitSoundToClient(target, sound, client, _, _, _, _, _, client, position);
					}
				}
			}
		}
	}
}

int Charge_Teleport(const char[] ability_name, int boss, int slot, int status)
{
	int client=GetClientOfUserId(FF2_GetBossUserId(boss));
	float charge=view_as<float>(FF2_GetBossCharge(boss, slot));
	switch(status)
	{
		case 1:
		{
			SetHudTextParams(-1.0, 0.88, 0.15, 255, 255, 255, 255);
			FF2_ShowSyncHudText(client, jumpHUD, "%t", "teleport_status_2", -RoundFloat(charge));
		}
		case 2:
		{
			SetHudTextParams(-1.0, 0.88, 0.15, 255, 255, 255, 255);
			FF2_ShowSyncHudText(client, jumpHUD, "%t", "teleport_status", RoundFloat(charge));
		}
		case 3:
		{
			Action action=Plugin_Continue;
			bool superJump=enableSuperDuperJump[boss];
			Call_StartForward(OnHaleJump);
			Call_PushCellRef(superJump);
			Call_Finish(action);
			if(action!=Plugin_Continue && action!=Plugin_Changed)
			{
				return;
			}
			else if(action==Plugin_Changed)
			{
				enableSuperDuperJump[boss]=superJump;
			}

			if(enableSuperDuperJump[boss])
			{
				enableSuperDuperJump[boss]=false;
			}
			else if(charge<100)
			{
				CreateTimer(0.1, Timer_ResetCharge, boss*10000+slot, TIMER_FLAG_NO_MAPCHANGE);  //FIXME: Investigate.
				return;
			}

			int tries;
			bool otherTeamIsAlive;
			for(int target=1; target<=MaxClients; target++)
			{
				if(IsClientInGame(target) && IsPlayerAlive(target) && target!=client && !(FF2_GetFF2flags(target) & FF2FLAG_ALLOWSPAWNINBOSSTEAM))
				{
					otherTeamIsAlive=true;
					break;
				}
			}

			int target;
			do
			{
				tries++;
				target=GetRandomInt(1, MaxClients);
				if(tries==100)
				{
					return;
				}
			}
			while(otherTeamIsAlive && (!IsValidEntity(target) || target==client || (FF2_GetFF2flags(target) & FF2FLAG_ALLOWSPAWNINBOSSTEAM) || !IsPlayerAlive(target)));

			char particle[PLATFORM_MAX_PATH];
			FF2_GetAbilityArgumentString(boss, this_plugin_name, ability_name, 3, particle, sizeof(particle));
			if(strlen(particle)>0)
			{
				CreateTimer(3.0, Timer_RemoveEntity, EntIndexToEntRef(AttachParticle(client, particle)), TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(3.0, Timer_RemoveEntity, EntIndexToEntRef(AttachParticle(client, particle, _, false)), TIMER_FLAG_NO_MAPCHANGE);
			}

			float position[3];
			GetEntPropVector(target, Prop_Data, "m_vecOrigin", position);
			if(IsValidEntity(target))
			{
				GetEntPropVector(target, Prop_Send, "m_vecOrigin", position);
				SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + (enableSuperDuperJump ? 4.0:2.0));
				if(GetEntProp(target, Prop_Send, "m_bDucked"))
				{
					float temp[3]={24.0, 24.0, 62.0};  //Compiler won't accept directly putting it into SEPV -.-
					SetEntPropVector(client, Prop_Send, "m_vecMaxs", temp);
					SetEntProp(client, Prop_Send, "m_bDucked", 1);
					SetEntityFlags(client, GetEntityFlags(client)|FL_DUCKING);
					CreateTimer(0.2, Timer_StunBoss, boss, TIMER_FLAG_NO_MAPCHANGE);
				}
				else
				{
					TF2_StunPlayer(client, (enableSuperDuperJump ? 4.0 : 2.0), 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, target);
				}

				GoombaBlockedUntil[client]=GetEngineTime()+3.0;
				TeleportEntity(client, position, NULL_VECTOR, NULL_VECTOR);
				if(strlen(particle)>0)
				{
					CreateTimer(3.0, Timer_RemoveEntity, EntIndexToEntRef(AttachParticle(client, particle)), TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(3.0, Timer_RemoveEntity, EntIndexToEntRef(AttachParticle(client, particle, _, false)), TIMER_FLAG_NO_MAPCHANGE);
				}
			}

			char sound[PLATFORM_MAX_PATH];
			if(FF2_RandomSound("sound_ability", sound, PLATFORM_MAX_PATH, boss, slot))
			{
				EmitSoundToAll(sound, client, _, _, _, _, _, client, position);
				EmitSoundToAll(sound, client, _, _, _, _, _, client, position);

				for(int enemy=1; enemy<=MaxClients; enemy++)
				{
					if(IsClientInGame(enemy) && enemy!=client)
					{
						EmitSoundToClient(enemy, sound, client, _, _, _, _, _, client, position);
						EmitSoundToClient(enemy, sound, client, _, _, _, _, _, client, position);
					}
				}
			}
		}
	}
}

public Action Timer_ResetCharge(Handle timer, any boss)  //FIXME: What.
{
	int slot=boss%10000;
	boss/=1000;
	FF2_SetBossCharge(boss, slot, 0.0);
}

public Action Timer_StunBoss(Handle timer, any boss)
{
	int client=GetClientOfUserId(FF2_GetBossUserId(boss));
	if(!IsValidEntity(client))
	{
		return;
	}
	TF2_StunPlayer(client, (enableSuperDuperJump[boss] ? 4.0 : 2.0), 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, client);
}

int Charge_WeighDown(int boss, int slot)  //TODO: Create a HUD for this
{
	int client=GetClientOfUserId(FF2_GetBossUserId(boss));
	if(client<=0 || !(GetClientButtons(client) & IN_DUCK))
	{
		return;
	}

	float charge=FF2_GetBossCharge(boss, slot)+0.2;
	if(!(GetEntityFlags(client) & FL_ONGROUND))
	{
		if(charge>=4.0)
		{
			float angles[3];
			GetClientEyeAngles(client, angles);
			if(angles[0]>60.0)
			{
				Action action=Plugin_Continue;
				Call_StartForward(OnHaleWeighdown);
				Call_Finish(action);
				if(action!=Plugin_Continue && action!=Plugin_Changed)
				{
					return;
				}

				Handle data;
				float velocity[3];
				if(gravityDatapack[client]==INVALID_HANDLE)
				{
					gravityDatapack[client]=CreateDataTimer(2.0, Timer_ResetGravity, data, TIMER_FLAG_NO_MAPCHANGE);
					WritePackCell(data, GetClientUserId(client));
					WritePackFloat(data, GetEntityGravity(client));
					ResetPack(data);
				}

				GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
				velocity[2]=-1000.0;
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
				SetEntityGravity(client, 6.0);

				FF2_SetBossCharge(boss, slot, 0.0);
			}
		}
		else
		{
			FF2_SetBossCharge(boss, slot, charge);
		}
	}
	else if(charge>0.3 || charge<0)
	{
		FF2_SetBossCharge(boss, slot, 0.0);
	}
}

public Action Timer_ResetGravity(Handle timer, Handle data)
{
	int client=GetClientOfUserId(ReadPackCell(data));
	if(client && IsValidEntity(client) && IsClientInGame(client))
	{
		SetEntityGravity(client, ReadPackFloat(data));
	}
	gravityDatapack[client]=INVALID_HANDLE;
	return Plugin_Continue;
}

public Action OnPlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	int boss=FF2_GetBossIndex(GetClientOfUserId(GetEventInt(event, "attacker")));
	if(boss!=-1 && FF2_HasAbility(boss, this_plugin_name, "special_dissolve"))
	{
		CreateTimer(0.1, Timer_DissolveRagdoll, GetEventInt(event, "userid"), TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Continue;
}

public Action Timer_DissolveRagdoll(Handle timer, any userid)
{
	int client=GetClientOfUserId(userid);
	int ragdoll=-1;
	if(client && IsClientInGame(client))
	{
		ragdoll=GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	}

	if(IsValidEntity(ragdoll))
	{
		DissolveRagdoll(ragdoll);
	}
}

int DissolveRagdoll(int ragdoll)
{
	int dissolver=CreateEntityByName("env_entity_dissolver");
	if(dissolver==-1)
	{
		return;
	}

	DispatchKeyValue(dissolver, "dissolvetype", "0");
	DispatchKeyValue(dissolver, "magnitude", "200");
	DispatchKeyValue(dissolver, "target", "!activator");

	AcceptEntityInput(dissolver, "Dissolve", ragdoll);
	AcceptEntityInput(dissolver, "Kill");
}

public Action Timer_RemoveEntity(Handle timer, any entid)
{
	int entity=EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		AcceptEntityInput(entity, "Kill");
	}
}

stock int AttachParticle(int entity, char[] particleType, float offset=0.0, bool attach=true)
{
	int particle=CreateEntityByName("info_particle_system");

	char targetName[128];
	float position[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
	position[2]+=offset;
	TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);

	Format(targetName, sizeof(targetName), "target%i", entity);
	DispatchKeyValue(entity, "targetname", targetName);

	DispatchKeyValue(particle, "targetname", "tf2particle");
	DispatchKeyValue(particle, "parentname", targetName);
	DispatchKeyValue(particle, "effect_name", particleType);
	DispatchSpawn(particle);
	SetVariantString(targetName);
	if(attach)
	{
		AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		SetEntPropEnt(particle, Prop_Send, "m_hOwnerEntity", entity);
	}
	ActivateEntity(particle);
	AcceptEntityInput(particle, "start");
	return particle;
}

public Action OnDeflect(Handle event, const char[] name, bool dontBroadcast)
{
	int boss=FF2_GetBossIndex(GetClientOfUserId(GetEventInt(event, "userid")));
	if(boss!=-1)
	{
		if(UberRageCount[boss]>11)
		{
			UberRageCount[boss]-=10;
		}
	}
	return Plugin_Continue;
}

public Action FF2_OnTriggerHurt(int boss, int triggerhurt, float &damage)
{
	enableSuperDuperJump[boss]=true;
	if(FF2_GetBossCharge(boss, 1)<0)
	{
		FF2_SetBossCharge(boss, 1, 0.0);
	}
	return Plugin_Continue;
}

public Action OnStomp(int attacker, int victim, float &damageMult, float &damageBonus, float &jumpPower)
{
	if(IsPlayerAlive(attacker) && GoombaBlockedUntil[attacker]>GetEngineTime())
	{
		// I'm doing it this way instead of Plugin_Handled so the boss also gets out of goomba range
		// this method causes the boss to jump up when the 0 damage goomba happens.
		damageMult = 0.0;
		damageBonus = 0.0;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

stock int ReadHexOrDecInt(char hexOrDecString[12])	// Credits to sarysa
{
	if(StrContains(hexOrDecString, "0x")==0)
	{
		int result=0;
		for(int i=2; i<10 && hexOrDecString[i]!=0; i++)
		{
			result=result<<4;
				
			if(hexOrDecString[i]>='0' && hexOrDecString[i]<='9')
				result+=hexOrDecString[i]-'0';
			else if(hexOrDecString[i]>='a' && hexOrDecString[i]<='f')
				result+=hexOrDecString[i]-'a'+10;
			else if(hexOrDecString[i]>='A' && hexOrDecString[i]<='F')
				result+=hexOrDecString[i]-'A'+10;
		}
		return result;
	}
	else
		return StringToInt(hexOrDecString);
}

stock int ReadHexOrDecString(int boss, const char[] ability_name, int args)
{
	static char hexOrDecString[12];
	FF2_GetAbilityArgumentString(boss, this_plugin_name, ability_name, args, hexOrDecString, sizeof(hexOrDecString));
	return ReadHexOrDecInt(hexOrDecString);
}
