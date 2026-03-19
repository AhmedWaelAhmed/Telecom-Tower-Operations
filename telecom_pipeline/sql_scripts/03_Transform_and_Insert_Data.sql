USE TowerPulseDB;
GO

-- 1. تعبئة جدول الشبكة
INSERT INTO Dim_Network (radio, mcc, mnc, network_name, country)
SELECT DISTINCT radio, MCC, MNC, Network, Country
FROM Staging_Telecom
WHERE radio IS NOT NULL;

-- 2. تعبئة جدول الأبراج
INSERT INTO Dim_Tower (cid, tac, lon, lat, range, coverage_gap, tower_stat)
SELECT DISTINCT CID, TAC, LON, LAT, RANGE, coverage_gap, tower_status
FROM Staging_Telecom
WHERE CID IS NOT NULL;

-- 3. تعبئة جدول الصيانة
INSERT INTO Dim_Maintenance (vendor, maintenance_type, priority, signal_qua)
SELECT DISTINCT vendor, maintenance_type, priority, signal_quality
FROM Staging_Telecom
WHERE vendor IS NOT NULL;

-- 4. تعبئة جدول الوقت (بيفصل التاريخ ليوم وشهر وسنة)
INSERT INTO Dim_Date (date_id, full_date, year, month, day, is_weekend)
SELECT DISTINCT 
    CAST(FORMAT(CAST(created_dt AS DATE), 'yyyyMMdd') AS INT) AS date_id,
    CAST(created_dt AS DATE),
    YEAR(created_dt),
    MONTH(created_dt),
    DAY(created_dt),
    CASE WHEN DATEPART(dw, created_dt) IN (1, 7) THEN 1 ELSE 0 END
FROM Staging_Telecom
WHERE created_dt IS NOT NULL;

-- 5. تعبئة جدول الحقائق (بيربط الـ IDs كلها بالأرقام)
INSERT INTO Fact_Cell_Performance (
    tower_id, network_id, maintenance_id, date_id, created_ts,
    total_calls, drop_calls, drop_rate, avg_load, signal_strength, 
    speed, latency, QoE, labor_cost, parts_cost, downtime_hours
)
SELECT 
    t.tower_id,
    n.network_id,
    m.maintenance_id,
    CAST(FORMAT(CAST(s.created_dt AS DATE), 'yyyyMMdd') AS INT) AS date_id,
    s.created_dt,
    s.total_calls, s.drop_calls, s.drop_rate, s.avg_load, s.signal_strength,
    s.speed, s.latency, s.QoE, s.labor_cost, s.parts_cost, s.downtime_hours
FROM Staging_Telecom s
LEFT JOIN Dim_Tower t ON s.CID = t.cid AND s.TAC = t.tac
LEFT JOIN Dim_Network n ON s.radio = n.radio AND s.MCC = n.mcc AND s.MNC = n.mnc
LEFT JOIN Dim_Maintenance m ON s.vendor = m.vendor AND s.maintenance_type = m.maintenance_type AND s.priority = m.priority;
GO

-- اتأكد إن الـ Fact Table اتملى صح!
SELECT TOP 20 * FROM Fact_Cell_Performance;