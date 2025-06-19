include("biased_mc.jl")

struct Compression{A<:Action,T<:AbstractFloat} <: AriannaAlgorithm
    barostats::Vector{A}        # Vector of independent barostats (one for each system)
    rate::T                     # Compression rate
end

function Compression(chains; rate=missing, dependencies=missing, extras...)
    @assert length(dependencies) == 1
    @assert isa(dependencies[1], Metropolis)
    metropolis = dependencies[1]
    barostats = first.(map(pool -> getfield.(filter(move -> isa(move.action, Barostat), pool), :action), metropolis.pools))
    return Compression(barostats, rate)
end

function Arianna.make_step!(::Simulation, algorithm::Compression)
    for barostat in algorithm.barostats
        barostat.P += algorithm.rate
    end
end

###############################################################################
# CALLBACKS

struct StorePressure <: CallbackAlgorithm
    paths::Vector{String}
    files::Vector{IOStream}
    store_first::Bool
    store_last::Bool

    function StorePressure(chains, path; store_first::Bool=true, store_last::Bool=false)
        dirs = joinpath.(path, "trajectories", ["$c" for c in eachindex(chains)])
        mkpath.(dirs)
        paths = joinpath.(dirs, "pressure.dat")
        files = Vector{IOStream}(undef, length(paths))
        try
            files = open.(paths, "w")
        finally
            close.(files)
        end
        return new(paths, files, store_first, store_last)
    end

end

function StorePressure(chains; path=missing, store_first=true, store_last=false, extras...)
    return StorePressure(chains, path, store_first=store_first, store_last=store_last)
end

function Arianna.make_step!(simulation::Simulation, algorithm::StorePressure)
    metropolis_instances = filter(x -> isa(x, Metropolis), simulation.algorithms)
    @assert length(metropolis_instances) == 1
    metropolis = metropolis_instances[1]
    barostats = first.(map(pool -> getfield.(filter(move -> isa(move.action, Barostat), pool), :action), metropolis.pools))
    for c in eachindex(simulation.chains)
        println(algorithm.files[c], "$(simulation.t) $(barostats[c].P)")
        flush(algorithm.files[c])
    end
end

mutable struct StorePackingFraction <: CallbackAlgorithm
    paths::Vector{String}
    files::Vector{IOStream}
    store_first::Bool
    store_last::Bool
    ϕ::Float64
    n::Int
    Δm::Int

    function StorePackingFraction(chains, path; store_first::Bool=true, store_last::Bool=false, Δm::Int=1)
        dirs = joinpath.(path, "trajectories", ["$c" for c in eachindex(chains)])
        mkpath.(dirs)
        paths = joinpath.(dirs, "phi.dat")
        files = Vector{IOStream}(undef, length(paths))
        try
            files = open.(paths, "w")
        finally
            close.(files)
        end
        ϕ = 0.0
        n = 0
        return new(paths, files, store_first, store_last, ϕ, n, Δm)
    end

end

function StorePackingFraction(chains; path=missing, Δm=1, store_first=true, store_last=false, extras...)
    return StorePackingFraction(chains, path, store_first=store_first, store_last=store_last, Δm=Δm)
end

function Arianna.make_step!(simulation::Simulation, algorithm::StorePackingFraction)
    for c in eachindex(simulation.chains)
        system = simulation.chains[c]
        algorithm.ϕ += system.density * π * sum(system.species .^ 2) / (4 * system.N)
        algorithm.n += 1
        if simulation.t % algorithm.Δm == 0
            ϕ = algorithm.ϕ / algorithm.n
            println(algorithm.files[c], "$(simulation.t) $ϕ")
            flush(algorithm.files[c])
            algorithm.ϕ = 0.0
            algorithm.n = 0
        end
    end
end

nothing