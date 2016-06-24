using CoordinateTransformations
using FixedSizeArrays

resolution = Vec(1024,768)
T = Translation(resolution/2)
for θ = linspace(0,2π,100)
    trans = T ∘ Rotation2D(θ) ∘ inv(T)

    # Hack out homogenous transform coeffs for xrandr
    H = [Array(trans.M) Array(trans.v);
         0     0        1]
    Hstr = join(map(x->@sprintf("%.2f",x), H'), ",")
    run(`xrandr --output HDMI2 --transform $Hstr`)
    sleep(0.1)
end
