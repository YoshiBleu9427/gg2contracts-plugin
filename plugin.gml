globalvar Contracts;
Contracts = id;



BACKEND_HOST = "localhost"
BACKEND_PORT = 4646

contracts_by_uuid = ds_map_create();
players_by_session_token = ds_map_create();

user_key = ""
session_token = ""

joined_server_id = ""

server_id = ""
server_validation_token = ""

execute_file(directory + "\src\ErrorLog.gml");
execute_file(directory + "\src\ini.gml");
execute_file(directory + "\src\Player.gml");
execute_file(directory + "\src\Contract.gml");
execute_file(directory + "\src\BackendNetworker.gml");
execute_file(directory + "\src\PluginNetworker.gml");
execute_file(directory + "\src\RoundEndObserver.gml");
execute_file(directory + "\src\contract_rules.gml");
execute_file(directory + "\src\menus.gml");
