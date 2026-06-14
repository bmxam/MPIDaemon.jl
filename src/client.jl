function run_script()
    s = ArgParseSettings()
    @add_arg_table! s begin
        "--script-path"
        help = "Path to script to execute"
        arg_type = String
        required = true
        "--port0"
        help = "Port for rank-0 process"
        default = DEFAULT_PORT0
    end
    args = parse_args(s)
    run_script(args["port0"], args["script-path"])
end

function run_script(port0, script_path)
    np = get_size(port0)
    for rank in 0:np-1
        @info "Sending script path to part $(rank+1)/$(np)"
        sock = Sockets.connect(port0 + rank)
        println(sock, action_to_string(RunScriptAction()))
        println(sock, abspath(script_path))
    end
end

""" Fetch the number of MPI processes (MPI.Comm_size) """
function get_size(port0=DEFAULT_PORT0)
    sock = Sockets.connect(port0)
    println(sock, "getsize")
    return parse(Int, readline(sock))
end

function kill_servers(port0=DEFAULT_PORT0)
    np = get_size(port0)
    @info "Sending kill signal to part $(rank+1)/$(np)"
    for rank in 0:np-1
        sock = Sockets.connect(port0 + rank)
        println(sock, "kill")
    end
end