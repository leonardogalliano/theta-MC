# CUSTOM CODE TO ANALYSE LUDO'S CONFIGURATION FOR THETA / HYPERUNIFORMITY PAPER

using LinearAlgebra, Statistics, DelimitedFiles, Delaunator, ArgParse

function load_ludo_config(path)
    data = readdlm(path)
    L = Float64(data[1, 1])
    box = (L, L)
    Xmat = Float64.(data[2:end, 1:2])
    X = [(Xmat[i, 1], Xmat[i, 2]) for i in axes(Xmat, 1)]
    X .= map(x -> x .- fld.(x, box) .* box, X)
    sizes = Float64.(data[2:end, 3])
    ϕ = sum(sizes .^ 2) * π / (4prod(box))
    return X, sizes, box, ϕ
end

########################################################################
# STRUCRTURE FACTOR

function structure_factor_2d(X, q::Tuple{T,T}) where {T<:AbstractFloat}
    q == (zero(T), zero(T)) && return NaN
    return (mapreduce(x -> cos(dot(q, x)), +, X)^2 + mapreduce(x -> sin(dot(q, x)), +, X)^2) / length(X)
end

function unnormalised_partial_structure_factor_2d(X1, X2, q::Tuple{T,T}) where {T<:AbstractFloat}
    q == (zero(T), zero(T)) && return NaN
    return (
        mapreduce(x -> cos(dot(q, x)), +, X1) * (mapreduce(x -> cos(dot(q, x)), +, X2))
        +
        mapreduce(x -> sin(dot(q, x)), +, X1) * (mapreduce(x -> sin(dot(q, x)), +, X2))
    )
end

function generate_q_lattice(box; δq=2π / mean(box), qmax=10.0)
    nmax = round(Int, mean(box) * qmax / (2pi * sqrt(2)))
    qlattice = [2π .* (nx, ny) ./ box for nx in -nmax:nmax for ny in 0:nmax]
    qs = norm.(qlattice)
    qbins = collect(2π/mean(box):δq:maximum(qs))
    return qlattice, qs, qbins
end

function structure_factor(X, box; δq=2π / mean(box), qmax=10.0)
    qlattice, qs, qbins = generate_q_lattice(box; δq=δq, qmax=qmax)
    s2d = map(q -> structure_factor_2d(X, q), qlattice)
    soq = map(qbin -> mean(s2d[findall(q -> qbin ≤ q ≤ qbin + δq, qs)]), qbins)
    return qbins, soq
end

function partial_structure_factor(X, species, box, sp1, sp2; δq=2π / mean(box), qmax=10.0)
    qlattice, qs, qbins = generate_q_lattice(box; δq=δq, qmax=qmax)
    ids1 = findall(isequal(sp1), species)
    ids2 = findall(isequal(sp2), species)
    X1 = @view X[ids1]
    X2 = @view X[ids2]
    s2d = map(q -> unnormalised_partial_structure_factor_2d(X1, X2, q), qlattice) ./ length(X)
    soq = map(qbin -> mean(s2d[findall(q -> qbin ≤ q ≤ qbin + δq, qs)]), qbins)
    return qbins, soq
end

function compressibility(X, species::Vector{T}, box; δq=2π / mean(box), qmax=10.0) where {T<:AbstractFloat}
    qlattice, qs, qbins = generate_q_lattice(box; δq=δq, qmax=qmax)
    types = unique(species)
    @assert length(types) == 2
    sp1, sp2 = types[1], types[2]
    ids1 = findall(isequal(sp1), species)
    ids2 = findall(isequal(sp2), species)
    X1 = @view X[ids1]
    X2 = @view X[ids2]
    N = length(X)
    c1 = length(ids1) / N
    c2 = length(ids2) / N
    s2d11 = map(q -> unnormalised_partial_structure_factor_2d(X1, X1, q), qlattice) ./ N
    s11 = map(qbin -> mean(s2d11[findall(q -> qbin ≤ q ≤ qbin + δq, qs)]), qbins)
    s2d12 = map(q -> unnormalised_partial_structure_factor_2d(X1, X2, q), qlattice) ./ N
    s12 = map(qbin -> mean(s2d12[findall(q -> qbin ≤ q ≤ qbin + δq, qs)]), qbins)
    s2d22 = map(q -> unnormalised_partial_structure_factor_2d(X2, X2, q), qlattice) ./ N
    s22 = map(qbin -> mean(s2d22[findall(q -> qbin ≤ q ≤ qbin + δq, qs)]), qbins)
    chiq = (s11 .* s22 .- s12 .^ 2) ./ (c1^2 .* s22 .+ c2^2 .* s11 .- 2 .* c1 .* c2 .* s12)
    return qbins, chiq
end

########################################################################
# THETA

theta(a, b, c) = acos((b^2 + c^2 - a^2) / (2 * b * c))

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

function get_theta_voronoi(
    X::Vector{Tuple{T,T}},
    sizes::Vector{T},
    box::Tuple{T,T};
    border::T=2.0
) where {T<:AbstractFloat}
    Xhpbc, shpbc = manual_pbc(X, sizes, box[1]; border=border)
    triangulation = triangulate(Xhpbc)
    return map(i -> get_theta_voronoi(Xhpbc, shpbc, triangulation, i), eachindex(X))
end

########################################################################
# SAVE RESULTS

function analyse_configurations(path_root)
    files = filter(isfile, readdir(path_root, join=true))
    M = length(files)
    phis = Vector{Float64}(undef, M)
    qs = Vector{Vector{Float64}}(undef, M)
    chis = Vector{Vector{Float64}}(undef, M)
    thetas = Vector{Float64}(undef, M)
    for (k, file) in enumerate(files)
        X, sizes, box, ϕ = load_ludo_config(file)
        phis[k] = ϕ
        qs[k], chis[k] = compressibility(X, sizes, box)
        thetas[k] = mean(get_theta_voronoi(X, sizes, box; border=2.0))
    end
    return phis, qs, chis, thetas
end

function save_results(path_root, out_path)
    phis, qs, chis, thetas = analyse_configurations(path_root)
    avgphi = mean(phis)
    avgq = mean(qs)
    avgchi = mean(chis)
    avgtheta = mean(thetas)
    open(joinpath(out_path, "compressibility.dat"), "w") do io
        writedlm(io, [avgq avgchi])
    end
    open(joinpath(out_path, "phi.dat"), "w") do io
        writedlm(io, [avgphi])
    end
    open(joinpath(out_path, "theta.dat"), "w") do io
        writedlm(io, [avgtheta])
    end
    return nothing
end

function main(args)
    path = args["path"]
    out_path = joinpath(path, "POSTPROCESSING")
    mkpath(out_path)
    save_results(path, out_path)
end

function parse_commandline()
    parser = ArgParseSettings()
    @add_arg_table! parser begin
        "path"
        help = "Path to folder with configuration files"
        arg_type = String
        required = true
    end
    return parse_args(parser)
end

if abspath(PROGRAM_FILE) == @__FILE__
    args = parse_commandline()
    main(args)
end

nothing