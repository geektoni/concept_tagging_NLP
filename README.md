# Concept Tagging for the Movie Domain by using Entity Recognition Tools

## Brief Description

This work focuses on the well-known task of concept tagging sentences. It is the starting
point for more complex techniques and it represents a relatively important challenge when
building Spoken Language Understanding applications. This repository contains the mid-term project for the [Language Understanding
System](http://disi.unitn.it/~riccardi/page7/page13/page13.html) course at the [University of Trento](https://unitn.it). It also contains the code for building
two SLU modules by using Entity Recognition tools for concept tagging phrases taken
from the movie domain. Code for evaluating the various models is also provided.

You can find a detailed report about this project [here](report/giovanni_de_toni_197814.pdf).

## Requirements and Install
This project was done using **Ubuntu 18.04**, **python3.6**, **conda** and the libraries
**OpenFST** and **OpenGRM**. Please make sure to have everything installed before actually
using the various scripts.I suggest to set up a virtual environment to develop
and test this code more freely.

In order to install and create the environment, please follow these steps:
```bash
git clone https://github.com/geektoni/concept_tagging_NLP
cd concept_tagging_NLP
conda create --name ctnlp --file requirements.txt
python -m spacy download en_core_web_sm
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
Inside the `evaluation_results` directory you will find the evaluation results
over the test set.

By calling `make help` an help message will be generated.

## Advanced Usage

There are several options that can be changed such to run the model with different
hyperparameters. More specifically, the options available are:

| Option | Description | Possible Value |
|---------------|-------------|----------------|
| NC | N-gram value | Integer greater than 1. **4 (default)**  |
| ER | Entity Recognition Tool we want to use. | spacy, nltk, **none (default)**  |
| METHOD | Smoothing method used. | witten_bell, absolute, katz, **kneser_ney (default)**, presmoothed, unsmoothed |
| PRUNE_TRESH | Prune threshold.  | Integer greater than 1. **5 (default)**  |
| OUTPUT_DIR | Path to the directory where to save the final results.  | **./evaluation_results (default)** |
| REPLACE | Method used to replace the "O" concepts. | word, lemma, stem, **keep (default)** |
| TRAIN_DATASET | The path to the train dataset used. | **NL2SparQL4NLU/dataset/NL2SparQL4NLU.train.conll.txt (default)** |
| TEST_DATASER | The path to the test dataset used. | **NL2SparQL4NLU/dataset/NL2SparQL4NLU.train.conll.txt (default)** |
| VERBOSE | Emit more messages when running the model. | **ON (default)**, OFF |

As an example, imagine we want to run the model by using spaCy as ER classifier and by using
the Witten-Bell smoothing method. We also want to replace the "O" concepts by using the lemma of the corresponding
tokens and to make the entire procedure more verbose. The command we would need to give would be:
```bash
cd concept_tagging_NLP
conda activate ctnlp
make ER=spacy METHOD=witten_bell REPLACE=lemma VERBOSE=ON evaluate
```

## License
This work is released under the MIT License. Please have a look at the [License](LICENSE) file.

## Author(s)

Giovanni De Toni - [giovanni.detoni@studenti.unitn.it](mailto:giovanni.detoni@studenti.unitn.it)