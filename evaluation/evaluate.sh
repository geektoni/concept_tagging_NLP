#!/usr/bin/env bash

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
bash ./utils/text2fsa.sh evaluation_text.txt --far

# Do the evaluation
for filename in `ls ${evaluation_dir}/*.fst_evaluation`
do

    echo "[*] Processing filename: $filename"
    fstcompose $filename $pos_tagger_fsa |\
    fstcompose - $pos |\
    fstrmepsilon |\
    fstshortestpath |\
    fsttopsort > result.fsa

    fstprint --isymbols=$lexicon --osymbols="lexicon_pos.txt" result.fsa | cut -f 4 >> predicted.txt
    fstprint --isymbols=$lexicon --osymbols="lexicon_pos.txt" result.fsa | cut -f 3 >> original_text.txt
done

# Generate the final result file
python3 ./evaluation/generate_evaluation_file.py

# Run conneval
perl ./evaluation/conlleval.pl -d "\t" < final_results.txt
