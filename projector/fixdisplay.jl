using CoordinateTransformations
using FixedSizeArrays

if length(ARGS) < 1
     error("Screen name not supplied")
end

resolution = Vec(1024,768)
T = Translation(resolution/3)
for θ = linspace(0,1.9π,100)
    trans = T ∘ Rotation2D(θ) ∘ inv(T)

    # Hack out homogenous transform coeffs for xrandr
    H = [Array(trans.M) Array(trans.v);
         0     0        1]
    Hstr = join(map(x->@sprintf("%.2f",x), H'), ",")
    try
         run(`xrandr --output $(ARGS[1]) --transform $Hstr`)
    end
    sleep(0.05)
end
