# Barton Peveril Analytics Platform - Dashboard Specification

## Document Purpose

This specification defines the dashboard requirements for the Barton Peveril Sixth Form College student analytics platform. The dashboards should be built using Loveable.dev with the Looker look-and-feel template applied automatically. This document focuses on functional requirements, data sources, and user interactions only.

---

## Platform Overview

### Target Users

| User Group | Access Level | Primary Use Case |
|------------|--------------|------------------|
| Senior Leadership Team (SLT) | Full access to all data | Strategic oversight, board reporting, target setting |
| Vice Principal | Full access | Performance monitoring, intervention decisions |
| Heads of Faculty | Faculty-filtered data | Subject area management, staff development |
| Subject Leaders | Subject-filtered data | Course-level analysis, teaching improvement |
| Teachers | Own subject data | Individual class performance insights |
| MIS Team | Full access + admin | Data validation, report generation |

### Role-Based Data Access Requirements

- All dashboards must enforce role-based access controls
- Teachers should only see subjects they teach
- Subject Leaders should see all subjects in their department
- Heads of Faculty should see all subjects in their faculty
- SLT and MIS should see all data
- Default filters must prevent accidental queries across all historical data
- Academic year filter should default to current year (24/25)

---

## Data Sources

All dashboards source data exclusively from the dimensional data warehouse marts layer:

### Fact Tables

| Table Name | Grain | Description |
|------------|-------|-------------|
| `fct_enrolment` | Student-Offering | Primary fact for internal student performance analysis |
| `fct_alps_subject_performance` | Subject-Year | ALPS subject-level external benchmarking |
| `fct_college_performance` | College-Year | Six Dimensions college-level metrics |
| `fct_subject_benchmark` | Subject-Year | Six Dimensions subject-level benchmarking |
| `fct_equity_gap` | Demographic-Year | JEDI equity gap analysis |

### Dimension Tables

| Table Name | Description |
|------------|-------------|
| `dim_academic_year` | Academic year reference (19/20 through 24/25) |
| `dim_offering_type` | Qualification types (A-Level, BTEC, AS-Level) |
| `dim_course_header` | Course master data (subject, department, faculty) |
| `dim_offering` | Course offerings by academic year |
| `dim_student` | Student master data (SCD Type 2) |
| `dim_student_detail` | Student detail by academic year |
| `dim_prior_attainment` | Prior attainment bands and GCSE scores |
| `dim_grade` | Grade reference with points mappings |

---

## Dashboard 1: Course Performance

### Purpose
Enable analysis of internal student performance at course level, supporting trend analysis and target comparison.

### Primary Data Source
`fct_enrolment` joined to all dimensions

### Required Filters

| Filter | Type | Default | Required |
|--------|------|---------|----------|
| Academic Year | Multi-select dropdown | Current year (24/25) | Yes |
| Qualification Type | Multi-select dropdown | All | No |
| Faculty | Multi-select dropdown | All | No |
| Department | Multi-select dropdown | All | No |
| Subject | Multi-select dropdown | All | No |
| Prior Attainment Band | Multi-select dropdown | All | No |
| Completion Status | Multi-select dropdown | Completed only | No |

### Visualizations

#### 1.1 Headline KPIs (Single Value Tiles)
Display as a row of 6 KPI tiles at the top of the dashboard:

| KPI | Measure | Comparison |
|-----|---------|------------|
| Total Enrolments | COUNT of enrolments | vs. Prior Year |
| Pass Rate | % of enrolments with is_pass = true | vs. Prior Year |
| High Grades (A*-B / D*-M) | % of enrolments with is_high_grade = true | vs. Prior Year |
| Average Grade Points | AVG of grade_points | vs. Prior Year |
| Completion Rate | % where is_completed = true | vs. Prior Year |
| Average GCSE on Entry | AVG of average_gcse_score | vs. Prior Year |

#### 1.2 Headline Outcomes Trend (Line Chart)
- X-axis: Academic Year (6 years)
- Y-axis: Percentage / Points (dual axis)
- Lines: Pass Rate %, High Grades %, Average Grade Points
- Interaction: Click to drill to subject-level detail
- Answers: "How did headline outcomes trend over the last 6 years?"

#### 1.3 Subject Performance Table
- Sortable table with the following columns:
  - Subject Name
  - Qualification Type
  - Cohort Size
  - A* Count, A Count, B Count, C Count, D Count, E Count, U Count
  - A*-A %, A*-B %, A*-C %, A*-E %
  - Pass Rate %
  - Average Grade Points
  - vs. Prior Year (indicator)
- Conditional formatting: Highlight subjects below target
- Interaction: Click row to filter other visualizations

#### 1.4 Grade Distribution by Subject (Stacked Bar Chart)
- X-axis: Subject Name
- Y-axis: Count of enrolments
- Stacking: Grade (A* through U for A-Level, D* through P for BTEC)
- Answers: "How have grade profiles shifted by subject?"

#### 1.5 Prior Attainment Analysis (Grouped Bar Chart)
- X-axis: Prior Attainment Band (Low, Mid, High, N/A)
- Y-axis: Pass Rate % and High Grades %
- Grouping: By Academic Year
- Answers: "Are outcomes improving across all prior attainment bands?"

#### 1.6 Subject Performance vs. Prior Year (Scatter Plot)
- X-axis: Prior Year Pass Rate %
- Y-axis: Current Year Pass Rate %
- Point size: Cohort Size
- Point label: Subject Name
- Reference line: Diagonal (y=x) showing improvement line
- Interaction: Click point to see subject detail

#### 1.7 Year-over-Year Subject Trajectory (Table with Sparklines)
- Columns:
  - Subject Name
  - Cohort Size
  - Pass Rate % (with 6-year sparkline)
  - High Grades % (with 6-year sparkline)
  - Trajectory (Improving / Stable / Declining indicator)
  - 6-Year Variance (standard deviation)
- Answers: "Which subjects are consistently over- or under-performing?"

### Drill-Down Capability
- Subject-level drill to see student-level detail
- Year-over-year comparison for selected subject
- Grade distribution breakdown

---

## Dashboard 2: Equity and Diversity

### Purpose
Identify and monitor attainment gaps across demographic groups to support intervention planning and equity goals.

### Primary Data Sources
- `fct_enrolment` for internal demographic analysis
- `fct_equity_gap` for JEDI benchmark data

### Required Filters

| Filter | Type | Default | Required |
|--------|------|---------|----------|
| Academic Year | Multi-select dropdown | Current year | Yes |
| Qualification Type | Multi-select dropdown | All | No |
| Subject | Multi-select dropdown | All | No |
| Demographic Category | Single-select dropdown | All | No |

### Visualizations

#### 2.1 Gap Summary KPIs (Single Value Tiles)
Display as a row of tiles:

| KPI | Measure | Description |
|-----|---------|-------------|
| Gender Gap | Female Pass Rate - Male Pass Rate | With trend arrow |
| Disadvantage Gap | Non-PP Pass Rate - PP Pass Rate | With trend arrow |
| SEND Gap | Non-SEND Pass Rate - SEND Pass Rate | With trend arrow |
| Ethnicity Gap (Max) | Highest - Lowest ethnic group pass rate | With trend arrow |

#### 2.2 Attainment Gap by Demographic (Horizontal Bar Chart)
- Y-axis: Demographic Category (Gender, Disadvantage, SEND, Ethnicity)
- X-axis: Gap in Percentage Points (negative = disadvantaged group underperforming)
- Bar color: Indicate gap direction and magnitude
- Answers: "Where are the attainment gaps?"

#### 2.3 Gap Trend Over Time (Line Chart)
- X-axis: Academic Year (6 years)
- Y-axis: Gap in Percentage Points
- Lines: One per demographic category
- Reference line: Zero line (no gap)
- Answers: "Are gaps narrowing over time?"

#### 2.4 Demographic Breakdown Table
- Rows: Demographic groups (Male/Female, PP/Non-PP, SEND/Non-SEND, Ethnicity groups)
- Columns:
  - Cohort Size
  - % of Total Cohort
  - Pass Rate %
  - High Grades %
  - Average Grade Points
  - Gap vs. Overall
  - Gap Trend (Narrowing / Stable / Widening)
  - vs. National (from JEDI data)
- Conditional formatting: Highlight significant gaps (>5 percentage points)

#### 2.5 Gender Analysis Detail (Grouped Bar Chart)
- X-axis: Subject Name
- Y-axis: Pass Rate %
- Grouping: Male / Female
- Sorted by: Gender gap magnitude
- Answers: "Which subjects have the largest gender gaps?"

#### 2.6 Disadvantage Analysis by Prior Attainment (Heat Map)
- Rows: Prior Attainment Band (Low, Mid, High)
- Columns: PP Status (PP / Non-PP)
- Cells: Pass Rate % with color gradient
- Answers: "Do disadvantage gaps persist across ability levels?"

#### 2.7 Intersectional Analysis (Table)
- Show combinations of demographic factors
- Example: Female + PP, Male + SEND, etc.
- Columns: Cohort Size, Pass Rate, vs. Overall, Intervention Priority
- Answers: "Are there compounding disadvantages?"

#### 2.8 JEDI National Comparison (Table with Indicators)
- Columns:
  - Demographic Category
  - Demographic Value
  - College Pass Rate %
  - National Pass Rate %
  - vs. National (percentage points)
  - Performance Band (Above/At/Below)
- Source: `fct_equity_gap`

### Drill-Down Capability
- Demographic group drill to student list
- Subject-specific gap analysis
- Year-over-year gap comparison

---

## Dashboard 3: ALPS Subject Benchmarking

### Purpose
Compare subject performance against ALPS national benchmarks to identify subjects significantly above or below national standards.

### Primary Data Source
`fct_alps_subject_performance`

### Required Filters

| Filter | Type | Default | Required |
|--------|------|---------|----------|
| Academic Year | Multi-select dropdown | Current year | Yes |
| Qualification Type | Single-select dropdown | A-Level | No |
| Subject | Multi-select dropdown | All | No |
| ALPS Band | Multi-select dropdown | All | No |

### Visualizations

#### 3.1 ALPS Overview KPIs (Single Value Tiles)

| KPI | Measure | Description |
|-----|---------|-------------|
| College ALPS Score | Weighted average across subjects | With band indicator |
| Subjects in Band 1-2 | Count with ALPS band 1 or 2 | Target: increasing |
| Subjects in Band 3-4 | Count with ALPS band 3 or 4 | Neutral |
| Subjects in Band 5+ | Count with ALPS band 5+ | Target: decreasing |
| Unmapped Subjects | Count where subject_mapping_status = 'Unmapped' | Alert indicator |

#### 3.2 ALPS Band Distribution (Horizontal Bar Chart)
- Y-axis: ALPS Band (1 through 9)
- X-axis: Count of subjects
- Band descriptions: 1 = Exceptional, 2 = Very Strong, etc.
- Answers: "What is our overall ALPS profile?"

#### 3.3 Subject ALPS Performance Table
- Sortable table:
  - Subject Name
  - Qualification Type
  - Cohort Size
  - ALPS Band
  - ALPS Score
  - Pass Rate %
  - High Grades %
  - A*-A %
  - vs. National Pass Rate
  - Mapping Status
- Conditional formatting: Color by ALPS band
- Answers: "Is 85% A*-B strong or weak?"

#### 3.4 ALPS Score vs. Cohort Size (Bubble Chart)
- X-axis: Cohort Size
- Y-axis: ALPS Score (inverted - lower is better)
- Bubble size: High Grade %
- Bubble label: Subject Name
- Quadrant analysis: Identify large cohorts with poor ALPS scores
- Answers: "Which subjects significantly outperform or underperform?"

#### 3.5 Subject Benchmark Comparison (Dot Plot)
- Y-axis: Subject Name (sorted by ALPS score)
- X-axis: Performance vs. National (percentage points)
- Dots: College performance vs. national benchmark
- Reference line: National average (zero)
- Answers: "Are Biology students above or below national standards?"

#### 3.6 ALPS Trend by Subject (Line Chart with Small Multiples)
- Small multiple grid: One chart per subject
- X-axis: Academic Year
- Y-axis: ALPS Score
- Reference band: Target ALPS band
- Answers: "How has each subject's ALPS score changed over time?"

#### 3.7 Grade Distribution vs. National (Grouped Bar Chart)
- X-axis: Grade (A* through U)
- Y-axis: Percentage of cohort
- Grouping: College vs. National
- Subject filter: Single subject selected
- Answers: "Where does our grade distribution differ from national?"

### Drill-Down Capability
- Subject drill to detailed grade breakdown
- Comparison with prior years
- Link to internal enrolment data (where mapped)

### Alert Panel
- Unmapped subjects requiring manual mapping
- Subjects with ALPS band deterioration (>1 band decline)
- Subjects approaching band threshold

---

## Dashboard 4: Value-Added Analysis

### Purpose
Analyze value-added performance to distinguish teaching effectiveness from intake quality.

### Primary Data Source
`fct_subject_benchmark` (VA reports) and `fct_college_performance`

### Required Filters

| Filter | Type | Default | Required |
|--------|------|---------|----------|
| Academic Year | Multi-select dropdown | Current year | Yes |
| Report Type | Single-select dropdown | VA | No |
| Qualification Type | Multi-select dropdown | All | No |
| Subject | Multi-select dropdown | All | No |

### Visualizations

#### 4.1 VA Overview KPIs (Single Value Tiles)

| KPI | Measure | Description |
|-----|---------|-------------|
| College VA Score | Average value-added score | With confidence interval |
| VA Percentile | National percentile rank | vs. Prior Year |
| VA Band | Overall VA performance band | A-E scale |
| Subjects Above Expected | Count where VA > 0 | Target indicator |

#### 4.2 Value-Added by Subject (Horizontal Bar Chart)
- Y-axis: Subject Name (sorted by VA score)
- X-axis: VA Score (centered at zero)
- Color: Positive (above expected) vs. Negative (below expected)
- Error bars: VA confidence interval
- Answers: "Which subjects add the most value?"

#### 4.3 VA Score vs. Average GCSE on Entry (Scatter Plot)
- X-axis: Average GCSE Score on Entry
- Y-axis: VA Score
- Points: Subjects
- Reference line: Expected VA (zero)
- Quadrants:
  - Top-right: High intake, positive VA (excellent)
  - Top-left: Low intake, positive VA (high value-add)
  - Bottom-right: High intake, negative VA (underperforming)
  - Bottom-left: Low intake, negative VA (concern)
- Answers: "Is our VA driven by intake quality or teaching?"

#### 4.4 VA Trend Over Time (Line Chart)
- X-axis: Academic Year (6 years)
- Y-axis: VA Score
- Lines: Overall and by qualification type
- Confidence band: Shaded area for confidence interval
- Answers: "Is our value-added improving?"

#### 4.5 Subject VA Performance Table
- Columns:
  - Subject Name
  - Qualification Type
  - Cohort Size
  - Average GCSE Entry
  - Expected Grade
  - Actual Average Grade
  - VA Score
  - VA Band
  - VA Percentile
  - vs. National VA
  - Confidence Interval
- Sorted by: VA Score descending

#### 4.6 VA Residual Analysis (Box Plot)
- Y-axis: Subject Name
- X-axis: VA Residual Score
- Box: Interquartile range
- Whiskers: Full range
- Points: Outliers
- Reference line: Zero (expected)
- Answers: "How consistent is VA within subjects?"

#### 4.7 High VA / Low VA Subject Comparison (Side-by-Side Table)
- Two tables: Top 5 VA performers and Bottom 5 VA performers
- Columns: Subject, VA Score, Cohort, Change vs. Prior Year
- Action indicator: Subjects requiring intervention

### Drill-Down Capability
- Subject drill to year-over-year VA trend
- Link to ALPS data for external validation
- Student-level breakdown (where available)

---

## Dashboard 5: Gender Gap Analysis

### Purpose
Deep-dive into gender-based attainment gaps with intersectional analysis and subject-level detail.

### Primary Data Sources
- `fct_enrolment` for internal gender analysis
- `fct_equity_gap` for JEDI gender benchmark data

### Required Filters

| Filter | Type | Default | Required |
|--------|------|---------|----------|
| Academic Year | Multi-select dropdown | Current year | Yes |
| Qualification Type | Multi-select dropdown | All | No |
| Faculty | Multi-select dropdown | All | No |
| Subject | Multi-select dropdown | All | No |
| Prior Attainment Band | Multi-select dropdown | All | No |

### Visualizations

#### 5.1 Gender Gap KPIs (Single Value Tiles)

| KPI | Measure | Description |
|-----|---------|-------------|
| Female Pass Rate | % pass for female students | |
| Male Pass Rate | % pass for male students | |
| Gender Gap | Female - Male pass rate | With trend |
| Subjects with Gap >5pp | Count of subjects | Alert indicator |

#### 5.2 Gender Gap by Subject (Horizontal Bar Chart)
- Y-axis: Subject Name (sorted by gap magnitude)
- X-axis: Gender Gap (percentage points, centered at zero)
- Color: Female outperforming (positive) vs. Male outperforming (negative)
- Reference line: Zero (no gap)
- Answers: "Which subjects have the largest gender gaps?"

#### 5.3 Gender Gap Trend (Line Chart)
- X-axis: Academic Year (6 years)
- Y-axis: Gender Gap (percentage points)
- Lines: Overall and by qualification type
- Reference line: Zero (target)
- Answers: "Is the gender gap narrowing?"

#### 5.4 Gender Performance by Subject (Grouped Bar Chart)
- X-axis: Subject Name
- Y-axis: Pass Rate %
- Grouping: Female / Male
- Sorted by: Gender gap magnitude

#### 5.5 Gender Gap by Prior Attainment (Grouped Bar Chart)
- X-axis: Prior Attainment Band (Low, Mid, High)
- Y-axis: Gender Gap (percentage points)
- Grouping: By Academic Year
- Answers: "Does the gender gap vary by prior attainment?"

#### 5.6 Intersectional Gender Analysis (Heat Map)
- Rows: Gender (Female, Male)
- Columns: Other demographic (PP Status, Ethnicity)
- Cells: Pass Rate %
- Answers: "Are there compounding effects with gender?"

#### 5.7 Gender Distribution by Grade (Stacked Bar Chart)
- X-axis: Grade (A* through U)
- Y-axis: Percentage
- Stacking: Female / Male
- Filter: Single subject selected
- Answers: "How do grade distributions differ by gender?"

#### 5.8 Gender Gap vs. National Benchmark (Dot Plot)
- Y-axis: Subject Name
- X-axis: Gap vs. National (percentage points)
- Dots: College gap vs. National average gap
- Reference line: National average gap
- Source: `fct_equity_gap`

### Drill-Down Capability
- Subject drill to student-level gender analysis
- Year-over-year gap comparison
- Link to intervention tracking

---

## Dashboard 6: Comprehensive Benchmarking

### Purpose
Unified view integrating all external benchmarks (ALPS, Six Dimensions, DfE) for strategic decision-making.

### Primary Data Sources
- `fct_alps_subject_performance`
- `fct_subject_benchmark`
- `fct_college_performance`
- `fct_equity_gap`

### Required Filters

| Filter | Type | Default | Required |
|--------|------|---------|----------|
| Academic Year | Multi-select dropdown | Current year | Yes |
| Qualification Type | Multi-select dropdown | All | No |
| Subject | Multi-select dropdown | All | No |

### Visualizations

#### 6.1 Strategic Overview KPIs (Single Value Tiles)

| KPI | Measure | Source |
|-----|---------|--------|
| College VA Percentile | National percentile | Six Dimensions VA |
| College ALPS Score | Weighted average | ALPS |
| Pass Rate vs. National | Percentage point difference | Six Dimensions |
| Largest Equity Gap | Max demographic gap | JEDI |

#### 6.2 External Benchmark Summary Table
- Rows: Benchmark source (ALPS, Six Dimensions VA, Six Dimensions Sixth Sense, JEDI)
- Columns:
  - Overall Score/Band
  - National Percentile
  - Year-over-Year Change
  - Status (Meeting Target / Approaching / Below)

#### 6.3 Subject League Table (Combined Benchmarks)
- Comprehensive subject ranking:
  - Subject Name
  - Internal Pass Rate %
  - Internal High Grades %
  - ALPS Band
  - ALPS Score
  - Six Dimensions VA Score
  - VA Band
  - Composite Rank (weighted average)
  - Stability Score (6-year variance)
  - Trajectory (Improving / Stable / Declining)
- Answers: "Which subjects are consistently over- or under-performing?"

#### 6.4 Benchmark Correlation Analysis (Scatter Plot Matrix)
- 2x2 matrix of scatter plots:
  - ALPS Score vs. Internal Pass Rate
  - VA Score vs. Internal Pass Rate
  - ALPS Score vs. VA Score
  - Cohort Size vs. ALPS Score
- Answers: "Do our internal metrics align with external benchmarks?"

#### 6.5 Percentile Rank Trend (Area Chart)
- X-axis: Academic Year (6 years)
- Y-axis: Percentile Rank (0-100)
- Areas: ALPS, Six Dimensions VA, Sixth Sense
- Answers: "Are we hitting internal targets and external benchmarks?"

#### 6.6 Subject Performance Quadrant Analysis (Scatter Plot)
- X-axis: Internal Performance (Pass Rate %)
- Y-axis: External Benchmark (ALPS Score)
- Quadrants:
  - High Internal + High External = Stars
  - High Internal + Low External = Over-grading concern
  - Low Internal + High External = Teaching vs. Assessment issue
  - Low Internal + Low External = Improvement needed
- Point labels: Subject names
- Point size: Cohort size

#### 6.7 Target Achievement Summary (Progress Bars)
- Visual progress indicators:
  - Pass Rate Target: [Progress bar showing % to target]
  - High Grades Target: [Progress bar]
  - ALPS Band Target: [Progress bar]
  - VA Score Target: [Progress bar]
  - Gender Gap Target: [Progress bar]

#### 6.8 Year-over-Year Component Analysis (Waterfall Chart)
- Start: Prior Year Overall Score
- Components: Contribution by subject
- End: Current Year Overall Score
- Answers: "Which component drives variance year-to-year?"

### Drill-Down Capability
- Subject drill to detailed benchmark comparison
- Time series for any selected metric
- Cross-link to other dashboards

### Alert Panel
- Benchmark data currency (last update date)
- Unmapped subjects across all external sources
- Subjects with conflicting benchmark signals
- Targets at risk

---

## Cross-Dashboard Features

### Natural Language Query Support

All dashboards must expose measures and dimensions with business-friendly names for natural language query support:

| Technical Term | Business Term |
|----------------|---------------|
| is_high_grade | High Grades (A*-B / D*-M) |
| is_pass | Pass (A*-E / D*-P) |
| is_disadvantaged | Disadvantaged (PP/FSM) |
| is_sen | SEND |
| average_gcse_score | Average GCSE on Entry |
| prior_attainment_band | Prior Attainment (Low/Mid/High) |
| alps_band | ALPS Band |
| va_score | Value-Added Score |
| gap_vs_overall_pct | Gap vs. Overall |

### Example Natural Language Queries to Support

1. "Show pass rate trend for Biology over the last 6 years"
2. "Which A-Level subjects have the largest gender gap?"
3. "Compare our Psychology ALPS score to national benchmark"
4. "What is the disadvantage gap for BTEC subjects?"
5. "Show subjects where value-added declined this year"
6. "Which subjects are underperforming their ALPS target?"
7. "Show high grade rates by prior attainment band"

### Data Refresh Schedule

| Data Source | Refresh Frequency | Typical Lag |
|-------------|-------------------|-------------|
| ProSolution (fct_enrolment) | Daily | 1 day |
| ALPS (fct_alps_subject_performance) | Annual (August) | Varies |
| Six Dimensions (fct_subject_benchmark, fct_college_performance) | Annual (August) | Varies |
| JEDI (fct_equity_gap) | Annual (August) | Varies |

### Data Quality Indicators

All dashboards should display data quality indicators:
- Last data refresh timestamp
- Row count / coverage indicator
- Data completeness warnings (e.g., "Prior attainment missing for 15% of cohort")
- Subject mapping status (for external benchmark dashboards)

---

## Appendix A: Measure Definitions

### Grade Flags (from fct_enrolment)

| Measure | Definition |
|---------|------------|
| Pass Rate % | SUM(is_pass) / COUNT(*) * 100 |
| High Grades % | SUM(is_high_grade) / COUNT(*) * 100 |
| A*-A % | SUM(is_grade_a_star_to_a) / COUNT(*) * 100 |
| A*-B % | SUM(is_grade_a_star_to_b) / COUNT(*) * 100 |
| A*-C % | SUM(is_grade_a_star_to_c) / COUNT(*) * 100 |
| A*-E % | SUM(is_grade_a_star_to_e) / COUNT(*) * 100 |
| Average Grade Points | AVG(grade_points) |

### Prior Attainment Bands

| Band | GCSE Score Range |
|------|------------------|
| Low | < 4.77 |
| Mid | 4.77 - 6.09 |
| High | > 6.09 |
| N/A | NULL or 0 |

### ALPS Bands

| Band | Description |
|------|-------------|
| 1 | Exceptional - Top 5% nationally |
| 2 | Very Strong - Top 25% nationally |
| 3 | Strong - Above average |
| 4 | Average |
| 5 | Below Average |
| 6-9 | Significantly below average |

### Value-Added Bands

| Band | VA Score Range | Description |
|------|----------------|-------------|
| A | > 0.5 | Well Above Expected |
| B | 0.25 - 0.5 | Above Expected |
| C | -0.25 - 0.25 | At Expected |
| D | -0.5 - -0.25 | Below Expected |
| E | < -0.5 | Well Below Expected |

---

## Appendix B: Data Model Entity Relationships

```
fct_enrolment
    |-- dim_academic_year (academic_year_key)
    |-- dim_offering_type (offering_type_key)
    |-- dim_course_header (course_header_key)
    |-- dim_offering (offering_key)
    |-- dim_student (student_key)
    |-- dim_student_detail (student_detail_key)
    |-- dim_prior_attainment (prior_attainment_key)
    |-- dim_grade (grade_key)

fct_alps_subject_performance
    |-- dim_academic_year (academic_year_key)
    |-- dim_offering (offering_key) [via subject mapping]

fct_subject_benchmark
    |-- dim_academic_year (academic_year_key)
    |-- dim_offering (offering_key) [via subject mapping]

fct_college_performance
    |-- dim_academic_year (academic_year_key)

fct_equity_gap
    |-- dim_academic_year (academic_year_key)
```

---

## Appendix C: Filter Interactions

### Global Filters (Apply to All Visualizations)
- Academic Year
- Qualification Type

### Dashboard-Specific Filters
- Each dashboard has additional filters as specified
- Filters should cascade appropriately (e.g., Faculty filter updates Department options)

### Cross-Filter Behavior
- Clicking a subject in one visualization should filter all other visualizations on the same dashboard
- Clear filter action should reset to default values (current year, all subjects)

---

## Document Version

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | December 2025 | Rittman Analytics | Initial specification |
