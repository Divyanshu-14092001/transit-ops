-- Custom migrations for TransitOps database schema
-- These define PostgreSQL check constraints and partial unique indexes

-- 1. Partial Unique Indexes
-- Enforce only one ACTIVE organization membership per user-organization combination
CREATE UNIQUE INDEX IF NOT EXISTS user_organizations_one_active_idx 
ON user_organizations (user_id, organization_id) 
WHERE status = 'ACTIVE';

-- Enforce only one active fleet assignment (where unassigned_at IS NULL) per vehicle
CREATE UNIQUE INDEX IF NOT EXISTS vehicle_fleet_assignments_one_active_idx 
ON vehicle_fleet_assignments (vehicle_id) 
WHERE unassigned_at IS NULL;


-- 2. Check Constraints
-- Coordinate limits in locations
ALTER TABLE locations 
ADD CONSTRAINT chk_locations_latitude 
CHECK (latitude >= -90 AND latitude <= 90);

ALTER TABLE locations 
ADD CONSTRAINT chk_locations_longitude 
CHECK (longitude >= -180 AND longitude <= 180);

-- Driver safety score between 0 and 100
ALTER TABLE drivers 
ADD CONSTRAINT chk_drivers_safety_score 
CHECK (safety_score >= 0 AND safety_score <= 100);

-- Driver license date sequence
ALTER TABLE drivers
ADD CONSTRAINT chk_drivers_license_dates
CHECK (license_expiry_date > license_issued_at);


-- 3. Non-Negative Validations
-- Vehicle numeric fields
ALTER TABLE vehicles 
ADD CONSTRAINT chk_vehicles_acquisition_cost 
CHECK (acquisition_cost >= 0);

ALTER TABLE vehicles 
ADD CONSTRAINT chk_vehicles_maximum_capacity 
CHECK (maximum_capacity >= 0);

ALTER TABLE vehicles 
ADD CONSTRAINT chk_vehicles_odometer_reading 
CHECK (odometer_reading >= 0);

-- Trip distance
ALTER TABLE trips 
ADD CONSTRAINT chk_trips_distance 
CHECK (distance >= 0);

-- Trip schedule & actual timeline constraints
ALTER TABLE trips
ADD CONSTRAINT chk_trips_scheduled_times
CHECK (scheduled_end_at >= scheduled_start_at);

ALTER TABLE trips
ADD CONSTRAINT chk_trips_actual_times
CHECK (actual_end_at IS NULL OR actual_start_at IS NULL OR actual_end_at >= actual_start_at);

-- Maintenance Record metrics & constraints
ALTER TABLE maintenance_records 
ADD CONSTRAINT chk_maintenance_records_odometer 
CHECK (odometer_reading >= 0);

ALTER TABLE maintenance_records 
ADD CONSTRAINT chk_maintenance_records_estimated_cost 
CHECK (estimated_cost >= 0);

ALTER TABLE maintenance_records 
ADD CONSTRAINT chk_maintenance_records_actual_cost 
CHECK (actual_cost >= 0);

ALTER TABLE maintenance_records
ADD CONSTRAINT chk_maintenance_records_times
CHECK (completed_at IS NULL OR completed_at >= started_at);

-- Expense amount
ALTER TABLE expenses 
ADD CONSTRAINT chk_expenses_amount 
CHECK (amount >= 0);

-- Fuel Log metrics
ALTER TABLE fuel_logs 
ADD CONSTRAINT chk_fuel_logs_quantity 
CHECK (quantity >= 0);

ALTER TABLE fuel_logs 
ADD CONSTRAINT chk_fuel_logs_price_per_unit 
CHECK (price_per_unit >= 0);

ALTER TABLE fuel_logs 
ADD CONSTRAINT chk_fuel_logs_total_cost 
CHECK (total_cost >= 0);

ALTER TABLE fuel_logs 
ADD CONSTRAINT chk_fuel_logs_odometer_reading 
CHECK (odometer_reading >= 0);
