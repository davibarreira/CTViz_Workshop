using Vizagrams
using Librsvg_jll: Librsvg_jll, rsvg_convert

function Vizagrams.centralize_graphic(t::Mark)::TMark
    return centralize_graphic(dmlift(t))
end

"""
savefigure(
    plt::Union{Mark,𝕋{Mark}}; filename::String, directory::String="./", height=0, width=500, pad=20
)

Save figure as pdf with a fixed scale. This is used in order that the
diagrams have the same figure size in terms of scale. For example,
and object `A` will have the same fontsize as `B` once we place
the pdf image into a text.
"""
function savefigure(
    plt::Union{Mark,𝕋{Mark}}; filename::String, directory::String="./", height=0, width=500, pad=20
)
    # Centralizing and Scaling
    plt = centralize_graphic(plt)
    plt = U(90)plt
    width = max(boundingwidth(plt) + pad, width)
    height = max(boundingheight(plt) + pad, height)

    img = tosvg(T(width / 2, -height / 2)plt, height=height, width=width) |> string

    extension = filename[(end-2):end]
    fname = filename
    dirpath = directory
    fpath = joinpath(dirpath, fname)

    return mktemp() do path, io
        write(io, img)
        close(io)
        run(`$(rsvg_convert()) $path -h $height -w $width -f $extension -o $fpath`)
    end
end


"""
vizcat(d; width=0, height=0, pad=20)

Visualize diagram.
"""
function vizcat(d; width=0, height=0, pad=20)
    d = centralize_graphic(d)
    d = U(100) * d

    width = max(boundingwidth(d) + pad, width)
    height = max(boundingheight(d) + pad, height)

    tosvg(T(width / 2, -height / 2)d, height=height, width=width)
end
