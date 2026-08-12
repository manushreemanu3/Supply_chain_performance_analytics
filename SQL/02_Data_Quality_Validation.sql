-- ============================================================
-- 02_Data_Quality_Validation.sql
-- Data-quality, completeness, consistency, uniqueness, range, and referential validation checks.
-- ============================================================

-- Query 1
SELECT COUNT(DISTINCT h.part_id) AS unmatched_parts
FROM supply_chain_history h
LEFT JOIN parts_master p
    ON h.part_id = p.part_id
WHERE p.part_id IS NULL;

-- Query 2
SELECT COUNT(DISTINCT h.site_id) AS unmatched_sites
FROM supply_chain_history h
LEFT JOIN purchase_orders p
    ON h.site_id = p.site_id
WHERE p.site_id IS NULL;

-- Query 3
SELECT
    COUNT(*) AS total_rows,
    SUM(date IS NULL) AS missing_date,
    SUM(site_id IS NULL) AS missing_site,
    SUM(part_id IS NULL) AS missing_part,
    SUM(consumption_qty IS NULL) AS missing_consumption,
    SUM(on_hand_qty IS NULL) AS missing_inventory,
    SUM(backorder_qty IS NULL) AS missing_backorder,
    SUM(blocked_qty IS NULL) AS missing_blocked,
    SUM(forecast_qty IS NULL) AS missing_forecast
FROM supply_chain_history;

-- Query 4
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT date, site_id, part_id) AS unique_records
FROM supply_chain_history;

-- Query 5
SELECT
    MIN(consumption_qty) AS min_consumption,
    MIN(on_hand_qty) AS min_inventory,
    MIN(backorder_qty) AS min_backorder,
    MIN(blocked_qty) AS min_blocked,
    MIN(forecast_qty) AS min_forecast
FROM supply_chain_history;

-- Query 6
SELECT
    MIN(forecast_qty) AS min_forecast,
    MAX(forecast_qty) AS max_forecast,
    MIN(forecast_uplift_pct) AS min_uplift,
    MAX(forecast_uplift_pct) AS max_uplift
FROM supply_chain_history;

-- Query 7
SELECT DISTINCT forecast_type
FROM supply_chain_history;

-- Query 8
SELECT DISTINCT planned_maintenance
FROM supply_chain_history;

-- Query 9
SELECT
    MIN(date) AS start_date,
    MAX(date) AS end_date,
    COUNT(DISTINCT date) AS unique_dates
FROM supply_chain_history;

-- Query 10
SELECT
    COUNT(*) AS total_parts,
    SUM(shelf_life_days IS NULL) AS missing_shelf_life
FROM parts_master;

-- Query 11
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT part_id) AS unique_parts
FROM parts_master;

-- Query 12
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT po_id) AS unique_po_ids
FROM purchase_orders;

-- Query 13
SELECT
    SUM(po_id IS NULL) AS missing_po_id,
    SUM(part_id IS NULL) AS missing_part_id,
    SUM(site_id IS NULL) AS missing_site_id,
    SUM(supplier_id IS NULL) AS missing_supplier_id,
    SUM(order_date IS NULL) AS missing_order_date,
    SUM(promised_date IS NULL) AS missing_promised_date,
    SUM(receipt_date IS NULL) AS missing_receipt_date
FROM purchase_orders;

-- Query 14
SELECT
    MIN(order_date) AS earliest_order,
    MAX(order_date) AS latest_order,
    MIN(promised_date) AS earliest_promised,
    MAX(promised_date) AS latest_promised,
    MIN(receipt_date) AS earliest_receipt,
    MAX(receipt_date) AS latest_receipt
FROM purchase_orders;

-- Query 15
SELECT COUNT(*) AS invalid_receipt_dates
FROM purchase_orders
WHERE receipt_date < order_date;

-- Query 16
SELECT
    COUNT(*) AS total_incidents,
    SUM(incident_id IS NULL) AS missing_incident_id,
    SUM(part_id IS NULL) AS missing_part_id,
    SUM(supplier_id IS NULL) AS missing_supplier_id
FROM quality_incidents;

-- Query 17
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT incident_id) AS unique_incidents
FROM quality_incidents;

-- Query 18
SELECT COUNT(DISTINCT q.supplier_id) AS unmatched_suppliers
FROM quality_incidents q
LEFT JOIN (
    SELECT DISTINCT supplier_id
    FROM purchase_orders
) p
    ON q.supplier_id = p.supplier_id
WHERE p.supplier_id IS NULL;

-- Query 19
SELECT
    SUM(consumption_qty < 0) AS negative_consumption,
    SUM(on_hand_qty < 0) AS negative_inventory,
    SUM(backorder_qty < 0) AS negative_backorder,
    SUM(blocked_qty < 0) AS negative_blocked,
    SUM(forecast_qty < 0) AS negative_forecast
FROM supply_chain_history;
