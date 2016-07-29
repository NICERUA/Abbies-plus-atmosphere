#!/bin/bash

# This script varies inclination angle from 90 degrees to 10 degrees in 10 degrees increments.

## THE BASICS
base="/Users/kitung/Desktop/thesis_material/Albert_codes"
exe_dir="$base/H_He_integrated"
make spot

## SETTING THINGS UP
fluxtype=4	 # doesn't do anything, as all four columns are printed anyways
E1Lower=0.2  # in keV; lower bound of first energy band (NICER effective area)
E1Upper=10   # in keV; upper bound of first energy band
E2Lower=0.2  # in keV; lower bound of second energy band (Hydrogen/Helium crossover)
E2Upper=0.3  # in keV; upper bound of second energy band
Emono=1.5    # in keV; monochromatic light curve energy value (NICER peak effective area)

gray=1    # 0 = isotropic emission, 1 = atmosphere
if test "$gray" -eq 0 # isotropic
	then gray_type="iso"
else
	gray_type="atmo"  # atmospheric
fi
atmosphere=0          # 0 = Hydrogen, 1 = Helium
if test "$atmosphere" -eq 0 
	then atmo_type="h" # Hydrogen
else
	atmo_type="he"     # Helium
fi

echo "Varying inclination angle from 90 degrees in increments of 10 degrees."

## SETTING VARIABLES
day=$(date +%m%d%y)  # make the date a string and assign it to 'day', for filename

# integers
numtheta=1 # number of theta bins; for a small spot, only need one
NS_model=3 # 1 (oblate) or 3 (spherical); don't use 2
numbins=128

# doubles -- using "e" notation
spin=500 	   # in Hz
mass=1.4 	   # in Msun
radius=13      # in km
inclination=90 # in degrees
emission=90    # in degrees
rho=20  	   # in degrees
phaseshift=0   # this is used when comparing with data, otherwise keep to 0
temp=0.10 	   # in keV
distance=1.41941169e20 # 4.6 kpc in meters

# Writing file names
out_dir="$exe_dir/output/var/var_a_inc"
if test "$gray" -eq 0
	then out_file="${out_dir}"/"${day}"_inc"${inclination}"_bb.txt #blackbody
else
	out_file="${out_dir}"/"${day}"_emi"${emission}"_inc"${inclination}"_"${atmo_type}".txt #h or he
fi


## MAKING NECESSARY DIRECTORIES
if test ! -d "$out_dir" 
   	then mkdir -p "$out_dir"
fi


## MAKING THE DATA FILE(S)
while test "$inclination" -gt 10 # this loop makes all of them EXCEPT FOR THE LAST ONE.
do
	echo "Output sent to $out_file"
	"$exe_dir/spot" -m "$mass" -r "$radius" -f "$spin" -i "$inclination" -e "$emission" -l "$phaseshift" -M "$Emono" -n "$numbins" -q "$NS_model" -o "$out_file" -p "$rho" -T "$temp" -D "$distance" -t "$numtheta" -u "$E1Lower" -U "$E1Upper" -v "$E2Lower" -V "$E2Upper" -g "$gray" -G "$atmosphere" -2
	let inclination=inclination-10
	if test "$gray" -eq 0
		then out_file="${out_dir}"/"${day}"_inc"${inclination}"_bb.txt #blackbody
	else
	    out_file="${out_dir}"/"${day}"_emi"${emission}"_inc"${inclination}"_"${atmo_type}".txt #h or he
	fi
done

# making the last data file (need to do this so that the script writes the gnuplot command file correctly, with the ";"
echo "Output sent to $out_file"
"$exe_dir/spot" -m "$mass" -r "$radius" -f "$spin" -i "$inclination" -e "$emission" -l "$phaseshift" -M "$Emono" -n "$numbins" -q "$NS_model" -o "$out_file" -p "$rho" -T "$temp" -D "$distance" -t "$numtheta" -u "$E1Lower" -U "$E1Upper" -v "$E2Lower" -V "$E2Upper" -g "$gray" -G "$atmosphere" -2

cp /Users/kitung/Desktop/thesis_material/Albert_codes/H_He_integrated/output/var/var_a_inc/"${day}"_* /Users/kitung/Desktop/thesis_material/Albert_codes/plotting_output_spectra/plot_with_variables/inc


