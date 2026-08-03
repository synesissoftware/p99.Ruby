#! /bin/bash

#############################################################################
# File:     generate_rdoc.sh
#
# Purpose:  Generates documentation
#
# Created:  4th August 2026
# Updated:  4th August 2026
#
#############################################################################

rm -rfd doc
rdoc \
  -x build_gem.sh \
  -x generate_rdoc.sh \
  -x run_all_unit_tests.sh \
  -x *.gemspec \
  \
  -x doc/ \
  -x gems/ \
  -x old-gems/ \
  -x test/performance/ \
  -x test/scratch/ \
  \
  -x ts_all.rb \
  -x tc_.*\.rb \
  \
  $*
