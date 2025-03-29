INI_SECTION = "Contracts";
INI_USER_KEY_KEY = "user_key";
INI_SERVER_ID_KEY = "server_id";
INI_SERVER_VALID_TOKEN_KEY = "server_validation_token";
INI_PLAY_SOUNDS_KEY = "play_sounds";
INI_NOTIFY_PROGRESS_KEY = "notify_progress";



ini_open("gg2.ini");
user_key = ini_read_string(INI_SECTION, INI_USER_KEY_KEY, "");
server_id = ini_read_string(INI_SECTION, INI_SERVER_ID_KEY, "");
server_validation_token = ini_read_string(INI_SECTION, INI_SERVER_VALID_TOKEN_KEY, "");
play_sounds = ini_read_real(INI_SECTION, INI_PLAY_SOUNDS_KEY, true);
notify_progress = ini_read_real(INI_SECTION, INI_NOTIFY_PROGRESS_KEY, true);
ini_close();

if (user_key != "") {user_key = unhex(user_key)}
if (server_id != "") {server_id = unhex(server_id)}
if (server_validation_token != "") {server_validation_token = unhex(server_validation_token)}

gg2_write_ini(INI_SECTION, INI_PLAY_SOUNDS_KEY, play_sounds);
gg2_write_ini(INI_SECTION, INI_NOTIFY_PROGRESS_KEY, notify_progress);