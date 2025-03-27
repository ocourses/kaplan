using Plots

function abscisses_curvilignes(x, y)
    # Vérifiez que les vecteurs x et y ont la même longueur
    if length(x) != length(y)
        throw(ArgumentError("Les vecteurs x et y doivent avoir la même longueur."))
    end

    # Calculez les différences entre les points successifs
    dx = diff(x)
    dy = diff(y)

    # Calculez les distances euclidiennes entre chaque paire de points consécutifs
    distances = sqrt.(dx.^2 + dy.^2)

    # Calculez le tableau des abscisses curvilignes
    abscisses = cumsum([0; distances])

    return abscisses
end

# Exemple d'utilisation
X = [0, 1, 2, 3, 4]
Y = [0, 1, 3, 2, 4]

abscisses = abscisses_curvilignes(X, Y)

@userplot CurvePlot
@recipe function f(cp::CurvePlot)
    x, y = cp.args
    seriestype := :path

    # compute arclength
    A = abscisses_curvilignes(x, y)
    L = A[end]

    #
    lw0 = 8
    lw1 = 1
    lw = ( lw0 * A + lw1 * (L .- A) ) ./ L

    linewidth --> lw
    return x, y
end

function initiate_plot(xlims_, ylims_, font_size; xx=-0.1, yy=-0.1, dpi=300)
    
    # plot
    plt = plot(framestyle=:none, ticks=nothing, legend=false, axes=false, xlims=xlims_, ylims=ylims_, dpi=dpi)

    # axes
    plot!(plt, [xlims_[1], xlims_[2]], [0, 0], color=:black, lw=2, arrow=true, z_order=1)
    plot!(plt, [0, 0], [ylims_[1], ylims_[2]], color=:black, lw=2, arrow=true, z_order=1)

    # labels
    annotate!(plt, xlims_[2], yy, text(L"x_1", font_size), :top)
    annotate!(plt, xx, ylims_[2]-0.01, text(L"x_2", font_size), :right)
 
    return plt
end

# ------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------
function exemple1(tf)

    #
    xlims_ = (-0.15, 1)
    ylims_ = (-0.15, 1)
    font_size = 22

    plt = initiate_plot(xlims_, ylims_, font_size; xx=-0.07, yy=-0.1)

    #
    N = 100

    x(t) = exp(-t)
    y(t) = exp(-2t)

    T = range(0, tf, length=100)
    X = x.(T)
    Y = y.(T)

    curveplot!(plt, X, Y; color=:blue, z_order=2)
    scatter!(plt, [X[end]], [Y[end]], color=:black, z_order=3, markersize=8)

    return plt

end

exemple1(2)

# Scénario
function scenario1()
    states = Any[]
    #
    for tf ∈ range(0, 5, length=300) push!(states, tf) end
    return states
end

# affichage
states = scenario1()
anim = @animate for state in states
    exemple1(state)
end

pathname = "assets/julia/exponentielle_exemple1"
gif(anim, pathname * ".gif", fps=20)
convert = `ffmpeg -y -i $(pathname).gif -vf format=yuv420p $(pathname).mp4`
run(convert)

# ------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------
function exemple2(tf)

    #
    xlims_ = (-21, 2)
    ylims_ = (-1, 10)
    font_size = 22

    plt = initiate_plot(xlims_, ylims_, font_size; xx=-1, yy=-0.8, dpi=300)

    #
    N = 200

    x(t) = exp(t)*cos(t)
    y(t) = exp(t)*sin(t)

    T = range(0, tf, length=100)
    X = x.(T)
    Y = y.(T)

    curveplot!(plt, X, Y; color=:blue, z_order=2)
    scatter!(plt, [X[end]], [Y[end]], color=:black, z_order=3, markersize=8)

    return plt

end

exemple2(3)

# Scénario
function scenario2()
    states = Any[]
    #
    for tf ∈ range(0, 3, length=300) push!(states, tf) end
    return states
end

# affichage
states = scenario2()
anim = @animate for state in states
    exemple2(state)
end

pathname = "assets/julia/exponentielle_exemple2"
gif(anim, pathname * ".gif", fps=30)
convert = `ffmpeg -y -i $(pathname).gif -vf format=yuv420p $(pathname).mp4`
run(convert)


# ------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------
function exemple3(tf)

    #
    xlims_ = (-0.2, 2)
    ylims_ = (-0.2, 2)
    font_size = 22

    plt = initiate_plot(xlims_, ylims_, font_size; xx=-0.12, yy=-0.17, dpi=300)

    #
    N = 200

    x(t) = 1-exp(-t)
    y(t) = 1-exp(-2t)/2

    T = range(0, tf, length=100)
    X = x.(T)
    Y = y.(T)

    curveplot!(plt, X, Y; color=:blue, z_order=2)
    scatter!(plt, [X[end]], [Y[end]], color=:black, z_order=3, markersize=8)

    return plt

end

exemple3(3)

# Scénario
function scenario3()
    states = Any[]
    #
    for tf ∈ range(0, 3, length=300) push!(states, tf) end
    return states
end

# affichage
states = scenario3()
anim = @animate for state in states
    exemple3(state)
end

pathname = "assets/julia/exponentielle_exemple3"
gif(anim, pathname * ".gif", fps=30)
convert = `ffmpeg -y -i $(pathname).gif -vf format=yuv420p $(pathname).mp4`
run(convert)

