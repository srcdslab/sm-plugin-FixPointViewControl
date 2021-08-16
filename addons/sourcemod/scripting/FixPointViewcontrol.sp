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
	version = "1.0",
	url = ""
}

Handle g_hAcceptInput;
int g_iAttachedViewControl[MAXPLAYERS + 1] = {INVALID_ENT_REFERENCE, ...};

public void OnPluginStart()
{
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);

	// Gamedata.
	Handle hConfig = LoadGameConfigFile("sdktools.games");
	if (hConfig == INVALID_HANDLE)
		SetFailState("Couldn't load sdktools game config!");

	int offset = GameConfGetOffset(hConfig, "AcceptInput");
	if (offset == -1)
		SetFailState("Failed to find AcceptInput offset");

	delete hConfig;

	// DHooks.
	g_hAcceptInput = DHookCreate(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, Hook_AcceptInput);
	DHookAddParam(g_hAcceptInput, HookParamType_CharPtr);
	DHookAddParam(g_hAcceptInput, HookParamType_CBaseEntity);
	DHookAddParam(g_hAcceptInput, HookParamType_CBaseEntity);
	DHookAddParam(g_hAcceptInput, HookParamType_Object, 20, DHookPass_ByVal|DHookPass_ODTOR|DHookPass_OCTOR|DHookPass_OASSIGNOP);
	DHookAddParam(g_hAcceptInput, HookParamType_Int);
}

public Action Event_PlayerDeath(Handle hEvent, const char[] szName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	DisableViewControl(client);
}

public void OnClientDisconnect(int client)
{
	DisableViewControl(client);
}

void DisableViewControl(int client)
{
	if (g_iAttachedViewControl[client] == INVALID_ENT_REFERENCE)
		return;

	int entity = EntRefToEntIndex(g_iAttachedViewControl[client]);
	if (entity == INVALID_ENT_REFERENCE)
		return;

	AcceptEntityInput(entity, "Disable", client, entity);
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrEqual(classname, "point_viewcontrol"))
	{
		DHookEntity(g_hAcceptInput, false, entity);
	}
}

public MRESReturn Hook_AcceptInput(int entity, Handle hReturn, Handle hParams)
{
	char sCommand[128];
	DHookGetParamString(hParams, 1, sCommand, sizeof(sCommand));

	if(DHookIsNullParam(hParams, 2))
		return MRES_Ignored;

	int iActivator = DHookGetParam(hParams, 2);
	if (iActivator < 1 || iActivator > MaxClients)
		return MRES_Ignored;

	if (StrEqual(sCommand, "Enable", false))
	{
		g_iAttachedViewControl[iActivator] = EntIndexToEntRef(entity);
	}

	else if (StrEqual(sCommand, "Disable", false))
	{
		SetEntPropEnt(entity, Prop_Data, "m_hPlayer", iActivator);
		g_iAttachedViewControl[iActivator] = INVALID_ENT_REFERENCE;
	}

	return MRES_Ignored;
}
