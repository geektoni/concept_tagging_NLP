#!/usr/bin/env bash
# Given a FAR archive with embedded a string, this
# script check if the given string is recognized by
# another FSA.
#
# Author: Giovanni De Toni
# Date: 05/04/2018
# Email: giovanni.det@gmail.com

test_far=''
acceptor_fsa=''
lexicon=''
stdout=''

# Usage and version information
eval "$(docopts -V - -h - : "$@" <<EOF
Usage: checkAccept <test_far> <acceptor_fsa> <lexicon> [--stdout]

Options:
	<test_far>      FAR archive with the string we want to check.
	<acceptor_fsa>  FSA which will be used to accept the string.
	<lexicon>       The lexicon which has to be used.
	--stdout        Send the result to the stdout instead of a file.
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

# Extract the fst from the far archive
farextract --filename suffix=".fst" $test_far > extracted.fsa

# Intersect it with the target fsa
fstintersect extracted.fsa $acceptor_fsa | fstshortestpath | fstrmepsilon | fsttopsort > intersected.fsa

# Print the result to screen
if [ -z $stdout ]; then
    fstprint --isymbols=$lexicon --osymbols=$lexicon intersected.fsa
else
    fstprint --isymbols=$lexicon --osymbols=$lexicon
fi
