import sys

if __name__ == "__main__":

    output = open("text_fsa_representation.txt", "w")
    text_string = sys.argv[1]

    elements = text_string.split(" ")
    b = 0
    e = 1
    for elem in elements:
        output.write("{}\t{}\t{}\t{}\n".format(b, e, elem, elem))
        b+=1
        e+=1

    output.write("{}\n".format(b))
    output.close()
