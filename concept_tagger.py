from math import log
import pandas as pd

if __name__ == "__main__":

    # Read POS counts
    pos_c = pd.read_csv("POS.counts", delimiter="\t")

    # Open the output file and the file with the unknown
    # probability
    output = open("TOK_POS.prob", "w")
    unkn = open("UNK_POS.prob", "w")

    # Read the tok pos counts and build the probabilities
    with open("TOK_POS.counts", "r") as f:

        line = f.readline()

        while line:

            # Contents:
            # 0: token
            # 1: concept
            # 2: count
            result = line.split("\t")
            token = result[0]
            concept = result[1]

            # Get how many times the pos is found
            concept_counts = pos_c[pos_c.token == result[1]]
            count = concept_counts["count"].values[0]

            # Get the token count
            tok_count = result[2].strip("\n")

            # write to file
            output.write("0\t0\t{}\t{}\t{}\n".format(token, concept, log(float(tok_count)/count)))

            line = f.readline()

        # Generate the file for the unkown probabilities
        tot_tag = pos_c["token"].nunique()
        for i in pos_c["token"].unique():
            unkn.write("0\t0\t<unk>\t{}\t{}\t\n".format(i, log(1.0/tot_tag)))

    # Close everything
    output.write("0\n")
    unkn.write("0\n")
    output.close()
    unkn.close()
