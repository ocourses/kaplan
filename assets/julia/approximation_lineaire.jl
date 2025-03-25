using LaTeXStrings
using MLStyle
using Plots

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

function draw(state)

    xlims_ = (-0.5, 2)
    ylims_ = (-0.4, 3)

    font_size = 22

    # initialisation
    function initiate_plot()
    
        # plot
        plt = plot(framestyle=:none, ticks=nothing, legend=false, axes=false, xlims=xlims_, ylims=ylims_)
    
        # axes
        plot!(plt, [xlims_[1], xlims_[2]], [0, 0], color=:black, lw=1, arrow=true)
        plot!(plt, [0, 0], [ylims_[1], ylims_[2]], color=:black, lw=1, arrow=true)
    
        # labels
        annotate!(plt, 2, -0.25, text(L"\theta", font_size), :top)
        #annotate!(plt, -0.3, 3-0.1, text(L"x(t_i, \cdot)", font_size), :right)
     
        return plt
    end

    # modèle
    x(θ) = 0.5 + (θ-0.5)^2

    # dérivée
    ∂x(θ) = 2*(θ-0.5)

    # point de départ
    θₖ = 1
    xₖ = x(θₖ)

    # affichage de la courbe sur un intervalle
    function draw_model!(plt, x, θ, Δθa, Δθb)
        curveplot!(plt, x, θ, Δθa, Δθb, :blue, 1)
        annotate!(plt, θ-0.3, x(θ)+0.3, text("modèle", 16, :blue), :bottom)
    end

    # affichage de la tangente à la courbe en un point sur un intervalle
    function draw_tangent!(plt, ∂x, θ, Δθa, Δθb)
        T(y) = x(θ) + ∂x(θ) * (y - θ)
        curveplot!(plt, T, θ, Δθa, Δθb, :red, 2)
        annotate!(plt, θ+0.5, x(θ)-0.2, text("approx. lin.", 16, :red), :bottom)
    end

    plt = initiate_plot()

    text_theta = text(L"\theta_k", font_size, :black)

    @match state begin
        :Init => nothing
        _ => annotate!(plt, θₖ, -0.25, text_theta, :bottom)
    end

    @match state begin
        (:theta, 1) => begin
            nothing
        end
        (:theta, 2) => begin
            #annotate!(plt, θₖ, -0.2, text_theta, :bottom)
            plot!(plt, [θₖ, θₖ], [0, xₖ], color=:black, lw=1, z_order=3, linestyle=:dash)
        end
        (:theta, 3) => begin
            #annotate!(plt, θₖ, -0.2, text_theta, :bottom)
            plot!(plt, [θₖ, θₖ], [0, xₖ], color=:black, lw=1, z_order=3, linestyle=:dash)
            scatter!(plt, [θₖ], [xₖ], color=:black, z_order=3)
        end
        (:model, r) => begin
            #annotate!(plt, θₖ, -0.2, text_theta, :bottom)
            plot!(plt, [θₖ, θₖ], [0, xₖ], color=:black, lw=1, z_order=3, linestyle=:dash)
            scatter!(plt, [θₖ], [xₖ], color=:black, z_order=3)
            Δθa = r*(θₖ-xlims_[1])
            Δθb = r*(xlims_[2]-θₖ)
            draw_model!(plt, x, θₖ, Δθa, Δθb)
        end
        (:model_and_tangent, r) => begin
            #annotate!(plt, θₖ, -0.2, text_theta, :bottom)
            plot!(plt, [θₖ, θₖ], [0, xₖ], color=:black, lw=1, z_order=3, linestyle=:dash)
            scatter!(plt, [θₖ], [xₖ], color=:black, z_order=3)
            Δθa = r*(θₖ-xlims_[1])
            Δθb = r*(xlims_[2]-θₖ)
            draw_model!(plt, x, θₖ, Δθa, Δθb)
            draw_tangent!(plt, ∂x, θₖ, Δθa, Δθb)
        end
        _ => nothing
    end

    return plt

end

# (:theta, step): affichage du point de départ en plusieurs étapes

# Scénario
states = Any[]

for r in 1:-0.01:0
    push!(states, (:model_and_tangent, r))
end
for i ∈ 1:10
    push!(states, (:theta, 3))
end
for i ∈ 1:10
    push!(states, (:theta, 2))
end
for i ∈ 1:10
    push!(states, (:theta, 1))
end
push!(states, :End)
for i ∈ 1:20
    push!(states, :Init)
end
for i ∈ 1:20
    push!(states, (:theta, 1))
end
for i ∈ 1:10
    push!(states, (:theta, 2))
end
for i ∈ 1:30
    push!(states, (:theta, 3))
end
for r in 0:0.01:1
    push!(states, (:model, r))
end
for r in 1:-0.01:0
    push!(states, (:model, r))
end
for i ∈ 1:10
    push!(states, (:model, 0))
end
for r in 0:0.01:1
    push!(states, (:model_and_tangent, r))
end


# affichage
anim = @animate for state in states
    plt = draw(state)
end

gif(anim, "assets/julia/approximation_lineaire.gif", fps=30)