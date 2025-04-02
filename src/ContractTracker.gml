Tracker = object_add();
object_set_persistent(Tracker, true);
object_set_depth(Tracker, -105000);

EVT_TRACKER_UPDATE_LIST = ev_user0;
EVT_TRACKER_INCREMENT = ev_user1;

tracker = instance_create(0, 0, Tracker);
with (tracker) {
    base_x = Contracts.tracker_xoffset;
    base_y = Contracts.tracker_yoffset;
    contracts = ds_list_create();
    
    // arg for EVT_TRACKER_INCREMENT
    contract = noone;
}
object_event_add(Tracker, ev_destroy, 0, '
    ds_list_destroy(contracts);
    ds_map_destroy(increments_by_contract);
');

object_event_add(Tracker, ev_other, EVT_TRACKER_UPDATE_LIST, '
    ds_list_clear(contracts);
    with (Contracts.Contract) {
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
    
    // TODO
');

object_event_add(Tracker, ev_draw, 0, '
    if (instance_exists(MenuController)) exit;
    if (!Contracts.display_tracker) exit;
    if (ds_list_size(contracts) == 0) exit;
    if (global.myself.object == -1) exit;
    
    var xoffset, yoffset, w, h;
    var alphaMod;
    
    xoffset = view_xview[0] + base_x;
    yoffset = view_yview[0] + base_y;
    
    alphaMod = 0.8;
    maxStringLen = 32;
    
    w = 160;
    h = 13;
    
    draw_sprite_ext(
        Contracts.img_tracker_bg, 0,
        xoffset - 4, yoffset - 20,
        1, 1,
        0, c_white, alphaMod);
    
    var i, contract, text_w_ratio;
    for (i = 0; i < ds_list_size(contracts); i+=1) {
        contract = ds_list_find_value(contracts, i);
        
        // draw_set_color(c_black);
        // draw_set_alpha(0.6 * alphaMod);
        // draw_rectangle(xoffset, yoffset, xoffset + w, yoffset + h -1, false);
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_alpha(1 * alphaMod);
        
        if (contract.completed) {
            draw_set_color(c_green);
        } else {
            draw_set_color(c_white);
        }
        
        text = contract.title;
        if (string_length(text) > maxStringLen) {
            text = string_copy(text, 1, maxStringLen);
        }
        text_w_ratio = min(1, w / string_width(text));
        
        draw_text_transformed(xoffset, yoffset, text, text_w_ratio, 1, 0);
        
        // progress
        if (contract.target_value > 0) {
            if (contract.value >= contract.target_value) {
                draw_set_color(c_green);
                draw_rectangle(
                    xoffset     , yoffset + 10,
                    xoffset + w , yoffset + 12,
                    false
                )
            } else {
                draw_healthbar(
                    xoffset     , yoffset + 11,
                    xoffset + w , yoffset + 12,
                    min(100, 100 * (contract.value + contract.value_increment)/contract.target_value),
                    c_black, c_aqua, c_aqua,
                    0, 0, 0
                )
                draw_healthbar(
                    xoffset     , yoffset + 11,
                    xoffset + w , yoffset + 12,
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