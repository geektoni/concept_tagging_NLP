import pandas as pd

import argparse

from nltk.stem import WordNetLemmatizer

lemmatizer = WordNetLemmatizer()

def lemmatize_text(text):

    if not text[0]:
        return text[0]

    if not text[0].startswith("_"):
        return lemmatizer.lemmatize(text[0]) if text[1]=="O" else text[1]
    else:
        return text[0]

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Generate the dataset we need to use.')
    parser.add_argument("--train-file", help="Train dataset.", type=str)
    parser.add_argument("--test-file", help="Test dataset.", type=str)
    parser.add_argument("--lemmatize", help="Lemmatize and replace O concept.", type=bool)
    parser.add_argument("--spacy", help="Spacy and replace O concept.", type=bool)
    args = parser.parse_args()

    train = pd.read_csv(args.train_file, delimiter="\t", header=None, skip_blank_lines=False)
    test = pd.read_csv(args.test_file, delimiter="\t", header=None, skip_blank_lines=False)

    print(args)

    if args.lemmatize:

        train = pd.read_csv(args.train_file, delimiter="\t", header=None, skip_blank_lines=False).fillna("_NEWLINE")
        test = pd.read_csv(args.test_file, delimiter="\t", header=None, skip_blank_lines=False).fillna("_NEWLINE")

        # Apply the first transformation to the dataset
        train[2] = train.apply(lemmatize_text, axis=1)
        test[2] = test.apply(lemmatize_text, axis=1)

        train[[0, 2]].to_csv("./data_analysis/train_result.csv", sep="\t", header=False, index=False)
        test[[0, 2]].to_csv("./data_analysis/test_result.csv", sep="\t", header=False, index=False)
    else:
        train.to_csv("./data_analysis/train_result.csv", sep="\t", header=False, index=False)
        test.to_csv("./data_analysis/test_result.csv", sep="\t", header=False, index=False)