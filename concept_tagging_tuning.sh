#!/bin/bash

SPACY=("" "--spacy True")
LEMMATIZE=("" "--lemmatize True")
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
      for s in ${SPACY[@]}
      do
        for l in ${LEMMATIZE[@]}
        do
          for i in $(seq 1 $KFOLD);
          do
            spacy_on="spacy_off"
            if [ ${s} = "--spacy True" ]; then
              spacy_on="spacy_on"
            fi

            lemma_on="lemma_off"
            if [ ${l} = "--lemmatize True" ]; then
              lemma_on="lemma_on"
            fi

            make NC=${ng} METHOD=${m} SPACY=${s} LEMMATIZE=${l} TRAIN_DATASET=./data_analysis/kfold_train_$i.txt TEST_DATASET=./data_analysis/kfold_test_$i.txt evaluate

            # Get the accuracy result from the file
            eval=`cat evaluation_results/conlleval_${ng}-${m}-1-${lemma_on}-${spacy_on}.txt | head -2 | tail -1 | /usr/bin/tr ";" "\n" | tail -1 | /usr/bin/tr ": " "\n" | tail -1`

            echo "$eval" >> ./evaluation_results/${ng}-${m}-1-${lemma_on}-${spacy_on}-kfold.txt

            make clean
          done
          # Compute the final performance
          awk '{s+=$1}END{print s/NR}' RS="\n" ./evaluation_results/${ng}-${m}-1-${lemma_on}-${spacy_on}-kfold.txt > ./evaluation_results/${ng}-${m}-1-${lemma_on}-${spacy_on}-evaluation.txt
        done
      done
    done
done

# Generate a lighter version of the results
for f in `ls ./evaluation_results/*-evaluation.txt`
do
  value=`cat ${f}`
  echo ${f}, ${value} >> complete_results.txt
done
