#!/bin/bash

# This is a bash script. That first line needs to be there.
# Need to change 'base' and 'exe_dir' for your specific machine


## THE BASICS
base="/Users/kitung/Desktop/thesis_material/Albert_codes"
exe_dir="$base/H_He_integrated"
mc="$exe_dir/ie_300.dat"
#pwd
make spot


## SETTING THINGS UP
fluxtype=4
#2 = bolometric, 3 = monochromatic at 2keV, 4 = first energy band, 5 = second energy band
# 1 is time, since we use this as the column identifier when telling gnuplot what to print
E1Lower=0.3  #Slavko's XMM observation on J0437
E1Upper=0.7
E2Lower=0.7
E2Upper=2
Emono=0.7

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
numtheta=5 # number of theta bins; for a small spot, only need one
NS_model=3 # 1 (oblate) or 3 (spherical); don't use 2
numbins=25 # 25 bins in Slavko's observation per rotation.

# doubles -- using "e" notation
spin=173.69 # in Hz
mass=140E-02 # in Msun
radius=100E-01 # in km, free para R
inclination=42 # in degrees, free para zeta
emission=30 # in degrees, free para alpha
rho=90  # 3.5 km arclength in degrees, free para R2
phaseshift=0 # this is used when comparing with data, otherwise keep to 0
temp=0.0310 # close to lowest temperature choice for hydrogen atmosphere
distance=4.84e18 # 156.79 pc in meters

# Writing file names
#  gnu_file is a text file storing gnuplot commands
#  lightcurve is the graphics output file for gnu_file
#  out_dir is the full directory of the output flux table
#  out_file is the output flux table
gnu_file="$exe_dir/output/plots/gplot_${day}_${fluxtypefile}.txt"
lightcurve="$exe_dir/output/plots/lightcurve_${day}_${fluxtypefile}"
out_dir="$exe_dir/output/q$NS_model/m$mass/r$radius/f$spin/i$inclination/e$emission/p$rho/T$temp/n$numtheta"
if test "$gray" -eq 0
	then out_file="${out_dir}"/slavkoJ0437_"${day}"_bb-2.txt #blackbody
else
	out_file="${out_dir}"/slavkoJ0437_"${day}"_"${atmo_type}".txt 
fi


## MAKING NECESSARY DIRECTORIES
if test ! -d "$exe_dir/output/plots" 
   	then mkdir -p "$exe_dir/output/plots"
fi
if test ! -d "$out_dir" 
   	then mkdir -p "$out_dir"
fi


## MAKING THE GNUPLOT COMMAND FILE
#echo "# Constant star and spot properties: " > "$gnu_file"
#echo "# Mass: $mass Msun" >> "$gnu_file"
#echo "# Radius: $radius km" >> "$gnu_file"
#echo "# NS shape model: $NS_model" >> "$gnu_file"
#echo "# Inclination angle: $inclination degrees" >> "$gnu_file"
#echo "# Emission angle of spot: $emission degrees" >> "$gnu_file"
#echo "# Spin frequency: $spin Hz" >> "$gnu_file"
#echo "# Phase shift: $phaseshift" >> "$gnu_file"
#echo "# Distance to NS: $distance m" >> "$gnu_file"
#echo "# Rho: $rho degrees" >> "$gnu_file"
#echo "# Number of physical spot bins: $numtheta" >> "$gnu_file"
#echo "# Number of phase bins: $numbins" >> "$gnu_file"
#echo "# Spot temperature: $temp keV" >> "$gnu_file"
#echo "# First energy band: $E1Lower to $E1Upper keV" >> "$gnu_file"
#echo "# Second energy band: $E2Lower to $E2Upper keV" >> "$gnu_file"
#echo "# Temperature mesh input file: $input_mesh.txt" >> "$gnu_file"
#echo "set terminal postscript eps enhanced color font 'Times,22';" >> "$gnu_file"
#echo "set output '$lightcurve.eps';" >> "$gnu_file"
#echo "set border 31 lw 1;" >> "$gnu_file"
#echo "set key top left;" >> "$gnu_file"
#echo "set label 'Both spots' at 0.02,0.047 left;" >> "$gnu_file"
#echo "unset key;" >> "$gnu_file"
#echo "set xlabel 'Normalized phase';" >> "$gnu_file"
#if "$normalizeFlux"  # yes normalized
#	then echo "set ylabel 'Normalized flux';" >> "$gnu_file"
#else # not normalized
#	echo "set ylabel 'Flux [photons / (s cm^2)]';" >> "$gnu_file"
#fi

#if test "$fluxtype" -eq 2
#	then echo "set label 'Bolometric' at 0.98,0.98 right;" >> "$gnu_file"
#elif test "$fluxtype" -eq 3 
#	then echo "set label 'Monochromatic, 2 keV' at 0.98,0.75 right;" >> "$gnu_file"
#elif test "$fluxtype" -eq 4
#	then echo "set label 'Low energy band, $E1Lower-$E1Upper keV' at 0.98,0.63 right;" >> "$gnu_file"
#else
#	echo "set label 'High energy band, $E2Lower-$E2Upper keV' at 0.98,0.65 right;" >> "$gnu_file"
#fi

#echo -n "plot [] [0.55:1.4] " >> "$gnu_file"


#echo "Output sent to $out_file"


## RUNNING THE CODE
"$exe_dir/spot" -m "$mass" -r "$radius" -f "$spin" -i "$inclination" -e "$emission" -l "$phaseshift" -M "$Emono" -n "$numbins" -q "$NS_model" -o "$out_file" -p "$rho" -T "$temp" -D "$distance" -t "$numtheta" -u "$E1Lower" -U "$E1Upper" -v "$E2Lower" -V "$E2Upper" -g "$gray" -G "$atmosphere" -2

# Plotting the output file to make a light curve
#echo -n "'$out_file' u 1:$fluxtype w lines lw 5 linecolor rgb 'magenta'; " >> "$gnu_file"


## OUTPUT
#echo Plot sent to "$gnu_file" 
#echo and "$lightcurve.eps"
#echo ""
#gnuplot < "$gnu_file"
#open "$lightcurve.eps"
