# Barton Peveril Sixth Form College - Data Model Diagrams

This document contains entity relationship diagrams, physical data models, and data flow diagrams for the data warehouse implementation.

## Table of Contents

1. [Source Schema](#1-source-schema)
   - [1.1 Entity Relationship Diagram](#11-entity-relationship-diagram)
   - [1.2 Physical Data Model](#12-physical-data-model)
2. [Warehouse Schema](#2-warehouse-schema)
   - [2.1 Entity Relationship Diagram](#21-entity-relationship-diagram)
   - [2.2 Physical Data Model](#22-physical-data-model)
3. [Data Flow Diagram](#3-data-flow-diagram)

---

## 1. Source Schema

The source schema captures data from operational systems including the ProSolution MIS, Focus prior attainment system, and external benchmarking providers (ALPS, Six Dimensions).

### 1.1 Entity Relationship Diagram

A logical entity relationship diagram showing core business entities, their attributes, and relationships. This diagram is database-agnostic and focuses on the business model.

```mermaid
erDiagram
    STUDENT {
        string student_id PK "Unique student identifier"
        string uln "Unique Learner Number"
        string first_name "Student first name"
        string last_name "Student last name"
        date date_of_birth "Date of birth"
        string email "Contact email"
        string gender "Male or Female"
        string ethnicity "Ethnicity description"
        boolean is_active "Currently enrolled"
        datetime created_at "First registration date"
        datetime updated_at "Last modification date"
    }

    STUDENT_DETAIL {
        string student_detail_id PK "Detail record identifier"
        string student_id FK "Reference to student"
        string academic_year_id FK "Academic year context"
        string postcode "Home postcode"
        string lldd_code "Learning difficulty code"
        boolean is_send "Has special educational needs"
        boolean is_high_needs "High needs funding"
        boolean is_free_meals "Free school meals eligible"
        boolean is_bursary "Receives bursary"
        boolean is_lac "Looked after child"
        string primary_send_type "Primary SEND category"
        string secondary_send_type "Secondary SEND category"
    }

    STUDENT_EXTENDED_DATA {
        string student_extended_id PK "Extended data identifier"
        string student_id FK "Reference to student"
        string academic_year_id FK "Academic year context"
        string nationality "Student nationality"
        string country_of_birth "Birth country"
        string first_language "Home language"
        string religion "Religious affiliation"
        boolean is_young_carer "Young carer status"
        boolean is_parent_carer "Parent or carer status"
        string care_leaver_status "Care leaver category"
        integer imd_decile "Deprivation index 1-10"
        integer polar4_quintile "HE participation quintile"
        string tundra_classification "TUNDRA category"
    }

    PRIOR_ATTAINMENT {
        string average_gcse_id PK "Prior attainment identifier"
        string student_id FK "Reference to student"
        string academic_year_id FK "Academic year context"
        decimal average_gcse_score "Mean GCSE point score"
        string gcse_english_grade "English GCSE grade"
        string gcse_maths_grade "Maths GCSE grade"
        integer gcse_count "Number of GCSEs taken"
        string data_source "Source of GCSE data"
    }

    COURSE {
        string course_header_id PK "Course identifier"
        string code "Course code"
        string name "Course name"
        string description "Course description"
        string subject_area "Subject classification"
        string department "Academic department"
        string faculty "Faculty grouping"
        boolean is_active "Currently offered"
    }

    OFFERING_TYPE {
        string offering_type_id PK "Type identifier"
        string name "Type name"
        string description "Type description"
        string category "Academic or Vocational"
        string qualification_level "Level 3 etc"
    }

    OFFERING {
        string offering_id PK "Offering identifier"
        string course_header_id FK "Reference to course"
        string offering_type_id FK "Reference to type"
        string academic_year_id "Academic year"
        string code "Offering code"
        string name "Offering name"
        string qual_id "Qualification ID"
        integer study_year "Year of study 1 or 2"
        integer duration "Programme duration years"
        date start_date "Start date"
        date end_date "End date"
        boolean is_active "Currently running"
    }

    COMPLETION_STATUS {
        string completion_status_id PK "Status identifier"
        string name "Status name"
        string description "Status description"
        boolean is_completed "Completed learning"
        boolean is_continuing "Still enrolled"
        boolean is_withdrawn "Withdrew from course"
    }

    ENROLMENT {
        string enrolment_id PK "Enrolment identifier"
        string student_id FK "Reference to student"
        string offering_id FK "Reference to offering"
        string completion_status_id FK "Reference to status"
        date enrolment_date "Date enrolled"
        date expected_end_date "Planned completion"
        date actual_end_date "Actual completion"
        string target_grade "Target grade"
        string predicted_grade "Predicted grade"
        string actual_grade "Achieved grade"
        decimal attendance_pct "Attendance percentage"
        boolean is_current "Current enrolment"
    }

    ALPS_SUBJECT_REPORT {
        string alps_report_id PK "Report identifier"
        string academic_year "Academic year"
        string subject_name "ALPS subject name"
        string qualification_type "Qualification type"
        integer student_count "Cohort size"
        decimal average_gcse_on_entry "Entry GCSE score"
        integer alps_grade "ALPS band 1-9"
        decimal alps_score "ALPS score"
        decimal value_added_score "Value added measure"
        string national_benchmark_grade "National benchmark"
        decimal pass_rate_pct "Pass rate"
        decimal high_grades_pct "High grade rate"
        date report_date "Report generation date"
    }

    SIX_DIMENSIONS_SUBJECT_REPORT {
        string report_id PK "Report identifier"
        string academic_year "Academic year"
        string report_type "Report type"
        string subject_name "Subject name"
        string qualification_type "Qualification type"
        integer student_count "Cohort size"
        decimal value_added_score "VA score"
        decimal pass_rate_pct "Pass rate"
        decimal high_grades_pct "High grade rate"
        decimal completion_rate_pct "Completion rate"
        decimal achievement_rate_pct "Achievement rate"
        string performance_band "Performance category"
        string performance_quartile "Quartile ranking"
        date report_date "Report date"
    }

    EQUITY_GAP_REPORT {
        string jedi_report_id PK "JEDI report identifier"
        string academic_year "Academic year"
        string report_type "Report type"
        string dimension_name "Gender Ethnicity SEND etc"
        string student_group "Group being analysed"
        string comparison_group "Comparison group"
        integer student_count "Group size"
        integer comparison_count "Comparison size"
        decimal student_avg_grade_points "Group grade points"
        decimal comparison_avg_grade_points "Comparison grade points"
        decimal gap_grade_points "Performance gap"
        string gap_significance "Statistical significance"
        string performance_band "Performance category"
        date report_date "Report date"
    }

    GRADE_REFERENCE {
        string grade PK "Grade value"
        string qualification_type PK "Grading scale"
        integer ucas_points "UCAS tariff points"
        integer grade_points "Internal points"
        integer grade_sort_order "Display order"
        boolean is_pass "Is passing grade"
        boolean is_high_grade "Is high grade"
    }

    SUBJECT_CROSSWALK {
        string course_header_id FK "Internal course ID"
        string offering_code "Internal offering code"
        string prosolution_subject_name "ProSolution name"
        string alps_subject_name "ALPS subject name"
        string six_dimensions_subject_name "Six Dims name"
        string dfe_qualification_code "DfE code"
        decimal match_confidence_pct "Match confidence"
        boolean is_verified "Manually verified"
    }

    %% Core relationships
    STUDENT ||--o{ STUDENT_DETAIL : "has yearly details"
    STUDENT ||--o| STUDENT_EXTENDED_DATA : "has extended demographics"
    STUDENT ||--o{ PRIOR_ATTAINMENT : "has prior attainment"
    STUDENT ||--o{ ENROLMENT : "enrolls in"

    COURSE ||--o{ OFFERING : "has offerings"
    OFFERING_TYPE ||--o{ OFFERING : "categorizes"
    OFFERING ||--o{ ENROLMENT : "has enrolments"
    COMPLETION_STATUS ||--o{ ENROLMENT : "status of"

    %% Reference relationships
    COURSE ||--o| SUBJECT_CROSSWALK : "maps to external"
```

### 1.2 Physical Data Model

A physical data model for Google BigQuery showing tables, columns, data types, primary keys, foreign keys, and constraints reflecting the actual implementation.

#### 1.2.1 ProSolution Core Tables

```mermaid
erDiagram
    raw_prosolution_student {
        INT64 student_id PK "NOT NULL - Primary Key"
        STRING uln "Nullable - ULN"
        STRING first_name "Nullable"
        STRING last_name "Nullable"
        DATE date_of_birth "Nullable"
        STRING email "Nullable"
        STRING gender "Nullable - Gender value"
        STRING ethnicity "Nullable"
        BOOL is_active "Nullable - Default TRUE"
        TIMESTAMP created_at "Nullable"
        TIMESTAMP updated_at "Nullable"
        TIMESTAMP _sdc_extracted_at "Nullable - ETL metadata"
        TIMESTAMP _sdc_received_at "Nullable - ETL metadata"
        TIMESTAMP _sdc_batched_at "Nullable - ETL metadata"
        TIMESTAMP _sdc_deleted_at "Nullable - Soft delete"
    }

    raw_prosolution_student_detail {
        INT64 student_detail_id PK "NOT NULL - Primary Key"
        INT64 student_id FK "NOT NULL - FK to student"
        STRING academic_year_id FK "Nullable - Year ID"
        STRING postcode "Nullable"
        STRING lldd_code "Nullable"
        BOOL is_send "Nullable"
        BOOL is_high_needs "Nullable"
        BOOL is_free_meals "Nullable"
        BOOL is_bursary "Nullable"
        BOOL is_lac "Nullable"
        STRING primary_send_type "Nullable"
        STRING secondary_send_type "Nullable"
        TIMESTAMP _sdc_extracted_at "Nullable"
        TIMESTAMP _sdc_received_at "Nullable"
        TIMESTAMP _sdc_batched_at "Nullable"
        TIMESTAMP _sdc_deleted_at "Nullable"
    }

    raw_prosolution_course_header {
        INT64 course_header_id PK "NOT NULL - Primary Key"
        STRING code "Nullable - Course code"
        STRING name "Nullable - Course name"
        STRING description "Nullable"
        STRING subject_area "Nullable"
        STRING department "Nullable"
        STRING faculty "Nullable"
        BOOL is_active "Nullable"
        TIMESTAMP _sdc_extracted_at "Nullable"
        TIMESTAMP _sdc_received_at "Nullable"
        TIMESTAMP _sdc_batched_at "Nullable"
        TIMESTAMP _sdc_deleted_at "Nullable"
    }

    raw_prosolution_offering_type {
        INT64 offering_type_id PK "NOT NULL - Primary Key"
        STRING name "Nullable"
        STRING description "Nullable"
        STRING category "Nullable - Category"
        STRING qualification_level "Nullable - Level 3"
        TIMESTAMP _sdc_extracted_at "Nullable"
        TIMESTAMP _sdc_received_at "Nullable"
        TIMESTAMP _sdc_batched_at "Nullable"
        TIMESTAMP _sdc_deleted_at "Nullable"
    }

    raw_prosolution_offering {
        INT64 offering_id PK "NOT NULL - Primary Key"
        INT64 course_header_id FK "Nullable - FK to course_header"
        INT64 offering_type_id FK "Nullable - FK to offering_type"
        STRING academic_year_id "Nullable - Year ID"
        STRING code "Nullable"
        STRING name "Nullable"
        STRING qual_id "Nullable"
        INT64 study_year "Nullable - 1 or 2"
        INT64 duration "Nullable - Years"
        DATE start_date "Nullable"
        DATE end_date "Nullable"
        INT64 planned_hours "Nullable"
        BOOL is_active "Nullable"
        TIMESTAMP _sdc_extracted_at "Nullable"
        TIMESTAMP _sdc_received_at "Nullable"
        TIMESTAMP _sdc_batched_at "Nullable"
        TIMESTAMP _sdc_deleted_at "Nullable"
    }

    raw_prosolution_completion_status {
        INT64 completion_status_id PK "NOT NULL - Primary Key"
        STRING name "Nullable"
        STRING description "Nullable"
        BOOL is_completed "Nullable"
        BOOL is_continuing "Nullable"
        BOOL is_withdrawn "Nullable"
        TIMESTAMP _sdc_extracted_at "Nullable"
        TIMESTAMP _sdc_received_at "Nullable"
        TIMESTAMP _sdc_batched_at "Nullable"
        TIMESTAMP _sdc_deleted_at "Nullable"
    }

    raw_prosolution_enrolment {
        INT64 enrolment_id PK "NOT NULL - Primary Key"
        INT64 student_id FK "NOT NULL - FK to student"
        INT64 offering_id FK "NOT NULL - FK to offering"
        INT64 completion_status_id FK "Nullable - FK to completion_status"
        DATE enrolment_date "Nullable"
        DATE expected_end_date "Nullable"
        DATE actual_end_date "Nullable"
        STRING target_grade "Nullable"
        STRING predicted_grade "Nullable"
        STRING actual_grade "Nullable"
        NUMERIC attendance_pct "Nullable - 0-100"
        BOOL is_current "Nullable"
        TIMESTAMP _sdc_extracted_at "Nullable"
        TIMESTAMP _sdc_received_at "Nullable"
        TIMESTAMP _sdc_batched_at "Nullable"
        TIMESTAMP _sdc_deleted_at "Nullable"
    }

    raw_prosolution_student ||--o{ raw_prosolution_student_detail : "student_id"
    raw_prosolution_student ||--o{ raw_prosolution_enrolment : "student_id"
    raw_prosolution_course_header ||--o{ raw_prosolution_offering : "course_header_id"
    raw_prosolution_offering_type ||--o{ raw_prosolution_offering : "offering_type_id"
    raw_prosolution_offering ||--o{ raw_prosolution_enrolment : "offering_id"
    raw_prosolution_completion_status ||--o{ raw_prosolution_enrolment : "completion_status_id"
```

#### 1.2.2 External Source Tables

```mermaid
erDiagram
    raw_mis_applications_student_extended_data {
        INT64 student_extended_id PK "NOT NULL - Primary Key"
        INT64 student_id FK "NOT NULL - FK to student"
        STRING academic_year_id "Nullable"
        STRING nationality "Nullable"
        STRING country_of_birth "Nullable"
        STRING first_language "Nullable"
        STRING religion "Nullable"
        BOOL is_young_carer "Nullable"
        BOOL is_parent_carer "Nullable"
        STRING care_leaver_status "Nullable"
        STRING asylum_seeker_status "Nullable"
        STRING armed_forces_status "Nullable"
        STRING household_situation "Nullable"
        INT64 imd_decile "Nullable - 1-10"
        INT64 polar4_quintile "Nullable - 1-5"
        STRING tundra_classification "Nullable"
        TIMESTAMP _sdc_extracted_at "Nullable"
        TIMESTAMP _sdc_received_at "Nullable"
        TIMESTAMP _sdc_batched_at "Nullable"
        TIMESTAMP _sdc_deleted_at "Nullable"
    }

    raw_focus_average_gcse {
        INT64 average_gcse_id PK "NOT NULL - Primary Key"
        INT64 student_id FK "NOT NULL - FK to student"
        STRING academic_year_id "Nullable"
        NUMERIC average_gcse_score "Nullable - NUMERIC(8,2)"
        STRING gcse_english_grade "Nullable"
        STRING gcse_maths_grade "Nullable"
        INT64 gcse_count "Nullable"
        STRING data_source "Nullable"
        TIMESTAMP _sdc_extracted_at "Nullable"
        TIMESTAMP _sdc_received_at "Nullable"
        TIMESTAMP _sdc_batched_at "Nullable"
        TIMESTAMP _sdc_deleted_at "Nullable"
    }

    raw_alps_provider_report_a_level {
        INT64 alps_report_id PK "NOT NULL - Primary Key"
        STRING academic_year "NOT NULL"
        STRING subject_name "NOT NULL"
        INT64 student_count "Nullable"
        NUMERIC average_gcse_on_entry "Nullable - NUMERIC(8,2)"
        INT64 alps_grade "Nullable - 1-9"
        NUMERIC alps_score "Nullable - NUMERIC(5,2)"
        NUMERIC value_added_score "Nullable - NUMERIC(5,2)"
        STRING national_benchmark_grade "Nullable"
        NUMERIC pass_rate_pct "Nullable - NUMERIC(5,2)"
        NUMERIC high_grades_pct "Nullable - NUMERIC(5,2)"
        DATE report_date "Nullable"
        TIMESTAMP _sdc_extracted_at "Nullable"
        TIMESTAMP _sdc_received_at "Nullable"
        TIMESTAMP _sdc_batched_at "Nullable"
        TIMESTAMP _sdc_deleted_at "Nullable"
    }

    raw_alps_provider_report_btec {
        INT64 alps_btec_report_id PK "NOT NULL - Primary Key"
        STRING academic_year "NOT NULL"
        STRING subject_name "NOT NULL"
        STRING qualification_type "Nullable"
        INT64 student_count "Nullable"
        NUMERIC average_gcse_on_entry "Nullable - NUMERIC(8,2)"
        INT64 alps_grade "Nullable"
        NUMERIC alps_score "Nullable - NUMERIC(5,2)"
        NUMERIC value_added_score "Nullable - NUMERIC(5,2)"
        STRING national_benchmark_grade "Nullable"
        NUMERIC pass_rate_pct "Nullable - NUMERIC(5,2)"
        NUMERIC high_grades_pct "Nullable - NUMERIC(5,2)"
        DATE report_date "Nullable"
        TIMESTAMP _sdc_extracted_at "Nullable"
        TIMESTAMP _sdc_received_at "Nullable"
        TIMESTAMP _sdc_batched_at "Nullable"
        TIMESTAMP _sdc_deleted_at "Nullable"
    }

    raw_six_dimensions_va_report {
        INT64 va_report_id PK "NOT NULL - Primary Key"
        STRING academic_year "NOT NULL"
        STRING subject_name "Nullable"
        STRING qualification_type "Nullable"
        INT64 student_count "Nullable"
        NUMERIC average_gcse_on_entry "Nullable - NUMERIC(8,2)"
        NUMERIC value_added_score "Nullable - NUMERIC(8,4)"
        NUMERIC residual_score "Nullable - NUMERIC(8,4)"
        STRING expected_grade "Nullable"
        STRING actual_avg_grade "Nullable"
        STRING performance_band "Nullable"
        NUMERIC confidence_interval_lower "Nullable - NUMERIC(8,4)"
        NUMERIC confidence_interval_upper "Nullable - NUMERIC(8,4)"
        DATE report_date "Nullable"
        TIMESTAMP _sdc_extracted_at "Nullable"
        TIMESTAMP _sdc_received_at "Nullable"
        TIMESTAMP _sdc_batched_at "Nullable"
        TIMESTAMP _sdc_deleted_at "Nullable"
    }

    raw_six_dimensions_sixth_sense_report {
        INT64 sixth_sense_id PK "NOT NULL - Primary Key"
        STRING academic_year "NOT NULL"
        STRING subject_name "Nullable"
        STRING qualification_type "Nullable"
        INT64 student_count "Nullable"
        NUMERIC completion_rate_pct "Nullable - NUMERIC(5,2)"
        NUMERIC retention_rate_pct "Nullable - NUMERIC(5,2)"
        NUMERIC achievement_rate_pct "Nullable - NUMERIC(5,2)"
        NUMERIC pass_rate_pct "Nullable - NUMERIC(5,2)"
        NUMERIC high_grades_pct "Nullable - NUMERIC(5,2)"
        NUMERIC attendance_rate_pct "Nullable - NUMERIC(5,2)"
        NUMERIC national_completion_pct "Nullable - NUMERIC(5,2)"
        NUMERIC national_achievement_pct "Nullable - NUMERIC(5,2)"
        NUMERIC national_pass_pct "Nullable - NUMERIC(5,2)"
        STRING performance_quartile "Nullable"
        DATE report_date "Nullable"
        TIMESTAMP _sdc_extracted_at "Nullable"
        TIMESTAMP _sdc_received_at "Nullable"
        TIMESTAMP _sdc_batched_at "Nullable"
        TIMESTAMP _sdc_deleted_at "Nullable"
    }

    raw_six_dimensions_vocational_report {
        INT64 vocational_report_id PK "NOT NULL - Primary Key"
        STRING academic_year "NOT NULL"
        STRING subject_name "Nullable"
        STRING qualification_type "Nullable"
        STRING qualification_size "Nullable"
        INT64 student_count "Nullable"
        NUMERIC average_gcse_on_entry "Nullable - NUMERIC(8,2)"
        NUMERIC completion_rate_pct "Nullable - NUMERIC(5,2)"
        NUMERIC achievement_rate_pct "Nullable - NUMERIC(5,2)"
        NUMERIC pass_rate_pct "Nullable - NUMERIC(5,2)"
        NUMERIC distinction_star_pct "Nullable - NUMERIC(5,2)"
        NUMERIC distinction_pct "Nullable - NUMERIC(5,2)"
        NUMERIC merit_pct "Nullable - NUMERIC(5,2)"
        NUMERIC pass_pct "Nullable - NUMERIC(5,2)"
        NUMERIC near_pass_pct "Nullable - NUMERIC(5,2)"
        NUMERIC fail_pct "Nullable - NUMERIC(5,2)"
        NUMERIC national_achievement_pct "Nullable - NUMERIC(5,2)"
        NUMERIC national_distinction_plus_pct "Nullable - NUMERIC(5,2)"
        STRING performance_band "Nullable"
        DATE report_date "Nullable"
        TIMESTAMP _sdc_extracted_at "Nullable"
        TIMESTAMP _sdc_received_at "Nullable"
        TIMESTAMP _sdc_batched_at "Nullable"
        TIMESTAMP _sdc_deleted_at "Nullable"
    }

    raw_six_dimensions_jedi_report {
        INT64 jedi_report_id PK "NOT NULL - Primary Key"
        STRING academic_year "NOT NULL"
        STRING report_type "Nullable"
        STRING dimension_name "NOT NULL"
        STRING student_group "NOT NULL"
        STRING comparison_group "Nullable"
        INT64 student_count "Nullable"
        INT64 comparison_count "Nullable"
        NUMERIC student_avg_grade_points "Nullable - NUMERIC(8,2)"
        NUMERIC comparison_avg_grade_points "Nullable - NUMERIC(8,2)"
        NUMERIC gap_grade_points "Nullable - NUMERIC(8,2)"
        STRING gap_significance "Nullable"
        STRING performance_band "Nullable"
        DATE report_date "Nullable"
        TIMESTAMP _sdc_extracted_at "Nullable"
        TIMESTAMP _sdc_received_at "Nullable"
        TIMESTAMP _sdc_batched_at "Nullable"
        TIMESTAMP _sdc_deleted_at "Nullable"
    }
```

#### 1.2.3 Seed Reference Tables

```mermaid
erDiagram
    seed_grade_points {
        STRING grade PK "NOT NULL - Composite PK"
        STRING qualification_type PK "NOT NULL - Composite PK"
        INT64 ucas_points "Nullable"
        INT64 grade_points "Nullable"
        INT64 grade_sort_order "Nullable"
        BOOL is_pass "Nullable"
        BOOL is_high_grade "Nullable"
    }

    seed_subject_crosswalk {
        INT64 course_header_id FK "Nullable - FK to course_header"
        STRING offering_code "Nullable"
        STRING prosolution_subject_name "Nullable"
        STRING alps_subject_name "Nullable"
        STRING alps_qualification_type "Nullable"
        STRING six_dimensions_subject_name "Nullable"
        STRING dfe_qualification_code "Nullable"
        STRING dfe_subject_name "Nullable"
        STRING mapping_method "Nullable - Mapping method"
        NUMERIC match_confidence_pct "Nullable - 0-100"
        BOOL is_verified "Nullable"
        STRING verified_by "Nullable"
        DATE verified_date "Nullable"
    }
```

---

## 2. Warehouse Schema

The warehouse schema implements a dimensional model (star schema) optimized for analytical queries and reporting on student performance, benchmarking, and equity analysis.

### 2.1 Entity Relationship Diagram

A logical entity relationship diagram showing the dimensional model with fact and dimension entities, their attributes, and relationships. This diagram is database-agnostic and focuses on the analytical business model.

```mermaid
erDiagram
    ACADEMIC_YEAR {
        string academic_year_key PK "Surrogate key"
        string academic_year_id NK "Natural key"
        string academic_year_name "Display name"
        date academic_year_start_date "Sept 1 start"
        date academic_year_end_date "Aug 31 end"
        integer calendar_year_start "Start year"
        integer calendar_year_end "End year"
        boolean is_current_year "Current year flag"
        integer years_from_current "Years from current"
    }

    OFFERING_TYPE {
        string offering_type_key PK "Surrogate key"
        string offering_type_id NK "Natural key"
        string offering_type_name "Type name"
        string offering_type_category "Academic or Vocational"
        string qualification_level "Level 3"
        string grading_scale "Grading scale"
        boolean is_academic "Academic flag"
        boolean is_vocational "Vocational flag"
    }

    COURSE_HEADER {
        string course_header_key PK "Surrogate key"
        string course_header_id NK "Natural key"
        string course_code "Course code"
        string course_name "Course name"
        string subject_area "Subject grouping"
        string department "Department"
        boolean is_active "Active flag"
    }

    OFFERING {
        string offering_key PK "Surrogate key"
        string offering_id NK "Natural key"
        string academic_year_id FK "Year context"
        string offering_type_id FK "Type reference"
        string course_header_id FK "Course reference"
        string offering_code "Offering code"
        string offering_name "Offering name"
        string qualification_id "Qualification ID"
        integer study_year "Year 1 or 2"
        integer duration_years "Programme length"
        boolean is_final_year "Final year flag"
        string alps_subject_name "ALPS mapping"
        string six_dimensions_subject_name "Six Dims mapping"
        string dfe_qualification_code "DfE code"
    }

    STUDENT {
        string student_key PK "Surrogate key"
        string student_id NK "Natural key"
        string uln "Unique Learner Number"
        string first_name "First name"
        string last_name "Last name"
        string full_name "Full name"
        date date_of_birth "DOB"
        string gender "Gender"
        string ethnicity "Ethnicity"
        boolean is_active "Active student"
        datetime first_enrolment_date "First enrolment"
        date valid_from_date "SCD2 start"
        date valid_to_date "SCD2 end"
        boolean is_current "Current version"
    }

    STUDENT_DETAIL {
        string student_detail_key PK "Surrogate key"
        string student_detail_id NK "Natural key"
        string student_id FK "Student reference"
        string academic_year_id FK "Year context"
        string full_name "Full name"
        string gender "Gender"
        string ethnicity "Ethnicity"
        boolean is_free_meals "FSM flag"
        boolean is_bursary "Bursary flag"
        boolean is_lac "LAC flag"
        boolean is_send "SEND flag"
        boolean is_high_needs "High needs flag"
        boolean is_young_carer "Young carer flag"
        string primary_send_type "SEND type"
        string postcode_area "Postcode area"
        integer imd_decile "IMD 1-10"
        integer polar4_quintile "POLAR4 1-5"
        string nationality "Nationality"
        string first_language "First language"
        decimal average_gcse_score "GCSE score"
        string prior_attainment_band "Low Mid High"
    }

    PRIOR_ATTAINMENT {
        string prior_attainment_key PK "Surrogate key"
        string average_gcse_id NK "Natural key"
        string student_id FK "Student reference"
        string academic_year_id FK "Year context"
        decimal average_gcse_score "Mean GCSE score"
        string prior_attainment_band "Band Low Mid High"
        integer prior_attainment_band_code "Band code 1-3"
        decimal low_threshold "Low band threshold"
        decimal high_threshold "High band threshold"
        integer gcse_english_grade "English grade"
        integer gcse_maths_grade "Maths grade"
        integer gcse_count "GCSE count"
    }

    GRADE {
        string grade_key PK "Surrogate key"
        string grade NK "Grade value"
        string grading_scale NK "Grading scale"
        integer ucas_points "UCAS points"
        integer grade_points "Internal points"
        integer grade_sort_order "Sort order"
        boolean is_high_grade "High grade flag"
        boolean is_pass_grade "Pass grade flag"
        boolean is_grade_a_star_to_a "Top two grades"
        boolean is_grade_a_star_to_b "Top three grades"
        boolean is_grade_a_star_to_c "Top four grades"
        boolean is_grade_a_star_to_e "Pass grades"
    }

    ENROLMENT_FACT {
        string enrolment_key PK "Surrogate key"
        string academic_year_key FK "Dim reference"
        string offering_type_key FK "Dim reference"
        string course_header_key FK "Dim reference"
        string offering_key FK "Dim reference"
        string student_key FK "Dim reference"
        string student_detail_key FK "Dim reference"
        string prior_attainment_key FK "Dim reference"
        string grade_key FK "Dim reference"
        string grade "Achieved grade"
        string target_grade "Target grade"
        string predicted_grade "Predicted grade"
        integer is_grade_a_star "Top grade count"
        integer is_grade_a "Grade A count"
        integer is_grade_b "Grade B count"
        integer is_high_grade "High grade count"
        integer is_pass "Pass count"
        decimal attendance_pct "Attendance"
        integer enrolment_count "Always 1"
        string completion_status "Status"
        boolean is_completed "Completed flag"
    }

    ALPS_SUBJECT_FACT {
        string alps_subject_performance_key PK "Surrogate key"
        string academic_year_key FK "Dim reference"
        string offering_key FK "Dim reference"
        string alps_subject_name "ALPS subject"
        string alps_qualification_type "Qualification type"
        string subject_mapping_status "Matched or Unmapped"
        decimal mapping_confidence_pct "Confidence 0-100"
        integer cohort_count "Cohort size"
        decimal average_gcse_on_entry "Entry GCSE"
        integer alps_band "ALPS band 1-9"
        decimal alps_score "ALPS score"
        decimal value_added_score "VA score"
        string national_benchmark_grade "Benchmark grade"
        decimal pass_rate_pct "Pass rate"
        decimal high_grades_pct "High grade rate"
    }

    COLLEGE_PERFORMANCE_FACT {
        string college_performance_key PK "Surrogate key"
        string academic_year_key FK "Dim reference"
        string report_type "Report type"
        string report_name "Report name"
        integer total_cohort_count "Total students"
        decimal avg_pass_rate_pct "Avg pass rate"
        decimal avg_high_grades_pct "Avg high grade rate"
        decimal avg_completion_rate_pct "Avg completion"
        decimal avg_retention_rate_pct "Avg retention"
        decimal avg_achievement_rate_pct "Avg achievement"
        decimal avg_attendance_rate_pct "Avg attendance"
        decimal avg_value_added_score "Avg VA"
    }

    SUBJECT_BENCHMARK_FACT {
        string subject_benchmark_key PK "Surrogate key"
        string academic_year_key FK "Dim reference"
        string offering_key FK "Dim reference"
        string report_type "Report type"
        string six_dimensions_subject_name "Subject name"
        string qualification_type "Qual type"
        string subject_mapping_status "Mapping status"
        integer cohort_count "Cohort size"
        decimal pass_rate_pct "Pass rate"
        decimal high_grades_pct "High grade rate"
        decimal value_added_score "VA score"
        string performance_band "Performance band"
        string performance_quartile "Quartile"
        string performance_trajectory "Trend"
        decimal yoy_change_pct "YoY change"
    }

    EQUITY_GAP_FACT {
        string equity_gap_key PK "Surrogate key"
        string academic_year_key FK "Dim reference"
        string report_type "Report type"
        string dimension_name "Gender Ethnicity etc"
        string student_group "Group analysed"
        string comparison_group "Comparison group"
        integer student_count "Group size"
        integer comparison_count "Comparison size"
        decimal student_avg_grade_points "Group grade pts"
        decimal comparison_avg_grade_points "Comparison pts"
        decimal gap_grade_points "Gap"
        string gap_significance "Significance"
        string performance_band "Band"
        decimal prior_year_gap "Prior gap"
        decimal gap_change_yoy "YoY change"
        string gap_trend "Narrowing Stable Widening"
    }

    %% Dimension relationships
    ACADEMIC_YEAR ||--o{ OFFERING : "year context"
    OFFERING_TYPE ||--o{ OFFERING : "categorizes"
    COURSE_HEADER ||--o{ OFFERING : "defines"
    STUDENT ||--o{ STUDENT_DETAIL : "yearly details"
    STUDENT ||--o{ PRIOR_ATTAINMENT : "attainment"

    %% Enrolment fact relationships
    ACADEMIC_YEAR ||--o{ ENROLMENT_FACT : "when"
    OFFERING_TYPE ||--o{ ENROLMENT_FACT : "what type"
    COURSE_HEADER ||--o{ ENROLMENT_FACT : "what course"
    OFFERING ||--o{ ENROLMENT_FACT : "what offering"
    STUDENT ||--o{ ENROLMENT_FACT : "who"
    STUDENT_DETAIL |o--o{ ENROLMENT_FACT : "demographics"
    PRIOR_ATTAINMENT |o--o{ ENROLMENT_FACT : "prior grades"
    GRADE |o--o{ ENROLMENT_FACT : "grade lookup"

    %% Benchmark fact relationships
    ACADEMIC_YEAR ||--o{ ALPS_SUBJECT_FACT : "when"
    OFFERING |o--o{ ALPS_SUBJECT_FACT : "mapping"
    ACADEMIC_YEAR ||--o{ COLLEGE_PERFORMANCE_FACT : "when"
    ACADEMIC_YEAR ||--o{ SUBJECT_BENCHMARK_FACT : "when"
    OFFERING |o--o{ SUBJECT_BENCHMARK_FACT : "mapping"
    ACADEMIC_YEAR ||--o{ EQUITY_GAP_FACT : "when"
```

### 2.2 Physical Data Model

A physical data model for Google BigQuery showing tables, columns, data types, primary keys, foreign keys, constraints, partitioning, and clustering reflecting the actual implementation.

#### 2.2.1 Dimension Tables

```mermaid
erDiagram
    dim_academic_year {
        INT64 academic_year_key PK "NOT NULL - Surrogate PK"
        STRING academic_year_id UK "NOT NULL - Natural Key"
        STRING academic_year_name "Nullable"
        DATE academic_year_start_date "Nullable"
        DATE academic_year_end_date "Nullable"
        INT64 calendar_year_start "Nullable"
        INT64 calendar_year_end "Nullable"
        BOOL is_current_year "Nullable"
        INT64 years_from_current "Nullable"
        STRING record_source "Nullable"
        TIMESTAMP loaded_at "Nullable"
    }

    dim_offering_type {
        INT64 offering_type_key PK "NOT NULL - Surrogate PK"
        INT64 offering_type_id UK "NOT NULL - Natural Key"
        STRING offering_type_name "Nullable"
        STRING offering_type_category "Nullable"
        STRING qualification_level "Nullable"
        STRING grading_scale "Nullable"
        BOOL is_academic "Nullable"
        BOOL is_vocational "Nullable"
        STRING record_source "Nullable"
        TIMESTAMP loaded_at "Nullable"
    }

    dim_course_header {
        INT64 course_header_key PK "NOT NULL - Surrogate PK"
        INT64 course_header_id UK "NOT NULL - Natural Key"
        STRING course_code "Nullable"
        STRING course_name "Nullable"
        STRING subject_area "Nullable"
        STRING department "Nullable"
        BOOL is_active "Nullable"
        STRING record_source "Nullable"
        TIMESTAMP loaded_at "Nullable"
    }

    dim_offering {
        INT64 offering_key PK "NOT NULL - Surrogate PK"
        INT64 offering_id UK "NOT NULL - Natural Key"
        STRING offering_code "Nullable"
        STRING offering_name "Nullable"
        STRING qualification_id "Nullable"
        INT64 study_year "Nullable"
        INT64 duration_years "Nullable"
        BOOL is_final_year "Nullable"
        STRING academic_year_id FK "Nullable - FK to dim_academic_year"
        INT64 offering_type_id FK "Nullable - FK to dim_offering_type"
        INT64 course_header_id FK "Nullable - FK to dim_course_header"
        STRING dfe_qualification_code "Nullable"
        STRING alps_subject_name "Nullable - For ALPS join"
        STRING six_dimensions_subject_name "Nullable - For Six Dims join"
        STRING record_source "Nullable"
        TIMESTAMP loaded_at "Nullable"
    }

    dim_student {
        INT64 student_key PK "NOT NULL - Surrogate PK"
        INT64 student_id UK "NOT NULL - Natural Key"
        STRING uln "Nullable"
        STRING first_name "Nullable"
        STRING last_name "Nullable"
        STRING full_name "Nullable"
        DATE date_of_birth "Nullable"
        STRING gender "Nullable"
        STRING ethnicity "Nullable"
        BOOL is_active "Nullable"
        TIMESTAMP first_enrolment_date "Nullable"
        DATE valid_from_date "Nullable - SCD2"
        DATE valid_to_date "Nullable - SCD2"
        BOOL is_current "Nullable - SCD2"
        STRING record_source "Nullable"
        TIMESTAMP loaded_at "Nullable"
    }

    dim_student_detail {
        INT64 student_detail_key PK "NOT NULL - Surrogate PK"
        INT64 student_detail_id UK "NOT NULL - Natural Key"
        INT64 student_id FK "Nullable - FK to dim_student"
        STRING academic_year_id FK "Nullable - FK to dim_academic_year"
        STRING full_name "Nullable"
        STRING gender "Nullable"
        STRING ethnicity "Nullable"
        BOOL is_free_meals "Nullable"
        BOOL is_bursary "Nullable"
        BOOL is_lac "Nullable"
        BOOL is_send "Nullable"
        BOOL is_high_needs "Nullable"
        BOOL is_young_carer "Nullable"
        STRING primary_send_type "Nullable"
        STRING secondary_send_type "Nullable"
        STRING postcode_area "Nullable"
        INT64 imd_decile "Nullable"
        INT64 polar4_quintile "Nullable"
        STRING tundra_classification "Nullable"
        STRING nationality "Nullable"
        STRING country_of_birth "Nullable"
        STRING first_language "Nullable"
        STRING religion "Nullable"
        NUMERIC average_gcse_score "Nullable"
        STRING prior_attainment_band "Nullable"
        STRING record_source "Nullable"
        TIMESTAMP loaded_at "Nullable"
    }

    dim_prior_attainment {
        INT64 prior_attainment_key PK "NOT NULL - Surrogate PK"
        INT64 average_gcse_id UK "NOT NULL - Natural Key"
        INT64 student_id FK "NOT NULL - FK to dim_student"
        STRING academic_year_id FK "Nullable - FK to dim_academic_year"
        NUMERIC average_gcse_score "Nullable"
        STRING prior_attainment_band "Nullable"
        INT64 prior_attainment_band_code "Nullable"
        NUMERIC low_threshold "Nullable"
        NUMERIC high_threshold "Nullable"
        INT64 gcse_english_grade "Nullable"
        INT64 gcse_maths_grade "Nullable"
        INT64 gcse_count "Nullable"
        STRING record_source "Nullable"
        TIMESTAMP loaded_at "Nullable"
    }

    dim_grade {
        INT64 grade_key PK "NOT NULL - Surrogate PK"
        STRING grade UK "NOT NULL - Composite NK"
        STRING grading_scale UK "NOT NULL - Composite NK"
        INT64 ucas_points "Nullable"
        INT64 grade_points "Nullable"
        INT64 grade_sort_order "Nullable"
        BOOL is_high_grade "Nullable"
        BOOL is_pass_grade "Nullable"
        BOOL is_grade_a_star_to_a "Nullable"
        BOOL is_grade_a_star_to_b "Nullable"
        BOOL is_grade_a_star_to_c "Nullable"
        BOOL is_grade_a_star_to_e "Nullable"
        STRING record_source "Nullable"
        TIMESTAMP loaded_at "Nullable"
    }

    dim_academic_year ||--o{ dim_offering : "academic_year_id"
    dim_offering_type ||--o{ dim_offering : "offering_type_id"
    dim_course_header ||--o{ dim_offering : "course_header_id"
    dim_student ||--o{ dim_student_detail : "student_id"
    dim_student ||--o{ dim_prior_attainment : "student_id"
    dim_academic_year ||--o{ dim_student_detail : "academic_year_id"
    dim_academic_year ||--o{ dim_prior_attainment : "academic_year_id"
```

#### 2.2.2 Fact Tables

```mermaid
erDiagram
    fct_enrolment {
        INT64 enrolment_key PK "NOT NULL - Surrogate PK"
        INT64 academic_year_key FK "NOT NULL - FK to dim_academic_year"
        INT64 offering_type_key FK "NOT NULL - FK to dim_offering_type"
        INT64 course_header_key FK "NOT NULL - FK to dim_course_header"
        INT64 offering_key FK "NOT NULL - FK to dim_offering"
        INT64 student_key FK "NOT NULL - FK to dim_student"
        INT64 student_detail_key FK "Nullable - FK to dim_student_detail"
        INT64 prior_attainment_key FK "Nullable - FK to dim_prior_attainment"
        INT64 grade_key FK "Nullable - FK to dim_grade"
        STRING academic_year_id "Nullable - Degenerate dim"
        INT64 offering_id "Nullable - Degenerate dim"
        INT64 student_id "Nullable - Degenerate dim"
        INT64 student_detail_id "Nullable - Degenerate dim"
        DATE academic_year_start_date "Nullable - PARTITION KEY"
        INT64 completion_status_id "Nullable"
        STRING completion_status "Nullable"
        BOOL is_completed "Nullable"
        STRING grade "Nullable"
        STRING target_grade "Nullable"
        STRING predicted_grade "Nullable"
        INT64 is_grade_a_star "Nullable - 0 or 1"
        INT64 is_grade_a "Nullable - 0 or 1"
        INT64 is_grade_b "Nullable - 0 or 1"
        INT64 is_grade_c "Nullable - 0 or 1"
        INT64 is_grade_d "Nullable - 0 or 1"
        INT64 is_grade_e "Nullable - 0 or 1"
        INT64 is_grade_u "Nullable - 0 or 1"
        INT64 is_grade_distinction_star "Nullable - 0 or 1"
        INT64 is_grade_distinction "Nullable - 0 or 1"
        INT64 is_grade_merit "Nullable - 0 or 1"
        INT64 is_grade_pass "Nullable - 0 or 1"
        INT64 is_high_grade "Nullable - 0 or 1"
        INT64 is_pass "Nullable - 0 or 1"
        NUMERIC average_gcse_score "Nullable - Denormalized"
        STRING prior_attainment_band "Nullable - Denormalized"
        STRING gender "Nullable - Denormalized"
        STRING ethnicity "Nullable - Denormalized"
        BOOL is_send "Nullable - Denormalized"
        BOOL is_free_meals "Nullable - Denormalized"
        BOOL is_bursary "Nullable - Denormalized"
        BOOL is_lac "Nullable - Denormalized"
        BOOL is_young_carer "Nullable - Denormalized"
        NUMERIC attendance_pct "Nullable"
        INT64 enrolment_count "Nullable - Always 1"
        STRING record_source "Nullable"
        TIMESTAMP loaded_at "Nullable"
    }

    fct_alps_subject_performance {
        INT64 alps_subject_performance_key PK "NOT NULL - Surrogate PK"
        INT64 academic_year_key FK "NOT NULL - FK to dim_academic_year"
        INT64 offering_key FK "Nullable - FK to dim_offering"
        STRING alps_subject_name "NOT NULL"
        STRING alps_qualification_type "Nullable"
        STRING subject_mapping_status "Nullable"
        NUMERIC mapping_confidence_pct "Nullable"
        INT64 cohort_count "Nullable"
        NUMERIC average_gcse_on_entry "Nullable"
        INT64 alps_band "Nullable - 1-9"
        NUMERIC alps_score "Nullable"
        NUMERIC value_added_score "Nullable"
        STRING national_benchmark_grade "Nullable"
        NUMERIC pass_rate_pct "Nullable"
        NUMERIC high_grades_pct "Nullable"
        DATE alps_report_date "Nullable"
        STRING record_source "Nullable"
        TIMESTAMP loaded_at "Nullable"
    }

    fct_college_performance {
        INT64 college_performance_key PK "NOT NULL - Surrogate PK"
        INT64 academic_year_key FK "NOT NULL - FK to dim_academic_year"
        STRING report_type "Nullable"
        STRING report_name "Nullable"
        INT64 total_cohort_count "Nullable"
        NUMERIC avg_pass_rate_pct "Nullable"
        NUMERIC avg_high_grades_pct "Nullable"
        NUMERIC avg_completion_rate_pct "Nullable"
        NUMERIC avg_retention_rate_pct "Nullable"
        NUMERIC avg_achievement_rate_pct "Nullable"
        NUMERIC avg_attendance_rate_pct "Nullable"
        NUMERIC avg_value_added_score "Nullable"
        NUMERIC avg_confidence_lower "Nullable"
        NUMERIC avg_confidence_upper "Nullable"
        DATE report_date "Nullable"
        STRING record_source "Nullable"
        TIMESTAMP loaded_at "Nullable"
    }

    fct_subject_benchmark {
        INT64 subject_benchmark_key PK "NOT NULL - Surrogate PK"
        INT64 academic_year_key FK "NOT NULL - FK to dim_academic_year"
        INT64 offering_key FK "Nullable - FK to dim_offering"
        STRING report_type "Nullable"
        STRING six_dimensions_subject_name "NOT NULL"
        STRING qualification_type "Nullable"
        STRING subject_mapping_status "Nullable"
        NUMERIC mapping_confidence_pct "Nullable"
        INT64 cohort_count "Nullable"
        NUMERIC average_gcse_on_entry "Nullable"
        NUMERIC pass_rate_pct "Nullable"
        NUMERIC high_grades_pct "Nullable"
        NUMERIC completion_rate_pct "Nullable"
        NUMERIC achievement_rate_pct "Nullable"
        NUMERIC value_added_score "Nullable"
        NUMERIC residual_score "Nullable"
        STRING expected_grade "Nullable"
        STRING actual_avg_grade "Nullable"
        STRING performance_band "Nullable"
        NUMERIC confidence_interval_lower "Nullable"
        NUMERIC confidence_interval_upper "Nullable"
        STRING performance_quartile "Nullable"
        STRING performance_trajectory "Nullable"
        NUMERIC yoy_change_pct "Nullable"
        DATE report_date "Nullable"
        STRING record_source "Nullable"
        TIMESTAMP loaded_at "Nullable"
    }

    fct_equity_gap {
        INT64 equity_gap_key PK "NOT NULL - Surrogate PK"
        INT64 academic_year_key FK "NOT NULL - FK to dim_academic_year"
        STRING report_type "Nullable"
        STRING dimension_name "NOT NULL"
        STRING student_group "NOT NULL"
        STRING comparison_group "Nullable"
        INT64 student_count "Nullable"
        INT64 comparison_count "Nullable"
        NUMERIC student_avg_grade_points "Nullable"
        NUMERIC comparison_avg_grade_points "Nullable"
        NUMERIC gap_grade_points "Nullable"
        STRING gap_significance "Nullable"
        STRING performance_band "Nullable"
        NUMERIC prior_year_gap "Nullable"
        NUMERIC gap_change_yoy "Nullable"
        STRING gap_trend "Nullable"
        DATE report_date "Nullable"
        STRING record_source "Nullable"
        TIMESTAMP loaded_at "Nullable"
    }
```

#### 2.2.3 BigQuery Table Options

| Table | Partition | Cluster Columns | Description |
|-------|-----------|-----------------|-------------|
| fct_enrolment | `academic_year_start_date` (YEAR) | `offering_key`, `student_key` | Most queries filter by year, then by offering or student |
| fct_alps_subject_performance | None | `academic_year_key`, `alps_subject_name` | Subject-level analysis queries |
| fct_college_performance | None | `academic_year_key`, `report_type` | Report filtering |
| fct_subject_benchmark | None | `academic_year_key`, `six_dimensions_subject_name` | Subject benchmarking queries |
| fct_equity_gap | None | `academic_year_key`, `dimension_name` | JEDI dimension analysis |

---

## 3. Data Flow Diagram

### 3.1 Layer Architecture

High-level view of the dbt layer architecture showing data transformation flow from source systems to the warehouse.

```mermaid
graph TB
    subgraph "Source Systems"
        PS[("ProSolution<br/>MIS")]
        MA[("MIS Applications")]
        FO[("Focus")]
        AL[("ALPS PDFs")]
        SD[("Six Dimensions PDFs")]
    end

    subgraph "Raw Layer - Seeds"
        direction TB
        PS --> S1["raw_prosolution.*<br/>(7 tables)"]
        MA --> S2["raw_mis_applications.*<br/>(1 table)"]
        FO --> S3["raw_focus.*<br/>(1 table)"]
        AL --> S4["raw_alps.*<br/>(2 tables)"]
        SD --> S5["raw_six_dimensions.*<br/>(4 tables)"]
        REF["seed_grade_points<br/>seed_subject_crosswalk"]
    end

    subgraph "Staging Layer - Views"
        direction TB
        S1 --> STG1["stg_prosolution__*<br/>(7 views)"]
        S2 --> STG2["stg_mis_applications__*<br/>(1 view)"]
        S3 --> STG3["stg_focus__*<br/>(1 view)"]
        S4 --> STG4["stg_alps__*<br/>(2 views)"]
        S5 --> STG5["stg_six_dimensions__*<br/>(4 views)"]
    end

    subgraph "Intermediate Layer - Views"
        direction TB
        STG1 --> INT1["int_enrolment_with_context"]
        STG2 --> INT2["int_student_demographics_joined"]
        STG3 --> INT2
        STG4 --> INT3["int_alps_performance_unioned"]
        STG5 --> INT4["int_six_dimensions_subject_unioned"]
        STG5 --> INT5["int_six_dimensions_college_unioned"]
        STG1 --> INT2
    end

    subgraph "Marts Layer - Tables"
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

Detailed view showing specific model transformations and dependencies through each layer.

```mermaid
flowchart TB
    subgraph RAW["Raw Layer - dbt seeds"]
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

    subgraph STG["Staging Layer - views"]
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

    subgraph INT["Intermediate Layer - views"]
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

### 3.3 Model Execution Order

Simplified DAG showing the recommended dbt execution order.

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

    subgraph "Layer 3: Dimensions"
        DIM[dbt run --select marts.dimensions]
    end

    subgraph "Layer 4: Facts"
        FCT[dbt run --select marts.facts]
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

## 4. Summary Tables

### 4.1 Source Schema Entity Summary

| Entity | Description | Primary Key | Key Relationships |
|--------|-------------|-------------|-------------------|
| Student | Student master record | student_id | Has details, extended data, enrolments |
| Student Detail | Yearly demographic snapshot | student_detail_id | Belongs to Student, Academic Year |
| Student Extended Data | Additional demographics | student_extended_id | Belongs to Student |
| Prior Attainment | GCSE scores | average_gcse_id | Belongs to Student |
| Course | Programme definition | course_header_id | Has Offerings |
| Offering Type | Qualification type | offering_type_id | Categorizes Offerings |
| Offering | Course instance per year | offering_id | Belongs to Course, Type; Has Enrolments |
| Completion Status | Enrolment status codes | completion_status_id | Status of Enrolments |
| Enrolment | Student on course | enrolment_id | Links Student to Offering |
| ALPS Report | External benchmarking | alps_report_id | Subject performance |
| Six Dimensions Reports | External benchmarking | report_id | Subject/college/equity data |

### 4.2 Warehouse Schema Entity Summary

| Entity | Type | Grain | Primary Key | Key Measures/Attributes |
|--------|------|-------|-------------|------------------------|
| dim_academic_year | Dimension | One per year | academic_year_key | is_current_year, years_from_current |
| dim_offering_type | Dimension | One per type | offering_type_key | grading_scale, is_academic, is_vocational |
| dim_course_header | Dimension | One per course | course_header_key | course_name, subject_area, department |
| dim_offering | Dimension | One per offering | offering_key | alps_subject_name, six_dimensions_subject_name |
| dim_student | Dimension | One per student | student_key | full_name, gender, ethnicity |
| dim_student_detail | Dimension | One per student/year | student_detail_key | is_free_meals, is_send, imd_decile |
| dim_prior_attainment | Dimension | One per student/year | prior_attainment_key | average_gcse_score, prior_attainment_band |
| dim_grade | Dimension | One per grade/scale | grade_key | ucas_points, is_high_grade, is_pass_grade |
| fct_enrolment | Fact | One per enrolment | enrolment_key | is_high_grade, is_pass, attendance_pct |
| fct_alps_subject_performance | Fact | One per subject/year | alps_subject_performance_key | alps_band, value_added_score |
| fct_college_performance | Fact | One per report/year | college_performance_key | avg_pass_rate_pct, avg_value_added_score |
| fct_subject_benchmark | Fact | One per subject/report/year | subject_benchmark_key | pass_rate_pct, performance_quartile |
| fct_equity_gap | Fact | One per dimension/year | equity_gap_key | gap_grade_points, gap_trend |

### 4.3 Join Key Reference

| From Table | To Table | Join Key(s) | Cardinality |
|------------|----------|-------------|-------------|
| fct_enrolment | dim_academic_year | academic_year_key | Many:1 |
| fct_enrolment | dim_offering_type | offering_type_key | Many:1 |
| fct_enrolment | dim_course_header | course_header_key | Many:1 |
| fct_enrolment | dim_offering | offering_key | Many:1 |
| fct_enrolment | dim_student | student_key | Many:1 |
| fct_enrolment | dim_student_detail | student_detail_key | Many:0..1 |
| fct_enrolment | dim_prior_attainment | prior_attainment_key | Many:0..1 |
| fct_enrolment | dim_grade | grade_key | Many:0..1 |
| fct_alps_subject_performance | dim_academic_year | academic_year_key | Many:1 |
| fct_alps_subject_performance | dim_offering | offering_key | Many:0..1 |
| fct_subject_benchmark | dim_academic_year | academic_year_key | Many:1 |
| fct_subject_benchmark | dim_offering | offering_key | Many:0..1 |
| fct_college_performance | dim_academic_year | academic_year_key | Many:1 |
| fct_equity_gap | dim_academic_year | academic_year_key | Many:1 |
