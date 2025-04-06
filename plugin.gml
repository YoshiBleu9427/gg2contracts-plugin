globalvar Contracts;
Contracts = id;



BACKEND_HOST = "localhost"
BACKEND_PORT = 4646

WEBSITE_HOST = BACKEND_HOST
WEBSITE_PORT = 51062


snd_beep        = sound_add(directory + "\sounds\beep.mp3", 0, true);
snd_fadeout     = sound_add(directory + "\sounds\fadeout.mp3", 0, true);
snd_increase    = sound_add(directory + "\sounds\increase.mp3", 0, true);
snd_success     = sound_add(directory + "\sounds\success.mp3", 0, true);

img_notification_icon = sprite_add(directory + "\images\notification_icon.png", 1, true, false, 0, 0);
img_contract_icon = sprite_add(directory + "\images\contract_icon.png", 1, true, false, 0, 0);
img_tracker_bg = sprite_add(directory + "\images\tracker_bg.png", 1, true, false, 0, 0);
img_tracker_notif = sprite_add(directory + "\images\tracker_notif.png", 1, true, false, 0, 0);


contracts_by_uuid = ds_map_create();
players_by_session_token = ds_map_create();

user_key = ""
user_points = 0  // TODO
session_token = ""
session_points = 0

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
execute_file(directory + "\src\ContractTracker.gml");
