using Arianna
using ParticlesMC
using StaticArrays
using Random
using ComponentArrays
using BenchmarkTools

include("src/biased_mc.jl")

seed = 42
rng = Xoshiro(seed)
path = "data/HardDisks"
chains = load_chains(path; args=Dict("temperature" => [1.0], "model" => ["HardCore"]), verbose=true)
N = length(chains[1].position)
displacement_policy = SimpleGaussian()
displacement_parameters = ComponentArray(σ=0.2)
pool = (
    Move(Displacement(0, zero(chains[1].box)), displacement_policy, displacement_parameters, 1.0),
)
steps = 10^6
burn = 0
block = [0, 1, 2, 4, 8, 16, 32, 64, 128]
# burn = 10^3
# block = [0, burn]

# λ = 0.0
# λ = 1e2
# λ = 5e2
λ = 1e3
# λ = 2.01e3
# λ = 3e3
# λ = 1e4
# steps_per_bias = 10
steps_per_bias = 100
biastimes = build_schedule(steps, burn, steps_per_bias)
sampletimes = build_schedule(steps, burn, block)
sampletimes_bias = build_schedule(steps, burn, steps_per_bias)
path = "data/Theta/lambda$λ/n$steps_per_bias"
algorithm_list = (
    (algorithm=Metropolis, pool=pool, seed=seed, parallel=true, sweepstep=N),
    (algorithm=BiasedMonteCarlo, bias=ThetaBias(λ), seed=seed, parallel=true, scheduler=biastimes),
    (algorithm=StoreCallbacks, callbacks=(callback_acceptance,), scheduler=sampletimes),
    (algorithm=StoreCallbacks, callbacks=(callback_bias_acceptance,), scheduler=sampletimes_bias),
    (algorithm=StoreTrajectories, scheduler=sampletimes, fmt=XYZ()),
    (algorithm=StoreTheta, scheduler=biastimes),
    (algorithm=StoreLastFrames, scheduler=[steps], fmt=XYZ()),
    (algorithm=PrintTimeSteps, scheduler=build_schedule(steps, burn, steps ÷ 10)),
)
simulation = Simulation(chains, algorithm_list, steps; path=path, verbose=true)

run!(simulation)
