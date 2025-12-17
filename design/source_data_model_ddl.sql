-- =====================================================================
-- Barton Peveril Sixth Form College - Source Data Model DDL
-- Google BigQuery Staging Layer
-- Version: 2.0 (Updated to match deployed seed/staging schemas)
-- =====================================================================
--
-- This DDL defines the source/staging layer tables that receive data
-- from the operational source systems before transformation into the
-- dimensional model.
--
-- Source Systems:
--   1. ProSolution (MIS) - Core student and course data
--   2. MISApplications   - Extended student demographics
--   3. Focus             - Prior attainment (GCSE) data
--   4. ALPS              - External benchmarking (parsed from PDF)
--   5. Six Dimensions    - External benchmarking (parsed from PDF)
--
-- dbt Layer: staging.*
-- Naming Convention: stg_<source>__<entity>
--
-- =====================================================================


-- =====================================================================
-- RAW LAYER: PROSOLUTION SOURCE TABLES
-- Schema: raw_prosolution
-- These tables mirror the source system structure (loaded via dbt seed)
-- =====================================================================

-- ---------------------------------------------------------------------
-- raw_prosolution.offering
-- Source: ProSolution.dbo.offering
-- Course/qualification offerings by academic year
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_prosolution.offering` (
    -- Primary key
    offering_id                     INT64 NOT NULL OPTIONS(description="Primary key - ProSolution OfferingID"),

    -- Foreign keys
    course_header_id                INT64 OPTIONS(description="FK to CourseHeader"),
    offering_type_id                INT64 OPTIONS(description="FK to OfferingType - 1=A-Level, 2=BTEC, etc."),
    academic_year_id                STRING OPTIONS(description="Academic year identifier, e.g., '23/24'"),

    -- Attributes
    code                            STRING OPTIONS(description="Offering code"),
    name                            STRING OPTIONS(description="Offering name/description"),
    qual_id                         STRING OPTIONS(description="Qualification identifier"),
    study_year                      INT64 OPTIONS(description="Current year of study (1, 2, etc.)"),
    duration                        INT64 OPTIONS(description="Total duration in years"),

    -- Dates
    start_date                      DATE OPTIONS(description="Offering start date"),
    end_date                        DATE OPTIONS(description="Offering end date"),
    planned_hours                   INT64 OPTIONS(description="Planned guided learning hours"),

    -- Flags
    is_active                       BOOL OPTIONS(description="Active offering flag"),

    -- Metadata
    _sdc_extracted_at               TIMESTAMP OPTIONS(description="Extraction timestamp"),
    _sdc_received_at                TIMESTAMP OPTIONS(description="Load timestamp"),
    _sdc_batched_at                 TIMESTAMP OPTIONS(description="Batch timestamp"),
    _sdc_deleted_at                 TIMESTAMP OPTIONS(description="Soft delete timestamp")
)
OPTIONS(
    description="Raw offering data from ProSolution MIS"
);


-- ---------------------------------------------------------------------
-- raw_prosolution.enrolment
-- Source: ProSolution.dbo.Enrolment
-- Student enrolments on offerings with grades
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_prosolution.enrolment` (
    -- Primary key
    enrolment_id                    INT64 NOT NULL OPTIONS(description="Primary key - ProSolution EnrolmentID"),

    -- Foreign keys
    student_id                      INT64 NOT NULL OPTIONS(description="FK to Student"),
    offering_id                     INT64 NOT NULL OPTIONS(description="FK to Offering"),
    completion_status_id            INT64 OPTIONS(description="FK to CompletionStatus - 1=Completed, 2=Continuing"),

    -- Dates
    enrolment_date                  DATE OPTIONS(description="Date of enrolment"),
    expected_end_date               DATE OPTIONS(description="Expected end date"),
    actual_end_date                 DATE OPTIONS(description="Actual end date if completed/withdrawn"),

    -- Grade attributes
    target_grade                    STRING OPTIONS(description="Target grade"),
    predicted_grade                 STRING OPTIONS(description="Predicted/target grade"),
    actual_grade                    STRING OPTIONS(description="Achieved grade (A*, A, B, C, D, E, U, D*, M, P, etc.)"),

    -- Attendance
    attendance_pct                  NUMERIC OPTIONS(description="Attendance percentage"),

    -- Status
    is_current                      BOOL OPTIONS(description="Current enrolment flag"),

    -- Metadata
    _sdc_extracted_at               TIMESTAMP,
    _sdc_received_at                TIMESTAMP,
    _sdc_batched_at                 TIMESTAMP,
    _sdc_deleted_at                 TIMESTAMP
)
OPTIONS(
    description="Raw enrolment data from ProSolution MIS"
);


-- ---------------------------------------------------------------------
-- raw_prosolution.student
-- Source: ProSolution.dbo.Student
-- Student master record
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_prosolution.student` (
    -- Primary key
    student_id                      INT64 NOT NULL OPTIONS(description="Primary key - ProSolution StudentID"),

    -- Unique identifiers
    uln                             STRING OPTIONS(description="Unique Learner Number"),

    -- Personal details
    first_name                      STRING OPTIONS(description="First name"),
    last_name                       STRING OPTIONS(description="Last name"),
    date_of_birth                   DATE OPTIONS(description="Date of birth"),
    email                           STRING OPTIONS(description="Email address"),

    -- Demographics
    gender                          STRING OPTIONS(description="Gender: 'Male', 'Female'"),
    ethnicity                       STRING OPTIONS(description="Ethnicity description"),

    -- Status
    is_active                       BOOL OPTIONS(description="Active student flag"),

    -- Dates
    created_at                      TIMESTAMP OPTIONS(description="Record creation timestamp"),
    updated_at                      TIMESTAMP OPTIONS(description="Record last updated timestamp"),

    -- Metadata
    _sdc_extracted_at               TIMESTAMP,
    _sdc_received_at                TIMESTAMP,
    _sdc_batched_at                 TIMESTAMP,
    _sdc_deleted_at                 TIMESTAMP
)
OPTIONS(
    description="Raw student master data from ProSolution MIS"
);


-- ---------------------------------------------------------------------
-- raw_prosolution.student_detail
-- Source: ProSolution.dbo.StudentDetail
-- Student demographic details by academic year
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_prosolution.student_detail` (
    -- Primary key
    student_detail_id               INT64 NOT NULL OPTIONS(description="Primary key - ProSolution StudentDetailID"),

    -- Foreign keys
    student_id                      INT64 NOT NULL OPTIONS(description="FK to Student master record"),
    academic_year_id                STRING OPTIONS(description="Academic year for these details"),

    -- Location
    postcode                        STRING OPTIONS(description="Student postcode"),

    -- SEND information
    lldd_code                       STRING OPTIONS(description="LLDD (Learners with Learning Difficulties/Disabilities) code"),
    is_send                         BOOL OPTIONS(description="SEN flag"),
    is_high_needs                   BOOL OPTIONS(description="High needs flag"),
    primary_send_type               STRING OPTIONS(description="Primary SEND type"),
    secondary_send_type             STRING OPTIONS(description="Secondary SEND type"),

    -- Disadvantage flags
    is_free_meals                   BOOL OPTIONS(description="Free school meals eligible"),
    is_bursary                      BOOL OPTIONS(description="Bursary recipient flag"),
    is_lac                          BOOL OPTIONS(description="Looked After Child flag"),

    -- Metadata
    _sdc_extracted_at               TIMESTAMP,
    _sdc_received_at                TIMESTAMP,
    _sdc_batched_at                 TIMESTAMP,
    _sdc_deleted_at                 TIMESTAMP
)
OPTIONS(
    description="Raw student detail data from ProSolution MIS"
);


-- ---------------------------------------------------------------------
-- raw_prosolution.course_header
-- Source: ProSolution.dbo.CourseHeader
-- Course/programme master data
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_prosolution.course_header` (
    -- Primary key
    course_header_id                INT64 NOT NULL OPTIONS(description="Primary key - ProSolution CourseHeaderID"),

    -- Attributes
    code                            STRING OPTIONS(description="Course code, e.g., 'BIOL-A2'"),
    name                            STRING OPTIONS(description="Course name"),
    description                     STRING OPTIONS(description="Course description"),

    -- Classification
    subject_area                    STRING OPTIONS(description="Subject area"),
    department                      STRING OPTIONS(description="Department"),
    faculty                         STRING OPTIONS(description="Faculty"),

    -- Status
    is_active                       BOOL OPTIONS(description="Active course flag"),

    -- Metadata
    _sdc_extracted_at               TIMESTAMP,
    _sdc_received_at                TIMESTAMP,
    _sdc_batched_at                 TIMESTAMP,
    _sdc_deleted_at                 TIMESTAMP
)
OPTIONS(
    description="Raw course header data from ProSolution MIS"
);


-- ---------------------------------------------------------------------
-- raw_prosolution.offering_type
-- Source: ProSolution.dbo.OfferingType (reference table)
-- Types of offerings (A-Level, BTEC, etc.)
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_prosolution.offering_type` (
    -- Primary key
    offering_type_id                INT64 NOT NULL OPTIONS(description="Primary key - OfferingTypeID"),

    -- Attributes
    name                            STRING OPTIONS(description="Offering type name"),
    description                     STRING OPTIONS(description="Offering type description"),
    category                        STRING OPTIONS(description="Category: Academic, Vocational"),
    qualification_level             STRING OPTIONS(description="Qualification level"),

    -- Metadata
    _sdc_extracted_at               TIMESTAMP,
    _sdc_received_at                TIMESTAMP,
    _sdc_batched_at                 TIMESTAMP,
    _sdc_deleted_at                 TIMESTAMP
)
OPTIONS(
    description="Raw offering type reference data from ProSolution MIS"
);


-- ---------------------------------------------------------------------
-- raw_prosolution.completion_status
-- Source: ProSolution.dbo.CompletionStatus (reference table)
-- Enrolment completion status codes
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_prosolution.completion_status` (
    -- Primary key
    completion_status_id            INT64 NOT NULL OPTIONS(description="Primary key - CompletionStatusID"),

    -- Attributes
    name                            STRING OPTIONS(description="Status name"),
    description                     STRING OPTIONS(description="Status description"),
    is_completed                    BOOL OPTIONS(description="Indicates completed status"),
    is_continuing                   BOOL OPTIONS(description="Indicates continuing status"),
    is_withdrawn                    BOOL OPTIONS(description="Indicates withdrawn status"),

    -- Metadata
    _sdc_extracted_at               TIMESTAMP,
    _sdc_received_at                TIMESTAMP,
    _sdc_batched_at                 TIMESTAMP,
    _sdc_deleted_at                 TIMESTAMP
)
OPTIONS(
    description="Raw completion status reference data from ProSolution MIS"
);


-- =====================================================================
-- RAW LAYER: MIS APPLICATIONS SOURCE TABLES
-- Schema: raw_mis_applications
-- Extended student demographic data
-- =====================================================================

-- ---------------------------------------------------------------------
-- raw_mis_applications.student_extended_data
-- Source: MISApplications.dbo.StudentExtendedData (view)
-- Extended student demographic flags for equity analysis
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_mis_applications.student_extended_data` (
    -- Primary key
    student_extended_id             INT64 NOT NULL OPTIONS(description="Primary key"),

    -- Foreign keys
    student_id                      INT64 NOT NULL OPTIONS(description="FK to Student"),
    academic_year_id                STRING OPTIONS(description="Academic year"),

    -- Background information
    nationality                     STRING OPTIONS(description="Student nationality"),
    country_of_birth                STRING OPTIONS(description="Country of birth"),
    first_language                  STRING OPTIONS(description="First/home language"),
    religion                        STRING OPTIONS(description="Religion"),

    -- Care and support flags
    is_young_carer                  BOOL OPTIONS(description="Young carer flag"),
    is_parent_carer                 BOOL OPTIONS(description="Parent/carer flag"),
    care_leaver_status              STRING OPTIONS(description="Care leaver status"),
    asylum_seeker_status            STRING OPTIONS(description="Asylum seeker status"),
    armed_forces_status             STRING OPTIONS(description="Armed forces family status"),
    household_situation             STRING OPTIONS(description="Household situation"),

    -- Deprivation indices
    imd_decile                      INT64 OPTIONS(description="Index of Multiple Deprivation decile (1-10)"),
    polar4_quintile                 INT64 OPTIONS(description="POLAR4 quintile (1-5)"),
    tundra_classification           STRING OPTIONS(description="TUNDRA classification"),

    -- Metadata
    _sdc_extracted_at               TIMESTAMP,
    _sdc_received_at                TIMESTAMP,
    _sdc_batched_at                 TIMESTAMP,
    _sdc_deleted_at                 TIMESTAMP
)
OPTIONS(
    description="Raw extended student demographic data from MISApplications"
);


-- =====================================================================
-- RAW LAYER: FOCUS SOURCE TABLES
-- Schema: raw_focus
-- Prior attainment data
-- =====================================================================

-- ---------------------------------------------------------------------
-- raw_focus.average_gcse
-- Source: focus.dbo.AverageGcse
-- Student prior attainment (GCSE scores)
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_focus.average_gcse` (
    -- Primary key
    average_gcse_id                 INT64 NOT NULL OPTIONS(description="Primary key"),

    -- Foreign key
    student_id                      INT64 NOT NULL OPTIONS(description="FK to Student"),
    academic_year_id                STRING OPTIONS(description="Academic year"),

    -- GCSE metrics
    average_gcse_score              NUMERIC(8,2) OPTIONS(description="Average GCSE point score"),

    -- Individual subject grades
    gcse_english_grade              STRING OPTIONS(description="GCSE English grade"),
    gcse_maths_grade                STRING OPTIONS(description="GCSE Maths grade"),

    -- Aggregate metrics
    gcse_count                      INT64 OPTIONS(description="Number of GCSEs"),

    -- Source information
    data_source                     STRING OPTIONS(description="Source of GCSE data"),

    -- Metadata
    _sdc_extracted_at               TIMESTAMP,
    _sdc_received_at                TIMESTAMP,
    _sdc_batched_at                 TIMESTAMP,
    _sdc_deleted_at                 TIMESTAMP
)
OPTIONS(
    description="Raw prior attainment (GCSE) data from Focus system"
);


-- =====================================================================
-- RAW LAYER: ALPS SOURCE TABLES
-- Schema: raw_alps
-- External benchmarking data parsed from ALPS PDF reports
-- =====================================================================

-- ---------------------------------------------------------------------
-- raw_alps.provider_report_a_level
-- Source: ALPS Provider Report (A-Level) - Parsed CSV
-- A-Level subject benchmarking data
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_alps.provider_report_a_level` (
    -- Primary key
    alps_report_id                  INT64 NOT NULL OPTIONS(description="Primary key"),

    -- Keys
    academic_year                   STRING NOT NULL OPTIONS(description="Academic year of report"),
    subject_name                    STRING NOT NULL OPTIONS(description="ALPS subject name"),

    -- Cohort
    student_count                   INT64 OPTIONS(description="Number of students"),
    average_gcse_on_entry           NUMERIC(8,2) OPTIONS(description="Average GCSE on entry"),

    -- ALPS metrics
    alps_grade                      INT64 OPTIONS(description="ALPS grade/band (1-9)"),
    alps_score                      NUMERIC(5,2) OPTIONS(description="ALPS score"),
    value_added_score               NUMERIC(5,2) OPTIONS(description="Value-added score"),
    national_benchmark_grade        STRING OPTIONS(description="National benchmark grade"),

    -- Performance percentages
    pass_rate_pct                   NUMERIC(5,2) OPTIONS(description="Pass rate percentage"),
    high_grades_pct                 NUMERIC(5,2) OPTIONS(description="High grades percentage (A*-B)"),

    -- Source metadata
    report_date                     DATE OPTIONS(description="Report generation date"),

    -- Metadata
    _sdc_extracted_at               TIMESTAMP,
    _sdc_received_at                TIMESTAMP,
    _sdc_batched_at                 TIMESTAMP,
    _sdc_deleted_at                 TIMESTAMP
)
OPTIONS(
    description="Raw ALPS A-Level provider benchmarking data"
);


-- ---------------------------------------------------------------------
-- raw_alps.provider_report_btec
-- Source: ALPS Provider Report (BTEC) - Parsed CSV
-- BTEC subject benchmarking data
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_alps.provider_report_btec` (
    -- Primary key
    alps_btec_report_id             INT64 NOT NULL OPTIONS(description="Primary key"),

    -- Keys
    academic_year                   STRING NOT NULL OPTIONS(description="Academic year of report"),
    subject_name                    STRING NOT NULL OPTIONS(description="ALPS subject name"),
    qualification_type              STRING OPTIONS(description="Qualification type (Extended Certificate, etc.)"),

    -- Cohort
    student_count                   INT64 OPTIONS(description="Number of students"),
    average_gcse_on_entry           NUMERIC(8,2) OPTIONS(description="Average GCSE on entry"),

    -- ALPS metrics
    alps_grade                      INT64 OPTIONS(description="ALPS grade/band"),
    alps_score                      NUMERIC(5,2) OPTIONS(description="ALPS score"),
    value_added_score               NUMERIC(5,2) OPTIONS(description="Value-added score"),
    national_benchmark_grade        STRING OPTIONS(description="National benchmark grade"),

    -- Performance percentages
    pass_rate_pct                   NUMERIC(5,2) OPTIONS(description="Pass rate percentage"),
    high_grades_pct                 NUMERIC(5,2) OPTIONS(description="High grades percentage (D*-M)"),

    -- Source metadata
    report_date                     DATE OPTIONS(description="Report generation date"),

    -- Metadata
    _sdc_extracted_at               TIMESTAMP,
    _sdc_received_at                TIMESTAMP,
    _sdc_batched_at                 TIMESTAMP,
    _sdc_deleted_at                 TIMESTAMP
)
OPTIONS(
    description="Raw ALPS BTEC provider benchmarking data"
);


-- =====================================================================
-- RAW LAYER: SIX DIMENSIONS SOURCE TABLES
-- Schema: raw_six_dimensions
-- External benchmarking data parsed from Six Dimensions PDF reports
-- =====================================================================

-- ---------------------------------------------------------------------
-- raw_six_dimensions.jedi_report
-- Source: Six Dimensions JEDI Reports - Parsed CSV
-- Justice, Equity, Diversity, Inclusion analysis
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_six_dimensions.jedi_report` (
    -- Primary key
    jedi_report_id                  INT64 NOT NULL OPTIONS(description="Primary key"),

    -- Keys
    academic_year                   STRING NOT NULL OPTIONS(description="Academic year of report"),
    report_type                     STRING OPTIONS(description="Report type identifier"),
    dimension_name                  STRING NOT NULL OPTIONS(description="Dimension: Gender, Disadvantage, Ethnicity, SEND"),

    -- Groups
    student_group                   STRING NOT NULL OPTIONS(description="Student group being analysed"),
    comparison_group                STRING OPTIONS(description="Comparison group"),

    -- Cohort metrics
    student_count                   INT64 OPTIONS(description="Student group count"),
    comparison_count                INT64 OPTIONS(description="Comparison group count"),

    -- Grade point metrics
    student_avg_grade_points        NUMERIC(8,2) OPTIONS(description="Student group average grade points"),
    comparison_avg_grade_points     NUMERIC(8,2) OPTIONS(description="Comparison group average grade points"),
    gap_grade_points                NUMERIC(8,2) OPTIONS(description="Gap in grade points"),

    -- Significance and performance
    gap_significance                STRING OPTIONS(description="Gap significance"),
    performance_band                STRING OPTIONS(description="Performance band classification"),

    -- Source metadata
    report_date                     DATE OPTIONS(description="Report generation date"),

    -- Metadata
    _sdc_extracted_at               TIMESTAMP,
    _sdc_received_at                TIMESTAMP,
    _sdc_batched_at                 TIMESTAMP,
    _sdc_deleted_at                 TIMESTAMP
)
OPTIONS(
    description="Raw Six Dimensions JEDI equity analysis data"
);


-- ---------------------------------------------------------------------
-- raw_six_dimensions.va_report
-- Source: Six Dimensions VA Reports - Parsed CSV
-- Value-Added analysis at subject level
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_six_dimensions.va_report` (
    -- Primary key
    va_report_id                    INT64 NOT NULL OPTIONS(description="Primary key"),

    -- Keys
    academic_year                   STRING NOT NULL OPTIONS(description="Academic year of report"),
    subject_name                    STRING OPTIONS(description="Subject name"),
    qualification_type              STRING OPTIONS(description="Qualification type"),

    -- Cohort
    student_count                   INT64 OPTIONS(description="Cohort size"),
    average_gcse_on_entry           NUMERIC(8,2) OPTIONS(description="Average GCSE on entry"),

    -- Value-added metrics
    value_added_score               NUMERIC(8,4) OPTIONS(description="VA score"),
    residual_score                  NUMERIC(8,4) OPTIONS(description="VA residual"),
    expected_grade                  STRING OPTIONS(description="Expected grade"),
    actual_avg_grade                STRING OPTIONS(description="Actual average grade"),
    performance_band                STRING OPTIONS(description="VA band"),

    -- Confidence intervals
    confidence_interval_lower       NUMERIC(8,4) OPTIONS(description="VA confidence interval lower bound"),
    confidence_interval_upper       NUMERIC(8,4) OPTIONS(description="VA confidence interval upper bound"),

    -- Source metadata
    report_date                     DATE OPTIONS(description="Report date"),

    -- Metadata
    _sdc_extracted_at               TIMESTAMP,
    _sdc_received_at                TIMESTAMP,
    _sdc_batched_at                 TIMESTAMP,
    _sdc_deleted_at                 TIMESTAMP
)
OPTIONS(
    description="Raw Six Dimensions Value-Added analysis data"
);


-- ---------------------------------------------------------------------
-- raw_six_dimensions.sixth_sense_report
-- Source: Six Dimensions Sixth Sense Reports - Parsed CSV
-- Comprehensive performance analysis
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_six_dimensions.sixth_sense_report` (
    -- Primary key
    sixth_sense_id                  INT64 NOT NULL OPTIONS(description="Primary key"),

    -- Keys
    academic_year                   STRING NOT NULL OPTIONS(description="Academic year of report"),
    subject_name                    STRING OPTIONS(description="Subject name"),
    qualification_type              STRING OPTIONS(description="A-Level, BTEC, etc."),

    -- Cohort
    student_count                   INT64 OPTIONS(description="Cohort size"),

    -- Performance metrics
    completion_rate_pct             NUMERIC(5,2) OPTIONS(description="Completion rate"),
    retention_rate_pct              NUMERIC(5,2) OPTIONS(description="Retention rate"),
    achievement_rate_pct            NUMERIC(5,2) OPTIONS(description="Achievement rate"),
    pass_rate_pct                   NUMERIC(5,2) OPTIONS(description="Pass rate"),
    high_grades_pct                 NUMERIC(5,2) OPTIONS(description="High grade rate (A*-B)"),
    attendance_rate_pct             NUMERIC(5,2) OPTIONS(description="Attendance rate"),

    -- National benchmarks
    national_completion_pct         NUMERIC(5,2) OPTIONS(description="National completion rate"),
    national_achievement_pct        NUMERIC(5,2) OPTIONS(description="National achievement rate"),
    national_pass_pct               NUMERIC(5,2) OPTIONS(description="National pass rate"),

    -- Performance classification
    performance_quartile            STRING OPTIONS(description="Performance quartile"),

    -- Source metadata
    report_date                     DATE OPTIONS(description="Report date"),

    -- Metadata
    _sdc_extracted_at               TIMESTAMP,
    _sdc_received_at                TIMESTAMP,
    _sdc_batched_at                 TIMESTAMP,
    _sdc_deleted_at                 TIMESTAMP
)
OPTIONS(
    description="Raw Six Dimensions Sixth Sense analysis data"
);


-- ---------------------------------------------------------------------
-- raw_six_dimensions.vocational_report
-- Source: Six Dimensions Vocational Reports - Parsed CSV
-- Vocational qualification benchmarking
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_six_dimensions.vocational_report` (
    -- Primary key
    vocational_report_id            INT64 NOT NULL OPTIONS(description="Primary key"),

    -- Keys
    academic_year                   STRING NOT NULL OPTIONS(description="Academic year of report"),
    subject_name                    STRING OPTIONS(description="Subject/qualification name"),
    qualification_type              STRING OPTIONS(description="BTEC, Cambridge Technical, etc."),
    qualification_size              STRING OPTIONS(description="Certificate, Extended Certificate, Diploma"),

    -- Cohort
    student_count                   INT64 OPTIONS(description="Cohort size"),
    average_gcse_on_entry           NUMERIC(8,2) OPTIONS(description="Average GCSE on entry"),

    -- Performance metrics
    completion_rate_pct             NUMERIC(5,2) OPTIONS(description="Completion rate"),
    achievement_rate_pct            NUMERIC(5,2) OPTIONS(description="Achievement rate"),
    pass_rate_pct                   NUMERIC(5,2) OPTIONS(description="Pass rate"),

    -- Grade distribution (BTEC-style)
    distinction_star_pct            NUMERIC(5,2) OPTIONS(description="% D*"),
    distinction_pct                 NUMERIC(5,2) OPTIONS(description="% D"),
    merit_pct                       NUMERIC(5,2) OPTIONS(description="% M"),
    pass_pct                        NUMERIC(5,2) OPTIONS(description="% P"),
    near_pass_pct                   NUMERIC(5,2) OPTIONS(description="% near pass"),
    fail_pct                        NUMERIC(5,2) OPTIONS(description="% fail"),

    -- National benchmarks
    national_achievement_pct        NUMERIC(5,2) OPTIONS(description="National achievement rate"),
    national_distinction_plus_pct   NUMERIC(5,2) OPTIONS(description="National D*/D rate"),

    -- Performance band
    performance_band                STRING OPTIONS(description="Performance band classification"),

    -- Source metadata
    report_date                     DATE OPTIONS(description="Report date"),

    -- Metadata
    _sdc_extracted_at               TIMESTAMP,
    _sdc_received_at                TIMESTAMP,
    _sdc_batched_at                 TIMESTAMP,
    _sdc_deleted_at                 TIMESTAMP
)
OPTIONS(
    description="Raw Six Dimensions Vocational benchmarking data"
);


-- =====================================================================
-- STAGING LAYER: CLEANED AND TYPED SOURCE DATA
-- Schema: staging
-- These models apply basic cleaning and type casting
-- =====================================================================

-- ---------------------------------------------------------------------
-- staging.stg_prosolution__offering
-- Cleaned offering data with proper types
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `staging.stg_prosolution__offering` (
    -- Primary key
    offering_id                     INT64 NOT NULL,

    -- Foreign keys
    course_header_id                INT64,
    offering_type_id                INT64,
    academic_year_id                STRING,

    -- Attributes (cleaned)
    offering_code                   STRING,
    offering_name                   STRING,
    qualification_id                STRING,
    study_year                      INT64,
    duration_years                  INT64,
    is_final_year                   BOOL,

    -- Dates
    start_date                      DATE,
    end_date                        DATE,

    -- Flags
    is_active                       BOOL,
    is_valid_qualification          BOOL OPTIONS(description="Excludes enrichment, tutor groups, etc."),

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Staged offering data from ProSolution"
);


-- ---------------------------------------------------------------------
-- staging.stg_prosolution__enrolment
-- Cleaned enrolment data with proper types
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `staging.stg_prosolution__enrolment` (
    -- Primary key
    enrolment_id                    INT64 NOT NULL,

    -- Foreign keys
    student_id                      INT64 NOT NULL,
    offering_id                     INT64 NOT NULL,
    completion_status_id            INT64,

    -- Dates
    enrolment_date                  DATE,
    expected_end_date               DATE,
    actual_end_date                 DATE,

    -- Grade (cleaned and validated)
    target_grade                    STRING,
    predicted_grade                 STRING,
    actual_grade                    STRING,

    -- Attendance
    attendance_pct                  NUMERIC,

    -- Status flags
    is_current                      BOOL,
    is_valid_completion             BOOL,

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Staged enrolment data from ProSolution"
);


-- ---------------------------------------------------------------------
-- staging.stg_prosolution__student
-- Cleaned student master data
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `staging.stg_prosolution__student` (
    -- Primary key
    student_id                      INT64 NOT NULL,

    -- Identifiers
    uln                             STRING,

    -- Personal information
    first_name                      STRING,
    last_name                       STRING,
    full_name                       STRING OPTIONS(description="Concatenated first_name + last_name"),
    email                           STRING,

    -- Demographics
    date_of_birth                   DATE,
    gender                          STRING OPTIONS(description="Gender: 'Male', 'Female'"),
    ethnicity                       STRING,

    -- Status
    is_active                       BOOL,

    -- Dates
    created_at                      TIMESTAMP,
    updated_at                      TIMESTAMP,

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Staged student master data from ProSolution"
);


-- ---------------------------------------------------------------------
-- staging.stg_prosolution__student_detail
-- Cleaned student detail data
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `staging.stg_prosolution__student_detail` (
    -- Primary key
    student_detail_id               INT64 NOT NULL,

    -- Foreign keys
    student_id                      INT64 NOT NULL,
    academic_year_id                STRING,

    -- Location
    postcode                        STRING,
    postcode_area                   STRING OPTIONS(description="First part of postcode"),

    -- SEND information
    lldd_code                       STRING,
    is_send                         BOOL,
    is_high_needs                   BOOL,
    primary_send_type               STRING,
    secondary_send_type             STRING,

    -- Disadvantage flags
    is_free_meals                   BOOL,
    is_bursary                      BOOL,
    is_lac                          BOOL OPTIONS(description="Looked After Child"),

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Staged student detail data from ProSolution"
);


-- ---------------------------------------------------------------------
-- staging.stg_prosolution__course_header
-- Cleaned course header data
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `staging.stg_prosolution__course_header` (
    -- Primary key
    course_header_id                INT64 NOT NULL,

    -- Attributes
    course_code                     STRING,
    course_name                     STRING,
    course_description              STRING,

    -- Classification
    subject_area                    STRING,
    department                      STRING,
    faculty                         STRING,

    -- Flags
    is_active                       BOOL,

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Staged course header data from ProSolution"
);


-- ---------------------------------------------------------------------
-- staging.stg_prosolution__offering_type
-- Cleaned offering type reference data
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `staging.stg_prosolution__offering_type` (
    -- Primary key
    offering_type_id                INT64 NOT NULL,

    -- Attributes
    offering_type_name              STRING,
    offering_type_description       STRING,
    offering_type_category          STRING,
    qualification_level             STRING,
    grading_scale                   STRING OPTIONS(description="Derived: 'A*-E', 'D*-P', 'Other'"),

    -- Flags
    is_academic                     BOOL,
    is_vocational                   BOOL,

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Staged offering type reference data from ProSolution"
);


-- ---------------------------------------------------------------------
-- staging.stg_prosolution__completion_status
-- Cleaned completion status reference data
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `staging.stg_prosolution__completion_status` (
    -- Primary key
    completion_status_id            INT64 NOT NULL,

    -- Attributes
    status_name                     STRING,
    status_description              STRING,

    -- Flags
    is_completed                    BOOL,
    is_continuing                   BOOL,
    is_withdrawn                    BOOL,

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Staged completion status reference data from ProSolution"
);


-- ---------------------------------------------------------------------
-- staging.stg_mis_applications__student_extended_data
-- Cleaned extended student demographics
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `staging.stg_mis_applications__student_extended_data` (
    -- Primary key
    student_extended_id             INT64 NOT NULL,

    -- Foreign key
    student_id                      INT64 NOT NULL,
    academic_year_id                STRING,

    -- Background information
    nationality                     STRING,
    country_of_birth                STRING,
    first_language                  STRING,
    religion                        STRING,

    -- Care and support flags
    is_young_carer                  BOOL,
    is_parent_carer                 BOOL,
    care_leaver_status              STRING,
    asylum_seeker_status            STRING,
    armed_forces_status             STRING,
    household_situation             STRING,

    -- Deprivation indices
    imd_decile                      INT64 OPTIONS(description="Index of Multiple Deprivation decile (1-10)"),
    polar4_quintile                 INT64 OPTIONS(description="POLAR4 quintile (1-5)"),
    tundra_classification           STRING,

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Staged extended student demographic data"
);


-- ---------------------------------------------------------------------
-- staging.stg_focus__average_gcse
-- Cleaned prior attainment data
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `staging.stg_focus__average_gcse` (
    -- Primary key
    average_gcse_id                 INT64 NOT NULL,

    -- Foreign key
    student_id                      INT64 NOT NULL,
    academic_year_id                STRING,

    -- GCSE metrics (typed)
    average_gcse_score              NUMERIC,

    -- Prior attainment band (derived)
    prior_attainment_band           STRING OPTIONS(description="Low (<4.77), Mid (4.77-6.09), High (>6.09), N/A"),
    prior_attainment_band_code      INT64 OPTIONS(description="0=N/A, 1=Low, 2=Mid, 3=High"),

    -- Individual subjects
    gcse_english_grade              INT64,
    gcse_maths_grade                INT64,
    gcse_count                      INT64,

    -- Source
    data_source                     STRING,

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Staged prior attainment data from Focus"
);


-- ---------------------------------------------------------------------
-- staging.stg_alps__a_level_performance
-- Cleaned ALPS A-Level benchmarking data
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `staging.stg_alps__a_level_performance` (
    -- Keys
    alps_report_id                  INT64 NOT NULL,
    academic_year_id                STRING NOT NULL,
    alps_subject_name               STRING NOT NULL,

    -- Cohort
    cohort_count                    INT64,
    average_gcse_on_entry           NUMERIC,

    -- ALPS metrics (typed)
    alps_band                       INT64,
    alps_score                      NUMERIC,
    value_added_score               NUMERIC,
    national_benchmark_grade        STRING,

    -- Performance percentages
    pass_rate_pct                   NUMERIC,
    high_grades_pct                 NUMERIC,

    -- Source metadata
    report_date                     DATE,

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Staged ALPS A-Level benchmarking data"
);


-- ---------------------------------------------------------------------
-- staging.stg_alps__btec_performance
-- Cleaned ALPS BTEC benchmarking data
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `staging.stg_alps__btec_performance` (
    -- Keys
    alps_btec_report_id             INT64 NOT NULL,
    academic_year_id                STRING NOT NULL,
    alps_subject_name               STRING NOT NULL,
    qualification_type              STRING,

    -- Cohort
    cohort_count                    INT64,
    average_gcse_on_entry           NUMERIC,

    -- ALPS metrics
    alps_band                       INT64,
    alps_score                      NUMERIC,
    value_added_score               NUMERIC,
    national_benchmark_grade        STRING,

    -- Performance percentages
    pass_rate_pct                   NUMERIC,
    high_grades_pct                 NUMERIC,

    -- Source metadata
    report_date                     DATE,

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Staged ALPS BTEC benchmarking data"
);


-- ---------------------------------------------------------------------
-- staging.stg_six_dimensions__jedi
-- Cleaned Six Dimensions JEDI data
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `staging.stg_six_dimensions__jedi` (
    -- Keys
    jedi_report_id                  INT64 NOT NULL,
    academic_year_id                STRING NOT NULL,
    report_type                     STRING,
    dimension_name                  STRING NOT NULL,

    -- Groups
    student_group                   STRING NOT NULL,
    comparison_group                STRING,

    -- Cohort metrics
    student_count                   INT64,
    comparison_count                INT64,

    -- Grade point metrics
    student_avg_grade_points        NUMERIC,
    comparison_avg_grade_points     NUMERIC,
    gap_grade_points                NUMERIC,

    -- Significance and performance
    gap_significance                STRING,
    performance_band                STRING,

    -- Source metadata
    report_date                     DATE,

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Staged Six Dimensions JEDI equity data"
);


-- ---------------------------------------------------------------------
-- staging.stg_six_dimensions__va
-- Cleaned Six Dimensions VA data
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `staging.stg_six_dimensions__va` (
    -- Keys
    va_report_id                    INT64 NOT NULL,
    academic_year_id                STRING NOT NULL,
    subject_name                    STRING,
    qualification_type              STRING,

    -- Cohort
    cohort_count                    INT64,
    average_gcse_on_entry           NUMERIC,

    -- Value-added (typed)
    value_added_score               NUMERIC,
    residual_score                  NUMERIC,
    expected_grade                  STRING,
    actual_avg_grade                STRING,
    performance_band                STRING,

    -- Confidence intervals
    confidence_interval_lower       NUMERIC,
    confidence_interval_upper       NUMERIC,

    -- Source metadata
    report_date                     DATE,

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Staged Six Dimensions Value-Added data"
);


-- ---------------------------------------------------------------------
-- staging.stg_six_dimensions__sixth_sense
-- Cleaned Six Dimensions Sixth Sense data
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `staging.stg_six_dimensions__sixth_sense` (
    -- Keys
    sixth_sense_id                  INT64 NOT NULL,
    academic_year_id                STRING NOT NULL,
    subject_name                    STRING,
    qualification_type              STRING,

    -- Cohort
    cohort_count                    INT64,

    -- Performance metrics
    completion_rate_pct             NUMERIC,
    retention_rate_pct              NUMERIC,
    achievement_rate_pct            NUMERIC,
    pass_rate_pct                   NUMERIC,
    high_grades_pct                 NUMERIC,
    attendance_rate_pct             NUMERIC,

    -- National benchmarks
    national_completion_pct         NUMERIC,
    national_achievement_pct        NUMERIC,
    national_pass_pct               NUMERIC,

    -- Performance classification
    performance_quartile            STRING,

    -- Source metadata
    report_date                     DATE,

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Staged Six Dimensions Sixth Sense data"
);


-- ---------------------------------------------------------------------
-- staging.stg_six_dimensions__vocational
-- Cleaned Six Dimensions Vocational data
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `staging.stg_six_dimensions__vocational` (
    -- Keys
    vocational_report_id            INT64 NOT NULL,
    academic_year_id                STRING NOT NULL,
    subject_name                    STRING,
    qualification_type              STRING,
    qualification_size              STRING,

    -- Cohort
    cohort_count                    INT64,
    average_gcse_on_entry           NUMERIC,

    -- Performance metrics
    completion_rate_pct             NUMERIC,
    achievement_rate_pct            NUMERIC,
    pass_rate_pct                   NUMERIC,

    -- Grade distribution (typed)
    distinction_star_pct            NUMERIC,
    distinction_pct                 NUMERIC,
    merit_pct                       NUMERIC,
    pass_pct                        NUMERIC,
    near_pass_pct                   NUMERIC,
    fail_pct                        NUMERIC,

    -- National benchmarks
    national_achievement_pct        NUMERIC,
    national_distinction_plus_pct   NUMERIC,

    -- Performance band
    performance_band                STRING,

    -- Source metadata
    report_date                     DATE,

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Staged Six Dimensions Vocational data"
);
