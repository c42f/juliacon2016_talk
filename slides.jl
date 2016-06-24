using FixedSizeArrays
using Displaz
using PointClouds
using PointCloudMatching

using NearestNeighbors

typealias V3d Vec{3,Float64}

run(`displaz -script`)
run(`displaz -toggleui`)
run(`displaz -viewposition 0.66666 0.5 0`)
run(`displaz -viewradius 0.866`)

function showslide(slidenum)
    filename="slides/rasters/slide-$slidenum.ply"
    run(`displaz -label Slide $filename`)
end

maxslides = 20
slidenum = 1

showslide(slidenum)

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
