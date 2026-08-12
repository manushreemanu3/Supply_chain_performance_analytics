-- ============================================================
-- 06_Site_Operations_Analysis.sql
-- Site-level consumption, inventory, backorders, maintenance, blocked inventory, and time-based operations analysis.
-- ============================================================

-- Query 1
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

-- Query 2
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

-- Query 3
SELECT
    planned_maintenance,
    COUNT(*) AS total_records,
    SUM(backorder_qty) AS total_backorder,
    ROUND(AVG(backorder_qty), 2) AS avg_backorder,
    ROUND(AVG(consumption_qty), 2) AS avg_consumption
FROM supply_chain_history
GROUP BY planned_maintenance
ORDER BY planned_maintenance;

-- Query 4
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

-- Query 5
SELECT
    SUM(on_hand_qty) AS total_inventory,
    SUM(blocked_qty) AS total_blocked,
    ROUND(
        SUM(blocked_qty) / NULLIF(SUM(on_hand_qty), 0) * 100,
        2
    ) AS overall_blocked_inventory_pct
FROM supply_chain_history;

-- Query 6
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

-- Query 7
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

-- Query 8
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
