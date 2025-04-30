using Plots, Measures, DelimitedFiles, Statistics, StatsBase, LaTeXStrings, BenchmarkTools

include("src/optimisation.jl")

seed = 42
verbose = true
rng = Xoshiro(seed)
# init_path = "data/CM/HardDisks/NVT/phi0.7976147813637013/N200/M8/steps10000000/seed1/trajectories/1/lastframe.xyz"
init_path = "data/CM/HardDisks/NPT/P20.0/rate2.5e-6/N200/M8/steps200000000/seed1/trajectories/1/lastframe.xyz"
chains = load_chains(init_path; args=Dict("temperature" => [1.0], "model" => ["HardCore"]), verbose=true)

theta_lr = 5e-2
#harmonic_lr = 1.2
harmonic_lr = 0.001

theta_rule = Optimisers.Descent(theta_lr)
# harmonic_rule = Optimisers.Adam(harmonic_lr)
harmonic_rule = FIRE(dt=harmonic_lr)

theta_steps = 2000
harmonic_steps = 5000
iterations = 100
theta_scheduler = vcat([k*(theta_steps+harmonic_steps)+1:(k+1)theta_steps+k*harmonic_steps for k in 0:iterations-1]..., [(iterations)theta_steps + (iterations - 1) * harmonic_steps])
harmonic_scheduler = vcat([(k+1)*theta_steps+k*harmonic_steps+1:(k+1)*(theta_steps+harmonic_steps) for k in 0:iterations-1]...)

steps = harmonic_scheduler[end]
burn = 0
nblocks = 10
block = append!([0], [2^n for n in 0:floor(Int, log2(steps / nblocks))])
sampletimes = build_schedule(steps, burn, block)
# path = joinpath("data", "Gradient", "lr_$(theta_lr)_$(harmonic_lr)", "steps$steps", "seed$seed")
path = joinpath("data", "Gradient")

algorithm_list = (
    (algorithm=MinimisePotential, rule=theta_rule, potential=ThetaPotential(), seed=seed, parallel=false, scheduler=theta_scheduler),
    (algorithm=MinimisePotential, rule=harmonic_rule, potential=HarmonicPotential(), seed=seed, parallel=false, scheduler=harmonic_scheduler),
    (algorithm=StoreCallbacks, callbacks=(callback_overlaps,), scheduler=sampletimes),
    (algorithm=StoreTrajectories, scheduler=sampletimes, fmt=ParticlesMC.XYZ()),
    (algorithm=StoreLastFrames, scheduler=[steps], fmt=ParticlesMC.XYZ()),
    (algorithm=StoreTheta, scheduler=sampletimes),
    (algorithm=StoreActivity, scheduler=sampletimes),
    (algorithm=PrintTimeSteps, scheduler=build_schedule(steps, burn, steps ÷ 10)),
)
simulation = Simulation(chains, algorithm_list, steps; path=path, verbose=verbose)

run!(simulation)