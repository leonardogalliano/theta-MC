include("compression.jl")

using Enzyme, Optimisers, Transducers

abstract type Potential end

function loss(X, s, box, ::Potential) end

struct FIRE{T<:AbstractFloat} <: Optimisers.AbstractRule
    dt_start::T
    α_start::T
    dt_max::T
    f_inc::T
    f_dec::T
    α_dec::T
    n_min::Int
end

FIRE(; dt_start=0.01, α_start=0.1, dt_max=10 * dt_start, f_inc=1.1, f_dec=0.5, α_dec=0.99, n_min=5) = FIRE(dt_start, α_start, dt_max, f_inc, f_dec, α_dec, n_min)

mutable struct FIREState{V<:AbstractArray, T<:AbstractFloat}
    F::V
    V::V
    dt::T
    α::T
    cnt_positive::Int
end

function Optimisers.init(o::FIRE{T}, X::V) where {T<:AbstractFloat, V<:AbstractArray}
    dt = o.dt_start
    α = o.α_start
    return FIREState{V, T}(zero(X), zero(X), dt, α, 0)
end

function Optimisers.apply!(o::FIRE, state, X, dX)
    state.F = dX
    state.V = state.V .+ state.dt .* state.F
    P = dot(state.V, state.F)

    if P > 0
        state.cnt_positive += 1
        if state.cnt_positive > o.n_min
            state.dt = min(state.dt * o.f_inc, o.dt_max)
            state.α = state.α * o.α_dec
        end
    else
        state.dt = state.dt * o.f_dec
        state.α = o.α_start
        state.V = zero(state.V)
        state.cnt_positive = 0
    end

    state.V = (1 - state.α) .* state.V .+ state.α .* (state.F .* (norm(state.V) / norm(state.F)))

    X = X .+ state.dt .* state.V

    return state, X
end

struct MinimisePotential{R,P<:Potential,V,S,ST,C} <: AriannaAlgorithm
    rule::R
    potential::P
    dXs::V
    dss::S
    state_trees::ST
    collecter::C

    function MinimisePotential(chains, rule::R, potential::P; parallel=false) where {R,P<:Potential}
        dXs = map(system -> zero.(system.position), chains)
        dss = map(system -> zero.(system.species), chains)
        state_trees = map(system -> Optimisers.setup(rule, system.position), chains)
        collecter = parallel ? Transducers.tcollect : collect
        return new{R,P,typeof(dXs),typeof(dss),typeof(state_trees),typeof(collecter)}(rule, potential, dXs, dss, state_trees, collecter)
    end

end

function MinimisePotential(chains; rule=missing, potential=missing, extras...)
    return MinimisePotential(chains, rule, potential)
end

function Arianna.make_step!(simulation::Simulation, algorithm::MinimisePotential)
    algorithm.collecter(
        eachindex(simulation.chains) |> Map(c -> begin
            dX = algorithm.dXs[c]
            ds = algorithm.dss[c]
            state_tree = algorithm.state_trees[c]
            X = simulation.chains[c].position
            sizes = simulation.chains[c].species
            box = simulation.chains[c].box
            dX .= map.(zero, dX)
            ds .= zero(ds)
            _, Θ = Enzyme.autodiff(ReverseWithPrimal, loss, Duplicated(X, dX), Duplicated(sizes, ds), Const(box), Const(algorithm.potential))
            state_tree, simulation.chains[c].position = Optimisers.update(state_tree, simulation.chains[c].position, dX)
        end)
    )
    return nothing
end

struct ThetaPotential <: Potential end

loss(X, s, box, ::ThetaPotential) = global_theta_shell(X, s, box)

struct HarmonicPotential <: Potential end

function loss(X, s, box, ::HarmonicPotential)
    H = zero(eltype(box))
    for i in eachindex(X)
        for j in i+1:length(X)
            rij = norm(nearest_image_distance(X[i], X[j], box))
            σij = (s[i] + s[j]) / 2
            if rij < σij
                H += (1 - rij / σij)^2 / 2
            end
        end
    end
    return H
end

struct StoreActivity <: CallbackAlgorithm
    paths::Vector{String}
    files::Vector{IOStream}
    store_first::Bool
    store_last::Bool

    function StoreActivity(chains, path; store_first::Bool=true, store_last::Bool=false)
        dirs = joinpath.(path, "trajectories", ["$c" for c in eachindex(chains)])
        mkpath.(dirs)
        paths = joinpath.(dirs, "activity.dat")
        files = Vector{IOStream}(undef, length(paths))
        try
            files = open.(paths, "w")
        finally
            close.(files)
        end
        return new(paths, files, store_first, store_last)
    end

end

function StoreActivity(chains; path=missing, store_first=true, store_last=false, extras...)
    return StoreActivity(chains, path, store_first=store_first, store_last=store_last)
end

function Arianna.make_step!(simulation::Simulation, algorithm::StoreActivity)
    for c in eachindex(simulation.chains)
        system = simulation.chains[c]
        distances = [norm(nearest_image_distance(xi, xj, system.box)) for xi in system.position, xj in system.position]
        maxdistances = [(si + sj) / 2 for si in system.species, sj in system.species]
        contacts = 0 .< distances .≤ maxdistances
        activity = sum(map(!iszero, sum(contacts, dims=2))) / system.N
        println(algorithm.files[c], "$(simulation.t) $activity")
        flush(algorithm.files[c])
    end
end



nothing