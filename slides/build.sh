#!/bin/bash

latexmk -pdf juliacon_talk.tex

pdftoppm -r 500 juliacon_talk.pdf rasters/slide

for i in rasters/slide*.ppm ; do
    convert $i -alpha on ${i%.ppm}.png
    cat slidemesh.ply | sed -e "s/TEX/$(basename $i .ppm).png/" > ${i%.ppm}.ply
done

