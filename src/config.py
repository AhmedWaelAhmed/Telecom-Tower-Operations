import os

# File Paths
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
INPUT_FILE = os.path.join(BASE_DIR, 'data', 'Africa towers.csv')
OUTPUT_FILE = os.path.join(BASE_DIR, 'data', 'FULL_telecom_dataset.csv')

# Transformation Parameters
TARGET_COUNTRY = 'Egypt'
COLUMNS_TO_DROP = ['unit', 'changeable', 'averageSignal', 'Continent']

# Azure PostgreSQL Configuration (Future-Proofing)
AZURE_PG_HOST = os.getenv('AZURE_PG_HOST', 'your-azure-server.postgres.database.azure.com')
AZURE_PG_DB = os.getenv('AZURE_PG_DB', 'telecom_db')
AZURE_PG_USER = os.getenv('AZURE_PG_USER', 'admin_user')
AZURE_PG_PASSWORD = os.getenv('AZURE_PG_PASSWORD', 'super_secret_password')
AZURE_PG_PORT = os.getenv('AZURE_PG_PORT', '5432')