/*
    Changelog:
	List of changes in Freak Fortress 2

		Commands:
		- ff2_new
		- ff2new
		- hale_new
		- halenew
		
		FF2 Panel:
		- What's new?
		
		Local Variables:
		- curhelp
		- ff2versiontitles
		- ff2versiondates
		- maxVersion
		
		Stocks:
		- FindVersionData
		
		Public:
		- NewPanelH
		- NewPanelCmd
		- NewPanel
		- Timer_LastUpdate
*/

int curHelp[MAXPLAYERS+1];

static const char ff2versiontitles[][]=
{
	"1.0",
	"1.01",
	"1.01",
	"1.02",
	"1.03",
	"1.04",
	"1.05",
	"1.05",
	"1.06",
	"1.06c",
	"1.06d",
	"1.06e",
	"1.06f",
	"1.06g",
	"1.06h",
	"1.07 beta 1",
	"1.07 beta 1",
	"1.07 beta 1",
	"1.07 beta 1",
	"1.07 beta 1",
	"1.07 beta 4",
	"1.07 beta 5",
	"1.07 beta 6",
	"1.07",
	"1.0.8",
	"1.0.8",
	"1.0.8",
	"1.0.8",
	"1.0.8",
	"1.9.0",
	"1.9.0",
	"1.9.1",
	"1.9.2",
	"1.9.2",
	"1.9.3",
	"1.10.0",
	"1.10.0",
	"1.10.0",
	"1.10.0",
	"1.10.0",
	"1.10.0",
	"1.10.0",
	"1.10.0",
	"1.10.1",
	"1.10.1",
	"1.10.1",
	"1.10.1",
	"1.10.1",
	"1.10.2",
	"1.10.3",
	"1.10.3",
	"1.10.3",
	"1.10.3",
	"1.10.3",
	"1.10.4",
	"1.10.4",
	"1.10.4",
	"1.10.4",
	"1.10.4",
	"1.10.5",
	"1.10.6",
	"1.10.6",
	"1.10.6",
	"1.10.6",
	"1.10.7",
	"1.10.7",
	"1.10.7",
	"1.10.8",
	"1.10.9",
	"1.10.9",
	"1.10.9",
	"1.10.9",
	"1.10.9",
	"1.10.10",
	"1.10.11",
	"1.10.12",
	"1.10.13",
	"1.10.14",
	"1.11.3",
	"1.11.4",
	"1.11.5",
	"1.11.6",
	"1.11.7",
	"1.11.8",
	"1.11.9",
	"1.11.10",
	"1.11.11",
	"1.11.12",
	"1.11.13",
	"1.12.0",
	"1.12.1",
	"1.12.2",
	"1.12.3",
	"1.12.4",
	"1.13.0",
	"1.13.1",
	"1.13.2",
	"1.13.3",
	"1.13.4",
	"1.13.5",
	"1.13.6",
	"1.13.7",
	"1.13.8",
	"1.14.0",
	"1.14.1",
	"1.14.2",
	"1.14.3",
	"1.14.4",
	"1.14.5",
	"1.15.0",
	"1.15.1",
	"1.15.2",
	"1.15.3",
	"1.16.0",
	"1.16.1",
	"1.16.2",
	"1.16.3",
	"1.16.4",
	"1.16.5",
	"1.16.6",
	"1.16.7",
	"1.16.8",
	"1.16.9",
	"1.16.10",
	"1.16.11",
	"1.16.12",
	"1.17.0",
	"1.17.1",
	"1.17.2",
	"1.17.3",
	"1.17.4",
	"1.17.5",
	"1.17.5",
	"1.17.6",
	"1.17.6",
	"1.17.7",
	"1.17.8",
	"1.17.9",
	"1.17.9",
	"1.17.10",
	"1.18.0"
};

static const char ff2versiondates[][]=
{
	"April 6, 2012",			//1.0
	"April 14, 2012",		//1.01
	"April 14, 2012",		//1.01
	"April 17, 2012",		//1.02
	"April 19, 2012",		//1.03
	"April 21, 2012",		//1.04
	"April 29, 2012",		//1.05
	"April 29, 2012",		//1.05
	"May 1, 2012",			//1.06
	"June 22, 2012",			//1.06c
	"July 3, 2012",			//1.06d
	"August 24, 2012",			//1.06e
	"September 5, 2012",			//1.06f
	"September 5, 2012",			//1.06g
	"September 6, 2012",			//1.06h
	"October 8, 2012",			//1.07 beta 1
	"October 8, 2012",			//1.07 beta 1
	"October 8, 2012",			//1.07 beta 1
	"October 8, 2012",			//1.07 beta 1
	"October 8, 2012",			//1.07 beta 1
	"October 11, 2012",			//1.07 beta 4
	"October 18, 2012",			//1.07 beta 5
	"November 9, 2012",			//1.07 beta 6
	"December 14, 2012",			//1.07
	"October 30, 2013",		//1.0.8
	"October 30, 2013",		//1.0.8
	"October 30, 2013",		//1.0.8
	"October 30, 2013",		//1.0.8
	"October 30, 2013",		//1.0.8
	"March 6, 2014",		//1.9.0
	"March 6, 2014",		//1.9.0
	"March 18, 2014",		//1.9.1
	"March 22, 2014",		//1.9.2
	"March 22, 2014",		//1.9.2
	"April 5, 2014",		//1.9.3
	"July 26, 2014",		//1.10.0
	"July 26, 2014",		//1.10.0
	"July 26, 2014",		//1.10.0
	"July 26, 2014",		//1.10.0
	"July 26, 2014",		//1.10.0
	"July 26, 2014",		//1.10.0
	"July 26, 2014",		//1.10.0
	"July 26, 2014",		//1.10.0
	"August 28, 2014",		//1.10.1
	"August 28, 2014",		//1.10.1
	"August 28, 2014",		//1.10.1
	"August 28, 2014",		//1.10.1
	"August 28, 2014",		//1.10.1
	"August 28, 2014",		//1.10.2
	"November 6, 2014",		//1.10.3
	"November 6, 2014",		//1.10.3
	"November 6, 2014",		//1.10.3
	"November 6, 2014",		//1.10.3
	"November 6, 2014",		//1.10.3
	"March 1, 2015",		//1.10.4
	"March 1, 2015",		//1.10.4
	"March 1, 2015",		//1.10.4
	"March 1, 2015",		//1.10.4
	"March 1, 2015",		//1.10.4
	"March 13, 2015",		//1.10.5
	"August 10, 2015",		//1.10.6
	"August 10, 2015",		//1.10.6
	"August 10, 2015",		//1.10.6
	"August 10, 2015",		//1.10.6
	"November 19, 2015",	//1.10.7
	"November 19, 2015",	//1.10.7
	"November 19, 2015",	//1.10.7
	"November 24, 2015",	//1.10.8
	"May 7, 2016",			//1.10.9
	"May 7, 2016",			//1.10.9
	"May 7, 2016",			//1.10.9
	"May 7, 2016",			//1.10.9
	"May 7, 2016",			//1.10.9
	"August 1, 2016",		//1.10.10
	"August 1, 2016",		//1.10.11
	"August 4, 2016",		//1.10.12
	"September 1, 2016",	//1.10.13
	"October 21, 2016",		//1.10.14
	"October 3, 2018",		//1.11.3
	"October 3, 2018",		//1.11.4
	"October 4, 2018",		//1.11.5
	"October 5, 2018",		//1.11.6
	"October 6, 2018",		//1.11.7
	"October 7, 2018",		//1.11.8
	"October 7, 2018",		//1.11.9
	"October 8, 2018",		//1.11.10
	"October 10, 2018",		//1.11.11
	"October 13, 2018",		//1.11.12
	"October 15, 2018",		//1.11.13
	"October 17, 2018",		//1.12.0
	"October 21, 2018",		//1.12.1
	"October 27, 2018",		//1.12.2
	"October 28, 2018",		//1.12.3
	"October 29, 2018",		//1.12.4
	"November 11, 2018",		//1.13.0
	"November 14, 2018",		//1.13.1
	"November 15, 2018",		//1.13.2
	"November 15, 2018",		//1.13.3
	"November 15, 2018",		//1.13.4
	"November 16, 2018",		//1.13.5
	"November 17, 2018",		//1.13.6
	"November 17, 2018",		//1.13.7
	"November 18, 2018",		//1.13.8
	"November 24, 2018",		//1.14.0
	"November 29, 2018",		//1.14.1
	"November 30, 2018",		//1.14.2
	"November 30, 2018",		//1.14.3
	"December 2, 2018",		//1.14.4
	"December 4, 2018",		//1.14.5
	"December 5, 2018",		//1.15.0
	"December 7, 2018",		//1.15.1
	"December 8, 2018",		//1.15.2
	"December 9, 2018",		//1.15.3
	"December 11, 2018",		//1.16.0
	"December 12, 2018",		//1.16.1
	"December 13, 2018",		//1.16.2
	"December 16, 2018",		//1.16.3
	"December 18, 2018",		//1.16.4
	"December 23, 2018",		//1.16.5
	"December 24, 2018",		//1.16.6
	"December 25, 2018",		//1.16.7
	"January 3, 2019",		//1.16.8
	"January 5, 2019",		//1.16.9
	"January 7, 2019",		//1.16.10
	"January 8, 2019",		//1.16.11
	"January 9, 2019",		//1.16.12
	"January 13, 2019",		//1.17.0
	"January 15, 2019",		//1.17.1
	"January 19, 2019",		//1.17.2
	"January 22, 2019",		//1.17.3
	"January 24, 2019",		//1.17.4
	"January 29, 2019",		//1.17.5
	"January 29, 2019",		//1.17.5
	"February 5, 2019",		//1.17.6
	"February 5, 2019",		//1.17.6
	"February 10, 2019",		//1.17.7
	"February 15, 2019",		//1.17.8
	"March 8, 2019",		//1.17.9
	"March 8, 2019",		//1.17.9
	"April 3, 2019",		//1.17.10
	"Development"			//1.18.0
};

stock void FindVersionData(Handle panel, int versionIndex)
{
	switch(versionIndex)
	{
		case 140:  //1.18.0
		{
			DrawPanelText(panel, "1) [Core] Code is now in Transitional Syntax (Batfoxkid)");
			DrawPanelText(panel, "2) [Bosses] Merged all default subplugins (Batfoxkid)");
			DrawPanelText(panel, "3) [Bosses] Added new stun options (Batfoxkid from sarysa)");
			DrawPanelText(panel, "4) [Gameplay] Added the ability to sap bosses or minions (Batfoxkid from SHADoW)");
		}
		case 139:  //1.17.10
		{
			DrawPanelText(panel, "1) [Gameplay] Bosses] Added 'theme' setting for certain bosses blocked with ff2_theme (Batfoxkid)");
			DrawPanelText(panel, "2) [Core] weapons.cfg is applied first than hardcoded, when enabled (Batfoxkid)");
			DrawPanelText(panel, "3) [Core] Added Russian preference translations (MAGNAT2645)");
			DrawPanelText(panel, "4) [Gameplay] Players with class info off won't view boss description in boss menu (Batfoxkid)");
			DrawPanelText(panel, "5) [Bosses] Fixed sound_lastman playing multiple times in a round (Batfoxkid)");
		}
		case 138:  //1.17.9
		{
			DrawPanelText(panel, "1) [Core] Cvar to show boss description before selecting the boss (Batfoxkid)");
			DrawPanelText(panel, "2) [Gameplay] Adjusted some hardcoded weapons (Batfoxkid)");
			DrawPanelText(panel, "3) [Gameplay] Fixed pickups when FF2 is disabled (Batfoxkid)");
			DrawPanelText(panel, "4) [Gameplay] Cvar for RPS queue point betting and boss limiter (Batfoxkid/SHADoW)");
			DrawPanelText(panel, "5) [Gameplay] Cvar to show healing done (Vee)");
		}
		case 137:  //1.17.9
		{
			DrawPanelText(panel, "6) [Gameplay] Candy Cane Scouts gain healing credit (Vee)");
			DrawPanelText(panel, "7) [Gameplay] Fix shields against critical hits (Batfoxkid)");
			DrawPanelText(panel, "8) [Gameplay] Made Killstreaker and Airstrike damage more accurate (Batfoxkid)");
			DrawPanelText(panel, "9) [Gameplay] Cvar for Airstrike damage to gain a head (Batfoxkid)");
		}
		case 136:  //1.17.8
		{
			DrawPanelText(panel, "1) [Core] Added Russian core translations (MAGNAT2645)");
			DrawPanelText(panel, "2) [Core] Cvar to record boss wins/losses in a log (Batfoxkid)");
			DrawPanelText(panel, "3) [Bosses] Added sound_intromusic and sound_outtromusic (Batfoxkid from SHADoW)");
		}
		case 135:  //1.17.7
		{
			DrawPanelText(panel, "1) [Bosses] Added 'bossteam' to allow specific bosses to use a specific team (SHADoW)");
			DrawPanelText(panel, "2) [Gameplay] Cvar for overtime mode activates if countdown timer expires while capping a point (SHADoW)");
			DrawPanelText(panel, "3) [Core] Added new debug logging system (Batfoxkid)");
			DrawPanelText(panel, "4) [Gameplay] Cvar for Huntsman being crit boosted and it's damage (Batfoxkid)");
		}
		case 134:  //1.17.6
		{
			DrawPanelText(panel, "1) [Gameplay] Cvar for game_text_tf entities as HUD replacements (SHADoW)");
			DrawPanelText(panel, "2) [Gameplay] Cvar for annotations or game_text_tf entities as hint replacements (Batfoxkid/SHADoW)");
			DrawPanelText(panel, "3) [Gameplay] Cvar to say the player's or boss's name in messages (Batfoxkid from SHADoW)");
			DrawPanelText(panel, "4) [Core] Fixed some issues from previous update (Batfoxkid)");
			DrawPanelText(panel, "5) [Bosses] Added 'ghost' setting for bosses for game_text_tf (Batfoxkid)");
		}
		case 133:  //1.17.6
		{
			DrawPanelText(panel, "6) [Players] Shield HP and damage reduction option (SHADoW)");
			DrawPanelText(panel, "7) [Players] Non-lethal shots don't break and none option (Batfoxkid)");
			DrawPanelText(panel, "8) [Core] Renamed \"Bat's Edit\" to \"Unofficial\" (Batfoxkid)");
			DrawPanelText(panel, "9) [Core] Improved some older and all newer changelogs (Batfoxkid from SHADoW)");
			DrawPanelText(panel, "10) [Core] Fixed ragedamage formulas and settings (Batfoxkid)");
		}
		case 132:  //1.17.5
		{
			DrawPanelText(panel, "1) [Bosses] Rages can be set infinitely, disabled, or blocked (Batfoxkid)");
			DrawPanelText(panel, "2) [Bosses] Speeds can be set to not handled by FF2 or full stand-still (Batfoxkid)");
			DrawPanelText(panel, "3) [Bosses] Added minimum, maximum, and mode rage settings (Batfoxkid)");
			DrawPanelText(panel, "4) [Core] Imported official 1.10.15 commits (naydef/Wliu)");
			DrawPanelText(panel, "5) [Bosses] Control point and round time settings can be done per-boss (Batfoxkid)");
		}
		case 131:  //1.17.5
		{
			DrawPanelText(panel, "6) [Gameplay] Allowed both ff2_point_time and ff2_point_alive for ff2_point_type (Batfoxkid)");
			DrawPanelText(panel, "7) [Bosses] Boss weapons can set custom models, clip, ammo, and color (SHADoW)");
			DrawPanelText(panel, "8) [Bosses] Boss weapons can disable base damage bonus and capture rate (Batfoxkid)");
			DrawPanelText(panel, "9) [Players] Cvar to buff backstab, market garden, and caber for low-player count (Batfoxkid)");
		}
		case 130:  //1.17.4
		{
			DrawPanelText(panel, "1) [Players] Disable boss/companion for a map duration (Batfoxkid)");
			DrawPanelText(panel, "2) [Core] More multi-translation fixes (MAGNAT2645)");
			DrawPanelText(panel, "3) [Players] Option to restore queue points after being a companion (Batfoxkid)");
			DrawPanelText(panel, "4) [Developers] Added FF2_GetForkVersion native (Batfoxkid)");
		}
		case 129:  //1.17.3
		{
			DrawPanelText(panel, "1) [Gameplay] Last player glow cvar is now how many players are left (Batfoxkid)");
			DrawPanelText(panel, "2) [Core] Multi-translation fixes (MAGNAT2645)");
			DrawPanelText(panel, "3) [Bosses] Added 'sound_ability_serverwide' for serverwide RAGE sound (SHADoW)");
			DrawPanelText(panel, "4) [Bosses] Allowed 'ragedamage' to be a formula (Batfoxkid)");
		}
		case 128:  //1.17.2
		{
			DrawPanelText(panel, "1) [Core] Companion bosses unplayable when less then defined players (Batfoxkid)");
			DrawPanelText(panel, "2) [Core] Cvar to adjust how the companion is choosen (Batfoxkid)");
		}
		case 127:  //1.17.1
		{
			DrawPanelText(panel, "1) [Core] Skip song doesn't play previous song and added shuffle song (Batfoxkid from SHADoW)");
			DrawPanelText(panel, "2) [Core] Selectable theme in track menu (Batfoxkid from SHADoW)");
		}
		case 126:  //1.17.0
		{
			DrawPanelText(panel, "1) [Core] Advanced music menu and commands (Batfoxkid from SHADoW)");
			DrawPanelText(panel, "2) [Core] Readded and improved ff2_voice (Batfoxkid)");
		}
		case 125:  //1.16.12
		{
			DrawPanelText(panel, "1) Points extra cvar defines max queue points instead (Batfoxkid)");
		}
		case 124:  //1.16.11
		{
			DrawPanelText(panel, "1) Cvars to adjust how queue points are handled (Batfoxkid from SHADoW)");
		}
		case 123:  //1.16.10
		{
			DrawPanelText(panel, "1) Cvars to disable ff2boss, ff2toggle, and/or ff2companion commands (Batfoxkid)");
		}
		case 122:  //1.16.9
		{
			DrawPanelText(panel, "1) Added nofirst setting for bosses with a first-round glitch (Batfoxkid)");
			DrawPanelText(panel, "2) Allowed to keep the boss players selected until another selection (Batfoxkid)");
			DrawPanelText(panel, "3) Removed 'No Random Critical Hits'' when attributes is undefined (Batfoxkid)");
		}
		case 121:  //1.16.8
		{
			DrawPanelText(panel, "1) Medi-Gun skins and festives are now shown (Batfoxkid)");
			DrawPanelText(panel, "2) Added crit setting for bosses (Batfoxkid)");
			DrawPanelText(panel, "3) 'Set rage' command sets rage and added 'add rage' command (Batfoxkid)");
		}
		case 120:  //1.16.7
		{
			DrawPanelText(panel, "1) Only block join team commands during a FF2 round (naydef)");
		}
		case 119:  //1.16.6
		{
			DrawPanelText(panel, "1) Added set rage command and infinite rage command (SHADoW from Chdata)");
		}
		case 118:  //1.16.5
		{
			DrawPanelText(panel, "1) Added self-knockback setting for bosses (Batfoxkid)");
		}
		case 117:  //1.16.4
		{
			DrawPanelText(panel, "1) Dead Ringer HUD (Chdata/naydef)");
		}
		case 116:  //1.16.3
		{
			DrawPanelText(panel, "1) Fixed owner marked bosses choosen by random (Batfoxkid)");
		}
		case 115:  //1.16.2
		{
			DrawPanelText(panel, "1) Server name has the current boss name (Deathreus)");
		}
		case 114:  //1.16.1
		{
			DrawPanelText(panel, "1) Details and more commands (Batfoxkid)");
			DrawPanelText(panel, "2) Fixed companion toggle (Batfoxkid)");
		}
		case 113:  //1.16.0
		{
			DrawPanelText(panel, "1) Boss selection and toggle (Batfoxkid from SHADoW)");
			DrawPanelText(panel, "2) Added owner settings for bosses (Batfoxkid)");
			DrawPanelText(panel, "3) Added triple settings for bosses (Batfoxkid/SHADoW)");
		}
		case 112:  //1.15.3
		{
			DrawPanelText(panel, "1) Bosses can take self-knockback (Bacon Plague/M76030)");
		}
		case 111:  //1.15.2
		{
			DrawPanelText(panel, "1) Fixed boss health being short by one (Batfoxkid)");
		}
		case 110:  //1.15.1
		{
			DrawPanelText(panel, "1) Weapons by config (SHADoW)");
			DrawPanelText(panel, "2) Fixed Razorback (naydef)");
			DrawPanelText(panel, "3) cvar to use hard-coded weapons (Batfoxkid)");
			DrawPanelText(panel, "4) Updated weapons stats (Batfoxkid)");
			DrawPanelText(panel, "5) Readded RTD support (for the last time) (Batfoxkid)");
			DrawPanelText(panel, "6) Boss health is reset on round start (Batfoxkid)");
		}
		case 109:  //1.15.0
		{
			DrawPanelText(panel, "1) Non-character configs use data filepath (SHADoW)");
			DrawPanelText(panel, "2) Added several admin commands for FF2 (SHADoW)");
			DrawPanelText(panel, "3) Sandman is no longer normally crit-boosted (Batfoxkid)");
		}
		case 108:  //1.14.5
		{
			DrawPanelText(panel, "1) Nerfed L'etranger (Batfoxkid)");
			DrawPanelText(panel, "2) Sniper can wall climb within FF2 (SHADoW)");
			DrawPanelText(panel, "3) Cvars for Sniper wall climbing (Batfoxkid)");
		}
		case 107:  //1.14.4
		{
			DrawPanelText(panel, "1) Boss BGM can be adjusted by TF2's music slider (SHADoW)");
			DrawPanelText(panel, "2) Bosses can set custom quaility and level (SHADoW)");
			DrawPanelText(panel, "3) Bosses can set custom strange rank/randomize rank (Batfoxkid)");
		}
		case 106:  //1.14.3
		{
			DrawPanelText(panel, "1) Fixed major issues with Huntsman and Sniper class (Batfoxkid)");
		}
		case 105:  //1.14.2
		{
			DrawPanelText(panel, "1) Adjusted Sniper Rifle/Huntsman damage with cvars (Batfoxkid)");
			DrawPanelText(panel, "2) Fixed Cozy Camper's SMG unable to be crit boosted (Batfoxkid)");
		}
		case 104:  //1.14.1
		{
			DrawPanelText(panel, "1) Killstreak system by damage done to the boss (shadow93)");
			DrawPanelText(panel, "2) Nerfed Sniper Rifle/Hunstman damage (Batfoxkid)");
			DrawPanelText(panel, "3) Buffed Sharpened Volcano Fragment (Batfoxkid)");
			DrawPanelText(panel, "4) Gave Huntsman faster charge rate (Batfoxkid)");
		}
		case 103:  //1.14.0
		{
			DrawPanelText(panel, "1) Reworked various weapons stats (Batfoxkid)");
			DrawPanelText(panel, "2) Caber no longer is crit boosted when used (Batfoxkid)");
			DrawPanelText(panel, "3) SMG deals only mini-crits (Batfoxkid)");
			DrawPanelText(panel, "4) Pistol is no longer crit-boosted by both classes (Batfoxkid)");
			DrawPanelText(panel, "5) Crit-boosted weapons that already crit (Batfoxkid)");
		}
		case 102:  //1.13.8
		{
			DrawPanelText(panel, "1) Ullapool Caber nerfed damage (Batfoxkid)");
			DrawPanelText(panel, "2) Forgot to mention Market Garden nerf like in VSH in 1.13.6 (Batfoxkid)");
		}
		case 101:  //1.13.7
		{
			DrawPanelText(panel, "1) ''admin'' in boss configs also acts the same as ''blocked'' (Batfoxkid)");
		}
		case 100:  //1.13.6
		{
			DrawPanelText(panel, "1) Pistol nerf reverted and Engineer's pistols mini-crit normally (Batfoxkid)");
			DrawPanelText(panel, "2) Buffed SMG's damage along too (Batfoxkid)");
			DrawPanelText(panel, "3) Ullapool Caber acts like a smaller Market Garden/Backstab (Batfoxkid)");
			DrawPanelText(panel, "4) Removed Ullapool Caber's multi-detonations (Batfoxkid)");
		}
		case 99:  //1.13.5
		{
			DrawPanelText(panel, "1) Reverted Razorback to match Darwin's Danger Sheild (Batfoxkid)");
			DrawPanelText(panel, "2) ''donator'' in boss configs acts the same as ''blocked'' (Batfoxkid)");
		}
		case 98:  //1.13.4
		{
			DrawPanelText(panel, "1) Increased max amount of bosses in a pack from 64 to 150 (Batfoxkid/WakaFlocka)");
			DrawPanelText(panel, "2) Increased max amount of abilties in a boss from 14 to 64? (Batfoxkid/WakaFlocka)");
		}
		case 97:  //1.13.3
		{
			DrawPanelText(panel, "1) Fixed FORK_STABLE_REVISION being STABLE_REVISION (Batfoxkid)");
		}
		case 96:  //1.13.2
		{
			DrawPanelText(panel, "1) Made public version number the same while keeping fork version");
			DrawPanelText(panel, "2) number for plugins using the FF2_GetFF2Version native. (Batfoxkid)");
		}
		case 95:  //1.13.1
		{
			DrawPanelText(panel, "1) Fixed FF2 messages not looping correctly (Batfoxkid)");
			DrawPanelText(panel, "2) Reworked Bazaar Bargain (Batfoxkid)");
		}
		case 94:  //1.13.0
		{
			DrawPanelText(panel, "1) Kritzkrieg gives only crits on Uber but faster Uber rate (Batfoxkid)");
			DrawPanelText(panel, "2) Quick-Fix gives no invulnerably but immunity to knockback with Uber (Batfoxkid)");
			DrawPanelText(panel, "3) Vaccinator gives a projectile sheild but weak Uber rate (Batfoxkid)");
			DrawPanelText(panel, "4) Nerfed Vita-Saw (Batfoxkid)");
		}
		case 93:  //1.12.4
		{
			DrawPanelText(panel, "1) Buffed Gunboats (Batfoxkid)");
			DrawPanelText(panel, "2) Reworked Chargin' Targe and Homewrecker/Mual (Batfoxkid)");
		}
		case 92:  //1.12.3
		{
			DrawPanelText(panel, "1) Buffed Rocket/Sticky Jumper (Batfoxkid)");
		}
		case 91:  //1.12.2
		{
			DrawPanelText(panel, "1) Nerfed KGB and buffed Enforcer (Batfoxkid)");
			DrawPanelText(panel, "2) YER/Wanga Prick makes backstabs silent except critical sound (Batfoxkid)");
		}
		case 90:  //1.12.1
		{
			DrawPanelText(panel, "1) DEV_REVISION adjusted to not get confused with official FF2 (Batfoxkid)");
		}
		case 89:  //1.12.0
		{
			DrawPanelText(panel, "1) Bosses damage output no longer tripled if");
			DrawPanelText(panel, "    the damage is less than 160 (Batfoxkid)");
		}
		case 88:  //1.11.13
		{
			DrawPanelText(panel, "1) Buffed Mantreads (Batfoxkid)");
		}
		case 87:  //1.11.12
		{
			DrawPanelText(panel, "1) BGM looping fixes (naydef)");
		}
		case 86:  //1.11.11
		{
			DrawPanelText(panel, "1) Fixed Detonator and Eviction Notice (Batfoxkid)");
		}
		case 85:  //1.11.10
		{
			DrawPanelText(panel, "1) Buffed Short Circuit, Righteous Bison, and Pomson 6000 (Batfoxkid)");
			DrawPanelText(panel, "2) Added sound_marketed and sound_telefraged (Batfoxkid)");
			DrawPanelText(panel, "3) Removed ff2_voice, due to it only working for very little sounds (Batfoxkid)");
		}
		case 84:  //1.11.9
		{
			DrawPanelText(panel, "1) Bosses no longer have fall damage sound effects (Batfoxkid)");
			DrawPanelText(panel, "1) Buffed Huo-Long Heater (Noobis)");
		}
		case 83:  //1.11.8
		{
			DrawPanelText(panel, "1) Nerfed KGB and Razorback (Batfoxkid)");
			DrawPanelText(panel, "2) Buffed Rocket/Sticky Jumper (Batfoxkid)");
			DrawPanelText(panel, "3) Reworked Razorback (Batfoxkid)");
			DrawPanelText(panel, "4) and Huo-Long Heater (Noobis)");
		}
		case 82:  //1.11.7
		{
			DrawPanelText(panel, "1) Nerfed KGB and Razorback (Batfoxkid)");
		}
		case 81:  //1.11.6
		{
			DrawPanelText(panel, "1) Adjusted, added, and reworked alot of weapons, too much to list (Batfoxkid)");
		}
		case 80:  //1.11.5
		{
			DrawPanelText(panel, "1) Battalion's Backup no longer gives full rage upon being hit (Batfoxkid)");
		}
		case 79:  //1.11.4
		{
			DrawPanelText(panel, "1) [Server] Always says Freak Fortress in game name (Batfoxkid)");
			DrawPanelText(panel, "       (Assuming that this server is always using FF2)");
			DrawPanelText(panel, "2) Actually blocked spectate command (Batfoxkid)");
			DrawPanelText(panel, "3) Updated killing spree, hit sounds, etc. (Batfoxkid)");
			DrawPanelText(panel, "4) No longer using TF2Items, hardcoded now (Batfoxkid)");
		}
		case 78:  //1.11.3
		{
			DrawPanelText(panel, "1) Spectate command is blocked as the boss (Batfoxkid)");
			DrawPanelText(panel, "2) Huo-Long Heater work-in-progress change (Noobis)");
		}
		case 77:  //1.10.14
		{
			DrawPanelText(panel, "1) Fixed minions occasionally spawning on the wrong team (Wliu from various)");
			DrawPanelText(panel, "2) Fixed ff2_start_music at the start of the round causing music to overlap (naydef)");
			DrawPanelText(panel, "3) Fixed new clients not hearing music in certain circumstances (naydef)");
		}
		case 76:  //1.10.13
		{
			DrawPanelText(panel, "1) Fixed insta-backstab issues (Wliu from tom0034)");
			DrawPanelText(panel, "2) Fixed team-changing exploit (Wliu from Edge_)");
			DrawPanelText(panel, "3) [Server] Fixed an error message logging the wrong values (Wliu)");
		}
		case 75:  //1.10.12
		{
			DrawPanelText(panel, "1) Actually fixed BGMs not looping (Wliu from WakaFlocka, again)");
			DrawPanelText(panel, "2) Fixed new clients not respecting the current music state (Wliu from shadow93)");
		}
		case 74:  //1.10.11
		{
			DrawPanelText(panel, "1) Fixed BGMs not looping (Wliu from WakaFlocka)");
		}
		case 73:  //1.10.10
		{
			DrawPanelText(panel, "1) Fixed multiple BGM issues in 1.10.9 (Wliu, shadow93, Nopied, WakaFlocka, and others)");
			DrawPanelText(panel, "2) Automatically start BGMs for new clients (Wliu)");
			DrawPanelText(panel, "3) Fixed the top damage dealt sometimes displaying as 0 damage (naydef)");
			DrawPanelText(panel, "4) Added back Shortstop reload penalty to reflect its buff in the Meet Your Match update (Wliu)");
			DrawPanelText(panel, "5) [Server] Fixed an invalid client error in ff2_1st_set_abilities.sp (Wliu)");
			DrawPanelText(panel, "6) [Server] Fixed a GetEntProp error (Wliu from Hemen353)");
		}
		case 72:  //1.10.9
		{
			DrawPanelText(panel, "1) Fixed a critical exploit related to sv_cheats (naydef)");
			DrawPanelText(panel, "2) Updated weapons for the Tough Break update (Wliu)");
			DrawPanelText(panel, "Partially synced with VSH (all changes listed courtesy of VSH contributors and shadow93)");
			DrawPanelText(panel, "2) VSH: Don't play end-of-round announcer sounds");
			DrawPanelText(panel, "3) VSH: Increase boss damage to 210% (up from 200%)");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 71:  //1.10.9
		{
			DrawPanelText(panel, "4) VSH: Give scout bosses +3 capture rate instead of +4");
			DrawPanelText(panel, "5) VSH: Don't actually call for medic when activating rage");
			DrawPanelText(panel, "6) VSH: Override attributes for all mediguns and syringe guns");
			DrawPanelText(panel, "7) Fixed Ambassador, Diamondback, Phlogistinator, and the Manmelter not dealing the correct damage (Dalix)");
			DrawPanelText(panel, "8) Adjusted medgiun and Dead Ringer mechanics to provide a more native experience (Wliu)");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 70:  //1.10.9
		{
			DrawPanelText(panel, "9) Prevent `autoteam` spam and possible crashes (naydef)");
			DrawPanelText(panel, "10) Fixed boss's health not appearing correctly before round start (Wliu)");
			DrawPanelText(panel, "11) Fixed ff2_alive...again (Wliu from Dalix)");
			DrawPanelText(panel, "12) Fixed BossInfoTimer (that thing no one knows about because it never worked) (Wliu)");
			DrawPanelText(panel, "13) Reset clone status properly (Wliu)");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 69:  //1.10.9
		{
			DrawPanelText(panel, "13) Don't allow sound_kill_* and sound_hit to overlap each other (Wliu from WakaFlocka)");
			DrawPanelText(panel, "14) Prevent sound_lastman sounds from overlapping with regular kill sounds (Wliu from WakaFlocka)");
			DrawPanelText(panel, "15) Updated Russian translation (silenser)");
			DrawPanelText(panel, "16) [Server] Make sure the entity is valid before creating a healthbar (shadow93)");
			DrawPanelText(panel, "17) [Server] Fixed invalid client errors originating from ff2_1st_set_abilities.sp (Wliu)");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 68:  //1.10.9
		{
			DrawPanelText(panel, "18) [Server] Added ff2_start_music command for symmetry (Wliu from WakaFlocka)");
			DrawPanelText(panel, "19) [Dev] Actually make FF2_OnMusic work (Wliu from shadow93)");
			DrawPanelText(panel, "20) [Dev] Rewrote BGM code (Wliu)");
			DrawPanelText(panel, "21) [Dev] Fixed ability sounds playing even if the ability was canceled in FF2_PreAbility (Wliu from xNanoChip)");
		}
		case 67:  //1.10.8
		{
			DrawPanelText(panel, "1) Fixed the Powerjack and Kunai killing the boss in one hit (naydef)");
		}
		case 66:  //1.10.7
		{
			DrawPanelText(panel, "1) Fixed companions always having default rage damage and lives, even if specified otherwise (Wliu from Shadow)");
			DrawPanelText(panel, "2) Fixed bosses instantly losing if a boss disconnected while there were still other bosses alive (Shadow from Spyper)");
			DrawPanelText(panel, "3) Fixed minions receiving benefits intended only for normal players (Wliu)");
			DrawPanelText(panel, "4) Removed Shortstop reload penalty (Starblaster64)");
			DrawPanelText(panel, "5) Whitelisted the Shooting Star (Wliu)");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 65:  //1.10.7
		{
			DrawPanelText(panel, "6) Fixed large amounts of lives being cut off when being displayed (Wliu)");
			DrawPanelText(panel, "7) More living spectator fixes (naydef, Shadow)");
			DrawPanelText(panel, "8) Fixed health bar not updating when goomba-ing the boss (Wliu from Akuba)");
			DrawPanelText(panel, "9) [Server] Added arg12 to rage_cloneattack to determine whether or not clones die after their boss dies (Wliu");
			DrawPanelText(panel, "10) [Server] Fixed 'UTIL_SetModel not precached' crashes when using 'model_projectile_replace' (Wliu from Shadow)");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 64:  //1.10.7
		{
			DrawPanelText(panel, "11) [Server] 'ff2_crits' now defaults to 0 instead of 1 (Wliu from Spyper)");
			DrawPanelText(panel, "12) [Server] Fixed divide by 0 errors (Wliu)");
			DrawPanelText(panel, "13) [Dev] Fixed FF2_OnAlivePlayersChanged not returning the number of minions (Wliu)");
			DrawPanelText(panel, "14) [Dev] Fixed PDAs and sappers not being usable when given to bosses (Shadow)");
		}
		case 63:  //1.10.6
		{
			DrawPanelText(panel, "1) Updated the default health formula to match VSH's (Wliu)");
			DrawPanelText(panel, "2) Updated for compatability with the Gunmettle update (Wliu, Shadow, Starblaster64, Chdata, sarysa, and others)");
			DrawPanelText(panel, "3) Fixed boss weapon animations sometimes not working (Chdata)");
			DrawPanelText(panel, "4) Disconnecting bosses now get replaced by the person with the second-highest queue points (Shadow)");
			DrawPanelText(panel, "5) Fixed bosses rarely becoming 'living spectators' during the first round (Shadow/Wliu)");
			DrawPanelText(panel, "See next page (press 1");
		}
		case 62:  //1.10.6
		{
			DrawPanelText(panel, "6) Fixed large amounts of damage insta-killing multi-life bosses (Wliu from Shadow)");
			DrawPanelText(panel, "7) Fixed death effects triggering when FF2 wasn't active (Shadow)");
			DrawPanelText(panel, "8) Fixed 'sound_fail' playing even when the boss won (Shadow)");
			DrawPanelText(panel, "9) Fixed charset voting again (Wliu from Shadow)");
			DrawPanelText(panel, "10) Fixed bravejump sounds not playing (Wliu from Maximilian_)");
			DrawPanelText(panel, "See next page (press 1");
		}
		case 61:  //1.10.6
		{
			DrawPanelText(panel, "11) Fixed end-of-round text occasionally showing random symbols and file paths (Wliu)");
			DrawPanelText(panel, "12) Updated Russian translations (Maximilian_)");
			DrawPanelText(panel, "13) [Server] Fixed 'UTIL_SetModel not precached' crashes-see #18 for the underlying fix (Shadow/Wliu)");
			DrawPanelText(panel, "14) [Server] Fixed Array Index Out of Bounds errors when there are more than 32 chances (Wliu from Maximilian_)");
			DrawPanelText(panel, "15) [Server] Fixed invalid client errors in easter_abilities.sp (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 60:  //1.10.6
		{
			DrawPanelText(panel, "16) [Server] Missing boss files are now logged (Shadow)");
			DrawPanelText(panel, "17) [Dev] Added FF2_StartMusic that was missing from the include file (Wliu from Shadow)");
			DrawPanelText(panel, "18) [Dev] FF2_GetBossIndex now makes sure the client index passed is valid (Wliu)");
			DrawPanelText(panel, "19) [Dev] Rewrote the health formula parser and fixed a few bugs along the way (WildCard65/Wliu)");
			DrawPanelText(panel, "20) [Dev] Prioritized exact matches in OnSpecialSelected and added a 'preset' bool (Wliu from Shadow)");
			DrawPanelText(panel, "21) [Dev] Removed deprecated FCVAR_PLUGIN cvar flags (Wliu)");
		}
		case 59:  //1.10.5
		{
			DrawPanelText(panel, "1) Fixed slow-mo being extremely buggy (Wliu from various)");
			DrawPanelText(panel, "2) Fixed the Festive SMG not getting crits (Wliu from Dalix)");
			DrawPanelText(panel, "3) Fixed teleport sounds not being played (Wliu from Dalix)");
			DrawPanelText(panel, "4) !ff2_stop_music can now target specific clients (Wliu)");
			DrawPanelText(panel, "5) [Server] Fixed multiple sounds not working after TF2 changed the default sound extension type (Wliu)");
			DrawPanelText(panel, "6) [Dev] Fixed rage damage not resetting after using FF2_SetBossRageDamage (Wliu from WildCard65)");
		}
		case 58:  //1.10.4
		{
			DrawPanelText(panel, "1) Fixed players getting overheal after winning as a boss (Wliu/FlaminSarge)");
			DrawPanelText(panel, "2) Rebalanced the Baby Face's Blaster (Shadow)");
			DrawPanelText(panel, "3) Fixed the Baby Face's Blaster being unusable when FF2 was disabled (Wliu from Curtgust)");
			DrawPanelText(panel, "4) Fixed the Darwin's Danger Shield getting replaced by the SMG (Wliu)");
			DrawPanelText(panel, "5) Added the Tide Turner and new festive weapons to the weapon whitelist (Wliu)");
			DrawPanelText(panel, "See next page (press 1");
		}
		case 57:  //1.10.4
		{
			DrawPanelText(panel, "6) Fixed Market Gardener backstabs (Wliu)");
			DrawPanelText(panel, "7) Improved class switching after you finish the round as a boss (Wliu)");
			DrawPanelText(panel, "8) Fixed the !ff2 command again (Wliu)");
			DrawPanelText(panel, "9) Fixed bosses not ducking when teleporting (CapnDev)");
			DrawPanelText(panel, "10) Prevented dead companion bosses from becoming clones (Wliu)");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 56:  //1.10.4
		{
			DrawPanelText(panel, "11) [Server] Fixed 'ff2_alive' never being shown (Wliu from various)");
			DrawPanelText(panel, "12) [Server] Fixed invalid healthbar errors (Wliu from ClassicGuzzi)");
			DrawPanelText(panel, "13) [Server] Fixed OnTakeDamage errors from spell Monoculuses (Wliu from ClassicGuzzi)");
			DrawPanelText(panel, "14) [Server] Added 'ff2_arena_rounds' and deprecated 'ff2_first_round' (Wliu from Spyper)");
			DrawPanelText(panel, "15) [Server] Added 'ff2_base_jumper_stun' to disable the parachute on stun (Wliu from Shadow)");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 55:  //1.10.4
		{
			DrawPanelText(panel, "16) [Server] Prevented FF2 from loading if it gets loaded in the /plugins/freaks/ directory (Wliu)");
			DrawPanelText(panel, "17) [Dev] Fixed 'sound_fail' (Wliu from M76030)");
			DrawPanelText(panel, "18) [Dev] Allowed companions to emit 'sound_nextlife' if they have it (Wliu from M76030)");
			DrawPanelText(panel, "19) [Dev] Added 'sound_last_life' (Wliu from WildCard65)");
			DrawPanelText(panel, "20) [Dev] Added FF2_OnAlivePlayersChanged and deprecated FF2_Get{Alive|Boss}Players (Wliu from Shadow)");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 54:  //1.10.4
		{
			DrawPanelText(panel, "21) [Dev] Fixed AIOOB errors in FF2_GetBossUserId (Wliu)");
			DrawPanelText(panel, "22) [Dev] Improved FF2_OnSpecialSelected so that only part of a boss name is needed (Wliu)");
			DrawPanelText(panel, "23) [Dev] Added FF2_{Get|Set}BossRageDamage (Wliu from WildCard65)");
		}
		case 53:  //1.10.3
		{
			DrawPanelText(panel, "1) Fixed bosses appearing to be overhealed (War3Evo/Wliu)");
			DrawPanelText(panel, "2) Rebalanced many weapons based on misc. feedback (Wliu/various)");
			DrawPanelText(panel, "3) Fixed not being able to use strange syringe guns or mediguns (Chris from Spyper)");
			DrawPanelText(panel, "4) Fixed the Bread Bite being replaced by the GRU (Wliu from Spyper)");
			DrawPanelText(panel, "5) Fixed Mantreads not giving extra rocket jump height (Chdata");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 52:  //1.10.3
		{
			DrawPanelText(panel, "6) Prevented bosses from picking up ammo/health by default (friagram)");
			DrawPanelText(panel, "7) Fixed a bug with respawning bosses (Wliu from Spyper)");
			DrawPanelText(panel, "8) Fixed an issue with displaying boss health in chat (Wliu)");
			DrawPanelText(panel, "9) Fixed an edge case where player crits would not be applied (Wliu from Spyper)");
			DrawPanelText(panel, "10) Fixed not being able to suicide as boss after round end (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 51:  //1.10.3
		{
			DrawPanelText(panel, "11) Updated Russian translations (wasder) and added German translations (CooliMC)");
			DrawPanelText(panel, "12) Fixed Dead Ringer deaths being too obvious (Wliu from AliceTaylor12)");
			DrawPanelText(panel, "13) Fixed many bosses not voicing their catch phrases (Wliu)");
			DrawPanelText(panel, "14) Updated Gentlespy, Easter Bunny, Demopan, and CBS (Wliu, configs need to be updated)");
			DrawPanelText(panel, "15) [Server] Added new cvar 'ff2_countdown_result' (Wliu from Shadow)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 50:  //1.10.3
		{
			DrawPanelText(panel, "16) [Server] Added new cvar 'ff2_caber_detonations' (Wliu)");
			DrawPanelText(panel, "17) [Server] Fixed a bug related to 'cvar_countdown_players' and the countdown timer (Wliu from Spyper)");
			DrawPanelText(panel, "18) [Server] Fixed 'nextmap_charset' VFormat errors (Wliu from BBG_Theory)");
			DrawPanelText(panel, "19) [Server] Fixed errors when Monoculus was attacking (Wliu from ClassicGuzzi)");
			DrawPanelText(panel, "20) [Dev] Added 'sound_first_blood' (Wliu from Mr-Bro)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 49:  //1.10.3
		{
			DrawPanelText(panel, "21) [Dev] Added 'pickups' to set what the boss can pick up (Wliu)");
			DrawPanelText(panel, "22) [Dev] Added FF2FLAG_ALLOW_{HEALTH|AMMO}_PICKUPS (Powerlord)");
			DrawPanelText(panel, "23) [Dev] Added FF2_GetFF2Version (Wliu)");
			DrawPanelText(panel, "24) [Dev] Added FF2_ShowSync{Hud}Text wrappers (Wliu)");
			DrawPanelText(panel, "25) [Dev] Added FF2_SetAmmo and fixed setting clip (Wliu/friagram for fixing clip)");
			DrawPanelText(panel, "26) [Dev] Fixed weapons not being hidden when asked to (friagram)");
			DrawPanelText(panel, "27) [Dev] Fixed not being able to set constant health values for bosses (Wliu from braak0405)");
		}
		case 48:  //1.10.2
		{
			DrawPanelText(panel, "1) Fixed a critical bug that rendered most bosses as errors without sound (Wliu; thanks to slavko17 for reporting)");
			DrawPanelText(panel, "2) Reverted escape sequences change, which is what caused this bug");
		}
		case 47:  //1.10.1
		{
			DrawPanelText(panel, "1) Fixed a rare bug where rage could go over 100% (Wliu)");
			DrawPanelText(panel, "2) Updated to use Sourcemod 1.6.1 (Powerlord)");
			DrawPanelText(panel, "3) Fixed goomba stomp ignoring demoshields (Wliu)");
			DrawPanelText(panel, "4) Disabled boss from spectating (Wliu)");
			DrawPanelText(panel, "5) Fixed some possible overlapping HUD text (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 46:  //1.10.1
		{
			DrawPanelText(panel, "6) Fixed ff2_charset displaying incorrect colors (Wliu)");
			DrawPanelText(panel, "7) Boss info text now also displays in the chat area (Wliu)");
			DrawPanelText(panel, "--Partially synced with VSH 1.49 (all VSH changes listed courtesy of Chdata)--");
			DrawPanelText(panel, "8) VSH: Do not show HUD text if the scoreboard is open");
			DrawPanelText(panel, "9) VSH: Added market gardener 'backstab'");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 45:  //1.10.1
		{
			DrawPanelText(panel, "10) VSH: Removed Darwin's Danger Shield from the blacklist (Chdata) and gave it a +50 health bonus (Wliu)");
			DrawPanelText(panel, "11) VSH: Rebalanced Phlogistinator");
			DrawPanelText(panel, "12) VSH: Improved backstab code");
			DrawPanelText(panel, "13) VSH: Added ff2_shield_crits cvar to control whether or not demomen get crits when using shields");
			DrawPanelText(panel, "14) VSH: Reserve Shooter now deals crits to bosses in mid-air");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 44:  //1.10.1
		{
			DrawPanelText(panel, "15) [Server] Fixed conditions still being added when FF2 was disabled (Wliu)");
			DrawPanelText(panel, "16) [Server] Fixed a rare healthbar error (Wliu)");
			DrawPanelText(panel, "17) [Server] Added convar ff2_boss_suicide to control whether or not the boss can suicide after the round starts (Wliu)");
			DrawPanelText(panel, "18) [Server] Changed ff2_boss_teleporter's default value to 0 (Wliu)");
			DrawPanelText(panel, "19) [Server] Updated translations (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 43:  //1.10.1
		{
			DrawPanelText(panel, "20) [Dev] Added FF2_GetAlivePlayers and FF2_GetBossPlayers (Wliu/AliceTaylor)");
			DrawPanelText(panel, "21) [Dev] Fixed a bug in the main include file (Wliu)");
			DrawPanelText(panel, "22) [Dev] Enabled escape sequences in configs (Wliu)");
		}
		case 42:  //1.10.0
		{
			DrawPanelText(panel, "1) Rage is now activated by calling for medic (Wliu)");
			DrawPanelText(panel, "2) Balanced Goomba Stomp and RTD (WildCard65)");
			DrawPanelText(panel, "3) Fixed BGM not stopping if the boss suicides at the beginning of the round (Wliu)");
			DrawPanelText(panel, "4) Fixed Jarate, etc. not disappearing immediately on the boss (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 41:  //1.10.0
		{
			DrawPanelText(panel, "5) Fixed ability timers not resetting when the round was over (Wliu)");
			DrawPanelText(panel, "6) Fixed bosses losing momentum when raging in the air (Wliu)");
			DrawPanelText(panel, "7) Fixed bosses losing health if their companion left at round start (Wliu)");
			DrawPanelText(panel, "8) Fixed bosses sometimes teleporting to each other if they had a companion (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 40:  //1.10.0
		{
			DrawPanelText(panel, "9) Optimized the health calculation system (WildCard65)");
			DrawPanelText(panel, "10) Slightly tweaked default boss health formula to be more balanced (Eggman)");
			DrawPanelText(panel, "11) Fixed and optimized the leaderboard (Wliu)");
			DrawPanelText(panel, "12) Fixed medic minions receiving the medigun (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 39:  //1.10.0
		{
			DrawPanelText(panel, "13) Fixed Ninja Spy slow-mo bugs (Wliu/Powerlord)");
			DrawPanelText(panel, "14) Prevented players from changing to the incorrect team or class (Powerlord/Wliu)");
			DrawPanelText(panel, "15) Fixed bosses immediately dying after using the dead ringer (Wliu)");
			DrawPanelText(panel, "16) Fixed a rare bug where you could get notified about being the next boss multiple times (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 38:  //1.10.0
		{
			DrawPanelText(panel, "17) Fixed gravity not resetting correctly after a weighdown if using non-standard gravity (Wliu)");
			DrawPanelText(panel, "18) [Server] FF2 now properly disables itself when required (Wliu/Powerlord)");
			DrawPanelText(panel, "19) [Server] Added ammo, clip, and health arguments to rage_cloneattack (Wliu)");
			DrawPanelText(panel, "20) [Server] Changed how BossCrits works...again (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 37:  //1.10.0
		{
			DrawPanelText(panel, "21) [Server] Removed convar ff2_halloween (Wliu)");
			DrawPanelText(panel, "22) [Server] Moved convar ff2_oldjump to the main config file (Wliu)");
			DrawPanelText(panel, "23) [Server] Added convar ff2_countdown_players to control when the timer should appear (Wliu/BBG_Theory)");
			DrawPanelText(panel, "24) [Server] Added convar ff2_updater to control whether automatic updating should be turned on (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 36:  //1.10.0
		{
			DrawPanelText(panel, "25) [Server] Added convar ff2_goomba_jump to control how high players should rebound after goomba stomping the boss (WildCard65)");
			DrawPanelText(panel, "26) [Server] Fixed hale_point_enable/disable being registered twice (Wliu)");
			DrawPanelText(panel, "27) [Server] Fixed some convars not executing (Wliu)");
			DrawPanelText(panel, "28) [Server] Fixed the chances and charset systems (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 35:  //1.10.0
		{
			DrawPanelText(panel, "29) [Dev] Added more natives and one additional forward (Eggman)");
			DrawPanelText(panel, "30) [Dev] Added sound_full_rage which plays once the boss is able to rage (Wliu/Eggman)");
			DrawPanelText(panel, "31) [Dev] Fixed FF2FLAG_ISBUFFED (Wliu)");
			DrawPanelText(panel, "32) [Dev] FF2 now checks for sane values for \"lives\" and \"health_formula\" (Wliu)");
			DrawPanelText(panel, "Big thanks to GIANT_CRAB, WildCard65, and kniL for their devotion to this release!");
		}
		case 34:  //1.9.3
		{
			DrawPanelText(panel, "1) Fixed a bug in 1.9.2 where the changelog was off by one version (Wliu)");
			DrawPanelText(panel, "2) Fixed a bug in 1.9.2 where one dead player would not be cloned in rage_cloneattack (Wliu)");
			DrawPanelText(panel, "3) Fixed a bug in 1.9.2 where sentries would be permanently disabled after a rage (Wliu)");
			DrawPanelText(panel, "4) [Server] Removed ff2_halloween (Wliu)");
		}
		case 33:  //1.9.2
		{
			DrawPanelText(panel, "1) Fixed a bug in 1.9.1 that allowed the same player to be the boss over and over again (Wliu)");
			DrawPanelText(panel, "2) Fixed a bug where last player glow was being incorrectly removed on the boss (Wliu)");
			DrawPanelText(panel, "3) Fixed a bug where the boss would be assumed dead (Wliu)");
			DrawPanelText(panel, "4) Fixed having minions on the boss team interfering with certain rage calculations (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 32:  //1.9.2
		{
			DrawPanelText(panel, "5) Fixed a rare bug where the rage percentage could go above 100% (Wliu)");
			DrawPanelText(panel, "6) [Server] Fixed possible special_noanims errors (Wliu)");
			DrawPanelText(panel, "7) [Server] Added new arguments to rage_cloneattack-no updates necessary (friagram/Wliu)");
			DrawPanelText(panel, "8) [Server] Certain cvars that SMAC detects are now automatically disabled while FF2 is running (Wliu)");
			DrawPanelText(panel, "            Servers can now safely have smac_cvars enabled");
		}
		case 31:  //1.9.1
		{
			DrawPanelText(panel, "1) Fixed some minor leaderboard bugs and also improved the leaderboard text (Wliu)");
			DrawPanelText(panel, "2) Fixed a minor round end bug (Wliu)");
			DrawPanelText(panel, "3) [Server] Fixed improper unloading of subplugins (WildCard65)");
			DrawPanelText(panel, "4) [Server] Removed leftover console messages (Wliu)");
			DrawPanelText(panel, "5) [Server] Fixed sound not precached warnings (Wliu)");
		}
		case 30:  //1.9.0
		{
			DrawPanelText(panel, "1) Removed checkFirstHale (Wliu)");
			DrawPanelText(panel, "2) [Server] Fixed invalid healthbar entity bug (Wliu)");
			DrawPanelText(panel, "3) Changed default medic ubercharge percentage to 40% (Wliu)");
			DrawPanelText(panel, "4) Whitelisted festive variants of weapons (Wliu/BBG_Theory)");
			DrawPanelText(panel, "5) [Server] Added convars to control last player glow and timer health cutoff (Wliu");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 29:  //1.9.0
		{
			DrawPanelText(panel, "6) [Dev] Added new natives/stocks: Debug, FF2_SetClientGlow and FF2_GetClientGlow (Wliu)");
			DrawPanelText(panel, "7) Fixed a few minor !whatsnew bugs (BBG_Theory)");
			DrawPanelText(panel, "8) Fixed Easter Abilities (Wliu)");
			DrawPanelText(panel, "9) Minor grammar/spelling improvements (Wliu)");
			DrawPanelText(panel, "10) [Server] Minor subplugin load/unload fixes (Wliu)");
		}
		case 28:  //1.0.8
		{
			DrawPanelText(panel, "Wliu, Chris, Lawd, and Carge of 50DKP have taken over FF2 development");
			DrawPanelText(panel, "1) Prevented spy bosses from changing disguises (Powerlord)");
			DrawPanelText(panel, "2) Added Saxton Hale stab sounds (Powerlord/AeroAcrobat)");
			DrawPanelText(panel, "3) Made sure that the boss doesn't have any invalid weapons/items (Powerlord)");
			DrawPanelText(panel, "4) Tried fixing the visible weapon bug (Powerlord)");
			DrawPanelText(panel, "5) Whitelisted some more action slot items (Powerlord)");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 27:  //1.0.8
		{
			DrawPanelText(panel, "6) Festive Huntsman has the same attributes as the Huntsman now (Powerlord)");
			DrawPanelText(panel, "7) Medigun now overheals 50% more (Powerlord)");
			DrawPanelText(panel, "8) Made medigun transparent if the medic's melee was the Gunslinger (Powerlord)");
			DrawPanelText(panel, "9) Slight tweaks to the view hp commands (Powerlord)");
			DrawPanelText(panel, "10) Whitelisted the Silver/Gold Botkiller Sniper Rifle Mk.II (Powerlord)");
			DrawPanelText(panel, "11) Slight tweaks to boss health calculation (Powerlord)");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 26:  //1.0.8
		{
			DrawPanelText(panel, "12) Made sure that spies couldn't quick-backstab the boss (Powerlord)");
			DrawPanelText(panel, "13) Made sure the stab animations were correct (Powerlord)");
			DrawPanelText(panel, "14) Made sure that healthpacks spawned from the Candy Cane are not respawned once someone uses them (Powerlord)");
			DrawPanelText(panel, "15) Healthpacks from the Candy Cane are no longer despawned (Powerlord)");
			DrawPanelText(panel, "16) Slight tweaks to removing laughs (Powerlord)");
			DrawPanelText(panel, "17) [Dev] Added a clip argument to special_noanims.sp (Powerlord)");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 25:  //1.0.8
		{
			DrawPanelText(panel, "18) [Dev] sound_bgm is now precached automagically (Powerlord)");
			DrawPanelText(panel, "19) Seeldier's minions can no longer cap (Wliu)");
			DrawPanelText(panel, "20) Fixed sometimes getting stuck when teleporting to a ducking player (Powerlord)");
			DrawPanelText(panel, "21) Multiple English translation improvements (Wliu/Powerlord)");
			DrawPanelText(panel, "22) Fixed Ninja Spy and other bosses that use the matrix ability getting stuck in walls/ceilings (Chris)");
			DrawPanelText(panel, "23) [Dev] Updated item attributes code per the TF2Items update (Powerlord)");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 24:  //1.0.8
		{
			DrawPanelText(panel, "24) Fixed duplicate sound downloads for Saxton Hale (Wliu)");
			DrawPanelText(panel, "25) [Server] FF2 now require morecolors, not colors (Powerlord)");
			DrawPanelText(panel, "26) [Server] Added a Halloween mode which will enable characters_halloween.cfg (Wliu)");
			DrawPanelText(panel, "27) Hopefully fixed multiple round-related issues (Wliu)");
			DrawPanelText(panel, "28) [Dev] Started to clean up/format the code (Wliu)");
			DrawPanelText(panel, "29) Changed versioning format to x.y.z and month day, year (Wliu)");
			DrawPanelText(panel, "HAPPY HALLOWEEN!");
		}
		case 23:  //1.07
		{
			DrawPanelText(panel, "1) [Players] Holiday Punch is now replaced by Fists");
			DrawPanelText(panel, "2) [Players] Bosses will have any disguises removed on round start");
			DrawPanelText(panel, "3) [Players] Bosses can no longer see all players health, as it wasn't working any more");
			DrawPanelText(panel, "4) [Server] ff2_addpoints no longer targets SourceTV or replay");
		}
		case 22:  //1.07 beta 6
		{
			DrawPanelText(panel, "1) [Dev] Fixed issue with sound hook not stopping sound when sound_block_vo was in use");
			DrawPanelText(panel, "2) [Dev] If ff2_charset was used, don't run the character set vote");
			DrawPanelText(panel, "3) [Dev] If a vote is already running, Character set vote will retry every 5 seconds or until map changes ");
		}
		case 21:  //1.07 beta 5
		{
			DrawPanelText(panel, "1) [Dev] Fixed issue with character sets not working.");
			DrawPanelText(panel, "2) [Dev] Improved IsValidClient replay check");
			DrawPanelText(panel, "3) [Dev] IsValidClient is now called when loading companion bosses");
			DrawPanelText(panel, "   This should prevent GetEntProp issues with m_iClass");
		}
		case 20:  //1.07 beta 4
		{
			DrawPanelText(panel, "1) [Players] Dead Ringers have no cloak defense buff. Normal cloaks do.");
			DrawPanelText(panel, "2) [Players] Fixed Sniper Rifle reskin behavior");
			DrawPanelText(panel, "3) [Players] Boss has small amount of stun resistance after rage");
			DrawPanelText(panel, "4) [Players] Various bugfixes and changes 1.7.0 beta 1");
		}
		case 19:  //1.07 beta
		{
			DrawPanelText(panel, "22) [Dev] Prevent boss rage from being activated if the boss is already taunting or is dead.");
			DrawPanelText(panel, "23) [Dev] Cache the result of the newer backstab detection");
			DrawPanelText(panel, "24) [Dev] Reworked Medic damage code slightly");
		}
		case 18:  //1.07 beta
		{
			DrawPanelText(panel, "16) [Server] The Boss queue now accepts negative points.");
			DrawPanelText(panel, "17) [Server] Bosses can be forced to a specific team using the new ff2_force_team cvar.");
			DrawPanelText(panel, "18) [Server] Eureka Effect can now be enabled using the new ff2_enable_eureka cvar");
			DrawPanelText(panel, "19) [Server] Bosses models and sounds are now precached the first time they are loaded.");
			DrawPanelText(panel, "20) [Dev] Fixed an issue where FF2 was trying to read cvars before config files were executed.");
			DrawPanelText(panel, "    This change should also make the game a little more multi-mod friendly.");
			DrawPanelText(panel, "21) [Dev] Fixed OnLoadCharacterSet not being fired. This should fix the deadrun plugin.");
			DrawPanelText(panel, "Continued on next page");
		}
		case 17:  //1.07 beta
		{
			DrawPanelText(panel, "10) [Players] Heatmaker gains Focus on hit (varies by charge)");
			DrawPanelText(panel, "11) [Players] Crusader's Crossbow damage has been adjusted to compensate for its speed increase.");
			DrawPanelText(panel, "12) [Players] Cozy Camper now gives you an SMG as well, but it has no crits and reduced damage.");
			DrawPanelText(panel, "13) [Players] Bosses get short defense buff after rage");
			DrawPanelText(panel, "14) [Server] Now attempts to integrate tf2items config");
			DrawPanelText(panel, "15) [Server] Changing the game description now requires Steam Tools");
			DrawPanelText(panel, "Continued on next page");
		}
		case 16:  //1.07 beta
		{
			DrawPanelText(panel, "6) [Players] Removed crits from sniper rifles, now do 2.9x damage");
			DrawPanelText(panel, "   Sydney Sleeper does 2.4x damage, 2.9x if boss's rage is >90pct");
			DrawPanelText(panel, "   Minicrit- less damage, more knockback");
			DrawPanelText(panel, "7) [Players] Baby Face's Blaster will fill boost normally, but will hit 100 and drain+minicrits.");
			DrawPanelText(panel, "8) [Players] Phlogistinator Pyros are invincible while activating the crit-boost taunt.");
			DrawPanelText(panel, "9) [Players] Can't Eureka+destroy dispenser to insta-teleport");
			DrawPanelText(panel, "Continued on next page");
		}
		case 15:  //1.07 beta
		{
			DrawPanelText(panel, "1) [Players] Reworked the crit code a bit. Should be more reliable.");
			DrawPanelText(panel, "2) [Players] Help panel should stop repeatedly popping up on round start.");
			DrawPanelText(panel, "3) [Players] Backstab disguising should be smoother/less obvious");
			DrawPanelText(panel, "4) [Players] Scaled sniper rifle glow time a bit better");
			DrawPanelText(panel, "5) [Players] Fixed Dead Ringer spy death icon");
			DrawPanelText(panel, "Continued on next page");
		}
		case 14:  //1.06h
		{
			DrawPanelText(panel, "1) [Players] Remove MvM powerup_bottle on Bosses. (RavensBro)");
		}
		case 13:  //1.06g
		{
			DrawPanelText(panel, "1) [Players] Fixed vote for charset. (RavensBro)");
		}
		case 12:  //1.06f
		{
			DrawPanelText(panel, "1) [Players] Changelog now divided into [Players] and [Dev] sections. (Otokiru)");
			DrawPanelText(panel, "2) [Players] Don't bother reading [Dev] changelogs because you'll have no idea what it's stated. (Otokiru)");
			DrawPanelText(panel, "3) [Players] Fixed civilian glitch. (Otokiru)");
			DrawPanelText(panel, "4) [Players] Fixed hale HP bar. (Valve) lol?");
			DrawPanelText(panel, "5) [Dev] Fixed \"GetEntProp\" reported: Entity XXX (XXX) is invalid on checkFirstHale(). (Otokiru)");
		}
		case 11:  //1.06e
		{

			DrawPanelText(panel, "1) [Players] Remove MvM water-bottle on hales. (Otokiru)");
			DrawPanelText(panel, "2) [Dev] Fixed \"GetEntProp\" reported: Property \"m_iClass\" not found (entity 0/worldspawn) error on checkFirstHale(). (Otokiru)");
			DrawPanelText(panel, "3) [Dev] Change how FF2 check for player weapons. Now also checks when spawned in the middle of the round. (Otokiru)");
			DrawPanelText(panel, "4) [Dev] Changed some FF2 warning messages color such as \"First-Hale Checker\" and \"Change class exploit\". (Otokiru)");
		}
		case 10:  //1.06d
		{
			DrawPanelText(panel, "1) Fix first boss having missing health or abilities. (Otokiru)");
			DrawPanelText(panel, "2) Health bar now goes away if the boss wins the round. (Powerlord)");
			DrawPanelText(panel, "3) Health bar cedes control to Monoculus if he is summoned. (Powerlord)");
			DrawPanelText(panel, "4) Health bar instantly updates if enabled or disabled via cvar mid-game. (Powerlord)");
		}
		case 9:  //1.06c
		{
			DrawPanelText(panel, "1) Remove weapons if a player tries to switch classes when they become boss to prevent an exploit. (Otokiru)");
			DrawPanelText(panel, "2) Reset hale's queue points to prevent the 'retry' exploit. (Otokiru)");
			DrawPanelText(panel, "3) Better detection of backstabs. (Powerlord)");
			DrawPanelText(panel, "4) Boss now has optional life meter on screen. (Powerlord)");
		}
		case 8:  //1.06
		{
			DrawPanelText(panel, "1) Fixed attributes key for weaponN block. Now 1 space needed for explode string.");
			DrawPanelText(panel, "2) Disabled vote for charset when there is only 1 not hidden chatset.");
			DrawPanelText(panel, "3) Fixed \"Invalid key value handle 0 (error 4)\" when when round starts.");
			DrawPanelText(panel, "4) Fixed ammo for special_noanims.ff2\\rage_new_weapon ability.");
			DrawPanelText(panel, "Coming soon: weapon balance will be moved into config file.");
		}
		case 7:  //1.05
		{
			DrawPanelText(panel, "1) Added \"hidden\" key for charsets.");
			DrawPanelText(panel, "2) Added \"sound_stabbed\" key for characters.");
			DrawPanelText(panel, "3) Mantread stomp deals 5x damage to Boss.");
			DrawPanelText(panel, "4) Minicrits will not play loud sound to all players");
			DrawPanelText(panel, "5-11) See next page...");
		}
		case 6:  //1.05
		{
			DrawPanelText(panel, "6) For mappers: Add info_target with name 'hale_no_music'");
			DrawPanelText(panel, "    to prevent Boss' music.");
			DrawPanelText(panel, "7) FF2 renames *.smx from plugins/freaks/ to *.ff2 by itself.");
			DrawPanelText(panel, "8) Third Degree hit adds uber to healers.");
			DrawPanelText(panel, "9) Fixed hard \"ghost_appearation\" in default_abilities.ff2.");
			DrawPanelText(panel, "10) FF2FLAG_HUDDISABLED flag blocks EVERYTHING of FF2's HUD.");
			DrawPanelText(panel, "11) Changed FF2_PreAbility native to fix bug about broken Boss' abilities.");
		}
		case 5:  //1.04
		{
			DrawPanelText(panel, "1) Seeldier's minions have protection (teleport) from pits for first 4 seconds after spawn.");
			DrawPanelText(panel, "2) Seeldier's minions correctly dies when owner-Seeldier dies.");
			DrawPanelText(panel, "3) Added multiplier for brave jump ability in char.configs (arg3, default is 1.0).");
			DrawPanelText(panel, "4) Added config key sound_fail. It calls when Boss fails, but still alive");
			DrawPanelText(panel, "4) Fixed potential exploits associated with feign death.");
			DrawPanelText(panel, "6) Added ff2_reload_subplugins command to reload FF2's subplugins.");
		}
		case 4:  //1.03
		{
			DrawPanelText(panel, "1) Finally fixed exploit about queue points.");
			DrawPanelText(panel, "2) Fixed non-regular bug with 'UTIL_SetModel: not precached'.");
			DrawPanelText(panel, "3) Fixed potential bug about reducing of Boss' health by healing.");
			DrawPanelText(panel, "4) Fixed Boss' stun when round begins.");
		}
		case 3:  //1.02
		{
			DrawPanelText(panel, "1) Added isNumOfSpecial parameter into FF2_GetSpecialKV and FF2_GetBossSpecial natives");
			DrawPanelText(panel, "2) Added FF2_PreAbility forward. Plz use it to prevent FF2_OnAbility only.");
			DrawPanelText(panel, "3) Added FF2_DoAbility native.");
			DrawPanelText(panel, "4) Fixed exploit about queue points...ow wait, it done in 1.01");
			DrawPanelText(panel, "5) ff2_1st_set_abilities.ff2 sets kac_enabled to 0.");
			DrawPanelText(panel, "6) FF2FLAG_HUDDISABLED flag disables Boss' HUD too.");
			DrawPanelText(panel, "7) Added FF2_GetQueuePoints and FF2_SetQueuePoints natives.");
		}
		case 2:  //1.01
		{
			DrawPanelText(panel, "1) Fixed \"classmix\" bug associated with Boss' class restoring.");
			DrawPanelText(panel, "3) Fixed other little bugs.");
			DrawPanelText(panel, "4) Fixed bug about instant kill of Seeldier's minions.");
			DrawPanelText(panel, "5) Now you can use name of Boss' file for \"companion\" Boss' keyvalue.");
			DrawPanelText(panel, "6) Fixed exploit when dead Boss can been respawned after his reconnect.");
			DrawPanelText(panel, "7-10) See next page...");
		}
		case 1:  //1.01
		{
			DrawPanelText(panel, "7) I've missed 2nd item.");
			DrawPanelText(panel, "8) Fixed \"Random\" charpack, there is no vote if only one charpack.");
			DrawPanelText(panel, "9) Fixed bug when boss' music have a chance to DON'T play.");
			DrawPanelText(panel, "10) Fixed bug associated with ff2_enabled in cfg/sourcemod/FreakFortress2.cfg and disabling of pugin.");
		}
		case 0:  //1.0
		{
			DrawPanelText(panel, "1) Boss' health devided by 3,6 in medieval mode");
			DrawPanelText(panel, "2) Restoring player's default class, after his round as Boss");
			DrawPanelText(panel, "===UPDATES OF VS SAXTON HALE MODE===");
			DrawPanelText(panel, "1) Added !ff2_resetqueuepoints command (also there is admin version)");
			DrawPanelText(panel, "2) Medic is credited 100% of damage done during ubercharge");
			DrawPanelText(panel, "3) If map changes mid-round, queue points not lost");
			DrawPanelText(panel, "4) Dead Ringer will not be able to activate for 2s after backstab");
			DrawPanelText(panel, "5) Added ff2_spec_force_boss cvar");
		}
		default:
		{
			DrawPanelText(panel, "-- Somehow you've managed to find a glitched version page!");
			DrawPanelText(panel, "-- Congratulations.  Now go and fight!");
		}
	}
}

static const int maxVersion=sizeof(ff2versiontitles)-1;

public int NewPanelH(Handle menu, MenuAction action, int param1, int param2)
{
	if(action==MenuAction_Select)
	{
		switch(param2)
		{
			case 1:
			{
				if(curHelp[param1]<=0)
					NewPanel(param1, 0);
				else
					NewPanel(param1, --curHelp[param1]);
			}
			case 2:
			{
				if(curHelp[param1]>=maxVersion)
					NewPanel(param1, maxVersion);
				else
					NewPanel(param1, ++curHelp[param1]);
			}
			default: return;
		}
	}
}

public Action NewPanelCmd(int client, int args)
{
	if(!IsValidClient(client))
	{
		return Plugin_Continue;
	}

	NewPanel(client, maxVersion);
	return Plugin_Handled;
}

public Action NewPanel(int client, int versionIndex)
{
	if(!Enabled2)
		return Plugin_Continue;

	if(versionIndex<0)
		curHelp[client]=maxVersion;
	else
		curHelp[client]=versionIndex;

	Handle panel=CreatePanel();
	char whatsNew[90];

	SetGlobalTransTarget(client);
	Format(whatsNew, 90, "=%t:=", "whatsnew", ff2versiontitles[versionIndex], ff2versiondates[versionIndex]);
	SetPanelTitle(panel, whatsNew);
	FindVersionData(panel, versionIndex);
	if(versionIndex>0)
	{
		Format(whatsNew, 90, "%t", "older");
	}
	else
	{
		Format(whatsNew, 90, "%t", "noolder");
	}

	DrawPanelItem(panel, whatsNew);
	if(versionIndex<maxVersion)
	{
		Format(whatsNew, 90, "%t", "newer");
	}
	else
	{
		Format(whatsNew, 90, "%t", "nonewer");
	}

	DrawPanelItem(panel, whatsNew);
	Format(whatsNew, 512, "%T", "menu_6", client);
	DrawPanelItem(panel, whatsNew);
	SendPanelToClient(panel, client, NewPanelH, MENU_TIME_FOREVER);
	CloseHandle(panel);
	return Plugin_Continue;
}

public Action Timer_LastUpdate(Handle timer)
{
	if(Announce>1.0 && Enabled2)
	{
		CPrintToChatAll("{olive}[FF2]{default} %t", "ff2_last_update", PLUGIN_VERSION, ff2versiondates[maxVersion]);
	}

	return Plugin_Continue;
}

#if !CHANGELOG
#error "Changelog is disabled but used?"
#endif

#file "FF2 Module: Changelog"
