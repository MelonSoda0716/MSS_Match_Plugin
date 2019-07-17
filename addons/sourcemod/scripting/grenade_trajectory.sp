/* grenade trajectory */
new BeamSprite;
new ColorArray[] = {0, 128, 0, 255};

public OnEntityCreated(entity, const String:classname[]){
    
    if(nade_mode == true){
        if(IsValidEntity(entity)) SDKHook(entity, SDKHook_SpawnPost, OnEntitySpawned);
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