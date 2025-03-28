Notification = object_add();
object_set_persistent(Notification, true);
object_set_depth(Notification, -12000);

EVT_NOTIFY = ev_user0;

object_event_add(Notification, ev_create, 0, '
    message = "";
    display_time = 0;
    max_display_time = 120;
    sound = noone;
    
    displayed_messages = ds_list_create();
');

object_event_add(Notification, ev_destroy, 0, '
    ds_list_destroy(displayed_messages);
');

object_event_add(Notification, ev_step, ev_step_end, '
    display_time -= global.delta_factor;
    
    if (display_time == 10) {
        if ((Contracts.play_sounds) and (Contracts.snd_fadeout != -1)) {
            var xmid, ymid;
            xmid = view_xview[0] + view_wview[0]/2;
            ymid = view_yview[0] + view_hview[0]/2;
            playsound(xmid, ymid, Contracts.snd_fadeout);
        }
    }
    
    if (display_time == 0) {
        ds_list_clear(displayed_messages);
    }
');

object_event_add(Notification, ev_draw, 0, '
    if (display_time <= 0) {
        exit;
    }
    var xoffset, yoffset, w, h;
    var alphaMod;
    
    w = 360;
    h = 48;
    
    // TODO configurable position
    xoffset = view_xview[0] + 16;
    yoffset = view_yview[0] + 16;
    
    alphaMod = min(1, min(display_time / 10, max_display_time - (display_time/10)));
    
    draw_set_color(c_black);
    draw_set_alpha(0.6 * alphaMod);
    draw_rectangle(xoffset, yoffset, xoffset + w, yoffset + h, false);
    
    draw_sprite_ext(
        Contracts.img_notification_icon, 0,
        xoffset, yoffset,
        1, 1,
        0, c_white, alphaMod);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1 * alphaMod);
    draw_set_color(c_white);
    
    var i, displayed_message, text_w_ratio;
    for (i = 0; i < ds_list_size(displayed_messages); i+=1) {
        displayed_message = ds_list_find_value(displayed_messages, i);
        text_w_ratio = min(1, w / string_width(displayed_message));
        draw_text_transformed(xoffset + 48, yoffset + 12 * i, displayed_message, text_w_ratio, 1, 0);
    }
');

object_event_add(Notification, ev_other, EVT_NOTIFY, '
    var notified_this_frame;
    notified_this_frame = (display_time == max_display_time);
    
    display_time = max_display_time;
    ds_list_add(displayed_messages, message);
    
    if (ds_list_size(displayed_messages) > 4) {
        ds_list_delete(displayed_messages, 0);
    }
    
    // TODO disable if F12
    if (!notified_this_frame)
    if (Contracts.play_sounds)
    if (sound != -1)
    if (sound != noone) {
        var xmid, ymid;
        xmid = view_xview[0] + view_wview[0]/2;
        ymid = view_yview[0] + view_hview[0]/2;
        playsound(xmid, ymid, sound);
        sound = noone;
    }
');

notification = instance_create(0, 0, Notification);
with(notification) {
    message = "";
    display_time = 0;
    max_display_time = 120;
    sound = noone;
    displayed_messages = ds_list_create();
}
