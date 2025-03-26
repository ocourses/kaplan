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

    # xlims_ = (-0.5, 2)
    # ylims_ = (-0.4, 3)

    xlims_ = (-2, 6)
    ylims_ = (-0.6, 5)

    font_size = 22

    # initialisation
    function initiate_plot()
    
        # plot
        plt = plot(framestyle=:none, ticks=nothing, legend=false, axes=false, xlims=xlims_, ylims=ylims_)
    
        # axes
        plot!(plt, [xlims_[1], xlims_[2]], [0, 0], color=:black, lw=1, arrow=true)
        plot!(plt, [0, 0], [ylims_[1], ylims_[2]], color=:black, lw=1, arrow=true)
    
        # labels
        annotate!(plt, xlims_[2]-0.1, -0.3, text(L"\theta", font_size), :top)
        #annotate!(plt, -0.3, 3-0.1, text(L"x(t_i, \cdot)", font_size), :right)
     
        return plt
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

    # données
    xi = 0.5

    # modèle
    x(θ) = 2.5+cos(θ-1-π) # 0.5 + (θ-0.5)^2
    F(θ) = 0.5*(xi-x(θ))^2

    # dérivée
    ∂x(θ) = -sin(θ-1-π) # 2*(θ-0.5)
    ∂F(θ, Δθ) = 0.5*(xi-x(θ)-∂x(θ)*Δθ)^2

    function lslin(θ)
        a = ∂x(θ)^2
        b = ∂x(θ)*(xi-x(θ))
        return b/a
    end

    # point de départ
    #θₖ = 1
    #xₖ = x(θₖ)

    plt = initiate_plot()

    text_theta = text(L"\theta_k", font_size, :black)
    text_theta_suivant = text(L"\theta_{k+1}", font_size, :black)
    text_delta_theta = text(L"\Delta\theta_k", 12, :black)

    fₖ = @match state begin
        (θₖ, _, _) => F(θₖ)
        _ => nothing
    end

    @match state begin
        (θₖ, :theta, 1) => begin
            annotate!(plt, θₖ+0.08, -0.5, text_theta, :bottom)
        end
        (θₖ, :theta, 2) => begin
            annotate!(plt, θₖ+0.08, -0.5, text_theta, :bottom)
            plot!(plt, [θₖ, θₖ], [0, fₖ], color=:black, lw=1, z_order=3, linestyle=:dash)
        end
        (θₖ, :theta, 3) => begin
            annotate!(plt, θₖ+0.08, -0.5, text_theta, :bottom)
            plot!(plt, [θₖ, θₖ], [0, fₖ], color=:black, lw=1, z_order=3, linestyle=:dash)
            scatter!(plt, [θₖ], [fₖ], color=:black, z_order=3)
        end
        (θₖ, :theta_suivant, 1) => begin
            annotate!(plt, θₖ+0.08, -0.5, text_theta, :bottom)
            plot!(plt, [θₖ, θₖ], [0, fₖ], color=:black, lw=1, z_order=3, linestyle=:dash)
            scatter!(plt, [θₖ], [fₖ], color=:black, z_order=3)
            Δθa = 1*(θₖ-xlims_[1])
            Δθb = 1*(xlims_[2]-θₖ)
            draw_model!(plt, F, θₖ, Δθa, Δθb)
            Δθa = 1*(θₖ-xlims_[1])
            Δθb = 1*(xlims_[2]-θₖ)
            draw_tangent!(plt, ∂F, θₖ, Δθa, Δθb)
            #
            θₖ₊₁ = θₖ + lslin(θₖ)
            Fₖ₊₁ = ∂F(θₖ, θₖ₊₁-θₖ)
            #
            plot!(plt, [θₖ, θₖ₊₁], [0, 0], color=:green, lw=4, z_order=3)
        end
        (θₖ, :theta_suivant, 2) => begin
            annotate!(plt, θₖ+0.08, -0.5, text_theta, :bottom)
            plot!(plt, [θₖ, θₖ], [0, fₖ], color=:black, lw=1, z_order=3, linestyle=:dash)
            scatter!(plt, [θₖ], [fₖ], color=:black, z_order=3)
            Δθa = 1*(θₖ-xlims_[1])
            Δθb = 1*(xlims_[2]-θₖ)
            draw_model!(plt, F, θₖ, Δθa, Δθb)
            Δθa = 1*(θₖ-xlims_[1])
            Δθb = 1*(xlims_[2]-θₖ)
            draw_tangent!(plt, ∂F, θₖ, Δθa, Δθb)
            #
            θₖ₊₁ = θₖ + lslin(θₖ)
            Fₖ₊₁ = ∂F(θₖ, θₖ₊₁-θₖ)
            #
            plot!(plt, [θₖ, θₖ₊₁], [0, 0], color=:green, lw=4, z_order=3)
            annotate!(plt, (θₖ+θₖ₊₁)/2+0, -0.2, text_delta_theta, :bottom)
        end
        (θₖ, :theta_suivant, 3) => begin
            annotate!(plt, θₖ+0.08, -0.5, text_theta, :bottom)
            plot!(plt, [θₖ, θₖ], [0, fₖ], color=:black, lw=1, z_order=3, linestyle=:dash)
            scatter!(plt, [θₖ], [fₖ], color=:black, z_order=3)
            Δθa = 1*(θₖ-xlims_[1])
            Δθb = 1*(xlims_[2]-θₖ)
            draw_model!(plt, F, θₖ, Δθa, Δθb)
            Δθa = 1*(θₖ-xlims_[1])
            Δθb = 1*(xlims_[2]-θₖ)
            draw_tangent!(plt, ∂F, θₖ, Δθa, Δθb)
            #
            θₖ₊₁ = θₖ + lslin(θₖ)
            Fₖ₊₁ = ∂F(θₖ, θₖ₊₁-θₖ)
            #
            plot!(plt, [θₖ, θₖ₊₁], [0, 0], color=:green, lw=4, z_order=3)
            annotate!(plt, (θₖ+θₖ₊₁)/2+0, -0.2, text_delta_theta, :bottom)
            #
            annotate!(plt, θₖ₊₁+0.3, -0.5, text_theta_suivant, :bottom)
            plot!(plt, [θₖ₊₁, θₖ₊₁], [0, Fₖ₊₁], color=:black, lw=1, z_order=3, linestyle=:dash)
            scatter!(plt, [θₖ₊₁], [Fₖ₊₁], color=:black, z_order=3)
        end
        (θₖ, :model, r) => begin
            Δθa = r*(θₖ-xlims_[1])
            Δθb = r*(xlims_[2]-θₖ)
            draw_model!(plt, F, θₖ, Δθa, Δθb)
        end
        (θₖ, :model_and_theta, 1) => begin
            annotate!(plt, θₖ+0.08, -0.5, text_theta, :bottom)
            Δθa = 1*(θₖ-xlims_[1])
            Δθb = 1*(xlims_[2]-θₖ)
            draw_model!(plt, F, θₖ, Δθa, Δθb)
        end
        (θₖ, :model_and_theta, 2) => begin
            annotate!(plt, θₖ+0.08, -0.5, text_theta, :bottom)
            plot!(plt, [θₖ, θₖ], [0, fₖ], color=:black, lw=1, z_order=3, linestyle=:dash)
            Δθa = 1*(θₖ-xlims_[1])
            Δθb = 1*(xlims_[2]-θₖ)
            draw_model!(plt, F, θₖ, Δθa, Δθb)
        end
        (θₖ, :model_and_theta, 3) => begin
            annotate!(plt, θₖ+0.08, -0.5, text_theta, :bottom)
            plot!(plt, [θₖ, θₖ], [0, fₖ], color=:black, lw=1, z_order=3, linestyle=:dash)
            scatter!(plt, [θₖ], [fₖ], color=:black, z_order=3)
            Δθa = 1*(θₖ-xlims_[1])
            Δθb = 1*(xlims_[2]-θₖ)
            draw_model!(plt, F, θₖ, Δθa, Δθb)
        end
        (θₖ, :model_and_tangent, r) => begin
            annotate!(plt, θₖ+0.08, -0.5, text_theta, :bottom)
            plot!(plt, [θₖ, θₖ], [0, fₖ], color=:black, lw=1, z_order=3, linestyle=:dash)
            scatter!(plt, [θₖ], [fₖ], color=:black, z_order=3)
            Δθa = 1*(θₖ-xlims_[1])
            Δθb = 1*(xlims_[2]-θₖ)
            draw_model!(plt, F, θₖ, Δθa, Δθb)
            Δθa = r*(θₖ-xlims_[1])
            Δθb = r*(xlims_[2]-θₖ)
            draw_tangent!(plt, ∂F, θₖ, Δθa, Δθb)
        end
        _ => nothing
    end

    return plt

end

draw((2, :theta_suivant, 3))

# Scénario
function scenario()
    states = Any[]
    θₖ = 2
    #
    for i ∈ 1:50        push!(states, (θₖ, :theta_suivant, 3))          end
    for i ∈ 1:50        push!(states, (θₖ, :theta_suivant, 2))          end
    for i ∈ 1:50        push!(states, (θₖ, :theta_suivant, 1))          end
    #
    for r ∈ 1:-0.01:0   push!(states, (θₖ, :model_and_tangent, r))      end
    for i ∈ 1:10        push!(states, (θₖ, :model_and_theta, 3))        end
    for i ∈ 1:10        push!(states, (θₖ, :model_and_theta, 2))        end
    for i ∈ 1:10        push!(states, (θₖ, :model_and_theta, 1))        end
    for r ∈ 1:-0.01:0    push!(states, (θₖ, :model, r))                 end
    for i ∈ 1:1         push!(states, :End)                             end
    #
    for i ∈ 1:20        push!(states, :Init)                            end
    for r ∈ 0:0.01:1    push!(states, (θₖ, :model, r))                  end
    for i ∈ 1:20        push!(states, (θₖ, :model_and_theta, 1))        end
    for i ∈ 1:10        push!(states, (θₖ, :model_and_theta, 2))        end
    for i ∈ 1:30        push!(states, (θₖ, :model_and_theta, 3))        end
    for r ∈ 0:0.01:1    push!(states, (θₖ, :model_and_tangent, r))      end
    for θₖ ∈ 2:0.025:5.5     push!(states, (θₖ, :model_and_tangent, 1))  end
    for θₖ ∈ 5.5:-0.025:-1.5 push!(states, (θₖ, :model_and_tangent, 1))  end
    for θₖ ∈ -1.5:0.025:2    push!(states, (θₖ, :model_and_tangent, 1))  end
    #
    for i ∈ 1:50        push!(states, (θₖ, :theta_suivant, 1))          end
    for i ∈ 1:50        push!(states, (θₖ, :theta_suivant, 2))          end
    return states
end

# affichage
states = scenario()
anim = @animate for state in states
    plt = draw(state)
end

gif(anim, "assets/julia/approximation_moindres_carres.gif", fps=30)
