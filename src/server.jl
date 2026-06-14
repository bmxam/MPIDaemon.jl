
"""
    create_servers(; port0=DEFAULT_PORT0, url = Sockets.localhost)

Initialize MPI and create a TCP server on each MPI process.
"""
function create_servers(; port0=DEFAULT_PORT0, url=Sockets.localhost)
    MPI.Init()
    comm = MPI.COMM_WORLD
    rank = MPI.Comm_rank(comm)

    # Create server
    port = port0 + rank
    @one_at_a_time println("Starting server on $(url):$(port)")
    server = Sockets.listen(url, port)
    while isopen(server)
        sock = accept(server)
        keep_going = handle_request(sock, comm)
        keep_going || close(server)
    end

    pprintln("Server has been killed by client", comm)
    MPI.Finalize()
end

function handle_request(sock, comm)
    action_as_str = readline(sock)
    action = string_to_action(action_as_str)
    msg = "Received action $(string(nameof(typeof(action))))"
    if is_collective_action(action)
        @only_root println(msg)
    else
        pprintln(msg, comm)
    end
    return handle_action(action, sock, comm)
end

function handle_action(::RunScriptAction, sock, comm)
    script_path = readline(sock)
    try
        include(script_path)
    catch e
        @show e
    end
    return true
end

handle_action(action::KillAction, sock, comm) = false

function handle_action(::GetSizeAction, sock, comm)
    println(sock, MPI.Comm_size(comm))
    return true
end

function handle_action(::EchoAction, sock, comm)
    msg = readline(sock)
    pprintln("$msg")
    return true
end

function handle_action(action::AbstractAction, sock, comm)
    @only_root println("Could not handle action '$(string(nameof(typeof(action))))'")
    return true
end