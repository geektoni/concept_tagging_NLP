import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
sns.set()

train = pd.read_csv("../NL2SparQL4NLU/dataset/NL2SparQL4NLU.train.conll.txt", delimiter="\t", header=None)[1]
test = pd.read_csv("../NL2SparQL4NLU/dataset/NL2SparQL4NLU.test.conll.txt", delimiter="\t", header=None)[1]

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

ax = sns.countplot(train, order=train.value_counts().index)

for p in ax.patches:
    percentage = '{:.1f}%'.format(100 * p.get_height()/len(train))
    if 5 > (100 * p.get_height()/len(train)):
        continue
    x = p.get_x()
    y = p.get_y() + p.get_height()+10
    plt.text(x,y,percentage, rotation=45)

plt.ylabel("Tag Count")
plt.xlabel("Tag Name")

plt.xticks(rotation="vertical")

plt.subplots_adjust(left=.07, bottom=.32)
plt.tight_layout()
#plt.savefig("result.png", dpi=200)
