#!/usr/bin/env bash
# This script is used to convert a text string
# into an FSA, which can be later used to check
# if a given string is recognized by another FSA.
#
# Author: Giovanni De Toni
# Date: 05/03/2019
# Email: giovanni.det@gmail.com

text_string=""
output_fsa=""
lexicon=""
far=""
result_output=""

# Usage and version information
eval "$(docopts -V - -h - : "$@" <<EOF
Usage: text2fsa [<text_string>] [<lexicon>] [<output_fsa>] [--far] [<result_output>]

Options:
	<train_data>    Text string which will be converted to an FSA.
	<lexicon>       Lexicon used.
	<output_fsa>    Name of the generated fsa (default: converted_string.far)
	<result_output> Directory where the files will be saved
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

# Check if a name was supplied
if [ -z ${text_string} ]; then text_string="text_fsa_representation.txt"; fi
if [ -z ${output_fsa} ]; then output_fsa="converted_string.fsa"; fi;
if [ -z $lexicon ]; then lexicon="lexicon.txt"; fi
if [ -z $result_output ]; then result_output="evaluation_files"; fi

# Create the fsa
if [ -z $far ]; then
    fstcompile --isymbols=$lexicon --osymbols=$lexicon $text_string $output_fsa
else
    total=$(cat $text_string|wc -l)
    cat $text_string |
    farcompilestrings --symbols=$lexicon --unknown_symbol='<unk>' --generate_keys="${#total}"  --keep_symbols |\
    farextract --filename_suffix='.fst_evaluation' --filename_prefix="${result_output}/"
fi
#echo "[*] FSA for the string \"$(cat $text_string)\" was created correctly."
