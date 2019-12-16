#!/bin/bash

NGRAMS=(4)
METHODS=( "witten_bell" "absolute" "katz" "kneser_ney" "presmoothed" "unsmoothed" )
KFOLD=5

# Unofficial strict bash
set -euo pipefail
IFS=$'\n\t'

# Generate dataset for cross validation

# Try all the possible combinations

python3 data_analysis/generate_kfold_dataset.py --test-file NL2SparQL4NLU/dataset/NL2SparQL4NLU.test.conll.txt \
          --train-file NL2SparQL4NLU/dataset/NL2SparQL4NLU.train.conll.txt --seed 42 --kfold ${KFOLD}

for ng in ${NGRAMS[@]}
do
  for m in ${METHODS[@]}
    do
      for i in $(seq 1 $KFOLD);
      do

        make NC=${ng} METHOD=${m} TRAIN_DATASET=./data_analysis/kfold_train_$i.txt TEST_DATASET=./data_analysis/kfold_test_$i.txt evaluate

        # Get the accuracy result from the file
        eval=`cat evaluation_results/conlleval_${ng}-${m}-1.txt | head -2 | tail -1 | /usr/bin/tr ";" "\n" | tail -1 | /usr/bin/tr ": " "\n" | tail -1`

        echo "$eval" >> ./evaluation_results/${ng}-${m}-1_kfold.txt

        make clean
      done
    done

    # Compute the final performance
    awk '{s+=$1}END{print s/NR}' RS="\n" ./evaluation_results/${ng}-${m}-1.txt > ./evaluation_results/${ng}-${m}-1_evaluation.txt

done

# Generate a lighter version of the results
for f in `ls ./evaluation_results`
do  
  echo ${f} >> complete_results.txt
  head -n 2 ./evaluation_results/${f} >> complete_results.txt
done
