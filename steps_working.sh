#!/bin/bash

# This is a bash script. That first line needs to be there.
# Need to change 'base' and 'exe_dir' for your specific machine


## THE BASICS
base="/Users/kitung/Desktop/thesis_material/Albert_codes"
exe_dir="$base/H_He_integrated"
#mc="$exe_dir/ie_300.dat"
#pwd
make spot


## SETTING THINGS UP
fluxtype=4
#2 = bolometric, 3 = monochromatic at 2keV, 4 = first energy band, 5 = second energy band
# 1 is time, since we use this as the column identifier when telling gnuplot what to print

E1Lower=0.2  # in keV; lower bound of first energy band (NICER effective area)
E1Upper=12   # in keV; upper bound of first energy band
E2Lower=0.2  # in keV; lower bound of second energy band (Hydrogen/Helium crossover)
E2Upper=0.3  # in keV; upper bound of second energy band
Emono=1.5    # in keV; monochromatic light curve energy value (NICER peak effective area)

if test "$fluxtype" -eq 2
	then fluxtypefile="bolo"
elif test "$fluxtype" -eq 3
	then fluxtypefile="mono_2keV"
elif test "$fluxtype" -eq 4
	then fluxtypefile="band_${E1Lower}_${E1Upper}"
else 
	fluxtypefile="band_${E2Lower}_${E2Upper}"
fi

gray=1    # 0 = isotropic emission, 1 = atmosphere
if test "$gray" -eq 0 # isotropic
	then gray_type="iso"
else # graybody
	gray_type="gray"
fi
atmosphere=0     # 0 = Hydrogen, 1 = Helium
if test "$atmosphere" -eq 0 # Hydrogen
	then atmo_type="h"
else # graybody
	atmo_type="he"
fi

## SETTING VARIABLES
day=$(date +%m%d%y)  # make the date a string and assign it to 'day', for filename

# integers
numtheta=1 # number of theta bins; for a small spot, only need one
NS_model=3 # 1 (oblate) or 3 (spherical); don't use 2
numbins=128 # number of phase bins or flux data points in a light curve; 128 is standard

# doubles -- using "e" notation
spin=500 # in Hz
mass=140E-02 # in Msun
radius=115E-01 # in km
inclination=90 # in degrees
emission=90 # in degrees
rho=20  # in degrees
phaseshift=0 # this is used when comparing with data, otherwise keep to 0
temp=0.10 # in keV
distance=1.41941169e20 # 4.6 kpc in meters

out_dir="$exe_dir/output/steps_test"
if test "$gray" -eq 0
	then out_file="${out_dir}"/"${day}"_bb.txt #blackbody
else
	out_file="${out_dir}"/"${day}"_"${atmo_type}".txt #h or he
fi


## MAKING NECESSARY DIRECTORIES
if test ! -d "$out_dir" 
   	then mkdir -p "$out_dir"
fi


## RUNNING THE CODE
"$exe_dir/spot" -m "$mass" -r "$radius" -f "$spin" -i "$inclination" -e "$emission" -l "$phaseshift" -M "$Emono" -n "$numbins" -q "$NS_model" -o "$out_file" -p "$rho" -T "$temp" -D "$distance" -t "$numtheta" -u "$E1Lower" -U "$E1Upper" -v "$E2Lower" -V "$E2Upper" -g "$gray" -G "$atmosphere" -2

