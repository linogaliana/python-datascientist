from urlchecker.core.check import UrlChecker
import os
import pandas as pd

path = os.getcwd()

checker = UrlChecker(
        path=path + "/content",
        file_types=[".qmd", ".py", ".md"],
        print_all=False
    )

checker.run()

df = pd.DataFrame(checker.results['failed'], columns = ["failed"])
df.to_csv("diagnostic.csv")