import sys
import os
from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.microsoft.mssql.operators.mssql import MsSqlOperator

# 1. تحديد المسار المطلق لفولدر المشروع جوه الكونتينر
# إيرفلو بيقرأ من /opt/airflow/dags/
BASE_PATH = os.path.abspath(os.path.dirname(__file__))
PROJECT_PATH = os.path.join(BASE_PATH, 'telecom_pipeline')

# 2. إضافة مسار المشروع ومسار الـ src لقائمة البحث في بايثون
if PROJECT_PATH not in sys.path:
    sys.path.insert(0, PROJECT_PATH)

# 3. دلوقتي نقدر نعمل import من غير مشاكل
try:
    from src.main import main as run_etl
except ImportError as e:
    print(f"Import Error: {e}")
    # ده حل احتياطي لو الـ import لسه معلق
    sys.path.insert(0, os.path.join(PROJECT_PATH, 'src'))
    from main import main as run_etl

with DAG(
    dag_id="tower_pulse_master_pipeline",
    start_date=datetime(2023, 1, 1),
    schedule_interval=None,
    catchup=False,
    tags=["telecom", "etl", "star_schema"],
) as dag:

    python_etl_task = PythonOperator(
        task_id="extract_transform_and_stage",
        python_callable=run_etl,
    )

    build_schema_task = MsSqlOperator(
        task_id="build_star_schema",
        mssql_conn_id="tower_pulse_mssql",
        sql="telecom_pipeline/sql_scripts/build_star_schema.sql",
        autocommit=True
    )

    python_etl_task >> build_schema_task