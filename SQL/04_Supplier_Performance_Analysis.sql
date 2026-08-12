-- ============================================================
-- 04_Supplier_Performance_Analysis.sql
-- Supplier delivery performance, late orders, quality linkage, and supplier-part risk analysis.
-- ============================================================

-- Query 1
SELECT
    supplier_id,
    COUNT(*) AS total_orders,
    ROUND(AVG(DATEDIFF(receipt_date, order_date)), 2) AS avg_lead_time_days,
    ROUND(AVG(DATEDIFF(receipt_date, promised_date)), 2) AS avg_delay_days,
    SUM(receipt_date > promised_date) AS late_orders
FROM purchase_orders
GROUP BY supplier_id
ORDER BY avg_delay_days DESC;

-- Query 2
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

-- Query 3
SELECT
    COUNT(*) AS total_orders,
    SUM(receipt_date <= promised_date) AS on_time_orders,
    SUM(receipt_date > promised_date) AS late_orders,
    ROUND(
        SUM(receipt_date <= promised_date) / COUNT(*) * 100,
        2
    ) AS overall_otd_pct
FROM purchase_orders;

-- Query 4
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

-- Query 5
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

-- Query 6
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

-- Query 7
SELECT
    supplier_id,
    COUNT(*) AS quality_incidents,
    COUNT(DISTINCT part_id) AS affected_parts
FROM quality_incidents
GROUP BY supplier_id
ORDER BY quality_incidents DESC;

-- Query 8
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

-- Query 9
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

-- Query 10
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

-- Query 11
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

-- Query 12
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

-- Query 13
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

-- Query 14
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
