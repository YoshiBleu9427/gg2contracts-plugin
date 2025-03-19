RoundEndObserver = object_add();

object_event_add(RoundEndObserver, ev_create, 0, '
    triggered = false;
');

object_event_add(RoundEndObserver, ev_step, ev_step_normal, '
    if (!triggered) {
        if (global.winners != -1) {
            with (Contracts.Contract) {
                event_perform(ev_other, Contracts.EVT_CONTRACT_ON_MAP_END);
            }
            
            with (instance_create(0, 0, Contracts.ServerBackendNetworker)) {
                event_perform(ev_other, Contracts.EVT_SEND_HELLO);
                on_hello_command = Contracts.EVT_SEND_SRV_GAME_DATA;
                destroy_on_queue_empty = true;
            }
            
            triggered = true;
        }
    }
');

object_event_add(PlayerControl, ev_step, ev_step_normal, '
    if (!instance_exists(Contracts.RoundEndObserver)) {
        instance_create(0, 0, Contracts.RoundEndObserver);
    }
');