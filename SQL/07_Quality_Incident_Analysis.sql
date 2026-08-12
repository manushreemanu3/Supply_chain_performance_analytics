-- ============================================================
-- 07_Quality_Incident_Analysis.sql
-- Quality incidents, defect severity/type, scrap, supplier, and site-level quality analysis.
-- ============================================================

-- Query 1
DESCRIBE quality_incidents;

-- Query 2
SELECT
    defect_severity,
    COUNT(*) AS total_incidents
FROM quality_incidents
GROUP BY defect_severity
ORDER BY total_incidents DESC;

-- Query 3
SELECT
    defect_type,
    COUNT(*) AS total_incidents,
    SUM(scrap_qty) AS total_scrap
FROM quality_incidents
GROUP BY defect_type
ORDER BY total_incidents DESC;

-- Query 4
SELECT
    defect_type,
    COUNT(*) AS critical_incidents,
    SUM(scrap_qty) AS critical_scrap
FROM quality_incidents
WHERE defect_severity = 'Critical'
GROUP BY defect_type
ORDER BY critical_incidents DESC;

-- Query 5
SELECT
    supplier_id,
    COUNT(*) AS total_incidents,
    SUM(scrap_qty) AS total_scrap,
    ROUND(AVG(scrap_qty), 2) AS avg_scrap_per_incident
FROM quality_incidents
GROUP BY supplier_id
ORDER BY total_scrap DESC;

-- Query 6
SELECT
    site_id,
    COUNT(*) AS total_incidents,
    SUM(scrap_qty) AS total_scrap,
    ROUND(AVG(scrap_qty), 2) AS avg_scrap_per_incident
FROM quality_incidents
GROUP BY site_id
ORDER BY total_scrap DESC;

-- Query 7
SELECT
    COUNT(*) AS total_incidents,
    SUM(scrap_qty) AS total_scrap,
    ROUND(AVG(scrap_qty), 2) AS avg_scrap_per_incident
FROM quality_incidents;

-- Query 8
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT CONCAT(
        date, site_id, part_id
    )) AS unique_records
FROM supply_chain_history;
