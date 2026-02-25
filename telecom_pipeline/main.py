from src.config import INPUT_FILE, OUTPUT_FILE, TARGET_COUNTRY, COLUMNS_TO_DROP
from src.extract import DataExtractor
from src.transform import DataTransformer
from src.load import DataLoader

def main():
    print("--- Starting Telecom Pipeline ---")
    
    # 1. Extract
    extractor = DataExtractor(INPUT_FILE)
    raw_data = extractor.extract_csv()
    
    # 2. Transform
    transformer = DataTransformer(raw_data, TARGET_COUNTRY, COLUMNS_TO_DROP)
    clean_data = transformer.execute_pipeline()
    
    # 3. Load
    loader = DataLoader(clean_data)
    loader.save_to_csv(OUTPUT_FILE)
    
    print("--- Pipeline Execution Finished ---")

if __name__ == "__main__":
    main()