import pandas as pd

class DataExtractor:
    def __init__(self, file_path):
        self.file_path = file_path

    def extract_csv(self):
        """Extracts data from a CSV file."""
        try:
            print(f"Extracting data from {self.file_path}...")
            df = pd.read_csv(self.file_path)
            print(f"Extraction successful. Row count: {len(df)}")
            return df
        except FileNotFoundError:
            print(f"Error: The file at {self.file_path} was not found.")
            raise
        except Exception as e:
            print(f"An error occurred during extraction: {e}")
            raise