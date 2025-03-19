MainMenu = object_add();
object_set_parent(MainMenu, OptionsController);
object_set_depth(MainMenu, -130000); 
object_event_add(MainMenu, ev_create, 0,'

    menu_create(60, 54, 98, 1, 32, 0, 96, 96 + 8);
    menu_setdimmed();
    menu_background(96, 24, 8, 12, 4);
    
    menu_addback("<<< Back", "
        instance_destroy();
        if(room == Menu)
            instance_create(0,0,MainMenuController);
        else
            instance_create(0,0,InGameMenuController);
    ");
    
    if (global.isHost) {
        menu_addlink("View all Contracts", "
            // TODO hehe
            instance_destroy();
            instance_create(0,0,Contracts.ViewContractsMenu);
        ");
    }
    
    menu_addlink("My Contracts", "
        instance_destroy();
        instance_create(0,0,Contracts.ViewMyContractsMenu);
    ");
');


ViewContractsMenu = object_add();
object_set_parent(ViewContractsMenu, OptionsController);
object_set_depth(ViewContractsMenu, -130000); 
object_event_add(ViewContractsMenu, ev_create, 0,'
    menu_create(60, 54, 98, 1, 32, 0, 96, 96 + 8);
    menu_setdimmed();
    menu_background(96, 24, 8, 12, 4);
    
    menu_addback("<<< Back", "
        instance_destroy();
        if(room == Menu)
            instance_create(0,0,MainMenuController);
        else
            instance_create(0,0,InGameMenuController);
    ");
    
    contracts_list = ds_list_create();
    
    var firsttt, val;
    firsttt = ds_map_find_first(Contracts.contracts_by_uuid);
    while (is_string(firsttt)) {
        val = ds_map_find_value(Contracts.contracts_by_uuid, firsttt);
        ds_list_add(contracts_list, val);
        map_key = ds_map_find_next(Contracts.contracts_by_uuid, map_key);
    }
');


ViewMyContractsMenu = object_add();
object_set_parent(ViewMyContractsMenu, ViewContractsMenu);
object_set_depth(ViewMyContractsMenu, -130000); 
object_event_add(ViewMyContractsMenu, ev_create, 0,'
    menu_create(60, 54, 98, 1, 32, 0, 96, 96 + 8);
    menu_setdimmed();
    menu_background(96, 24, 8, 12, 4);
    
    menu_addback("<<< Back", "
        instance_destroy();
        if(room == Menu)
            instance_create(0,0,MainMenuController);
        else
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
    xoffset = view_xview[0] + 32;
    yoffset = view_yview[0] + 84;
    w = view_wview[0] - 60;
    //h = view_hview[0] - 220;
    
    nbOffset = 0;
    nbPerPage = 10;
    nbMax = ds_list_size(contracts_list);
    
    var rectX, rectY, rectW, rectH, rectIndex, rectXpad, rectYpad;
    var iconXOffset, nameXOffset, descXOffset, progressXOffset, progressTrackIconXOffset;
    var iconYOffset, nameYOffset, descYOffset, progressYOffset, progressTrackIconYOffset;
    var progressTrackIconWidth;
    var contract_index, contract_data;
    rectW = w - 32;
    rectH = 32;
    rectXpad = 18;
    rectYpad = 12;
    rectIndex = 0;
    iconXOffset = 0;
    nameXOffset = 48;
    descXOffset = 36;
    progressXOffset = rectW - 40;
    progressTrackIconXOffset = 38;
    iconYOffset = 0;
    nameYOffset = 4;
    descYOffset = 18;
    progressYOffset = 4;
    progressTrackIconYOffset = 6;
    progressTrackIconWidth = 5;
    
    h = nbPerPage*(rectH + rectYpad) + 2*rectYpad;
    draw_set_color(c_black);
    draw_set_alpha(0.4);
    draw_rectangle(xoffset, yoffset, xoffset + w, yoffset + h, false);
    
    for (contract_index = nbOffset * nbPerPage; contract_index < min(nbMax, (nbOffset+1) * nbPerPage); contract_index += 1) {
        contract_data = ds_list_find_value(contracts_list, contract_index);
        
        // achievement bg rect
        rectX = xoffset + rectXpad;
        rectY = yoffset + rectYpad + rectIndex*(rectH + rectYpad);
        draw_set_color(c_black);
        draw_set_alpha(0.4);
        draw_rectangle(rectX, rectY, rectX + rectW, rectY + rectH, false);
        
        // name and desc
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_alpha(1);
        if (contract_data.completed) {
            draw_set_color(c_green);
        } else {
            draw_set_color(c_orange);
        }
        draw_text(rectX + nameXOffset, rectY + nameYOffset, contract_data.description);
        
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
                    100 * contract_data.value/contract_data.target_value,
                    c_black, c_gray, c_white,
                    0, 1, 0
                )
            }
        }
        draw_text(rectX + progressXOffset, rectY + progressYOffset, string(contract_data.value) + "/" + string(contract_data.target_value));
        
        // tracking
        if (contract_data.completed) {
            draw_set_color(c_teal);
            draw_rectangle(
                rectX + progressTrackIconXOffset,                           rectY + progressTrackIconYOffset,
                rectX + progressTrackIconXOffset + progressTrackIconWidth,  rectY + progressTrackIconYOffset + progressTrackIconWidth,
                false
            )
        }
        
        rectIndex += 1;
    }
');

object_event_add(InGameMenuController, ev_create, 0, '
    menu_addlink("Contracts", "
        instance_destroy();
        instance_create(0,0,Contracts.MainMenu);
    ");
');