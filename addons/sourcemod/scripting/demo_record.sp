public ForceCvarChange_cvar_tv_enable(Handle:cvar, const String:oldVal[], const String:newVal[]){

	/* tv_enable "1" */
    SetConVarInt(cvar, 1);
}

public ForceCvarChange_cvar_tv_autorecord(Handle:cvar, const String:oldVal[], const String:newVal[]){

	/* tv_autorecord "0" */
    SetConVarInt(cvar, 0);
}

public Action:DemoRecordStart(Handle:timer){

	decl String:map[128];
	decl String:demo_name[128];
	decl String:demo_directory[128];

	/* 現在のマップ名を取得 */
	GetCurrentMap(map, sizeof(map));
	/* DEMOの名前を取得 */
	GetConVarString(cvar_mss_demo_name, demo_name, sizeof(demo_name));
	/* DEMOのディレクトリを取得 */
	GetConVarString(cvar_mss_damo_directory, demo_directory, sizeof(demo_directory));
	/* DEMO名の日付を取得 */
	FormatTime(demo_name_formated, sizeof(demo_name_formated), demo_name);
	/* ディレクトリ名の日付を取得 */
	FormatTime(demo_directory_formated, sizeof(demo_directory_formated), demo_directory);
	/* マップ名を置換 */
	ReplaceString(demo_name_formated, sizeof(demo_name_formated), "<*MAPNAME*>", map);
	/* スラッシュをアンダーバに置換 */
	ReplaceString(demo_name_formated, sizeof(demo_name_formated), "/", "_");
	/* ディレクトリが存在するかを確認 */
	if(!DirExists(demo_directory_formated)){
		/* DEMO保存先のディレクトリを作成 */
		CreateDirectory_EX();
	}
	/* Full Path */
	Format(full_path, sizeof(full_path), "%s/%s", demo_directory_formated, demo_name_formated);
	/* DEMO録画開始 */
	ServerCommand("tv_record \"%s\"", full_path);
	PrintToServer("Recording Start");

}

public Action:DemoRecordStop(Handle:timer){

	/* DEMO録画停止 */
	ServerCommand("tv_stoprecord");
	PrintToServer("Recording Stop");

}

CreateDirectory_EX(){

	char directory_piece[32][PLATFORM_MAX_PATH];
	char directory_name[PLATFORM_MAX_PATH];
	
	/* スラッシュごとに分割 */
	int explode_count = ExplodeString(demo_directory_formated, "/", directory_piece, sizeof(directory_piece), sizeof(directory_piece[]));

	/* exploade_countだけ */
	for(int i=0 ; i < explode_count ; i++){
		
		Format(directory_name, sizeof(directory_name), "%s/%s", directory_name, directory_piece[i]);
		
		if(!DirExists(directory_name)){

			CreateDirectory(directory_name, 509);

		}

	}

}