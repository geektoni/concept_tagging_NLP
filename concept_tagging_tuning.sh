#!/bin/bash

NGRAMS=(5)
METHODS=( "witten_bell" "absolute" "katz" "kneser_ney" "presmoothed" "unsmoothed" )
KFOLD=5

# Unofficial strict bash
set -euo pipefail
IFS=$'\n\t'

# Generate dataset for cross validation

# Try all the possible combinations


for ng in ${NGRAMS[@]}
do
  for m in ${METHODS[@]}
    do
      for i in $(seq 1 $KFOLD);
      do
        python3 data_analysis/generate_k_fold_dataset.py --test-file NL2SparQL4NLU/dataset/NL2SparQL4NLU.test.conll.txt \
          --train-file NL2SparQL4NLU/dataset/NL2SparQL4NLU.train.conll.txt --seed i

        make NC=${ng} METHOD=${m} TRAIN_DATASET=./data_analysis/kfold_train.txt TEST_DATASET=./data_analysis/kfold_test.txt evaluate

        # Get the accuracy result from the file
        cat evaluation_results/conlleval_${ng}-${m}-1.txt | head -2 | tail -1 | /usr/bin/tr ";" "\n" | tail -1 | /usr/bin/tr ": " "\n" | tail -1

        make clean
      done
    done
done

# Generate a lighter version of the results
for f in `ls ./evaluation_results`
do  
  echo ${f} >> complete_results.txt
  head -n 2 ./evaluation_results/${f} >> complete_results.txt
done
