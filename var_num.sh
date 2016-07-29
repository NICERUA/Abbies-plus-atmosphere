#!/bin/bash

base="/Users/jasper/Documents"
exe_dir="$base/spot"
pwd
make spot

fluxtype=2
#2 = bolometric, 3 = monochromatic at 2keV, 4 = first energy band, 5 = second energy band
E1Lower=2  # in keV; lower bound of first energy band
E1Upper=3  # in keV; upper bound of first energy band
E2Lower=5  # in keV; lower bound of second energy band
E2Upper=6  # in keV; upper bound of second energy band

normalizeFlux=true  # false = no, true = yes; still need to add or remove -N flag in command line (-N means yes)

if test "$fluxtype" -eq 2
	then fluxtypefile="bolo"
fi
if test "$fluxtype" -eq 3
	then fluxtypefile="mono_2keV"
fi
if test "$fluxtype" -eq 4
	then fluxtypefile="band_${E1Lower}_${E1Upper}"
fi
if test "$fluxtype" -eq 5 
	then fluxtypefile="band_${E2Lower}_${E2Upper}"
fi

gray=0 # 0 = isotropic emission, 1 = graybody
if test "$gray" -eq 0
	then gray_type="iso"
fi
if test "$gray" -eq 1
	then gray_type="gray"
fi

echo "Varying Spot Mesh"

## SETTING VARIABLES
day=$(date +%m%d%y)  # make the date a string and assign it to 'day', for filename

# integers
numtheta=1 # number of theta bins; for a small spot, only need one
NS_model=3 # 1 (oblate) or 3 (spherical); don't use 2
numbins=64

# doubles -- using "e" notation
spin=581 # in Hz
mass=1600e-3 # in Msun
radius=12 # in km
inclination=10 # in degrees
emission=60 # in degrees
rho=20  # in degrees
phaseshift=0.0 # this is used when comparing with data
temp=2 # in keV
distance=1.85141655e20 # 6 kpc in meters
#distance=3.08567758e20 # 10 kpc in meters

in_file="$exe_dir/input/test_input_4"
in_file_to_plot="input/test_input_4"
input_mesh="mesh/TmeshTall.txt"

gnu_file="$exe_dir/output/plots/gplot_${day}_num_p${rho}_${fluxtypefile}.txt"    # name of the text file storing gnuplot commands
lightcurve="$exe_dir/output/plots/lightcurve_${day}_num_p${rho}_${fluxtypefile}" # the lightcurve graphics output file
tex_file="$exe_dir/output/plots/plot_${day}_num_p${rho}_${fluxtypefile}.tex"     # TeX file output with the parameters in the comment

if test "$NS_model" -eq 1
	then NSshape="an oblate"
fi
if test "$NS_model" -eq 3
	then NSshape="a spherical"
fi

## MAKING THE GNUPLOT COMMAND FILE
echo "# Constant star and spot properties: " > "$gnu_file"
echo "# Mass: $mass Msun" >> "$gnu_file"
echo "# Radius: $radius km" >> "$gnu_file"
echo "# NS shape model: $NS_model" >> "$gnu_file"
echo "# Inclination angle: $inclination degrees" >> "$gnu_file"
echo "# Emission angle of spot: $emission degrees" >> "$gnu_file"
echo "# Spin frequency: $spin Hz" >> "$gnu_file"
echo "# Phase shift: $phaseshift" >> "$gnu_file"
echo "# Distance to NS: $distance m" >> "$gnu_file"
echo "# Rho: $rho degrees" >> "$gnu_file"
#echo "# Number of physical spot bins: $numtheta" >> "$gnu_file"
echo "# Number of phase bins: $numbins" >> "$gnu_file"
echo "# Spot temperature: $temp keV" >> "$gnu_file"
echo "# First energy band: $E1Lower to $E1Upper keV" >> "$gnu_file"
echo "# Second energy band: $E2Lower to $E2Upper keV" >> "$gnu_file"
#echo "# Temperature mesh input file: $input_mesh.txt" >> "$gnu_file"
echo "set terminal postscript eps enhanced color font 'Times,22';" >> "$gnu_file"
echo "set output '$lightcurve.eps';" >> "$gnu_file"
echo "set key top center;" >> "$gnu_file"
echo "set border 31 lw 1;" >> "$gnu_file"
echo "set xlabel 'Normalized phase';" >> "$gnu_file"
if "$normalizeFlux"  # yes normalized
	then echo "set ylabel 'Normalized flux';" >> "$gnu_file"
else # not normalized
	echo "set ylabel 'Flux [photons / (s cm^2 keV)]';" >> "$gnu_file"
fi

if test "$fluxtype" -eq 2
	then echo "set label 'Bolometric flux' at 0.98,0.82 right;" >> "$gnu_file"
fi
if test "$fluxtype" -eq 3
	then echo "set label 'Monochromatic flux at 2 keV' at 0.98,0.75 right;" >> "$gnu_file"
fi
if test "$fluxtype" -eq 4
	then echo "set label 'Energy band flux for $E1Lower to $E1Upper keV' at 0.98,0.75 right;" >> "$gnu_file"
fi
if test "$fluxtype" -eq 5 
	then echo "set label 'Energy band flux for $E2Lower to $E2Upper keV' at 0.98,0.82 right;" >> "$gnu_file"
fi

echo -n "plot " >> "$gnu_file"

out_dir="$exe_dir/output/q$NS_model/m$mass/r$radius/f$spin/i$inclination/e$emission/p$rho/T$temp/n$numtheta"
out_file="${out_dir}"/"${day}"_"${gray_type}".txt
if test ! -d "$out_dir"
    	then mkdir -p "$out_dir"
	fi
	echo "Output sent to $out_file"
	"$exe_dir/spot" -m "$mass" -r "$radius" -f "$spin" -i "$inclination" -e "$emission" -l "$phaseshift" -n "$numbins" -q "$NS_model" -o "$out_file" -p "$rho" -T "$temp" -D "$distance" -t "$numtheta" -u "$E1Lower" -U "$E1Upper" -v "$E2Lower" -V "$E2Upper" -N 
	echo -n "'$out_file' u 1:$fluxtype w lines lw 4 title 'mesh = $numtheta x $numtheta', " >> "$gnu_file"
	numtheta=5
	out_dir="$exe_dir/output/q$NS_model/m$mass/r$radius/f$spin/i$inclination/e$emission/p$rho/T$temp/n$numtheta"
	out_file="${out_dir}"/"${day}"_"${gray_type}".txt

## MAKING THE DATA FILE(S)
while test "$numtheta" -lt 20  # this loop makes all of them EXCEPT FOR THE LAST ONE.
do
	if test ! -d "$out_dir"
    	then mkdir -p "$out_dir"
	fi
	echo "Output sent to $out_file"
	"$exe_dir/spot" -m "$mass" -r "$radius" -f "$spin" -i "$inclination" -e "$emission" -l "$phaseshift" -n "$numbins" -q "$NS_model" -o "$out_file" -p "$rho" -T "$temp" -D "$distance" -t "$numtheta" -u "$E1Lower" -U "$E1Upper" -v "$E2Lower" -V "$E2Upper" -N 
	echo -n "'$out_file' u 1:$fluxtype w lines lw 4 title 'mesh = $numtheta x $numtheta', " >> "$gnu_file"
	let numtheta=numtheta+5
	out_dir="$exe_dir/output/q$NS_model/m$mass/r$radius/f$spin/i$inclination/e$emission/p$rho/T$temp/n$numtheta"
	out_file="${out_dir}"/"${day}"_"${gray_type}".txt
done
if test ! -d "$out_dir"
   	then mkdir -p "$out_dir"
fi
echo "Output sent to $out_file"
"$exe_dir/spot" -m "$mass" -r "$radius" -f "$spin" -i "$inclination" -e "$emission" -l "$phaseshift" -n "$numbins" -q "$NS_model" -o "$out_file" -p "$rho" -T "$temp" -D "$distance" -t "$numtheta" -u "$E1Lower" -U "$E1Upper" -v "$E2Lower" -V "$E2Upper" -N 
echo -n "'$out_file' u 1:$fluxtype w lines lw 4 title 'mesh = $numtheta x $numtheta'; " >> "$gnu_file"


## OUTPUT
echo Plot data sent to "$gnu_file" 
echo and "$lightcurve.eps"
echo ""
gnuplot < "$gnu_file"
open "$lightcurve.eps"


## WRITING THE OUTPUT TO A TEX FILE
echo "\documentclass[12pt]{article}" > "$tex_file"
echo "\usepackage{MnSymbol, graphicx, amsmath}" >> "$tex_file"
echo "\newcommand{\Msun}{\(\,M_\odot\)}" >> "$tex_file"
echo "\begin{document}" >> "$tex_file"
echo "\begin{figure}[h] \centering" >> "$tex_file"
echo "\includegraphics[width=4in]{lightcurve_${day}_num_p${rho}_${fluxtypefile}.eps}" >> "$tex_file"
echo "\caption[Spot mesh over small spot]{X-ray light curve for $NSshape neutron star with mass \($mass\Msun\), radius~$radius km, spin frequency $spin Hz, inclination angle \($inclination\degrees\), spot emission angle \($emission\degrees\), phase shift $phaseshift, distance $distance m, spot angular radius \($rho\degrees\), and spot temperature $temp keV.}" >> "$tex_file"
echo "\end{figure}" >> "$tex_file"
echo "\end{document}" >> "$tex_file"
