#!/bin/bash

REPLACE=("keep" "word" "lemma" "stem")
SPACY=("OFF" "ON")
NGRAMS=( 4 )
METHODS=( "witten_bell" "absolute" "katz" "kneser_ney" "presmoothed" "unsmoothed" )
KFOLD=3

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
      for s in ${SPACY[@]}
      do
        for r in ${REPLACE[@]}
        do
          for i in $(seq 1 $KFOLD);
          do
            make NC=${ng} METHOD=${m} SPACY=${s} REPLACE=${r} TRAIN_DATASET=./data_analysis/kfold_train_$i.txt TEST_DATASET=./data_analysis/kfold_test_$i.txt evaluate

            # Get the accuracy result from the file
            eval=`cat evaluation_results/conlleval_${ng}-${m}-5-${r}-${s}.txt | head -2 | tail -1 | /usr/bin/tr ";" "\n" | tail -1 | /usr/bin/tr ": " "\n" | tail -1`

            echo "$eval" >> ./evaluation_results/${ng}-${m}-5-${r}-${s}-kfold.txt

            make clean
          done
          # Compute the final performance
          awk '{s+=$1}END{print s/NR}' RS="\n" ./evaluation_results/${ng}-${m}-5-${r}-${s}-kfold.txt > ./evaluation_results/${ng}-${m}-5-${r}-${s}-evaluation.txt
        done
      done
    done
done

# Generate a lighter version of the results
cat "ngram size,smoothing used, pruning, replace O, entity resolution, k-fold F1 score" complete_results.txt
for f in `ls ./evaluation_results/*-evaluation.txt`
do
  file_name=`basename ${f} -evaluation.txt | tr "-" ","`
  value=`cat ${f}`
  echo ${f}, ${value} >> complete_results.txt
done
