#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <dhooks>

public Plugin myinfo =
{
	name = "FixPointViewcontrol",
	author = "xen + BotoX",
	description = "Fixes the point_viewcontrol bug",
	version = "1.2",
	url = ""
}

DynamicHook g_hAcceptInput;

public void OnPluginStart()
{
	// Gamedata.
	GameData hConfig = new GameData("sdktools.games");
	if (hConfig == null)
		SetFailState("Couldn't load sdktools game config!");

	int offset = hConfig.GetOffset("AcceptInput");
	if (offset == -1)
		SetFailState("Failed to find AcceptInput offset");

	delete hConfig;

	// DHooks.
	g_hAcceptInput = new DynamicHook(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity);
	g_hAcceptInput.AddParam(HookParamType_CharPtr);
	g_hAcceptInput.AddParam(HookParamType_CBaseEntity);
	g_hAcceptInput.AddParam(HookParamType_CBaseEntity);
	g_hAcceptInput.AddParam(HookParamType_Object, 20, DHookPass_ByVal|DHookPass_ODTOR|DHookPass_OCTOR|DHookPass_OASSIGNOP);
	g_hAcceptInput.AddParam(HookParamType_Int);
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrEqual(classname, "point_viewcontrol"))
		g_hAcceptInput.HookEntity(Hook_Pre, entity, Hook_AcceptInput);
}

public MRESReturn Hook_AcceptInput(int entity, DHookReturn hReturn, DHookParam hParams)
{
	char sCommand[128];
	hParams.GetString(1, sCommand, sizeof(sCommand));

	if(hParams.IsNull(2))
		return MRES_Ignored;

	int iActivator = hParams.Get(2);
	
	if (iActivator < 1 || iActivator > MaxClients)
		return MRES_Ignored;
	else if (StrEqual(sCommand, "Disable", false))
		SetEntPropEnt(entity, Prop_Data, "m_hPlayer", iActivator);

	return MRES_Ignored;
}
