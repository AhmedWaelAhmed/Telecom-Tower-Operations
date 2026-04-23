import pandas as pd
import numpy as np

class DataTransformer:
    def __init__(self, df, target_country, columns_to_drop):
        self.df = df.copy()
        self.target_country = target_country
        self.columns_to_drop = columns_to_drop
        np.random.seed(42) # Ensure reproducibility for simulated data

    def clean_and_filter(self):
        """Drops unnecessary columns, filters by country, and renames IDs."""
        # Drop columns if they exist
        existing_drops = [col for col in self.columns_to_drop if col in self.df.columns]
        self.df = self.df.drop(existing_drops, axis=1)
        
        # Filter by country
        if 'Country' in self.df.columns:
            self.df = self.df[self.df['Country'].astype(str).str.strip() == self.target_country].reset_index(drop=True)
        
        # Rename and strip column spaces
        if 'Unnamed: 0' in self.df.columns:
            self.df = self.df.rename(columns={'Unnamed: 0': ' ID'})
        self.df.columns = self.df.columns.str.strip()
        
        return self

    def calculate_derived_kpis(self):
        """Calculates simulated KPIs like drop rate, load, and QoE."""
        n_rows = len(self.df)
        
        self.df["drop_calls"] = np.random.randint(0, 50, n_rows)
        self.df["total_calls"] = self.df["RANGE"] + self.df["drop_calls"]
        self.df["drop_rate"] = (self.df["drop_calls"] / self.df["total_calls"]) * 100
        
        tower_counts = self.df.groupby(["MCC", "MNC"])["ID"].transform("count")
        self.df["avg_load"] = self.df["total_calls"] / tower_counts
        
        self.df["signal_strength"] = np.random.randint(-105, -60, n_rows)
        self.df["speed"] = np.random.uniform(1, 80, n_rows)
        self.df["latency"] = np.random.uniform(10, 200, n_rows)
        
        self.df["QoE"] = (
            ((self.df["signal_strength"] + 110) / 50) * 0.4 + 
            (self.df["speed"] / 80) * 0.4 +
            (1 - (self.df["latency"] / 200)) * 0.2
        ) * 5
        
        self.df["coverage_gap"] = self.df["RANGE"] > 2000
        
        return self

    def apply_classifications(self):
        """Applies categorical labels for signal quality, status, and priority."""
        def classify_signal(dBm):
            if -70 <= dBm <= -60: return "Excellent"
            elif -80 <= dBm < -70: return "Good"
            elif -90 <= dBm < -80: return "Fair"
            elif -100 <= dBm < -90: return "Poor"
            else: return "Very Poor"

        def tower_status(dr):
            if dr < 20: return "Healthy"
            elif dr < 40: return "Warning"
            elif dr < 60: return "Critical"
            else: return "Failed"

        def assign_priority(status):
            if "Failed" in status or "Critical" in status: return "P1"
            elif "Warning" in status: return "P2"
            else: return "P3"

        self.df["signal_quality"] = self.df["signal_strength"].apply(classify_signal)
        self.df["tower_status"] = self.df["drop_rate"].apply(tower_status)
        self.df["priority"] = self.df["tower_status"].apply(assign_priority)
        
        return self

    def simulate_maintenance_data(self):
        """Generates maintenance schedules, costs, and vendor notes."""
        n_rows = len(self.df)
        
        # Maintenance types
        m_types = ["preventive", "predictive", "emergency"]
        self.df["maintenance_type"] = np.random.choice(m_types, size=n_rows, p=[0.60, 0.25, 0.15])
        
        # Dates
        self.df["created_dt"] = pd.to_datetime(self.df["created"], unit="s")
        self.df["updated_dt"] = pd.to_datetime(self.df["updated"], unit="s")
        
        mask = self.df["updated_dt"] < self.df["created_dt"]
        self.df.loc[mask, "updated_dt"] = self.df.loc[mask, "created_dt"] + pd.Timedelta(days=30)
        
        def generate_date(row):
            start, end = row["created_dt"], row["updated_dt"]
            total_seconds = int((end - start).total_seconds())
            if total_seconds <= 0: return start
            
            if row["maintenance_type"] == "preventive":
                offset = np.random.uniform(total_seconds * 0.6, total_seconds * 1.0)
            elif row["maintenance_type"] == "predictive":
                offset = np.random.uniform(total_seconds * 0.3, total_seconds * 0.7)
            else:
                offset = np.random.uniform(0, total_seconds)
            return start + pd.Timedelta(seconds=offset)
            
        self.df["maintenance_date"] = self.df.apply(generate_date, axis=1)
        
        # Costs & Downtime
        def get_costs(mt):
            if mt == "preventive": return np.random.randint(1500, 4000), np.random.randint(500, 2500), round(np.random.uniform(0.5, 3), 1)
            if mt == "predictive": return np.random.randint(3000, 7000), np.random.randint(1000, 5000), round(np.random.uniform(1, 6), 1)
            return np.random.randint(5000, 15000), np.random.randint(3000, 20000), round(np.random.uniform(4, 24), 1)

        costs_downtime = self.df["maintenance_type"].apply(get_costs)
        self.df["labor_cost_egp"] = [x[0] for x in costs_downtime]
        self.df["parts_cost_egp"] = [x[1] for x in costs_downtime]
        self.df["downtime_hours"] = [x[2] for x in costs_downtime]
        
        # Vendors and Notes
        vendors = ["Huawei", "Ericsson", "Nokia", "ZTE", "FiberMisr", "Benya", "Local Contractor"]
        self.df["vendor"] = np.random.choice(vendors, size=n_rows)
        
        notes = ["Replaced sector antenna", "Battery replaced", "Fiber cut repaired", 
                 "Power system failure", "Software upgrade", "Transmission issue", 
                 "Cooling system maintenance", ""]
        self.df["notes"] = np.random.choice(notes, size=n_rows, p=[0.08,0.08,0.08,0.08,0.08,0.08,0.02,0.5])
        
        return self

    def execute_pipeline(self):
        """Runs the full transformation pipeline and returns the final dataframe."""
        print("Starting data transformation...")
        self.clean_and_filter()
        self.calculate_derived_kpis()
        self.apply_classifications()
        self.simulate_maintenance_data()
        print("Transformation complete.")
        return self.df