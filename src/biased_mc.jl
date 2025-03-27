include("theta.jl")

using Random, Transducers

abstract type Bias end

function log_bias(::AriannaSystem, ::Bias) end

struct BiasedMonteCarlo{S,T<:AbstractFloat,B<:Bias,R<:AbstractRNG,C<:Function} <: AriannaAlgorithm
    memories::Vector{S}         # Copy of chains to revert to in case of rejection
    log_bias_cache::Vector{T}   # Cache for the log_bias of each chain
    bias::B                     # Type of bias
    seed::Int                   # Random number seed
    rngs::Vector{R}             # Vector of random number generators
    parallel::Bool              # Flag to parallelise over different threads
    collecter::C                # Transducer to collect results from parallelised loops
    total_calls::Vector{Int}    # Number of calls to the algorithm per chain
    accepted_calls::Vector{Int} # Number of accepted calls to the algorithm per chain

    function BiasedMonteCarlo(
        chains::Vector{S},
        bias::B;
        seed::Int=1,
        R::DataType=Xoshiro,
        parallel::Bool=false
    ) where {S<:AriannaSystem,B<:Bias}   
        # Copy chains
        memories = deepcopy(chains)
        # Build initial cache
        cache = map(system -> log_bias(system, bias), chains)
        # Handle randomness
        seeds = [seed + c - 1 for c in eachindex(chains)]
        rngs = [R(s) for s in seeds]
        # Handle parallelism
        collecter = parallel ? Transducers.tcollect : collect
        # Initialise acceptance counters
        total_calls = zeros(Int, length(chains))
        accepted_calls = zeros(Int, length(chains))
        return new{S,eltype(cache),B,R,typeof(collecter)}(memories, cache, bias, seed, rngs, parallel, collecter, total_calls, accepted_calls)
    end

end

function BiasedMonteCarlo(chains; bias=missing, seed=1, R=Xoshiro, parallel=false, extras...)
    return BiasedMonteCarlo(chains, bias; seed=seed, R=R, parallel=parallel)
end

function Arianna.make_step!(simulation::Simulation, algorithm::BiasedMonteCarlo)
    algorithm.collecter(
        eachindex(simulation.chains) |> Map(c -> begin
            logp₂ = log_bias(simulation.chains[c], algorithm.bias)
            Δlogp = logp₂ - algorithm.log_bias_cache[c]
            α = min(one(typeof(Δlogp)), exp(Δlogp))
            if α > rand(rng)
                algorithm.memories[c] = deepcopy(simulation.chains[c])
                algorithm.log_bias_cache[c] = logp₂
                algorithm.accepted_calls[c] += 1
            else
                simulation.chains[c] = deepcopy(algorithm.memories[c])
            end
            algorithm.total_calls[c] += 1
        end)
    )
    return nothing
end

function callback_bias_acceptance(simulation)
    return mean([mean(algo.accepted_calls ./ algo.total_calls) for algo in filter(x -> isa(x, BiasedMonteCarlo), simulation.algorithms)])
end

###############################################################################
# THETA 

struct ThetaBias{T<:AbstractFloat} <: Bias 
    λ::T
end

log_bias(system::Particles, bias::ThetaBias) = - bias.λ * mean(get_theta_voronoi(system))^2 / system.temperature





nothing