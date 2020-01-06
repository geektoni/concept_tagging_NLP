# -----------------------------------------------------------
# Generate the complete files with the predicted concepts and
# the ground truth concepts.
#
# (C) 2020 Giovanni De Toni, Trento, Italy
# Released under MIT License
# email giovanni.detoni@studenti.unitn.it
# -----------------------------------------------------------
import pandas as pd

import argparse

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Generate evaluation files.')
    parser.add_argument("--test-file", help="It contains the test data we need to check.", type=str)
    args = parser.parse_args()

    text = pd.read_csv(args.test_file,
                       header=None, delimiter="\t", skip_blank_lines=False, engine="python")
    print(text)

    labels = pd.read_csv("./predicted.txt", header=None, delimiter="\t", skip_blank_lines=False)

    print(labels)

    final_result = pd.concat([text, labels], axis=1)

    final_result.dropna(inplace=True)

    final_result.to_csv("final_results.txt", header=None, index=False, sep="\t")
