# Supply Chain Performance & Operations Analytics

An interactive Power BI dashboard developed to analyze supply chain performance across operations, supplier fulfillment, inventory planning, procurement, parts, demand, and quality incidents.

## Project Overview

This project transforms supply chain operational data into an interactive analytical dashboard that enables users to monitor key performance indicators, identify operational constraints, evaluate supplier performance, analyze inventory and procurement patterns, and investigate quality incidents.

The dashboard consists of five analytical pages with interactive year-based filtering and cross-filtering between visuals.

## Business Objectives

- Monitor overall supply chain performance using key operational KPIs.
- Analyze consumption, forecast, inventory, and backorder trends.
- Evaluate supplier fulfillment and delayed purchase orders.
- Identify inventory and supply constraints across sites.
- Analyze parts and procurement patterns.
- Examine quality incidents, defect types, severity, and scrap quantity.
- Provide an interactive view for exploring operational performance across different years.

## Dashboard Pages

### 1. Supply Chain Performance & Operations Overview

Provides an executive-level overview of overall supply chain performance.

Key metrics and analysis include:

- Total Consumption
- Total Backorders
- Total Inventory
- Total Scrap
- Total Quality Incidents
- Forecast vs Consumption
- Inventory trends
- Consumption trends

![Supply Chain Performance & Operations Overview](Dashboard%20Screenshots/Page_1-Executive%20Overview.jpg)

---

### 2. Supplier Performance & Fulfillment Analysis

Evaluates supplier fulfillment performance and purchase order delivery behavior.

Key analysis includes:

- Supplier Performance Overview
- Overall Supplier Fulfillment Rate
- Delayed Purchase Orders by Site
- On-Time vs Delayed Purchase Orders
- Supplier Fulfillment Rate by Year

![Supplier Performance & Fulfillment Analysis](Dashboard%20Screenshots/Page_2-Supplier%20Performance.jpg)

---

### 3. Inventory Planning & Supply Constraints

Analyzes inventory levels, supply constraints, forecast variance, blocked inventory, and backorders.

Key analysis includes:

- Supply Constraints by Year
- Forecast vs Consumption Variance
- Inventory by Site
- Forecast Quantity by Type
- Blocked Inventory by Site
- Available vs Blocked Inventory
- Backorders by Site

![Inventory Planning & Supply Constraints](Dashboard%20Screenshots/Page_3-Demand%20and%20Forecast%20Analysis.jpg)

---

### 4. Parts, Inventory & Procurement Analysis

Provides detailed analysis of parts, backorders, inventory value, procurement quantities, cost, and supplier risk.

Key analysis includes:

- Top 10 Parts by Backorder Quantity
- Backorder Quantity by Part Family
- Inventory Value by Part Family
- Ordered vs Received Quantity
- Average Unit Cost by Criticality Class
- Part Cost vs Repair Lead Time by Risk Class
- Parts Distribution by Risk Class

![Parts, Inventory & Procurement Analysis](Dashboard%20Screenshots/Page_4-Inventory%20and%20Procurement%20Analysis.jpg)

---

### 5. Quality & Incident Analysis

Analyzes quality incidents, defect types, severity, scrap quantity, and supplier-level quality patterns.

Key analysis includes:

- Quality Incident Trend by Year
- Critical Quality Incidents
- Quality Incidents by Defect Type
- Quality Incidents by Severity and Defect Type
- Scrap Quantity by Defect Type
- Quality Incidents vs Scrap Quantity by Supplier

![Quality & Incident Analysis](Dashboard%20Screenshots/Page_5-Quality%20and%20Incident%20Analysis.jpg)

---

## Key Insights Enabled by the Dashboard

The dashboard supports analysis of:

- Changes in consumption, inventory, and backorders across years.
- Supplier fulfillment and delayed purchase order patterns.
- Differences between forecasted and consumed quantities.
- Inventory distribution across different sites.
- Parts and part families contributing to backorders.
- Ordered versus received quantities.
- Cost and repair lead-time patterns across supplier risk classes.
- Quality incidents across defect types and severity levels.
- Relationships between quality incidents and scrap quantities.

## Data Model

The Power BI model combines four related operational datasets covering:

- Supply chain activity
- Purchase orders
- Parts and inventory information
- Quality incidents

Relationships between the datasets allow information to be analyzed across different operational areas.

A dedicated year-based filtering structure enables consistent time-based analysis across the dashboard.

## Tools & Technologies

- Power BI Desktop
- Power Query
- Data Modeling
- DAX
- Interactive Data Visualization

## Dashboard Features

- Interactive year slicer
- KPI cards
- Trend analysis
- Supplier performance analysis
- Inventory analysis
- Procurement analysis
- Quality and incident analysis
- Cross-filtering between visuals
- Conditional formatting
- Multiple analytical visualizations

## Project Structure

```text
Supply_chain_performance_analytics/
│
├── PowerBI/
│   └── Supply_Chain_Performance_Analytics.pbix
│
├── Dashboard Screenshots/
│   ├── Page_1-Executive Overview.jpg
│   ├── Page_2-Supplier Performance.jpg
│   ├── Page_3-Demand and Forecast Analysis.jpg
│   ├── Page_4-Inventory and Procurement Analysis.jpg
│   └── Page_5-Quality and Incident Analysis.jpg
│
└── README.md
