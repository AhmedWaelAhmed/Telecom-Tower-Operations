import pandas as pd

print("Reading the first 1000 rows...")
df_sample = pd.read_csv('data/Africa towers.csv', nrows=1000)

sample_path = 'data/Africa_towers_sample.csv'
df_sample.to_csv(sample_path, index=False)

print(f"Success! Sample saved to {sample_path}")