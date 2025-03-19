/**
 *  Hooks for more complex contract rules
 */

object_event_add(Character, ev_destroy, 0, '
    if (global.isHost)
	if (lastDamageDealer != player)
    {
        with (Contracts.Contract) {
            if (!completed)
            if (owner == other.lastDamageDealer) {
                if (contract_type == Contracts.CONTRACT_TYPE_KILLS_ON_CLASS) {
                    if (other.player.class == game_class) {
                        value_increment += 1;
                    }
                }
                if (contract_type == Contracts.CONTRACT_TYPE_KILLS_AS_CLASS) {
                    if (owner.class == game_class) {
                        value_increment += 1;
                    }
                }
            }
        }
	}
');