
object_event_add(Player, ev_create, 0, '
    Contracts_has_plugin = false;
    Contracts_session_token = "";
');

/**
 *  If player leaves, remove their contracts
 */
object_event_add(Player, ev_destroy, 0, '
    if (Contracts_has_plugin) {
        ds_map_delete(Contracts.players_by_session_token, Contracts_session_token);
        with (Contracts.Contract) {
            if (owner == other.id) {
                ds_map_delete(Contracts.contracts_by_uuid, contract_id);
                instance_destroy();
            }
        }
    }
');