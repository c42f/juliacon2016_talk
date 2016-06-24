using FixedSizeArrays
using Displaz
using PointClouds
using PointCloudMatching
using CoordinateTransformations

using NearestNeighbors

typealias V3d Vec{3,Float64}

function genslide_ply(slidenum, trans)
    texturefile = abspath("slides/rasters/slide-$(@sprintf("%02d", slidenum)).png")
    vertex_data = [
        0     0   0  0 1
        4/3   0   0  1 1
        4/3   1   0  1 0
        0     1   0  0 0
        4/3/2 1/2 0  0 0
    ]
    trans2 = trans ∘ Translation(-4/3/2, -1/2, 0)
    for i=1:size(vertex_data,1)
        vertex_data[i,1:3] = [transform(trans2, Point(vertex_data[i,1:3]...))...]
    end
    plyname = abspath("slides/rasters/slide-$(@sprintf("%02d", slidenum)).ply")
    open(plyname, "w") do f
        write(f,
            """
            ply
            format ascii 1.0
            comment TextureFile $texturefile
            element vertex 5
            property double x
            property double y
            property double z
            property double u
            property double v
            element face 1
            property list int int vertex_index
            end_header
            $(join([@sprintf("%.3f", x) for x in vec(vertex_data')], " "))
            4 0 1 2 3
            """
        )
    end
    plyname
end

maxslides = 30
slideposes = Dict(
    2=> (Vec(318594.281000, 7358164.560005, 29), 154.318000),
    3=> (Vec(389819.050910, 7281222.665877, 12.290000), 681.855143),
    4=> (Vec(482417.480011, 7207376.740005, 12.940000), 248.705282),
    5=> (Vec(436865.792499, 7244398.039191, 22.586765), 76.534792),
    #5=> (Vec(482369.720001, 7207425.970001, 13.500000), 196.309295),
    #2=> (Vec(318627.684999, 7358030.485001, 30.711000), 154.317704, Vec(0.0,90.0,0.0))
    #2=> (Vec(318651.647996, 7358057.850998, 29.608999), 138.744194, Vec(-106.905765, 25.132797, 0))
)

slidecommands = Dict(
    #2=> ()->run(`displaz -viewposition 318651.647996 7358057.850998 29.608999 -viewradius 138.744194 -viewangles -106.905765 25.132797 0`)
)

function showslide(slidenum)
    angles = Vec(0.0,90.0,0.0)
    pose = (Vec(0.0,0.0,0.0), 0.866)
    if haskey(slideposes, slidenum)
        pose = slideposes[slidenum]
    end
    (transvec, range) = pose
    trans = Translation(transvec) ∘ #RotationYZ(deg2rad(angles[2])) ∘ RotationXY(deg2rad(angles[1]-90))) ∘
            Translation(0.0, 0.0, range - 0.866)
    filename = genslide_ply(slidenum, trans)
    if haskey(slidecommands, slidenum)
        slidecommands[slidenum]()
    end
    run(`displaz -viewposition $(transvec[1]) $(transvec[2]) $(transvec[3]) -viewradius $range -viewangles $(angles[1]) $(angles[2]) 0 -label Slide $filename`)
end

run(`displaz -script`)
run(`displaz -toggleui`)
#run(`displaz -viewposition 0.66666 0.5 0`)
#run(`displaz -viewradius 0.866`)

slidenum = 1
showslide(slidenum)

run(`displaz -script -label GladstoneLidar data/gladstone_houses.laz data/121116_050444.laz data/lines/Poles.ply data/lines/point_vernon.laz data/lines/Lines.ply data/icp/matched.ply data/icp/unmatched.ply`)




Displaz.event_loop(
        KeyEvent("n")=>Void,
        KeyEvent("p")=>Void,
        KeyEvent("t")=>Void
) do event, arg
    global slidenum
    if event == KeyEvent("n")
        slidenum = min(maxslides, slidenum + 1)
        showslide(slidenum)
    elseif event == KeyEvent("p")
        slidenum = max(1, slidenum - 1)
        showslide(slidenum)
    elseif event == KeyEvent("t")
        run(`displaz -toggleui`)
    end
end
