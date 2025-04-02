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
CONTRACT_TYPE_DOMINATIONS = 8
CONTRACT_TYPE_CAPTURES = 9
CONTRACT_TYPE_STABS = 10
CONTRACT_TYPE_BURN_DURATION = 11
CONTRACT_TYPE_AUTOGUN_KILLS = 12
CONTRACT_TYPE_UBERED_KILLS = 13
CONTRACT_TYPE_DAMAGE_TAKEN = 14
CONTRACT_TYPE_KILL_STREAK = 15
CONTRACT_TYPE_HEAL_STREAK = 16
CONTRACT_TYPE_AUTOGUN_STREAK = 17
CONTRACT_TYPE_FLARE_KILLS = 18
CONTRACT_TYPE_GUN_KILLS = 19
CONTRACT_TYPE_UBERED_STREAK = 20
CONTRACT_TYPE_DEBUG = 69

var i;
for (i = 0; i < 256; i+=1) {
    CONTRACT_DESCRIPTION_BY_TYPE[i] = "<undefined>"
}
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_KILLS]             = "Kills"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_KILLS_ON_CLASS]    = "Kill {class}"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_KILLS_AS_CLASS]    = "Kills as {class}"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_HEALING]           = "Healing"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_UBERS]             = "Superburts"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_ROUNDS_PLAYED]     = "Rounds played"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_ROUNDS_WON]        = "Rounds won"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_DOMINATIONS]       = "Dominations"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_CAPTURES]          = "Captures"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_STABS]             = "Stabs"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_BURN_DURATION]     = "Burn duration"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_AUTOGUN_KILLS]     = "Autogun kills"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_UBERED_KILLS]      = "Kills while invicible"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_DAMAGE_TAKEN]      = "Tank damage"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_KILL_STREAK]       = "Kill streak"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_HEAL_STREAK]       = "Heals in one life"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_AUTOGUN_STREAK]    = "Single Autogun kills"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_FLARE_KILLS]       = "Flare kills"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_GUN_KILLS]         = "Gun kills"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_UBERED_STREAK]     = "Kill streak while invicible"
CONTRACT_TITLE_BY_TYPE[CONTRACT_TYPE_DEBUG]             = "DEBUG"

CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_KILLS]           = "Kill {value} enemies"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_KILLS_ON_CLASS]  = "Get {value} kills against {class}"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_KILLS_AS_CLASS]  = "Kill {value} enemies as {class}"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_HEALING]         = "Heal {value}k HP"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_UBERS]           = "As healer, activate {value} superbursts"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_ROUNDS_PLAYED]   = "Play {value} rounds"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_ROUNDS_WON]      = "Win {value} rounds"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_DOMINATIONS]     = "Dominate {value} enemies"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_CAPTURES]        = "Capture {value} objectives"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_STABS]           = "As Infiltrator, stab {value} enemies"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_BURN_DURATION]   = "Burn enemies for {value}0 seconds"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_AUTOGUN_KILLS]   = "Kill {value} enemies with your autogun"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_UBERED_KILLS]    = "Get {value} kills or assists while invicible"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_DAMAGE_TAKEN]    = "Receive {value}00 damage in one life"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_KILL_STREAK]     = "Kill {value} enemies in one life"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_HEAL_STREAK]     = "Heal {value}k HP in one life"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_AUTOGUN_STREAK]  = "Kill {value} enemies with the same Autogun"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_FLARE_KILLS]     = "Kill {value} enemies with flares"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_GUN_KILLS]       = "Kill {value} enemies with your primary gun"
CONTRACT_DESCRIPTION_BY_TYPE[CONTRACT_TYPE_UBERED_STREAK]   = "Get {value} kills or assists in a single invuln"
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
    old_increment = 0;
');

object_event_add(Contract, ev_destroy, 0, '
    ds_map_delete(Contracts.contracts_by_uuid, contract_id);
');

object_event_add(Contract, ev_step, ev_step_normal, '
    // update title and description
    title = Contracts.CONTRACT_TITLE_BY_TYPE[contract_type];
    title = string_replace(title, "{class}", classname(game_class));
    
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
    
    if (floor(value_increment) != floor(old_increment)) {
        if (owner != noone) {
            if (owner != global.myself) {
                var buf;
                buf = buffer_create();
                write_ubyte(buf, Contracts.NET_GAME_SRV_SYNC_INCREMENT);
                write_binstring(buf, contract_id);
                write_ubyte(buf, floor(value_increment));
                PluginPacketSendTo(Contracts.packetID, buf, owner);
                buffer_destroy(buf);
            } else {
                event_perform(ev_other, Contracts.EVT_CONTRACT_ON_INCREMENTED);
            }
        }
    }
    old_increment = value_increment;
');

object_event_add(Contract, ev_other, EVT_CONTRACT_ON_MAP_END, '
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
    
    if (global.isHost) {
        // invalidate streak contracts if not fulfilled
        switch (contract_type) {
            case Contracts.CONTRACT_TYPE_KILL_STREAK:
            case Contracts.CONTRACT_TYPE_HEAL_STREAK:
            case Contracts.CONTRACT_TYPE_AUTOGUN_STREAK:
            case Contracts.CONTRACT_TYPE_UBERED_STREAK:
            case Contracts.CONTRACT_TYPE_DAMAGE_TAKEN:
                if (value_increment < value) {
                    value_increment = 0;
                }
                break;
        }
        
        value_increment = floor(value_increment);
    } else {
        // as client, the server will never udpate ongoing contracts
        // so assume increment will apply
        value += value_increment;
        value_increment = 0;
    }
');

object_event_add(Contract, ev_other, EVT_CONTRACT_ON_INCREMENTED, '
    if (Contracts.notify_progress)
    if (value_increment > 0) {
        with (Contracts.notification) {
            message = other.title + ": +" + string(other.value_increment);
            sound = Contracts.snd_increase;
            event_perform(ev_other, Contracts.EVT_NOTIFY);
        }
    }
');

object_event_add(Contract, ev_other, EVT_CONTRACT_ON_COMPLETED, '
    value_increment = 0;
    value = target_value;
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
    }
    
    // reset
    value_increment = 0;
');
