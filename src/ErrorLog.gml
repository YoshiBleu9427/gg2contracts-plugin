ErrorLog = object_add();
object_set_persistent(ErrorLog, true);

EVT_ERROR_LOG = ev_user0;
EVT_ERROR_DUMP = ev_user1;

ERROR_FILE_PATH = working_directory + "/contracts_error.log"

object_event_add(ErrorLog, ev_create, 0, '
    log = "";
    logs = ds_list_create();
');

object_event_add(ErrorLog, ev_destroy, 0, '
    ds_list_destroy(logs);
');

object_event_add(ErrorLog, ev_other, EVT_ERROR_LOG, '
    if (global.isHost) {
        if (!instance_exists(NoticeO)) {
            with (instance_create(0, 0, NoticeO)) {
                notice = NOTICE_CUSTOM;  // TODO introduce new notice type if possible
                message = "[CONTRACTS ERROR] " + other.log;
            }
        }
    } else {
        show_error("[CONTRACTS ERROR] " + log, false);
    }
    
    ds_list_add(logs, log);
');

object_event_add(ErrorLog, ev_step, ev_step_begin, '
    if (ds_list_size(logs) > 0) {
        event_perform(ev_other, Contracts.EVT_ERROR_DUMP);
    }
'); 

object_event_add(ErrorLog, ev_other, EVT_ERROR_DUMP, '
    var i, fd, log_line, log_date;
    
    log_date = date_datetime_string(date_current_datetime());
    
    fd = file_text_open_append(Contracts.ERROR_FILE_PATH);
    
    for (i = 0; i < ds_list_size(logs); i+=1) {
        log_line = ds_list_find_value(logs, i);
        file_text_write_string(fd, "[" + log_date + "] " +log_line);
        file_text_writeln(fd);
    }
    
    file_text_close(fd);
    ds_list_clear(logs);
');

errorLog = instance_create(0, 0, ErrorLog);
with (errorLog) {
    // crazy that I even have to do that smh
    log = "";
    logs = ds_list_create();
}