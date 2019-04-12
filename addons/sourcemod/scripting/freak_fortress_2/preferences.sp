#define PREF_DUO	2
#define PREF_BOSS	3

#define TOGGLE_UNDEF	0
#define TOGGLE_ON	1
#define TOGGLE_OFF	2
#define TOGGLE_TEMP	3

char xIncoming[MAXPLAYERS+1][700];
char cIncoming[MAXPLAYERS+1][700];

public Action OnPlayerDisconnect(Handle event, const char[] name, bool dontBroadcast)
{
	if(!Enabled)
	{
		return Plugin_Continue;
	}

	if(playing>=GetConVarInt(cvarDuoMin) && !DuoMin)  // Check if theres enough players for companions
	{
		DuoMin=true;
	}
	else if(playing<GetConVarInt(cvarDuoMin) && DuoMin)
	{
		DuoMin=false;
	}
	int client=GetClientOfUserId(GetEventInt(event, "userid"));
	xIncoming[client] = "";
	return Plugin_Continue;
}

public Action BossMenuTimer(Handle timer, any clientpack)
{
	int clientId;
	ResetPack(clientpack);
	clientId = ReadPackCell(clientpack);
	CloseHandle(clientpack);
	GetClientCookie(clientId, FF2Cookies, cookies, sizeof(cookies));
	ExplodeString(cookies, " ", cookieValues, 8, 5);
	if(StringToInt(cookieValues[5])==0)
	{
		BossMenu(clientId, 0);
	}
}

public Action CompanionMenu(int client, int args)
{
	if(IsValidClient(client) && GetConVarBool(cvarDuoBoss))
	{
		CPrintToChat(client, "{olive}[FF2]{default} %t", "FF2 Companion Toggle Menu Title", ClientCookie2[client]);

		char sEnabled[2];
		GetClientCookie(client, CompanionCookie, sEnabled, sizeof(sEnabled));
		ClientCookie2[client] = StringToInt(sEnabled);	

		Handle menu = CreateMenu(MenuHandlerCompanion);
		SetGlobalTransTarget(client);
		SetMenuTitle(menu, "%t", "FF2 Companion Toggle Menu Title", ClientCookie2[client]);

		char menuoption[128];
		Format(menuoption, sizeof(menuoption), "%t", "Enable Companion Selection");
		AddMenuItem(menu, "FF2 Companion Toggle Menu", menuoption);
		Format(menuoption, sizeof(menuoption), "%t", "Disable Companion Selection");
		AddMenuItem(menu, "FF2 Companion Toggle Menu", menuoption);
		Format(menuoption, sizeof(menuoption), "%t", "Disable Companion Selection For Map");
		AddMenuItem(menu, "FF2 Companion Toggle Menu", menuoption);

		SetMenuExitButton(menu, true);

		DisplayMenu(menu, client, 20);
	}
	return Plugin_Handled;
}

public int MenuHandlerCompanion(Handle menu, MenuAction action, int param1, int param2)
{
	if(action == MenuAction_Select)
	{
		char sEnabled[2];
		int choice = param2 + 1;

		ClientCookie2[param1] = choice;
		IntToString(choice, sEnabled, sizeof(sEnabled));

		SetClientCookie(param1, CompanionCookie, sEnabled);

		if(1 == choice)
		{
			CPrintToChat(param1, "{olive}[FF2]{default} %t", "FF2 Companion Enabled");
		}
		else if(2 == choice)
		{
			CPrintToChat(param1, "{olive}[FF2]{default} %t", "FF2 Companion Disabled");
		}
		else if(3 == choice)
		{
			CPrintToChat(param1, "{olive}[FF2]{default} %t", "FF2 Companion Disabled For Map");
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action BossMenu(int client, int args)
{
	if(IsValidClient(client) && GetConVarBool(cvarToggleBoss))
	{
		CPrintToChat(client, "{olive}[FF2]{default} %t", "FF2 Toggle Menu Title", ClientCookie[client]);
		char sEnabled[2];
		SetClientPreferences(client, PREF_BOSS, sEnabled);

		Handle menu = CreateMenu(MenuHandlerBoss);
		SetGlobalTransTarget(client);
		SetMenuTitle(menu, "%t", "FF2 Toggle Menu Title", ClientCookie[client]);

		char menuoption[128];
		Format(menuoption, sizeof(menuoption), "%t", "Enable Queue Points");
		AddMenuItem(menu, "Boss Toggle", menuoption);
		Format(menuoption, sizeof(menuoption), "%t", "Disable Queue Points");
		AddMenuItem(menu, "Boss Toggle", menuoption);
		Format(menuoption, sizeof(menuoption), "%t", "Disable Queue Points For This Map");
		AddMenuItem(menu, "Boss Toggle", menuoption);

		SetMenuExitButton(menu, true);

		DisplayMenu(menu, client, 20);
	}
	return Plugin_Handled;
}

public int MenuHandlerBoss(Handle menu, MenuAction action, int param1, int param2)
{
	if(action==MenuAction_Select)
	{
		int choice = param2+1;
		SetClientPreferences(client, PREF_BOSS, choice);
		
		switch(choice)
		{
			case 1:
				CPrintToChat(param1, "{olive}[FF2]{default} %t", "FF2 Toggle Enabled Notification");
			case 2:
				CPrintToChat(param1, "{olive}[FF2]{default} %t", "FF2 Toggle Disabled Notification");
			case 3:
				CPrintToChat(param1, "{olive}[FF2]{default} %t", "FF2 Toggle Disabled Notification For Map");
		}
	} 
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

int GetClientPreferences(int client, int type)
{
	if(!IsValidClient(client) || IsFakeClient(client) || !AreClientCookiesCached(client))
	{
		return -1;
	}

	char cookies[24];
	char cookieValues[8][5];
	GetClientCookie(client, FF2Cookies, cookies, sizeof(cookies));
	ExplodeString(cookies, " ", cookieValues, 8, 5);
	if(type==PREF_DUO)
	{
		return StringToInt(cookieValues[4][0]);
	}
	else
	{
		return StringToInt(cookieValues[5][0]);
	}
	Format(cookies, sizeof(cookies), "%s %s %s %s %s %s %s %s", cookieValues[0], cookieValues[1], cookieValues[2], cookieValues[3], cookieValues[4], cookieValues[5], cookieValues[6], cookieValues[7]);
	SetClientCookie(client, FF2Cookies, cookies);
}

void SetClientPreferences(int client, int type, int enable)
{
	if(!IsValidClient(client) || IsFakeClient(client) || !AreClientCookiesCached(client))
	{
		return;
	}

	char cookies[24];
	char cookieValues[8][5];
	GetClientCookie(client, FF2Cookies, cookies, sizeof(cookies));
	ExplodeString(cookies, " ", cookieValues, 8, 5);
	if(type==PREF_DUO)
	{
		if(TOGGLE_ON)
		{
			cookieValues[4][0]='1';
		}
		else if(TOGGLE_OFF)
		{
			cookieValues[4][0]='2';
			xIncoming[client] = "";
		}
		else if(TOGGLE_TEMP)
		{
			cookieValues[4][0]='3';
			xIncoming[client] = "";
		}
		else
		{
			cookieValues[4][0]='0';
		}
	}
	else
	{
		if(TOGGLE_ON)
		{
			cookieValues[5][0]='1';
		}
		else if(TOGGLE_OFF)
		{
			cookieValues[5][0]='2';
			xIncoming[param1] = "";
		}
		else if(TOGGLE_TEMP)
		{
			cookieValues[5][0]='3';
			xIncoming[param1] = "";
		}
		else
		{
			cookieValues[5][0]='0';
		}
	}
	Format(cookies, sizeof(cookies), "%s %s %s %s %s %s %s %s", cookieValues[0], cookieValues[1], cookieValues[2], cookieValues[3], cookieValues[4], cookieValues[5], cookieValues[6], cookieValues[7]);
	SetClientCookie(client, FF2Cookies, cookies);
}

public Action Command_SetMyBoss(int client, int args)
{
	if(!client)
	{
		ReplyToCommand(client, "[SM] %t", "Command is in-game only");
		return Plugin_Handled;
	}
	
	if(!GetConVarBool(cvarSelectBoss))
	{
		return Plugin_Handled;
	}
	
	if(!CheckCommandAccess(client, "ff2_boss", 0, true))
	{
		ReplyToCommand(client, "[SM] %t", "No Access");
		return Plugin_Handled;
	}

	if(args)
	{
		char name[64], boss[64], companionName[64];
		GetCmdArgString(name, sizeof(name));
		
		for(int config; config<Specials; config++)
		{
			KvRewind(BossKV[config]);
			KvGetString(BossKV[config], "companion", companionName, sizeof(companionName));
			KvGetString(BossKV[config], "name", boss, sizeof(boss));
			if(KvGetNum(BossKV[config], "blocked", 0)) continue;
			if(KvGetNum(BossKV[config], "hidden", 0)) continue;
			if(KvGetNum(BossKV[config], "admin", 0) && !CheckCommandAccess(client, "ff2_admin_bosses", ADMFLAG_GENERIC, true)) continue;
			if(KvGetNum(BossKV[config], "owner", 0) && !CheckCommandAccess(client, "ff2_owner_bosses", ADMFLAG_ROOT, true)) continue;
			if(StrContains(boss, name, false)!=-1)
			{
				if(KvGetNum(BossKV[config], "donator", 0) && !CheckCommandAccess(client, "ff2_donator_bosses", ADMFLAG_RESERVATION, true))
				{
					CReplyToCommand(client, "{olive}[FF2]{default} %t", "deny_donator");
					return Plugin_Handled;
				}
				if(KvGetNum(BossKV[config], "nofirst", 0) && (RoundCount<arenaRounds || (RoundCount==arenaRounds && CheckRoundState()!=1)))
				{
					CReplyToCommand(client, "{olive}[FF2]{default} %t", "deny_nofirst");
					return Plugin_Handled;
				}
				if(strlen(companionName) && !DuoMin)
				{
					CReplyToCommand(client, "{olive}[FF2]{default} %t", "deny_duo_short");
					return Plugin_Handled;
				}
				if(strlen(companionName) && GetConVarBool(cvarDuoBoss) && GetClientPreferences(client, PREF_DUO)>1)
				{
					CReplyToCommand(client, "{olive}[FF2]{default} %t", "deny_duo_off");
					return Plugin_Handled;
				}
				if(BossTheme(config) && !CheckCommandAccess(client, "ff2_theme_bosses", ADMFLAG_ROOT, true))
				{
					CReplyToCommand(client, "{olive}[FF2]{default} %t", "deny_donator");
					return Plugin_Handled;
				}
				if(AreClientCookiesCached(client) && GetConVarInt(cvarKeepBoss)<0)
				{
					char cookie[64];
					GetClientCookie(client, LastPlayedCookie, cookie, sizeof(cookie));
					if(StrEqual(boss, cookie, false))
					{
						CReplyToCommand(client, "{olive}[FF2]{default} %t", "deny_recent");
						return Plugin_Handled;
					}
				}
				IsBossSelected[client]=true;
				strcopy(xIncoming[client], sizeof(xIncoming[]), boss);
				CReplyToCommand(client, "%t", "to0_boss_selected", boss);
				return Plugin_Handled;
			}

			KvGetString(BossKV[config], "filename", boss, sizeof(boss));
			if(StrContains(boss, name, false)!=-1)
			{
				if(KvGetNum(BossKV[config], "donator", 0) && !CheckCommandAccess(client, "ff2_donator_bosses", ADMFLAG_RESERVATION, true))
				{
					CReplyToCommand(client, "{olive}[FF2]{default} %t", "deny_donator");
					return Plugin_Handled;
				}
				if(KvGetNum(BossKV[config], "nofirst", 0) && (RoundCount<arenaRounds || (RoundCount==arenaRounds && CheckRoundState()!=1)))
				{
					CReplyToCommand(client, "{olive}[FF2]{default} %t", "deny_nofirst");
					return Plugin_Handled;
				}
				if(strlen(companionName) && !DuoMin)
				{
					CReplyToCommand(client, "{olive}[FF2]{default} %t", "deny_duo_short");
					return Plugin_Handled;
				}
				if(strlen(companionName) && GetConVarBool(cvarDuoBoss) && GetClientPreferences(client, PREF_DUO)>1)
				{
					CReplyToCommand(client, "{olive}[FF2]{default} %t", "deny_duo_off");
					return Plugin_Handled;
				}
				if(BossTheme(config) && !CheckCommandAccess(client, "ff2_theme_bosses", ADMFLAG_ROOT, true))
				{
					CReplyToCommand(client, "{olive}[FF2]{default} %t", "deny_donator");
					return Plugin_Handled;
				}
				KvGetString(BossKV[config], "name", boss, sizeof(boss));
				if(AreClientCookiesCached(client) && GetConVarInt(cvarKeepBoss)<0)
				{
					char cookie[64];
					GetClientCookie(client, LastPlayedCookie, cookie, sizeof(cookie));
					if(StrEqual(boss, cookie, false))
					{
						CReplyToCommand(client, "{olive}[FF2]{default} %t", "deny_recent");
						return Plugin_Handled;
					}
				}
				IsBossSelected[client]=true;
				strcopy(xIncoming[client], sizeof(xIncoming[]), boss);
				CReplyToCommand(client, "%t", "to0_boss_selected", boss);
				return Plugin_Handled;
			}
		}
		CReplyToCommand(client, "{olive}[FF2]{default} Boss could not be found!");
		return Plugin_Handled;
	}

	char boss[64];
	Handle dMenu = CreateMenu(Command_SetMyBossH);

	SetGlobalTransTarget(client);
	SetMenuTitle(dMenu, "%t", "ff2_boss_selection", xIncoming[client]);
	
	Format(boss, sizeof(boss), "%T", "to0_random", client);
	AddMenuItem(dMenu, boss, boss);
	
	if(GetConVarBool(cvarToggleBoss))
	{
		if(GetClientPreferences(client, PREF_BOSS)>1)
			Format(boss, sizeof(boss), "%t", "to0_enablepts");
		else
			Format(boss, sizeof(boss), "%t", "to0_disablepts");

		AddMenuItem(dMenu, boss, boss);
	}
	if(GetConVarBool(cvarDuoBoss))
	{
		if(GetClientPreferences(client, PREF_DUO)>1)
			Format(boss, sizeof(boss), "%t", "to0_enableduo");
		else
			Format(boss, sizeof(boss), "%t", "to0_disableduo");

		AddMenuItem(dMenu, boss, boss);
	}
	#if defined _freak_fortress_2_kstreak_included
	if(kmerge && CheckCommandAccess(client, "ff2_kstreak_a", 0, true))
	{
		if(FF2_KStreak_GetCookies(client, 0)==1)
			Format(boss, sizeof(boss), "%t", "to0_disablekstreak");
		else if(FF2_KStreak_GetCookies(client, 0)<1)
			Format(boss, sizeof(boss), "%t", "to0_enablekstreak");
		else
			Format(boss, sizeof(boss), "%t", "to0_togglekstreak");

		AddMenuItem(dMenu, boss, boss);
	}
	#endif
	
	for(int config; config<Specials; config++)
	{
		char companionName[64];
		KvRewind(BossKV[config]);
		KvGetString(BossKV[config], "companion", companionName, sizeof(companionName));
		if(KvGetNum(BossKV[config], "blocked", 0)) continue;
		if(KvGetNum(BossKV[config], "hidden", 0)) continue;
		if(KvGetNum(BossKV[config], "admin", 0) && !CheckCommandAccess(client, "ff2_admin_bosses", ADMFLAG_GENERIC, true)) continue;
		if(KvGetNum(BossKV[config], "owner", 0) && !CheckCommandAccess(client, "ff2_owner_bosses", ADMFLAG_ROOT, true)) continue;
		
		KvGetString(BossKV[config], "name", boss, sizeof(boss));
		if((KvGetNum(BossKV[config], "donator", 0) && !CheckCommandAccess(client, "ff2_donator_bosses", ADMFLAG_RESERVATION, true)) ||
		   (KvGetNum(BossKV[config], "nofirst", 0) && (RoundCount<arenaRounds || (RoundCount==arenaRounds && CheckRoundState()!=1))) ||
		   (strlen(companionName) && !DuoMin))
		{
			AddMenuItem(dMenu, boss, boss, ITEMDRAW_DISABLED);
		}
		else if(AreClientCookiesCached(client) && strlen(companionName) && GetConVarBool(cvarDuoBoss) && GetClientPreferences(client, PREF_DUO)>1)
		{
			AddMenuItem(dMenu, boss, boss, ITEMDRAW_DISABLED);
		}
		else if(BossTheme(config) && !CheckCommandAccess(client, "ff2_theme_bosses", ADMFLAG_ROOT, true))
		{
			AddMenuItem(dMenu, boss, boss, ITEMDRAW_DISABLED);
		}
		else
		{
			if(AreClientCookiesCached(client) && GetConVarInt(cvarKeepBoss)<0)
			{
				char cookie[64];
				GetClientCookie(client, LastPlayedCookie, cookie, sizeof(cookie));
				if(StrEqual(boss, cookie, false))
					AddMenuItem(dMenu, boss, boss, ITEMDRAW_DISABLED);
				else
					AddMenuItem(dMenu, boss, boss);
			}
			else
				AddMenuItem(dMenu, boss, boss);
		}
	}

	SetMenuExitButton(dMenu, true);
	DisplayMenu(dMenu, client, 20);
	return Plugin_Handled;
}

public int Command_SetMyBossH(Handle menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0: 
				{
					IsBossSelected[param1]=true;
					xIncoming[param1] = "";
					CReplyToCommand(param1, "%t", "to0_comfirmrandom");
					return;
				}
				case 1:
				{
					if(GetConVarBool(cvarToggleBoss))
						BossMenu(param1, 0);

					else if(GetConVarBool(cvarDuoBoss))
						CompanionMenu(param1, 0);

					#if defined _freak_fortress_2_kstreak_included
					else if(kmerge && CheckCommandAccess(param1, "ff2_kstreak_a", 0, true))
						FF2_KStreak_Menu(param1, 0);
					#endif

					else
					{
						if(!GetConVarBool(cvarBossDesc) || !GetClientClassInfoCookie(param1))
						{
							IsBossSelected[param1]=true;
							GetMenuItem(menu, param2, xIncoming[param1], sizeof(xIncoming[]));
							CReplyToCommand(param1, "%t", "to0_boss_selected", xIncoming[param1]);
						}
						else
						{
							GetMenuItem(menu, param2, cIncoming[param1], sizeof(cIncoming[]));
							ConfirmBoss(param1);
						}
					}
				}
				case 2:
				{
					if(GetConVarBool(cvarDuoBoss) && GetConVarBool(cvarToggleBoss))
						CompanionMenu(param1, 0);

					#if defined _freak_fortress_2_kstreak_included
					else if(GetConVarBool(cvarToggleBoss) && !GetConVarBool(cvarDuoBoss) && kmerge && CheckCommandAccess(param1, "ff2_kstreak_a", 0, true))
						FF2_KStreak_Menu(param1, 0);

					else if(!GetConVarBool(cvarToggleBoss) && GetConVarBool(cvarDuoBoss) && kmerge && CheckCommandAccess(param1, "ff2_kstreak_a", 0, true))
						FF2_KStreak_Menu(param1, 0);
					#endif

					else
					{
						if(!GetConVarBool(cvarBossDesc) || !GetClientClassInfoCookie(param1))
						{
							IsBossSelected[param1]=true;
							GetMenuItem(menu, param2, xIncoming[param1], sizeof(xIncoming[]));
							CReplyToCommand(param1, "%t", "to0_boss_selected", xIncoming[param1]);
						}
						else
						{
							GetMenuItem(menu, param2, cIncoming[param1], sizeof(cIncoming[]));
							ConfirmBoss(param1);
						}
					}
				}
				case 3:
				{
					#if defined _freak_fortress_2_kstreak_included
					if(GetConVarBool(cvarToggleBoss) && GetConVarBool(cvarDuoBoss) && kmerge && CheckCommandAccess(param1, "ff2_kstreak_a", 0, true))
						FF2_KStreak_Menu(param1, 0);

					else
					{
						if(!GetConVarBool(cvarBossDesc) || !GetClientClassInfoCookie(param1))
						{
							IsBossSelected[param1]=true;
							GetMenuItem(menu, param2, xIncoming[param1], sizeof(xIncoming[]));
							CReplyToCommand(param1, "%t", "to0_boss_selected", xIncoming[param1]);
						}
						else
						{
							GetMenuItem(menu, param2, cIncoming[param1], sizeof(cIncoming[]));
							ConfirmBoss(param1);
						}
					}
					#else
					if(!GetConVarBool(cvarBossDesc) || !GetClientClassInfoCookie(param1))
					{
						IsBossSelected[param1]=true;
						GetMenuItem(menu, param2, xIncoming[param1], sizeof(xIncoming[]));
						CReplyToCommand(param1, "%t", "to0_boss_selected", xIncoming[param1]);
					}
					else
					{
						GetMenuItem(menu, param2, cIncoming[param1], sizeof(cIncoming[]));
						ConfirmBoss(param1);
					}
					#endif
				}
				default:
				{
					if(!GetConVarBool(cvarBossDesc) || !GetClientClassInfoCookie(param1))
					{
						IsBossSelected[param1]=true;
						GetMenuItem(menu, param2, xIncoming[param1], sizeof(xIncoming[]));
						CReplyToCommand(param1, "%t", "to0_boss_selected", xIncoming[param1]);
					}
					else
					{
						GetMenuItem(menu, param2, cIncoming[param1], sizeof(cIncoming[]));
						ConfirmBoss(param1);
					}
				}
			}
		}
	}
	return;
}

public Action ConfirmBoss(int client)
{
	if(!GetConVarBool(cvarBossDesc))
	{
		return Plugin_Handled;
	}

	char text[512], language[20], boss[64];
	GetLanguageInfo(GetClientLanguage(client), language, 8, text, 8);
	Format(language, sizeof(language), "description_%s", language);
	SetGlobalTransTarget(client);
		
	for(int config; config<Specials; config++)
	{
		KvRewind(BossKV[config]);
		KvGetString(BossKV[config], "name", boss, sizeof(boss));
		if(StrContains(boss, cIncoming[client], false)!=-1)
		{
			KvRewind(BossKV[config]);
			KvGetString(BossKV[config], language, text, sizeof(text));
			if(!text[0])
			{
				KvGetString(BossKV[config], "description_en", text, sizeof(text));  //Default to English if their language isn't available
				if(!text[0])
				{
					Format(text, sizeof(text), "%t", "to0_nodesc");
				}
			}
			ReplaceString(text, sizeof(text), "\\n", "\n");
		}
	}

	Handle dMenu = CreateMenu(ConfirmBossH);
	SetMenuTitle(dMenu, text);

	Format(text, sizeof(text), "%t", "to0_confirm", cIncoming[client]);
	AddMenuItem(dMenu, text, text);

	Format(text, sizeof(text), "%t", "to0_cancel");
	AddMenuItem(dMenu, text, text);

	SetMenuExitButton(dMenu, false);
	DisplayMenu(dMenu, client, 20);
	return Plugin_Handled;
}

public int ConfirmBossH(Handle menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0: 
				{
					IsBossSelected[param1]=true;
					xIncoming[param1]=cIncoming[param1];
					CReplyToCommand(param1, "%t", "to0_boss_selected", xIncoming[param1]);
				}
				default:
				{
					Command_SetMyBoss(param1, 0);
				}
			}
		}
	}
	return;
}

bool BossTheme(int config)
{
	KvRewind(BossKV[config]);
	int theme=KvGetNum(BossKV[config], "theme", 0);
	if(theme>0)
	{
		switch(GetConVarInt(cvarTheme))
		{
			case 0:
			{
				return true;
			}
			case 1:
			{
				if(theme==1)
					return false;
			}
			case 2:
			{
				if(theme==2)
					return false;
			}
			case 3:
			{
				if(theme==1 || theme==2)
					return false;
			}
			case 4:
			{
				if(theme==3)
					return false;
			}
			case 5:
			{
				if(theme==1 || theme==3)
					return false;
			}
			case 6:
			{
				if(theme==2 || theme==3)
					return false;
			}
			case 7:
			{
				if(theme==1 || theme==2 || theme==3)
					return false;
			}
			case 8:
			{
				if(theme==4)
					return false;
			}
			case 9:
			{
				if(theme==1 || theme==4)
					return false;
			}
			case 10:
			{
				if(theme==2 || theme==4)
					return false;
			}
			case 11:
			{
				if(theme==1 || theme==2 || theme==4)
					return false;
			}
			case 12:
			{
				if(theme==3 || theme==4)
					return false;
			}
			case 13:
			{
				if(theme==1 || theme==3 || theme==4)
					return false;
			}
			case 14:
			{
				if(theme==2 || theme==3 || theme==4)
					return false;
			}
			default:
			{
				return false;
			}
		}
		return true;
	}
	return false;
}

public Action FF2_OnSpecialSelected(int boss, int &SpecialNum, char[] SpecialName, bool preset)
{
	int client=GetClientOfUserId(FF2_GetBossUserId(boss));
	if(preset)
	{
		if(!boss && !StrEqual(xIncoming[client], ""))
		{
			CPrintToChat(client, "{olive}[FF2]{default} %t", "boss_selection_overridden");
		}
		return Plugin_Continue;
	}
	
	if(!boss && !StrEqual(xIncoming[client], ""))
	{
		strcopy(SpecialName, sizeof(xIncoming[]), xIncoming[client]);
		if(GetConVarInt(cvarKeepBoss)<1 || !GetConVarBool(cvarSelectBoss) || IsFakeClient(client))
		{
			xIncoming[client] = "";
		}
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

stock int GetRandomValidClient(bool[] omit)
{
	int companion;
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsValidClient(client) && !omit[client] && (GetClientQueuePoints(client)>=GetClientQueuePoints(companion) || GetConVarBool(cvarDuoRandom)))
		{
			if(GetConVarBool(cvarDuoBoss)) // Skip clients who have disabled being able to be selected as a companion
			{
				GetClientCookie(client, FF2Cookies, cookies, sizeof(cookies));
				ExplodeString(cookies, " ", cookieValues, 8, 5);
				if(StringToInt(cookieValues[4])==0)
				{
					continue;
				}
			}

			if(GetConVarBool(cvarToggleBoss)) // Skip clients who have disabled being able to be a boss
			{
				GetClientCookie(client, FF2Cookies, cookies, sizeof(cookies));
				ExplodeString(cookies, " ", cookieValues, 8, 5);
				if(StringToInt(cookieValues[5])==0)
				{
					continue;
				}
			}
			
			if((SpecForceBoss && !GetConVarBool(cvarDuoRandom)) || GetClientTeam(client)>view_as<int>(TFTeam_Spectator))
			{
				companion=client;
			}
		}
	}
	
	if(!companion)
	{
		for(int client=1; client<MaxClients; client++)
		{
			if(IsValidClient(client) && !omit[client]) //&& (GetClientQueuePoints(client)>=GetClientQueuePoints(companion) || GetConVarBool(cvarDuoRandom)))
			{
				if(GetConVarBool(cvarToggleBoss)) // Skip clients who have disabled being able to be a boss
				{
					GetClientCookie(client, FF2Cookies, cookies, sizeof(cookies));
					ExplodeString(cookies, " ", cookieValues, 8, 5);
					if(StringToInt(cookieValues[5])==0)
					{
						continue;
					}
				}

				if(SpecForceBoss || GetClientTeam(client)>view_as<int>(TFTeam_Spectator)) // Ignore the companion toggle pref if we can't find available clients
				{
					companion=client;
				}
			}		
		}
	}
	return companion;
}

#if !PREFERENCES
#error "Preferences is disabled but used?"
#endif

#file "FF2 Module: Preferences"
