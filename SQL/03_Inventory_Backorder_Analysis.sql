-- ============================================================
-- 03_Inventory_Backorder_Analysis.sql
-- Inventory, consumption, backorder, coverage, and part-level risk analysis.
-- ============================================================

-- Query 1
SELECT
    part_id,
    SUM(consumption_qty) AS total_consumption,
    AVG(on_hand_qty) AS avg_inventory,
    SUM(backorder_qty) AS total_backorder,
    SUM(forecast_qty) AS total_forecast
FROM supply_chain_history
GROUP BY part_id
ORDER BY total_consumption DESC;

-- Query 2
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

-- Query 3
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

-- Query 4
SELECT
    ROUND(
        SUM(backorder_qty) / NULLIF(SUM(consumption_qty), 0) * 100,
        2
    ) AS overall_backorder_rate_pct
FROM supply_chain_history;

-- Query 5
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

-- Query 6
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
