ViewContractsMenu = object_add();
object_set_parent(ViewContractsMenu, OptionsController);
object_set_depth(ViewContractsMenu, -130000); 
object_event_add(ViewContractsMenu, ev_create, 0,'
    menu_create(48, 320, 196, 144, 32, 0, 96, 96 + 8);
    menu_setdimmed();
    menu_background(196, 24, 8, 12, 4);
    
    menu_addlink("Clear completed", "
        with (Contracts.Contract) {
            if (completed) {
                instance_destroy();
            }
        }
        
        ds_list_clear(contracts_list);
        var map_key, map_value;
        map_key = ds_map_find_first(Contracts.contracts_by_uuid);
        while (is_string(map_key)) {
            map_value = ds_map_find_value(Contracts.contracts_by_uuid, map_key);
            if (map_value.owner == global.myself) {
                ds_list_add(contracts_list, map_value);
            }
            map_key = ds_map_find_next(Contracts.contracts_by_uuid, map_key);
        }
        
        // TODO probably bad that I have to do this here idk
        with (Contracts.tracker) {
            event_perform(ev_other, Contracts.EVT_TRACKER_UPDATE_LIST);
        }
    ");
    
    if (Contracts.user_key != "") {
        url = "http://" + Contracts.WEBSITE_HOST + ":" + string(Contracts.WEBSITE_PORT) + "/me#" + hex(Contracts.user_key)
        menu_addlink("Update profile", "
            action_splash_web(url, 1);
        ");
    } else {
        sent_signup_form = false;
        next_menu_name = "Signing up...";
        menu_addlink("Sign up", "
            if (!sent_signup_form) {
                item_name[virtualitem] = next_menu_name
                with (instance_create(0, 0, Contracts.ClientBackendNetworker)) {
                    event_perform(ev_other, Contracts.EVT_SEND_HELLO);
                    on_hello_command = Contracts.EVT_SEND_CLT_NEW_ACCOUNT;
                    destroy_on_queue_empty = true;
                }
            }
        ");
    }
    
    menu_addedit_boolean("Tracker", "Contracts.display_tracker", "
        gg2_write_ini(Contracts.INI_SECTION, Contracts.INI_DISPLAY_TRACKER_KEY, argument0);
    ")
    
    menu_addedit_boolean("Notifications", "Contracts.display_notifications", "
        gg2_write_ini(Contracts.INI_SECTION, Contracts.INI_DISPLAY_NOTIFICATIONS_KEY, argument0);
    ")
    
    menu_addedit_boolean("Notif. sounds", "Contracts.play_sounds", "
        gg2_write_ini(Contracts.INI_SECTION, Contracts.INI_PLAY_SOUNDS_KEY, argument0);
    ")
    
    menu_addedit_boolean("Notify progress", "Contracts.notify_progress", "
        gg2_write_ini(Contracts.INI_SECTION, Contracts.INI_NOTIFY_PROGRESS_KEY, argument0);
    ")
    
    menu_addlink("", "");
    
    menu_addback("<<< Back", "
        instance_destroy();
        instance_create(0,0,InGameMenuController);
    ");
    
    contracts_list = ds_list_create();
    
    var map_key, map_value;
    map_key = ds_map_find_first(Contracts.contracts_by_uuid);
    while (is_string(map_key)) {
        map_value = ds_map_find_value(Contracts.contracts_by_uuid, map_key);
        if (map_value.owner == global.myself) {
            ds_list_add(contracts_list, map_value);
        }
        map_key = ds_map_find_next(Contracts.contracts_by_uuid, map_key);
    }
');

object_event_add(ViewContractsMenu, ev_destroy, 0,'
    ds_list_destroy(contracts_list);
');

object_event_add(ViewContractsMenu, ev_draw, 0, '
    event_inherited();
    var xoffset, yoffset, w, h;
    xoffset = view_xview[0] + 48 + 230;
    yoffset = view_yview[0] + 90;
    w = view_wview[0] - (48 + 230 + 48);
    //h = view_hview[0] - 220;
    
    nbOffset = 0;
    nbPerPage = 10;
    nbMax = ds_list_size(contracts_list);
    
    var rectX, rectY, rectW, rectH, rectIndex, rectXpad, rectYpad;
    var iconXOffset, nameXOffset, descXOffset, progressXOffset;
    var iconYOffset, nameYOffset, descYOffset, progressYOffset;
    var contract_index, contract_data;
    rectW = w - 32;
    rectH = 32;
    rectXpad = 18;
    rectYpad = 12;
    rectIndex = 0;
    iconXOffset = 0;
    nameXOffset = 36;
    descXOffset = 48;
    pointsXOffset = rectW - 180;
    progressXOffset = rectW - 40;
    iconYOffset = 0;
    nameYOffset = 4;
    descYOffset = 18;
    pointsYOffset = 4;
    progressYOffset = 4;
    
    h = nbPerPage*(rectH + rectYpad) + 2*rectYpad;
    draw_set_color(c_black);
    draw_set_alpha(0.4);
    draw_rectangle(xoffset, yoffset, xoffset + w, yoffset + h, false);
    
    for (contract_index = nbOffset * nbPerPage; contract_index < min(nbMax, (nbOffset+1) * nbPerPage); contract_index += 1) {
        contract_data = ds_list_find_value(contracts_list, contract_index);
        
        // bg rect
        rectX = xoffset + rectXpad;
        rectY = yoffset + rectYpad + rectIndex*(rectH + rectYpad);
        draw_set_color(c_black);
        draw_set_alpha(0.4);
        draw_rectangle(rectX, rectY, rectX + rectW, rectY + rectH, false);
        
        // icon
        var completion_color, completable_by_any_class, class_icon;
        
        completable_by_any_class = true;
        switch (contract_data.contract_type) {
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
        
        if (contract_data.completed) {
            completion_color = c_green;
        } else if (completable_by_any_class or (contract_data.game_class == global.myself.class)) {
            completion_color = c_white;
        } else {
            completion_color = c_gray;
        }
        
        if (completable_by_any_class) {
            draw_sprite_ext(
                Contracts.img_contract_icon, 0,
                rectX + 4, rectY + 4,
                1, 1,
                0, completion_color, 1);
        } else {
            draw_sprite_ext(
                MedAlert, 2 + contract_data.game_class,
                rectX + 16, rectY + 16,
                1, 1,
                0, completion_color, 1);
        }
        
        // title, description, points
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_alpha(1);
        
        draw_set_color(c_white);
        draw_text(rectX + nameXOffset, rectY + nameYOffset, contract_data.title);
        if (contract_data.completed) {
            draw_set_color(c_green);
        } else {
            draw_set_color(c_orange);
        }
        draw_text(rectX + descXOffset, rectY + descYOffset, contract_data.description);
        
        draw_set_color(c_gray);
        draw_text(rectX + pointsXOffset, rectY + pointsYOffset, "[+" + string(contract_data.points) + " pts]");
        
        // progress
        draw_set_halign(fa_right);
        if (contract_data.target_value > 0) {
            if (contract_data.value >= contract_data.target_value) {
                draw_set_color(c_green);
                draw_rectangle(
                    rectX + progressXOffset + 8 , rectY + progressYOffset + 1,
                    rectX + progressXOffset + 32, rectY + progressYOffset + 7,
                    false
                )
            } else {
                draw_healthbar(
                    rectX + progressXOffset + 8 , rectY + progressYOffset + 1,
                    rectX + progressXOffset + 32, rectY + progressYOffset + 7,
                    min(100, 100 * (contract_data.value + contract_data.value_increment)/contract_data.target_value),
                    c_black, c_teal, c_teal,
                    0, 1, 0
                )
                draw_healthbar(
                    rectX + progressXOffset + 8 , rectY + progressYOffset + 1,
                    rectX + progressXOffset + 32, rectY + progressYOffset + 7,
                    100 * contract_data.value/contract_data.target_value,
                    c_black, c_gray, c_white,
                    0, 0, 0
                )
            }
        }
        draw_text(rectX + progressXOffset, rectY + progressYOffset, string(contract_data.value) + "/" + string(contract_data.target_value));
        if (contract_data.value_increment > 0) {
            draw_set_color(c_teal);
            draw_text(rectX + progressXOffset, rectY + descYOffset, "+" + string(contract_data.value_increment));
        }
        
        rectIndex += 1;
    }
    
    // Display points
    xoffset = view_xview[0] + 48;
    yoffset = view_yview[0] + 240;
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_color(c_gray);
    draw_text(xoffset, yoffset, "Points earned#this session:");
    draw_set_halign(fa_right);
    draw_set_color(c_white);
    draw_text_transformed(xoffset + 190, yoffset, string(Contracts.session_points), 2, 2, 0);
');

object_event_add(InGameMenuController, ev_create, 0, '
    menu_addlink("Contracts", "
        instance_destroy();
        instance_create(0,0,Contracts.ViewContractsMenu);
    ");
');