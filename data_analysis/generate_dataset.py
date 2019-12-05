import pandas as pd
import numpy as np

from nltk.stem import WordNetLemmatizer

lemmatizer = WordNetLemmatizer()


def lemmatize_text(text):
    return lemmatizer.lemmatize(text[0]) if text[1]=="O" else text[1]

if __name__ == "__main__":

    train = pd.read_csv("../NL2SparQL4NLU/dataset/NL2SparQL4NLU.train.conll.txt", delimiter="\t", header=None)
    test = pd.read_csv("../NL2SparQL4NLU/dataset/NL2SparQL4NLU.test.conll.txt", delimiter="\t", header=None)

    # Apply the first transformation to the dataset
    train[2] = train.apply(lemmatize_text, axis=1)
    test[2] = test.apply(lemmatize_text, axis=1)

    train[[0,2]].to_csv("train_result.csv", sep="\t", header=False, index=False)
    test[[0,2]].to_csv("test_result.csv", sep="\t", header=False, index=False)


