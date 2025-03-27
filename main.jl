using Arianna
using ParticlesMC
using StaticArrays
using Random
using ComponentArrays
using ArgParse

include("src/biased_mc.jl")

function main(args)

    verbose = args["verbose"]
    if verbose
        println("Parsed args:")
        for (arg, val) in args
            println("  $arg  =>  $val")
        end
    end

    seed = args["seed"]
    init_path = args["init_file"]
    args["model"] = "HardCore"
    chains = load_chains(init_path; args=args, verbose=verbose)
    N = length(chains[1].position)
    displacement_policy = SimpleGaussian()
    displacement_parameters = ComponentArray(σ=0.2)
    pool = (
        Move(Displacement(0, zero(chains[1].box)), displacement_policy, displacement_parameters, 1.0),
    )
    steps = args["steps"]
    burn = 0
    block = append!([0], [2^n for n in 0:floor(Int, log2(args["steps"] / args["nblocks"]))])
    λ = args["lambda"]
    steps_per_bias = args["reversible_steps"]
    biastimes = build_schedule(steps, burn, steps_per_bias)
    sampletimes = build_schedule(steps, burn, block)
    sampletimes_bias = build_schedule(steps, burn, steps_per_bias)
    path = "data/Theta/lambda$λ/n$steps_per_bias/N$N/M$(length(chains))/steps$steps/seed$seed"
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

end

function parse_commandline()
    parser = ArgParseSettings()
    @add_arg_table! parser begin
        "init_file"
        help = "Path to the initial configuration file (accepts multiple files)"
        arg_type = String
        required = true
        "steps"
        help = "Number of steps"
        arg_type = Int
        required = true
        "--lambda"
        help = "Biased MC lambda"
        arg_type = Float64
        default = 0.0
        "--reversible_steps", "-n"
        help = "Number of standard MC steps between biased steps"
        arg_type = Int
        default = 1
        "--nsim"
        help = "Number of chains per configuration file"
        arg_type = Int
        default = 1
        "--temperature", "-T"
        help = "Ovveride the temperature in the configuration file"
        arg_type = Float64
        "--density", "-D"
        help = "Ovveride the density in the configuration file (affine transformation)"
        "--nblocks"
        help = "Number of log2 blocks"
        arg_type = Int
        default = 1
        arg_type = Float64
        "--verbose", "-v"
        help = "verbose"
        action = :store_true
        "--seed"
        help = "Random number seed"
        arg_type = Int
        default = 1
    end

    return parse_args(parser)

end

if abspath(PROGRAM_FILE) == @__FILE__
    args = parse_commandline()
    main(args)
end

nothing