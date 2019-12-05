import pandas as pd

if __name__ == "__main__":

    text = pd.read_csv("./data_analysis/test_result.csv",
                       header=None, delimiter="\t", skip_blank_lines=False)
    print(text)

    labels = pd.read_csv("./predicted.txt", header=None, delimiter="\t", skip_blank_lines=False)

    print(labels)

    final_result = pd.concat([text, labels], axis=1)

    final_result.dropna(inplace=True)

    final_result.to_csv("final_results.txt", header=None, index=False, sep="\t")
