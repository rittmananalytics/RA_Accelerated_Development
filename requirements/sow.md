## 

## 

## 

## Rittman Analytics \- Statement of Work

# Barton Peveril Sixth Form College \- Proposal

## Version 1.1 Prepared By Mark Rittman, CEO, Rittman Analytics For Chris Loveday, Vice Principal

## Effective Date : 25th November 2025

# 

Table of Contents

[Background and Context](#background-and-context)

[Problem to be Solved](#problem-to-be-solved)

[Proposed Solution](#proposed-solution)

[Stage 1 MVP: Core Student Attainment](#stage-1-mvp:-core-student-attainment)

[Business functionality and capabilities](#business-functionality-and-capabilities)

[Data sources, modeling and integration](#data-sources,-modeling-and-integration)

[Challenges](#challenges)

[Stage 2: ALPS Provider Benchmarking Integration](#stage-2:-alps-provider-benchmarking-integration)

[Business functionality and capabilities](#business-functionality-and-capabilities-1)

[Data sources, modeling and integration](#data-sources,-modeling-and-integration-1)

[Challenges](#challenges-1)

[Stage 3: Six Dimensions/JEDI Benchmarking Integration](#stage-3:-six-dimensions/jedi-benchmarking-integration)

[Business functionality and capabilities](#business-functionality-and-capabilities-2)

[Data sources, modeling and integration](#data-sources,-modeling-and-integration-2)

[Challenges](#challenges-2)

[Services Schedule](#services-schedule)

[Stage 1 MVP: Core Student Attainment](#stage-1-mvp:-core-student-attainment-1)

[Stage 2: ALPS Provider Benchmarking Integration](#stage-2:-alps-provider-benchmarking-integration-1)

[Stage 3: Six Dimensions/JEDI Benchmarking Integration](#stage-3:-six-dimensions/jedi-benchmarking-integration-1)

[Commercials](#commercials)

[Timeline](#timeline)

[Principal Contacts](#principal-contacts)

# 

# Background and Context {#background-and-context}

Barton Peveril is undertaking a strategic data project to consolidate six years of student results data from multiple, disparate sources. These include the ProSolution SQL database, 6Dimension reports, ALPS reports, and DfE performance tables.

The primary goal of this platform is to empower a range of stakeholders—from the Senior Leadership Team (SLT) to teachers—to interrogate this consolidated data. A key requirement is the ability to use natural language queries (NLQ) to explore trends and answer questions such as:

* How did headline outcomes trend over the last 6 years? Overall pass/attainment rates, high grades (A\*–B / D\*–M), average points/grade, and value-added/ALPS bands by year and programme type.  
* Are we hitting internal targets and external benchmarks? Compare centre results to ALPS benchmarks and DfE performance tables; show percentile rank and confidence bands.  
* Which subjects are consistently over- or under-performing? 6-year subject league with stability (variance) and trajectory.  
* Where are the attainment gaps? Gender, disadvantaged, ethnicity, SEND—gap size and whether it's narrowing over time.  
* How have grade profiles shifted by subject and specification across years?  
* What are our first-sit vs re-sit improvement rates and time-to-improvement.  
* Which component drives variance year-to-year?

while enforcing granular, role-based data access for different user groups.

# 

# Problem to be Solved {#problem-to-be-solved}

The college faces several challenges that this project aims to solve.

* First, performance data is currently siloed across systems with overlapping but inconsistent metrics and definitions. This makes it difficult to create a single, trustworthy view of performance, compare value-added measures from different sources (e.g., ALPS vs. DfE), or analyse long-term trends.  
* Second, this fragmentation places a significant ad-hoc reporting burden on the MIS team. Senior staff and subject leaders must request data extracts rather than self-serving insights, which is time-consuming and limits exploratory analysis.  
* Finally, the success of a natural language query tool depends entirely on a robust semantic layer. The tool must correctly interpret user questions by mapping them to accurately codified business logic and definitions (such as 'disadvantage', 'grade points', or 'value-added' variants). Without this, the NLQ will return inconsistent or untrustworthy answers.

# 

# Proposed Solution {#proposed-solution}

## Stage 1 MVP: Core Student Attainment {#stage-1-mvp:-core-student-attainment}

This stage must come first—it establishes the foundational model, semantic definitions, and data quality that external benchmarking stages depend on. Without accurate internal data, external comparisons would be meaningless.

### Business functionality and capabilities {#business-functionality-and-capabilities}

Stage 1 moves Barton Peveril from spreadsheet-based analysis to a governed analytics platform. It delivers student-level and course-level reporting from ProSolution, including demographic analysis, prior attainment tracking, and equity dashboards. 

The platform enables trend analysis, internal target comparison, and attainment gap identification across gender, disadvantage, ethnicity, and SEND. Role-based access controls and mandatory filters prevent accidental queries across all historical data. 

This MVP provides the semantic layer foundation needed for natural language queries.

### Data sources, modeling and integration {#data-sources,-modeling-and-integration}

- **Data source:** ProSolution SQL database as the single data source  
- **Dimensional model:** 7 dimension tables (academic year, offering type, course header, offering, student, student detail, prior attainment) and 1 fact table (enrolment\_fct) at student-enrolment grain  
- **dbt project:** 20+ models with 50+ data quality tests  
- **Looker platform:** 2 explores and 8 views exposed through 2 dashboards (Course Performance and Equity & Diversity)

### Challenges {#challenges}

1. **Data access permissions and GDPR compliance** \- Determining who has database access and what compliance requirements apply  
2. **Academic year scope** \- Deciding between 3 years initial load vs. all 6 years of historical data  
3. **Business rule validation** \- Ensuring filter logic and derived fields are correct and haven't changed recently

## Stage 2: ALPS Provider Benchmarking Integration {#stage-2:-alps-provider-benchmarking-integration}

Stage 2 must follow Stage 1 for the dim\_offering dimension. Stage 3 will reuse this proven methodology but face multiplied PDF parsing challenges with 44 reports instead of 2\.

### Business functionality and capabilities {#business-functionality-and-capabilities-1}

Stage 2 adds subject-level external benchmarking through ALPS Provider Reports. This enables critical questions: 

* Are Biology students above or below national standards?   
* Is 85% A\*-B strong or weak?   
* Which subjects significantly outperform or underperform? 

ALPS provides standardized comparison across UK sixth form providers, transforming isolated internal metrics into meaningful benchmarks.

### Data sources, modeling and integration {#data-sources,-modeling-and-integration-1}

- **Data source:** ALPS data from pre-aggregated provider reports at subject-level grain  
- **Fact table:** Separate alps\_subject\_performance\_fct to avoid grain mismatch with student-level data  
- **dbt implementation:** 2 staging models for A-Level and BTEC data, fuzzy matching logic for subject mapping  
- **Warehouse fact table:** 40+ columns supporting multiple grading scales with sparse column design handling A-Level (A\* through X), BTEC single-award (D\* through P), and BTEC double-award (D*D* through PP) grades in one table  
- **Looker platform:** 1 explore and 1 dashboard for ALPS subject benchmarking

### Challenges {#challenges-1}

1. **PDF parsing model selection** \- Selecting between Google's Document AI OCR (excels at structured documents with native table detection) vs. Cloud Vision AI (provides flexible layout analysis for complex formats but requires additional post-processing), with tradeoffs in accuracy, cost, and table structure preservation  
2. **Client review and corrections** \- Parsed CSV outputs must be reviewed by the client for accuracy of subject names, percentage values, and grade distributions, with manual corrections needed for parsing errors before data integration begins  
3. **Subject name mapping** \- Mapping between ALPS subject names ("A \- Biology") and ProSolution codes ("BIOL-A2-2024") requires fuzzy matching combined with manual mapping tables  
4. **Multiple grading scales** \- Handling A-Level and BTEC grading scales in a single sparse fact table structure  
5. **Academic year assignment** \- Assigning ambiguous report dates to specific academic years

## Stage 3: Six Dimensions/JEDI Benchmarking Integration {#stage-3:-six-dimensions/jedi-benchmarking-integration}

This stage requires Stage 1's foundation and benefits from Stage 2's proven parsing and mapping approaches. Recommended sub-phasing: 3A (JEDI only \- 7 PDFs), 3B (+ VA/Sixth Sense \- 25 PDFs), 3C (+ Vocational \- 12 PDFs) with decision gates to validate parsing accuracy and ROI before full investment.

### Business functionality and capabilities {#business-functionality-and-capabilities-2}

Stage 3 delivers comprehensive external benchmarking with three key capabilities. 

1. Value-added (VA) analysis normalizes for intake profiles, distinguishing teaching effectiveness from selective admissions.   
2. JEDI equity analysis surfaces performance disparities across gender, ethnicity, and disadvantage, including intersectional views.   
3. Percentile rankings show national positioning. This completes the platform's analytical capability for continuous improvement and equity monitoring.

### Data sources, modeling and integration {#data-sources,-modeling-and-integration-2}

- **Data source:** 44 CSV files (7 JEDI, 9 VA, 16 Sixth Sense, 12 Vocational) at three incompatible grains  
- **Fact tables:** Three parallel fact tables required: six\_dimensions\_college\_performance\_fct (college x year), six\_dimensions\_subject\_performance\_fct (subject x year), and six\_dimensions\_subgroup\_performance\_fct (demographic x year)  
- **dbt project:** 50+ models including 44 staging models as schema adapters, 3 intermediate unification models, and 3 warehouse facts  
- **Looker platform:** 3 explores and 3 dashboards (Value-Added Analysis, Gender Gap Analysis, Comprehensive Benchmarking)

### 

### Challenges {#challenges-2}

1. **Amplified PDF parsing complexity** \- 44 reports require parsing instead of 2, with schema inconsistencies across report types (JEDI, VA, Sixth Sense, Vocational) demanding different parsing strategies using Google's Document AI OCR or Cloud Vision AI  
2. **Vocational report complexity** \- Document AI OCR may suffice for standardized JEDI/VA reports but struggle with Vocational reports containing 5 distinct datasets per PDF requiring dataset boundary detection, where Cloud Vision AI's flexible layout analysis becomes necessary  
3. **Client review bottleneck** \- Validating 44 parsed CSVs for subject names, demographic categories, VA scores, and percentile rankings requires significant time investment, with parsing errors potentially requiring multiple correction-reprocessing cycles  
4. **Manual intervention multiplication** \- Manual interventions multiply across reports, particularly for vocational files where dataset splitting may need manual preprocessing  
5. **Subject mapping expansion** \- Subject mapping reuses ALPS logic but requires additional hours for new vocational qualifications not covered in Stage 2  
6. **Multi-dataset parsing failure risk** \- 27% of reports (vocational files) may be inaccessible if multi-dataset parsing fails  
7. **Query performance** \- Complex joins between student-level internal data and subject-level external benchmarks may impact dashboard performance

# 

# Services Schedule {#services-schedule}

The project will be delivered by 1.25 FTE of Rittman Analytics’ consultants over the duration of the engagement.

SAC \= Senior Analytics Consultant  
PC \= Principal Consultant

## Stage 1 MVP: Core Student Attainment  {#stage-1-mvp:-core-student-attainment-1}

| Task ID | Description | SAC Hrs | PC Hrs |
| :---- | :---- | :---- | :---- |
| 1.1.1 | Dimension Table Design & DDL (7 tables) | 3 | 1 |
| 1.1.2 | Fact Table Design & DDL (enrolment\_fct with 40+ columns, grade flags, demographic counts) | 2 | 1 |
| 1.1.3 | Data Quality Design (integrity rules, grade flag consistency checks) | 1.5 | 1 |
| 1.2.1 | dbt Project Setup (initialize structure, configure BigQuery, create macros) | 1 |  |
| 1.2.2 | Source Definitions (7 ProSolution sources with freshness checks) | 1 |  |
| 1.2.3 | Staging Models \- Dimension Tables (7 models with conversions, filters, derived fields) | 3 |  |
| 1.2.4 | Warehouse \- Dimension Tables (7 final dimensions with surrogate keys and documentation) | 2 |  |
| 1.2.5 | Warehouse \- Fact Table (joins to 6 dimensions, 20+ grade flags, 10+ demographic flags) | 3 |  |
| 1.2.6 | dbt Tests & Documentation (unique/not\_null tests, referential integrity, schema.yml) | 3 |  |
| 1.3.1 | LookML Project Setup (initialize project, configure BigQuery connection, Git setup) | 1 |  |
| 1.3.2 | LookML Views \- Dimensions (7 views with measures, drill fields, formatting) | 3 |  |
| 1.3.3 | LookML View \- Fact Table (50+ measures with conditional formatting and drill paths) | 3 |  |
| 1.3.4 | LookML Explores (2 explores with dimension joins, access grants, always\_filter) | 2 | 1 |
| 1.3.5 | Dashboards \- Course Performance (8-10 visualizations with interactive filters) | 2 | 1 |
| 1.3.6 | Dashboards \- Equity & Diversity (8-10 visualizations for gap analysis) | 2 |  |
| 1.3.7 | LookML Semantic Layer (define metrics with business-friendly names) | 1 | 1 |
| 1.3.8 | Conversational Analytics Configuration (configure and fine-tune natural language query capabilities) | 2 | 2 |
| 1.4.1 | Integration Testing (end-to-end ETL validation, row counts, calculation spot-checks) | 2 |  |
| 1.4.2 | Performance Testing (query optimization, implement aggregate tables if needed) | 1 |  |
| 1.4.3 | User Acceptance Testing (stakeholder review, validate against manual reports) | 0.5 | 1 |
| 1.4.4 | Documentation & Training (data dictionary, user guides, runbook, training session) | 1 | 1 |
| TOTAL Hours |  | 40 | 10 |

## 

## Stage 2: ALPS Provider Benchmarking Integration  {#stage-2:-alps-provider-benchmarking-integration-1}

| Task ID | Description | SAC Hrs | PC Hrs |
| :---- | :---- | :---- | :---- |
| 2.0.1 | PDF Parsing Model Selection (evaluate Document AI OCR vs Cloud Vision AI, test sample PDFs for accuracy) | 2.5 | 2 |
| 2.0.2 | PDF to CSV Conversion (parse 2 ALPS reports using selected Google model, extract tables, handle multi-page layouts) | 2.0 | 2 |
| 2.0.3 | Client Review of Parsed Data (validate subject names, percentages, grade distributions; document corrections) | 1.5 | 1 |
| 2.0.4 | Manual Corrections & Reprocessing (fix parsing errors identified in client review) | 1.5 |  |
| 2.1.1 | ALPS Fact Table Design (subject-aggregate grain with 40+ columns for A-Level/BTEC grading scales) | 1.5 |  |
| 2.1.2 | ALPS Subject Mapping Dimension (manual seed table DDL with mapping confidence and overrides) | 1 |  |
| 2.1.3 | Initial Subject Mapping (client SME collaboration to populate mapping table and validate fuzzy matches) | 2.5 |  |
| 2.2.1 | ALPS Source Definitions (CSV sources for 2 ALPS reports) | 0.5 |  |
| 2.2.2 | Staging Models \- ALPS Data (2 models with percentage parsing, qualification type detection, SAFE\_CAST) | 2.5 |  |
| 2.2.3 | Integration Model \- Subject Mapping (fuzzy matching logic with normalization, similarity scoring, manual lookups) | 2.5 |  |
| 2.2.4 | Warehouse \- ALPS Fact Table (A-Level/BTEC union, subject mapping application, dimension joins) | 1.5 |  |
| 2.2.5 | dbt Tests \- ALPS Models (tests for subject not null, valid percentages, grade sum validation, mapping status) | 1 |  |
| 2.3.1 | LookML View \- ALPS Fact (measures for grade distributions, pass rates, completion rate) | 1.5 |  |
| 2.3.2 | LookML Explore \- ALPS Benchmarking (explore with joins to academic\_year\_dim and offering\_dim) | 1 | 1 |
| 2.3.3 | Dashboard \- ALPS Subject Benchmarking (6-8 visualizations with unmapped subject alerts) | 2 | 1 |
| 2.3.4 | Conversational Analytics Extension (extend natural language query capabilities to ALPS benchmarking data) | 3 | 0.5 |
| 2.4.1 | Subject Mapping Validation (review success rates, validate with SME, document unmapped subjects) | 1 |  |
| 2.4.2 | Data Quality Validation (spot-check ALPS metrics against source PDFs, validate grade distributions) | 1 |  |
| TOTAL |  | 30 | 7.5 |

## 

## 

## Stage 3: Six Dimensions/JEDI Benchmarking Integration  {#stage-3:-six-dimensions/jedi-benchmarking-integration-1}

| Task ID | Description | SAC Hrs | PC Hrs |
| :---- | :---- | :---- | :---- |
| 3.0.1 | PDF Parsing Strategy Refinement (apply Stage 2 learnings, determine Document AI OCR vs Cloud Vision AI per report type) | 2 | 2 |
| 3.0.2 | PDF to CSV Conversion \- JEDI Reports (parse 7 reports using Google models, handle standardized layouts) | 2 | 2 |
| 3.0.3 | PDF to CSV Conversion \- VA Reports (parse 9 reports, extract multi-table structures) | 2 | 2 |
| 3.0.4 | PDF to CSV Conversion \- Sixth Sense Reports (parse 16 reports, similar to VA with high grades metrics) | 2 | 2 |
| 3.0.5 | PDF to CSV Conversion \- Vocational Reports (parse 12 reports with 5 datasets each, dataset boundary detection) | 2 |  |
| 3.0.6 | Client Review of Parsed Data (validate 44 CSVs for subject names, demographics, VA scores, percentiles) | 2 |  |
| 3.0.7 | Manual Corrections & Reprocessing (fix parsing errors across all report types, iterate on problematic files) | 2 | 2 |
| 3.1.1 | Six Dimensions Fact Tables Design (3 fact tables at different grains with 40-60 columns each) | 2.5 |  |
| 3.1.2 | Six Dimensions Dimension Tables (3 tables: report metadata, demographic categories, subject mapping) | 1.5 |  |
| 3.2.1 | Six Dimensions Source Definitions (CSV sources for 44 reports) | 1 |  |
| 3.2.2 | Staging Models \- JEDI Reports (7 models with schema normalization) | 2 |  |
| 3.2.3 | Staging Models \- VA Reports (9 models with schema normalization) | 2 |  |
| 3.2.4 | Staging Models \- Sixth Sense Reports (16 models similar to VA with High Grades metrics) | 2 |  |
| 3.2.5 | Staging Models \- Vocational Reports (12 models: Option A pre-split CSVs or Option B multi-dataset parsing) | 2 |  |
| 3.2.6 | Integration Model \- Subject Mapping (reuse ALPS approach with fuzzy matching for Six Dimensions subjects) | 1 |  |
| 3.2.7 | Initial Subject Mapping (client SME collaboration, assumes 50% overlap with ALPS) | 2 |  |
| 3.2.8 | Integration Models \- Data Unification (3 models to union report types into common schemas) | 2 |  |
| 3.2.9 | Warehouse \- Six Dimensions Fact Tables (3 final fact tables with dimension joins and derived metrics) | 2 |  |
| 3.2.10 | dbt Tests \- Six Dimensions Models (comprehensive tests for 50+ models) | 2 |  |
| 3.3.1 | LookML Views \- Six Dimensions Facts (3 views with VA scores, demographic metrics, gender gaps, percentiles) | 2 |  |
| 3.3.2 | LookML Explores \- Six Dimensions (3 explores with appropriate dimension joins) | 1 |  |
| 3.3.3 | Dashboard \- Value Added Analysis (8-10 visualizations for VA scores, trends, high/low performers) | 2 |  |
| 3.3.4 | Dashboard \- Gender Gap Analysis (8-10 visualizations for equity metrics, intersectional analysis) | 2 |  |
| 3.3.5 | Dashboard \- Comprehensive Benchmarking (8-10 visualizations integrating all data sources) | 2 |  |
| 3.3.6 | Conversational Analytics Enhancement (extend natural language query capabilities to comprehensive benchmarking) | 2 | 2 |
| 3.4.1 | Subject Mapping Validation (review success rates, validate with SME, document unmapped subjects) | 1 |  |
| 3.4.2 | Data Quality Validation (spot-check VA scores, gender gaps, percentile rankings against source PDFs) | 1 |  |
| 3.4.3 | Multi-Dataset Parsing Validation (if Option B used, validate all 5 datasets extracted correctly per vocational file) | 1 | 0.5 |
| TOTAL |  | 50 | 12.5 |

# Deliverable Review and Sign-Off Process

## Review Process for Each Stage

### 1\. Demo Session (1-2 hours)

**Rittman Analytics demonstrates:**

- ☐ All functionality from the SOW  
- ☐ Key capabilities using real Barton Peveril data  
- ☐ Natural language queries  
- ☐ Data quality results

### 2\. Client Review (3 business days)

**Stage 1 Checklist:**

- ☐ ProSolution data loads correctly  
- ☐ Dashboards work (Course Performance & Equity/Diversity)  
- ☐ Natural language queries return expected results  
- ☐ Role-based access controls function properly

**Stage 2 Checklist:**

- ☐ Parsed ALPS CSV data matches source PDFs  
- ☐ Subject mapping is accurate  
- ☐ ALPS benchmarking dashboard works  
- ☐ Grade distributions are correct

**Stage 3 Checklist:**

- ☐ All 44 parsed CSVs validated  
- ☐ Three dashboards work (Value-Added, Gender Gap, Comprehensive)  
- ☐ Subject mapping complete  
- ☐ Natural language queries work across all data

### 3\. Issue Resolution

- ☐ Client documents issues in shared tracker  
- ☐ Categorize as: **Critical** (blocks sign-off), **Major** (must fix), or **Minor** (nice to have)  
- ☐ Rittman Analytics resolves Critical and Major issues before sign-off

### 4\. Written Sign-Off

**Acceptance Email Template:**

**To: mark.rittman@rittmananalytics.com**

**Subject: Stage \[X\] Acceptance \- Barton Peveril Analytics Platform**

**I confirm Stage \[X\] deliverables are complete and accepted:**

**\- \[Key deliverable 1\]**

**\- \[Key deliverable 2\]**

**\- \[Key deliverable 3\]**

**Outstanding minor issues: \[None / List if applicable\]**

**Approved to proceed to Stage \[X+1\].**

**Chris Loveday**

**Vice Principal (Business Services)**

**Date: \[Date\]**

## Stage Gate Rule

**Do not start the next stage until:**

- Written email acceptance received from Chris Loveday  
- All Critical and Major issues resolved  
- Especially for Stage 1 (foundation for everything else)

## Key Client Time Commitments

- **Stage 2**: 1.5 hours reviewing ALPS CSVs \+ 2.5 hours subject mapping  
- **Stage 3**: 5 hours reviewing 44 CSVs \+ 3 hours subject mapping

# Responsibility Assignment Matrix

| Activity | Rittman Analytics | Barton Peveril College |
| :---- | :---- | :---- |
| **Project Management** |  |  |
| Single point of contact | Mark Rittman (CEO) | Chris Loveday (Vice Principal) |
| Weekly status updates | Colin Berry (Lead) | Attend meetings |
| Timeline management | Own and track | Approve milestones |
| Deliverable sign-off | Request approval | Provide written sign-off |
| **Infrastructure & Access** |  |  |
| Google Cloud Platform setup | Configure services | Grant permissions |
| ProSolution database access | Configure connection | Provide credentials |
| PDF report uploads | \- | Upload 46 PDFs to GCP |
| GDPR compliance | Follow protocols | Ensure compliance |
| **Stage 1: Core Student Attainment (40 hours)** |  |  |
| Dimensional model design | Design & build all tables | \- |
| dbt development | Build 20+ models | \- |
| Looker dashboards | Build 2 dashboards | \- |
| Business rules validation | \- | Validate logic (1.5 hrs) |
| User acceptance testing | Support testing | Test dashboards (1.5 hrs) |
| Natural language queries | Configure & test | Validate results (0.5 hrs) |
| **Stage 2: ALPS Benchmarking (30 hours)** |  |  |
| PDF parsing model selection | Evaluate & select | \- |
| PDF to CSV conversion | Parse 2 reports | Review CSV accuracy (1.5 hrs) |
| Subject mapping logic | Build fuzzy matching | Collaborate on mapping (2.5 hrs) |
| ALPS dashboard | Build dashboard | Test & validate (2 hrs) |
| Parsing error corrections | Fix and reprocess | Document errors (1.5 hrs) |
| **Stage 3: Six Dimensions Integration (50 hours)** |  |  |
| PDF parsing (44 reports) | Parse all reports | Review 44 CSVs (5 hrs) |
| Multi-dataset extraction | Handle vocational reports | Validate datasets (1 hr) |
| Subject mapping expansion | Extend mapping logic | Collaborate on mapping (3 hrs) |
| Three dashboards | Build all dashboards | Test & validate (2 hrs) |
| Comprehensive NLQ | Enhance capabilities | Validate queries (1 hr) |
| **Documentation & Training** |  |  |
| Data dictionary | Create and maintain | Review |
| User guides | Write guides | Provide feedback |
| Training session | Deliver training | Attend (all users) |
| Runbook | Document procedures | \- |
| **Quality Assurance** |  |  |
| Data quality tests | Build 50+ tests | \- |
| Calculation validation | Validate against specs | Provide manual reports |
| Performance testing | Optimize queries | \- |
| Issue resolution | Fix all Critical/Major | Document issues |

# 

# Commercials {#commercials}

Pricing is fixed-price and the total contract amount is $32,220 including local taxes.

| Stage | Description | Hours | Net Cost | VAT | Gross Cost |
| :---- | :---- | :---- | :---- | :---- | :---- |
| Stage 1 | Core Student Attainment | 50 (40 SAC \+ 10 PC) | US$ 8950 | US$ 1790 | US$ 10740  |
| Stage 2 | ALPS Provider Benchmarking Integration | 37.5 (30 SAC \+ 7.5 PC) | US$ 6700 | US$ 1340 | US$ 8040  |
| Stage 3 | Six Dimensions/JEDI Benchmarking Integration | 62.5 (50 SAC \+ 12.5 PC) | US$ 11200 | US$ 2240 | US$ 13440 |
| Partner Assessment Services Cost |  | 150 (120 SAC \+ 30 PC) | US$ 26850 | US$ 5370 | US$ 32220 |
| LESS Google Deal Acceleration Funds Investment  |  |  | US$ 26850 | US$ 5370 | US$ 32220 |
| Total Services Cost |  |  | US $0 | US$ 0 | US$ 0 |

**Google Partner Funds Investment**.  Barton Peveril College acknowledges and agrees that the Google Partner Funds Investment is subject to formal PSF approval by Google Cloud.  If Barton Peveril College terminates this SOW or does not permit Partner to meet the Success Criteria for any reason, then Barton Peveril College will be obligated to pay Partner the sum of the amount shown in the Services Cost.  

**Estimated Project Expenses**.  Expenses, if any, would be billed as incurred with prior approval from Client and adhere to Client policies. No travel, or travel-related expenses, shall apply to services under this SOW.

Fair Market Value Calculations:

| Grade | Hourly Rate US$ | GBP Equiv. | Hours | Total |
| :---- | ----- | ----- | ----- | ----- |
| PC | $223.75 | £169.92 | 30 | $6,712.50 |
| SAC | $167.81 | £127.44 | 120 | $20,137.20 |
|  |  |  |  | $26,849.70 |

# Timeline {#timeline}

| Stage | Description | Start Date | End Date |
| :---- | :---- | :---- | :---- |
| Stage 1 | Core Student Attainment | 1st December 2025 | 5th December 2025 |
| Stage 2 | ALPS Provider Benchmarking Integration | 8th December 2025 | 12th December 2025 |
| Stage 3 | Six Dimensions/JEDI Benchmarking Integration | 15th December  2025 | 19th December 2025 |

*Timeline assumes single resource delivering 8 hours/day, Monday-Friday only*

**Project Duration:** 3  weeks (1st December 2025 \- 19th December 2025\)

# 

# Principal Contacts {#principal-contacts}

|  | Authorised Customer | Rittman Analytics |
| :---- | :---- | :---- |
| **Name:** | Chris Loveday | Mark Rittman |
| **Title:** | Vice Principal (Business Services) | CEO |
| **Email:** | crl@barton.ac.uk | mark.rittman@rittmananalytics.com |
| **Tel:** |  | 07866 568246 |

Signed for and on behalf of:

the **Customer**

Signed:	 \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Name:	 \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Title:	 \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Date: 	\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Signed for and on behalf of: 

**Rittman Analytics**

Signed:	 \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Name:	 \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Title:	 \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Date: 	\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_
