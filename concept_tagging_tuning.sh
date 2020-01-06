#!/bin/bash
# -----------------------------------------------------------
# Run the hyperparameters search procedure and generate a
# final file with all the k-fold crossvalidation results.
#
# (C) 2020 Giovanni De Toni, Trento, Italy
# Released under MIT License
# email giovanni.detoni@studenti.unitn.it
# -----------------------------------------------------------

REPLACE=("keep" "word" "lemma" "stem")
SPACY=("none" "spacy" "nltk")
PRUNING=(5 10 20)
NGRAMS=(3 4 5)
METHODS=( "witten_bell" "absolute" "katz" "kneser_ney" "presmoothed" "unsmoothed" )
KFOLD=3

# Unofficial strict bash
set -euo pipefail
IFS=$'\n\t'

# Generate dataset for cross validation

# Try all the possible combinations

# Generate dataset
python3 data_analysis/generate_kfold_dataset.py --test-file NL2SparQL4NLU/dataset/NL2SparQL4NLU.test.conll.txt \
          --train-file NL2SparQL4NLU/dataset/NL2SparQL4NLU.train.conll.txt --seed 42 --kfold ${KFOLD}

for ng in ${NGRAMS[@]}
do
  for p in ${PRUNING[@]}
  do
    for m in ${METHODS[@]}
    do
      for s in ${SPACY[@]}
      do
        for r in ${REPLACE[@]}
        do
          for i in $(seq 1 $KFOLD);
          do
            make PRUNE_TRESH=${p} NC=${ng} METHOD=${m} ER=${s} REPLACE=${r} TRAIN_DATASET=./data_analysis/kfold_train_$i.txt TEST_DATASET=./data_analysis/kfold_test_$i.txt evaluate

            # Get the accuracy result from the file
            eval=`cat evaluation_results/conlleval_${ng}-${m}-${p}-${r}-${s}.txt | head -2 | tail -1 | /usr/bin/tr ";" "\n" | tail -1 | /usr/bin/tr ": " "\n" | tail -1`

            echo "$eval" >> ./evaluation_results/${ng}-${m}-${p}-${r}-${s}-kfold.txt

            make clean
          done
          # Compute the final performance
          awk '{s+=$1}END{print s/NR}' RS="\n" ./evaluation_results/${ng}-${m}-${p}-${r}-${s}-kfold.txt > ./evaluation_results/${ng}-${m}-${p}-${r}-${s}-evaluation.txt
        done
      done
    done
  done
done

# Generate a lighter version of the results
echo "ngram size,smoothing used, pruning, replace O, k-fold F1 score, k-fold F1 score (spacy), k-fold F1 score (nltk)" >> complete_results.txt
for f in `ls ./evaluation_results/*none-evaluation.txt | sort`
do
  original_file_name=`basename ${f} -none-evaluation.txt`
  file_name=`basename ${f} -none-evaluation.txt | /usr/bin/tr "-" ","`
  spacy_value=`cat ./evaluation_results/$original_file_name-spacy-evaluation.txt`
  nltk_value=`cat ./evaluation_results/$original_file_name-nltk-evaluation.txt`
  value=`cat ${f}`
  echo ${file_name}, ${value}, ${spacy_value}, ${nltk_value} >> complete_results.txt
done
