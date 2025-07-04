#!/bin/bash
#-------------------------------------------------------------------------------
#
# MB-System processing of R/V Falkor (too) multibeam data
#   - Kongsberg EM124 and EM712 multibeam echosounders
#
# David W. Caress and Jenny Paduan
# Monterey Bay Aquarium Research Institute
# 5 March 2023
#
# Christian d. Santos Ferreira
# MARUM
# 9 January 2025
#
#-------------------------------------------------------------------------------
#
# 2D bathymetry editor
# mbedit

# 3D bathymetry editor
mbeditviz -I datalist.mb-1

rm *.lck

#
# If mbeditviz did not finish sucessfully (crashed), then say "no" and run the script again
#
echo
echo -n "If the 3D editor crashed say no and please run the script again"
echo

read -p "Do you want to proceed? (yes/no) " yn

case $yn in 
	yes ) echo ok, we will proceed;;
	no ) echo exiting...;
		exit;;
	* ) echo invalid response;
		exit 1;;
esac

# Apply soundings edits also to sidescan data
mbset -PSSRECALCMODE:1

# Process the data
mbprocess -C4

# Create grid for backscatter slope correction
mbgrid -I datalistp.mb-1 \
    -A2 -F5 -N -C20/2 \
    -O ZTopoInt -V
#mbgrdviz -I ZTopoInt.grd &

# process amplitude and sidescan
mbbackangle -I datalist.mb-1 \
            -A1 -A2 -Q -V \
            -N87/86.0 -R50 -G2/85/1500.0/85/100 \
            -T ZTopoInt.grd
mbset -PAMPCORRFILE:datalist.mb-1_tot.aga
mbset -PSSCORRFILE:datalist.mb-1_tot.sga
mbset -PAMPSSCORRTOPOFILE:ZTopoInt.grd

# Process the data
mbprocess -C4

# Filter the sidescan 
mbfilter -Idatalistp.mb-1 -S2/5/3 -V

