USE TowerPulseDB;
GO

-- 1. إنشاء الجداول لو مش موجودة
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Dim_Network')
BEGIN
    CREATE TABLE Dim_Network (network_id INT IDENTITY(1,1) PRIMARY KEY, radio VARCHAR(50), mcc INT, mnc INT, network_name VARCHAR(100), country VARCHAR(100));
    CREATE TABLE Dim_Tower (tower_id INT IDENTITY(1,1) PRIMARY KEY, cid INT, tac INT, lon FLOAT, lat FLOAT, range INT, coverage_gap VARCHAR(10), tower_stat VARCHAR(50));
    CREATE TABLE Dim_Maintenance (maintenance_id INT IDENTITY(1,1) PRIMARY KEY, vendor VARCHAR(100), maintenance_type VARCHAR(50), priority VARCHAR(50), signal_qua VARCHAR(50));
    CREATE TABLE Dim_Date (date_id INT PRIMARY KEY, full_date DATE, year INT, month INT, day INT, is_weekend BIT);
    CREATE TABLE Fact_Cell_Performance (
        fact_id INT IDENTITY(1,1) PRIMARY KEY, tower_id INT FOREIGN KEY REFERENCES Dim_Tower(tower_id),
        network_id INT FOREIGN KEY REFERENCES Dim_Network(network_id), maintenance_id INT FOREIGN KEY REFERENCES Dim_Maintenance(maintenance_id),
        date_id INT FOREIGN KEY REFERENCES Dim_Date(date_id), created_ts DATETIME, total_calls INT, drop_calls INT,
        drop_rate FLOAT, avg_load FLOAT, signal_strength FLOAT, speed FLOAT, latency FLOAT, QoE FLOAT, labor_cost FLOAT, parts_cost FLOAT, downtime_hours FLOAT
    );
END
GO

-- 2. تنظيف البيانات القديمة عشان لو شغلنا الكود كذا مرة الداتا ماتتكررش
TRUNCATE TABLE Fact_Cell_Performance;
DELETE FROM Dim_Network; DBCC CHECKIDENT ('Dim_Network', RESEED, 0);
DELETE FROM Dim_Tower; DBCC CHECKIDENT ('Dim_Tower', RESEED, 0);
DELETE FROM Dim_Maintenance; DBCC CHECKIDENT ('Dim_Maintenance', RESEED, 0);
DELETE FROM Dim_Date;
GO

-- 3. تعبئة الأبعاد والحقائق من جدول Staging_Telecom
INSERT INTO Dim_Network (radio, mcc, mnc, network_name, country) SELECT DISTINCT radio, MCC, MNC, Network, Country FROM Staging_Telecom WHERE radio IS NOT NULL;
INSERT INTO Dim_Tower (cid, tac, lon, lat, range, coverage_gap, tower_stat) SELECT DISTINCT CID, TAC, LON, LAT, RANGE, coverage_gap, tower_status FROM Staging_Telecom WHERE CID IS NOT NULL;
INSERT INTO Dim_Maintenance (vendor, maintenance_type, priority, signal_qua) SELECT DISTINCT vendor, maintenance_type, priority, signal_quality FROM Staging_Telecom WHERE vendor IS NOT NULL;
INSERT INTO Dim_Date (date_id, full_date, year, month, day, is_weekend) SELECT DISTINCT CAST(FORMAT(CAST(created_dt AS DATE), 'yyyyMMdd') AS INT), CAST(created_dt AS DATE), YEAR(created_dt), MONTH(created_dt), DAY(created_dt), CASE WHEN DATEPART(dw, created_dt) IN (1, 7) THEN 1 ELSE 0 END FROM Staging_Telecom WHERE created_dt IS NOT NULL;

INSERT INTO Fact_Cell_Performance (tower_id, network_id, maintenance_id, date_id, created_ts, total_calls, drop_calls, drop_rate, avg_load, signal_strength, speed, latency, QoE, labor_cost, parts_cost, downtime_hours)
SELECT t.tower_id, n.network_id, m.maintenance_id, CAST(FORMAT(CAST(s.created_dt AS DATE), 'yyyyMMdd') AS INT) AS date_id, s.created_dt, s.total_calls, s.drop_calls, s.drop_rate, s.avg_load, s.signal_strength, s.speed, s.latency, s.QoE, s.labor_cost, s.parts_cost, s.downtime_hours
FROM Staging_Telecom s
LEFT JOIN Dim_Tower t ON s.CID = t.cid AND s.TAC = t.tac
LEFT JOIN Dim_Network n ON s.radio = n.radio AND s.MCC = n.mcc AND s.MNC = n.mnc
LEFT JOIN Dim_Maintenance m ON s.vendor = m.vendor AND s.maintenance_type = m.maintenance_type AND s.priority = m.priority;
GO