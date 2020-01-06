#!/usr/bin/env bash
# -----------------------------------------------------------
# Generate evaluation data from the test set.
#
# (C) 2020 Giovanni De Toni, Trento, Italy
# Released under MIT License
# email giovanni.detoni@studenti.unitn.it
# -----------------------------------------------------------

export test_data=""

# Usage and version information
eval "$(docopts -V - -h - : "$@" <<EOF
Usage: generate_evaluation_data [<test_data>]

Options:
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

if [ -z $test_data ]; then test_data="NL2SparQL4NLU/dataset/NL2SparQL4NLU.test.conll.txt"; fi

# Generate test phrases and labels
cat $test_data | cut -f 2 |\
sed 's/^ *$/#/g' |\
/usr/bin/tr '\n' ' ' |\
/usr/bin/tr '#' '\n' |\
sed 's/^ *//g;s/ *$//g' > evaluation_labels.txt

cat $test_data | cut -f 1 |\
sed 's/^ *$/#/g' |\
/usr/bin/tr '\n' ' ' |\
/usr/bin/tr '#' '\n' |\
sed 's/^ *//g;s/ *$//g' > evaluation_text.txt




