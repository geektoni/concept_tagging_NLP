# Concept Tagging for the Movie Domain
##### Concept Tagging Module for Movie Domain using the NL-SPARQL Data Set

This repository contains the mid-term project for the [Language Understanding
System](http://disi.unitn.it/~riccardi/page7/page13/page13.html) course at the [University of Trento](https://unitn.it).

## Install
This project was done using **Ubuntu 18.04**, **python3.6** and the libraries
**OpenFST** and **OpenGRM**. I suggest to set up a virtual environment to develop
and test this code more freely. I used **conda** during the development.

In order to install and create the environment, please follow these steps:
```bash
git clone https://github.com/geektoni/concept_tagging_NLP
cd concept_tagging_NLP
conda create --name ctnlp --file requirements.txt
conda activate ctnlp
```

## Usage

To run the experiments we used the utility `make`. More specifically, if you need to
run the SLU model just run:
```bash
cd concept_tagging_NLP
conda activate ctnlp
make evaluate
```
Inside the `evaluation_results` directory you will find the evaluation.

## Advanced Usage

There are several options that can be changed such to run the model with different
hyperparameter. More specifically, the options available are:

| Option | Description | Possible Value |
|---------------|-------------|----------------|
| NC | Ngram counts | Integer greater than 1.  |
| ER | Entity Recognition Tool we want to use. | spacy, nltk, none (default)  |
| METHOD | Smoothing method used. | "witten_bell", "absolute", "katz", "kneser_ney", "presmoothed", "unsmoothed" |
| PRUNE_TRESH | Prune threshold.  | Integer greater than 1. |
| OUTPUT_DIR | Directory where to save the final results.  | "./evaluation_results" (default) |
| REPLACE | Method used to replace the "O" concepts. | word, lemma, stem, keep (default) |
| TRAIN_DATASET | The path to the train dataset used. |  |
| TEST_DATASER | The path to the test dataset used. |  |
| VERBOSE | Emit more messages when running the model. | ON, OFF |

As an example, imagine we want to run the model by using spaCy as ER classifier and by using
the Witten-Bell smoothing method. We also want to replace the "O" concepts by using the lemma of the corresponding
tokens and to make the entire procedure more verbose. The command we would need to give would be:
```bash
cd concept_tagging_NLP
conda activate ctnlp
make ER=spacy METHOD=witten_bell REPLACE=lemma VERBOSE=ON evaluate
```