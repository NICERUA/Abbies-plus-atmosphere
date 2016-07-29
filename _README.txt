Spot:

This code produces a light curve once a set of parameters describing the NS, spectrum 
and hotspot have been inputed. 

Observational data can also be read in, and a chi^2 value computed.


********** INSTRUCTIONS **********


1. Since this is a c++ code, you will need a c++ compiler. 
If you have the gnu version of c++, g++, installed then
you don't have to change anything in the Makefile.

If you have a different c++ compiler, edit the file "Makefile".
You will need to change the line:
CC=g++
to
CC=name
where name is the name of your compiler.

You will also need gnuplot installed, as this is what the code uses to produce the light 
curve plots.

I like ImageJ as a lightweight application to open .png files like the lightcurve, but 
your computer's default image viewer is probably fine too.




2. Open up "go.sh", the text file, and change the variable "base", in line 6. This should
have the path to where the folder "spot" is stored on your computer.

If you want to change input parameters, they begin at line 39 of "go". Note that the 
doubles are stored in scientific e notation, as decimals cannot be written to a filename.




3. I've created a very simple c-shell (tcsh) script that you can use to compile and run 
the code. To try out the code, navigate into the 'spot' folder in the command line.
Then at the command line type: go.sh

The program will output to the screen:

Output sent to << directory/file.txt >>
Spot: m = 1.6 Msun, r = 12 km, f = 500 Hz, i = 30, e = 45, X^2 = 1
Plot sent to << directory/file.txt >>
and << directory/file.eps >>




4. Change parameters by changing the command line arguments in the file go.sh.
There are more intensive shell scripts in the directory spot, such as 'var_none.sh',
which can compute the chi^2 of a data file with a model, or compute the flux from two 
hotspots.




5. Key Contents of Directory "Spot"

Spot.cpp -- main.c is found here. This is the start of the program.

OblDeflectionTOA.cpp -- routines that compute deflection angles, times of arrivals, 
                        etc are found here.

Chi.cpp -- routines for computing chi^2, calls to OblDeflectionTOA, computing fluxes for
           the light curve, etc are found here.

Struct.h -- definitions of some data storage structures.

Makefile -- instructions for compiling the program.

go.sh -- a simple script for compiling and running the code.

Manual.txt -- a more in-depth instruction manual for using and understanding the Spot code


