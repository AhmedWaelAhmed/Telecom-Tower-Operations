-- 1. إنشاء الداتابيز واستخدامها
CREATE DATABASE TowerPulseDB;
GO
USE TowerPulseDB;
GO

-- 2. إنشاء جدول الـ Staging (الجدول المؤقت)
CREATE TABLE Staging_Telecom (
    ID INT, radio VARCHAR(50), MCC INT, MNC INT, TAC INT, CID INT, LON FLOAT, LAT FLOAT,
    RANGE INT, SAM INT, created VARCHAR(50), updated VARCHAR(50), Country VARCHAR(100),
    Network VARCHAR(100), drop_calls INT, total_calls INT, drop_rate FLOAT, avg_load FLOAT,
    signal_strength FLOAT, speed FLOAT, latency FLOAT, QoE FLOAT, coverage_gap VARCHAR(10),
    signal_quality VARCHAR(50), tower_status VARCHAR(50), priority VARCHAR(50),
    maintenance_type VARCHAR(50), created_dt DATETIME, updated_dt DATETIME,
    maintenance_id VARCHAR(50), labor_cost FLOAT, parts_cost FLOAT, downtime_hours FLOAT,
    vendor VARCHAR(100), notes VARCHAR(500)
);
GO

-- 3. سحب الداتا من ملف الـ CSV اللي جوه فولدر raw_data
BULK INSERT Staging_Telecom
FROM '/data/FULL_telecom_dataset.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

-- 4. عرض أول 10 صفوف عشان نتأكد إن الداتا دخلت
SELECT TOP 10 * FROM Staging_Telecom;