#!/usr/bin/env bash

fstcompose sent.fsa pos-tagger.fst |\
fstcompose - pos.lm |\
fstcompose - unkn-tagger.fst |\
fstrmepsilon |\
fstshortestpath > final_result.fsa

fstdraw -isymbols=$alphabeth -osymbols=$output_alphabeth -portrait final_result.fsa | dot -Tjpg -Gdpi=500 >automata.jpg
