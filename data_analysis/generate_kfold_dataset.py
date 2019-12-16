import pandas as pd
import random
import argparse

def parse_file(filename):
    with open(filename, "r") as f:

        is_phrase = True
        total_phrase = []
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

            total_phrase.append((phrase, concepts))

            # We reached the end of the file
            if not line:
                is_phrase = False

def write(data, filename):
    with open(filename, "w+") as output:
        for i in range(len(data)):
            for d in data:
                text_splitted = d[0].split(" ")
                conc_splitted = d[1].split(" ")
                for w in range(len(text_splitted)):
                    output.write("{}\t{}\n".format(text_splitted[w], conc_splitted[w]))
                output.write("\n")


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Generate kfold dataset files.')
    parser.add_argument("--test-file", help="Train dataset", type=str)
    parser.add_argument("--train-file", help="Test dataset", type=str)
    parser.add_argument("--seed", help="Seed", type=int, default=42)

    args = parser.parse_args()

    random.seed(int(args.seed))

    train = parse_file(args.train_file)
    test = parse_file(args.test_file)

    total = train + test

    random.shuffle(total)

    train_new = total[:len(total)*0.7]
    test_new = total[len(total)*0.7:]

    write(train_new, "kfold_train.txt")
    write(test_new, "kfold_test.txt")


