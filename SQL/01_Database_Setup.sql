-- ============================================================
-- 01_Database_Setup.sql
-- Database setup and initial table inspection queries.
-- ============================================================

-- Query 1
CREATE DATABASE supply_chain_project;

-- Query 2
USE supply_chain_project;

-- Query 3
SELECT COUNT(*) AS row_count
FROM supply_chain_history;

-- Query 4
SELECT 'purchase_orders' AS table_name, COUNT(*) AS row_count
FROM purchase_orders
UNION ALL
SELECT 'parts_master', COUNT(*)
FROM parts_master
UNION ALL
SELECT 'quality_incidents', COUNT(*)
FROM quality_incidents;

-- Query 5
DESCRIBE supply_chain_history;

-- Query 6
SELECT *
FROM supply_chain_history
LIMIT 10;

-- Query 7
SELECT COUNT(DISTINCT part_id) AS unique_parts,
       COUNT(DISTINCT site_id) AS unique_sites
FROM supply_chain_history;

-- Query 8
SELECT COUNT(DISTINCT supplier_id) AS unique_suppliers
FROM purchase_orders;

-- Query 9
SELECT DISTINCT site_id
FROM supply_chain_history;

-- Query 10
SELECT DISTINCT site_id
FROM purchase_orders
ORDER BY site_id;
