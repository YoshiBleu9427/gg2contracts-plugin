Tracker = object_add();
object_set_persistent(Tracker, true);
object_set_depth(Tracker, -105000);

ALARM_TRACKER_NEXT_TEXT_NOTIFICATION    = 0;
ALARM_TRACKER_CLEAR_INCREMENT_DISPLAY   = 1;

EVT_TRACKER_UPDATE_LIST = ev_user0;
EVT_TRACKER_INCREMENT   = ev_user1;
EVT_TRACKER_NOTIFY      = ev_user2;
EVT_TRACKER_PLAY_SOUND  = ev_user3;

// times in 30fps frames
TRACKER_NOTIFICATION_DISPLAY_TIME       = 30 * 4;
TRACKER_NOTIFICATION_TRANSITION_TIME    = 30 * 0.5;
TRACKER_INCREMENT_DISPLAY_TIME          = 30 * 1.5;
TRACKER_INCREMENT_BLINK_TIME            = 30 * 0.5;

tracker = instance_create(0, 0, Tracker);
with (tracker) {
    base_x = Contracts.tracker_xoffset;
    base_y = Contracts.tracker_yoffset;
    contracts = ds_list_create();
    
    recently_incremented = ds_list_create();
    
    notifications_text = ds_list_create();
    notifications_sound = ds_list_create();
    
    // arg for EVT_TRACKER_INCREMENT
    contract = noone;
    
    // args for EVT_TRACKER_NOTIFY
    message = noone;
    sound = noone;
}
object_event_add(Tracker, ev_destroy, 0, '
    ds_list_destroy(contracts);
    ds_list_destroy(recently_incremented);
    ds_list_destroy(notifications_text);
    ds_list_destroy(notifications_sound);
');

object_event_add(Tracker, ev_alarm, ALARM_TRACKER_NEXT_TEXT_NOTIFICATION, '
    ds_list_delete(notifications_text, 0);
    ds_list_delete(notifications_sound, 0);
    
    if (ds_list_size(notifications_text) > 0) {
        alarm[Contracts.ALARM_TRACKER_NEXT_TEXT_NOTIFICATION] = Contracts.TRACKER_NOTIFICATION_DISPLAY_TIME / global.delta_factor;
    }
    
    if (ds_list_size(notifications_sound) > 0) {
        sound = ds_list_find_value(notifications_sound, 0);
    } else {
        sound = Contracts.snd_fadeout;
    }
    event_perform(ev_other, Contracts.EVT_TRACKER_PLAY_SOUND);
');

object_event_add(Tracker, ev_alarm, ALARM_TRACKER_CLEAR_INCREMENT_DISPLAY, '
    ds_list_clear(recently_incremented);
');

object_event_add(Tracker, ev_other, EVT_TRACKER_UPDATE_LIST, '
    ds_list_clear(contracts);
    with (Contracts.Contract) {
        if (!completed)
        if (owner == global.myself) {
        
            // TODO duplicated from menus.gml; find way to refactor
            var completable_by_any_class;
            completable_by_any_class = true;
            switch (contract_type) {
                case Contracts.CONTRACT_TYPE_KILLS_AS_CLASS:
                case Contracts.CONTRACT_TYPE_HEALING:
                case Contracts.CONTRACT_TYPE_UBERS:
                case Contracts.CONTRACT_TYPE_STABS:
                case Contracts.CONTRACT_TYPE_BURN_DURATION:
                case Contracts.CONTRACT_TYPE_AUTOGUN_KILLS:
                case Contracts.CONTRACT_TYPE_HEAL_STREAK:
                case Contracts.CONTRACT_TYPE_AUTOGUN_STREAK:
                case Contracts.CONTRACT_TYPE_FLARE_KILLS:
                case Contracts.CONTRACT_TYPE_GUN_KILLS:
                    completable_by_any_class = false;
                    break;
            }
            
            if (completable_by_any_class or (game_class == global.myself.class)) {
                ds_list_add(other.contracts, id);
            }
        }
    }
');

// args: contract
object_event_add(Tracker, ev_other, EVT_TRACKER_INCREMENT, '
    if (ds_list_find_index(contracts, contract) < 0) {
        exit;
    }
    
    if (ds_list_find_index(recently_incremented, contract) < 0) {
        ds_list_add(recently_incremented, contract);
    }
    
    alarm[Contracts.ALARM_TRACKER_CLEAR_INCREMENT_DISPLAY] = Contracts.TRACKER_INCREMENT_DISPLAY_TIME / global.delta_factor;
');

// args: message, sound
object_event_add(Tracker, ev_other, EVT_TRACKER_NOTIFY, '
    var is_notification_running, notified_this_frame;
    notified_this_frame = (alarm[Contracts.ALARM_TRACKER_NEXT_TEXT_NOTIFICATION] = Contracts.TRACKER_NOTIFICATION_DISPLAY_TIME / global.delta_factor);
    is_notification_running = (alarm[Contracts.ALARM_TRACKER_NEXT_TEXT_NOTIFICATION] > 0);
    
    ds_list_add(notifications_text, message);
    ds_list_add(notifications_sound, sound);
    
    if (!is_notification_running) {
        alarm[Contracts.ALARM_TRACKER_NEXT_TEXT_NOTIFICATION] = Contracts.TRACKER_NOTIFICATION_DISPLAY_TIME / global.delta_factor;
        if (!notified_this_frame) {
            event_perform(ev_other, Contracts.EVT_TRACKER_PLAY_SOUND);
        }
    } else {
        // TODO review
        if (ds_list_size(notifications_text) > 3) {
            alarm[Contracts.ALARM_TRACKER_NEXT_TEXT_NOTIFICATION] = max(1, ceil(alarm[Contracts.ALARM_TRACKER_NEXT_TEXT_NOTIFICATION] / 2));
        }
    }
    
    sound = noone;
    message = "";
');

object_event_add(Tracker, ev_other, EVT_TRACKER_PLAY_SOUND, '
    if (!AudioControl.allAudioMuted)
    if (Contracts.play_sounds)
    if (sound != -1)
    if (sound != noone) {
        var xmid, ymid;
        xmid = view_xview[0] + view_wview[0]/2;
        ymid = view_yview[0] + view_hview[0]/2;
        playsound(xmid, ymid, sound);
    }
');


object_event_add(Tracker, ev_draw, 0, '
    if (instance_exists(MenuController)) exit;
    if (ds_list_size(contracts) == 0) exit;
    // if (global.myself.object == -1) exit; // TODO option to hide when dead
    
    var xoffset, yoffset, w, h;
    var alphaMod;
    var text_w_ratio, text;
    
    xoffset = view_xview[0] + base_x;
    yoffset = view_yview[0] + base_y;
    
    alphaMod = 0.8;
    maxStringLen = 20;
    
    w = 160;
    h = 13;
        
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_alpha(alphaMod);
    
    if (Contracts.display_notifications)
    if (ds_list_size(notifications_text) > 0) {
        var text_notification;
        text_notification = ds_list_find_value(notifications_text, 0);
        
        draw_sprite_ext(
            Contracts.img_tracker_notif, 0,
            xoffset + 14, yoffset - 23,
            1, 1,
            0, c_white, alphaMod);
        
        if (string_length(text_notification) > maxStringLen) {
            var str_start, time_ratio;
            time_ratio = alarm[Contracts.ALARM_TRACKER_NEXT_TEXT_NOTIFICATION] / (Contracts.TRACKER_NOTIFICATION_DISPLAY_TIME/global.delta_factor);
            str_start = 1 + round((1-time_ratio) * (string_length(text_notification) - maxStringLen));
            text_notification = string_copy(text_notification, str_start, maxStringLen);
        }
        text_w_ratio = min(1, 146 / string_width(text_notification));
        
        draw_set_color(c_white);
        draw_text_transformed(xoffset + 84, yoffset - 16, text_notification, text_w_ratio, 1, 0);
    }
    
    if (!Contracts.display_tracker) exit;
    
    draw_set_halign(fa_left);
    maxStringLen = 32;
    
    draw_sprite_ext(
        Contracts.img_tracker_bg, 0,
        xoffset - 4, yoffset - 20,
        1, 1,
        0, c_white, alphaMod);
    
    var i, contract, is_recently_incremented;
    for (i = 0; i < ds_list_size(contracts); i+=1) {
        contract = ds_list_find_value(contracts, i);
        
        is_recently_incremented = (ds_list_find_index(recently_incremented, contract) >= 0);
        
        if (is_recently_incremented) {
            draw_set_color(c_aqua);
        } else if (contract.completed) {
            draw_set_color(c_lime);
        } else {
            draw_set_color(c_white);
        }
        
        text = contract.title;
        if (string_length(text) > maxStringLen) {
            text = string_copy(text, 1, maxStringLen);
        }
        if (is_recently_incremented) {
            text += " +" + string(contract.value_increment);
        }
        text_w_ratio = min(1, w / string_width(text));
        
        draw_text_transformed(xoffset, yoffset, text, text_w_ratio, 1, 0);
        
        // progress
        if (contract.target_value > 0) {
            if (contract.value >= contract.target_value) {
                draw_set_color(c_lime);
                draw_rectangle(
                    xoffset     , yoffset + 10,
                    xoffset + w , yoffset + 11,
                    false
                )
            } else {
                draw_healthbar(
                    xoffset     , yoffset + 10,
                    xoffset + w , yoffset + 11,
                    min(100, 100 * (contract.value + contract.value_increment)/contract.target_value),
                    c_black, c_aqua, c_aqua,
                    0, 0, 0
                )
                draw_healthbar(
                    xoffset     , yoffset + 10,
                    xoffset + w , yoffset + 11,
                    100 * contract.value/contract.target_value,
                    c_black, c_white, c_white,
                    0, 0, 0
                )
            }
        }
        
        yoffset += h;
    }
');


// Hook
object_event_add(Character, ev_create, 0, '
    if (player == global.myself)
    with (Contracts.tracker) {
        event_perform(ev_other, Contracts.EVT_TRACKER_UPDATE_LIST);
    }
');