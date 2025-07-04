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
# List of abbreviations for the grid names: 
#
# ZTopoRaw = raw bathymetry data
# ZTopo = processed bathymetry data
# ZTopoSlope = slope map from processed bathymetry data
# ZTopoShade = shaded map from processed bathymetry data
# ZTopoCont = contour map from processed bathymetry data
# ZAmpR = raw amplitude data
# ZAmpC = corrected amplitude data
# ZSsR = raw amplitude data
# ZssC = corrected amplitude data
# ZTopoASCII = processed bathymetry data in ASCII format
# ZTopoShade_tiff = geotiff map from processed bathymetry data
# ZAmpCPlot_tiff = geotiff map from corrected amplitude data
# ZSsCFPlot_tiff = geotiff map from corrected sidescan data
#
#-------------------------------------------------------------------------------
#
# List of global variables that can be changed by the user
#
# Grid resolution (im meters) for bathymetry and amplitude data
GRID_RESOLUTION=50/50m!
#
# Grid resolution (im meters) for sidescan data
GRID_RESOLUTIONSS=25/25m!
#
# Grid resolution for ASCII grid (in meters)
# ArcGIS and others only accept square grid cells
# Only chagnge the first value, and leave the zero (0)
GRID_RESOLUTION_ASCII=50/0m!
#
# Range for amplitude and sidescan maps (in decibels)
RANGE=-45/-15
#
PLOT_NAME="MSM133_Survey_XX"
#
#-------------------------------------------------------------------------------
#
# Generate first cut grid and plots
mbgrid -I datalist.mb-1 \
    -A2 -F5 -N -C4 \
    -O ZTopoRaw -V
# mbgrdviz -I ZTopoRaw.grd &

mbgrid -I datalistp.mb-1 \
    -A2 -F5 -N -C4 -E$GRID_RESOLUTION \
    -O ZTopo -V
# mbgrdviz -I ZTopo.grd &

mbgrid -I datalistp.mb-1 \
    -A2 -F5 -N -C4 -E$GRID_RESOLUTION_ASCII \
    -O ZTopoASCII -V

mbm_grdplot -I ZTopo.grd \
	-O ZTopoSlopeNav \
	-G5 -D0/1 -A1 \
	-L$PLOT_NAME:"Topography (meters)" \
	-MGLfx4/2/23.50/5.0+l"km" \
	-MNIdatalistp.mb-1 \
	-Pc -MIE300 -MITg -V
bash ZTopoSlopeNav.cmd
gmt psconvert ZTopoSlopeNav.ps -Tj -E300 -A

mbm_grdplot -I ZTopoRaw.grd \
	-O ZTopoRawSlopeNav \
	-G5 -D0/1 -A1 \
	-L$PLOT_NAME:"Realtime (Raw) Topography (meters)" \
	-MGLfx4/2/23.50/5.0+l"km" \
	-MNIdatalist.mb-1 \
	-Pc -MIE300 -MITg -V
bash ZTopoRawSlopeNav.cmd
gmt psconvert ZTopoRawSlopeNav.ps -Tj -E300 -A

# Topo slope map
mbm_grdplot -I ZTopo.grd \
	-O ZTopoSlope \
	-G5 -D0/1 -A1 \
	-L$PLOT_NAME:"Topography (meters)" \
	-MGLfx4/2/23.50/5.0+l"km" \
	-Pc -MIE300 -MITg -V
bash ZTopoSlope.cmd
gmt psconvert ZTopoSlope.ps -Tj -E300 -A

# Topo shade map
mbm_grdplot -I ZTopo.grd \
	-O ZTopoShade \
	-G2 -A0.2/090/05 \
	-L$PLOT_NAME:"Topography (meters)" \
	-MGLfx4/2/23.50/5.0+l"km" \
	-Pc -MIE300 -MITg -V
bash ZTopoShade.cmd
gmt psconvert ZTopoShade.ps -Tj -E300 -A

mbm_grdplot -I ZTopo.grd \
	-O ZTopoCont \
	-G1 -C100 -A1 -MCW0p \
	-L$PLOT_NAME:"Topography (meters)" \
	-MGLfx4/2/23.50/5.0+l"km" \
	-Pc -MIE300 -MITg -V
bash ZTopoCont.cmd
gmt psconvert ZTopoCont.ps -Tj -E300 -A

# Topo shade map
mbm_grd3dplot -I ZTopo.grd \
	-O ZTopo3DShade \
	-G2 -A0.2/90/05 -E150/15 \
	-L$PLOT_NAME:"Topography (meters)" \
	-MGLfx4/2/23.50/5.0+l"km" \
	-Pc -MIE300 -MITg -V
bash ZTopo3DShade.cmd
gmt psconvert ZTopo3DShade.ps -Tj -E300 -A

#-------------------------------------------------------------------------------
#
# Generate first cut amplitude mosaic and plot
mbmosaic -I datalist.mb-1 \
    -A3 -N -Y6 -F0.05 -E$GRID_RESOLUTION \
	  -O ZAmpR -V
# mbgrdviz -I ZTopoRaw.grd -J ZAmpR.grd &
#
# Generate first cut amplitude mosaic and plot
mbmosaic -I datalistp.mb-1 \
    -A3 -N -Y6 -F0.05 -E$GRID_RESOLUTION \
	  -O ZAmpC -V
# mbgrdviz -I ZTopo.grd -J ZAmpC.grd &

mbm_grdplot -I ZAmpR.grd \
	-O ZAmpRPlot \
	-G1 -W1/4 -D \
	-L$PLOT_NAME:"Uncorrected Amplitude (dB)" \
	-MGLfx4/2/23.50/5.0+l"km" \
	-Pc -MIE300 -MITg -Z$RANGE -V -Y -D0/1
bash ZAmpRPlot.cmd
gmt psconvert ZAmpRPlot.ps -Tj -E300 -A

mbm_grdplot -I ZAmpC.grd \
	-O ZAmpCPlot \
	-G1 -W1/4 -D \
	-L$PLOT_NAME:"Corrected Amplitude (dB)" \
	-MGLfx4/2/23.50/5.0+l"km" \
	-Pc -MIE300 -MITg -Z$RANGE -V -Y -D0/1
bash ZAmpCPlot.cmd
gmt psconvert ZAmpCPlot.ps -Tj -E300 -A

# Generate first cut sidescan mosaic and plot
mbmosaic -I datalist.mb-1 \
    -A4 -N -Y6 -F0.05 -E$GRID_RESOLUTIONSS \
	   -O ZSsR -V
# mbgrdviz -I ZTopoRaw.grd -J ZSsR.grd &
#
# Generate first cut sidescan mosaic and plot
mbmosaic -I datalistp.mb-1 \
    -A4F -N -Y6 -F0.05 -E$GRID_RESOLUTION \
	  -O ZSsCF -V
# mbgrdviz -I ZTopo.grd -J ZSsCF.grd &

mbm_grdplot -I ZSsR.grd \
	-O ZSsRPlot \
	-G1 -W1/4 -D \
	-L$PLOT_NAME:"Uncorrected Sidescan (dB)" \
	-MGLfx4/2/23.50/5.0+l"km" \
	-Pc -MIE300 -MITg -Z$RANGE -V -Y -D0/1
bash ZSsRPlot.cmd
gmt psconvert ZSsRPlot.ps -Tj -E300 -A

mbm_grdplot -I ZSsCF.grd \
	-O ZSsCFPlot \
	-G1 -W1/4 -D \
	-L$PLOT_NAME:"Corrected and Filtered Sidescan (dB)" \
	-MGLfx4/2/23.50/5.0+l"km" \
	-Pc -MIE300 -MITg -Z$RANGE -V -Y -D0/1
bash ZSsCFPlot.cmd
gmt psconvert ZSsCFPlot.ps -Tj -E300 -A

#-------------------------------------------------------------------------------
#
# This section will create products that are more friendly to Windows users 
# since this OS commonly cannot open Postscript file. Another addition is the
# grid convertion from .grd (netCDF) to ASCII grid for ArcGIS
# 
# 
# Create Bathy map (pdf and GeoTiff)
ps2pdf ZTopoShade.ps
mbm_grdtiff  -I ZTopo.grd \
	-G2 -A0.2/090/05 \
	-O ZTopoShade
bash ZTopoShade_tiff.cmd

# Create Corrected Amplitude map (pdf and GeoTiff)
ps2pdf ZAmpCPlot.ps
mbm_grdtiff  -I ZAmpC.grd \
	-G1  -W1/4 -D0/1 -Z$RANGE \
	-O ZAmpCPlot
bash ZAmpCPlot_tiff.cmd

# Create Corrected Sidescan map (pdf and GeoTiff)
ps2pdf ZSsCFPlot.ps
mbm_grdtiff  -I ZSsCF.grd \
	-G1  -W1/4 -D0/1 -Z$RANGE \
	-O ZSsCFPlot
bash ZSsCFPlot_tiff.cmd

# convert grids from .grd to .asc (ArcGIS)
gmt grdconvert ZTopoASCII.grd -GZTopoASCII.asc=ef+n-99999

