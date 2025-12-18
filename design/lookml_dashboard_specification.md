# LookML Dashboard Specification

## Barton Peveril Sixth Form College - Student Analytics Platform

This document specifies the LookML dashboards that can be created with the current data model and measures available in the semantic layer.

---

## Overview

| Dashboard | Status | Elements | Notes |
|-----------|--------|----------|-------|
| Course Performance | Fully Supported | 12 | All visualizations creatable |
| Equity & Diversity | Mostly Supported | 10 | Ethnicity gap KPI requires table calc |
| ALPS Subject Benchmarking | Mostly Supported | 11 | National grade distribution partial |
| Value-Added Analysis | Mostly Supported | 11 | VA percentile is approximate |
| Gender Gap Analysis | Fully Supported | 12 | All visualizations creatable |

---

## Dashboard 1: Course Performance

### Dashboard Settings

```yaml
dashboard: course_performance
title: "Course Performance"
layout: newspaper
preferred_viewer: dashboards-next
filters_location_top: true
```

### Filters

| Filter Name | Field | Type | Default | UI Config |
|-------------|-------|------|---------|-----------|
| Academic Year | dim_academic_year.academic_year_name | field_filter | Current Year | dropdown_menu, multiple |
| Qualification Type | dim_offering_type.offering_type_name | field_filter | All | dropdown_menu, multiple |
| Faculty | dim_course_header.department | field_filter | All | dropdown_menu, multiple |
| Prior Attainment | fct_enrolment.prior_attainment_band | field_filter | All | dropdown_menu, multiple |

### Elements

#### Row 1: Headline KPIs (6 tiles)

##### Element 1.1: Total Enrolments
```yaml
name: total_enrolments
title: "Total Enrolments"
type: single_value
explore: fct_enrolment
fields:
  - fct_enrolment.cohort_count
filters:
  dim_academic_year.is_current_year: "Yes"
comparison:
  type: value
  field: prior_year_college_performance.prior_total_cohort
  label: "vs prior year"
style:
  font_size: large
  comparison_style: percentage_change
row: 0
col: 0
width: 4
height: 3
```

##### Element 1.2: Pass Rate
```yaml
name: pass_rate
title: "Pass Rate"
type: single_value
explore: fct_enrolment
fields:
  - fct_enrolment.pass_rate_pct
filters:
  dim_academic_year.is_current_year: "Yes"
comparison:
  field: prior_year_college_performance.prior_college_pass_rate
value_format: "0.0\%"
row: 0
col: 4
width: 4
height: 3
```

##### Element 1.3: High Grades
```yaml
name: high_grades
title: "High Grades (A*-B / D*-M)"
type: single_value
explore: fct_enrolment
fields:
  - fct_enrolment.high_grade_pct
filters:
  dim_academic_year.is_current_year: "Yes"
comparison:
  field: prior_year_college_performance.prior_college_high_grade
value_format: "0.0\%"
row: 0
col: 8
width: 4
height: 3
```

##### Element 1.4: Average Grade Points
```yaml
name: avg_grade_points
title: "Average Grade Points"
type: single_value
explore: fct_enrolment
fields:
  - fct_enrolment.avg_grade_points
filters:
  dim_academic_year.is_current_year: "Yes"
comparison:
  field: prior_year_college_performance.prior_college_avg_grade_points
value_format: "0.0"
row: 0
col: 12
width: 4
height: 3
```

##### Element 1.5: Completion Rate
```yaml
name: completion_rate
title: "Completion Rate"
type: single_value
explore: fct_enrolment
fields:
  - fct_enrolment.completion_rate_pct
filters:
  dim_academic_year.is_current_year: "Yes"
comparison:
  field: prior_year_college_performance.prior_college_completion_rate
value_format: "0.0\%"
row: 0
col: 16
width: 4
height: 3
```

##### Element 1.6: Average GCSE on Entry
```yaml
name: avg_gcse_entry
title: "Average GCSE on Entry"
type: single_value
explore: fct_enrolment
fields:
  - fct_enrolment.avg_gcse_cohort
filters:
  dim_academic_year.is_current_year: "Yes"
comparison:
  field: prior_year_college_performance.prior_college_avg_gcse
value_format: "0.00"
row: 0
col: 20
width: 4
height: 3
```

#### Row 2: Headline Outcomes Trend

##### Element 2.1: Outcomes Trend Line Chart
```yaml
name: outcomes_trend
title: "How did headline outcomes trend over the last 6 years?"
type: looker_line
explore: fct_enrolment
fields:
  - dim_academic_year.academic_year_name
  - fct_enrolment.pass_rate_pct
  - fct_enrolment.high_grade_pct
  - fct_enrolment.avg_grade_points
sorts:
  - dim_academic_year.academic_year_name asc
series_colors:
  fct_enrolment.pass_rate_pct: "#4285F4"
  fct_enrolment.high_grade_pct: "#FBBC04"
  fct_enrolment.avg_grade_points: "#34A853"
y_axes:
  - label: "Percentage"
    orientation: left
    series:
      - fct_enrolment.pass_rate_pct
      - fct_enrolment.high_grade_pct
  - label: "Grade Points"
    orientation: right
    series:
      - fct_enrolment.avg_grade_points
legend_position: bottom
row: 3
col: 0
width: 24
height: 6
```

#### Row 3: Subject Performance Summary Table

##### Element 3.1: Subject Performance Table
```yaml
name: subject_performance_table
title: "Subject Performance Summary"
type: looker_grid
explore: fct_enrolment
fields:
  - dim_offering.offering_name
  - dim_offering_type.offering_type_name
  - fct_enrolment.cohort_count
  - fct_enrolment.grade_a_star_count
  - fct_enrolment.grade_a_count
  - fct_enrolment.grade_b_count
  - fct_enrolment.grade_c_count
  - fct_enrolment.pass_rate_pct
  - fct_enrolment.high_grade_pct
  - fct_enrolment.avg_grade_points
filters:
  dim_academic_year.is_current_year: "Yes"
sorts:
  - dim_offering.offering_name asc
conditional_formatting:
  - type: along_a_scale
    field: fct_enrolment.pass_rate_pct
    palette: red_to_green
row: 9
col: 0
width: 24
height: 8
```

#### Row 4: Charts Row

##### Element 4.1: Grade Distribution by Subject
```yaml
name: grade_distribution
title: "Grade Distribution by Subject"
type: looker_bar
explore: fct_enrolment
fields:
  - dim_offering.offering_name
  - fct_enrolment.grade_a_star_count
  - fct_enrolment.grade_a_count
  - fct_enrolment.grade_b_count
  - fct_enrolment.grade_c_count
  - fct_enrolment.grade_d_count
  - fct_enrolment.grade_e_count
  - fct_enrolment.grade_u_count
filters:
  dim_academic_year.is_current_year: "Yes"
stacking: normal
series_colors:
  fct_enrolment.grade_a_star_count: "#1a73e8"
  fct_enrolment.grade_a_count: "#4285f4"
  fct_enrolment.grade_b_count: "#669df6"
  fct_enrolment.grade_c_count: "#aecbfa"
  fct_enrolment.grade_d_count: "#fbbc04"
  fct_enrolment.grade_e_count: "#f9ab00"
  fct_enrolment.grade_u_count: "#ea4335"
row: 17
col: 0
width: 12
height: 7
```

##### Element 4.2: Outcomes by Prior Attainment Band
```yaml
name: outcomes_by_prior_attainment
title: "Outcomes by Prior Attainment Band"
type: looker_column
explore: fct_enrolment
fields:
  - fct_enrolment.prior_attainment_band
  - fct_enrolment.pass_rate_pct
  - fct_enrolment.high_grade_pct
filters:
  dim_academic_year.is_current_year: "Yes"
  fct_enrolment.prior_attainment_band: "-N/A"
series_colors:
  fct_enrolment.pass_rate_pct: "#34A853"
  fct_enrolment.high_grade_pct: "#4285F4"
row: 17
col: 12
width: 12
height: 7
```

#### Row 5: Subject Performance vs Prior Year

##### Element 5.1: Subject Performance Scatter Plot
```yaml
name: subject_vs_prior_year
title: "Subject Performance vs Prior Year (Bubble size = cohort)"
type: looker_scatter
explore: fct_enrolment_yoy
fields:
  - dim_offering.offering_name
  - prior_year_performance.prior_pass_rate_pct
  - fct_enrolment_yoy.pass_rate_pct
  - fct_enrolment_yoy.cohort_count
filters:
  dim_academic_year.is_current_year: "Yes"
x_axis:
  field: prior_year_performance.prior_pass_rate_pct
  label: "Prior Year Pass Rate %"
y_axis:
  field: fct_enrolment_yoy.pass_rate_pct
  label: "Current Year Pass Rate %"
size_by:
  field: fct_enrolment_yoy.cohort_count
reference_lines:
  - type: line
    value_format: ""
    label: "Improvement Line"
    line_value: "y=x"
row: 24
col: 0
width: 24
height: 8
```

---

## Dashboard 2: Equity & Diversity

### Dashboard Settings

```yaml
dashboard: equity_diversity
title: "Equity & Diversity"
layout: newspaper
preferred_viewer: dashboards-next
```

### Filters

| Filter Name | Field | Type | Default |
|-------------|-------|------|---------|
| Academic Year | dim_academic_year.academic_year_name | field_filter | Current Year |
| Qualification Type | dim_offering_type.offering_type_name | field_filter | All |
| Subject | dim_offering.offering_name | field_filter | All |

### Elements

#### Row 1: Attainment Gap Summary KPIs (4 tiles)

##### Element 1.1: Gender Gap
```yaml
name: gender_gap_kpi
title: "Gender Gap"
type: single_value
explore: fct_enrolment
fields:
  - fct_enrolment.gender_gap_pass_pp
filters:
  dim_academic_year.is_current_year: "Yes"
value_format: "+0.0;-0.0"
custom_suffix: "pp"
note_text: "Female - Male pass rate"
row: 0
col: 0
width: 6
height: 3
```

##### Element 1.2: Disadvantage Gap
```yaml
name: disadvantage_gap_kpi
title: "Disadvantage Gap"
type: single_value
explore: fct_enrolment
fields:
  - fct_enrolment.disadvantage_gap_pass_pp
filters:
  dim_academic_year.is_current_year: "Yes"
value_format: "+0.0;-0.0"
custom_suffix: "pp"
note_text: "Non-PP minus PP pass rate"
row: 0
col: 6
width: 6
height: 3
```

##### Element 1.3: Ethnicity Gap
```yaml
name: ethnicity_gap_kpi
title: "Ethnicity Gap"
type: single_value
explore: fct_enrolment
note: "Requires table calculation: MAX(pass_rate_pct) - MIN(pass_rate_pct) grouped by ethnicity"
fields:
  - fct_enrolment.ethnicity
  - fct_enrolment.pass_rate_pct
table_calculations:
  - label: "Ethnicity Gap"
    expression: "max(${fct_enrolment.pass_rate_pct}) - min(${fct_enrolment.pass_rate_pct})"
row: 0
col: 12
width: 6
height: 3
```

##### Element 1.4: SEND Gap
```yaml
name: send_gap_kpi
title: "SEND Gap"
type: single_value
explore: fct_enrolment
fields:
  - fct_enrolment.send_gap_pass_pp
filters:
  dim_academic_year.is_current_year: "Yes"
value_format: "+0.0;-0.0"
custom_suffix: "pp"
row: 0
col: 18
width: 6
height: 3
```

#### Row 2: Attainment Gap Visualization

##### Element 2.1: Where are the attainment gaps?
```yaml
name: attainment_gaps_bar
title: "Where are the attainment gaps?"
type: looker_bar
explore: fct_equity_gap
fields:
  - fct_equity_gap.dimension_name
  - fct_equity_gap.avg_gap_grade_points
filters:
  dim_academic_year.is_current_year: "Yes"
sorts:
  - fct_equity_gap.avg_gap_grade_points desc
series_colors:
  fct_equity_gap.avg_gap_grade_points: "#5F6368"
row: 3
col: 0
width: 24
height: 5
```

#### Row 3: Gap Trends and Summary

##### Element 3.1: Are gaps narrowing over time?
```yaml
name: gap_trend_line
title: "Are gaps narrowing over time?"
type: looker_line
explore: fct_equity_gap
fields:
  - dim_academic_year.academic_year_name
  - fct_equity_gap.dimension_name
  - fct_equity_gap.avg_gap_grade_points
pivots:
  - fct_equity_gap.dimension_name
sorts:
  - dim_academic_year.academic_year_name asc
reference_lines:
  - value: 0
    label: "No Gap"
row: 8
col: 0
width: 14
height: 6
```

##### Element 3.2: Gap Movement Summary
```yaml
name: gap_movement_summary
title: "Gap Movement Summary"
type: looker_single_record
explore: fct_equity_gap
fields:
  - fct_equity_gap.dimension_name
  - fct_equity_gap.gap_trend
  - fct_equity_gap.avg_gap_grade_points
filters:
  dim_academic_year.is_current_year: "Yes"
row: 8
col: 14
width: 10
height: 6
```

#### Row 4: Demographic Breakdown Detail

##### Element 4.1: Demographic Breakdown Table
```yaml
name: demographic_breakdown_table
title: "Demographic Breakdown Detail"
type: looker_grid
explore: fct_enrolment
fields:
  - fct_enrolment.gender
  - fct_enrolment.ethnicity
  - fct_enrolment.is_disadvantaged
  - fct_enrolment.cohort_count
  - fct_enrolment.pass_rate_pct
  - fct_enrolment.high_grade_pct
  - fct_enrolment.avg_grade_points
  - fct_enrolment.gap_vs_overall_pass_pp
filters:
  dim_academic_year.is_current_year: "Yes"
conditional_formatting:
  - type: along_a_scale
    field: fct_enrolment.gap_vs_overall_pass_pp
    palette: red_white_green
row: 14
col: 0
width: 24
height: 8
```

#### Row 5: Additional Analysis Charts

##### Element 5.1: Gender Analysis by Subject
```yaml
name: gender_by_subject
title: "Pass Rate by Gender & Subject"
type: looker_bar
explore: fct_enrolment
fields:
  - dim_offering.offering_name
  - fct_enrolment.gender
  - fct_enrolment.pass_rate_pct
pivots:
  - fct_enrolment.gender
filters:
  dim_academic_year.is_current_year: "Yes"
row: 22
col: 0
width: 12
height: 7
```

##### Element 5.2: Disadvantage by Prior Attainment Heat Map
```yaml
name: disadvantage_prior_attainment
title: "Disadvantage Analysis by Prior Attainment"
type: looker_grid
explore: fct_enrolment
fields:
  - fct_enrolment.prior_attainment_band
  - fct_enrolment.is_disadvantaged
  - fct_enrolment.pass_rate_pct
pivots:
  - fct_enrolment.is_disadvantaged
filters:
  dim_academic_year.is_current_year: "Yes"
  fct_enrolment.prior_attainment_band: "-N/A"
conditional_formatting:
  - type: along_a_scale
    field: fct_enrolment.pass_rate_pct
    palette: red_to_green
row: 22
col: 12
width: 12
height: 7
```

---

## Dashboard 3: ALPS Subject Benchmarking

### Dashboard Settings

```yaml
dashboard: alps_benchmarking
title: "ALPS Subject Benchmarking"
layout: newspaper
preferred_viewer: dashboards-next
```

### Filters

| Filter Name | Field | Type | Default |
|-------------|-------|------|---------|
| Academic Year | dim_academic_year.academic_year_name | field_filter | Current Year |
| Qualification Type | fct_alps_subject_performance.alps_qualification_type | field_filter | A-Level |
| ALPS Band | fct_alps_subject_performance.alps_band | field_filter | All |

### Elements

#### Row 1: ALPS Overview KPIs (5 tiles)

##### Element 1.1: College ALPS Score
```yaml
name: college_alps_score
title: "College ALPS Score"
type: single_value
explore: fct_alps_subject_performance
fields:
  - fct_alps_subject_performance.college_alps_band
filters:
  dim_academic_year.is_current_year: "Yes"
custom_prefix: "Band "
note_text: "Weighted average"
row: 0
col: 0
width: 5
height: 3
```

##### Element 1.2: Subjects Band 1-2
```yaml
name: subjects_band_1_2
title: "Subjects Band 1-2"
type: single_value
explore: fct_alps_subject_performance
fields:
  - fct_alps_subject_performance.count_band_1_2
filters:
  dim_academic_year.is_current_year: "Yes"
note_text: "Target: increasing"
color_application:
  custom_color: "#34A853"
row: 0
col: 5
width: 5
height: 3
```

##### Element 1.3: Subjects Band 3-4
```yaml
name: subjects_band_3_4
title: "Subjects Band 3-4"
type: single_value
explore: fct_alps_subject_performance
fields:
  - fct_alps_subject_performance.count_band_3_4
filters:
  dim_academic_year.is_current_year: "Yes"
note_text: "Neutral"
color_application:
  custom_color: "#4285F4"
row: 0
col: 10
width: 5
height: 3
```

##### Element 1.4: Subjects Band 5+
```yaml
name: subjects_band_5_plus
title: "Subjects Band 5+"
type: single_value
explore: fct_alps_subject_performance
fields:
  - fct_alps_subject_performance.count_band_5_plus
filters:
  dim_academic_year.is_current_year: "Yes"
note_text: "Target: decreasing"
color_application:
  custom_color: "#EA4335"
row: 0
col: 15
width: 5
height: 3
```

##### Element 1.5: Unmapped Subjects
```yaml
name: unmapped_subjects
title: "Unmapped Subjects"
type: single_value
explore: fct_alps_subject_performance
fields:
  - fct_alps_subject_performance.count_unmapped_subjects
filters:
  dim_academic_year.is_current_year: "Yes"
note_text: "Require mapping"
row: 0
col: 20
width: 4
height: 3
```

#### Row 2: ALPS Band Distribution

##### Element 2.1: ALPS Band Distribution Chart
```yaml
name: alps_band_distribution
title: "What is our overall ALPS profile?"
type: looker_bar
explore: fct_alps_subject_performance
fields:
  - fct_alps_subject_performance.alps_band
  - fct_alps_subject_performance.alps_band_description
  - fct_alps_subject_performance.count
filters:
  dim_academic_year.is_current_year: "Yes"
sorts:
  - fct_alps_subject_performance.alps_band asc
series_colors:
  fct_alps_subject_performance.count: "#4285F4"
row: 3
col: 0
width: 16
height: 6
```

##### Element 2.2: ALPS Band Descriptions Legend
```yaml
name: alps_band_legend
title: "ALPS Band Descriptions"
type: looker_single_record
explore: fct_alps_subject_performance
fields:
  - fct_alps_subject_performance.alps_band
  - fct_alps_subject_performance.alps_band_description
note: "Static reference panel"
row: 3
col: 16
width: 8
height: 6
```

#### Row 3: ALPS Performance Scatter

##### Element 3.1: Subjects Performance Scatter
```yaml
name: alps_performance_scatter
title: "Which subjects significantly outperform or underperform?"
type: looker_scatter
explore: fct_alps_subject_performance
fields:
  - fct_alps_subject_performance.alps_subject_name
  - fct_alps_subject_performance.cohort_count_dim
  - fct_alps_subject_performance.high_grades_pct_dim
  - fct_alps_subject_performance.alps_band
filters:
  dim_academic_year.is_current_year: "Yes"
x_axis:
  field: fct_alps_subject_performance.cohort_count_dim
  label: "Cohort Size"
y_axis:
  field: fct_alps_subject_performance.high_grades_pct_dim
  label: "High Grade %"
color_by:
  field: fct_alps_subject_performance.alps_band
series_colors:
  "1": "#34A853"
  "2": "#34A853"
  "3": "#4285F4"
  "4": "#4285F4"
  "5": "#FBBC04"
  "6": "#FBBC04"
  "7": "#EA4335"
  "8": "#EA4335"
  "9": "#EA4335"
row: 9
col: 0
width: 24
height: 7
```

#### Row 4: Subject vs National Standards

##### Element 4.1: Subjects vs National Bar
```yaml
name: subjects_vs_national
title: "Are subjects above or below national standards?"
type: looker_bar
explore: fct_alps_subject_performance
fields:
  - fct_alps_subject_performance.alps_subject_name
  - fct_alps_subject_performance.average_value_added
filters:
  dim_academic_year.is_current_year: "Yes"
sorts:
  - fct_alps_subject_performance.average_value_added desc
series_colors:
  fct_alps_subject_performance.average_value_added: "#4285F4"
conditional_formatting:
  - type: greater_than
    value: 0
    background_color: "#E6F4EA"
  - type: less_than
    value: 0
    background_color: "#FCE8E6"
row: 16
col: 0
width: 24
height: 6
```

#### Row 5: Subject ALPS Performance Table

##### Element 5.1: Subject ALPS Detail Table
```yaml
name: subject_alps_table
title: "Subject ALPS Performance Detail"
type: looker_grid
explore: fct_alps_subject_performance
fields:
  - fct_alps_subject_performance.alps_subject_name
  - fct_alps_subject_performance.alps_qualification_type
  - fct_alps_subject_performance.cohort_count_dim
  - fct_alps_subject_performance.alps_band
  - fct_alps_subject_performance.average_alps_score
  - fct_alps_subject_performance.pass_rate_pct_dim
  - fct_alps_subject_performance.high_grades_pct_dim
  - fct_alps_subject_performance.national_benchmark_grade
  - fct_alps_subject_performance.subject_mapping_status
filters:
  dim_academic_year.is_current_year: "Yes"
sorts:
  - fct_alps_subject_performance.alps_band asc
conditional_formatting:
  - type: along_a_scale
    field: fct_alps_subject_performance.alps_band
    palette: green_to_red
row: 22
col: 0
width: 24
height: 8
```

#### Row 6: ALPS Alerts

##### Element 6.1: ALPS Alerts Panel
```yaml
name: alps_alerts
title: "ALPS Alerts"
type: looker_single_record
explore: fct_alps_subject_performance
fields:
  - fct_alps_subject_performance.count_band_5_plus
  - fct_alps_subject_performance.alps_subject_name
filters:
  dim_academic_year.is_current_year: "Yes"
  fct_alps_subject_performance.alps_band: ">=5"
note_text: "Subjects requiring intervention to improve ALPS performance"
row: 30
col: 0
width: 24
height: 3
```

---

## Dashboard 4: Value-Added Analysis

### Dashboard Settings

```yaml
dashboard: value_added_analysis
title: "Value-Added Analysis"
layout: newspaper
preferred_viewer: dashboards-next
```

### Filters

| Filter Name | Field | Type | Default |
|-------------|-------|------|---------|
| Academic Year | dim_academic_year.academic_year_name | field_filter | Current Year |
| Report Type | fct_subject_benchmark.report_type | field_filter | VA |
| Qualification Type | fct_subject_benchmark.qualification_type | field_filter | All |

### Elements

#### Row 1: VA Overview KPIs (4 tiles)

##### Element 1.1: College VA Score
```yaml
name: college_va_score
title: "College VA Score"
type: single_value
explore: fct_subject_benchmark
fields:
  - fct_subject_benchmark.weighted_avg_va_score
filters:
  dim_academic_year.is_current_year: "Yes"
  fct_subject_benchmark.report_type: "VA"
value_format: "+0.00;-0.00"
note_text: "vs prior year"
row: 0
col: 0
width: 6
height: 3
```

##### Element 1.2: VA Percentile
```yaml
name: va_percentile
title: "VA Percentile"
type: single_value
explore: fct_subject_benchmark
fields:
  - fct_subject_benchmark.va_percentile_tier
filters:
  dim_academic_year.is_current_year: "Yes"
  fct_subject_benchmark.report_type: "VA"
note_text: "Approximate national ranking"
row: 0
col: 6
width: 6
height: 3
```

##### Element 1.3: Overall VA Band
```yaml
name: va_band
title: "Overall VA Band"
type: single_value
explore: fct_subject_benchmark
fields:
  - fct_subject_benchmark.college_va_band
filters:
  dim_academic_year.is_current_year: "Yes"
  fct_subject_benchmark.report_type: "VA"
note_text: "A-E scale"
row: 0
col: 12
width: 6
height: 3
```

##### Element 1.4: Subjects Above Expected
```yaml
name: subjects_above_expected
title: "Subjects Above Expected"
type: single_value
explore: fct_subject_benchmark
fields:
  - fct_subject_benchmark.count_above_expected
  - fct_subject_benchmark.count
filters:
  dim_academic_year.is_current_year: "Yes"
  fct_subject_benchmark.report_type: "VA"
single_value_title: "Subjects Above Expected"
note_text: "Positive VA score"
row: 0
col: 18
width: 6
height: 3
```

#### Row 2: Value-Added by Subject

##### Element 2.1: VA by Subject Bar Chart
```yaml
name: va_by_subject
title: "Which subjects add the most value?"
type: looker_bar
explore: fct_subject_benchmark
fields:
  - fct_subject_benchmark.six_dimensions_subject_name
  - fct_subject_benchmark.avg_value_added_score
filters:
  dim_academic_year.is_current_year: "Yes"
  fct_subject_benchmark.report_type: "VA"
sorts:
  - fct_subject_benchmark.avg_value_added_score desc
reference_lines:
  - value: 0
    label: "Expected"
conditional_formatting:
  - type: greater_than
    value: 0
    color: "#34A853"
  - type: less_than
    value: 0
    color: "#EA4335"
row: 3
col: 0
width: 24
height: 7
```

#### Row 3: VA Analysis Charts

##### Element 3.1: VA vs GCSE Entry Scatter
```yaml
name: va_vs_gcse_scatter
title: "Is VA driven by intake quality or teaching?"
type: looker_scatter
explore: fct_subject_benchmark
fields:
  - fct_subject_benchmark.six_dimensions_subject_name
  - fct_subject_benchmark.average_gcse_on_entry
  - fct_subject_benchmark.avg_value_added_score
filters:
  dim_academic_year.is_current_year: "Yes"
  fct_subject_benchmark.report_type: "VA"
x_axis:
  field: fct_subject_benchmark.average_gcse_on_entry
  label: "Avg GCSE Entry"
y_axis:
  field: fct_subject_benchmark.avg_value_added_score
  label: "VA Score"
reference_lines:
  - value: 0
    axis: y
    label: "Expected"
note_text: "Top-left = Low intake, high VA (excellent teaching)"
row: 10
col: 0
width: 12
height: 7
```

##### Element 3.2: VA Trend Over Time
```yaml
name: va_trend
title: "Is our value-added improving?"
type: looker_line
explore: fct_subject_benchmark
fields:
  - dim_academic_year.academic_year_name
  - fct_subject_benchmark.qualification_type
  - fct_subject_benchmark.avg_value_added_score
pivots:
  - fct_subject_benchmark.qualification_type
filters:
  fct_subject_benchmark.report_type: "VA"
sorts:
  - dim_academic_year.academic_year_name asc
reference_lines:
  - value: 0
    label: "Expected"
row: 10
col: 12
width: 12
height: 7
```

#### Row 4: Subject VA Performance Table

##### Element 4.1: Subject VA Detail Table
```yaml
name: subject_va_table
title: "Subject VA Performance Detail"
type: looker_grid
explore: fct_subject_benchmark
fields:
  - fct_subject_benchmark.six_dimensions_subject_name
  - fct_subject_benchmark.qualification_type
  - fct_subject_benchmark.cohort_count
  - fct_subject_benchmark.average_gcse_on_entry
  - fct_subject_benchmark.expected_grade
  - fct_subject_benchmark.actual_avg_grade
  - fct_subject_benchmark.avg_value_added_score
  - fct_subject_benchmark.va_band
  - fct_subject_benchmark.va_percentile_tier
filters:
  dim_academic_year.is_current_year: "Yes"
  fct_subject_benchmark.report_type: "VA"
sorts:
  - fct_subject_benchmark.avg_value_added_score desc
conditional_formatting:
  - type: along_a_scale
    field: fct_subject_benchmark.avg_value_added_score
    palette: red_white_green
row: 17
col: 0
width: 24
height: 8
```

#### Row 5: Top/Bottom Performers

##### Element 5.1: Top 5 VA Performers
```yaml
name: top_5_va
title: "Top 5 VA Performers"
type: looker_grid
explore: fct_subject_benchmark
fields:
  - fct_subject_benchmark.six_dimensions_subject_name
  - fct_subject_benchmark.avg_value_added_score
filters:
  dim_academic_year.is_current_year: "Yes"
  fct_subject_benchmark.report_type: "VA"
sorts:
  - fct_subject_benchmark.avg_value_added_score desc
limit: 5
row: 25
col: 0
width: 12
height: 5
```

##### Element 5.2: Bottom 5 VA Performers
```yaml
name: bottom_5_va
title: "Bottom 5 VA Performers (Intervention Required)"
type: looker_grid
explore: fct_subject_benchmark
fields:
  - fct_subject_benchmark.six_dimensions_subject_name
  - fct_subject_benchmark.avg_value_added_score
filters:
  dim_academic_year.is_current_year: "Yes"
  fct_subject_benchmark.report_type: "VA"
sorts:
  - fct_subject_benchmark.avg_value_added_score asc
limit: 5
row: 25
col: 12
width: 12
height: 5
```

---

## Dashboard 5: Gender Gap Analysis

### Dashboard Settings

```yaml
dashboard: gender_gap_analysis
title: "Gender Gap Analysis"
layout: newspaper
preferred_viewer: dashboards-next
```

### Filters

| Filter Name | Field | Type | Default |
|-------------|-------|------|---------|
| Academic Year | dim_academic_year.academic_year_name | field_filter | Current Year |
| Qualification Type | dim_offering_type.offering_type_name | field_filter | All |
| Prior Attainment | fct_enrolment.prior_attainment_band | field_filter | All |

### Elements

#### Row 1: Gender Gap Overview KPIs (4 tiles)

##### Element 1.1: Female Pass Rate
```yaml
name: female_pass_rate
title: "Female Pass Rate"
type: single_value
explore: fct_enrolment
fields:
  - fct_enrolment.female_pass_rate_pct
filters:
  dim_academic_year.is_current_year: "Yes"
value_format: "0.0\%"
row: 0
col: 0
width: 6
height: 3
```

##### Element 1.2: Male Pass Rate
```yaml
name: male_pass_rate
title: "Male Pass Rate"
type: single_value
explore: fct_enrolment
fields:
  - fct_enrolment.male_pass_rate_pct
filters:
  dim_academic_year.is_current_year: "Yes"
value_format: "0.0\%"
row: 0
col: 6
width: 6
height: 3
```

##### Element 1.3: Gender Gap
```yaml
name: gender_gap
title: "Gender Gap"
type: single_value
explore: fct_enrolment
fields:
  - fct_enrolment.gender_gap_pass_pp
filters:
  dim_academic_year.is_current_year: "Yes"
value_format: "+0.0;-0.0"
custom_suffix: "pp"
note_text: "Female - Male"
row: 0
col: 12
width: 6
height: 3
```

##### Element 1.4: Subjects with Gap >5pp
```yaml
name: subjects_large_gap
title: "Subjects with Gap >5pp"
type: single_value
explore: subject_gender_gap
fields:
  - subject_gender_gap.count_subjects_with_large_gap
filters:
  dim_academic_year.is_current_year: "Yes"
note_text: "Alert"
color_application:
  custom_color: "#EA4335"
row: 0
col: 18
width: 6
height: 3
```

#### Row 2: Gender Gap by Subject

##### Element 2.1: Gender Gap by Subject Bar
```yaml
name: gender_gap_by_subject
title: "Which subjects have the largest gender gaps?"
type: looker_bar
explore: subject_gender_gap
fields:
  - subject_gender_gap.offering_name
  - subject_gender_gap.subject_gender_gap_pass
filters:
  dim_academic_year.is_current_year: "Yes"
sorts:
  - subject_gender_gap.subject_gender_gap_pass desc
reference_lines:
  - value: 0
    label: "No Gap"
conditional_formatting:
  - type: greater_than
    value: 0
    color: "#4285F4"
    label: "Female outperforming"
  - type: less_than
    value: 0
    color: "#EA4335"
    label: "Male outperforming"
row: 3
col: 0
width: 24
height: 7
```

#### Row 3: Gender Gap Trend and Pass Rate by Subject

##### Element 3.1: Gender Gap Trend
```yaml
name: gender_gap_trend
title: "Is the gender gap narrowing?"
type: looker_line
explore: fct_enrolment
fields:
  - dim_academic_year.academic_year_name
  - fct_enrolment.gender_gap_pass_pp
sorts:
  - dim_academic_year.academic_year_name asc
reference_lines:
  - value: 0
    label: "No Gap"
row: 10
col: 0
width: 12
height: 6
```

##### Element 3.2: Pass Rate by Gender & Subject
```yaml
name: pass_rate_by_gender_subject
title: "Pass Rate by Gender & Subject"
type: looker_bar
explore: fct_enrolment
fields:
  - dim_offering.offering_name
  - fct_enrolment.gender
  - fct_enrolment.pass_rate_pct
pivots:
  - fct_enrolment.gender
filters:
  dim_academic_year.is_current_year: "Yes"
series_colors:
  Female: "#4285F4"
  Male: "#FBBC04"
row: 10
col: 12
width: 12
height: 6
```

#### Row 4: Subject-Level Gender Analysis Table

##### Element 4.1: Subject Gender Analysis Table
```yaml
name: subject_gender_table
title: "Subject-Level Gender Analysis"
type: looker_grid
explore: subject_gender_gap
fields:
  - subject_gender_gap.offering_name
  - subject_gender_gap.subject_female_pass_rate
  - subject_gender_gap.subject_male_pass_rate
  - subject_gender_gap.subject_gender_gap_pass
  - subject_gender_gap.subject_female_high_grade_rate
  - subject_gender_gap.subject_male_high_grade_rate
  - subject_gender_gap.subject_gender_gap_high_grade
filters:
  dim_academic_year.is_current_year: "Yes"
sorts:
  - subject_gender_gap.subject_gender_gap_pass desc
conditional_formatting:
  - type: along_a_scale
    field: subject_gender_gap.subject_gender_gap_pass
    palette: red_white_green
row: 16
col: 0
width: 24
height: 8
```

---

## Appendix A: Color Palette

| Usage | Color | Hex Code |
|-------|-------|----------|
| Primary Blue | Google Blue | #4285F4 |
| Success Green | Google Green | #34A853 |
| Warning Yellow | Google Yellow | #FBBC04 |
| Alert Red | Google Red | #EA4335 |
| Neutral Gray | Google Gray | #5F6368 |
| Light Blue | Light Blue | #669DF6 |
| Light Green | Light Green | #81C995 |

## Appendix B: Value Formats

| Format Name | Pattern | Example |
|-------------|---------|---------|
| Percentage | 0.0% | 98.4% |
| Percentage Point | +0.0;-0.0 pp | +1.5pp |
| Decimal 2 | 0.00 | 5.82 |
| Integer | #,##0 | 1,422 |
| Grade Points | 0.0 | 37.8 |

## Appendix C: Conditional Formatting Rules

### Pass Rate Thresholds
- Green: >= 95%
- Yellow: 90-94%
- Red: < 90%

### ALPS Band Colors
- Band 1-2: Green (#34A853)
- Band 3-4: Blue (#4285F4)
- Band 5-6: Yellow (#FBBC04)
- Band 7-9: Red (#EA4335)

### VA Score Colors
- Positive (>0): Green
- At Expected (~0): Gray
- Negative (<0): Red

### Gap Analysis Colors
- Narrowing: Green
- Stable: Gray
- Widening: Red
