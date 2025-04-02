INI_SECTION = "Contracts";
INI_USER_KEY_KEY = "user_key";
INI_SERVER_ID_KEY = "server_id";
INI_SERVER_VALID_TOKEN_KEY = "server_validation_token";
INI_PLAY_SOUNDS_KEY = "play_sounds";
INI_NOTIFY_PROGRESS_KEY = "notify_progress";
INI_DISPLAY_NOTIFICATIONS_KEY = "display_notifications";
INI_NOTIFICATION_XOFFSET_KEY = "notification_xoffset";
INI_NOTIFICATION_YOFFSET_KEY = "notification_yoffset";
INI_DISPLAY_TRACKER_KEY = "display_tracker";
INI_TRACKER_XOFFSET_KEY = "tracker_xoffset";
INI_TRACKER_YOFFSET_KEY = "tracker_yoffset";



ini_open("gg2.ini");
user_key = ini_read_string(INI_SECTION, INI_USER_KEY_KEY, "");
server_id = ini_read_string(INI_SECTION, INI_SERVER_ID_KEY, "");
server_validation_token = ini_read_string(INI_SECTION, INI_SERVER_VALID_TOKEN_KEY, "");
play_sounds = ini_read_real(INI_SECTION, INI_PLAY_SOUNDS_KEY, true);
notify_progress = ini_read_real(INI_SECTION, INI_NOTIFY_PROGRESS_KEY, true);
display_notifications = ini_read_real(INI_SECTION, INI_DISPLAY_NOTIFICATIONS_KEY, true);
notification_xoffset = ini_read_real(INI_SECTION, INI_NOTIFICATION_XOFFSET_KEY, 8);
notification_yoffset = ini_read_real(INI_SECTION, INI_NOTIFICATION_YOFFSET_KEY, 8);
display_tracker = ini_read_real(INI_SECTION, INI_DISPLAY_TRACKER_KEY, true);
tracker_xoffset = ini_read_real(INI_SECTION, INI_TRACKER_XOFFSET_KEY, 8);
tracker_yoffset = ini_read_real(INI_SECTION, INI_TRACKER_YOFFSET_KEY, 60);
ini_close();

if (user_key != "") {user_key = unhex(user_key)}
if (server_id != "") {server_id = unhex(server_id)}
if (server_validation_token != "") {server_validation_token = unhex(server_validation_token)}

gg2_write_ini(INI_SECTION, INI_PLAY_SOUNDS_KEY, play_sounds);
gg2_write_ini(INI_SECTION, INI_NOTIFY_PROGRESS_KEY, notify_progress);
gg2_write_ini(INI_SECTION, INI_DISPLAY_NOTIFICATIONS_KEY, display_notifications);
gg2_write_ini(INI_SECTION, INI_NOTIFICATION_XOFFSET_KEY, notification_xoffset);
gg2_write_ini(INI_SECTION, INI_NOTIFICATION_YOFFSET_KEY, notification_yoffset);
gg2_write_ini(INI_SECTION, INI_DISPLAY_TRACKER_KEY, display_tracker);
gg2_write_ini(INI_SECTION, INI_TRACKER_XOFFSET_KEY, tracker_xoffset);
gg2_write_ini(INI_SECTION, INI_TRACKER_YOFFSET_KEY, tracker_yoffset);