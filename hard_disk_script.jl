using Arianna
using Arianna.PolicyGuided
using ParticlesMC
using StaticArrays
using Distributions
using Random
using ComponentArrays
using ArgParse

include("src/compression.jl")

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
    pressure = args["pressure"]
    compression_rate = args["compression_rate"]

    if isempty(args["init_file"])
        N = args["N"]
        NA = ceil(Int, N * args["concentration"])
        NB = N - NA
        M = args["nsim"]
        d = 2
        temperature = args["temperature"]
        density = args["density"]
        box = @SVector fill(typeof(temperature)((N / density)^(1 / d)), d)
        position = [[box .* @SVector rand(rng, d) for i in 1:N] for m in 1:M]
        species = [shuffle!(rng, vcat(ones(NA), 1.4 * ones(NB))) for _ in 1:M]
        chains = [System(position[m], species[m], density, temperature, HardCore(); list_type=LinkedList) for m in 1:M]
    else
        args["model"] = "HardCore"
        delete!(args, "density")
        delete!(args, "temperature")
        delete!(args, "nsim")
        chains = load_chains(args["init_file"]; args=args, verbose=args["verbose"])
        N = length(chains[1].position)
        M = length(chains)
        d = chains[1].d
        temperature = chains[1].temperature
        density = chains[1].density
        box = chains[1].box
    end

    # Simulation parameters
    steps = args["steps"]
    burn = 0
    block = append!([0], [2^n for n in 0:floor(Int, log2(args["steps"] / args["nblocks"]))])
    sampletimes = build_schedule(steps, burn, block)
    path = joinpath(args["out_path"], "NPT", "P$pressure", "rate$compression_rate", "N$N", "M$M", "steps$steps", "seed$seed")
    # Remove overlaps from initial conditions
    displacement_policy = SimpleGaussian()
    displacement_parameters = ComponentArray(σ=args["delta_x"])
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
    displacement_parameters = ComponentArray(σ=args["delta_x"])
    barostat_policy = SimpleGaussian()
    barostat_parameters = ComponentArray(σ=args["delta_V"])
    pool = (
        Move(Displacement(0, zero(box)), displacement_policy, displacement_parameters, 1 - 1 / N),
        Move(Barostat(pressure, 0.0), barostat_policy, barostat_parameters, 1 / N),
    )

    compression_algorithm = compression_rate > 0 ? (algorithm=Compression, dependencies=(Metropolis,), rate=compression_rate) : (algorithm=Compression, dependencies=(Metropolis,), rate=compression_rate, scheduler=[steps])
    phi_algoritm = args["time_average_phi"] > 0 ? (algorithm=StorePackingFraction, Δm=args["time_average_phi"]) : (algorithm=StorePackingFraction, scheduler=sampletimes)

    algorithm_list = (
        (algorithm=Metropolis, pool=pool, seed=seed, parallel=true, sweepstep=N),
        compression_algorithm,
        (algorithm=StoreCallbacks, callbacks=(callback_acceptance,callback_overlaps), scheduler=sampletimes),
        (algorithm=StoreTrajectories, scheduler=sampletimes, fmt=XYZ()),
        (algorithm=StoreLastFrames, scheduler=[steps], fmt=XYZ()),
        (algorithm=StoreTheta, scheduler=sampletimes),
        (algorithm=StorePressure, scheduler=sampletimes),
        phi_algoritm,
        (algorithm=PrintTimeSteps, scheduler=build_schedule(steps, burn, steps ÷ 10)),
    )
    simulation = Simulation(chains, algorithm_list, steps; path=path, verbose=args["verbose"])
    run!(simulation)
    args["verbose"] && println("Overlaps: $(map(system -> check_overlaps(system), chains))")

    # Normalise densities
    if args["do_NVT"]
        args["verbose"] && println("Normalising densitities...")
        densities = map(system -> system.N / prod(system.box), chains)
        target_density = minimum(densities)
        map(system -> affine_transformation!(system, target_density), chains)
        args["verbose"] && println("Overlaps: $(map(system -> check_overlaps(system), chains))")
        pool = (
            Move(Displacement(0, zero(box)), displacement_policy, displacement_parameters, 1.0),
        )
        phi = target_density * π * sum(chains[1].species .^ 2) / (4 * N)
        path = joinpath(args["out_path"], "NVT", "phi$phi", "N$N", "M$M", "steps$steps", "seed$seed")
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
        default = 0.65
        "--density", "-D"
        help = "Initial density"
        arg_type = Float64
        default = 0.01
        "--temperature", "-T"
        help = "Temperature"
        arg_type = Float64
        default = 1.0
        "--delta_x"
        help = "Amplitude of displacement"
        arg_type = Float64
        default = 0.2
        "--delta_V"
        help = "Amplitude of volume change"
        arg_type = Float64
        default = 1.0
        "--compression_rate"
        help = "Compression rate in NPT simulation"
        arg_type = Float64
        default = 0.0
        "--init_file"
        help = "Path to the initial configurations (overwrites everything)"
        arg_type = String
        default = ""
        "--out_path"
        help = "Output path"
        arg_type = String
        default = "data/HardDisks/"
        "--nblocks"
        help = "Number of log2 blocks"
        arg_type = Int
        default = 1
        "--time_average_phi"
        help = "If positive, store a time averaged packing fraction every Δm steps"
        arg_type = Int
        default = -1
        "--do_NVT"
        help = "Run extra NVT simulation after NPT to fix volume"
        action = :store_true
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