import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
sns.set()

train = pd.read_csv("../NL2SparQL4NLU/dataset/NL2SparQL4NLU.train.conll.txt", delimiter="\t", header=None)[1]
test = pd.read_csv("../NL2SparQL4NLU/dataset/NL2SparQL4NLU.test.conll.txt", delimiter="\t", header=None)[1]

# Get only the tag from the various elements (not IOB)
train = train.str.split("-", expand=True).fillna("O")[1]
test = test.str.split("-", expand=True).fillna("O")[1]

# Describe the datasets
print(train.describe())
print("")
print(test.describe())
print("")

# Elements missing from the test set
missing_elements_train = list(set(test.unique())-set(train.unique()))
print(missing_elements_train)
for i in missing_elements_train:
    print(i, test[ test == i ].count(), test[ test == i ].count()/len(test))

print("")

# Elements missing from the train set
missing_elements_test = list(set(train.unique())-set(test.unique()))
print(missing_elements_test)
for i in missing_elements_test:
    print(i, train[ train == i ].count(), train[ train == i ].count()/len(train))

plt.figure(figsize=(11,6))

# Plot the data without looking at the O tag (since it is the most abundant)
ax = sns.countplot(train[train != "O"], order=train[train != "O"].value_counts().index)

for p in ax.patches:
    percentage = '{:.3f}%'.format(100 * p.get_height()/len(train))
    x = p.get_x()
    y = p.get_y() + p.get_height()+10
    if 0.01 > (100 * p.get_height()/len(train)):
        plt.text(x,y,"<0.01%", rotation=45)
    else:
        plt.text(x,y,percentage, rotation=45)

plt.ylabel("Tag Count")
plt.xlabel("Tag Name")

plt.xticks(rotation="vertical")

plt.subplots_adjust(left=.07, bottom=.32)
plt.tight_layout()
#plt.show()
plt.savefig("result.png", dpi=200)
