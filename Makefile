build_lexicon:
	bash build_lexicon.sh
	bash build_lexicon.sh --pos

build_test_string: build_lexicon
	bash utils/text2fsa.sh "who plays luke"

build_tok_pos_counts:
	bash utils/compute_token_pos_counts.sh

build_tok_pos_prob: build_tok_pos_counts
	python3 concept_tagger.py

build_lm: build_lexicon build_tok_pos_prob
	bash build_lm.sh

check: build_test_string build_lm
	bash utils/checkAccept.sh

clean:
	rm -f lexicon.txt lexicon_base.txt lexicon_count.txt utils/converted_string.far utils/extracted.fsa utils/intersected.fsa
	rm -f *.prob *.counts *.txt *.far *.fsa *.fst *.lm
