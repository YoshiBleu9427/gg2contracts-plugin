object_event_add(Player, ev_create, 0, '
    Contracts_has_plugin = false;
    Contracts_session_token = "";
');

object_event_add(Player, ev_destroy, 0, '
    if (Contracts_has_plugin) {
        ds_map_delete(Contracts.players_by_session_token, Contracts_session_token);
        with (Contracts.Contract) {
            if (owner == other.id) {
                owner = noone;
            }
        }
    }
');