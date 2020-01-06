#!/usr/bin/env bash
# Script used to build a language model given OpenFST tool
# and train/test data files. It also computes the perplexity
# over the test dataset. This has to be used with the outputs
# of compute_token_pos_counts.sh
#
# Author: Giovanni De Toni
# Date: 05/03/2019
# Email: giovanni.det@gmail.com

export train_data=""
export test_data=""
export ngrams=""
export method=""
export prune_tresh=""
export example=""
export verbose=""

# Usage and version information
eval "$(docopts -V - -h - : "$@" <<EOF
Usage: build_lm.sh [<train_data>] [<test_data>] [--ngrams=<ngrams>] [--method=<method>] [--prune=<prune_thresh>] [--example] [--verbose]

Options:
  <train_data>  Train data.
  <test_data>   Test data.
	--ngrams=<ngrams>    Size of n-grams.
	--method=<method>     Method used for discounting.
	--prune=<prune_thresh>
	--verbose
	--help			Show help options.
	--version		Print program version.
----
compute_lm 0.1.0
Copyright (C) 2019 Giovanni De Toni
License MIT
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
EOF
)"

# Unofficial strict bash
set -euo pipefail
IFS=$'\n\t'

if [ -z $train_data ]; then train_data="pos_lm_data.txt"; fi
if [ -z $test_data ]; then test_data="pos_lm_data_test.txt"; fi
if [ -z $ngrams ]; then ngrams=4; fi
if [ -z $method ]; then method="witten_bell"; fi
if [ -z $prune_tresh ]; then prune_thresh=5; fi

if $verbose; then
  echo  "[*] LM Generator ($ngrams, $method)"
fi

# Generate the first model

cat UNK_POS.prob >> TOK_POS.prob
fstcompile --isymbols=lexicon.txt -osymbols=lexicon_pos.txt TOK_POS.prob > pos-tagger.fst
#fstcompile --isymbols=lexicon.txt -osymbols=lexicon_pos.txt UNK_POS.prob > unkn-tagger.fst

# Generate a simple image which shows a transducer
if [ -z $example ]; then
  echo -e "0	0	amazing	I-movie.name	6.083929774780076 \n0" > TOK_POS_draw.prob
  echo "amazing 0" > lexicon_draw.txt
  echo "I-movie.name 0" > lexicon_pos_draw.txt
  fstcompile --isymbols=lexicon_draw.txt -osymbols=lexicon_pos_draw.txt TOK_POS_draw.prob > pos-tagger-draw.fst
  fstdraw --isymbols=lexicon_draw.txt --osymbols=lexicon_pos_draw.txt -portrait pos-tagger-draw.fst | dot -Tjpg -Gdpi=100 > pos-tagger.jpg
  exit 0
fi

# Run fst on the model
farcompilestrings --symbols=lexicon_pos.txt --unknown_symbol="<unk>" -keep_symbols=1 $train_data > text.far
if $verbose; then
  echo "[*] The LM was generated"
fi

# Compute the ngrams and do frequency cutoff
ngramcount --order="$ngrams" --require_symbols=false text.far > text.counts
ngramshrink --method="count_prune" --count_pattern=$ngrams:$prune_thresh text.counts > text_reduced.counts

# Build the actual LM
ngrammake --method="$method" text_reduced.counts > pos.lm

#fstdraw -isymbols=lexicon.txt -osymbols=lexicon_pos.txt -portrait pos.lm | dot -Tjpg -Gdpi=1000 >automata.jpg
#fstprint --isymbols=lexicon.txt -osymbols=lexicon.txt final_result.fsa > output.

# Generating a random string
#echo "[*] Generating a random string from the LM"
#generated_string=`ngramrandgen text.lm | farprintstrings`
#echo "[*] The string is: $generated_string"

# Compute the perplexity on the test data
echo "[*] Computing perplexity on the given test dataset $test_data"
ngramsymbols $test_data > perplexity.txt
farcompilestrings --symbols=lexicon.txt --unknown_symbol="<unk>" $test_data > perplexity.far
ngramperplexity --OOV_symbol="<unk>" pos.lm perplexity.far

# Clean the directory from the generated files
#rm lex.txt text.far text.cnts text.lm text_reduced.cnts test.txt test.far
