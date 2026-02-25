# Telecom Tower Operations: Automated ETL Pipeline


## 📌 Project Overview
This project refactors a monolithic exploratory data analysis notebook into a scalable, production-ready ETL pipeline. It processes thousands of records of telecom tower data (specifically focused on the Egyptian region) to calculate network Key Performance Indicators (KPIs), categorize tower health, and simulate maintenance schedules and costs.

The architecture is built using Object-Oriented Programming (OOP) principles, ensuring the codebase is modular, testable, and future-proofed for cloud database integration (e.g., Azure PostgreSQL).

## 🏗️ Pipeline Architecture
The project follows a standard Extract, Transform, Load (ETL) architecture:

1. **Extract (`src/extract.py`):** Ingests raw CSV data with robust error handling.
2. **Transform (`src/transform.py`):** Applies business logic, including:
   - Filtering geographic data (Target: Egypt).
   - Calculating derived KPIs (`drop_rate`, `avg_load`, `QoE`).
   - Categorizing signal quality and setting maintenance priority levels (P1 - P3).
   - Generating simulated predictive/preventive maintenance costs and schedules.
3. **Load (`src/load.py`):** Exports the clean, transformed dataset and includes architectural placeholders for SQLAlchemy integration with Azure PostgreSQL.

## 💻 Tech Stack
* **Language:** Python 3.x
* **Data Processing:** Pandas, NumPy
* **Visualization:** Matplotlib, Seaborn, Jupyter Notebooks
* **Design Pattern:** Object-Oriented Programming (OOP)

## 📂 Directory Structure
```text
telecom_pipeline/
│
├── data/                       # Raw and processed datasets
│   ├── Africa towers.csv       # (Input) Raw data
│   └── FULL_telecom_dataset.csv# (Output) Transformed data
│
├── src/                        # Core ETL Modules
│   ├── __init__.py
│   ├── config.py               # Centralized parameters & Azure credentials
│   ├── extract.py              # Data ingestion logic
│   ├── transform.py            # Business logic and KPI calculations
│   └── load.py                 # Data export and database loading logic
│
├── main.py                     # Pipeline orchestrator
├── dataAnaylsis.ipynb          # EDA & Statistical Validation
└── requirements.txt            # Project dependencies

🚀 How to Run Locally
1. Clone the repository and navigate to the directory:

Bash
cd telecom_pipeline
2. Create and activate a virtual environment:

Bash
python -m venv venv
# Windows:
.\venv\Scripts\activate
# Mac/Linux:
source venv/bin/activate
3. Install dependencies:

Bash
pip install -r requirements.txt
4. Execute the pipeline:

Bash
python main.py
5. View Visualizations:
Open dataAnaylsis.ipynb and run the cells to view correlation heatmaps, geospatial tower distributions, and QoE density plots.

🔮 Future Enhancements
Activate the SQLAlchemy engine in load.py to push transformed data directly to an Azure PostgreSQL instance.

Orchestrate the main.py script using Apache Airflow or Azure Data Factory for automated daily runs.


### Step 3: Save and Preview
Once you paste and save it, you can actually preview how it looks in VS Code! Just right-click on `README.md` and select **Open Preview** (or press `Ctrl + Shift + V`). 

This project looks incredible. You took a raw notebook and turned it into a highly structured data pip