using Plots
using LaTeXStrings

function plot_consistance()

    xlims_ = (-0.3, 2)
    ylims_ = (-0.7, 4)
    dpi = 50

    xx = -0.12
    yy = -0.3

    font_size = 18

    # plot
    plt = plot(framestyle=:none, ticks=nothing, legend=false, axes=false, xlims=xlims_, ylims=ylims_, dpi=dpi)

    # axes
    plot!(plt, [xlims_[1], xlims_[2]], [0, 0], color=:black, lw=1, arrow=true, z_order=1)
    plot!(plt, [0, 0], [ylims_[1], ylims_[2]], color=:black, lw=1, arrow=true, z_order=1)

    # labels
    annotate!(plt, xlims_[2], yy, text(L"t", font_size), :top)
    annotate!(plt, -0.08, ylims_[2]-0.01, text(L"y", font_size), :right)

    #
    g(t) = t^2 + 0.5
    t0 = 0.3
    t1 = 1.6
    X = range(xlims_[1], xlims_[2], length=100)
    #X  = range(t0, t1, length=100)
    plot!(plt, X, g.(X), color=:blue, linewidth=2, z_order=2)
    annotate!(plt, 0.9, 2, text(L"y = x(t)", font_size, color=:blue))

    #
    plot!(plt, [t0, t0], [0, g(t0)], color=:black, lw=1, z_order=3, linestyle=:dash)
    plot!(plt, [t1, t1], [0, g(t1)], color=:black, lw=1, z_order=3, linestyle=:dash)
    plot!(plt, [0, t0], [g(t0), g(t0)], color=:black, lw=1, z_order=3, linestyle=:dash)
    annotate!(plt, t0, yy, text(L"t_i", font_size), :top)
    annotate!(plt, t1+0.02, yy, text(L"t_i + h_i", font_size), :top)
    annotate!(plt, xx, g(t0)+0.12, text(L"x(t_i)", font_size), :right)
    scatter!(plt, [t0], [g(t0)], color=:black, z_order=5, markersize=4)

    # tangente
    ∂g(t) = 2t
    T(t) = g(t0) + ∂g(t0) * (t - t0)
    plot!(plt, X, T.(X), color=:black, linewidth=2, z_order=2)

    #
    annotate!(plt, 0.4, 2.9, text(L"\textbf{Euler}", font_size, color=:black))
    annotate!(plt, 1, 0.6, text(L"y = T(t)", font_size, color=:black))

    #
    scatter!(plt, [t1], [g(t1)], color=:blue, z_order=5, markersize=4)
    scatter!(plt, [t1], [T(t1)], color=:black, z_order=5, markersize=4)

    #
    plot!(plt, [t1, t1], [(g(t1)+T(t1))/2, g(t1)], color=:red, lw=3, z_order=4, arrow=true)
    plot!(plt, [t1, t1], [(g(t1)+T(t1))/2, T(t1)], color=:red, lw=3, z_order=4, arrow=true)
    annotate!(plt, t1+0.1, 2.2, text(L"e_i", font_size, color=:red))

    return plt
end

plt = plot_consistance()

pathname = "assets/julia/"
savefig(plt, pathname*"consistance.svg")