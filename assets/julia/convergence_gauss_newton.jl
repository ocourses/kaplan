using LinearAlgebra
using LaTeXStrings

# modèle
x(t, θ₁, θ₂) = θ₁ + θ₂ * t
x(t, θ) = x(t, θ...)

# dérivée partielle du modèle par rapport aux paramètre
∂x∂θ(t) = [1 t]
∂x∂θ(t, θ) = ∂x∂θ(t)

# Fonction que l'on minimise
function F(θ, T, X)
    N = length(T)
    res = 0
    for i ∈ range(1, N)
        res = res + (X[i] - x(T[i], θ))^2
    end
    return res / 2
end

# données
T = [1, 2, 4]
X = [1, 4, 3]

T = [1, 2, 3]
X = [2, 3, 5]

# fonctions pour construire le système linéaire
function system(T, X, θ)

    N = length(T)
    l = length(θ)
    A = zeros(l, l)
    b = zeros(l)

    for i ∈ range(1, N)
        J = ∂x∂θ(T[i], θ)
        A = A + J'*J
        b = b + J'*(X[i] - x(T[i], θ))
    end

    return A, b
end


# algorithme de Gauss-Newton sur 2 itérations
θ = [2, 0] # initialisation
θ = [1, 1] # initialisation
θ₀ = θ
F(θ, T, X)

# itération 0
A, b = system(T, X, θ)
Δθ = A \ b
θ = θ + Δθ
F(θ, T, X)

# itération 1
A, b = system(T, X, θ)
Δθ = A \ b
θ = θ + Δθ
F(θ, T, X)

# ---------------------------------------------------------------------
# ---------------------------------------------------------------------
# affichage

function draw(x, θ; plt=nothing, color=:blue)

    firstplot = plt === nothing ? true : false

    xlims_ = (-1, 5)
    ylims_ = (-0.6, 5)

    xlims_ = (-1, 4)
    ylims_ = (-0.6, 6)

    font_size = 22

    # plot
    if firstplot
        plt = plot(framestyle=:none, ticks=nothing, legend=false, axes=false, xlims=xlims_, ylims=ylims_)

        # axes
        plot!(plt, [xlims_[1], xlims_[2]], [0, 0], color=:black, lw=1, arrow=true)
        plot!(plt, [0, 0], [ylims_[1], ylims_[2]], color=:black, lw=1, arrow=true)

        # labels
        annotate!(plt, xlims_[2]-0.1, -0.5, text(L"t", font_size), :top)
        annotate!(plt, -0.3, ylims_[2]-0.1, text(L"x", font_size), :right)

        # données
        scatter!(plt, T, X, color=:black, label="données", z_order=2)

        # annotation (t1, x1), (t2, x2), (t3, x3)
        annotate!(plt, T[1]-0.2, X[1]+0.5, text(L"(t_1, x_1)", font_size), :top, z_order=3)
        annotate!(plt, T[2]+0.2, X[2]-0.5, text(L"(t_2, x_2)", font_size), :top, z_order=3)
        annotate!(plt, T[3]-0.2, X[3]+0.5, text(L"(t_3, x_3)", font_size), :top, z_order=3)
    end

    # modèle
    t = range(xlims_[1], xlims_[2], length=100)
    plot!(plt, t, t -> x(t, θ), color=color, lw=2, label="modèle", z_order=1)

    return plt
end

plt = draw(x, θ₀; color=:red)
plt = draw(x, θ; plt=plt)

# save fig
savefig(plt, "assets/julia/convergence_gauss_newton.svg")