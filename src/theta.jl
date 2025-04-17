using Arianna, ParticlesMC, StaticArrays, LinearAlgebra, Delaunator, Statistics

###############################################################################
# DEFINITION

theta(a, b, c) = acos((b^2 + c^2 - a^2) / (2 * b * c))

###############################################################################
# VORONOI

function manual_pbc(X, sizes, L; border=2.0)
    lb = findall(x -> x[1] ≤ border, X)
    rb = findall(x -> x[1] ≥ L - border, X)
    bb = findall(x -> x[2] ≤ border, X)
    tb = findall(x -> x[2] ≥ L - border, X)
    blb = findall(x -> x[1] ≤ border && x[2] ≤ border, X)
    brb = findall(x -> x[1] ≥ L - border && x[2] ≤ border, X)
    tlb = findall(x -> x[1] ≤ border && x[2] ≥ L - border, X)
    trb = findall(x -> x[1] ≥ L - border && x[2] ≥ L - border, X)
    Xhpbc = copy(X)
    shpbc = copy(sizes)
    append!(Xhpbc, map(x -> (x[1] + L, x[2]), X[lb]))
    append!(Xhpbc, map(x -> (x[1] - L, x[2]), X[rb]))
    append!(Xhpbc, map(x -> (x[1], x[2] + L), X[bb]))
    append!(Xhpbc, map(x -> (x[1], x[2] - L), X[tb]))
    append!(Xhpbc, map(x -> (x[1] + L, x[2] + L), X[blb]))
    append!(Xhpbc, map(x -> (x[1] - L, x[2] + L), X[brb]))
    append!(Xhpbc, map(x -> (x[1] + L, x[2] - L), X[tlb]))
    append!(Xhpbc, map(x -> (x[1] - L, x[2] - L), X[trb]))
    append!(shpbc, sizes[lb])
    append!(shpbc, sizes[rb])
    append!(shpbc, sizes[bb])
    append!(shpbc, sizes[tb])
    append!(shpbc, sizes[blb])
    append!(shpbc, sizes[brb])
    append!(shpbc, sizes[tlb])
    append!(shpbc, sizes[trb])
    return Xhpbc, shpbc
end

function get_theta_voronoi(X::Vector{Tuple{T,T}}, sizes, triangulation, o) where {T<:AbstractFloat}
    ∂o = collect(neighbors(triangulation, o))
    θo = zero(T)
    n = 0
    for i in ∂o
        ∂i = collect(neighbors(triangulation, i))
        for j in intersect(∂o, ∂i)
            if j < i
                θ1 = theta(norm(X[i] .- X[j]), norm(X[o] .- X[i]), norm(X[o] .- X[j]))
                θ2 = theta((sizes[i] + sizes[j]) / 2, (sizes[o] + sizes[i]) / 2, (sizes[o] + sizes[j]) / 2)
                θo += abs(θ1 - θ2)
                n += 1
            end
        end
    end
    return θo / n
end

function get_theta_voronoi(system; border=2.0)
    box = system.box
    sizes = system.species
    X = map(x -> getfield(fold_back(x, box), :data), system.position)
    Xhpbc, shpbc = manual_pbc(X, sizes, box[1]; border=border)
    triangulation = triangulate(Xhpbc)
    return map(i -> get_theta_voronoi(Xhpbc, shpbc, triangulation, i), eachindex(X))
end

###############################################################################
# CALLBACK

abstract type CallbackAlgorithm <: AriannaAlgorithm end

struct StoreTheta <: CallbackAlgorithm
    paths::Vector{String}
    files::Vector{IOStream}
    store_first::Bool
    store_last::Bool

    function StoreTheta(chains, path; store_first::Bool=true, store_last::Bool=false)
        dirs = joinpath.(path, "trajectories", ["$c" for c in eachindex(chains)])
        mkpath.(dirs)
        paths = joinpath.(dirs, "theta.dat")
        files = Vector{IOStream}(undef, length(paths))
        try
            files = open.(paths, "w")
        finally
            close.(files)
        end
        return new(paths, files, store_first, store_last)
    end

end

function StoreTheta(chains; path=missing, store_first=true, store_last=false, extras...)
    return StoreTheta(chains, path, store_first=store_first, store_last=store_last)
end

function Arianna.initialise(algorithm::CallbackAlgorithm, simulation::Simulation)
    simulation.verbose && println("Opening " * replace(string(typeof(algorithm)), r"\{.*" => "") * " files...")
    algorithm.files .= open.(algorithm.paths, "w")
    algorithm.store_first && Arianna.make_step!(simulation, algorithm)
    return nothing
end

function Arianna.make_step!(simulation::Simulation, algorithm::StoreTheta)
    for c in eachindex(simulation.chains)
        theta = mean(get_theta_voronoi(simulation.chains[c]))
        println(algorithm.files[c], "$(simulation.t) $theta")
        flush(algorithm.files[c])
    end
end

function Arianna.finalise(algorithm::CallbackAlgorithm, simulation::Simulation)
    simulation.verbose && println("Closing " * replace(string(typeof(algorithm)), r"\{.*" => "") * " files...")
    close.(algorithm.files)
    return nothing
end
