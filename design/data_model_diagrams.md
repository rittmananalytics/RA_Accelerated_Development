# Barton Peveril Sixth Form College - Data Model Diagrams

This document contains physical data model diagrams and data flow diagrams for the data warehouse implementation.

## Table of Contents

1. [Source Layer Physical Data Model](#1-source-layer-physical-data-model)
   - [ProSolution Source Tables](#11-prosolution-source-tables)
   - [External Source Tables](#12-external-source-tables)
2. [Warehouse Layer Physical Data Model](#2-warehouse-layer-physical-data-model)
   - [Dimension Tables](#21-dimension-tables)
   - [Fact Tables](#22-fact-tables)
   - [Star Schema Overview](#23-star-schema-overview)
3. [Data Flow Diagram](#3-data-flow-diagram)
   - [Layer Architecture](#31-layer-architecture)
   - [Detailed Transformation Flow](#32-detailed-transformation-flow)

---

## 1. Source Layer Physical Data Model

### 1.1 ProSolution Source Tables

The core MIS data from ProSolution including students, courses, and enrolments.

```mermaid
erDiagram
    raw_prosolution_student {
        INT64 student_id PK "NOT NULL"
        STRING uln
        STRING first_name
        STRING last_name
        DATE date_of_birth
        STRING email
        STRING gender
        STRING ethnicity
        BOOL is_active
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP _sdc_extracted_at
        TIMESTAMP _sdc_received_at
        TIMESTAMP _sdc_batched_at
        TIMESTAMP _sdc_deleted_at
    }

    raw_prosolution_student_detail {
        INT64 student_detail_id PK "NOT NULL"
        INT64 student_id FK "NOT NULL"
        STRING academic_year_id FK
        STRING postcode
        STRING lldd_code
        BOOL is_send
        BOOL is_high_needs
        BOOL is_free_meals
        BOOL is_bursary
        BOOL is_lac
        STRING primary_send_type
        STRING secondary_send_type
        TIMESTAMP _sdc_extracted_at
        TIMESTAMP _sdc_received_at
        TIMESTAMP _sdc_batched_at
        TIMESTAMP _sdc_deleted_at
    }

    raw_prosolution_course_header {
        INT64 course_header_id PK "NOT NULL"
        STRING code
        STRING name
        STRING description
        STRING subject_area
        STRING department
        STRING faculty
        BOOL is_active
        TIMESTAMP _sdc_extracted_at
        TIMESTAMP _sdc_received_at
        TIMESTAMP _sdc_batched_at
        TIMESTAMP _sdc_deleted_at
    }

    raw_prosolution_offering_type {
        INT64 offering_type_id PK "NOT NULL"
        STRING name
        STRING description
        STRING category
        STRING qualification_level
        TIMESTAMP _sdc_extracted_at
        TIMESTAMP _sdc_received_at
        TIMESTAMP _sdc_batched_at
        TIMESTAMP _sdc_deleted_at
    }

    raw_prosolution_offering {
        INT64 offering_id PK "NOT NULL"
        INT64 course_header_id FK
        INT64 offering_type_id FK
        STRING academic_year_id
        STRING code
        STRING name
        STRING qual_id
        INT64 study_year
        INT64 duration
        DATE start_date
        DATE end_date
        INT64 planned_hours
        BOOL is_active
        TIMESTAMP _sdc_extracted_at
        TIMESTAMP _sdc_received_at
        TIMESTAMP _sdc_batched_at
        TIMESTAMP _sdc_deleted_at
    }

    raw_prosolution_completion_status {
        INT64 completion_status_id PK "NOT NULL"
        STRING name
        STRING description
        BOOL is_completed
        BOOL is_continuing
        BOOL is_withdrawn
        TIMESTAMP _sdc_extracted_at
        TIMESTAMP _sdc_received_at
        TIMESTAMP _sdc_batched_at
        TIMESTAMP _sdc_deleted_at
    }

    raw_prosolution_enrolment {
        INT64 enrolment_id PK "NOT NULL"
        INT64 student_id FK "NOT NULL"
        INT64 offering_id FK "NOT NULL"
        INT64 completion_status_id FK
        DATE enrolment_date
        DATE expected_end_date
        DATE actual_end_date
        STRING target_grade
        STRING predicted_grade
        STRING actual_grade
        NUMERIC attendance_pct
        BOOL is_current
        TIMESTAMP _sdc_extracted_at
        TIMESTAMP _sdc_received_at
        TIMESTAMP _sdc_batched_at
        TIMESTAMP _sdc_deleted_at
    }

    raw_prosolution_student ||--o{ raw_prosolution_student_detail : "has details"
    raw_prosolution_student ||--o{ raw_prosolution_enrolment : "enrolls in"
    raw_prosolution_course_header ||--o{ raw_prosolution_offering : "has offerings"
    raw_prosolution_offering_type ||--o{ raw_prosolution_offering : "categorizes"
    raw_prosolution_offering ||--o{ raw_prosolution_enrolment : "has enrolments"
    raw_prosolution_completion_status ||--o{ raw_prosolution_enrolment : "status of"
```

### 1.2 External Source Tables

Extended demographics, prior attainment, and external benchmarking data.

```mermaid
erDiagram
    raw_mis_applications_student_extended_data {
        INT64 student_extended_id PK "NOT NULL"
        INT64 student_id FK "NOT NULL"
        STRING academic_year_id
        STRING nationality
        STRING country_of_birth
        STRING first_language
        STRING religion
        BOOL is_young_carer
        BOOL is_parent_carer
        STRING care_leaver_status
        STRING asylum_seeker_status
        STRING armed_forces_status
        STRING household_situation
        INT64 imd_decile
        INT64 polar4_quintile
        STRING tundra_classification
        TIMESTAMP _sdc_extracted_at
        TIMESTAMP _sdc_received_at
        TIMESTAMP _sdc_batched_at
        TIMESTAMP _sdc_deleted_at
    }

    raw_focus_average_gcse {
        INT64 average_gcse_id PK "NOT NULL"
        INT64 student_id FK "NOT NULL"
        STRING academic_year_id
        NUMERIC average_gcse_score
        STRING gcse_english_grade
        STRING gcse_maths_grade
        INT64 gcse_count
        STRING data_source
        TIMESTAMP _sdc_extracted_at
        TIMESTAMP _sdc_received_at
        TIMESTAMP _sdc_batched_at
        TIMESTAMP _sdc_deleted_at
    }

    raw_alps_provider_report_a_level {
        INT64 alps_report_id PK "NOT NULL"
        STRING academic_year "NOT NULL"
        STRING subject_name "NOT NULL"
        INT64 student_count
        NUMERIC average_gcse_on_entry
        INT64 alps_grade
        NUMERIC alps_score
        NUMERIC value_added_score
        STRING national_benchmark_grade
        NUMERIC pass_rate_pct
        NUMERIC high_grades_pct
        DATE report_date
        TIMESTAMP _sdc_extracted_at
        TIMESTAMP _sdc_received_at
        TIMESTAMP _sdc_batched_at
        TIMESTAMP _sdc_deleted_at
    }

    raw_alps_provider_report_btec {
        INT64 alps_btec_report_id PK "NOT NULL"
        STRING academic_year "NOT NULL"
        STRING subject_name "NOT NULL"
        STRING qualification_type
        INT64 student_count
        NUMERIC average_gcse_on_entry
        INT64 alps_grade
        NUMERIC alps_score
        NUMERIC value_added_score
        STRING national_benchmark_grade
        NUMERIC pass_rate_pct
        NUMERIC high_grades_pct
        DATE report_date
        TIMESTAMP _sdc_extracted_at
        TIMESTAMP _sdc_received_at
        TIMESTAMP _sdc_batched_at
        TIMESTAMP _sdc_deleted_at
    }

    raw_six_dimensions_va_report {
        INT64 va_report_id PK "NOT NULL"
        STRING academic_year "NOT NULL"
        STRING subject_name
        STRING qualification_type
        INT64 student_count
        NUMERIC average_gcse_on_entry
        NUMERIC value_added_score
        NUMERIC residual_score
        STRING expected_grade
        STRING actual_avg_grade
        STRING performance_band
        NUMERIC confidence_interval_lower
        NUMERIC confidence_interval_upper
        DATE report_date
        TIMESTAMP _sdc_extracted_at
        TIMESTAMP _sdc_received_at
        TIMESTAMP _sdc_batched_at
        TIMESTAMP _sdc_deleted_at
    }

    raw_six_dimensions_sixth_sense_report {
        INT64 sixth_sense_id PK "NOT NULL"
        STRING academic_year "NOT NULL"
        STRING subject_name
        STRING qualification_type
        INT64 student_count
        NUMERIC completion_rate_pct
        NUMERIC retention_rate_pct
        NUMERIC achievement_rate_pct
        NUMERIC pass_rate_pct
        NUMERIC high_grades_pct
        NUMERIC attendance_rate_pct
        NUMERIC national_completion_pct
        NUMERIC national_achievement_pct
        NUMERIC national_pass_pct
        STRING performance_quartile
        DATE report_date
        TIMESTAMP _sdc_extracted_at
        TIMESTAMP _sdc_received_at
        TIMESTAMP _sdc_batched_at
        TIMESTAMP _sdc_deleted_at
    }

    raw_six_dimensions_vocational_report {
        INT64 vocational_report_id PK "NOT NULL"
        STRING academic_year "NOT NULL"
        STRING subject_name
        STRING qualification_type
        STRING qualification_size
        INT64 student_count
        NUMERIC average_gcse_on_entry
        NUMERIC completion_rate_pct
        NUMERIC achievement_rate_pct
        NUMERIC pass_rate_pct
        NUMERIC distinction_star_pct
        NUMERIC distinction_pct
        NUMERIC merit_pct
        NUMERIC pass_pct
        NUMERIC near_pass_pct
        NUMERIC fail_pct
        NUMERIC national_achievement_pct
        NUMERIC national_distinction_plus_pct
        STRING performance_band
        DATE report_date
        TIMESTAMP _sdc_extracted_at
        TIMESTAMP _sdc_received_at
        TIMESTAMP _sdc_batched_at
        TIMESTAMP _sdc_deleted_at
    }

    raw_six_dimensions_jedi_report {
        INT64 jedi_report_id PK "NOT NULL"
        STRING academic_year "NOT NULL"
        STRING report_type
        STRING dimension_name "NOT NULL"
        STRING student_group "NOT NULL"
        STRING comparison_group
        INT64 student_count
        INT64 comparison_count
        NUMERIC student_avg_grade_points
        NUMERIC comparison_avg_grade_points
        NUMERIC gap_grade_points
        STRING gap_significance
        STRING performance_band
        DATE report_date
        TIMESTAMP _sdc_extracted_at
        TIMESTAMP _sdc_received_at
        TIMESTAMP _sdc_batched_at
        TIMESTAMP _sdc_deleted_at
    }

    raw_prosolution_student ||--o| raw_mis_applications_student_extended_data : "extended demographics"
    raw_prosolution_student ||--o| raw_focus_average_gcse : "prior attainment"
```

### 1.3 Seed Reference Tables

Static reference data loaded as dbt seeds.

```mermaid
erDiagram
    seed_grade_points {
        STRING grade PK "NOT NULL"
        STRING qualification_type PK "NOT NULL"
        INT64 ucas_points
        INT64 grade_points
        INT64 grade_sort_order
        BOOL is_pass
        BOOL is_high_grade
    }

    seed_subject_crosswalk {
        INT64 course_header_id FK
        STRING offering_code
        STRING prosolution_subject_name
        STRING alps_subject_name
        STRING alps_qualification_type
        STRING six_dimensions_subject_name
        STRING dfe_qualification_code
        STRING dfe_subject_name
        STRING mapping_method
        NUMERIC match_confidence_pct
        BOOL is_verified
        STRING verified_by
        DATE verified_date
    }
```

---

## 2. Warehouse Layer Physical Data Model

### 2.1 Dimension Tables

```mermaid
erDiagram
    dim_academic_year {
        INT64 academic_year_key PK "NOT NULL"
        STRING academic_year_id UK "NOT NULL"
        STRING academic_year_name
        DATE academic_year_start_date
        DATE academic_year_end_date
        INT64 calendar_year_start
        INT64 calendar_year_end
        BOOL is_current_year
        INT64 years_from_current
        STRING record_source
        TIMESTAMP loaded_at
    }

    dim_offering_type {
        INT64 offering_type_key PK "NOT NULL"
        INT64 offering_type_id UK "NOT NULL"
        STRING offering_type_name
        STRING offering_type_category
        STRING qualification_level
        STRING grading_scale
        BOOL is_academic
        BOOL is_vocational
        STRING record_source
        TIMESTAMP loaded_at
    }

    dim_course_header {
        INT64 course_header_key PK "NOT NULL"
        INT64 course_header_id UK "NOT NULL"
        STRING course_code
        STRING course_name
        STRING subject_area
        STRING department
        BOOL is_active
        STRING record_source
        TIMESTAMP loaded_at
    }

    dim_offering {
        INT64 offering_key PK "NOT NULL"
        INT64 offering_id UK "NOT NULL"
        STRING offering_code
        STRING offering_name
        STRING qualification_id
        INT64 study_year
        INT64 duration_years
        BOOL is_final_year
        STRING academic_year_id FK
        INT64 offering_type_id FK
        INT64 course_header_id FK
        STRING dfe_qualification_code
        STRING alps_subject_name
        STRING six_dimensions_subject_name
        STRING record_source
        TIMESTAMP loaded_at
    }

    dim_student {
        INT64 student_key PK "NOT NULL"
        INT64 student_id UK "NOT NULL"
        STRING uln
        STRING first_name
        STRING last_name
        STRING full_name
        DATE date_of_birth
        STRING gender
        STRING ethnicity
        BOOL is_active
        TIMESTAMP first_enrolment_date
        DATE valid_from_date
        DATE valid_to_date
        BOOL is_current
        STRING record_source
        TIMESTAMP loaded_at
    }

    dim_student_detail {
        INT64 student_detail_key PK "NOT NULL"
        INT64 student_detail_id UK "NOT NULL"
        INT64 student_id FK
        STRING academic_year_id FK
        STRING full_name
        STRING gender
        STRING ethnicity
        BOOL is_free_meals
        BOOL is_bursary
        BOOL is_lac
        BOOL is_send
        BOOL is_high_needs
        BOOL is_young_carer
        STRING primary_send_type
        STRING secondary_send_type
        STRING postcode_area
        INT64 imd_decile
        INT64 polar4_quintile
        STRING tundra_classification
        STRING nationality
        STRING country_of_birth
        STRING first_language
        STRING religion
        NUMERIC average_gcse_score
        STRING prior_attainment_band
        STRING record_source
        TIMESTAMP loaded_at
    }

    dim_prior_attainment {
        INT64 prior_attainment_key PK "NOT NULL"
        INT64 average_gcse_id UK "NOT NULL"
        INT64 student_id FK "NOT NULL"
        STRING academic_year_id FK
        NUMERIC average_gcse_score
        STRING prior_attainment_band
        INT64 prior_attainment_band_code
        NUMERIC low_threshold
        NUMERIC high_threshold
        INT64 gcse_english_grade
        INT64 gcse_maths_grade
        INT64 gcse_count
        STRING record_source
        TIMESTAMP loaded_at
    }

    dim_grade {
        INT64 grade_key PK "NOT NULL"
        STRING grade UK "NOT NULL"
        STRING grading_scale UK "NOT NULL"
        INT64 ucas_points
        INT64 grade_points
        INT64 grade_sort_order
        BOOL is_high_grade
        BOOL is_pass_grade
        BOOL is_grade_a_star_to_a
        BOOL is_grade_a_star_to_b
        BOOL is_grade_a_star_to_c
        BOOL is_grade_a_star_to_e
        STRING record_source
        TIMESTAMP loaded_at
    }

    dim_academic_year ||--o{ dim_offering : "academic_year_id"
    dim_offering_type ||--o{ dim_offering : "offering_type_id"
    dim_course_header ||--o{ dim_offering : "course_header_id"
    dim_student ||--o{ dim_student_detail : "student_id"
    dim_student ||--o{ dim_prior_attainment : "student_id"
    dim_academic_year ||--o{ dim_student_detail : "academic_year_id"
    dim_academic_year ||--o{ dim_prior_attainment : "academic_year_id"
```

### 2.2 Fact Tables

```mermaid
erDiagram
    fct_enrolment {
        INT64 enrolment_key PK "NOT NULL"
        INT64 academic_year_key FK "NOT NULL"
        INT64 offering_type_key FK "NOT NULL"
        INT64 course_header_key FK "NOT NULL"
        INT64 offering_key FK "NOT NULL"
        INT64 student_key FK "NOT NULL"
        INT64 student_detail_key FK
        INT64 prior_attainment_key FK
        INT64 grade_key FK
        STRING academic_year_id
        INT64 offering_id
        INT64 student_id
        INT64 student_detail_id
        DATE academic_year_start_date "PARTITION KEY"
        INT64 completion_status_id
        STRING completion_status
        BOOL is_completed
        STRING grade
        STRING target_grade
        STRING predicted_grade
        INT64 is_grade_a_star
        INT64 is_grade_a
        INT64 is_grade_b
        INT64 is_grade_c
        INT64 is_grade_d
        INT64 is_grade_e
        INT64 is_grade_u
        INT64 is_grade_distinction_star
        INT64 is_grade_distinction
        INT64 is_grade_merit
        INT64 is_grade_pass
        INT64 is_high_grade
        INT64 is_pass
        NUMERIC average_gcse_score
        STRING prior_attainment_band
        STRING gender
        STRING ethnicity
        BOOL is_send
        BOOL is_free_meals
        BOOL is_bursary
        BOOL is_lac
        BOOL is_young_carer
        NUMERIC attendance_pct
        INT64 enrolment_count
        STRING record_source
        TIMESTAMP loaded_at
    }

    fct_alps_subject_performance {
        INT64 alps_subject_performance_key PK "NOT NULL"
        INT64 academic_year_key FK "NOT NULL"
        INT64 offering_key FK
        STRING alps_subject_name "NOT NULL"
        STRING alps_qualification_type
        STRING subject_mapping_status
        NUMERIC mapping_confidence_pct
        INT64 cohort_count
        NUMERIC average_gcse_on_entry
        INT64 alps_band
        NUMERIC alps_score
        NUMERIC value_added_score
        STRING national_benchmark_grade
        NUMERIC pass_rate_pct
        NUMERIC high_grades_pct
        DATE alps_report_date
        STRING record_source
        TIMESTAMP loaded_at
    }

    fct_college_performance {
        INT64 college_performance_key PK "NOT NULL"
        INT64 academic_year_key FK "NOT NULL"
        STRING report_type
        STRING report_name
        INT64 total_cohort_count
        NUMERIC avg_pass_rate_pct
        NUMERIC avg_high_grades_pct
        NUMERIC avg_completion_rate_pct
        NUMERIC avg_retention_rate_pct
        NUMERIC avg_achievement_rate_pct
        NUMERIC avg_attendance_rate_pct
        NUMERIC avg_value_added_score
        NUMERIC avg_confidence_lower
        NUMERIC avg_confidence_upper
        DATE report_date
        STRING record_source
        TIMESTAMP loaded_at
    }

    fct_subject_benchmark {
        INT64 subject_benchmark_key PK "NOT NULL"
        INT64 academic_year_key FK "NOT NULL"
        INT64 offering_key FK
        STRING report_type
        STRING six_dimensions_subject_name "NOT NULL"
        STRING qualification_type
        STRING subject_mapping_status
        NUMERIC mapping_confidence_pct
        INT64 cohort_count
        NUMERIC average_gcse_on_entry
        NUMERIC pass_rate_pct
        NUMERIC high_grades_pct
        NUMERIC completion_rate_pct
        NUMERIC achievement_rate_pct
        NUMERIC value_added_score
        NUMERIC residual_score
        STRING expected_grade
        STRING actual_avg_grade
        STRING performance_band
        NUMERIC confidence_interval_lower
        NUMERIC confidence_interval_upper
        STRING performance_quartile
        STRING performance_trajectory
        NUMERIC yoy_change_pct
        DATE report_date
        STRING record_source
        TIMESTAMP loaded_at
    }

    fct_equity_gap {
        INT64 equity_gap_key PK "NOT NULL"
        INT64 academic_year_key FK "NOT NULL"
        STRING report_type
        STRING dimension_name "NOT NULL"
        STRING student_group "NOT NULL"
        STRING comparison_group
        INT64 student_count
        INT64 comparison_count
        NUMERIC student_avg_grade_points
        NUMERIC comparison_avg_grade_points
        NUMERIC gap_grade_points
        STRING gap_significance
        STRING performance_band
        NUMERIC prior_year_gap
        NUMERIC gap_change_yoy
        STRING gap_trend
        DATE report_date
        STRING record_source
        TIMESTAMP loaded_at
    }
```

### 2.3 Star Schema Overview

Complete star schema showing fact-to-dimension relationships.

```mermaid
erDiagram
    fct_enrolment ||--|| dim_academic_year : "academic_year_key"
    fct_enrolment ||--|| dim_offering_type : "offering_type_key"
    fct_enrolment ||--|| dim_course_header : "course_header_key"
    fct_enrolment ||--|| dim_offering : "offering_key"
    fct_enrolment ||--|| dim_student : "student_key"
    fct_enrolment ||--o| dim_student_detail : "student_detail_key"
    fct_enrolment ||--o| dim_prior_attainment : "prior_attainment_key"
    fct_enrolment ||--o| dim_grade : "grade_key"

    fct_alps_subject_performance ||--|| dim_academic_year : "academic_year_key"
    fct_alps_subject_performance ||--o| dim_offering : "offering_key"

    fct_college_performance ||--|| dim_academic_year : "academic_year_key"

    fct_subject_benchmark ||--|| dim_academic_year : "academic_year_key"
    fct_subject_benchmark ||--o| dim_offering : "offering_key"

    fct_equity_gap ||--|| dim_academic_year : "academic_year_key"

    dim_academic_year {
        INT64 academic_year_key PK
        STRING academic_year_id UK
        STRING academic_year_name
        BOOL is_current_year
    }

    dim_offering_type {
        INT64 offering_type_key PK
        INT64 offering_type_id UK
        STRING offering_type_name
        STRING grading_scale
    }

    dim_course_header {
        INT64 course_header_key PK
        INT64 course_header_id UK
        STRING course_name
        STRING subject_area
    }

    dim_offering {
        INT64 offering_key PK
        INT64 offering_id UK
        STRING offering_name
        STRING alps_subject_name
        STRING six_dimensions_subject_name
    }

    dim_student {
        INT64 student_key PK
        INT64 student_id UK
        STRING full_name
        STRING gender
        STRING ethnicity
    }

    dim_student_detail {
        INT64 student_detail_key PK
        INT64 student_id FK
        STRING academic_year_id FK
        BOOL is_free_meals
        BOOL is_send
    }

    dim_prior_attainment {
        INT64 prior_attainment_key PK
        INT64 student_id FK
        NUMERIC average_gcse_score
        STRING prior_attainment_band
    }

    dim_grade {
        INT64 grade_key PK
        STRING grade
        STRING grading_scale
        INT64 ucas_points
    }

    fct_enrolment {
        INT64 enrolment_key PK
        INT64 academic_year_key FK
        INT64 student_key FK
        INT64 offering_key FK
        STRING grade
        INT64 is_high_grade
        INT64 is_pass
    }

    fct_alps_subject_performance {
        INT64 alps_subject_performance_key PK
        INT64 academic_year_key FK
        STRING alps_subject_name
        INT64 alps_band
        NUMERIC value_added_score
    }

    fct_college_performance {
        INT64 college_performance_key PK
        INT64 academic_year_key FK
        STRING report_type
        NUMERIC avg_pass_rate_pct
    }

    fct_subject_benchmark {
        INT64 subject_benchmark_key PK
        INT64 academic_year_key FK
        STRING six_dimensions_subject_name
        NUMERIC value_added_score
    }

    fct_equity_gap {
        INT64 equity_gap_key PK
        INT64 academic_year_key FK
        STRING dimension_name
        NUMERIC gap_grade_points
    }
```

---

## 3. Data Flow Diagram

### 3.1 Layer Architecture

High-level view of the dbt layer architecture and data flow.

```mermaid
graph TB
    subgraph "Source Systems"
        PS[("ProSolution<br/>MIS")]
        MA[("MIS Applications")]
        FO[("Focus")]
        AL[("ALPS PDFs")]
        SD[("Six Dimensions PDFs")]
    end

    subgraph "Raw Layer (Seeds)"
        direction TB
        PS --> S1["raw_prosolution.*<br/>(7 tables)"]
        MA --> S2["raw_mis_applications.*<br/>(1 table)"]
        FO --> S3["raw_focus.*<br/>(1 table)"]
        AL --> S4["raw_alps.*<br/>(2 tables)"]
        SD --> S5["raw_six_dimensions.*<br/>(4 tables)"]
        REF["seed_grade_points<br/>seed_subject_crosswalk"]
    end

    subgraph "Staging Layer (Views)"
        direction TB
        S1 --> STG1["stg_prosolution__*<br/>(7 views)"]
        S2 --> STG2["stg_mis_applications__*<br/>(1 view)"]
        S3 --> STG3["stg_focus__*<br/>(1 view)"]
        S4 --> STG4["stg_alps__*<br/>(2 views)"]
        S5 --> STG5["stg_six_dimensions__*<br/>(4 views)"]
    end

    subgraph "Intermediate Layer (Views)"
        direction TB
        STG1 --> INT1["int_enrolment_with_context"]
        STG2 --> INT2["int_student_demographics_joined"]
        STG3 --> INT2
        STG4 --> INT3["int_alps_performance_unioned"]
        STG5 --> INT4["int_six_dimensions_subject_unioned"]
        STG5 --> INT5["int_six_dimensions_college_unioned"]
        STG1 --> INT2
    end

    subgraph "Marts Layer (Tables)"
        direction TB
        INT1 --> FCT1[("fct_enrolment")]
        INT2 --> DIM1[("dim_student_detail")]
        INT3 --> FCT2[("fct_alps_subject_performance")]
        INT4 --> FCT3[("fct_subject_benchmark")]
        INT5 --> FCT4[("fct_college_performance")]

        STG1 --> DIM2[("dim_academic_year")]
        STG1 --> DIM3[("dim_offering_type")]
        STG1 --> DIM4[("dim_course_header")]
        STG1 --> DIM5[("dim_offering")]
        STG1 --> DIM6[("dim_student")]
        STG3 --> DIM7[("dim_prior_attainment")]
        REF --> DIM8[("dim_grade")]

        STG5 --> FCT5[("fct_equity_gap")]
    end

    subgraph "Consumers"
        FCT1 --> BI["BI Tools<br/>(Power BI, Looker)"]
        FCT2 --> BI
        FCT3 --> BI
        FCT4 --> BI
        FCT5 --> BI
        DIM1 --> BI
        DIM2 --> BI
    end

    style PS fill:#e1f5fe
    style MA fill:#e1f5fe
    style FO fill:#e1f5fe
    style AL fill:#fff3e0
    style SD fill:#fff3e0
    style FCT1 fill:#c8e6c9
    style FCT2 fill:#c8e6c9
    style FCT3 fill:#c8e6c9
    style FCT4 fill:#c8e6c9
    style FCT5 fill:#c8e6c9
    style BI fill:#f3e5f5
```

### 3.2 Detailed Transformation Flow

Detailed view showing specific model transformations and dependencies.

```mermaid
flowchart TB
    subgraph RAW["Raw Layer (dbt seeds)"]
        direction LR
        R1[raw_prosolution.student]
        R2[raw_prosolution.student_detail]
        R3[raw_prosolution.enrolment]
        R4[raw_prosolution.offering]
        R5[raw_prosolution.course_header]
        R6[raw_prosolution.offering_type]
        R7[raw_prosolution.completion_status]
        R8[raw_mis_applications.student_extended_data]
        R9[raw_focus.average_gcse]
        R10[raw_alps.provider_report_a_level]
        R11[raw_alps.provider_report_btec]
        R12[raw_six_dimensions.va_report]
        R13[raw_six_dimensions.sixth_sense_report]
        R14[raw_six_dimensions.vocational_report]
        R15[raw_six_dimensions.jedi_report]
        R16[seed_grade_points]
        R17[seed_subject_crosswalk]
    end

    subgraph STG["Staging Layer (views)"]
        direction LR
        S1[stg_prosolution__student]
        S2[stg_prosolution__student_detail]
        S3[stg_prosolution__enrolment]
        S4[stg_prosolution__offering]
        S5[stg_prosolution__course_header]
        S6[stg_prosolution__offering_type]
        S7[stg_prosolution__completion_status]
        S8[stg_mis_applications__student_extended_data]
        S9[stg_focus__average_gcse]
        S10[stg_alps__a_level_performance]
        S11[stg_alps__btec_performance]
        S12[stg_six_dimensions__va]
        S13[stg_six_dimensions__sixth_sense]
        S14[stg_six_dimensions__vocational]
        S15[stg_six_dimensions__jedi]
    end

    subgraph INT["Intermediate Layer (views)"]
        direction LR
        I1[int_enrolment_with_context]
        I2[int_student_demographics_joined]
        I3[int_alps_performance_unioned]
        I4[int_six_dimensions_subject_unioned]
        I5[int_six_dimensions_college_unioned]
    end

    subgraph DIM["Dimension Tables"]
        direction LR
        D1[dim_academic_year]
        D2[dim_offering_type]
        D3[dim_course_header]
        D4[dim_offering]
        D5[dim_student]
        D6[dim_student_detail]
        D7[dim_prior_attainment]
        D8[dim_grade]
    end

    subgraph FCT["Fact Tables"]
        direction LR
        F1[fct_enrolment]
        F2[fct_alps_subject_performance]
        F3[fct_subject_benchmark]
        F4[fct_college_performance]
        F5[fct_equity_gap]
    end

    %% Raw to Staging
    R1 --> S1
    R2 --> S2
    R3 --> S3
    R4 --> S4
    R5 --> S5
    R6 --> S6
    R7 --> S7
    R8 --> S8
    R9 --> S9
    R10 --> S10
    R11 --> S11
    R12 --> S12
    R13 --> S13
    R14 --> S14
    R15 --> S15

    %% Staging to Intermediate
    S3 --> I1
    S4 --> I1
    S6 --> I1
    S7 --> I1
    S1 --> I2
    S2 --> I2
    S8 --> I2
    S9 --> I2
    S10 --> I3
    S11 --> I3
    S12 --> I4
    S13 --> I4
    S14 --> I4
    S12 --> I5
    S13 --> I5

    %% Staging/Intermediate to Dimensions
    S4 --> D1
    S6 --> D2
    S5 --> D3
    S4 --> D4
    R17 --> D4
    S1 --> D5
    I2 --> D6
    S9 --> D7
    R16 --> D8

    %% Intermediate/Dimensions to Facts
    I1 --> F1
    D1 --> F1
    D2 --> F1
    D3 --> F1
    D4 --> F1
    D5 --> F1
    D6 --> F1
    D7 --> F1
    D8 --> F1

    I3 --> F2
    D1 --> F2
    D4 --> F2

    I4 --> F3
    D1 --> F3
    D4 --> F3

    I5 --> F4
    D1 --> F4

    S15 --> F5
    D1 --> F5
```

### 3.3 Model Dependency Graph

Simplified DAG showing model execution order.

```mermaid
graph LR
    subgraph "Layer 0: Seeds"
        SEED[dbt seed]
    end

    subgraph "Layer 1: Staging"
        STG[dbt run --select staging]
    end

    subgraph "Layer 2: Intermediate"
        INT[dbt run --select intermediate]
    end

    subgraph "Layer 3: Marts - Dimensions"
        DIM[dbt run --select dimensions]
    end

    subgraph "Layer 4: Marts - Facts"
        FCT[dbt run --select facts]
    end

    SEED --> STG
    STG --> INT
    INT --> DIM
    DIM --> FCT
    STG --> DIM
    INT --> FCT

    style SEED fill:#fff9c4
    style STG fill:#e3f2fd
    style INT fill:#e8f5e9
    style DIM fill:#fce4ec
    style FCT fill:#f3e5f5
```

---

## 4. Key Relationships Summary

### 4.1 Dimension Key Types

| Dimension | Surrogate Key | Natural Key(s) | Grain |
|-----------|---------------|----------------|-------|
| dim_academic_year | academic_year_key | academic_year_id | One row per academic year |
| dim_offering_type | offering_type_key | offering_type_id | One row per offering type |
| dim_course_header | course_header_key | course_header_id | One row per course |
| dim_offering | offering_key | offering_id | One row per offering |
| dim_student | student_key | student_id | One row per student |
| dim_student_detail | student_detail_key | student_detail_id | One row per student per year |
| dim_prior_attainment | prior_attainment_key | average_gcse_id | One row per student per year |
| dim_grade | grade_key | grade + grading_scale | One row per grade per scale |

### 4.2 Fact Table Grain and Measures

| Fact Table | Grain | Primary Measures |
|------------|-------|------------------|
| fct_enrolment | One row per student per offering | is_high_grade, is_pass, attendance_pct, enrolment_count |
| fct_alps_subject_performance | One row per subject per year | alps_band, alps_score, value_added_score, pass_rate_pct |
| fct_college_performance | One row per report type per year | avg_pass_rate_pct, avg_value_added_score |
| fct_subject_benchmark | One row per subject per report per year | pass_rate_pct, value_added_score, performance_quartile |
| fct_equity_gap | One row per demographic comparison per year | gap_grade_points, gap_trend |

### 4.3 External System Mapping

```mermaid
graph LR
    subgraph "Internal System"
        O[dim_offering]
    end

    subgraph "External Systems"
        ALPS[ALPS Reports]
        SD[Six Dimensions Reports]
        DFE[DfE Data]
    end

    subgraph "Mapping Table"
        XW[seed_subject_crosswalk]
    end

    O -->|course_header_id| XW
    XW -->|alps_subject_name| ALPS
    XW -->|six_dimensions_subject_name| SD
    XW -->|dfe_qualification_code| DFE

    style XW fill:#ffecb3
```

---

## 5. Partitioning and Clustering Strategy

### 5.1 Table Partitioning

| Table | Partition Column | Partition Type | Rationale |
|-------|------------------|----------------|-----------|
| fct_enrolment | academic_year_start_date | YEAR | Most queries filter by academic year |

### 5.2 Table Clustering

| Table | Cluster Columns | Rationale |
|-------|-----------------|-----------|
| fct_enrolment | offering_key, student_key | Common filter/join columns |
| fct_alps_subject_performance | academic_year_key, alps_subject_name | Subject-level analysis |
| fct_college_performance | academic_year_key, report_type | Report filtering |
| fct_subject_benchmark | academic_year_key, six_dimensions_subject_name | Subject benchmarking |
| fct_equity_gap | academic_year_key, dimension_name | JEDI dimension analysis |
