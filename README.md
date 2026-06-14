# MPIDaemon

`MPIDaemon` helps you develop MPI applications with Julia without recompiling your whole codebase at each execution. The code is heavily inspired (or directly copied) by [DaemonMode](https://github.com/dmolina/DaemonMode.jl).

## Installation

Install it in your base environment, or add it to your project:

```julia
pkg> add https://github.com/bmxam/MPIDaemon.jl
```

## How to use it

1. Write a (driver) script you want to execute in parallel, see for instance `example/script.jl`.
2. Open a terminal and run `mpirun -n 2 julia -e 'import MPIDaemon: create_servers; create_servers()'`. Each MPI process will create a TCP server waiting for instructions (typically, "execute this script").
3. Open a new terminal and ask the servers to execute the script: `julia -e 'import MPIDaemon: run_script; run_script()' --script-path script.jl`. The output is printed in the "mpi terminal".
4. Modify the `script.jl` file and send it again to the servers.

## Example

Checkout the three files in the `example` folder:

1. Run `mpirun -n 2 julia --project example/create-servers.jl`
2. In a new terminal, run `julia --project example/send-to-servers.jl example/script.jl` : on the mpi terminal, you should see each rank printing the sum of `rank + 1`.

## Limitations

- `MPI.Init()` is called by `MPIDaemon` when creating the servers, so your parallel script should not call it.
- Don't call `MPI.Finalize()` in your script, otherwise the server won't be able to run any new MPI call.
- For now, the MPI comm is necessarily `MPI.COMM_WORLD`; but it could easily improved if necessary.

## Remarks

- Instead of deploying servers and so on, we could implement some kind of "file watcher" : each MPI process has a `while` loop checking if some defined file changes and reacts to some change. But the TCP solution is somewhat more elegant.
- the client is written in julia for convenience, but could be implemented in any other language
