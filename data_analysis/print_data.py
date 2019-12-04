import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
sns.set()

f = pd.read_csv("../NL2SparQL4NLU/dataset/NL2SparQL4NLU.train.conll.txt", delimiter="\t", header=None)[1]

print(f)

plt.figure(figsize=(11,6))

ax = sns.countplot(f, order=f.value_counts().index)

for p in ax.patches:
    percentage = '{:.1f}%'.format(100 * p.get_height()/len(f))
    if 5 > (100 * p.get_height()/len(f)):
        continue
    x = p.get_x()
    y = p.get_y() + p.get_height()+10
    plt.text(x,y,percentage, rotation=45)

plt.ylabel("Tag Count")
plt.xlabel("Tag Name")

plt.xticks(rotation="vertical")

plt.subplots_adjust(left=.07, bottom=.32)
plt.tight_layout()
plt.show()
