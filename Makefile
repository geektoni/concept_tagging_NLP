NC=4
METHOD="witten_bell"
PRUNE_TRESH=1
OUTPUT_DIR="./evaluation_results"
OUTPUT=$(NC)-$(METHOD)-$(PRUNE_TRESH)
TRAIN_DATASET="./NL2SparQL4NLU/dataset/NL2SparQL4NLU.train.conll.txt"
TEST_DATASET="./NL2SparQL4NLU/dataset/NL2SparQL4NLU.test.conll.txt"

build_lexicon:
	bash build_lexicon.sh $(TRAIN_DATASET)
	bash build_lexicon.sh $(TRAIN_DATASET) --pos

build_fsa_string_representation: build_lexicon
	python3 utils/text2fsatxt.py "star of thor"

build_test_string: build_lexicon build_fsa_string_representation
	bash utils/text2fsa.sh

build_tok_pos_counts:
	bash utils/compute_token_pos_counts.sh $(TRAIN_DATASET) $(TEST_DATASET)

build_tok_pos_prob: build_tok_pos_counts
	python3 concept_tagger.py

build_lm: build_lexicon build_tok_pos_prob
	bash build_lm.sh -nc $(NC) -m $(METHOD) -p $(PRUNE_TRESH)

check: build_test_string build_lm
	bash utils/checkAccept.sh

evaluate: clean build_lm
	bash evaluation/generate_evaluation_data.sh $(TEST_DATASET)
	bash evaluation/evaluate.sh $(OUTPUT) $(OUTPUT_DIR) $(TEST_DATASET)

clean:
	rm -f lexicon.txt lexicon_base.txt lexicon_count.txt utils/converted_string.far utils/extracted.fsa utils/intersected.fsa
	rm -f *.tex *.prob *.counts *.txt *.far *.fsa *.fst *.lm *.jpg evaluation_files/*.fst_evaluation
