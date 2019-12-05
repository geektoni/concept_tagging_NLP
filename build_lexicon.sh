#!/usr/bin/env bash
# This script is used to generate some base files
# (e.g lexicon) needed for further operations
#
# Author: Giovanni De Toni
# Date: 05/03/2019
# Email: giovanni.det@gmail.com

train_data=""
pos=""
output_name=""

# Usage and version information
eval "$(docopts -V - -h - : "$@" <<EOF
Usage: build_lexicon [<train_data>] [--pos]

Options:
	<train_data>    Train dataset used.
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

# Read the training data
if [ -z $train_data ]; then train_data="./NL2SparQL4NLU/dataset/NL2SparQL4NLU.train.utterances.txt"; fi

if $pos; then
    cat $train_data | cut -f 2 |\
    sed '/ˆ *$/d' |\
    sort | uniq > temp_lexicon.txt
    train_data="temp_lexicon.txt"
    output_name="lexicon_pos.txt"
else
    output_name="lexicon.txt"
fi

# Generate the lexicon (dumb way)
cat $train_data | tr ' ' '\n' | sort | uniq > lexicon_base.txt
echo "[*] Lexicon file was built."

# Generate the lexicon with count
cat $train_data | tr ' ' '\n' | sort | uniq -c > lexicon_count.txt
echo "[*] Lexicon file with token counts was built."

# Generate lexicon with ngram
ngramsymbols $train_data $output_name
echo "[*] Lexicon file with ngramsymbols was built to $output_name"
