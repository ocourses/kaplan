using LinearAlgebra

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