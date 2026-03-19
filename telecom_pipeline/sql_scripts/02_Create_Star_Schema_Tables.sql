USE TowerPulseDB;
GO

-- 1. إنشاء جدول الشبكة
CREATE TABLE Dim_Network (
    network_id INT IDENTITY(1,1) PRIMARY KEY,
    radio VARCHAR(50),
    mcc INT,
    mnc INT,
    network_name VARCHAR(100),
    country VARCHAR(100)
);

-- 2. إنشاء جدول الأبراج
CREATE TABLE Dim_Tower (
    tower_id INT IDENTITY(1,1) PRIMARY KEY,
    cid INT,
    tac INT,
    lon FLOAT,
    lat FLOAT,
    range INT,
    coverage_gap VARCHAR(10),
    tower_stat VARCHAR(50)
);

-- 3. إنشاء جدول الصيانة
CREATE TABLE Dim_Maintenance (
    maintenance_id INT IDENTITY(1,1) PRIMARY KEY,
    vendor VARCHAR(100),
    maintenance_type VARCHAR(50),
    priority VARCHAR(50),
    signal_qua VARCHAR(50)
);

-- 4. إنشاء جدول الوقت
CREATE TABLE Dim_Date (
    date_id INT PRIMARY KEY, 
    full_date DATE,
    year INT,
    month INT,
    day INT,
    is_weekend BIT
);

-- 5. إنشاء جدول الحقائق (وهو مربوط بـ Foreign Keys بالجداول اللي فوق)
CREATE TABLE Fact_Cell_Performance (
    fact_id INT IDENTITY(1,1) PRIMARY KEY,
    tower_id INT FOREIGN KEY REFERENCES Dim_Tower(tower_id),
    network_id INT FOREIGN KEY REFERENCES Dim_Network(network_id),
    maintenance_id INT FOREIGN KEY REFERENCES Dim_Maintenance(maintenance_id),
    date_id INT FOREIGN KEY REFERENCES Dim_Date(date_id),
    
    created_ts DATETIME,
    total_calls INT,
    drop_calls INT,
    drop_rate FLOAT,
    avg_load FLOAT,
    signal_strength FLOAT,
    speed FLOAT,
    latency FLOAT,
    QoE FLOAT,
    labor_cost FLOAT,
    parts_cost FLOAT,
    downtime_hours FLOAT
);
GO