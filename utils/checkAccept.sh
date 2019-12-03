#!/usr/bin/env bash
# Given a FAR archive with embedded a string, this
# script check if the given string is recognized by
# another FSA.
#
# Author: Giovanni De Toni
# Date: 05/04/2018
# Email: giovanni.det@gmail.com

test_fsa=''
pos_tagger_fsa=''
unk_tagger=''
pos=''
lexicon=''
stdout=''

# Usage and version information
eval "$(docopts -V - -h - : "$@" <<EOF
Usage: checkAccept [<test_fsa>] [<pos_tagger_fsa>] [<unk_tagger>] [<pos>] [<lexicon>] [--stdout]

Options:
	<test_fsa>      FAS string we want to check.
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

if [ -z $test_fsa ]; then test_fsa="converted_string.fsa"; fi
if [ -z $pos_tagger_fsa ]; then pos_tagger_fsa="pos-tagger.fst"; fi
if [ -z $unk_tagger ]; then unk_tagger="unkn-tagger.fst"; fi
if [ -z $pos ]; then pos="pos.lm"; fi
if [ -z $lexicon ]; then lexicon="lexicon.txt"; fi

fstcompose $test_fsa $pos_tagger_fsa |\
fstcompose - $pos |\
fstrmepsilon |\
fstshortestpath |\
fsttopsort > result.fsa

# Print the result to screen
if [ -z $stdout ]; then
    fstprint --isymbols=$lexicon --osymbols="lexicon_pos.txt" result.fsa
else
    fstprint --isymbols=$lexicon --osymbols="lexicon_pos.txt" result.fsa
fi

fstdraw --isymbols=$lexicon --osymbols=lexicon.txt -portrait $test_fsa | dot -Tjpg -Gdpi=1000 >automata.jpg
fstdraw --isymbols=$lexicon --osymbols=lexicon_pos.txt -portrait result.fsa | dot -Tjpg -Gdpi=1000 >result.jpg
