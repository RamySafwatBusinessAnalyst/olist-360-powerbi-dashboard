# Olist 360: Sales, Retention, Delivery & Customer Intelligence Dashboard

An end-to-end **Data Analyst / Business Intelligence project** built using **SQL, Python, and Power BI** on the **Olist Brazilian E-Commerce Public Dataset**.

This project was designed to provide a unified analytical view of marketplace performance across **sales trends, customer retention, delivery operations, product/category performance, customer satisfaction, and basket cross-sell opportunities**.

---

## Project Overview

Olist 360 is a business intelligence and customer analytics project created to help business users move from fragmented operational reporting to a more strategic understanding of:

- what drives revenue
- where operational gaps exist
- which customers and categories create the most value
- which business levers can improve long-term performance

The project combines:

- data cleaning and validation
- analytical feature engineering
- exploratory data analysis (EDA)
- Power BI dashboard design

into one decision-support framework.

---

## Business Problem

The business lacks a unified analytical view connecting:

- sales performance
- customer loyalty
- delivery operations
- customer satisfaction

Without this integration, it becomes difficult to identify the true drivers of growth, detect operational bottlenecks, and understand retention behavior.

---

## Project Objectives

This project was built to answer the following business questions:

1. How have revenue and order volume changed over time?
2. Which geographies drive revenue growth?
3. Which categories generate the highest revenue and which underperform?
4. How do delivery delays affect customer satisfaction?
5. Which customer segments are the most valuable?
6. How strong is customer retention over time?
7. Which basket and cross-sell opportunities can increase value per order?

---

## Tools & Technologies

- **SQL** → schema validation, relational checks, data preparation
- **Python** → cleaning, preprocessing, feature engineering, EDA
- **Power BI** → data modeling, DAX KPIs, dashboards
- **Jupyter Notebook** → analytical workflow documentation

---

## Analytical Scope

The project covers the following analytical themes:

- **Sales & Trends**
- **Geography Performance**
- **Category Performance**
- **Delivery & Customer Satisfaction**
- **Customer Segmentation (RFM)**
- **Cohort Retention**
- **Basket & Cross-Sell Analysis**

---

## Key Insights

### 1. Revenue growth was strong but volume-driven
- The business reached its strongest month in **November 2017**
- Revenue growth was driven mainly by **higher order volume**
- AOV remained relatively stable during the active growth period

### 2. Revenue is highly concentrated geographically
- **SP, RJ, and MG** contribute the majority of total revenue
- Smaller states show higher AOV and may represent premium-value opportunities

### 3. Category performance is uneven
- A limited number of categories drive most of the revenue
- Some categories underperform in customer satisfaction and delivery performance

### 4. Delivery delays have a strong negative effect on review scores
- Late deliveries are associated with significantly lower customer satisfaction
- Delays beyond **3 days** represent a critical threshold

### 5. The business is highly acquisition-driven
- The customer base is dominated by **one-time buyers**
- Repeat customers are more valuable, but too few to materially impact the business model

### 6. Retention is structurally weak
- Cohort analysis shows retention drops sharply after the first purchase
- Long-term customer retention remains very low across cohorts

### 7. Basket expansion is a growth opportunity
- Multi-category baskets have higher order value
- Cross-sell rules reveal practical recommendation and bundling opportunities
- Most basket growth potential lies in expanding beyond single-category purchases

---

## Dashboard Pages

The Power BI solution includes the following dashboard pages:

- **Executive Overview**
- **Sales & Trends**
- **Geography**
- **Category Performance**
- **Delivery & Satisfaction**
- **Customers / RFM**
- **Cohort Retention**
- **Basket & Cross-Sell**

---

## Files Included

### Report
- Final project report (PDF / DOCX)

### Dashboards
- Dashboard screenshots
- Power BI dashboard file (if shared separately)

### Notebook
- Jupyter notebook used for preparation, EDA, and feature engineering

### SQL
- SQL scripts used for data preparation, checks, and validation
---

## Dashboard Preview

![Executive Overview](dashboards/screenshots/executive-overview.png)

### Sales & Trends
![Sales & Trends](dashboards/screenshots/sales-trends.png)

### Delivery & Satisfaction
![Delivery & Satisfaction](dashboards/screenshots/delivery.png)

### Customers / RFM
![Customers / RFM](dashboards/screenshots/customers-rfm.png)

For additional visuals, see the full screenshots inside the **dashboards/screenshots/** folder.

--------


##  Business Value
This project demonstrates how a Data Analyst can move from raw transactional data to:

executive KPI design
structured analytical modeling
business-focused dashboards
strategic recommendations

The project highlights three major business opportunities:

improving delivery reliability
strengthening customer retention
expanding baskets through cross-sell strategies

---
----

## Data Source

This project uses the **Brazilian E-Commerce Public Dataset by Olist**.

- **Source / Provider:** Olist
- **Original dataset page:** https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
- **Dataset summary:** Public Brazilian e-commerce dataset containing approximately 100k orders from 2016 to 2018, including orders, customers, sellers, products, payments, reviews, and geolocation data.
- **Anonymization notice:** According to the original source, the dataset is anonymized and identifying references in review text were replaced.

## Important License Scope Notice

**The MIT License in this repository applies only to the original code, notebooks, SQL scripts, documentation, and other original project materials created by the repository owner.**

**It does NOT apply to third-party dataset files, including the Olist dataset, whether raw, cleaned, transformed, or exported.**

All dataset files remain subject to the **original dataset source terms and license conditions**.

## Dataset Attribution

Original dataset credit belongs to **Olist**.  
Original dataset page: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

This repository does **not** claim ownership of the original dataset.

## Dataset License Notice

If the original dataset page specifies the dataset license as **Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)**, then any dataset files included in this repository are intended to remain subject to that license and not to the MIT License.

CC BY-NC-SA 4.0:
https://creativecommons.org/licenses/by-nc-sa/4.0/

Under that license:
- Attribution to the original source must be preserved.
- Commercial use is not permitted.
- Adaptations or derivative versions must be shared under the same license.
- Changes made to the original material should be indicated.
- No endorsement by Olist is implied.

## Changes Made to the Data

For analysis purposes, this project may include one or more of the following transformations:
- data cleaning
- missing value handling
- data type standardization
- column renaming
- feature engineering
- aggregation
- analytical exports
- data quality flags
- derived tables for reporting or modeling

Any such modifications are analytical transformations for educational and portfolio purposes only.

## Non-Commercial Data Use Notice

Dataset files included in this repository, if any, are shared only for **educational, reproducibility, and portfolio purposes**.

They are **not** provided under the MIT License and are **not** intended for unrestricted commercial reuse.

Anyone reusing dataset files from this repository is responsible for reviewing and complying with the original dataset license and source terms.

## No Ownership / No Endorsement

This repository does not claim any ownership in the original Olist dataset.

Nothing in this repository should be interpreted as suggesting that **Olist** endorses the repository owner, this project, or any derived analysis, dashboards, conclusions, or models.

## Disclaimer

This repository is provided "as is", without warranties of any kind.

The repository owner makes no representation that inclusion of third-party data is sufficient for every downstream use case. Users are responsible for independently verifying the original source terms, applicable license conditions, and any other rights or restrictions that may apply.
----


##  Author
**Ramy Safwat**
**Role:** Business Analyst / Business Intelligence Portfolio Project
---
## Repository Structure

```text
report/                  -> final project report
dashboards/screenshots/  -> dashboard screenshots
notebooks/               -> Jupyter notebooks
sql/                     -> SQL scripts
data/                    -> data notes / cleaned data references
assets/                  -> additional supporting files

