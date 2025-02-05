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


function valuescols(values;fontw=nothing,fontsize=12,colwidth=nothing,anchor=:e)
    cols = map(x->S(:fontWeight=>fontw)TextMark(text=x,fontfamily="Helvetica",anchor=anchor,fontsize=fontsize), values)
    if isnothing(colwidth)
        colwidth = maximum(boundingwidth.(cols))+10
    end
    acc = vcat(0,map(x->colwidth, 1:length(cols)-1) |> Scan(+) |> collect)
    dcols = mapreduce(x->begin
            T(x[1],0)x[2]# + Style(:fillOpacity=>0,:stroke=>:black)T(x[1]+colwidth/2,0)*Rectangle(h=20,w=colwidth)
        end
            ,+,zip(acc,cols))
    width = colwidth*length(cols)
    return dcols, colwidth, width
end

function create_temp_df(df::DataFrame;dots=true,nrows=2)
    if dots
        temp = DataFrame(map(x->(x=>"⋅⋅⋅"),names(df)))
        return vcat(df[1:nrows,:],temp,df[end-(nrows-1):end,:])
    end
    vcat(df[1:nrows,:],df[end-(nrows-1):end,:])
end

function tablemark(df::DataFrame;colwidth=80,rowheight=9,dots=true,nrows=2, reduce_df= true)
    tdf = df
    if reduce_df
        tdf = create_temp_df(df,dots=dots,nrows=nrows)
    end
    dcols,colwidth, width = valuescols(names(tdf),fontw=:bold,colwidth=80)
    pad = 2
    d = dcols ↓ (T(0,-rowheight-pad),Line([[-pad,0],[width+pad,0]]))

    rows = map(row->valuescols(collect(row),colwidth=colwidth,fontsize=12)[1],eachrow(tdf))
    rows = reduce((x,y)->x↓(T(0,-rowheight),y),rows)
    d = d ↓ (T(0,-rowheight),rows)
end
