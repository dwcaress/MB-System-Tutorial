#! /bin/bash
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
# These notes pertain to Kongsberg multibeam data logged in files with suffixes
# of ".kmall". These data are supported by MB-System format:
#   MBF_KEMKMALL 261 => *.kmall files, current Kongsberg format for EM124, EM304, EM712, EM2040
#
#-------------------------------------------------------------------------------
# Preprocess Stage: Format 261 files with *.kmall suffix
#-------------------------------------------------------------------------------
#
# MB-System now recognizes files with the *.kmall suffix as format 261.
# Preprocessing is required, but there is no format conversion - the raw files
# are still in format 261. Also, there is no need to extract or specify a
# platform model.
#
# Get datalist of the logged swath files using
chmod -x *kmall
mbm_makedatalist -S.kmall -Odatalistl.mb-1 -P
#
# On R/V Falkor (too) the rsync obtaining the kmall files always resets the timestamp of
# pre-existing kmall files. To avoid remaking the pre-existing ancillary files, reset 
# those timestamps using touch before making ancillary files with mbdatalist
touch *.kmall.*
mbdatalist -I datalistl.mb-1 -O -V
#
# Preprocess the data - merge asynchronous data (position, depth, heading, attitude)
# from navigation post processing
mbpreprocess \
    --input=datalistl.mb-1 \
    --verbose
#
# Get datalist of raw *.mb261 files
mbm_makedatalist -S.mb261 -P -V
mbdatalist -Z

#-------------------------------------------------------------------------------
# Processing: tide correction only, no bathymetry editing, backscatter correction
#-------------------------------------------------------------------------------

# Get tide models and set for use by mbprocess
mbotps -I datalist.mb-1 -M -D60.0 -V

# Process the data and apply tide correction
mbprocess

#-------------------------------------------------------------------------------
