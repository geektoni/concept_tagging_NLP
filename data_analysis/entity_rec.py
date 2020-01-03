import nltk

import spacy
nlp = spacy.load("en_core_web_sm")

import argparse

def ie_preprocess(phrase):
    return nltk.pos_tag(nltk.word_tokenize(phrase))

def er_tool(phrase, method="spacy"):

    if method=="none":
        return phrase

    if method=="spacy":
        doc = nlp(" ".join(phrase))

        for entity in doc.ents:

            words = entity.text.split(" ")
            label = entity.label_

            indexes = []
            try:
                for w in words:
                    indexes.append(phrase.index(w))
                for i in range(0, len(indexes)):
                    phrase[indexes[i]] = "_{}".format(label.lower())
            except:
                # there are errors? Then we do not include that
                # phrase in the final dataset
                break
    else:
        sent = ie_preprocess(" ".join(phrase))
        result = nltk.ne_chunk(sent)
        result_bin = nltk.ne_chunk(sent, binary=True)
        for i in range(0, len(result_bin)):
            if result_bin[i][1] == "NE":
                phrase[i] = "_{}".format(result[i][1].lower())

        # Remove duplicate occurrences
        # i = 0
        # while i < len(phrase) - 1:
        #    if phrase[i] == phrase[i + 1] and phrase[i].startswith("_"):
        # del phrase[i]
        # del concepts[i]
        #        pass
        #    else:
        #        i = i + 1
    return phrase

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Run entity recognition on the given dataset')
    parser.add_argument("--train-file", help="Train dataset.", type=str, default="../NL2SparQL4NLU/dataset/NL2SparQL4NLU.train.conll.txt")
    parser.add_argument("--test-file", help="Test dataset.", type=str, default="../NL2SparQL4NLU/dataset/NL2SparQL4NLU.test.conll.txt")
    parser.add_argument("--er", help="Type of ER we want to use (spacy or nltk)", type=str, default="spacy")
    args = parser.parse_args()

    for original_dataset in [(args.train_file, "train"),
                             (args.test_file, "test")]:
        total_words = []
        total_concepts = []
        with open(original_dataset[0], "r") as f:

            is_phrase = True

            while is_phrase:

                # Read an entire question
                phrase = []
                concepts = []
                line = f.readline()

                while line:
                    if line == "\n":
                        break
                    else:
                        words = line.split("\t")
                        phrase.append(words[0].translate(str.maketrans('', '', '.')))
                        concepts.append(words[1].replace("\n", ""))
                    line = f.readline()

                if len(phrase) != 0:

                    phrase = er_tool(phrase, args.er)

                    total_words.append(phrase)
                    total_concepts.append(concepts)
                # We reached the end of the file
                if not line:
                    is_phrase = False

        with open("./data_analysis/{}_result_spacy.csv".format(original_dataset[1]), "w+") as output:
            for i in range(len(total_words)):
                for w, c in zip(total_words[i], total_concepts[i]):
                    output.write("{}\t{}\n".format(w, c))
                output.write("\n")
