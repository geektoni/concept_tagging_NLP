#!/usr/bin/env bash
# -----------------------------------------------------------
# For each of the evalution files (*.fst), run the SLU model
# and generate its evaluation against the ground truth.
#
# (C) 2020 Giovanni De Toni, Trento, Italy
# Released under MIT License
# email giovanni.detoni@studenti.unitn.it
# -----------------------------------------------------------

test_fsa=''
pos_tagger_fsa=''
unk_tagger=''
pos=''
lexicon=''
stdout=''
evaluation_dir=''

# Unofficial strict bash
set -euo pipefail
IFS=$'\n\t'

if [ -z $test_fsa ]; then test_fsa="converted_string.fsa"; fi
if [ -z $pos_tagger_fsa ]; then pos_tagger_fsa="pos-tagger.fst"; fi
if [ -z $unk_tagger ]; then unk_tagger="unkn-tagger.fst"; fi
if [ -z $pos ]; then pos="pos.lm"; fi
if [ -z $lexicon ]; then lexicon="lexicon.txt"; fi
if [ -z $evaluation_dir ]; then evaluation_dir="evaluation_files"; fi

# Generate the various fsa
if [ -z "$(ls -A $evaluation_dir)" ]; then
  bash ./utils/text2fsa.sh evaluation_text.txt --far
else
  echo "[*] The evaluation dir (${evaluation_dir}) is not empty. Reusing files."
fi

# Do the evaluation
for filename in `ls ${evaluation_dir}/*.fst_evaluation`
do

    #echo "[*] Processing filename: $filename"
    fstcompose $filename $pos_tagger_fsa |\
    fstcompose - $pos |\
    fstrmepsilon |\
    fstshortestpath |\
    fsttopsort > result.fsa

    fstprint --isymbols=$lexicon --osymbols="lexicon_pos.txt" result.fsa | cut -f 4 >> predicted.txt
    fstprint --isymbols=$lexicon --osymbols="lexicon_pos.txt" result.fsa | cut -f 3 >> original_text.txt
done

# Generate the final result file
python3 ./evaluation/generate_evaluation_file.py --test-file ${3:-}

# Run conneval
perl ./evaluation/conlleval.pl -d "\t" < final_results.txt > ${2:-}/conlleval_${1:-}.txt
