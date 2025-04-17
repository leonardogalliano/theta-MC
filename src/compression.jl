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

struct StorePackingFraction <: CallbackAlgorithm
    paths::Vector{String}
    files::Vector{IOStream}
    store_first::Bool
    store_last::Bool

    function StorePackingFraction(chains, path; store_first::Bool=true, store_last::Bool=false)
        dirs = joinpath.(path, "trajectories", ["$c" for c in eachindex(chains)])
        mkpath.(dirs)
        paths = joinpath.(dirs, "phi.dat")
        files = Vector{IOStream}(undef, length(paths))
        try
            files = open.(paths, "w")
        finally
            close.(files)
        end
        return new(paths, files, store_first, store_last)
    end

end

function StorePackingFraction(chains; path=missing, store_first=true, store_last=false, extras...)
    return StorePackingFraction(chains, path, store_first=store_first, store_last=store_last)
end

function Arianna.make_step!(simulation::Simulation, algorithm::StorePackingFraction)
    for c in eachindex(simulation.chains)
        system = simulation.chains[c]
        phi = system.density * π * sum(system.species .^ 2) / (4 * system.N)
        println(algorithm.files[c], "$(simulation.t) $phi")
        flush(algorithm.files[c])
    end
end

nothing