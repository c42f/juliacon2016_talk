#!/bin/bash

xrandr --output HDMI2 --mode 1024x768 --same-as eDP1 
xrandr --output HDMI2 --transform 1.0,0,-30,0,1,0,0,0,1
