import pandas as pd
import numpy as np

np.random.seed(42)
coverage_table = np.random.randint(2, size=(50, 1000))

df = pd.DataFrame(coverage_table)
df.to_csv('coverage_table.csv', index=False)