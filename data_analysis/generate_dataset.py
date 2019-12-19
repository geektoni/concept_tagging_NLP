import pandas as pd

import argparse

import nltk
from nltk.stem import *
from nltk.stem import WordNetLemmatizer
from nltk.corpus import wordnet
from nltk.tokenize import word_tokenize

lemmatizer = WordNetLemmatizer()
stemmer = PorterStemmer()

def get_wordnet_pos(treebank_tag):

    if treebank_tag.startswith('J'):
        return wordnet.ADJ
    elif treebank_tag.startswith('V'):
        return wordnet.VERB
    elif treebank_tag.startswith('N'):
        return wordnet.NOUN
    elif treebank_tag.startswith('R'):
        return wordnet.ADV
    else:
        return ""

def get_lemmatize_word(word):
    token = word_tokenize(word)
    pos_wn = nltk.pos_tag(token)[0][1]
    pos = "n" if get_wordnet_pos(pos_wn) == "" else get_wordnet_pos(pos_wn)
    return lemmatizer.lemmatize(word, pos=pos)

def lemmatize_text(text):
    if not text[0].startswith("_"):
        if text[1] == "O":
            return get_lemmatize_word(text[0])
        else:
            return text[1]
    else:
        return text[0] if text[1] == "O" else text[1]

def word_text(text):
    if not text[0].startswith("_"):
        if text[1] == "O":
            return text[0]
        else:
            return text[1]
    else:
        return text[0] if text[1] == "O" else text[1]

def stem_text(text):
    if not text[0].startswith("_"):
        if text[1] == "O":
            return stemmer.stem(text[0])
        else:
            return text[1]
    else:
        return text[0] if text[1] == "O" else text[1]


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Generate the dataset we need to use.')
    parser.add_argument("--train-file", help="Train dataset.", type=str)
    parser.add_argument("--test-file", help="Test dataset.", type=str)
    parser.add_argument("--replace", help="Replace O concepts (keep, lemma, word, stem)", default="keep")
    args = parser.parse_args()

    train = pd.read_csv(args.train_file, delimiter="\t", header=None, skip_blank_lines=False).fillna("_NEWLINE")
    test = pd.read_csv(args.test_file, delimiter="\t", header=None, skip_blank_lines=False).fillna("_NEWLINE")

    print(args)

    if args.replace != "keep":

        # Apply the first transformation to the dataset
        if args.replace == "stem":
            transform = stem_text
        elif args.replace == "lemma":
            transform = lemmatize_text
        else:
            transform = word_text

        train[2] = train.apply(transform, axis=1)
        test[2] = test.apply(transform, axis=1)

        if args.replace == "stem":
            train[0] = train[0].apply(lambda x: stemmer.stem(x) if not x.startswith("_") else x)
            test[0] = test[0].apply(lambda x: stemmer.stem(x) if not x.startswith("_") else x)
        elif args.replace == "lemma":
            train[0] = train[0].apply(lambda x: get_lemmatize_word(x) if not x.startswith("_") else x)
            test[0] = test[0].apply(lambda x: get_lemmatize_word(x) if not x.startswith("_") else x)

        train[[0, 2]].to_csv("./data_analysis/train_result.csv", sep="\t", header=False, index=False)
        test[[0, 2]].to_csv("./data_analysis/test_result.csv", sep="\t", header=False, index=False)
    else:
        train.to_csv("./data_analysis/train_result.csv", sep="\t", header=False, index=False)
        test.to_csv("./data_analysis/test_result.csv", sep="\t", header=False, index=False)