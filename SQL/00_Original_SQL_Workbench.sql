CREATE DATABASE supply_chain_project;
USE supply_chain_project;

SELECT COUNT(*) AS row_count
FROM supply_chain_history;

SELECT 'purchase_orders' AS table_name, COUNT(*) AS row_count
FROM purchase_orders
UNION ALL
SELECT 'parts_master', COUNT(*)
FROM parts_master
UNION ALL
SELECT 'quality_incidents', COUNT(*)
FROM quality_incidents;

DESCRIBE supply_chain_history;

SELECT *
FROM supply_chain_history
LIMIT 10;

SELECT COUNT(DISTINCT part_id) AS unique_parts,
       COUNT(DISTINCT site_id) AS unique_sites
FROM supply_chain_history;

SELECT COUNT(DISTINCT supplier_id) AS unique_suppliers
FROM purchase_orders;

SELECT COUNT(DISTINCT h.part_id) AS unmatched_parts
FROM supply_chain_history h
LEFT JOIN parts_master p
    ON h.part_id = p.part_id
WHERE p.part_id IS NULL;

SELECT COUNT(DISTINCT h.site_id) AS unmatched_sites
FROM supply_chain_history h
LEFT JOIN purchase_orders p
    ON h.site_id = p.site_id
WHERE p.site_id IS NULL;

SELECT DISTINCT site_id
FROM supply_chain_history;

SELECT DISTINCT site_id
FROM purchase_orders
ORDER BY site_id;

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

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT date, site_id, part_id) AS unique_records
FROM supply_chain_history;

SELECT
    MIN(consumption_qty) AS min_consumption,
    MIN(on_hand_qty) AS min_inventory,
    MIN(backorder_qty) AS min_backorder,
    MIN(blocked_qty) AS min_blocked,
    MIN(forecast_qty) AS min_forecast
FROM supply_chain_history;

SELECT
    MIN(forecast_qty) AS min_forecast,
    MAX(forecast_qty) AS max_forecast,
    MIN(forecast_uplift_pct) AS min_uplift,
    MAX(forecast_uplift_pct) AS max_uplift
FROM supply_chain_history;

SELECT DISTINCT forecast_type
FROM supply_chain_history;

SELECT DISTINCT planned_maintenance
FROM supply_chain_history;

SELECT
    MIN(date) AS start_date,
    MAX(date) AS end_date,
    COUNT(DISTINCT date) AS unique_dates
FROM supply_chain_history;

SELECT
    COUNT(*) AS total_parts,
    SUM(shelf_life_days IS NULL) AS missing_shelf_life
FROM parts_master;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT part_id) AS unique_parts
FROM parts_master;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT po_id) AS unique_po_ids
FROM purchase_orders;

SELECT
    SUM(po_id IS NULL) AS missing_po_id,
    SUM(part_id IS NULL) AS missing_part_id,
    SUM(site_id IS NULL) AS missing_site_id,
    SUM(supplier_id IS NULL) AS missing_supplier_id,
    SUM(order_date IS NULL) AS missing_order_date,
    SUM(promised_date IS NULL) AS missing_promised_date,
    SUM(receipt_date IS NULL) AS missing_receipt_date
FROM purchase_orders;

SELECT
    MIN(order_date) AS earliest_order,
    MAX(order_date) AS latest_order,
    MIN(promised_date) AS earliest_promised,
    MAX(promised_date) AS latest_promised,
    MIN(receipt_date) AS earliest_receipt,
    MAX(receipt_date) AS latest_receipt
FROM purchase_orders;

SELECT COUNT(*) AS invalid_receipt_dates
FROM purchase_orders
WHERE receipt_date < order_date;

SELECT
    COUNT(*) AS total_incidents,
    SUM(incident_id IS NULL) AS missing_incident_id,
    SUM(part_id IS NULL) AS missing_part_id,
    SUM(supplier_id IS NULL) AS missing_supplier_id
FROM quality_incidents;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT incident_id) AS unique_incidents
FROM quality_incidents;

SELECT COUNT(DISTINCT q.supplier_id) AS unmatched_suppliers
FROM quality_incidents q
LEFT JOIN (
    SELECT DISTINCT supplier_id
    FROM purchase_orders
) p
    ON q.supplier_id = p.supplier_id
WHERE p.supplier_id IS NULL;

SELECT
    part_id,
    SUM(consumption_qty) AS total_consumption,
    AVG(on_hand_qty) AS avg_inventory,
    SUM(backorder_qty) AS total_backorder,
    SUM(forecast_qty) AS total_forecast
FROM supply_chain_history
GROUP BY part_id
ORDER BY total_consumption DESC;

SELECT
    part_id,
    SUM(consumption_qty) AS total_consumption,
    AVG(on_hand_qty) AS avg_inventory,
    SUM(backorder_qty) AS total_backorder,
    SUM(forecast_qty) AS total_forecast
FROM supply_chain_history
GROUP BY part_id
HAVING SUM(backorder_qty) > 0
ORDER BY total_backorder DESC;

SELECT
    part_id,
    SUM(consumption_qty) AS total_consumption,
    AVG(on_hand_qty) AS avg_inventory,
    ROUND(
        AVG(on_hand_qty) / NULLIF(SUM(consumption_qty) / COUNT(DISTINCT date), 0),
        2
    ) AS inventory_coverage_weeks,
    SUM(backorder_qty) AS total_backorder
FROM supply_chain_history
GROUP BY part_id
ORDER BY inventory_coverage_weeks ASC;

SELECT
    ROUND(
        SUM(backorder_qty) / NULLIF(SUM(consumption_qty), 0) * 100,
        2
    ) AS overall_backorder_rate_pct
FROM supply_chain_history;

SELECT
    part_id,
    SUM(consumption_qty) AS total_consumption,
    SUM(backorder_qty) AS total_backorder,
    ROUND(
        SUM(backorder_qty) / NULLIF(SUM(consumption_qty), 0) * 100,
        2
    ) AS backorder_rate_pct,
    ROUND(AVG(on_hand_qty), 2) AS avg_inventory
FROM supply_chain_history
GROUP BY part_id
HAVING SUM(backorder_qty) > 0
ORDER BY backorder_rate_pct DESC;


SELECT
    part_id,
    SUM(consumption_qty) AS total_consumption,
    ROUND(AVG(on_hand_qty), 2) AS avg_inventory,
    ROUND(
        AVG(on_hand_qty) /
        NULLIF(SUM(consumption_qty) / COUNT(DISTINCT date), 0),
        2
    ) AS inventory_coverage_weeks,
    SUM(backorder_qty) AS total_backorder,
    ROUND(
        SUM(backorder_qty) /
        NULLIF(SUM(consumption_qty), 0) * 100,
        2
    ) AS backorder_rate_pct,
    CASE
        WHEN
            AVG(on_hand_qty) /
            NULLIF(SUM(consumption_qty) / COUNT(DISTINCT date), 0) < 1
            AND
            SUM(backorder_qty) /
            NULLIF(SUM(consumption_qty), 0) > 0.05
        THEN 'CRITICAL'
        WHEN
            AVG(on_hand_qty) /
            NULLIF(SUM(consumption_qty) / COUNT(DISTINCT date), 0) < 1
            AND
            SUM(backorder_qty) > 0
        THEN 'HIGH'
        WHEN SUM(backorder_qty) > 0
        THEN 'MEDIUM'
        ELSE 'LOW'
    END AS risk_level
FROM supply_chain_history
GROUP BY part_id
ORDER BY
    CASE risk_level
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        ELSE 4
    END,
    backorder_rate_pct DESC;


SELECT
    supplier_id,
    COUNT(*) AS total_orders,
    ROUND(AVG(DATEDIFF(receipt_date, order_date)), 2) AS avg_lead_time_days,
    ROUND(AVG(DATEDIFF(receipt_date, promised_date)), 2) AS avg_delay_days,
    SUM(receipt_date > promised_date) AS late_orders
FROM purchase_orders
GROUP BY supplier_id
ORDER BY avg_delay_days DESC;

SELECT
    supplier_id,
    COUNT(*) AS total_orders,
    SUM(receipt_date <= promised_date) AS on_time_orders,
    SUM(receipt_date > promised_date) AS late_orders,
    ROUND(
        SUM(receipt_date <= promised_date) / COUNT(*) * 100,
        2
    ) AS on_time_delivery_pct
FROM purchase_orders
GROUP BY supplier_id
ORDER BY on_time_delivery_pct ASC;


SELECT
    COUNT(*) AS total_orders,
    SUM(receipt_date <= promised_date) AS on_time_orders,
    SUM(receipt_date > promised_date) AS late_orders,
    ROUND(
        SUM(receipt_date <= promised_date) / COUNT(*) * 100,
        2
    ) AS overall_otd_pct
FROM purchase_orders;

SELECT
    supplier_id,
    COUNT(*) AS total_orders,
    ROUND(
        SUM(receipt_date <= promised_date) / COUNT(*) * 100,
        2
    ) AS on_time_delivery_pct,
    CASE
        WHEN SUM(receipt_date <= promised_date) / COUNT(*) < 0.30
            THEN 'CRITICAL'
        WHEN SUM(receipt_date <= promised_date) / COUNT(*) < 0.45
            THEN 'HIGH'
        ELSE 'LOW'
    END AS supplier_risk
FROM purchase_orders
GROUP BY supplier_id
ORDER BY
    CASE supplier_risk
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        ELSE 3
    END,
    on_time_delivery_pct ASC;
    
    
    
    SELECT
    supplier_id,
    COUNT(*) AS total_orders,
    SUM(receipt_date > promised_date) AS late_orders,
    ROUND(
        SUM(receipt_date > promised_date) /
        (SELECT COUNT(*)
         FROM purchase_orders
         WHERE receipt_date > promised_date) * 100,
        2
    ) AS contribution_to_total_late_pct
FROM purchase_orders
GROUP BY supplier_id
ORDER BY contribution_to_total_late_pct DESC;

SELECT
    YEAR(order_date) AS order_year,
    COUNT(*) AS total_orders,
    SUM(receipt_date <= promised_date) AS on_time_orders,
    SUM(receipt_date > promised_date) AS late_orders,
    ROUND(
        SUM(receipt_date <= promised_date) / COUNT(*) * 100,
        2
    ) AS on_time_delivery_pct,
    ROUND(
        AVG(DATEDIFF(receipt_date, promised_date)),
        2
    ) AS avg_delay_days
FROM purchase_orders
GROUP BY YEAR(order_date)
ORDER BY order_year;

SELECT
    supplier_id,
    COUNT(*) AS quality_incidents,
    COUNT(DISTINCT part_id) AS affected_parts
FROM quality_incidents
GROUP BY supplier_id
ORDER BY quality_incidents DESC;
SELECT
    p.supplier_id,
    p.total_orders,
    COALESCE(q.quality_incidents, 0) AS quality_incidents,
    ROUND(
        COALESCE(q.quality_incidents, 0) / p.total_orders * 100,
        2
    ) AS quality_incident_rate_pct
FROM
    (
        SELECT
            supplier_id,
            COUNT(*) AS total_orders
        FROM purchase_orders
        GROUP BY supplier_id
    ) p
LEFT JOIN
    (
        SELECT
            supplier_id,
            COUNT(*) AS quality_incidents
        FROM quality_incidents
        GROUP BY supplier_id
    ) q
    ON p.supplier_id = q.supplier_id
ORDER BY quality_incident_rate_pct DESC;

SELECT
    p.supplier_id,
    p.total_orders,
    ROUND(
        p.on_time_orders / p.total_orders * 100,
        2
    ) AS on_time_delivery_pct,
    ROUND(p.avg_delay_days, 2) AS avg_delay_days,
    COALESCE(q.quality_incidents, 0) AS quality_incidents,
    ROUND(
        COALESCE(q.quality_incidents, 0) / p.total_orders * 100,
        2
    ) AS quality_incident_rate_pct
FROM
    (
        SELECT
            supplier_id,
            COUNT(*) AS total_orders,
            SUM(receipt_date <= promised_date) AS on_time_orders,
            AVG(DATEDIFF(receipt_date, promised_date)) AS avg_delay_days
        FROM purchase_orders
        GROUP BY supplier_id
    ) p
LEFT JOIN
    (
        SELECT
            supplier_id,
            COUNT(*) AS quality_incidents
        FROM quality_incidents
        GROUP BY supplier_id
    ) q
    ON p.supplier_id = q.supplier_id
ORDER BY on_time_delivery_pct ASC;

SELECT
    p.supplier_id,
    p.part_id,
    COUNT(*) AS total_orders,
    SUM(p.receipt_date > p.promised_date) AS late_orders,
    ROUND(
        SUM(p.receipt_date > p.promised_date) / COUNT(*) * 100,
        2
    ) AS late_delivery_pct
FROM purchase_orders p
GROUP BY
    p.supplier_id,
    p.part_id
HAVING COUNT(*) >= 5
ORDER BY late_delivery_pct DESC;

SELECT
    p.supplier_id,
    p.part_id,
    COUNT(*) AS total_orders,
    SUM(p.receipt_date > p.promised_date) AS late_orders,
    ROUND(
        SUM(p.receipt_date > p.promised_date) / COUNT(*) * 100,
        2
    ) AS late_delivery_pct,
    COALESCE(s.total_backorder, 0) AS total_backorder
FROM purchase_orders p
LEFT JOIN (
    SELECT
        part_id,
        SUM(backorder_qty) AS total_backorder
    FROM supply_chain_history
    GROUP BY part_id
) s
    ON p.part_id = s.part_id
GROUP BY
    p.supplier_id,
    p.part_id,
    s.total_backorder
HAVING COUNT(*) >= 5
ORDER BY
    total_backorder DESC,
    late_delivery_pct DESC;





SELECT
    supplier_id,
    part_id,
    total_orders,
    late_orders,
    late_delivery_pct,
    total_backorder
FROM (
    SELECT
        p.supplier_id,
        p.part_id,
        COUNT(*) AS total_orders,
        SUM(p.receipt_date > p.promised_date) AS late_orders,
        ROUND(
            SUM(p.receipt_date > p.promised_date) / COUNT(*) * 100,
            2
        ) AS late_delivery_pct,
        COALESCE(s.total_backorder, 0) AS total_backorder
    FROM purchase_orders p
    LEFT JOIN (
        SELECT
            part_id,
            SUM(backorder_qty) AS total_backorder
        FROM supply_chain_history
        GROUP BY part_id
    ) s
        ON p.part_id = s.part_id
    GROUP BY
        p.supplier_id,
        p.part_id,
        s.total_backorder
    HAVING COUNT(*) >= 5
) x
WHERE total_backorder > 0
ORDER BY
    total_backorder DESC,
    late_delivery_pct DESC;
    
    
    
  SELECT
    supplier_id,
    part_id,
    total_orders,
    late_orders,
    late_delivery_pct,
    total_backorder,
    CASE
        WHEN late_delivery_pct >= 50
             AND total_backorder >= 50
            THEN 'CRITICAL'
        WHEN late_delivery_pct >= 40
             AND total_backorder >= 25
            THEN 'HIGH'
        WHEN late_delivery_pct >= 30
             AND total_backorder > 0
            THEN 'MEDIUM'
        ELSE 'LOW'
    END AS supplier_part_risk
FROM (
    SELECT
        p.supplier_id,
        p.part_id,
        COUNT(*) AS total_orders,
        SUM(p.receipt_date > p.promised_date) AS late_orders,
        ROUND(
            SUM(p.receipt_date > p.promised_date) / COUNT(*) * 100,
            2
        ) AS late_delivery_pct,
        COALESCE(s.total_backorder, 0) AS total_backorder
    FROM purchase_orders p
    LEFT JOIN (
        SELECT
            part_id,
            SUM(backorder_qty) AS total_backorder
        FROM supply_chain_history
        GROUP BY part_id
    ) s
        ON p.part_id = s.part_id
    GROUP BY
        p.supplier_id,
        p.part_id,
        s.total_backorder
    HAVING COUNT(*) >= 5
) x
WHERE total_backorder > 0
ORDER BY
    CASE supplier_part_risk
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        ELSE 4
    END,
    total_backorder DESC;  
    
    
    SELECT
    forecast_type,
    COUNT(*) AS total_records,
    ROUND(AVG(consumption_qty), 2) AS avg_actual_consumption,
    ROUND(AVG(forecast_qty), 2) AS avg_forecast,
    ROUND(
        AVG(forecast_qty - consumption_qty),
        2
    ) AS avg_forecast_bias,
    ROUND(
        AVG(ABS(forecast_qty - consumption_qty)),
        2
    ) AS MAE
FROM supply_chain_history
GROUP BY forecast_type
ORDER BY MAE DESC;


SELECT
    part_id,
    forecast_type,
    COUNT(*) AS records,
    ROUND(AVG(consumption_qty), 2) AS avg_actual,
    ROUND(AVG(forecast_qty), 2) AS avg_forecast,
    ROUND(
        AVG(ABS(forecast_qty - consumption_qty)),
        2
    ) AS MAE,
    ROUND(
        AVG(forecast_qty - consumption_qty),
        2
    ) AS forecast_bias
FROM supply_chain_history
GROUP BY
    part_id,
    forecast_type
ORDER BY MAE DESC;



SELECT
    site_id,
    SUM(consumption_qty) AS total_consumption,
    ROUND(AVG(on_hand_qty), 2) AS avg_inventory,
    SUM(backorder_qty) AS total_backorder,
    SUM(blocked_qty) AS total_blocked,
    SUM(planned_maintenance) AS maintenance_records
FROM supply_chain_history
GROUP BY site_id
ORDER BY total_backorder DESC;


SELECT
    site_id,
    SUM(consumption_qty) AS total_consumption,
    SUM(backorder_qty) AS total_backorder,
    ROUND(
        SUM(backorder_qty) / NULLIF(SUM(consumption_qty), 0) * 100,
        2
    ) AS backorder_rate_pct,
    ROUND(AVG(on_hand_qty), 2) AS avg_inventory
FROM supply_chain_history
GROUP BY site_id
ORDER BY backorder_rate_pct DESC;


SELECT
    planned_maintenance,
    COUNT(*) AS total_records,
    SUM(backorder_qty) AS total_backorder,
    ROUND(AVG(backorder_qty), 2) AS avg_backorder,
    ROUND(AVG(consumption_qty), 2) AS avg_consumption
FROM supply_chain_history
GROUP BY planned_maintenance
ORDER BY planned_maintenance;



SELECT
    site_id,
    SUM(blocked_qty) AS total_blocked,
    ROUND(AVG(blocked_qty), 2) AS avg_blocked,
    SUM(on_hand_qty) AS total_inventory,
    ROUND(
        SUM(blocked_qty) / NULLIF(SUM(on_hand_qty), 0) * 100,
        2
    ) AS blocked_inventory_pct
FROM supply_chain_history
GROUP BY site_id
ORDER BY blocked_inventory_pct DESC;


SELECT
    SUM(on_hand_qty) AS total_inventory,
    SUM(blocked_qty) AS total_blocked,
    ROUND(
        SUM(blocked_qty) / NULLIF(SUM(on_hand_qty), 0) * 100,
        2
    ) AS overall_blocked_inventory_pct
FROM supply_chain_history;



SELECT
    YEAR(date) AS year,
    forecast_type,
    ROUND(AVG(ABS(forecast_qty - consumption_qty)), 2) AS MAE,
    ROUND(AVG(forecast_qty - consumption_qty), 2) AS forecast_bias
FROM supply_chain_history
GROUP BY YEAR(date), forecast_type
ORDER BY year, forecast_type;



SELECT
    YEAR(date) AS year,
    ROUND(AVG(consumption_qty), 2) AS avg_consumption,
    SUM(consumption_qty) AS total_consumption,
    SUM(backorder_qty) AS total_backorder,
    ROUND(
        SUM(backorder_qty) / NULLIF(SUM(consumption_qty), 0) * 100,
        2
    ) AS backorder_rate_pct
FROM supply_chain_history
GROUP BY YEAR(date)
ORDER BY year;


SELECT
    YEAR(date) AS year,
    MONTH(date) AS month,
    ROUND(AVG(consumption_qty), 2) AS avg_consumption,
    SUM(consumption_qty) AS total_consumption,
    SUM(backorder_qty) AS total_backorder
FROM supply_chain_history
GROUP BY
    YEAR(date),
    MONTH(date)
ORDER BY
    year,
    month;
    
    
    SELECT
    MONTH(date) AS month,
    ROUND(AVG(consumption_qty), 2) AS avg_consumption,
    SUM(consumption_qty) AS total_consumption,
    SUM(backorder_qty) AS total_backorder,
    ROUND(
        SUM(backorder_qty) /
        NULLIF(SUM(consumption_qty), 0) * 100,
        2
    ) AS backorder_rate_pct
FROM supply_chain_history
GROUP BY MONTH(date)
ORDER BY month;


SELECT
    p.supplier_id,
    p.site_id,
    COUNT(*) AS total_orders,
    SUM(p.receipt_date > p.promised_date) AS late_orders,
    ROUND(
        SUM(p.receipt_date > p.promised_date) / COUNT(*) * 100,
        2
    ) AS late_delivery_pct
FROM purchase_orders p
GROUP BY
    p.supplier_id,
    p.site_id
HAVING COUNT(*) >= 10
ORDER BY late_delivery_pct DESC;

DESCRIBE quality_incidents;

SELECT
    defect_severity,
    COUNT(*) AS total_incidents
FROM quality_incidents
GROUP BY defect_severity
ORDER BY total_incidents DESC;

SELECT
    defect_type,
    COUNT(*) AS total_incidents,
    SUM(scrap_qty) AS total_scrap
FROM quality_incidents
GROUP BY defect_type
ORDER BY total_incidents DESC;

SELECT
    defect_type,
    COUNT(*) AS critical_incidents,
    SUM(scrap_qty) AS critical_scrap
FROM quality_incidents
WHERE defect_severity = 'Critical'
GROUP BY defect_type
ORDER BY critical_incidents DESC;


SELECT
    supplier_id,
    COUNT(*) AS total_incidents,
    SUM(scrap_qty) AS total_scrap,
    ROUND(AVG(scrap_qty), 2) AS avg_scrap_per_incident
FROM quality_incidents
GROUP BY supplier_id
ORDER BY total_scrap DESC;


SELECT
    site_id,
    COUNT(*) AS total_incidents,
    SUM(scrap_qty) AS total_scrap,
    ROUND(AVG(scrap_qty), 2) AS avg_scrap_per_incident
FROM quality_incidents
GROUP BY site_id
ORDER BY total_scrap DESC;

SELECT
    COUNT(*) AS total_incidents,
    SUM(scrap_qty) AS total_scrap,
    ROUND(AVG(scrap_qty), 2) AS avg_scrap_per_incident
FROM quality_incidents;


SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT CONCAT(
        date, site_id, part_id
    )) AS unique_records
FROM supply_chain_history;


SELECT
    SUM(consumption_qty < 0) AS negative_consumption,
    SUM(on_hand_qty < 0) AS negative_inventory,
    SUM(backorder_qty < 0) AS negative_backorder,
    SUM(blocked_qty < 0) AS negative_blocked,
    SUM(forecast_qty < 0) AS negative_forecast
FROM supply_chain_history;