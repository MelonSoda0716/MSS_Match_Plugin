/* grenade trajectory */
/* warmup 1v1arena */
new BeamSprite;
new ColorArray[] = {0, 128, 0, 255};

public OnEntityCreated(entity, const String:classname[]){
    
    if(nade_mode == true){
        if(IsValidEntity(entity)) SDKHook(entity, SDKHook_SpawnPost, OnEntitySpawned);
    }

    if(GetConVarInt(cvar_mss_warmup_1v1arena_enable) == 0 ){
        if(StrEqual(classname, "logic_script", true) || StrEqual(classname, "trigger_multiple", true)){
            SDKHook(entity, SDKHook_Spawn, OnEntitySpawn_1vs1arena);
        }
    }
    
}

public OnEntitySpawn_1vs1arena(entity){

    char vScripts[256];
    GetEntPropString(entity, Prop_Data, "m_iszVScripts", vScripts, sizeof(vScripts));

    if(StrEqual(vScripts, "warmup/warmup_arena.nut", true) || StrEqual(vScripts, "warmup/warmup_teleport.nut", true)){
        DispatchKeyValue(entity, "vscripts", "");
        DispatchKeyValue(entity, "targetname", "");
    }

}

public OnEntitySpawned(entity){

	if(!IsValidEdict(entity))
		return;

	decl String:class_name[32];
	GetEdictClassname(entity, class_name, 32);
	
	if(StrContains(class_name, "projectile") != -1 && IsValidEntity(entity)){

        /* tailtime 20.0 ailwidth 1.0 tailwidth 1.0 tailfadetime 1*/
        TE_SetupBeamFollow(entity, BeamSprite, 0, 20.0, 1.0, 1.0, 1, ColorArray);
        TE_SendToAll();
        
    }

}