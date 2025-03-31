using Arianna
using Arianna.PolicyGuided
using ParticlesMC
using StaticArrays
using Distributions
using Random
using ComponentArrays
using ArgParse

function affine_transformation!(system, density)
    λ = (system.density / density) ^ (1 / system.d)
    system.density = density
    system.position .= system.position .* λ
    system.box = system.box .* λ
    list_type = getfield(parentmodule(typeof(system.cell_list)), nameof(typeof(system.cell_list)))
    system.cell_list = list_type(system.box, system.cell_list.rcut, system.N)
    ParticlesMC.build_cell_list!(system, system.cell_list)
    return nothing
end

function main(args)

    if args["verbose"]
        println("Parsed args:")
        for (arg, val) in args
            println("  $arg  =>  $val")
        end
    end

    # Create chains
    seed = args["seed"]
    rng = Xoshiro(seed)
    N = args["N"]
    # NA = N ÷ 2
    NA = ceil(Int, N * args["concentration"])
    NB = N - NA
    M = args["nsim"]
    d = 2
    temperature = args["temperature"]
    density = args["density"]
    pressure = args["pressure"]
    box = @SVector fill(typeof(temperature)((N / density)^(1 / d)), d)
    position = [[box .* @SVector rand(rng, d) for i in 1:N] for m in 1:M]
    species = [shuffle!(rng, vcat(ones(NA), 1.4 * ones(NB))) for _ in 1:M]
    chains = [System(position[m], species[m], density, temperature, HardCore(); list_type=LinkedList) for m in 1:M]

    # Simulation parameters
    steps = args["steps"]
    burn = 0
    block = append!([0], [2^n for n in 0:floor(Int, log2(args["steps"] / args["nblocks"]))])
    sampletimes = build_schedule(steps, burn, block)
    path = "data/HardDisks/NPT/P$pressure/N$N/M$M/steps$steps/seed$seed"

    # Remove overlaps from initial conditions
    displacement_policy = SimpleGaussian()
    displacement_parameters = ComponentArray(σ=0.2)
    pool = (
        Move(Displacement(0, zero(box)), displacement_policy, displacement_parameters, 1.0),
    )
    cnt = 0
    while !all(map(system -> !check_overlaps(system), chains))
        args["verbose"] && println("\nRemoving overlaps...")
        algorithm_list = (
            (algorithm=Metropolis, pool=pool, seed=seed+cnt, parallel=true, sweepstep=N),
            (algorithm=PrintTimeSteps, scheduler=build_schedule(steps, burn, steps ÷ 10)),
        )
        simulation = Simulation(chains, algorithm_list, steps; path=path, verbose=args["verbose"])
        run!(simulation)
        cnt +=1
        density = density * 0.8
        map(system -> affine_transformation!(system, density), chains)
        args["verbose"] && println("density = $density")
        args["verbose"] && println("Overlaps: $(map(system -> check_overlaps(system), chains))")
    end

    # Run NPT
    displacement_policy = SimpleGaussian()
    displacement_parameters = ComponentArray(σ=0.2)
    barostat_policy = SimpleGaussian()
    barostat_parameters = ComponentArray(σ=1.0)
    pool = (
        Move(Displacement(0, zero(box)), displacement_policy, displacement_parameters, 1 - 1 / N),
        Move(Barostat(pressure, 0.0), barostat_policy, barostat_parameters, 1 / N),
    )

    ## PGMC parameters
    #optimisers = (BLAPG(1e-5, 1e-4), Static())
    # pgmc_start = 10^4
    # estimator_scheduler = build_schedule(steps, pgmc_start, 1)
    # learner_scheduler = build_schedule(steps, pgmc_start, 10)

    algorithm_list = (
        (algorithm=Metropolis, pool=pool, seed=seed, parallel=true, sweepstep=N),
        # (algorithm=PolicyGradientEstimator, dependencies=(Metropolis,), optimisers=optimisers, q_batch_size=20, parallel=true, scheduler=estimator_scheduler),
        # (algorithm=PolicyGradientUpdate, dependencies=(PolicyGradientEstimator,), scheduler=learner_scheduler),
        (algorithm=StoreCallbacks, callbacks=(callback_acceptance,callback_overlaps), scheduler=sampletimes),
        (algorithm=StoreTrajectories, scheduler=sampletimes, fmt=XYZ()),
        (algorithm=StoreLastFrames, scheduler=[steps], fmt=XYZ()),
        # (algorithm=StoreParameters, dependencies=(Metropolis,), scheduler=sampletimes),
        (algorithm=PrintTimeSteps, scheduler=build_schedule(steps, burn, steps ÷ 10)),
    )
    simulation = Simulation(chains, algorithm_list, steps; path=path, verbose=args["verbose"])
    run!(simulation)
    args["verbose"] && println("Overlaps: $(map(system -> check_overlaps(system), chains))")

    # Normalise densities
    args["verbose"] && println("Normalising densitities...")
    densities = map(system -> system.N / prod(system.box), chains)
    target_density = minimum(densities)
    map(system -> affine_transformation!(system, target_density), chains)
    args["verbose"] && println("Overlaps: $(map(system -> check_overlaps(system), chains))")
    pool = (
        Move(Displacement(0, zero(box)), displacement_policy, displacement_parameters, 1.0),
    )
    phi = target_density * π * sum(species[1] .^ 2) / (4 * N)
    path = "data/HardDisks/NVT/phi$phi/N$N/M$M/steps$steps/seed$seed"
    algorithm_list = (
        (algorithm=Metropolis, pool=pool, seed=seed, parallel=true, sweepstep=N),
        (algorithm=StoreCallbacks, callbacks=(callback_acceptance, callback_overlaps), scheduler=sampletimes),
        (algorithm=StoreTrajectories, scheduler=sampletimes, fmt=XYZ()),
        (algorithm=StoreLastFrames, scheduler=[steps], fmt=XYZ()),
        (algorithm=PrintTimeSteps, scheduler=build_schedule(steps, burn, steps ÷ 10)),
    )
    simulation = Simulation(chains, algorithm_list, steps; path=path, verbose=args["verbose"])
    run!(simulation)
    args["verbose"] && println("Overlaps: $(map(system -> check_overlaps(system), chains))")

end

function parse_commandline()
    parser = ArgParseSettings()
    @add_arg_table! parser begin
        "steps"
        help = "Number of steps"
        arg_type = Int
        required = true
        "N"
        help = "number of particles"
        arg_type = Int
        required = true   
        "pressure"
        help = "Pressure"
        arg_type = Float64
        required = true
        "--nsim", "-M"
        help = "Number of parallel chains"
        arg_type = Int
        default = 1
        "--concentration", "-x"
        help = "Concentration of small particles"
        arg_type = Float64
        default = 1.0
        "--density", "-D"
        help = "Initial density"
        arg_type = Float64
        default = 0.01
        "--temperature", "-T"
        help = "Temperature"
        arg_type = Float64
        default = 1.0
        "--nblocks"
        help = "Number of log2 blocks"
        arg_type = Int
        default = 1
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