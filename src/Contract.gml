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
EVT_CONTRACT_ON_INCREMENTED = ev_user3;
EVT_CONTRACT_ON_COMPLETED = ev_user4;
EVT_CONTRACT_ON_RESTORED = ev_user5;



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
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_KILLS]           = "Kills"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_KILLS_ON_CLASS]  = "Kill {class}"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_KILLS_AS_CLASS]  = "Kills as {class}"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_HEALING]         = "Healing"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_UBERS]           = "Superburts"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_ROUNDS_PLAYED]   = "Rounds played"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_ROUNDS_WON]      = "Rounds won"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_DEBUG]           = "DEBUG"

CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_KILLS]           = "Get {value} kills"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_KILLS_ON_CLASS]  = "Get {value} kills against {class}"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_KILLS_AS_CLASS]  = "Get {value} kills while playing as {class}"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_HEALING]         = "Heal {value}00 HP"
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
    
    title = "";
    description = "";
    
    value_increment = 0; // how much the contract value changed since receiving it
');

object_event_add(Contract, ev_destroy, 0, '
    ds_map_delete(Contracts.contracts_by_uuid, contract_id);
');

object_event_add(Contract, ev_step, ev_step_normal, '
    // update title and description
    title = Contracts.CONTRACT_TITLE_BY_TYPE[contract_type];
    title = string_replace(description, "{class}", classname(game_class));
    
    description = Contracts.CONTRACT_DESCRIPTION_BY_TYPE[contract_type];
    description = string_replace(description, "{value}", string(target_value));
    description = string_replace(description, "{class}", classname(game_class));
');


object_event_add(Contract, ev_step, ev_step_normal, '
    // keep updating stats-based contracts, just for display
    if (!global.isHost) {
        exit;
    }
    if (global.winners != -1) {
        // nothing to sync after round ends
        exit;
    }
    if (owner == noone) {
        exit;
    }
    
    // TODO stats-based things desync when client disconnects and reconnects,
    // because stats are then reset to 0.
    // Keep a preserved_increment for the server to keep track of,
    // on player destroy: contract.preserved_increment = value_increment,
    // and set value_increment = preserved_increment + <stat>
    // Also, Contracts probably shouldnt be objects. I cant imagine its good for performance
    
    var old_increment;
    old_increment = value_increment;
    
    // consolidate stats
    switch (contract_type) {
        case Contracts.CONTRACT_TYPE_KILLS:
            value_increment = owner.stats[KILLS];
            break;
        case Contracts.CONTRACT_TYPE_HEALING:
            value_increment = ceil(owner.stats[HEALING] / 100);
            break;
        case Contracts.CONTRACT_TYPE_UBERS:
            value_increment = owner.stats[INVULNS];
            break;
    }
    
    if (value_increment != old_increment) {
        if (owner != noone) {
            if (owner != global.myself) {
                var buf;
                buf = buffer_create();
                write_ubyte(buf, Contracts.NET_GAME_SRV_SYNC_INCREMENT);
                write_binstring(buf, contract_id);
                write_ubyte(buf, value_increment);
                PluginPacketSendTo(Contracts.packetID, buf, owner);
                buffer_destroy(buf);
            } else {
                event_perform(ev_other, Contracts.EVT_CONTRACT_ON_INCREMENTED);
            }
        }
    }
');

object_event_add(Contract, ev_other, EVT_CONTRACT_ON_MAP_END, '
    // round stats stuff
    if (!global.isHost) {
        exit;
    }
    
    // consolidate stats
    switch (contract_type) {
        case Contracts.CONTRACT_TYPE_DEBUG:
            value_increment = 1;
            break;
        case Contracts.CONTRACT_TYPE_ROUNDS_PLAYED:
            value_increment = 1;
            break;
        case Contracts.CONTRACT_TYPE_ROUNDS_WON:
            if (owner != noone) {
                if (global.winners == owner.team) {
                    value_increment = 1
                }
            }
            break;
    }
');

object_event_add(Contract, ev_other, EVT_CONTRACT_ON_RESTORED, '
    with (Contracts.notification) {
        message = other.title + ": +" + string(other.value_increment);
        sound = Contracts.snd_beep;
        event_perform(ev_other, Contracts.EVT_NOTIFY);
    }
');

object_event_add(Contract, ev_other, EVT_CONTRACT_ON_INCREMENTED, '
    with (Contracts.notification) {
        message = other.title + ": +" + string(other.value_increment);
        sound = Contracts.snd_increase;
        event_perform(ev_other, Contracts.EVT_NOTIFY);
    }
');

object_event_add(Contract, ev_other, EVT_CONTRACT_ON_COMPLETED, '
    with (Contracts.notification) {
        message = "Completed contract! " + other.description;
        sound = Contracts.snd_success;
        event_perform(ev_other, Contracts.EVT_NOTIFY);
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
