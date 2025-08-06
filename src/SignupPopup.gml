SignupPopup = object_add();
object_set_depth(SignupPopup, -105000);
object_set_sprite(SignupPopup, img_paula_icon);

EVT_SIGNUP_SHOW = ev_user0;


object_event_add(SignupPopup, ev_create, 0, '
');

object_event_add(SignupPopup, ev_step, ev_step_end, '
    if (global.myself == -1) {
        instance_destroy();
        exit;
    }
    
    visible = (global.myself.object != -1);
    x = view_xview[0] + 48;
    y = view_yview[0] + 80;
    
    y += 8 * sin(2 * 3.14 * (current_time mod 3000) / 3000) - 4;
');

object_event_add(SignupPopup, ev_other, EVT_SIGNUP_SHOW, '
    var prompt;
    prompt = "Welcome to Contracts!##Play the game. Complete missions. Earn points!#Score a lot and earn prizes!##Would you like to sign up?";
    
    switch (show_message_ext(prompt, "Yes", "Not now", "Never")) {
        case 1:
            // Yes
            with (instance_create(0, 0, Contracts.ClientBackendNetworker)) {
                event_perform(ev_other, Contracts.EVT_SEND_HELLO);
                on_hello_command = Contracts.EVT_SEND_CLT_NEW_ACCOUNT;
                destroy_on_queue_empty = true;
            }
            break;
        case 2:
            // Not now
            break;
        case 3:
            Contracts.disable_signup_popup = true;
            gg2_write_ini(Contracts.INI_SECTION, Contracts.INI_NO_SIGNUP_POPUP_KEY, true);
            show_message("If you change your mind, you can always#sign up later in the Plugins Options Menu.");
            break;
    }
');

object_event_add(SignupPopup, ev_mouse, ev_left_button, '
    event_perform(ev_other, Contracts.EVT_SIGNUP_SHOW);
    instance_destroy();
');