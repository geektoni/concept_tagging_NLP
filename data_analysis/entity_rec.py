import spacy
nlp = spacy.load("en_core_web_sm")

if __name__ == "__main__":

    for original_dataset in [("./data_analysis/train_result.csv", "train"),
                             ("./data_analysis/test_result.csv", "test")]:
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

                        # Remove duplicate occurrences
                        i = 0
                        while i < len(phrase) - 1:
                            if phrase[i] == phrase[i + 1] and phrase[i].startswith("_"):
                                del phrase[i]
                                del concepts[i]
                            else:
                                i = i + 1
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
