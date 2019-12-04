#!/bin/bash

NGRAMS=(5)
METHODS=( "witten_bell" "absolute" "katz" "kneser_ney" "presmoothed" "unsmoothed" )

# Unofficial strict bash
set -euo pipefail
IFS=$'\n\t'

# Try all the possible combinations
#for ng in ${NGRAMS[@]}
#do
#  for m in ${METHODS[@]}
#    do
#      make NC=${ng} METHOD=${m} evaluate
#    done
#done
# Once we have done this, we clear everything again and generate a more readable file
make clean

# Generate a lighter version of the results
for f in `ls ./evaluation_results`
do  
  echo ${f} >> complete_results.txt
  head -n 2 ./evaluation_results/${f} >> complete_results.txt
done
