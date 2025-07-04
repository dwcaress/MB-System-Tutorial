#! /bin/bash
#-------------------------------------------------------------------------------
#
# MB-System processing of R/V Merian multibeam data
#   - Kongsberg EM712 multibeam echosounders
#
# David W. Caress, Jenny Paduan
# Monterey Bay Aquarium Research Institute
# 5 March 2023
#
# Christian d. S. Ferreira
# MARUM
# 9 January 2025
#
#-------------------------------------------------------------------------------
#
# These notes pertain to Kongsberg multibeam data logged in files with suffixes
# of ".all". These data are supported by MB-System format:
#   MBF_EM710RAW 58 => *.all files, current Kongsberg format for EM122, EM302, EM710/EM712, EM2040
#
#-------------------------------------------------------------------------------
# Preprocess Stage: Format 58 files with *.all suffix
#-------------------------------------------------------------------------------
#
# MB-System now recognizes files with the *.all suffix as format 58.
# Preprocessing is required, and there is a format conversion - the raw files
# are translated in format 59. Therefore, there is a need to extract and specify a
# platform model.
#
# Get datalist of the logged swath files using
chmod -x *all
mbm_makedatalist -S.all -Odatalistl.mb-1 -P
#
# create platform file
mbmakeplatform --swath=datalistl.mb-1 --verbose --platform-type-surface-vessel \
	--output=Merian_EM712.plf 
#
# On R/V Falkor (too) the rsync obtaining the kmall files always resets the timestamp of
# pre-existing kmall files. To avoid remaking the pre-existing ancillary files, reset 
# those timestamps using touch before making ancillary files with mbdatalist
touch *.all.*
mbdatalist -I datalistl.mb-1 -O -V
#
# Preprocess the data - merge asynchronous data (position, depth, heading, attitude)
# from navigation post processing
mbpreprocess \
    --input=datalistl.mb-1 \
    --verbose --platform-file=Merian_EM712.plf \
    --ignore-water-column \
	--skip-existing
#
# Get datalist of raw *.mb59 files
mbm_makedatalist -S.mb59 -P -V
mbdatalist -Z

#-------------------------------------------------------------------------------
# Processing: tide correction only, no bathymetry editing, backscatter correction
#-------------------------------------------------------------------------------

# Get tide models and set for use by mbprocess
mbotps -I datalist.mb-1 -M -D60.0 -V

# Process the data
mbprocess

#-------------------------------------------------------------------------------
