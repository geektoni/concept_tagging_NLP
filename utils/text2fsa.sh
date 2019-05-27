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

# Usage and version information
eval "$(docopts -V - -h - : "$@" <<EOF
Usage: text2fsa <text_string> <lexicon> [<output_fsa>]

Options:
	<train_data>    Text string which will be converted to an FSA.
	<lexicon>       Lexicon used.
	<output_fsa>    Name of the generated fsa (default: converted_string.far)
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
if [ -z ${output_fsa} ]; then output_fsa="converted_string.far"; fi;

# Create the fsa
echo $text_string | farcompilestrings --symbols=${lexicon} -unknown_symbol='<unk>' --generate_keys=1 --keep_symbols > $output_fsa
echo "[*] FAR for the string \"$text_string\" was created correctly."
