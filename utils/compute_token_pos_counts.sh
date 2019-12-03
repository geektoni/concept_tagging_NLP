#!/usr/bin/env bash
# This script generates helpers files with the token
# counts and token/pos counts given training and test data.
#
# Author: Giovanni De Toni
# Date: 05/03/2019
# Email: giovanni.det@gmail.com

export train_data=""
export test_data=""

# Usage and version information
eval "$(docopts -V - -h - : "$@" <<EOF
Usage: ngram_pos_tagger [<train_data>] [<test_data>]

Options:
	<train_data>    Train dataset used.
	<test_data>     Test dataset used.
	--help			Show help options.
	--version		Print program version.
----
ngram_pos_tagger 0.1.0
Copyright (C) 2019 Giovanni De Toni
License MIT
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
EOF
)"

# Unofficial strict bash
set -euo pipefail
IFS=$'\n\t'

if [ -z $train_data ]; then train_data="NL2SparQL4NLU/dataset/NL2SparQL4NLU.train.conll.txt"; fi
if [ -z $test_data ]; then test_data="NL2SparQL4NLU/dataset/NL2SparQL4NLU.test.conll.txt"; fi

# Compute POS counts
cat $train_data | cut -f 2 |\
sed '/ˆ *$/d' |\
sort | uniq -c |\
sed 's/ˆ *//g' |\
awk '{OFS="\t"; print $2,$1}' >> POS.tmp
echo -e "token\tcount" > POS.counts
cat POS.tmp | tail -n +2 >> POS.counts

# Compute TOK_POS counts
cat $train_data |\
sed '/ˆ *$/d' |\
sort | uniq -c |\
sed 's/ˆ *//g' |\
awk '{OFS="\t"; print $2,$3,$1}' > TOK_POS.tmp

# Dataset for the second transducer
cat $train_data | cut -f 2 |\
awk '!NF{$0="#"}1' |\
tr '\n' ' ' |\
tr '#' '\n' |\
sed 's/^ *//g;s/ *$//g' > lex.txt

cat TOK_POS.tmp | tail -n +2 > TOK_POS.counts

cat $train_data | cut -f 2 |\
sed 's/^ *$/#/g' |\
tr '\n' ' ' |\
tr '#' '\n' |\
sed 's/^ *//g;s/ *$//g' > pos_lm_data.txt

# Remove files
rm POS.tmp TOK_POS.tmp



