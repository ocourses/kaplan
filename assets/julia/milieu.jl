using Plots
using LaTeXStrings

function plot_milieu()

    xlims_ = (-0.1, 1)
    ylims_ = (-0.1, 1)
    dpi = 50

    xx = -0.04
    yy = -0.07

    font_size = 18

    # plot
    plt = plot(framestyle=:none, ticks=nothing, legend=false, axes=false, xlims=xlims_, ylims=ylims_, dpi=dpi)

    # axes
    plot!(plt, [xlims_[1], xlims_[2]], [0, 0], color=:black, lw=1, arrow=true, z_order=1)
    plot!(plt, [0, 0], [-0.1, ylims_[2]], color=:black, lw=1, arrow=true, z_order=1)

    # labels
    annotate!(plt, xlims_[2], yy, text(L"t", font_size), :top)
    annotate!(plt, xx, ylims_[2]-0.01, text(L"y", font_size), :right)

    #
    g(t) = t^2 + 0.35
    t0 = 0.15
    t1 = 0.65
    tm = (t0+t1)/2
    X = range(t0, t1, length=100)
    plot!(plt, X, g.(X), color=:blue, linewidth=3, z_order=2)
    annotate!(plt, t1+0.1, g(t1)+0.06, text(L"y = g(t) := f(t, x(t))", font_size, color=:blue))

    #
    plot!(plt, [t0, t0], [0, g(tm)], color=:black, lw=1, z_order=3, linestyle=:dash)
    plot!(plt, [t1, t1], [0, g(t1)], color=:black, lw=1, z_order=3, linestyle=:dash)
    plot!(plt, [tm, tm], [0, g(tm)], color=:black, lw=1, z_order=3, linestyle=:dash)
    plot!(plt, [t0, t1], [g(tm), g(tm)], color=:black, lw=1, z_order=3, linestyle=:dash)
    annotate!(plt, t0, yy, text(L"t_i", font_size), :top)
    annotate!(plt, (t1+t0)/2, yy, text(L"t_i+h_i/2", 14), :top)
    annotate!(plt, t1, yy, text(L"t_i+h_i", font_size), :top)
    scatter!(plt, [tm], [g(tm)], color=:black, z_order=3, markersize=4)

    #
    h(t) = g(tm)
    z(t) = 0
    plot!(plt, X, z.(X), fillrange=h.(X), fillalpha=0.3, c=1, z_order=1)

    #
    plot!(plt, X, z.(X), fillrange=g.(X), fillalpha=0.1, color=:magenta, z_order=1)

    #
    plot!(plt, X, h.(X), color=:black, linewidth=3, z_order=2)
    annotate!(plt, t1+0.18, h(t1), text(L"y = g(t_i+\frac{h_i}{2})", font_size, color=:black))

    #
    annotate!(plt, 0.2, 0.7, text(L"\textbf{Milieu}", font_size, color=:black))

    return plt
end

plt = plot_milieu()

pathname = "assets/julia/"
savefig(plt, pathname*"milieu.svg")