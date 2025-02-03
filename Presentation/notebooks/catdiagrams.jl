"""
    cbezier_tangent(c::CBezier,t::Real)
Compute tanget for cubic bezier. For t=0, computes the tangent
at the start of the curve, and for t=1 at the end.
"""
function cbezier_tangent(c::CBezier, t::Real)
    C0, C1 = c.cpts
    P0, P1 = c.bpts
    (1 - t)^2 * (C0 - P0) * 3 +
    2 * (1 - t) * t * (C1 - C0) * 3 +
    t^2 * (P1 - C1) * 3
end
"""
    cbezier_angle(c::CBezier, t::Real)
Compute tanget angle for cubic bezier. For t=0, computes the tangent
at the start of the curve, and for t=1 at the end.
"""
function cbezier_angle(c::CBezier, t::Real)
    tan = cbezier_tangent(c, t)
    atan(tan[2], tan[1])
end

"""
derivative_qbezier(b::QBezier, t=1)
Computes the derivative of a quadratic Bezier curve at a given parameter `t`.

# Arguments
- `b::QBezier`: The quadratic Bezier curve.
- `t::Real`: The parameter at which to compute the derivative (default is 1).

# Returns
- The derivative of the quadratic Bezier curve at `t`.

# Notes
- Handles the degenerate case where the control points are collinear.

# Example
```julia
b = QBezier(bpts=[[0, 0], [1, 1]], cpts=[[0.5, 0.5]])
derivative = derivative_qbezier(b, 0.5)
```
"""
function derivative_qbezier(b::QBezier, t=1)
    if b.bpts[2] == b.cpts[1]
        # degenerate case
        return b.bpts[2] - b.bpts[1]
    end
    2(1 - t) * (b.cpts[1] - b.bpts[1]) + 2t * (b.bpts[2] - b.cpts[1])
end

"""
coords(p::Arc, θ::Real)

Computes the coordinates on an elliptical arc at a given angle `θ`.

# Arguments
- `p::Arc`: The elliptical arc.
- `θ::Real`: The angle at which to compute the coordinates.

# Returns
- A 2-element array representing the coordinates on the arc at angle `θ`.

# Example
```julia
p = Arc(c=[0, 0], rx=1.0, ry=1.2, initangle=0, finalangle=π)
point = coords(p, π/4)
```
"""
function coords(p::Arc, θ::Real)
    a = p.rx
    b = p.ry
    c = p.c
    ang = p.rot
    return R(ang)([a * cos(θ), b * sin(θ)])
end

"""
tangent_at(p::Arc, θ::Real)

Computes the tangent vector of an elliptical arc at a given angle `θ`.

# Arguments
- `p::Arc`: The elliptical arc.
- `θ::Real`: The angle at which to compute the tangent vector.

# Returns
- A 2-element array representing the tangent vector at angle `θ`.

# Example
```julia
p = Arc(c=[0, 0], rx=1.0, ry=1.2, initangle=0, finalangle=π)
tangent = tangent_at(p, π/4)
```
"""
function tangent_at(p::Arc, θ::Real)
    a = p.rx
    b = p.ry
    ang = p.rot
    # Derivatives with respect to θ
    dx_dθ = -a * sin(θ)
    dy_dθ = b * cos(θ)
    # Apply rotation
    derivative = R(ang)([dx_dθ, dy_dθ])
    return derivative
end

"""
angle_at(p::Arc, θ::Real)

Computes the angle of the tangent vector of an elliptical arc at a given angle `θ`.

# Arguments
- `p::Arc`: The elliptical arc.
- `θ::Real`: The angle at which to compute the tangent angle.

# Returns
- The angle of the tangent vector at angle `θ`.

# Example
```julia
p = Arc(c=[0, 0], rx=1.0, ry=1.2, initangle=0, finalangle=π)
angle = angle_at(p, π/4)
```
"""
function angle_at(p::Arc, θ::Real)
    derivative = -tangent_at(p, θ)
    ang = atan(derivative[2], derivative[1])
end

struct Obj <: Mark
    label
    pos
end

function Vizagrams.ζ(o::Obj)
    if o.label isa LaTeXString
        return T(o.pos...)T(-0.03, 0)TextMark(text=o.label, fontsize=0.15, anchor=:c)
    end
    T(o.pos...)TextMark(text=o.label, fontsize=0.15, anchor=:c)
end

Obj(; label=L"A", pos=[0, 0]) = Obj(label, pos)

struct Morphism <: Mark
    pos::Vector
    offset::Real #-5 a 5
    curve::Real #-5 a 5
    length::Real #0 a 100
    level::Int # 1 ou 2
    label::AbstractString
    labelposition::Real #0 a 100
    labelalign # left, center, right
    labeltransform::Union{H,S,G}
    linestyle::S
    auto::Bool # If it is automorphism (A,A) or not (A,B)
    fontsize::Real
    fontfamily::AbstractString
end

"""
Morphism(; pos=[[0, 0], [1, 0]], offset=0, curve=0, length=1, level=1, label="", labelposition=0.5, labelalign=:left, labeltransform=S(), auto=false)

Constructs a `Morphism` object with specified properties.

# Arguments
- `pos::Vector`: Positions of the morphism (default is `[[0, 0], [1, 0]]`).
- `offset::Real`: Offset value (default is `0`).
- `curve::Real`: Curve value (default is `0`).
- `length::Real`: Length value (default is `1`).
- `level::Int`: Level value (default is `1`).
- `label::AbstractString`: Label for the morphism (default is `""`).
- `labelposition::Real`: Position of the label (default is `0.5`).
- `labelalign`: Alignment of the label (default is `:left`).
- `labeltransform::Union{H,S,G}`: Transformation for the label (default is `S()`).
- `auto::Bool`: Indicates if it is an automorphism (default is `false`).

# Returns
- A `Morphism` object.

# Example
```julia
morphism = Morphism(pos=[[0, 0], [1, 1]], label="f")
```
"""
function Morphism(;
    pos=[[0, 0], [1, 0]],
    offset=0,
    curve=0,
    length=1,
    level=1,
    label="",
    labelposition=0.5,
    labelalign=:left,
    labeltransform=S(),
    linestyle=S(:vectorEffect => "none", :strokeLinecap => :round, :strokeWidth => 1.012),
    auto=false,
    fontsize=0.1,
    fontfamily="Monaco",
)
    return Morphism(pos, offset, curve, length, level, label, labelposition, labelalign, labeltransform, linestyle, auto, fontsize, fontfamily)
end

function Vizagrams.ζ(m::Morphism)
    if m.auto

        bpts = [[0.2, 0], [-0.2, 0]]
        cpts = (m.curve + 1) .* [[0.8, 1], [-0.8, 1]]

        a = CBezier(bpts, cpts)
        a_angle = cbezier_angle(a, 0)
        a_start = a.bpts[1]
        arrowhead = T(a_start...)R(π + a_angle)U(0.05)T(-1, -1) * (CBezier() + T(0, 2)M(0)CBezier())

        # a = Arc(c=[0, 0], rx=0.8, ry=1.0, initangle=-π / 4, finalangle=π + π / 4, rot=0π / 4)
        # a_start = coords(a, a.initangle)
        # arrowhead = T(a_start...)R(angle_at(a, a.initangle) + 0.1)U(5 * 0.03)T(-1, -1) * (CBezier() + T(0, 2)M(0)CBezier())

        d = T(0, 0.1)T(m.pos[1]...)m.linestyle * U(0.5) * (a + arrowhead)
        # d = T(0, 0.25)T(m.pos[1]...)S(:strokeLinecap => :round, :strokeWidth => 2.0) * U(0.2) * (a + arrowhead)

        labelpos = m.pos[1] + [0.0, 0.65] + m.curve * [0, 0.37]
        # marklabel = T(labelpos...)TextMark(text=m.label, fontfamily="Monaco", fontsize=0.1, anchor=:n)
        marklabel = T(labelpos...)TextMark(text=m.label, fontfamily=m.fontfamily, fontsize=m.fontsize, anchor=:n)
        return d + m.labeltransform * marklabel
    end

    # If Morphism is not an automorphism
    curvepoint = m.curve * normalize(R(π / 2)(m.pos[2] - m.pos[1])) + (m.pos[2] + m.pos[1]) ./ 2

    line = QBezier(bpts=m.pos, cpts=[curvepoint])
    line = shorten_qbezier(line, m.length)

    der = derivative_qbezier(line)
    ang = atan(der[2], der[1])
    arrowhead = U(0.03) * (T(-1, -1) * (CBezier() + T(0, 2)M(0)CBezier()))
    # arrowhead = T(m.pos[2]...)R(ang)arrowhead
    arrowhead = T(line.bpts[2]...)R(ang)arrowhead

    labelpos = (m.pos[2] + m.pos[1]) * m.labelposition
    labelpos = m.curve / 2 * normalize(R(π / 2)(m.pos[2] - m.pos[1])) + (m.pos[2] + m.pos[1]) * m.labelposition
    labelpad = 0.05 * normalize(R(π / 2)(m.pos[2] - m.pos[1]))
    labelpad = [labelpad[1], abs(labelpad[2])]
    marklabel = T(labelpos...)T(labelpad...)TextMark(text=m.label, fontfamily=m.fontfamily, fontsize=m.fontsize, anchor=:s)
    bblabel = boundingbox(marklabel)
    if !isnothing(bblabel)
        background = S(:fill => :white)Vizagrams.rectangle(boundingbox(marklabel)...)
        marklabel = background + marklabel
    end


    lineang = atan((m.pos[2]-m.pos[1])[2], (m.pos[2]-m.pos[1])[1])
    if !isnothing(boundingbox(marklabel))
        horizontal_adj = boundingwidth(marklabel) * sin(lineang) / 2
        marklabel = T(-horizontal_adj, 0) * marklabel
    end

    # Quick and dirty implementation of approx offset curve for quadratic bezier
    if m.level == 2

        der0 = derivative_qbezier(line, 0)
        ang0 = atan(der0[2], der0[1])
        transf0 = T(R(ang0)([0.0, 0.02])...)

        der05 = derivative_qbezier(line, 0.5)
        ang05 = atan(der05[2], der05[1])
        transf05 = T(R(ang05)([0.0, 0.02 + 0.02 * max(0, m.curve)])...)

        der1 = derivative_qbezier(line, 1)
        ang1 = atan(der1[2], der1[1])
        transf1 = T(R(ang1)([-0.05, 0.02])...)

        bpts = [transf0(line.bpts[1]), transf1(line.bpts[2])]
        cpts = [transf05(line.cpts[1])]

        linetop = QBezier(bpts=bpts, cpts=cpts)

        der0 = derivative_qbezier(line, 0.0)
        ang0 = atan(der0[2], der0[1])
        transf0 = T(R(ang0)([0.0, -0.02])...)

        der05 = derivative_qbezier(line, 0.5)
        ang05 = atan(der05[2], der05[1])
        transf05 = T(R(ang05)([0.0, -0.02 - 0.02 * max(0, -m.curve)])...)

        der1 = derivative_qbezier(line, 1)
        ang1 = atan(der1[2], der1[1])
        transf1 = T(R(ang1)([-0.05, -0.02])...)

        bpts = [transf0(line.bpts[1]), transf1(line.bpts[2])]
        cpts = [transf05(line.cpts[1])]

        linebot = QBezier(bpts=bpts, cpts=cpts)

        line = linetop + linebot
    end


    # return S(:strokeLinecap => :round, :strokeWidth => 2.0) * (line + arrowhead) + m.labeltransform * marklabel
    return m.linestyle * (line + arrowhead) + m.labeltransform * marklabel
end

"""
obj(label; x=0, y=0)

Constructs an `Obj` object with a specified label and position.

# Arguments
- `label`: The label for the object.
- `x::Real`: The x-coordinate of the position (default is `0`).
- `y::Real`: The y-coordinate of the position (default is `0`).

# Returns
- An `Obj` object.

# Example
```
`
object = obj("A", x=1, y=2)
"""
function obj(label; x=0, y=0)
    Obj(latexstring(label), [1.2x, 1.2y])
end

"""
anchorobj(a::Obj, anchor::Symbol=:e; offset=0.1)

Computes the anchor position of an object (`Obj`) based on a specified anchor point.

# Arguments
- `a::Obj`: The object to anchor.
- `anchor::Symbol`: The anchor point (default is `:e`).
- `offset::Real`: The offset value (default is `0.1`).

# Returns
- A 2-element array representing the anchor position.

# Example
```julia
object = Obj(label="A", pos=[0, 0])
anchor_position = anchorobj(object, :n)
```
"""
function anchorobj(a::Obj, anchor::Symbol=:e; offset=0.1)
    bb = boundingbox(a)
    if anchor == :e
        x = bb[2][1] + offset
        # y = (bb[2][2] + bb[1][2]) / 2
        y = a.pos[2]
    elseif anchor == :w
        x = bb[1][1] - offset
        # y = (bb[2][2] + bb[1][2]) / 2
        y = a.pos[2]
    elseif anchor == :n
        # x = (bb[2][1] + bb[1][1]) / 2
        x = a.pos[1]
        y = bb[2][2] + offset
    elseif anchor == :s
        # x = (bb[2][1] + bb[1][1]) / 2
        x = a.pos[1]
        y = bb[1][2] - offset
    elseif anchor == :ne
        x = bb[2][1] + offset
        y = bb[2][2] + offset
    elseif anchor == :nw
        x = bb[1][1] - offset
        y = bb[2][2] + offset
    elseif anchor == :se
        x = bb[2][1] + offset
        y = bb[1][2] - offset
    elseif anchor == :sw
        x = bb[1][1] - offset
        y = bb[1][2] + -offset
    else
        throw("Use :n,:s,:e,:w,:nw,:ne,:sw,:se")
    end
    return [x, y]
end


"""
mor(a::Obj, b::Obj, label=""; offset=0.1, kwargs...)

Constructs a `Morphism` object between two objects (`Obj`) with a specified label and offset.

# Arguments
- `a::Obj`: The starting object.
- `b::Obj`: The ending object.
- `label::AbstractString`: The label for the morphism (default is `""`).
- `offset::Real`: The offset value (default is `0.1`).
- `kwargs`: Additional keyword arguments.

# Returns
- A `Morphism` object.

# Example
```julia
obj1 = Obj(label="A", pos=[0, 0])
obj2 = Obj(label="B", pos=[1, 1])
morphism = mor(obj1, obj2, label="f")
```
"""
function mor(a::Obj, b::Obj, label=""; offset=0.1, kwargs...)
    label = length(label) > 0 ? latexstring(label) : ""
    anchor_a, anchor_b = determine_anchor(a, b)
    # p1 = anchorobj(a, :e, offset=offset)
    # p2 = anchorobj(b, :w, offset=offset)
    p1 = anchorobj(a, anchor_a, offset=offset)
    p2 = anchorobj(b, anchor_b, offset=offset)
    Morphism(; pos=[p1, p2], label=label, kwargs...)
end

"""
mor(a::Obj, label=""; kwargs...)

Constructs an automorphism `Morphism` object for a single object (`Obj`) with a specified label.

# Arguments
- `a::Obj`: The object.
- `label::AbstractString`: The label for the morphism (default is `""`).
- `kwargs`: Additional keyword arguments.

# Returns
- An automorphism `Morphism` object.

# Example
```julia
obj = Obj(label="A", pos=[0, 0])
automorphism = mor(obj, label="id")
```
"""
function mor(a::Obj, label=""; kwargs...)
    label = length(label) > 0 ? latexstring(label) : ""
    Morphism(; pos=[a.pos], label=label, auto=true, kwargs...)
end

function idmor(a::Obj; labeltransform=T(0.03, 0), label=nothing, kwargs...)
    if length(a.label) ≥ 3 && isnothing(label)
        label = latexstring("id_{" * a.label[2:end-1] * "}")
    end
    label = isnothing(label) ? L"id" : label
    Morphism(; pos=[a.pos], label=label, auto=true, labeltransform=labeltransform, kwargs...)
end

# function mor(mf::Morphism, mg::Morphism, label="", level=2; kwargs...)
#     label = length(label) > 0 ? latexstring(label) : ""
#     p1 = (mf.pos[1] + mf.pos[2]) / 2
#     p2 = (mg.pos[1] + mg.pos[2]) / 2
#     Morphism(; pos=[p1, p2], label=label, auto=true, level=leve, kwargs...)
# end

# Function to calculate anchor based on relative positions of objects a and b
function determine_anchor(a::Obj, b::Obj)
    # Extract the positions of a and b
    pos_a = a.pos
    pos_b = b.pos

    # Difference in positions
    dx = pos_b[1] - pos_a[1]  # Horizontal difference
    dy = pos_b[2] - pos_a[2]  # Vertical difference

    # Determine the anchor for a and b based on position differences
    anchor_a = :e  # Default anchor for a
    anchor_b = :w  # Default anchor for b

    if abs(dx) > abs(dy)
        if dx > 0
            # b is to the right of a
            anchor_a = :e
            anchor_b = :w
        else
            # b is to the left of a
            anchor_a = :w
            anchor_b = :e
        end
    else
        if dy > 0
            # b is above a
            anchor_a = :n
            anchor_b = :s
        else
            # b is below a
            anchor_a = :s
            anchor_b = :n
        end
    end

    # Add diagonal cases when dx and dy are comparable
    if abs(dx) ≈ abs(dy)
        if dx > 0 && dy > 0
            # b is to the top-right of a
            anchor_a = :ne
            anchor_b = :sw
        elseif dx > 0 && dy < 0
            # b is to the bottom-right of a
            anchor_a = :se
            anchor_b = :nw
        elseif dx < 0 && dy > 0
            # b is to the top-left of a
            anchor_a = :nw
            anchor_b = :se
        elseif dx < 0 && dy < 0
            # b is to the bottom-left of a
            anchor_a = :sw
            anchor_b = :ne
        end
    end

    return (anchor_a, anchor_b)
end

function qbezier_point(qb::QBezier, t::Real)
    P0, P2 = qb.bpts
    P1 = qb.cpts[1]

    x = (1 - t)^2 * P0[1] + 2 * (1 - t) * t * P1[1] + t^2 * P2[1]
    y = (1 - t)^2 * P0[2] + 2 * (1 - t) * t * P1[2] + t^2 * P2[2]

    return [x, y]
end

function shorten_qbezier(qb::QBezier, l::Real)
    bpts = [qbezier_point(qb, (1 - l)), qbezier_point(qb, l)]
    QBezier(bpts=bpts, cpts=qb.cpts)
end
