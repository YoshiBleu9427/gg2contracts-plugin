BackendNetworker = object_add();
ServerBackendNetworker = object_add();
ClientBackendNetworker = object_add();

object_set_parent(ServerBackendNetworker, BackendNetworker);
object_set_parent(ClientBackendNetworker, BackendNetworker);

object_set_persistent(ClientBackendNetworker, true);
object_set_persistent(ServerBackendNetworker, true);

/**
 *   ----------------------------------------
 *
 *      Net constants
 *
 *      NET_                Header bytes to communicate
 *         _BACK_               with the backend
 *              _REQ_               from this (request)
 *              _RESP_              from the backend (response)
 *
 *   ----------------------------------------
 */
NET_BACK_HELLO_UUID = unhex("fe8300b349784a428e48b07c04934a18")

NET_BACK_REQ_HELLO                  = 0
NET_BACK_REQ_LOGIN                  = 1
NET_BACK_REQ_NEW_ACCOUNT            = 2
NET_BACK_REQ_SET_ACCOUNT_USERNAME   = 3
NET_BACK_REQ_JOIN_SERVER            = 4
NET_BACK_REQ_GET_CONTRACTS          = 5
NET_BACK_REQ_REGISTER_SERVER        = 100
NET_BACK_REQ_SERVER_RECEIVES_CLIENT = 101
NET_BACK_REQ_GAME_DATA              = 102

NET_BACK_RESP_HELLO                 = 0
NET_BACK_RESP_SUCCESS               = 1
NET_BACK_RESP_FAIL                  = 2
NET_BACK_RESP_CHALLENGE_TOKEN       = 10
NET_BACK_RESP_PLAYER_CONTRACTS      = 11
NET_BACK_RESP_UPDATE_CONTRACTS      = 12



/**
 *   ----------------------------------------
 *
 *      Commands and handler consts
 *
 *   ----------------------------------------
 */
 
EVT_SEND_HELLO = ev_user0;

EVT_SEND_CLT_LOGIN                  = ev_user1;
EVT_SEND_CLT_NEW_ACCOUNT            = ev_user2;
EVT_SEND_CLT_SET_ACCOUNT_USERNAME   = ev_user3;
EVT_SEND_CLT_JOIN_SERVER            = ev_user4;
EVT_SEND_CLT_GET_CONTRACTS          = ev_user5;

EVT_SEND_SRV_REGISTER_SERVER        = ev_user1;
EVT_SEND_SRV_SERVER_RECEIVES_CLIENT = ev_user2;
EVT_SEND_SRV_GAME_DATA              = ev_user3;


EVT_HANDLE_HELLO = ev_user6;

EVT_HANDLE_CLT_LOGIN                = ev_user7;
EVT_HANDLE_CLT_NEW_ACCOUNT          = ev_user8;
EVT_HANDLE_CLT_SET_ACCOUNT_USERNAME = ev_user9;
EVT_HANDLE_CLT_JOIN_SERVER          = ev_user10;
EVT_HANDLE_CLT_GET_CONTRACTS        = ev_user11;

EVT_HANDLE_SRV_REGISTER_SERVER      = ev_user7;
EVT_HANDLE_SRV_SERVER_RECEIVES_CLIENT = ev_user8;
EVT_HANDLE_SRV_GAME_DATA            = ev_user9;


CMD_STATE_INIT = 0;
CMD_STATE_EXPECT_RESPONSE = 1;
CMD_STATE_EXPECT_COUNT = 2;
CMD_STATE_EXPECT_COMPLETED_CONTRACT_COUNT = 3;
CMD_STATE_EXPECT_COMPLETED_CONTRACT_DATA = 4;
CMD_STATE_EXPECT_NEW_CONTRACT_COUNT = 5;
CMD_STATE_EXPECT_NEW_CONTRACT_DATA = 6;







/**
 *   ----------------------------------------
 *
 *      Net handlers
 *
 *   ----------------------------------------
 */
object_event_add(BackendNetworker, ev_create, 0, '
    backend_socket = tcp_connect(Contracts.BACKEND_HOST, Contracts.BACKEND_PORT);
    last_contact = current_time;
    expected_byte_count = 0;
    running_handler_event = noone;
    next_handler_event = noone;
    command_state = Contracts.CMD_STATE_INIT;
    destroy_on_queue_empty = false;
    
    on_hello_command = noone;
');

object_event_add(ServerBackendNetworker, ev_create, 0, '
    event_inherited();
    received_session_token = ""; // arg for SERVER_RECEIVES_CLIENT
');

object_event_add(ClientBackendNetworker, ev_create, 0, '
    event_inherited();    
    on_login_command = noone;
');

object_event_add(BackendNetworker, ev_destroy, 0, '
    socket_destroy(backend_socket);
');

object_event_add(BackendNetworker, ev_step, ev_step_normal, '
    keep_processing = true;
    while (keep_processing) {
        if (running_handler_event == noone) {
            command_state = Contracts.CMD_STATE_INIT;
            if (next_handler_event != noone) {
                running_handler_event = next_handler_event;
                next_handler_event = noone;
            } else {
                if (destroy_on_queue_empty) {
                    instance_destroy();
                }
                break;
            }
        }
        
        // TODO crash silently in dedicated mode
        if (socket_has_error(backend_socket)) {
            show_error("Lost connexion to the Contracts server: " + socket_error(backend_socket), false);
            instance_destroy();
            break;
        }
        if (current_time - last_contact > 30000) {  // TODO const
            show_error("Lost connexion to the Contracts server (timeout)", false);
            instance_destroy();
            break;
        }
        
        if (!tcp_receive(backend_socket, expected_byte_count)) {
            break;
        }

        last_contact = current_time;
        expected_byte_count = 0;
        event_perform(ev_other, running_handler_event);
    }
');

/**
 *   ----------------------------------------
 *
 *      Common handlers
 *
 *      Sender events:
 *          - SHOULD Write to backend socket, and send it
 *          - MUST Set expected_byte_count to the size of the next expected data (at least 1 to receive the next header)
 *          - MUST Set next_handler_event to the EVT_HANDLE_### matching their EVT_SEND_### value
 *
 *      Handler events:
 *          - MUST Only attempt to read [previous value of expected_byte_count] bytes from backend_socket
 *          - MUST If more data is required (e.g. reading strings), set their expected_byte_count and update their command_state
 *          - SHOULD Use a switch(command_state) with a case for first entry, and for each update of expected_byte_count
 *          - MUST Set running_handler_event to noone on success
 *          - MUST Call instance_destroy on error
 *
 *   ----------------------------------------
 */
object_event_add(BackendNetworker, ev_other, EVT_SEND_HELLO, '
    write_ubyte(backend_socket, Contracts.NET_BACK_REQ_HELLO);
    write_binstring(backend_socket, Contracts.NET_BACK_HELLO_UUID);
    socket_send(backend_socket);
    
    expected_byte_count += 1;
    next_handler_event = Contracts.EVT_HANDLE_HELLO;
');

object_event_add(BackendNetworker, ev_other, EVT_HANDLE_HELLO, '
    var resp;
    resp = read_ubyte(backend_socket);
    switch (resp) {
        case Contracts.NET_BACK_RESP_HELLO:
            // cool
            if (on_hello_command != noone) {
                event_perform(ev_other, on_hello_command);
            }
            running_handler_event = noone;
            break;
        case Contracts.NET_BACK_RESP_FAIL:
            // oh no
            show_error("Failed to get hello from Contracts backend. Version mismatch?", false);  // TODO better handling
            instance_destroy();
            break;
        default:
            show_error("Unexpected response " + string(resp) + " from Contracts backend (EVT_HANDLE_HELLO)", false);
            instance_destroy();
            break;
        
    }
');



/**
 *   ----------------------------------------
 *
 *      Client handlers
 *
 *   ----------------------------------------
 */
object_event_add(ClientBackendNetworker, ev_other, EVT_SEND_CLT_LOGIN, '
    write_ubyte(backend_socket, Contracts.NET_BACK_REQ_LOGIN);
    write_binstring(backend_socket, Contracts.user_key);
    socket_send(backend_socket);
    
    expected_byte_count += 1;
    next_handler_event = Contracts.EVT_HANDLE_CLT_LOGIN;
');

object_event_add(ClientBackendNetworker, ev_other, EVT_HANDLE_CLT_LOGIN, '
    var resp;
    resp = read_ubyte(backend_socket);
    switch (resp) {
        case Contracts.NET_BACK_RESP_SUCCESS:
            if (on_login_command != noone) {
                event_perform(ev_other, on_login_command);
            }
            running_handler_event = noone;
            break;
            
        case Contracts.NET_BACK_RESP_FAIL:
            // oh no
            show_error("Failed to login to Contracts backend.", false); // TODO better handling
            instance_destroy();
            break;
            
        default:
            show_error("Unexpected response " + string(resp) + " from Contracts backend (EVT_HANDLE_CLT_LOGIN)", false);
            instance_destroy();
            break;
        
    }
');



object_event_add(ClientBackendNetworker, ev_other, EVT_SEND_CLT_NEW_ACCOUNT, '
    write_ubyte(backend_socket, Contracts.NET_BACK_REQ_NEW_ACCOUNT);
    write_ubyte(backend_socket, string_length(global.playerName));
    write_string(backend_socket, global.playerName);
    write_ubyte(backend_socket, CLASS_SOLDIER);  // TODO
    socket_send(backend_socket);
    
    expected_byte_count += 16;
    next_handler_event = Contracts.EVT_HANDLE_CLT_NEW_ACCOUNT;
');

object_event_add(ClientBackendNetworker, ev_other, EVT_HANDLE_CLT_NEW_ACCOUNT, '
    Contracts.user_key = read_binstring(backend_socket, 16);
    gg2_write_ini(Contracts.INI_SECTION, Contracts.INI_USER_KEY_KEY, hex(Contracts.user_key));
    
    running_handler_event = noone;
');



object_event_add(ClientBackendNetworker, ev_other, EVT_SEND_CLT_JOIN_SERVER, '
    if (string_length(Contracts.joined_server_id) != 16) {
        show_error("Contracts plugin error: bad length for joined_server_id (EVT_SEND_CLT_JOIN_SERVER)", false);
    }
    write_ubyte(backend_socket, Contracts.NET_BACK_REQ_JOIN_SERVER);
    write_binstring(backend_socket, Contracts.joined_server_id);
    socket_send(backend_socket);
    
    expected_byte_count += 16 + 1;
    next_handler_event = Contracts.EVT_HANDLE_CLT_JOIN_SERVER;
');

object_event_add(ClientBackendNetworker, ev_other, EVT_HANDLE_CLT_JOIN_SERVER, '
    switch(command_state) {
        case Contracts.CMD_STATE_INIT:
            Contracts.session_token = read_binstring(backend_socket, 16);
            contract_count = read_ubyte(backend_socket);
            expected_byte_count += contract_count * 21;
            command_state = Contracts.CMD_STATE_EXPECT_RESPONSE;
            break;
        case Contracts.CMD_STATE_EXPECT_RESPONSE:
            var i;
            for (i=0; i<contract_count; i+=1) {
                new_contract = instance_create(0, 0, Contracts.Contract);
                with (new_contract) {
                    contract_id = read_binstring(other.backend_socket, 16);
                    contract_type = read_ubyte(other.backend_socket);
                    value = read_ubyte(other.backend_socket);
                    target_value = read_ubyte(other.backend_socket);
                    game_class = read_ubyte(other.backend_socket);
                    points = read_ubyte(other.backend_socket);
                    owner = global.myself;
                    owner_id = Contracts.session_token;
                }
                ds_map_add(Contracts.contracts_by_uuid, new_contract.contract_id, new_contract);
            }
            Contracts.backend_knows_we_joined_as_client = true;  // TODO global var bad
            // use the newly received session_token instead
            running_handler_event = noone;
            break;
    }
');



/**
 *   ----------------------------------------
 *
 *      Server handlers
 *
 *   ----------------------------------------
 */
object_event_add(ServerBackendNetworker, ev_other, EVT_SEND_SRV_REGISTER_SERVER, '
    write_ubyte(backend_socket, Contracts.NET_BACK_REQ_REGISTER_SERVER);
    socket_send(backend_socket);
    
    expected_byte_count += 2 * 16;
    next_handler_event = Contracts.EVT_HANDLE_SRV_REGISTER_SERVER;
');

object_event_add(ServerBackendNetworker, ev_other, EVT_HANDLE_SRV_REGISTER_SERVER, '
    Contracts.server_id = read_binstring(backend_socket, 16);
    Contracts.server_validation_token = read_binstring(backend_socket, 16);
    gg2_write_ini(Contracts.INI_SECTION, Contracts.INI_SERVER_ID_KEY, hex(Contracts.server_id));
    gg2_write_ini(Contracts.INI_SECTION, Contracts.INI_SERVER_VALID_TOKEN_KEY, hex(Contracts.server_validation_token));

    
    running_handler_event = noone;
');



object_event_add(ServerBackendNetworker, ev_other, EVT_SEND_SRV_SERVER_RECEIVES_CLIENT, '
    if (received_session_token == "") {
        // TODO dont show error in dedicated mode
        show_error("Contracts plugin error: ServerBackendNetworker.received_session_token is undefined", false);
    }
    write_ubyte(backend_socket, Contracts.NET_BACK_REQ_SERVER_RECEIVES_CLIENT);
    write_binstring(backend_socket, Contracts.server_id);
    write_binstring(backend_socket, received_session_token);
    socket_send(backend_socket);
    
    expected_byte_count += 1;
    next_handler_event = Contracts.EVT_HANDLE_SRV_SERVER_RECEIVES_CLIENT;
');

object_event_add(ServerBackendNetworker, ev_other, EVT_HANDLE_SRV_SERVER_RECEIVES_CLIENT, '
    if (received_session_token == "") {
        show_error("Contracts plugin error: ServerBackendNetworker.received_session_token is undefined in Handler, and THAT is super weird", false);
    }
    
    var resp, _player, pluginPacketBuffer;
    _player = ds_map_find_value(Contracts.players_by_session_token, received_session_token); // may be -1 if player left before we received the backend response
    switch (command_state) {
        case Contracts.CMD_STATE_INIT:
            resp = read_ubyte(backend_socket);
            switch (resp) {
                case Contracts.NET_BACK_RESP_SUCCESS:
                    // cool
                    command_state = Contracts.CMD_STATE_EXPECT_COUNT;
                    expected_byte_count += 1;
                    break;
                    
                case Contracts.NET_BACK_RESP_FAIL:
                    // client probably sent an invalid session token. Tell them it failed, then drop them
                    if (_player != -1) {
                        pluginPacketBuffer = buffer_create();
                        write_ubyte(pluginPacketBuffer, Contracts.NET_GAME_SRV_FAIL);
                        PluginPacketSendTo(Contracts.packetID, pluginPacketBuffer, _player);
                        buffer_destroy(pluginPacketBuffer);
                    }
                    
                    // TODO log error: client sent a bad session token, or our server_id is wrong
                    instance_destroy();
                    break;
                    
                default:
                    show_error("Unexpected response " + string(resp) + " from Contracts backend (EVT_HANDLE_SRV_SERVER_RECEIVES_CLIENT)", false);
                    instance_destroy();
                    break;
            }
            break;
            
        case Contracts.CMD_STATE_EXPECT_COUNT:
            contract_count = read_ubyte(backend_socket);
            command_state = Contracts.CMD_STATE_EXPECT_RESPONSE;
            expected_byte_count += 21 * contract_count;
            break;
            
        case Contracts.CMD_STATE_EXPECT_RESPONSE:
            if ((global.isHost) and (_player == global.myself)) {
                // as the host, we already know our own contracts,
                // because we received them after sending NET_BACK_REQ_JOIN_SERVER
                // so ignore this data
                read_binstring(backend_socket, contract_count * 21);
            } else {
                for (i = 0; i < contract_count; i += 1) {
                    var contract_id, contract_type, value, target_value, game_class, points;
                    
                    contract_id = read_binstring(other.backend_socket, 16);
                    contract_type = read_ubyte(other.backend_socket);
                    value = read_ubyte(other.backend_socket);
                    target_value = read_ubyte(other.backend_socket);
                    game_class = read_ubyte(other.backend_socket);
                    points = read_ubyte(other.backend_socket);
                    
                    if (ds_map_exists(Contracts.contracts_by_uuid, contract_id)) {
                        // same player joins again; re-link it, dont create a new one
                        with (ds_map_find_value(Contracts.contracts_by_uuid, contract_id)) {
                            owner = _player;
                        }
                        // TODO maybe a PluginPacket to sync value_increment
                    } else {
                        var newContract;
                        newContract = instance_create(0, 0, Contracts.Contract);
                        
                        newContract.contract_id = contract_id;
                        newContract.contract_type = contract_type;
                        newContract.value = value;
                        newContract.target_value = target_value;
                        newContract.game_class = game_class;
                        newContract.points = points;
                        
                        newContract.owner = _player;
                        newContract.owner_id = _player.Contracts_session_token;
                        
                        ds_map_add(Contracts.contracts_by_uuid, newContract.contract_id, newContract);
                    }
                }
            }
            
            if (_player != -1) {
                // tell the player it worked
                pluginPacketBuffer = buffer_create();
                write_ubyte(pluginPacketBuffer, Contracts.NET_GAME_SRV_SUCCESS);
                PluginPacketSendTo(Contracts.packetID, pluginPacketBuffer, _player);
                buffer_destroy(pluginPacketBuffer);
            }
            
            running_handler_event = noone;
            break;
    }
');



object_event_add(ServerBackendNetworker, ev_other, EVT_SEND_SRV_GAME_DATA, '
    var _user_contract_list, _contracts_by_user, _user_session_key, i, val;
    _contracts_by_user = ds_map_create();  // contract lists by user session token
    
    with (Contracts.Contract) {
        if (value_increment > 0) {
            if (!ds_map_exists(_contracts_by_user, owner_id)) {
                _user_contract_list = ds_list_create();
                ds_map_add(_contracts_by_user, owner_id, _user_contract_list);
            } else {
                _user_contract_list = ds_map_find_value(_contracts_by_user, owner_id);
            }
            ds_list_add(_user_contract_list, id);
        }
    }
    
    write_ubyte(backend_socket, Contracts.NET_BACK_REQ_GAME_DATA);
    write_binstring(backend_socket, Contracts.server_id);
    write_binstring(backend_socket, Contracts.server_validation_token);
    
    // TODO maybe dont save serverid or validation token in ini, because one server desync makes it unusable unless you edit out your serverid
    // TODO outside of this specific scope, but the whole validation exchange can probably be dumbed down to private key/public key on both clients and servers
    
    write_ubyte(backend_socket, ds_map_size(_contracts_by_user));
    
    _user_session_key = ds_map_find_first(_contracts_by_user);
    while (is_string(_user_session_key)) {
        _user_contract_list = ds_map_find_value(_contracts_by_user, _user_session_key);
        
        write_binstring(backend_socket, _user_session_key);
        write_ubyte(backend_socket, ds_list_size(_user_contract_list));
        
        for (i = 0; i < ds_list_size(_user_contract_list); i+=1) {
            val = ds_list_find_value(_user_contract_list, i);
            write_binstring(backend_socket, val.contract_id);
            write_ubyte(backend_socket, val.value_increment);
            
            with (val) {
                event_perform(ev_other, Contracts.EVT_CONTRACT_ON_DATA_SENT);
            }
        }
        
        ds_list_destroy(_user_contract_list);
        
        _user_session_key = ds_map_find_next(_contracts_by_user, _user_session_key);
    }
    
    ds_map_destroy(_contracts_by_user);
    
    socket_send(backend_socket);
    
    expected_byte_count += 16 + 1;
    next_handler_event = Contracts.EVT_HANDLE_SRV_GAME_DATA;
');

object_event_add(ServerBackendNetworker, ev_other, EVT_HANDLE_SRV_GAME_DATA, '
    switch (command_state) {
        case Contracts.CMD_STATE_INIT:
            Contracts.server_validation_token = read_binstring(backend_socket, 16);
            user_count = read_ubyte(backend_socket);
            
            if (user_count > 0) {
                expected_byte_count += 16 + 1;
                command_state = Contracts.CMD_STATE_EXPECT_COMPLETED_CONTRACT_COUNT;
            } else {
                running_handler_event = noone;
            }
            break;
            
        case Contracts.CMD_STATE_EXPECT_COMPLETED_CONTRACT_COUNT:
            received_session_token = read_binstring(backend_socket, 16);
            contract_count = read_ubyte(backend_socket);
            
            buffer_for_player = buffer_create();  // TODO possible memory leak // maybe hook into some ServerPluginNetworker buffer
            write_ubyte(buffer_for_player, Contracts.NET_GAME_SRV_UPDATE_CONTRACTS);
            write_ubyte(buffer_for_player, contract_count);
            
            expected_byte_count += contract_count * 16;
            command_state = Contracts.CMD_STATE_EXPECT_COMPLETED_CONTRACT_DATA;
            break;
            
        case Contracts.CMD_STATE_EXPECT_COMPLETED_CONTRACT_DATA:
            for (i = 0; i < contract_count; i += 1) {
                contract_uuid = read_binstring(backend_socket, 16);
                contract = ds_map_find_value(Contracts.contracts_by_uuid, contract_uuid)
                if (contract != -1) {
                    contract.completed = true;
                    // TODO handle error maybe?
                }
                write_binstring(buffer_for_player, contract_uuid);
            }
            expected_byte_count += 1;
            command_state = Contracts.CMD_STATE_EXPECT_NEW_CONTRACT_COUNT;
            break;
            
        case Contracts.CMD_STATE_EXPECT_NEW_CONTRACT_COUNT:
            contract_count = read_ubyte(backend_socket);
            write_ubyte(buffer_for_player, contract_count);
            
            expected_byte_count += contract_count * 20;
            command_state = Contracts.CMD_STATE_EXPECT_NEW_CONTRACT_DATA;
            break;
            
        case Contracts.CMD_STATE_EXPECT_NEW_CONTRACT_DATA:
            _player = ds_map_find_value(Contracts.players_by_session_token, received_session_token);
            if (_player == -1) {
                // player left before getting response from backend, ignore this data specifically
                read_binstring(backend_socket, 20 * contract_count);
            } else {
                for (i = 0; i < contract_count; i += 1) { 
                    var newContract;
                    newContract = instance_create(0, 0, Contracts.Contract);
                    with (newContract) {
                        contract_id = read_binstring(other.backend_socket, 16);
                        contract_type = read_ubyte(other.backend_socket);
                        target_value = read_ubyte(other.backend_socket);
                        game_class = read_ubyte(other.backend_socket);
                        points = read_ubyte(other.backend_socket);
                        owner = other._player;
                        owner_id = other.received_session_token;
                        
                        write_binstring(other.buffer_for_player, contract_id);
                        write_ubyte(other.buffer_for_player, contract_type);
                        write_ubyte(other.buffer_for_player, target_value);
                        write_ubyte(other.buffer_for_player, game_class);
                        write_ubyte(other.buffer_for_player, points);
                    }
                    ds_map_add(Contracts.contracts_by_uuid, newContract.contract_id, newContract);
                }
                
                PluginPacketSendTo(Contracts.packetID, buffer_for_player, _player);
                buffer_destroy(buffer_for_player);
            }
            
            user_count -= 1;
            if (user_count > 0) {
                expected_byte_count += 16 + 1;
                command_state = Contracts.CMD_STATE_EXPECT_COMPLETED_CONTRACT_COUNT;
            } else {
                running_handler_event = noone;
            }
            break;
        
    }
');
