import pandas as pd

import argparse

from nltk.stem import WordNetLemmatizer
import spacy
nlp = spacy.load("en_core_web_sm")

lemmatizer = WordNetLemmatizer()

def lemmatize_text(text):

    if not text[0].startswith("_"):
        return lemmatizer.lemmatize(text[0]) if text[1]=="O" else text[1]
    else:
        if text[1] == "O":
            return text[0]
        else:
            return text[1]

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

        print(train)

        train[[0, 2]].to_csv("./data_analysis/train_result.csv", sep="\t", header=False, index=False)
        test[[0, 2]].to_csv("./data_analysis/test_result.csv", sep="\t", header=False, index=False)

    elif args.spacy:
        for original_dataset in [("../NL2SparQL4NLU/dataset/NL2SparQL4NLU.train.conll.txt", "train"),
                                 ("../NL2SparQL4NLU/dataset/NL2SparQL4NLU.test.conll.txt", "test")]:
            total_words= []
            total_concepts= []
            with open(original_dataset[0], "r") as f:

                is_phrase = True

                while is_phrase:

                    # Read an entire question
                    phrase = []
                    concepts = []
                    line = f.readline()

                    while line:
                        if line== "\n":
                            break
                        else:
                            words = line.split("\t")
                            phrase.append(words[0].translate(str.maketrans('', '', '.')))
                            concepts.append(words[1].replace("\n", ""))
                        line = f.readline()

                    if len(phrase) != 0:
                        doc = nlp(" ".join(phrase))

                        for entity in doc.ents:

                            words = entity.text.split(" ")
                            label = entity.label_

                            indexes = []
                            try:
                                for w in words:
                                    indexes.append(phrase.index(w))
                                for i in range(0,len(indexes)):
                                    phrase[indexes[i]] = "_{}".format(label.lower())
                            except:
                                # there are errors? Then we do not include that
                                # phrase in the final dataset
                                break

                            # Remove duplicate occurrences
                            i=0
                            while i < len(phrase) - 1:
                                if phrase[i] == phrase[i + 1] and phrase[i].startswith("_"):
                                    print(phrase[i])
                                    del phrase[i]
                                    del concepts[i]
                                else:
                                    i = i + 1
                        total_words.append(phrase)
                        total_concepts.append(concepts)
                    # We reached the end of the file
                    if not line:
                        is_phrase = False

            with open("./data_analysis/{}_result.csv".format(original_dataset[1]), "w+") as output:
                for i in range(len(total_words)):
                    for w, c in zip(total_words[i], total_concepts[i]):
                        output.write("{}\t{}\n".format(w, c))
                    output.write("\n")
    else:
        train.to_csv("./data_analysis/train_result.csv", sep="\t", header=False, index=False)
        test.to_csv("./data_analysis/test_result.csv", sep="\t", header=False, index=False)