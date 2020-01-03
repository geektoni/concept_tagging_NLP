NC=4
VERBOSE=ON
ER=none
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

OUTPUT_NAME=$(NC)-$(METHOD)-$(PRUNE_TRESH)-$(REPLACE)-$(ER)

build_dataset: ## 1) Generate the dataset which will be used to train the SLU model.
	python3 ./data_analysis/entity_rec.py --train-file $(TRAIN_DATASET) --test-file $(TEST_DATASET) --er $(ER)
	mv ./data_analysis/train_result_spacy.csv ./data_analysis/train_result.csv
	mv ./data_analysis/test_result_spacy.csv ./data_analysis/test_result.csv
	python3 data_analysis/generate_dataset.py --train-file ./data_analysis/train_result.csv --test-file ./data_analysis/test_result.csv --replace $(REPLACE)

	sed -i "s/_NEWLINE\t_NEWLINE//g" ./data_analysis/train_result.csv
	sed -i "s/_NEWLINE\t_NEWLINE//g" ./data_analysis/test_result.csv

build_lexicon: ## 2) Build the lexicon
build_lexicon: build_dataset
	bash build_lexicon.sh data_analysis/train_result.csv $(VERB)
	bash build_lexicon.sh data_analysis/train_result.csv --pos $(VERB)

build_fsa_string_representation: build_lexicon
	python3 utils/text2fsatxt.py "star of thor"

build_test_string: build_lexicon build_fsa_string_representation
	bash utils/text2fsa.sh

build_tok_pos_counts: ## 3) Generate the token counts
build_tok_pos_counts:
	bash utils/compute_token_pos_counts.sh data_analysis/train_result.csv data_analysis/test_result.csv

build_tok_pos_prob: ## 4) Generate the token transition probabilities
build_tok_pos_prob: build_tok_pos_counts
	python3 concept_tagger.py

build_lm:  ## 5) Buil the actual WFST and Language Model
build_lm: build_lexicon build_tok_pos_prob
	bash build_lm.sh --ngrams $(NC) --method $(METHOD) --prune $(PRUNE_TRESH) $(VERB)

check: build_test_string build_lm
	bash utils/checkAccept.sh

evaluate: ## ** Build and evaluate the SLU model on the given movie dataset
evaluate: clean build_lm
	bash evaluation/generate_evaluation_data.sh data_analysis/test_result.csv
	bash evaluation/evaluate.sh $(OUTPUT_NAME) $(OUTPUT_DIR) data_analysis/test_result.csv

clean: ## Clean the directory from the temporary files
	rm -f lexicon.txt lexicon_base.txt lexicon_count.txt utils/converted_string.far utils/extracted.fsa utils/intersected.fsa data_analysis/*.csv
	rm -f *.tex *.prob *.counts *.far *.fsa *.fst *.lm *.jpg evaluation_files/*.fst_evaluation *.csv
	rm -r `touch tmpfiletxt.txt && ls *.txt | grep -v "requirements.txt"`

# https://gist.github.com/prwhite/8168133
help:           ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/\t/'
