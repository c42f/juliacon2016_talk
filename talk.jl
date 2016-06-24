using FixedSizeArrays
using Displaz
using PointClouds
using PointCloudMatching

using NearestNeighbors

typealias V3d Vec{3,Float64}

#= Base.(:.+){FSA<:FixedArray}(A::Vector{FSA}, b::FSA) = [a+b for a in A] =#
#= Base.(:.+){FSA<:FixedArray}(b::FSA, A::Vector{FSA}) = [b+a for a in A] =#

foo(v) = V3d(v[1], v[2], 0.1*(v[1].^2+v[2].^2))

function toroid(R1,R2,theta,phi)
    v = [R1+R2*cos(phi),0,R2*sin(phi)]
    ct,st = sin(theta),cos(theta)
    V3d([ ct st 0;
         -st ct 0;
         0  0  1] * v)
end

N = 10000
#c1 = PointCloud([foo(randn(V3d)) for _=1:N])
#c2 = PointCloud([foo(randn(V3d)) .+ Vec(0,0,5) for _=1:N])
R1 = 10.0
R2 = 2.0
c1 = PointCloud(V3d[toroid(R1, R2, 2π*rand(),2π*rand()) for _=1:N])
c2 = PointCloud(V3d[toroid(R1, R2, 2π*rand(),2π*rand())+V3d(1,0,0) for _=1:N])
add_normals!(c1)
add_normals!(c2)

clearplot()

function icpdebug(c1, c2, T, ref_inds, inlier_inds)
    println(T)
    p1 = positions(c1)
    p2 = copy(positions(c2))
    @fslice p2[:,:] .+= T
    matches = similar(p1, 2*length(inlier_inds))
    matches[1:2:end] = p1[inlier_inds]
    matches[2:2:end] = p2[ref_inds[inlier_inds]]
    plot3d!(p1, label="Cloud1", color=[0.5,0.5,1], markershape='x')
    plot3d!(p2, label="Cloud2", color=[1,0.5,0.5], markershape='+')
    plot3d!(matches, label="Matches", markershape='-', linebreak=2)
    wait(KeyEvent("Space"))
end

Displaz.event_loop(
        KeyEvent("c")=>Void,
        KeyEvent("q")=>Void,
        KeyEvent("u")=>CursorPosition
) do event, arg
    @show event, arg
    global c1, c2
    if event == KeyEvent("q")
        return false
    elseif event == KeyEvent("c")
        clearplot()
    elseif event == KeyEvent("u")
        println("ICP")
        register(c1, c2,
                 iterfunc=(T,inds,inlier_inds)->icpdebug(c1,c2,T,inds,inlier_inds))
        println("Done")
        #=
        arg::CursorPosition
        p1 = positions(c1)
        p2 = positions(c2)
        @fslice p1[:,:] .+= 0.01*randn(3) + [0,0,0.01]
        idx = find_closest_points(dpositions(c1), c2)
        matches = similar(p1, 2*length(p1))
        matches[1:2:end] = p1
        matches[2:2:end] = p2[idx]
        plot3d!(p1, label="Cloud1", color=[0.8,0.8,1], markershape='x')
        plot3d!(p2, label="Cloud2", color=[1,0.8,0.8], markershape='+')
        plot3d!(matches, label="Matches", markershape='-', linebreak=2)
        #plot3d!([arg.pos...], markersize=[1], label="Cursor")
        =#
    end
end
