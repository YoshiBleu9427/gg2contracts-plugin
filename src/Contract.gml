Contract = object_add();
object_set_persistent(Contract, true);



/**
 *  chain of events is:
 *      map ends
 *      EVT_CONTRACT_ON_MAP_END
 *      game server sends contract data to the backend
 *      EVT_CONTRACT_ON_DATA_SENT
 */
EVT_CONTRACT_ON_MAP_END = ev_user1;
EVT_CONTRACT_ON_DATA_SENT = ev_user2;




/**
 *  Contract types
 */
CONTRACT_TYPE_KILLS = 1
CONTRACT_TYPE_KILLS_ON_CLASS = 2
CONTRACT_TYPE_KILLS_AS_CLASS = 3
CONTRACT_TYPE_HEALING = 4
CONTRACT_TYPE_UBERS = 5
CONTRACT_TYPE_ROUNDS_PLAYED = 6
CONTRACT_TYPE_ROUNDS_WON = 7
CONTRACT_TYPE_DEBUG = 69

var i;
for (i = 0; i < 256; i+=1) {
    CONTRACT_DESCRIPTION_BY_TYPE[i] = "<undefined>"
}
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_KILLS]           = "Get {value} kills"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_KILLS_ON_CLASS]  = "Get {value} kills against {class}"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_KILLS_AS_CLASS]  = "Get {value} kills while playing as {class}"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_HEALING]         = "Heal {value} HP"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_UBERS]           = "As healer, activate {value} superbursts"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_ROUNDS_PLAYED]   = "Play {value} rounds"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_ROUNDS_WON]      = "Win {value} rounds"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_DEBUG]           = "DEBUG"




object_event_add(Contract, ev_create, 0, '
    contract_id = "";
    contract_type = 0;
    value = 0;
    target_value = 0;
    game_class = 0;
    points = 0;
    completed = false;
    
    owner = noone;
    owner_id = "";
    
    description = "";
    
    value_increment = 0; // how much the contract value changed since receiving it
');

object_event_add(Contract, ev_destroy, 0, '
    ds_map_delete(Contracts.contracts_by_uuid, contract_id);
');

object_event_add(Contract, ev_step, ev_step_normal, '
    // update description
    description = Contracts.CONTRACT_DESCRIPTION_BY_TYPE[contract_type];
    description = string_replace(description, "{value}", string(target_value));
    description = string_replace(description, "{class}", classname(game_class));
');



object_event_add(Contract, ev_other, EVT_CONTRACT_ON_MAP_END, '
    // consolidate stats
    switch (contract_type) {
        case Contracts.CONTRACT_TYPE_DEBUG:
            value_increment = 1;
            break;
        case Contracts.CONTRACT_TYPE_KILLS:
            value_increment = owner.stats[KILLS];
            break;
        case Contracts.CONTRACT_TYPE_HEALING:
            value_increment = ceil(owner.stats[HEALING] / 100);
            break;
        case Contracts.CONTRACT_TYPE_UBERS:
            value_increment = owner.stats[INVULNS];
            break;
        case Contracts.CONTRACT_TYPE_ROUNDS_PLAYED:
            value_increment = 1;
            break;
        case Contracts.CONTRACT_TYPE_ROUNDS_WON:
            if (global.winners == owner.team) {
                value_increment = 1
            }
            break;
    }
');

// TODO run this event on data sent AND backend replies positively
object_event_add(Contract, ev_other, EVT_CONTRACT_ON_DATA_SENT, '
    // if player left, no point in keeping the contract
    // now that the update was sent to the backend, it is safe to delete here
    if (owner == noone) {
        instance_destroy();
    } else {
        // apply the increment server-side, because backend wont send detailed updates
        value += value_increment;
        
        // TODO send plugin packet to owner so that the client may apply the value increment
    }
    
    // reset
    value_increment = 0;
');

// TODO event that syncs the value increment from server to client during a round
