PluginNetworker = object_add();
object_set_persistent(PluginNetworker, true);

/**
 *   ----------------------------------------
 *
 *      Net constants
 *
 *      NET_                Header bytes to communicate
 *         _GAME_               with the game through plugin packets
 *              _CLT_               from the game client
 *              _SRV_               from the game server
 *
 *   ----------------------------------------
 */

NET_GAME_HELLO_UUID = unhex("b40e8d6ed49d47b78b2508dca6b35a88")

NET_GAME_CLT_HELLO = 0
NET_GAME_CLT_REGISTER_CLIENT = 1

NET_GAME_SRV_HELLO          = 10
NET_GAME_SRV_SUCCESS        = 11
NET_GAME_SRV_FAIL           = 12
NET_GAME_SRV_UPDATE_CONTRACTS = 13
NET_GAME_SRV_SYNC_INCREMENT = 14



/**
 *   ----------------------------------------
 *
 *      Plugin Networker
 *
 *   ----------------------------------------
 */

//  Hooks to spawn it
//
object_event_add(PlayerControl, ev_step, ev_step_end, '
    if (!instance_exists(Contracts.PluginNetworker)) {
        instance_create(0, 0, Contracts.PluginNetworker);
    }
');

object_event_add(PlayerControl, ev_destroy, 0, '
    with(Contracts.PluginNetworker) {
        instance_destroy();
    }
');


//  On create,
//      if server, register
//      if client (i.e. not dedicated server), setup client key if not exists
//
object_event_add(PluginNetworker, ev_create, 0, '
    tried_to_login = false;
    tried_to_register_client = false;
    
    
    if (Contracts.user_key == "") {
        if (!show_question("Welcome to Contracts!##Play the game. Complete missions. Earn points!#Score a lot and earn prices!##Would you like to sign up?")) { // TODO better signup form
            // TODO choice to paste an existing key
            show_message("Sadge"); // TODO probably just say nothing
        } else {
            with (instance_create(0, 0, Contracts.ClientBackendNetworker)) {
                event_perform(ev_other, Contracts.EVT_SEND_HELLO);
                on_hello_command = Contracts.EVT_SEND_CLT_NEW_ACCOUNT;
                destroy_on_queue_empty = true;
            }
        }
    }
    
    if (global.isHost) {
        if ((Contracts.server_id == "") or (Contracts.server_validation_token == "")) {
            with (instance_create(0, 0, Contracts.ServerBackendNetworker)) {
                event_perform(ev_other, Contracts.EVT_SEND_HELLO);
                on_hello_command = Contracts.EVT_SEND_SRV_REGISTER_SERVER;
                destroy_on_queue_empty = true;  // TODO maybe this isnt even needed, and I can always destroy the networker when queue is empty when not in debug mode
            }
        }
    }
');


//  As a client, tell server youre ready to connect as soon as you get your user key
//
object_event_add(PluginNetworker, ev_step, ev_step_normal, '
    if (!tried_to_login) {
        if (Contracts.user_key != "") {
            var buf;
            buf = buffer_create();
            write_ubyte(buf, Contracts.NET_GAME_CLT_HELLO);
            write_binstring(buf, Contracts.NET_GAME_HELLO_UUID);
            if (global.isHost) {
                PluginPacketSendTo(Contracts.packetID, buf, global.myself);
            } else {
                PluginPacketSend(Contracts.packetID, buf);
            }
            buffer_destroy(buf);
            tried_to_login = true;
        }
    }
    
    // when youre ready to send your session token, send it
    if (!tried_to_register_client) {
        if (Contracts.session_token != "") {
            var buf;
            buf = buffer_create();
            write_ubyte(buf, Contracts.NET_GAME_CLT_REGISTER_CLIENT);
            write_binstring(buf, Contracts.session_token);
            if (global.isHost) {
                PluginPacketSendTo(Contracts.packetID, buf, global.myself);
            } else {
                PluginPacketSend(Contracts.packetID, buf);
            }
            buffer_destroy(buf);
            tried_to_register_client = true;
        }
    }
');


//  Handle received plugin packets
//
object_event_add(PluginNetworker, ev_step, ev_step_normal, '
    if (global.isHost) {
        if (Contracts.server_id = "") {
            // not ready to handle clients
            exit;
        }
    }
    
    var buf, _player, respBuf, header;
    var received_uuid;
    var count, i;
    var completed_contract_uuid;
    var contract_id, contract_type, value, target_value, value_increment, game_class, points;
    
    while (PluginPacketGetBuffer(Contracts.packetID) != -1) {
        respBuf = buffer_create();
        buf = PluginPacketGetBuffer(Contracts.packetID);
        _player = PluginPacketGetPlayer(Contracts.packetID);
        
        while (buffer_bytes_left(buf) > 0) {
        
            header = read_ubyte(buf);
            switch (header) {
                // ------------
                //  Only the server should receive those
                //
                case Contracts.NET_GAME_CLT_HELLO:
                    if (!global.isHost) {
                        with (Contracts.errorLog) {
                            log = "Client received unexpected NET_GAME_CLT_HELLO";
                            event_perform(ev_other, Contracts.EVT_ERROR_LOG);
                        }
                        exit;
                    }
                    
                    received_uuid = read_binstring(buf, 16);
                    if (received_uuid != Contracts.NET_GAME_HELLO_UUID) {
                        // invalid client
                        write_ubyte(respBuf, Contracts.NET_GAME_SRV_FAIL);
                    } else {
                        _player.Contracts_has_plugin = true;
                        write_ubyte(respBuf, Contracts.NET_GAME_SRV_HELLO);
                        write_binstring(respBuf, Contracts.server_id);
                    }
                    
                    PluginPacketSendTo(Contracts.packetID, respBuf, _player);
                    buffer_destroy(respBuf);
                    break;
                    
                case Contracts.NET_GAME_CLT_REGISTER_CLIENT:
                    if (!global.isHost) {
                        with (Contracts.errorLog) {
                            log = "Client received unexpected NET_GAME_CLT_REGISTER_CLIENT";
                            event_perform(ev_other, Contracts.EVT_ERROR_LOG);
                        }
                        exit;
                    }
                    
                    with (instance_create(0, 0, Contracts.ServerBackendNetworker)) {
                        event_perform(ev_other, Contracts.EVT_SEND_HELLO); // TODO creating it always starts with hello; remove everywhere
                        received_session_token = read_binstring(buf, 16);  // TODO test what happens if client sends bad size
                        _player.Contracts_session_token = received_session_token;
                        ds_map_add(Contracts.players_by_session_token, received_session_token, _player);
                        on_hello_command = Contracts.EVT_SEND_SRV_SERVER_RECEIVES_CLIENT;
                        destroy_on_queue_empty = true;
                    }
                    // will have to wait for backend response before getting back to _player
                    break;
                    
                // ------------
                //  Only clients should receive those, but the server can also send those to itself
                //
                case Contracts.NET_GAME_SRV_HELLO:
                    Contracts.joined_server_id = read_binstring(buf, 16);
                    
                    if (global.isHost) {
                        if (Contracts.server_id != Contracts.joined_server_id) {
                            // TODO what to do on error?
                            with (Contracts.errorLog) {
                                log = "Contracts plugin error: server sent itself a server_id that is not, in fact, its server_id";
                                event_perform(ev_other, Contracts.EVT_ERROR_LOG);
                            }
                            exit;
                        }
                    }
                    
                    with (instance_create(0,0,Contracts.ClientBackendNetworker)) {
                        event_perform(ev_other, Contracts.EVT_SEND_HELLO);
                        on_hello_command = Contracts.EVT_SEND_CLT_LOGIN;
                        on_login_command = Contracts.EVT_SEND_CLT_JOIN_SERVER;
                        destroy_on_queue_empty = true;
                    }
                    break;
                    
                case Contracts.NET_GAME_SRV_SUCCESS: // TODO rename to REGISTRATION_SUCCESS or something
                    // yay
                    // idk what to do here tbh
                    // TODO
                    break;
                    
                case Contracts.NET_GAME_SRV_FAIL:
                    // oh no
                    with (Contracts.errorLog) {
                        log = "Contracts plugin error: version mismatch between client and server";
                        event_perform(ev_other, Contracts.EVT_ERROR_LOG);
                    }
                    // TODO disable plugin probably. not that it does anything clientside. so do nothing? maybe just dont respawn a PluginNetworker
                    break;
                    
                case Contracts.NET_GAME_SRV_SYNC_INCREMENT:
                    contract_id = read_binstring(buf, 16);
                    value_increment = read_ubyte(buf);
                    
                    if (global.isHost) {
                        // as the host you already know, so you can ignore this packet altogether
                        break;
                    }
                    
                    if (!ds_map_exists(Contracts.contracts_by_uuid, contract_id)) {
                        with (Contracts.errorLog) {
                            log = "Contracts plugin error: server wants to sync unknown contract " + string(hex(contract_id));
                            event_perform(ev_other, Contracts.EVT_ERROR_LOG);
                        }
                    } else {
                        var syncing_contract;
                        syncing_contract = ds_map_find_value(Contracts.contracts_by_uuid, contract_id);
                        syncing_contract.value_increment = value_increment;
                        with (syncing_contract) {
                            event_perform(ev_other, Contracts.EVT_CONTRACT_ON_INCREMENTED);
                        }
                    }
                    break;
                
                    
                case Contracts.NET_GAME_SRV_UPDATE_CONTRACTS:
                    count = read_ubyte(buf);
                    for (i = 0; i < count; i += 1) {
                        completed_contract_uuid = read_binstring(buf, 16);
                        if (!ds_map_exists(Contracts.contracts_by_uuid, completed_contract_uuid)) {
                            with (Contracts.errorLog) {
                                log = "Contracts plugin error: completed unknown contract " + string(hex(completed_contract_uuid));
                                event_perform(ev_other, Contracts.EVT_ERROR_LOG);
                            }
                        } else {                    
                            completed_contract = ds_map_find_value(Contracts.contracts_by_uuid, completed_contract_uuid);
                            completed_contract.completed = true;
                            completed_contract.value = completed_contract.target_value;  // TODO do it elsewhere?
                            with (completed_contract) {
                                event_perform(ev_other, Contracts.EVT_CONTRACT_ON_COMPLETED);
                            }
                        }
                    }
                    
                    count = read_ubyte(buf);
                    if (global.isHost) {
                        // as the host you already know, so you can ignore this packet
                        // we didnt ignore the previous part because we might want to trigger EVT_CONTRACT_ON_COMPLETED
                        // TODO think about it
                        read_binstring(buf, 20 * count);
                    } else {
                        for (i = 0; i < count; i += 1) {
                            var newContract;
                            newContract = instance_create(0, 0, Contracts.Contract);
                            newContract.contract_id = read_binstring(buf, 16);
                            newContract.contract_type = read_ubyte(buf);
                            newContract.target_value = read_ubyte(buf);
                            newContract.game_class = read_ubyte(buf);
                            newContract.points = read_ubyte(buf);
                            newContract.owner = global.myself;
                            newContract.owner_id = Contracts.session_token;
                            ds_map_add(Contracts.contracts_by_uuid, newContract.contract_id, newContract);
                        }
                    }
                    break;
                    
                default:
                    with (Contracts.errorLog) {
                        log = "Contracts: received unknown header in PluginNetworker: " + string(header);
                        event_perform(ev_other, Contracts.EVT_ERROR_LOG);
                    }
                    break
            }
        }
    
        PluginPacketPop(Contracts.packetID);
    }
');
