build_tok_pos_counts:
	bash utils/compute_token_pos_counts.sh

build_tok_pos_prob: build_tok_pos_counts
	python3 concept_tagger.py

build_lexicon:
	bash build_lexicon.sh

clean:
	rm -f lexicon.txt lexicon_base.txt lexicon_count.txt utils/converted_string.far utils/extracted.fsa utils/intersected.fsa
	rm -f *.prob *.counts *.txt
