import pandas as pd
import random
import argparse
from tqdm import tqdm

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
    return total_phrase

def write(data, filename):
    with open(filename, "w+") as output:
        for e in data:
            for w in zip(e[0], e[1]):
                output.write("{}\t{}\n".format(w[0], w[1]))
            output.write("\n")


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Generate kfold dataset files.')
    parser.add_argument("--test-file", help="Train dataset", type=str)
    parser.add_argument("--train-file", help="Test dataset", type=str)
    parser.add_argument("--seed", help="Seed", type=int, default=42)
    parser.add_argument("--kfold", help="Kfold size", type=int, default=5)

    args = parser.parse_args()

    random.seed(int(args.seed))

    train = parse_file(args.train_file)
    test = parse_file(args.test_file)

    total = train + test

    random.shuffle(total)

    fold_size = len(total) // args.kfold
    for i in range(0, args.kfold):
        train_new = total[fold_size*(i+1):len(total)-1]+total[0:fold_size*i]
        test_new = total[fold_size*i:fold_size*(i+1)]

        write(train_new, "./data_analysis/kfold_train_{}.txt".format(i))
        write(test_new, "./data_analysis/kfold_test_{}.txt".format(i))


