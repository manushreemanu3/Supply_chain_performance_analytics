-- ============================================================
-- 05_Forecast_Analysis.sql
-- Forecast accuracy, forecast bias, and MAE analysis.
-- ============================================================

-- Query 1
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

-- Query 2
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

-- Query 3
SELECT
    YEAR(date) AS year,
    forecast_type,
    ROUND(AVG(ABS(forecast_qty - consumption_qty)), 2) AS MAE,
    ROUND(AVG(forecast_qty - consumption_qty), 2) AS forecast_bias
FROM supply_chain_history
GROUP BY YEAR(date), forecast_type
ORDER BY year, forecast_type;
