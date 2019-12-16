NC=4
VERBOSE="--verbose"
SPACY=
METHOD="witten_bell"
PRUNE_TRESH=1
OUTPUT_DIR="./evaluation_results"
OUTPUT_NAME=$(NC)-$(METHOD)-$(PRUNE_TRESH)
TRAIN_DATASET="./NL2SparQL4NLU/dataset/NL2SparQL4NLU.train.conll.txt"
TEST_DATASET="./NL2SparQL4NLU/dataset/NL2SparQL4NLU.test.conll.txt"
LEMMATIZE=

build_dataset:
ifeq ("$(LEMMATIZE)","--lemmatize True")
	python3 data_analysis/generate_dataset.py --train-file $(TRAIN_DATASET) --test-file $(TEST_DATASET) $(LEMMATIZE) $(SPACY)
	sed -i "s/_NEWLINE\t_NEWLINE/\n/g" ./data_analysis/train_result.csv
	sed -i "s/_NEWLINE\t_NEWLINE/\n/g" ./data_analysis/test_result.csv
else
	python3 data_analysis/generate_dataset.py --train-file $(TRAIN_DATASET) --test-file $(TEST_DATASET) $(LEMMATIZE) $(SPACY)
endif

build_lexicon: build_dataset
ifeq ("$(SPACY)","--spacy True")
	python3 ./data_analysis/entity_rec.py
	mv ./data_analysis/train_result_spacy.csv ./data_analysis/train_result.csv
	mv ./data_analysis/test_result_spacy.csv ./data_analysis/test_result.csv
endif
	bash build_lexicon.sh data_analysis/train_result.csv $(VERBOSE)
	bash build_lexicon.sh data_analysis/train_result.csv --pos $(VERBOSE)

build_fsa_string_representation: build_lexicon
	python3 utils/text2fsatxt.py "star of thor"

build_test_string: build_lexicon build_fsa_string_representation
	bash utils/text2fsa.sh

build_tok_pos_counts:
	bash utils/compute_token_pos_counts.sh data_analysis/train_result.csv data_analysis/test_result.csv

build_tok_pos_prob: build_tok_pos_counts
	python3 concept_tagger.py

build_lm: build_lexicon build_tok_pos_prob
	bash build_lm.sh -nc $(NC) -m $(METHOD) -p $(PRUNE_TRESH) $(VERBOSE)

check: build_test_string build_lm
	bash utils/checkAccept.sh

evaluate: clean build_lm
	bash evaluation/generate_evaluation_data.sh data_analysis/test_result.csv
	bash evaluation/evaluate.sh $(OUTPUT_NAME) $(OUTPUT_DIR) data_analysis/test_result.csv

clean:
	rm -f lexicon.txt lexicon_base.txt lexicon_count.txt utils/converted_string.far utils/extracted.fsa utils/intersected.fsa data_analysis/*.csv
	rm -f *.tex *.prob *.counts *.txt *.far *.fsa *.fst *.lm *.jpg evaluation_files/*.fst_evaluation *.csv
