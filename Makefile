NC=4
VERBOSE=ON
SPACY=OFF
METHOD=witten_bell
PRUNE_TRESH=5
OUTPUT_DIR="./evaluation_results"
TRAIN_DATASET="./NL2SparQL4NLU/dataset/NL2SparQL4NLU.train.conll.txt"
TEST_DATASET="./NL2SparQL4NLU/dataset/NL2SparQL4NLU.test.conll.txt"
REPLACE=keep

ifeq ("$(VERBOSE)","ON")
	VERB=--verbose
else
	VERB=
endif

OUTPUT_NAME=$(NC)-$(METHOD)-$(PRUNE_TRESH)-$(REPLACE)-$(SPACY)

build_dataset:
ifeq ("$(SPACY)","ON")
	python3 ./data_analysis/entity_rec.py
	mv ./data_analysis/train_result_spacy.csv ./data_analysis/train_result.csv
	mv ./data_analysis/test_result_spacy.csv ./data_analysis/test_result.csv
	python3 data_analysis/generate_dataset.py --train-file ./data_analysis/train_result.csv --test-file ./data_analysis/test_result.csv --replace $(REPLACE)
else
	python3 data_analysis/generate_dataset.py --train-file $(TRAIN_DATASET) --test-file $(TEST_DATASET) --replace $(REPLACE)
endif
	sed -i "s/_NEWLINE\t_NEWLINE//g" ./data_analysis/train_result.csv
	sed -i "s/_NEWLINE\t_NEWLINE//g" ./data_analysis/test_result.csv

build_lexicon: build_dataset
	bash build_lexicon.sh data_analysis/train_result.csv $(VERB)
	bash build_lexicon.sh data_analysis/train_result.csv --pos $(VERB)

build_fsa_string_representation: build_lexicon
	python3 utils/text2fsatxt.py "star of thor"

build_test_string: build_lexicon build_fsa_string_representation
	bash utils/text2fsa.sh

build_tok_pos_counts:
	bash utils/compute_token_pos_counts.sh data_analysis/train_result.csv data_analysis/test_result.csv

build_tok_pos_prob: build_tok_pos_counts
	python3 concept_tagger.py

build_lm: build_lexicon build_tok_pos_prob
	bash build_lm.sh --ngrams $(NC) --method $(METHOD) --prune $(PRUNE_TRESH) $(VERB)

check: build_test_string build_lm
	bash utils/checkAccept.sh

evaluate: clean build_lm
	bash evaluation/generate_evaluation_data.sh data_analysis/test_result.csv
	bash evaluation/evaluate.sh $(OUTPUT_NAME) $(OUTPUT_DIR) data_analysis/test_result.csv

clean:
	rm -f lexicon.txt lexicon_base.txt lexicon_count.txt utils/converted_string.far utils/extracted.fsa utils/intersected.fsa data_analysis/*.csv
	rm -f *.tex *.prob *.counts *.txt *.far *.fsa *.fst *.lm *.jpg evaluation_files/*.fst_evaluation *.csv
