/**
 *  Hooks for more complex contract rules
 */
object_event_add(Character, ev_create, 0, '
    contracts__damage_taken = 0;
');
with (Character) {
    contracts__damage_taken = 0;
}

object_event_add(Character, ev_destroy, 0, '
    if (global.isHost)
    if (global.winners == -1)
	if (lastDamageDealer != player)
    {
        with (Contracts.Contract) {
            if (!completed) {
                if (owner == other.lastDamageDealer) {
                    // if owner kills
                    
                    switch (contract_type) {
                        case Contracts.CONTRACT_TYPE_KILLS:
                        case Contracts.CONTRACT_TYPE_KILL_STREAK:
                            value_increment += 1;
                            break;
                            
                        case Contracts.CONTRACT_TYPE_STABS:
                            if (other.lastDamageSource == DAMAGE_SOURCE_KNIFE) or (other.lastDamageSource == DAMAGE_SOURCE_BACKSTAB) {
                                value_increment += 1;
                            }
                            break;
                            
                        case Contracts.CONTRACT_TYPE_GUN_KILLS:
                            if (other.lastDamageSource == DAMAGE_SOURCE_SHOTGUN) or (other.lastDamageSource == DAMAGE_SOURCE_REVOLVER) {
                                value_increment += 1;
                            }
                            break;
                            
                        case Contracts.CONTRACT_TYPE_AUTOGUN_KILLS:
                        case Contracts.CONTRACT_TYPE_AUTOGUN_STREAK:
                            if (other.lastDamageSource == DAMAGE_SOURCE_SENTRYTURRET) {
                                value_increment += 1;
                            }
                            break;
                            
                        case Contracts.CONTRACT_TYPE_FLARE_KILLS:
                            if (other.lastDamageSource == DAMAGE_SOURCE_FLARE) or (other.lastDamageSource == DAMAGE_SOURCE_REFLECTED_FLARE) {
                                value_increment += 1;
                            }
                            break;
                            
                        case Contracts.CONTRACT_TYPE_UBERED_KILLS:
                        case Contracts.CONTRACT_TYPE_UBERED_STREAK:
                            if (owner.object.ubered) {
                                value_increment += 1;
                            }
                            break;
                            
                        case Contracts.CONTRACT_TYPE_KILLS_ON_CLASS:
                            if (other.player.class == game_class) {
                                value_increment += 1;
                            }
                            break;
                            
                        case Contracts.CONTRACT_TYPE_KILLS_AS_CLASS:
                            if (owner.class == game_class) {
                                value_increment += 1;
                            }
                            break;
                    }
                } else if (owner == other.secondToLastDamageDealer) {
                    // if owner assists
                    
                    switch (contract_type) {
                        case Contracts.CONTRACT_TYPE_UBERED_KILLS:
                        case Contracts.CONTRACT_TYPE_UBERED_STREAK:
                            if (owner.object.ubered) {
                                value_increment += 1;
                            }
                            break;
                    }
                } else if (owner == other.player) {
                    // if owner died
                    switch (contract_type) {
                        case Contracts.CONTRACT_TYPE_KILL_STREAK:
                        case Contracts.CONTRACT_TYPE_UBERED_STREAK:
                            value_increment = 0;
                            break;
                    }
                }
            }
        }
	}
');

object_event_add(Sentry, ev_destroy, 0, '
    if (global.isHost)
    if (global.winners == -1)
	if (lastDamageDealer != noone)
    {
        with (Contracts.Contract) {
            if (!completed) {
                if (owner == other.ownerPlayer) {
                    // if owner died
                    switch (contract_type) {
                        case Contracts.CONTRACT_TYPE_AUTOGUN_STREAK:
                            value_increment = 0;
                            break;
                    }
                }
            }
        }
	}
');

object_event_add(Contract, ev_create, 0, '
    prev_dom_count = 0;
    burn_duration = 0;
');
with (Contract) {
    prev_dom_count = 0;
    burn_duration = 0;
}
object_event_add(Contract, ev_step, ev_step_end, '
    if (!global.isHost) exit;
    if (owner == noone) exit;
    
    switch (contract_type) {
        case Contracts.CONTRACT_TYPE_DOMINATIONS:
            var dom_count;
            dom_count = domination_kills_getDomCount(owner);
            if (dom_count > prev_dom_count) {
                value_increment += dom_count - prev_dom_count;
            }
            prev_dom_count = dom_count;
            break;
        case Contracts.CONTRACT_TYPE_CAPTURES:
            // TODO
            break;
        case Contracts.CONTRACT_TYPE_DAMAGE_TAKEN:
            if (owner.object != -1) {
                value_increment = floor(owner.object.contracts__damage_taken / 100);
            } else {
                value_increment = 0;
            }
            break;
        case Contracts.CONTRACT_TYPE_BURN_DURATION:
            if (burn_duration >= 10) {
                var mod;
                mod = floor(burn_duration / 10);
                value_increment += mod;
                burn_duration -= mod * 10;
            }
            break;
    }
    
');

// dealDamage( sourcePlayer, damagedObject, damageDealt )
global.dealDamageFunction += '
    if (global.isHost) {
        // CONTRACT_TYPE_DAMAGE_TAKEN
        with (argument1) {
            if (variable_local_exists("contracts__damage_taken"){
                contracts__damage_taken += argument2;
            }
        }
        
        // CONTRACT_TYPE_BURN_DURATION
        if (argument1.lastDamageSource == DAMAGE_SOURCE_FLAMETHROWER) or (argument1.lastDamageSource == DAMAGE_SOURCE_FLARE) or (argument1.lastDamageSource == DAMAGE_SOURCE_REFLECTED_FLARE) {
            with (Contracts.Contract) {
                if (!completed) {
                    if (owner == argument0) {
                        switch (contract_type) {
                            case Contracts.CONTRACT_TYPE_BURN_DURATION:
                                burn_duration += global.delta_factor;
                                break;
                        }
                    }
                }
            }
        }
    }
';