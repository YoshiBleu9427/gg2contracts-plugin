INI_SECTION = "Contracts";
INI_USER_KEY_KEY = "user_key";
INI_SERVER_ID_KEY = "server_id";
INI_SERVER_VALID_TOKEN_KEY = "server_validation_token";
INI_SESSION_TOKEN_KEY = "session_token";
INI_LAST_JOINED_SERVER_KEY = "last_joined_server";

ini_open("gg2.ini");
user_key = ini_read_string(INI_SECTION, INI_USER_KEY_KEY, "");
session_token = ini_read_string(INI_SECTION, INI_SESSION_TOKEN_KEY, "");
last_joined_server = ini_read_string(INI_SECTION, INI_LAST_JOINED_SERVER_KEY, "");
server_id = ini_read_string(INI_SECTION, INI_SERVER_ID_KEY, "");
server_validation_token = ini_read_string(INI_SECTION, INI_SERVER_VALID_TOKEN_KEY, "");
ini_close();

if (user_key != "") {user_key = unhex(user_key)}
if (session_token != "") {session_token = unhex(session_token)}
if (last_joined_server != "") {last_joined_server = unhex(last_joined_server)}
if (server_id != "") {server_id = unhex(server_id)}
if (server_validation_token != "") {server_validation_token = unhex(server_validation_token)}
