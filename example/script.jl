using MPI
comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
np = MPI.Comm_size(comm)
total = MPI.Allreduce(rank + 1, MPI.SUM, comm)
expected = np * (np + 1) / 2
@show total, expected