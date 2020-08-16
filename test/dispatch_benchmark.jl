# Give me benchmarks:
# The dispatching is zero-cost like a normal struct:

using VarStructs

@var struct A end;
@var struct B end;

dispacth_varstruct(x::A) = 1

dispacth_varstruct(x::B) = 2

using BenchmarkTools
@btime dispath_varstruct(x) setup = (x = rand() < 0.5 ? A() : B())
# 0.001 ns (0 allocations: 0 bytes)
