#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2items>
#include <tf2_stocks>
#include <freak_fortress_2>
#include <freak_fortress_2_subplugin>

#pragma newdecls required

#define MAJOR_REVISION	"0"
#define MINOR_REVISION	"1"
#define STABLE_REVISION	"0"
#define PLUGIN_VERSION MAJOR_REVISION..."."...MINOR_REVISION..."."...STABLE_REVISION

#define PROJECTILE	"model_projectile_replace"
#define OBJECTS		"spawn_many_objects_on_kill"
#define OBJECTS_DEATH	"spawn_many_objects_on_death"

#define SPOOK "yikes_fx"

Handle OnHaleRage;
Handle jumpHUD;

float UberRageCount[MAXPLAYERS+1];
int BossTeam=view_as<int>(TFTeam_Blue);

ConVar cvarBaseJumperStun;
ConVar cvarSoloShame;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	OnHaleJump=CreateGlobalForward("VSH_OnDoJump", ET_Hook, Param_CellByRef);
	OnHaleRage=CreateGlobalForward("VSH_OnDoRage", ET_Hook, Param_FloatByRef);
	OnHaleWeighdown=CreateGlobalForward("VSH_OnDoWeighdown", ET_Hook);
	return APLRes_Success;
}

public Plugin myinfo=
{
	name		=	"Unofficial Freak Fortress 2: New Defaults",
	author		=	"Many many people",
	description	=	"FF2: Combined subplugin of default abilties",
	version		=	PLUGIN_VERSION
};

public void OnPluginStart2()
{
	int fversion[3];
	FF2_GetForkVersion(fversion);
	if(fversion[0]==1 && fversion[1]<18)
	{
		SetFailState("This subplugin depends on at least Unofficial FF2 v1.18.0");
	}

	jumpHUD=CreateHudSynchronizer();

	HookEvent("object_deflected", OnDeflect, EventHookMode_Pre);
	HookEvent("teamplay_round_start", OnRoundStart);
	HookEvent("player_death", OnPlayerDeath);

	PrecacheSound("items/pumpkin_pickup.wav");

	LoadTranslations("freak_fortress_2.phrases");
}

public void OnAllPluginsLoaded()
{
	cvarOldJump=FindConVar("ff2_oldjump");  //Created in freak_fortress_2.sp
	cvarBaseJumperStun=FindConVar("ff2_base_jumper_stun");
	cvarSoloShame=FindConVar("ff2_solo_shame");
}

public Action FF2_OnAbility2(int boss, const char[] plugin_name, const char[] ability_name, int status)
{
    /*
       Rages
    */
	if(!strcmp(ability_name, "rage_new_weapon"))
	{
		Rage_New_Weapon(boss, ability_name);
	}
	else if(!strcmp(ability_name, "rage_overlay"))
	{
		Rage_Overlay(boss, ability_name);
	}
	else if(!strcmp(ability_name, "rage_uber"))
	{
		int client=GetClientOfUserId(FF2_GetBossUserId(boss));
		TF2_AddCondition(client, TFCond_Ubercharged, FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 1, 5.0));
		SetEntProp(client, Prop_Data, "m_takedamage", 0);
		CreateTimer(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 1, 5.0), Timer_StopUber, boss, TIMER_FLAG_NO_MAPCHANGE);
	}
	else if(!strcmp(ability_name, "rage_stun"))
	{
		CreateTimer(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 10, 0.0), Timer_Rage_Stun, boss);
	}
	else if(!strcmp(ability_name, "rage_stunsg"))
	{
		Rage_StunBuilding(ability_name, boss);
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
		if(flagOverride==0)
			flagOverride=TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT;
	// Slowdown
		float slowdown=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 4, 0.0));
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
				if(sounds)
					TF2_StunPlayer(client, stun, slowdown, flagOverride, target);
				else
					TF2_StunPlayer(client, stun, slowdown, flagOverride, 0);
			}
			TeleportEntity(client, position, NULL_VECTOR, NULL_VECTOR);
		}
	}
    /*
       Specials
    */
	else if(!strcmp(ability_name, "special_preventtaunt"))
	{
		// TODO
	}
    /*
       Deprecated
    */
	else if(!strcmp(ability_name, "special_notripledamage"))
	{
		char name[64];
		FF2_GetBossSpecial(boss, name, sizeof(name));
		PrintToServer("[FF2] Warning: \"special_notripledamage\" is used on %s.  This ability was only present on BBG, use \"triple\" setting instead.", name);
	}
	else if(!strcmp(ability_name, "charge_weightdown"))
	{
		char name[64];
		FF2_GetBossSpecial(boss, name, sizeof(name));
		PrintToServer("[FF2] Warning: \"charge_teleport\" has been deprecated!  Please use ff2_dynamic_defaults for %s", name);
	}
	else if(!strcmp(ability_name, "charge_bravejump"))
	{
		char name[64];
		FF2_GetBossSpecial(boss, name, sizeof(name));
		PrintToServer("[FF2] Warning: \"charge_bravejump\" has been deprecated!  Please use ff2_dynamic_defaults for %s", name);
	}
	else if(!strcmp(ability_name, "charge_teleport"))
	{
		char name[64];
		FF2_GetBossSpecial(boss, name, sizeof(name));
		PrintToServer("[FF2] Warning: \"charge_teleport\" has been deprecated!  Please use ff2_dynamic_defaults for %s", name);
		Charge_Teleport(ability_name, boss, slot, status);
	}
	return Plugin_Continue;
}

public Action OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	for(int client; client<MaxClients; client++)
	{
		UberRageCount[client]=0.0;
	}

	CreateTimer(0.30, Timer_GetBossTeam, _, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.41, Timer_Disable_Anims, _, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(9.31, Timer_Disable_Anims, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}

public Action Timer_GetBossTeam(Handle timer)
{
	BossTeam=FF2_GetBossTeam();
	return Plugin_Continue;
}

public int OnPlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	int client=GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker=GetClientOfUserId(GetEventInt(event, "attacker"));
	if(!client || !attacker || !IsClientInGame(client) || !IsClientInGame(attacker))
	{
		return;
	}

	int boss=FF2_GetBossIndex(attacker);
	if(boss>=0 && FF2_HasAbility(boss, this_plugin_name, OBJECTS))
	{
		char classname[PLATFORM_MAX_PATH], model[PLATFORM_MAX_PATH];
		FF2_GetAbilityArgumentString(boss, this_plugin_name, OBJECTS, 1, classname, sizeof(classname));
		FF2_GetAbilityArgumentString(boss, this_plugin_name, OBJECTS, 2, model, sizeof(model));
		int skin=FF2_GetAbilityArgument(boss, this_plugin_name, OBJECTS, 3);
		int count=FF2_GetAbilityArgument(boss, this_plugin_name, OBJECTS, 4, 14);
		float distance=FF2_GetAbilityArgumentFloat(boss, this_plugin_name, OBJECTS, 5, 30.0);
		SpawnManyObjects(classname, client, model, skin, count, distance);
		return;
	}
	if(boss>=0 && FF2_HasAbility(boss, this_plugin_name, "special_dissolve"))
	{
		CreateTimer(0.1, Timer_DissolveRagdoll, GetEventInt(event, "userid"), TIMER_FLAG_NO_MAPCHANGE);
	}

	boss=FF2_GetBossIndex(client);
	if(boss>=0 && FF2_HasAbility(boss, this_plugin_name, OBJECTS_DEATH))
	{
		char classname[PLATFORM_MAX_PATH], model[PLATFORM_MAX_PATH];
		FF2_GetAbilityArgumentString(boss, this_plugin_name, OBJECTS_DEATH, 1, classname, sizeof(classname));
		FF2_GetAbilityArgumentString(boss, this_plugin_name, OBJECTS_DEATH, 2, model, sizeof(model));
		int skin=FF2_GetAbilityArgument(boss, this_plugin_name, OBJECTS_DEATH, 3);
		int count=FF2_GetAbilityArgument(boss, this_plugin_name, OBJECTS_DEATH, 4, 14);
		float distance=FF2_GetAbilityArgumentFloat(boss, this_plugin_name, OBJECTS_DEATH, 5, 30.0);
		SpawnManyObjects(classname, client, model, skin, count, distance);
		return;
	}
}

/*	No Animations	*/

public Action Timer_Disable_Anims(Handle timer)
{
	int client;
	for(int boss; (client=GetClientOfUserId(FF2_GetBossUserId(boss)))>0; boss++)
	{
		if(FF2_HasAbility(boss, this_plugin_name, "special_noanims"))
		{
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 0);
			SetEntProp(client, Prop_Send, "m_bCustomModelRotates", FF2_GetAbilityArgument(boss, this_plugin_name, "special_noanims", 1, 0));
		}
	}
	return Plugin_Continue;
}


/*	Easter  Abilities	*/

public void OnEntityCreated(int entity, const char[] classname)
{
	if(IsValidEntity(entity) && StrContains(classname, "tf_projectile")>=0)
	{
		SDKHook(entity, SDKHook_SpawnPost, OnProjectileSpawned);
	}
}

public void OnProjectileSpawned(int entity)
{
	int client=GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(client>0 && client<=MaxClients && IsClientInGame(client))
	{
		int boss=FF2_GetBossIndex(client);
		if(boss>=0 && FF2_HasAbility(boss, this_plugin_name, PROJECTILE))
		{
			char projectile[PLATFORM_MAX_PATH];
			FF2_GetAbilityArgumentString(boss, this_plugin_name, PROJECTILE, 1, projectile, sizeof(projectile));

			char classname[PLATFORM_MAX_PATH];
			GetEntityClassname(entity, classname, sizeof(classname));
			if(StrEqual(classname, projectile, false))
			{
				char model[PLATFORM_MAX_PATH];
				FF2_GetAbilityArgumentString(boss, this_plugin_name, PROJECTILE, 2, model, sizeof(model));
				if(IsModelPrecached(model))
				{
					SetEntityModel(entity, model);
				}
				else
				{
					char bossName[64];
					FF2_GetBossSpecial(boss, bossName, sizeof(bossName));
					LogError("[FF2 Bosses] Model %s (used by boss %s for ability %s) isn't precached!", model, bossName, PROJECTILE);
				}
			}
		}
	}
}

int SpawnManyObjects(char[] classname, int client, char[] model, int skin=0, int amount=14, float distance=30.0)
{
	if(!client || !IsClientInGame(client))
	{
		return;
	}

	float position[3], velocity[3];
	float angle[]={90.0, 0.0, 0.0};
	GetClientAbsOrigin(client, position);
	position[2]+=distance;
	for(int i; i<amount; i++)
	{
		velocity[0]=GetRandomFloat(-400.0, 400.0);
		velocity[1]=GetRandomFloat(-400.0, 400.0);
		velocity[2]=GetRandomFloat(300.0, 500.0);
		position[0]+=GetRandomFloat(-5.0, 5.0);
		position[1]+=GetRandomFloat(-5.0, 5.0);

		int entity=CreateEntityByName(classname);
		if(!IsValidEntity(entity))
		{
			LogError("[FF2] Invalid entity while spawning objects for New Defaults-check your configs!");
			continue;
		}

		SetEntityModel(entity, model);
		DispatchKeyValue(entity, "OnPlayerTouch", "!self,Kill,,0,-1");
		SetEntProp(entity, Prop_Send, "m_nSkin", skin);
		SetEntProp(entity, Prop_Send, "m_nSolidType", 6);
		SetEntProp(entity, Prop_Send, "m_usSolidFlags", 152);
		SetEntProp(entity, Prop_Send, "m_triggerBloat", 24);
		SetEntProp(entity, Prop_Send, "m_CollisionGroup", 1);
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(entity, Prop_Send, "m_iTeamNum", 2);
		DispatchSpawn(entity);
		TeleportEntity(entity, position, angle, velocity);
		SetEntProp(entity, Prop_Data, "m_iHealth", 900);
		int offs=GetEntSendPropOffs(entity, "m_vecInitialVelocity", true);
		SetEntData(entity, offs-4, 1, _, true);
	}
}


/*	Overlay		*/

void Rage_Overlay(int boss, const char[] ability_name)
{
	char overlay[PLATFORM_MAX_PATH];
	FF2_GetAbilityArgumentString(boss, this_plugin_name, ability_name, 1, overlay, PLATFORM_MAX_PATH);
	Format(overlay, PLATFORM_MAX_PATH, "r_screenoverlay \"%s\"", overlay);
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & ~FCVAR_CHEAT);
	for(int target=1; target<=MaxClients; target++)
	{
		if(IsClientInGame(target) && IsPlayerAlive(target) && GetClientTeam(target)!=BossTeam)
		{
			ClientCommand(target, overlay);
		}
	}

	CreateTimer(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, ability_name, 2, 6.0), Timer_Remove_Overlay, _, TIMER_FLAG_NO_MAPCHANGE);
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & FCVAR_CHEAT);
}

public Action Timer_Remove_Overlay(Handle timer)
{
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & ~FCVAR_CHEAT);
	for(int target=1; target<=MaxClients; target++)
	{
		if(IsClientInGame(target) && IsPlayerAlive(target) && GetClientTeam(target)!=BossTeam)
		{
			ClientCommand(target, "r_screenoverlay off");
		}
	}
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & FCVAR_CHEAT);
	return Plugin_Continue;
}


/*	New Weapon	*/

int Rage_New_Weapon(int boss, const char[] ability_name)
{
	int client=GetClientOfUserId(FF2_GetBossUserId(boss));
	if(!client || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return;
	}

	char classname[64], attributes[256];
	FF2_GetAbilityArgumentString(boss, this_plugin_name, ability_name, 1, classname, sizeof(classname));
	FF2_GetAbilityArgumentString(boss, this_plugin_name, ability_name, 3, attributes, sizeof(attributes));

	int slot=FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 4);
	TF2_RemoveWeaponSlot(client, slot);

	int index=FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 2);
	int weapon=SpawnWeapon(client, classname, index, 101, 5, attributes);
	if(StrEqual(classname, "tf_weapon_builder") && index!=735)  //PDA, normal sapper
	{
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 0);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 1);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 2);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 3);
	}
	else if(StrEqual(classname, "tf_weapon_sapper") || index==735)  //Sappers, normal sapper
	{
		SetEntProp(weapon, Prop_Send, "m_iObjectType", 3);
		SetEntProp(weapon, Prop_Data, "m_iSubType", 3);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 0);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 1);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 2);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 3);
	}

	if(FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 6))
	{
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
	}

	int ammo=FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 5, 0);
	int clip=FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 7, 0);
	if(ammo || clip)
	{
		FF2_SetAmmo(client, weapon, ammo, clip);
	}
}

stock int SpawnWeapon(int client, char[] name, int index, int level, int quality, char[] attribute)
{
	Handle weapon=TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	TF2Items_SetClassname(weapon, name);
	TF2Items_SetItemIndex(weapon, index);
	TF2Items_SetLevel(weapon, level);
	TF2Items_SetQuality(weapon, quality);
	char attributes[32][32];
	int count=ExplodeString(attribute, ";", attributes, 32, 32);
	if(count%2!=0)
	{
		count--;
	}

	if(count>0)
	{
		TF2Items_SetNumAttributes(weapon, count/2);
		int i2=0;
		for(int i=0; i<count; i+=2)
		{
			int attrib=StringToInt(attributes[i]);
			if(!attrib)
			{
				LogError("Bad weapon attribute passed: %s ; %s", attributes[i], attributes[i+1]);
				return -1;
			}
			TF2Items_SetAttribute(weapon, i2, attrib, StringToFloat(attributes[i+1]));
			i2++;
		}
	}
	else
	{
		TF2Items_SetNumAttributes(weapon, 0);
	}

	if(weapon==INVALID_HANDLE)
	{
		return -1;
	}

	int entity=TF2Items_GiveNamedItem(client, weapon);
	CloseHandle(weapon);
	EquipPlayerWeapon(client, entity);
	return entity;
}


/*	Stun	*/

public Action Timer_Rage_Stun(Handle timer, any boss)
{
	int client=GetClientOfUserId(FF2_GetBossUserId(boss));
	int victims=-1;
	bool solorage=false;
	char bossName[128];
	float bossPosition[3], targetPosition[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", bossPosition);
 // Initial Duration
	float duration=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, "rage_stun", 1, 5.0));
 // Distance
	float distance=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, "rage_stun", 2, -1.0));
	if(distance<=0)
		distance=view_as<float>(FF2_GetRageDist(boss, this_plugin_name, "rage_stun"));
 // Stun Flags
	char flagOverrideStr[12];
	FF2_GetAbilityArgumentString(boss, this_plugin_name, "rage_stun", 3, flagOverrideStr, sizeof(flagOverrideStr));
	int flagOverride = ReadHexOrDecInt(flagOverrideStr);
	if(flagOverride==0)
		flagOverride=TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT;
 // Slowdown
	float slowdown=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, "rage_stun", 4, 0.0));
 // Sound To Boss
	bool sounds=view_as<bool>(FF2_GetAbilityArgument(boss, this_plugin_name, "rage_stun", 5, 1));
 // Particle Effect
	char particleEffect[48];
	FF2_GetAbilityArgumentString(boss, this_plugin_name, "rage_stun", 6, particleEffect, sizeof(particleEffect));
	if(strlen(particleEffect)==0)
		particleEffect=SPOOK;
 // Ignore
	int ignore=FF2_GetAbilityArgument(boss, this_plugin_name, "rage_stun", 7, 0);
 // Friendly Fire
	int friendly=FF2_GetAbilityArgument(boss, this_plugin_name, "rage_stun", 8, -1);
	if(friendly<0)
		friendly=GetConVarInt(FindConVar("mp_friendlyfire"));
 // Remove Parachute
	bool removeBaseJumperOnStun=view_as<bool>(FF2_GetAbilityArgument(boss, this_plugin_name, "rage_stun", 9, GetConVarInt(cvarBaseJumperStun)));
 // Max Duration
	float maxduration=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, "rage_stun", 11, -1.0));
 // Add Duration
	float addduration=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, "rage_stun", 12, 0.0));
	if(maxduration<=0)
	{
		maxduration=duration;
		addduration=0.0;
	}
 // Solo Rage Duration
	float soloduration=view_as<float>(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, "rage_stun", 13, -1.0));
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
			FF2_GetBossSpecial(boss, bossName, sizeof(bossName));
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
				if(strlen(particleEffect)>1)
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


/*	Uber	*/

public Action Timer_StopUber(Handle timer, any boss)
{
	SetEntProp(GetClientOfUserId(FF2_GetBossUserId(boss)), Prop_Data, "m_takedamage", 2);
	return Plugin_Continue;
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


/*	Building Stun	*/

void Rage_StunBuilding(const char[] ability_name, int boss)
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
 // Building Health
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
							CreateTimer(duration, Timer_EnableBuilding, EntIndexToEntRef(sentry), TIMER_FLAG_NO_MAPCHANGE);
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
							CreateTimer(duration, Timer_EnableBuilding, EntIndexToEntRef(dispenser), TIMER_FLAG_NO_MAPCHANGE);
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
							CreateTimer(duration, Timer_EnableBuilding, EntIndexToEntRef(teleporter), TIMER_FLAG_NO_MAPCHANGE);
						}
					}
				}
			}
		}
	}
}

public Action Timer_EnableBuilding(Handle timer, any sentryid)
{
	int sentry=EntRefToEntIndex(sentryid);
	if(FF2_GetRoundState()==1 && sentry>MaxClients)
	{
		SetEntProp(sentry, Prop_Send, "m_bDisabled", 0);
	}
	return Plugin_Continue;
}


/*	Instant Teleport	*/


public Action Timer_StunBoss(Handle timer, any boss)
{
	int client=GetClientOfUserId(FF2_GetBossUserId(boss));
	if(!IsValidEntity(client))
	{
		return;
	}
	TF2_StunPlayer(client, 2.0, 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, client);
}


/*	Dissolve	*/

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


/*	Extras	*/

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
