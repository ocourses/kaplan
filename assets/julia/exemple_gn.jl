using LinearAlgebra
using LaTeXStrings
using Plots

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
θ = [1, 1] # initialisation
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

# ----------------------------------------------------------------------
# Exemple 2

# données
xi = π/8 # entre -1 et 1

# modèle
x(θ) = cos(θ)
F(θ) = 0.5*(xi-x(θ))^2

Fmax = F(π)

# dérivée
∂x(θ) = -sin(θ)
∂F(θ, Δθ) = 0.5*(xi-x(θ)-∂x(θ)*Δθ)^2

# solution
θ_sol = acos(xi)
F(θ_sol)

# résolution du problème linéaire en θ
function lslin(θ)
    a = ∂x(θ)^2
    b = ∂x(θ)*(xi-x(θ))
    return b/a
end

# itéré initial
θₖ = 2.5

#
@userplot CurvePlot
@recipe function f(cp::CurvePlot)

    x, θ, Δθa, Δθb, c, z = cp.args
    N = 100
    θs = range(θ-Δθa, θ+Δθb, length=N)
    xs = x.(θs)

    #
    seriestype := :path
    color := c

    # find index of the point closest to the θ
    idx = argmin(abs.(θs .- θ))
    if idx > 1 
        lw = range(0.5, 3, length=idx)
        lw = vcat(lw, range(3, 0.5, length=N-idx))
        linewidth --> lw
    else
        linewidth := 3
    end

    #
    z_order := z

    return θs, xs
end

# affichage de la courbe sur un intervalle
function draw_model!(plt, F, θ, Δθa, Δθb)
    curveplot!(plt, F, θ, Δθa, Δθb, :blue, 1)
    annotate!(plt, 1, 1.5, text(L"F", font_size, :blue), :bottom)
end

# affichage de la tangente à la courbe en un point sur un intervalle
function draw_tangent!(plt, ∂F, θ, Δθa, Δθb)
    T(y) = ∂F(θ, y-θ)
    curveplot!(plt, T, θ, Δθa, Δθb, :red, 2)
    annotate!(plt, 3, 1, text(L"F_k", font_size, :red), :bottom)
end

# affichage F et son approximation en l'itéré initial
xlims_ = (-2, 6)
ylims_ = (-0.1*Fmax, 1.1*Fmax)
font_size = 18
plt = plot(framestyle=:none, ticks=nothing, legend=false, axes=false, xlims=xlims_, ylims=ylims_, dpi=100)
plot!(plt, [xlims_[1], xlims_[2]], [0, 0], color=:black, lw=1, arrow=true)
plot!(plt, [0, 0], [ylims_[1], ylims_[2]], color=:black, lw=1, arrow=true)
annotate!(plt, xlims_[2]-0.1, -0.08*Fmax, text(L"\theta", font_size), :top)    
text_theta = text(L"\theta_k", font_size, :black)
text_theta_suivant = text(L"\theta_{k+1}", font_size, :black)
text_delta_theta = text(L"\Delta\theta_k", 12, :black)
theta_y = -0.08*Fmax
delta_theta_y = -0.04*Fmax
fₖ = F(θₖ)
annotate!(plt, θₖ+0.08, theta_y, text_theta, :bottom)
plot!(plt, [θₖ, θₖ], [0, fₖ], color=:black, lw=1, z_order=3, linestyle=:dash)
scatter!(plt, [θₖ], [fₖ], color=:black, z_order=3)
Δθa = 1*(θₖ-xlims_[1])
Δθb = 1*(xlims_[2]-θₖ)
draw_model!(plt, F, θₖ, Δθa, Δθb)
Δθa = 1*(θₖ-xlims_[1])
Δθb = 1*(xlims_[2]-θₖ)
draw_tangent!(plt, ∂F, θₖ, Δθa, Δθb)
θₖ₊₁ = θₖ + lslin(θₖ)
Fₖ₊₁ = ∂F(θₖ, θₖ₊₁-θₖ)
plot!(plt, [θₖ, θₖ₊₁], [0, 0], color=:green, lw=4, z_order=4)
annotate!(plt, (θₖ+θₖ₊₁)/2+0, delta_theta_y, text_delta_theta, :bottom)
annotate!(plt, θₖ₊₁+0.3, theta_y, text_theta_suivant, :bottom)
plot!(plt, [θₖ₊₁, θₖ₊₁], [0, Fₖ₊₁], color=:black, lw=1, z_order=5, linestyle=:dash)
scatter!(plt, [θₖ₊₁], [Fₖ₊₁], color=:black, z_order=5)

# itération
θₖ = 2.5

N = 5
θₛ = Float64[θₖ]
for i ∈ 1:N
    θₖ = θₖ + lslin(θₖ)
    push!(θₛ, θₖ)
end

#
plt_convergence = plot(xlims=(0, N), ylims=(-1, 3), legend=false, xlabel=L"n", ylabel=L"\theta")
plot!(plt_convergence, [0, N], [θ_sol, θ_sol], color=:black, lw=1, linestyle=:dash, z_order=1)
plot!(plt_convergence, 0:N, θₛ, color=:blue, z_order=2, marker=:circle)

# erreur en log
plt_erreur = plot(xlims=(-1, N+1), ylims=(1e-11, 1e1), legend=false, xlabel=L"n", ylabel=L"Erreur")
plot!(plt_erreur, 0:N, abs.(θₛ.-θ_sol), yaxis=:log, marker=:circle, color=:blue)

θₛ
abs.(θₛ.-θ_sol)