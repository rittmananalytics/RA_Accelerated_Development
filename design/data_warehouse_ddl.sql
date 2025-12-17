-- =====================================================================
-- Barton Peveril Sixth Form College - Data Warehouse DDL
-- Google BigQuery Dimensional Model
-- Version: 2.0 (dbt naming standards)
-- =====================================================================
--
-- dbt Layer Architecture:
--   staging.*      - Source-conformed staging models (stg_)
--   intermediate.* - Business logic transformations (int_)
--   marts.*        - Final dimensional models (dim_, fct_)
--   seeds.*        - Static reference data (seed_)
--
-- Naming Conventions:
--   - Tables: lowercase snake_case with layer prefix
--   - Primary keys: <table_name>_key (surrogate) or <entity>_id (natural)
--   - Foreign keys: <referenced_table>_key
--   - Booleans: is_* or has_* prefix
--   - Counts: *_count suffix
--   - Percentages: *_pct suffix
--   - Dates: *_date suffix
--   - Timestamps: *_at suffix
--
-- =====================================================================


-- =====================================================================
-- MARTS LAYER: DIMENSION TABLES
-- Schema: marts
-- =====================================================================

-- ---------------------------------------------------------------------
-- marts.dim_academic_year
-- {{ doc("dim_academic_year") }}
-- Academic year reference dimension supporting 6-year trend analysis
-- Grain: One row per academic year
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `marts.dim_academic_year` (
    -- Primary key
    academic_year_key               INT64 NOT NULL OPTIONS(description="Surrogate key for academic year dimension"),

    -- Natural key
    academic_year_id                STRING NOT NULL OPTIONS(description="Source system academic year identifier, e.g., '23/24'"),

    -- Attributes
    academic_year_name              STRING OPTIONS(description="Full academic year name, e.g., '2023/2024'"),
    academic_year_start_date        DATE OPTIONS(description="First day of academic year"),
    academic_year_end_date          DATE OPTIONS(description="Last day of academic year"),
    calendar_year_start             INT64 OPTIONS(description="Calendar year when academic year begins"),
    calendar_year_end               INT64 OPTIONS(description="Calendar year when academic year ends"),
    is_current_year                 BOOL OPTIONS(description="Flag indicating if this is the current academic year"),
    years_from_current              INT64 OPTIONS(description="Number of years from current year (0=current, 1=prior year, etc.)"),

    -- Metadata
    record_source                   STRING OPTIONS(description="Source system identifier"),
    loaded_at                       TIMESTAMP OPTIONS(description="Timestamp when record was loaded")
)
PARTITION BY DATE_TRUNC(academic_year_start_date, YEAR)
OPTIONS(
    description="Academic year dimension table supporting 6-year historical analysis"
);


-- ---------------------------------------------------------------------
-- marts.dim_offering_type
-- {{ doc("dim_offering_type") }}
-- Types of educational offerings (A-Level, BTEC, etc.)
-- Grain: One row per offering type
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `marts.dim_offering_type` (
    -- Primary key
    offering_type_key               INT64 NOT NULL OPTIONS(description="Surrogate key for offering type dimension"),

    -- Natural key
    offering_type_id                INT64 NOT NULL OPTIONS(description="Source system offering type identifier"),

    -- Attributes
    offering_type_name              STRING OPTIONS(description="Name of offering type, e.g., 'A-Level', 'BTEC'"),
    offering_type_category          STRING OPTIONS(description="Category grouping, e.g., 'Academic', 'Vocational'"),
    qualification_level             STRING OPTIONS(description="Qualification level, e.g., 'Level 3'"),
    grading_scale                   STRING OPTIONS(description="Grading scale used, e.g., 'A*-E', 'D*-P'"),
    is_academic                     BOOL OPTIONS(description="Flag indicating academic qualification"),
    is_vocational                   BOOL OPTIONS(description="Flag indicating vocational qualification"),

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Offering type dimension for qualification categorization"
);


-- ---------------------------------------------------------------------
-- marts.dim_course_header
-- {{ doc("dim_course_header") }}
-- Course/programme master dimension
-- Grain: One row per course header
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `marts.dim_course_header` (
    -- Primary key
    course_header_key               INT64 NOT NULL OPTIONS(description="Surrogate key for course header dimension"),

    -- Natural key
    course_header_id                INT64 NOT NULL OPTIONS(description="ProSolution CourseHeaderID"),

    -- Attributes
    course_code                     STRING OPTIONS(description="Course code, e.g., 'BIOL-A2'"),
    course_name                     STRING OPTIONS(description="Full course name"),
    subject_area                    STRING OPTIONS(description="Subject area grouping"),
    department                      STRING OPTIONS(description="Academic department"),
    is_active                       BOOL OPTIONS(description="Flag indicating if course is currently offered"),

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Course header dimension for programme-level analysis"
);


-- ---------------------------------------------------------------------
-- marts.dim_offering
-- {{ doc("dim_offering") }}
-- Individual course offerings (course + academic year instance)
-- Grain: One row per offering
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `marts.dim_offering` (
    -- Primary key
    offering_key                    INT64 NOT NULL OPTIONS(description="Surrogate key for offering dimension"),

    -- Natural key
    offering_id                     INT64 NOT NULL OPTIONS(description="ProSolution OfferingID"),

    -- Attributes
    offering_code                   STRING OPTIONS(description="Offering code, e.g., 'BIOL-A2-2024'"),
    offering_name                   STRING OPTIONS(description="Full offering name"),
    qualification_id                STRING OPTIONS(description="QualID from ProSolution"),
    study_year                      INT64 OPTIONS(description="Current year of study within programme"),
    duration_years                  INT64 OPTIONS(description="Total programme duration in years"),
    is_final_year                   BOOL OPTIONS(description="Flag indicating final year of study (study_year = duration)"),

    -- Foreign keys (natural keys for source system joins)
    academic_year_id                STRING OPTIONS(description="FK to academic year (natural key)"),
    offering_type_id                INT64 OPTIONS(description="FK to offering type (natural key)"),
    course_header_id                INT64 OPTIONS(description="FK to course header (natural key)"),

    -- External system mappings for benchmarking
    dfe_qualification_code          STRING OPTIONS(description="DfE qualification code for external benchmarking"),
    alps_subject_name               STRING OPTIONS(description="ALPS subject name for benchmarking joins"),
    six_dimensions_subject_name     STRING OPTIONS(description="Six Dimensions subject name for benchmarking joins"),

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Offering dimension linking courses to specific academic years"
);


-- ---------------------------------------------------------------------
-- marts.dim_student
-- {{ doc("dim_student") }}
-- Student dimension (SCD Type 2)
-- Grain: One row per student per version
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `marts.dim_student` (
    -- Primary key
    student_key                     INT64 NOT NULL OPTIONS(description="Surrogate key for student dimension"),

    -- Natural keys
    student_id                      INT64 NOT NULL OPTIONS(description="ProSolution StudentID"),
    student_detail_id               INT64 OPTIONS(description="ProSolution StudentDetailID"),

    -- Attributes
    gender                          STRING OPTIONS(description="Student gender: 'Male', 'Female', 'Other'"),
    gender_code                     STRING OPTIONS(description="Gender code: 'M', 'F'"),

    -- SCD Type 2 tracking
    valid_from_date                 DATE OPTIONS(description="Date this version became effective"),
    valid_to_date                   DATE OPTIONS(description="Date this version expired (NULL if current)"),
    is_current                      BOOL OPTIONS(description="Flag indicating current version of student record"),

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Student dimension with SCD Type 2 history tracking"
);


-- ---------------------------------------------------------------------
-- marts.dim_student_detail
-- {{ doc("dim_student_detail") }}
-- Extended student demographic attributes for equity analysis
-- Grain: One row per student per academic year
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `marts.dim_student_detail` (
    -- Primary key
    student_detail_key              INT64 NOT NULL OPTIONS(description="Surrogate key for student detail dimension"),

    -- Natural keys
    student_detail_id               INT64 NOT NULL OPTIONS(description="ProSolution StudentDetailID"),
    student_id                      INT64 OPTIONS(description="ProSolution StudentID"),
    academic_year_id                STRING OPTIONS(description="Academic year for these details"),

    -- Demographic flags for equity analysis (JEDI)
    is_disadvantaged                BOOL OPTIONS(description="Economically disadvantaged (ED) flag"),
    is_pupil_premium                BOOL OPTIONS(description="Pupil Premium eligible flag"),
    is_free_school_meals            BOOL OPTIONS(description="Free School Meals (FSM) eligible flag"),
    is_sen                          BOOL OPTIONS(description="Special Educational Needs flag"),
    is_access_plus                  BOOL OPTIONS(description="AccessPlus composite flag"),
    has_additional_adjustments      BOOL OPTIONS(description="Additional Adjustments (AA) flag"),
    is_bursary_recipient            BOOL OPTIONS(description="Bursary recipient flag"),

    -- Ethnicity attributes
    ethnicity_code                  STRING OPTIONS(description="Ethnicity code from source system"),
    ethnicity_description           STRING OPTIONS(description="Full ethnicity description"),
    ethnicity_group                 STRING OPTIONS(description="Grouped ethnicity for analysis"),

    -- SEND attributes
    send_category                   STRING OPTIONS(description="SEND category classification"),
    send_type                       STRING OPTIONS(description="Specific SEND type"),

    -- Geographic attributes
    postcode_area                   STRING OPTIONS(description="Student postcode area"),
    imd_decile                      INT64 OPTIONS(description="Index of Multiple Deprivation decile (1-10)"),

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Student demographic details for equity and diversity analysis"
);


-- ---------------------------------------------------------------------
-- marts.dim_prior_attainment
-- {{ doc("dim_prior_attainment") }}
-- Prior attainment (GCSE) dimension for value-added analysis
-- Grain: One row per student
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `marts.dim_prior_attainment` (
    -- Primary key
    prior_attainment_key            INT64 NOT NULL OPTIONS(description="Surrogate key for prior attainment dimension"),

    -- Natural key
    student_id                      INT64 NOT NULL OPTIONS(description="ProSolution StudentID"),

    -- GCSE score metrics
    average_gcse_score              NUMERIC(8,2) OPTIONS(description="Average GCSE point score"),

    -- Prior attainment banding (ALPS-style)
    prior_attainment_band           STRING OPTIONS(description="Prior attainment band: 'Low', 'Mid', 'High', 'N/A'"),
    prior_attainment_band_code      INT64 OPTIONS(description="Numeric band code: 0=N/A, 1=Low, 2=Mid, 3=High"),

    -- Band thresholds (configurable)
    low_threshold                   NUMERIC(8,2) OPTIONS(description="Upper boundary for Low band (default 4.77)"),
    high_threshold                  NUMERIC(8,2) OPTIONS(description="Lower boundary for High band (default 6.09)"),

    -- Additional GCSE metrics
    gcse_english_grade              STRING OPTIONS(description="GCSE English grade"),
    gcse_maths_grade                STRING OPTIONS(description="GCSE Maths grade"),
    total_gcse_points               INT64 OPTIONS(description="Total GCSE points"),
    gcse_count                      INT64 OPTIONS(description="Number of GCSEs taken"),

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Prior attainment dimension for ALPS-style value-added analysis"
);


-- ---------------------------------------------------------------------
-- marts.dim_grade
-- {{ doc("dim_grade") }}
-- Grade reference dimension for all grading scales
-- Grain: One row per grade per grading scale
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `marts.dim_grade` (
    -- Primary key
    grade_key                       INT64 NOT NULL OPTIONS(description="Surrogate key for grade dimension"),

    -- Natural key
    grade                           STRING NOT NULL OPTIONS(description="Grade value, e.g., 'A*', 'A', 'D*', 'M'"),
    grading_scale                   STRING NOT NULL OPTIONS(description="Grading scale: 'A-Level', 'BTEC Single', 'BTEC Double'"),

    -- Point values
    ucas_points                     INT64 OPTIONS(description="UCAS tariff points for this grade"),
    grade_points                    INT64 OPTIONS(description="Internal grade point value"),
    grade_sort_order                INT64 OPTIONS(description="Sort order for display (1 = highest grade)"),

    -- Grade classification flags
    is_high_grade                   BOOL OPTIONS(description="High grade flag (A*-B for A-Level, D*-M for BTEC)"),
    is_pass_grade                   BOOL OPTIONS(description="Pass grade flag (A*-E for A-Level, D*-P for BTEC)"),
    is_grade_a_star_to_a            BOOL OPTIONS(description="Grade is A* or A"),
    is_grade_a_star_to_b            BOOL OPTIONS(description="Grade is A* to B"),
    is_grade_a_star_to_c            BOOL OPTIONS(description="Grade is A* to C"),
    is_grade_a_star_to_e            BOOL OPTIONS(description="Grade is A* to E (pass)"),

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Grade dimension supporting multiple grading scales"
);


-- =====================================================================
-- MARTS LAYER: FACT TABLES - STAGE 1 (Core Student Attainment)
-- Schema: marts
-- =====================================================================

-- ---------------------------------------------------------------------
-- marts.fct_enrolment
-- {{ doc("fct_enrolment") }}
-- Student enrolment fact table for internal performance analysis
-- Grain: One row per student per offering (student-enrolment)
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `marts.fct_enrolment` (
    -- Primary key
    enrolment_key                   INT64 NOT NULL OPTIONS(description="Surrogate key for enrolment fact"),

    -- Dimension foreign keys (surrogate)
    academic_year_key               INT64 NOT NULL OPTIONS(description="FK to dim_academic_year"),
    offering_type_key               INT64 NOT NULL OPTIONS(description="FK to dim_offering_type"),
    course_header_key               INT64 NOT NULL OPTIONS(description="FK to dim_course_header"),
    offering_key                    INT64 NOT NULL OPTIONS(description="FK to dim_offering"),
    student_key                     INT64 NOT NULL OPTIONS(description="FK to dim_student"),
    student_detail_key              INT64 NOT NULL OPTIONS(description="FK to dim_student_detail"),
    prior_attainment_key            INT64 OPTIONS(description="FK to dim_prior_attainment"),
    grade_key                       INT64 OPTIONS(description="FK to dim_grade"),

    -- Natural/degenerate keys (for debugging and late-arriving dimensions)
    academic_year_id                STRING OPTIONS(description="Academic year natural key"),
    offering_id                     INT64 OPTIONS(description="Offering natural key"),
    student_id                      INT64 OPTIONS(description="Student natural key"),
    student_detail_id               INT64 OPTIONS(description="Student detail natural key"),

    -- Enrolment status
    completion_status_id            INT64 OPTIONS(description="Completion status code"),
    completion_status               STRING OPTIONS(description="Completion status: 'Completed', 'Continuing', etc."),
    is_completed                    BOOL OPTIONS(description="Flag indicating completed enrolment"),

    -- Grade measures
    grade                           STRING OPTIONS(description="Achieved grade"),
    grade_points                    INT64 OPTIONS(description="Grade point value"),
    ucas_points                     INT64 OPTIONS(description="UCAS tariff points"),

    -- A-Level grade flags (1/0 for aggregation)
    is_grade_a_star                 INT64 OPTIONS(description="1 if grade is A*, else 0"),
    is_grade_a                      INT64 OPTIONS(description="1 if grade is A, else 0"),
    is_grade_b                      INT64 OPTIONS(description="1 if grade is B, else 0"),
    is_grade_c                      INT64 OPTIONS(description="1 if grade is C, else 0"),
    is_grade_d                      INT64 OPTIONS(description="1 if grade is D, else 0"),
    is_grade_e                      INT64 OPTIONS(description="1 if grade is E, else 0"),
    is_grade_u                      INT64 OPTIONS(description="1 if grade is U (unclassified), else 0"),
    is_grade_x                      INT64 OPTIONS(description="1 if grade is X (absent/ungraded), else 0"),

    -- BTEC grade flags
    is_grade_distinction_star       INT64 OPTIONS(description="1 if BTEC D*, else 0"),
    is_grade_distinction            INT64 OPTIONS(description="1 if BTEC D (Distinction), else 0"),
    is_grade_merit                  INT64 OPTIONS(description="1 if BTEC M (Merit), else 0"),
    is_grade_pass                   INT64 OPTIONS(description="1 if BTEC P (Pass), else 0"),

    -- Cumulative grade flags
    is_high_grade                   INT64 OPTIONS(description="1 if high grade (A*-B or D*-M), else 0"),
    is_pass                         INT64 OPTIONS(description="1 if pass grade, else 0"),
    is_grade_a_star_to_a            INT64 OPTIONS(description="1 if A* or A, else 0"),
    is_grade_a_star_to_b            INT64 OPTIONS(description="1 if A* to B, else 0"),
    is_grade_a_star_to_c            INT64 OPTIONS(description="1 if A* to C, else 0"),
    is_grade_a_star_to_e            INT64 OPTIONS(description="1 if A* to E, else 0"),

    -- Prior attainment measures (denormalized)
    average_gcse_score              NUMERIC(8,2) OPTIONS(description="Student average GCSE score"),
    prior_attainment_band           STRING OPTIONS(description="Prior attainment band"),
    is_prior_low                    INT64 OPTIONS(description="1 if low prior attainment, else 0"),
    is_prior_mid                    INT64 OPTIONS(description="1 if mid prior attainment, else 0"),
    is_prior_high                   INT64 OPTIONS(description="1 if high prior attainment, else 0"),
    is_prior_na                     INT64 OPTIONS(description="1 if no prior attainment data, else 0"),

    -- Demographic flags (denormalized for performance)
    gender                          STRING OPTIONS(description="Student gender"),
    is_male                         INT64 OPTIONS(description="1 if male, else 0"),
    is_female                       INT64 OPTIONS(description="1 if female, else 0"),
    is_disadvantaged                INT64 OPTIONS(description="1 if economically disadvantaged, else 0"),
    is_pupil_premium                INT64 OPTIONS(description="1 if pupil premium, else 0"),
    is_free_school_meals            INT64 OPTIONS(description="1 if FSM eligible, else 0"),
    is_sen                          INT64 OPTIONS(description="1 if SEN, else 0"),
    is_access_plus                  INT64 OPTIONS(description="1 if AccessPlus, else 0"),
    ethnicity_group                 STRING OPTIONS(description="Ethnicity group"),

    -- Re-sit tracking
    is_first_sit                    BOOL OPTIONS(description="Flag indicating first attempt"),
    is_resit                        BOOL OPTIONS(description="Flag indicating re-sit attempt"),
    previous_grade                  STRING OPTIONS(description="Grade from previous attempt"),
    previous_grade_points           INT64 OPTIONS(description="Points from previous attempt"),
    grade_improvement_points        INT64 OPTIONS(description="Points gained from re-sit"),
    time_to_resit_years             INT64 OPTIONS(description="Years between attempts"),

    -- Value-added measures
    target_grade                    STRING OPTIONS(description="Target grade based on prior attainment"),
    target_grade_points             INT64 OPTIONS(description="Target grade points"),
    value_added_points              NUMERIC(8,2) OPTIONS(description="Value added (actual - target)"),

    -- Counting measure
    enrolment_count                 INT64 OPTIONS(description="Always 1, for counting enrolments"),

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
PARTITION BY DATE_TRUNC(PARSE_DATE('%y/%m', SUBSTR(academic_year_id, 1, 5)), YEAR)
CLUSTER BY offering_key, student_key
OPTIONS(
    description="Student enrolment fact table at student-offering grain"
);


-- =====================================================================
-- MARTS LAYER: FACT TABLES - STAGE 2 (ALPS Benchmarking)
-- Schema: marts
-- =====================================================================

-- ---------------------------------------------------------------------
-- marts.fct_alps_subject_performance
-- {{ doc("fct_alps_subject_performance") }}
-- ALPS provider benchmarking at subject level
-- Grain: One row per subject per academic year
-- Note: Different grain from fct_enrolment (aggregate, not student-level)
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `marts.fct_alps_subject_performance` (
    -- Primary key
    alps_subject_performance_key    INT64 NOT NULL OPTIONS(description="Surrogate key for ALPS performance fact"),

    -- Dimension foreign keys
    academic_year_key               INT64 NOT NULL OPTIONS(description="FK to dim_academic_year"),
    offering_key                    INT64 OPTIONS(description="FK to dim_offering (via fuzzy match)"),

    -- ALPS identifiers
    alps_subject_name               STRING NOT NULL OPTIONS(description="Subject name from ALPS report"),
    alps_qualification_type         STRING OPTIONS(description="Qualification type: 'A-Level', 'BTEC'"),

    -- Subject mapping status
    subject_mapping_status          STRING OPTIONS(description="Mapping status: 'Exact', 'Fuzzy', 'Manual', 'Unmapped'"),
    mapping_confidence_pct          NUMERIC(5,2) OPTIONS(description="Mapping confidence score (0-100)"),

    -- Cohort measure
    cohort_count                    INT64 OPTIONS(description="Number of students in cohort"),

    -- A-Level grade distribution (counts)
    grade_a_star_count              INT64 OPTIONS(description="Count of A* grades"),
    grade_a_count                   INT64 OPTIONS(description="Count of A grades"),
    grade_b_count                   INT64 OPTIONS(description="Count of B grades"),
    grade_c_count                   INT64 OPTIONS(description="Count of C grades"),
    grade_d_count                   INT64 OPTIONS(description="Count of D grades"),
    grade_e_count                   INT64 OPTIONS(description="Count of E grades"),
    grade_u_count                   INT64 OPTIONS(description="Count of U grades"),
    grade_x_count                   INT64 OPTIONS(description="Count of X grades (absent)"),

    -- A-Level grade distribution (percentages)
    grade_a_star_pct                NUMERIC(5,2) OPTIONS(description="Percentage A* grades"),
    grade_a_pct                     NUMERIC(5,2) OPTIONS(description="Percentage A grades"),
    grade_b_pct                     NUMERIC(5,2) OPTIONS(description="Percentage B grades"),
    grade_c_pct                     NUMERIC(5,2) OPTIONS(description="Percentage C grades"),
    grade_d_pct                     NUMERIC(5,2) OPTIONS(description="Percentage D grades"),
    grade_e_pct                     NUMERIC(5,2) OPTIONS(description="Percentage E grades"),
    grade_u_pct                     NUMERIC(5,2) OPTIONS(description="Percentage U grades"),
    grade_x_pct                     NUMERIC(5,2) OPTIONS(description="Percentage X grades"),

    -- BTEC Single Award distribution (counts)
    btec_distinction_star_count     INT64 OPTIONS(description="Count of D* grades"),
    btec_distinction_count          INT64 OPTIONS(description="Count of D grades"),
    btec_merit_count                INT64 OPTIONS(description="Count of M grades"),
    btec_pass_count                 INT64 OPTIONS(description="Count of P grades"),

    -- BTEC Single Award distribution (percentages)
    btec_distinction_star_pct       NUMERIC(5,2) OPTIONS(description="Percentage D* grades"),
    btec_distinction_pct            NUMERIC(5,2) OPTIONS(description="Percentage D grades"),
    btec_merit_pct                  NUMERIC(5,2) OPTIONS(description="Percentage M grades"),
    btec_pass_pct                   NUMERIC(5,2) OPTIONS(description="Percentage P grades"),

    -- BTEC Double Award distribution (counts)
    btec_d_star_d_star_count        INT64 OPTIONS(description="Count of D*D* grades"),
    btec_d_star_d_count             INT64 OPTIONS(description="Count of D*D grades"),
    btec_dd_count                   INT64 OPTIONS(description="Count of DD grades"),
    btec_dm_count                   INT64 OPTIONS(description="Count of DM grades"),
    btec_mm_count                   INT64 OPTIONS(description="Count of MM grades"),
    btec_mp_count                   INT64 OPTIONS(description="Count of MP grades"),
    btec_pp_count                   INT64 OPTIONS(description="Count of PP grades"),

    -- BTEC Double Award distribution (percentages)
    btec_d_star_d_star_pct          NUMERIC(5,2) OPTIONS(description="Percentage D*D* grades"),
    btec_d_star_d_pct               NUMERIC(5,2) OPTIONS(description="Percentage D*D grades"),
    btec_dd_pct                     NUMERIC(5,2) OPTIONS(description="Percentage DD grades"),
    btec_dm_pct                     NUMERIC(5,2) OPTIONS(description="Percentage DM grades"),
    btec_mm_pct                     NUMERIC(5,2) OPTIONS(description="Percentage MM grades"),
    btec_mp_pct                     NUMERIC(5,2) OPTIONS(description="Percentage MP grades"),
    btec_pp_pct                     NUMERIC(5,2) OPTIONS(description="Percentage PP grades"),

    -- Cumulative metrics
    a_star_to_a_pct                 NUMERIC(5,2) OPTIONS(description="Percentage A*-A"),
    a_star_to_b_pct                 NUMERIC(5,2) OPTIONS(description="Percentage A*-B"),
    a_star_to_c_pct                 NUMERIC(5,2) OPTIONS(description="Percentage A*-C"),
    a_star_to_e_pct                 NUMERIC(5,2) OPTIONS(description="Percentage A*-E (pass rate)"),
    high_grade_pct                  NUMERIC(5,2) OPTIONS(description="High grade rate (A*-B or D*-M)"),
    pass_rate_pct                   NUMERIC(5,2) OPTIONS(description="Overall pass rate"),

    -- ALPS benchmarking metrics
    alps_band                       INT64 OPTIONS(description="ALPS band (1-9, 1=best)"),
    alps_score                      NUMERIC(5,2) OPTIONS(description="ALPS score"),
    alps_national_percentile        NUMERIC(5,2) OPTIONS(description="National percentile ranking"),

    -- Point averages
    average_grade_points            NUMERIC(8,2) OPTIONS(description="Average grade points"),
    average_ucas_points             NUMERIC(8,2) OPTIONS(description="Average UCAS points"),

    -- Completion
    completion_rate_pct             NUMERIC(5,2) OPTIONS(description="Completion rate"),

    -- Metadata
    alps_report_date                DATE OPTIONS(description="Date of ALPS report"),
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
CLUSTER BY academic_year_key, alps_subject_name
OPTIONS(
    description="ALPS subject-level benchmarking fact table"
);


-- =====================================================================
-- MARTS LAYER: FACT TABLES - STAGE 3 (Six Dimensions/JEDI)
-- Schema: marts
-- =====================================================================

-- ---------------------------------------------------------------------
-- marts.fct_college_performance
-- {{ doc("fct_college_performance") }}
-- College-level performance from Six Dimensions reports
-- Grain: One row per report type per academic year
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `marts.fct_college_performance` (
    -- Primary key
    college_performance_key         INT64 NOT NULL OPTIONS(description="Surrogate key for college performance fact"),

    -- Dimension foreign key
    academic_year_key               INT64 NOT NULL OPTIONS(description="FK to dim_academic_year"),

    -- Source identifiers
    report_type                     STRING OPTIONS(description="Report type: 'VA', 'Sixth Sense', 'JEDI', 'Vocational'"),
    report_name                     STRING OPTIONS(description="Full report name"),

    -- Cohort measures
    total_cohort_count              INT64 OPTIONS(description="Total student cohort"),
    a_level_cohort_count            INT64 OPTIONS(description="A-Level student count"),
    btec_cohort_count               INT64 OPTIONS(description="BTEC student count"),
    vocational_cohort_count         INT64 OPTIONS(description="Vocational student count"),

    -- Attainment metrics
    pass_rate_pct                   NUMERIC(5,2) OPTIONS(description="Overall pass rate"),
    high_grade_rate_pct             NUMERIC(5,2) OPTIONS(description="High grade rate"),
    average_grade_points            NUMERIC(8,2) OPTIONS(description="Average grade points"),
    average_ucas_points             NUMERIC(8,2) OPTIONS(description="Average UCAS points"),

    -- Value-added metrics
    va_score                        NUMERIC(8,4) OPTIONS(description="Value-added score"),
    va_band                         STRING OPTIONS(description="VA band: 'Above Average', 'Average', etc."),
    va_confidence_lower             NUMERIC(8,4) OPTIONS(description="VA confidence interval lower bound"),
    va_confidence_upper             NUMERIC(8,4) OPTIONS(description="VA confidence interval upper bound"),
    va_percentile                   NUMERIC(5,2) OPTIONS(description="VA national percentile"),
    va_national_rank                INT64 OPTIONS(description="VA national ranking"),

    -- Sixth Sense metrics
    sixth_sense_score               NUMERIC(8,4) OPTIONS(description="Sixth Sense composite score"),
    sixth_sense_band                STRING OPTIONS(description="Sixth Sense band classification"),

    -- National benchmarks
    national_pass_rate_pct          NUMERIC(5,2) OPTIONS(description="National average pass rate"),
    national_high_grade_pct         NUMERIC(5,2) OPTIONS(description="National average high grade rate"),
    national_percentile_rank        NUMERIC(5,2) OPTIONS(description="College national percentile"),

    -- Variance from benchmark
    pass_rate_vs_national_pct       NUMERIC(5,2) OPTIONS(description="Pass rate difference from national"),
    high_grade_vs_national_pct      NUMERIC(5,2) OPTIONS(description="High grade difference from national"),

    -- Metadata
    report_date                     DATE OPTIONS(description="Date of report"),
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
CLUSTER BY academic_year_key, report_type
OPTIONS(
    description="College-level performance metrics from Six Dimensions"
);


-- ---------------------------------------------------------------------
-- marts.fct_subject_benchmark
-- {{ doc("fct_subject_benchmark") }}
-- Subject-level benchmarking from Six Dimensions reports
-- Grain: One row per subject per academic year
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `marts.fct_subject_benchmark` (
    -- Primary key
    subject_benchmark_key           INT64 NOT NULL OPTIONS(description="Surrogate key for subject benchmark fact"),

    -- Dimension foreign keys
    academic_year_key               INT64 NOT NULL OPTIONS(description="FK to dim_academic_year"),
    offering_key                    INT64 OPTIONS(description="FK to dim_offering"),

    -- Source identifiers
    report_type                     STRING OPTIONS(description="Report type: 'VA', 'Sixth Sense', 'Vocational'"),
    six_dimensions_subject_name     STRING NOT NULL OPTIONS(description="Subject name from Six Dimensions"),
    qualification_type              STRING OPTIONS(description="Qualification type"),

    -- Subject mapping
    subject_mapping_status          STRING OPTIONS(description="Mapping status to internal offerings"),
    mapping_confidence_pct          NUMERIC(5,2) OPTIONS(description="Mapping confidence score"),

    -- Cohort
    cohort_count                    INT64 OPTIONS(description="Subject cohort size"),

    -- Attainment metrics
    pass_rate_pct                   NUMERIC(5,2) OPTIONS(description="Subject pass rate"),
    high_grade_rate_pct             NUMERIC(5,2) OPTIONS(description="Subject high grade rate"),
    average_grade_points            NUMERIC(8,2) OPTIONS(description="Average grade points"),
    average_ucas_points             NUMERIC(8,2) OPTIONS(description="Average UCAS points"),

    -- Value-added metrics
    va_score                        NUMERIC(8,4) OPTIONS(description="Subject VA score"),
    va_residual                     NUMERIC(8,4) OPTIONS(description="VA residual"),
    va_band                         STRING OPTIONS(description="VA performance band"),
    va_percentile                   NUMERIC(5,2) OPTIONS(description="VA percentile"),
    va_confidence_lower             NUMERIC(8,4) OPTIONS(description="VA confidence lower"),
    va_confidence_upper             NUMERIC(8,4) OPTIONS(description="VA confidence upper"),

    -- National benchmarks
    national_pass_rate_pct          NUMERIC(5,2) OPTIONS(description="National subject pass rate"),
    national_high_grade_pct         NUMERIC(5,2) OPTIONS(description="National subject high grade rate"),
    national_va_average             NUMERIC(8,4) OPTIONS(description="National VA average"),

    -- Variance from benchmark
    pass_rate_vs_national_pct       NUMERIC(5,2) OPTIONS(description="Pass rate vs national"),
    high_grade_vs_national_pct      NUMERIC(5,2) OPTIONS(description="High grade vs national"),
    va_vs_national                  NUMERIC(8,4) OPTIONS(description="VA vs national"),

    -- Subject ranking
    subject_rank_internal           INT64 OPTIONS(description="Subject rank within college"),
    subject_rank_national           INT64 OPTIONS(description="Subject national rank"),

    -- Trend indicators
    performance_trajectory          STRING OPTIONS(description="Trajectory: 'Improving', 'Stable', 'Declining'"),
    yoy_change_pct                  NUMERIC(5,2) OPTIONS(description="Year-over-year change"),

    -- Metadata
    report_date                     DATE OPTIONS(description="Report date"),
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
CLUSTER BY academic_year_key, six_dimensions_subject_name
OPTIONS(
    description="Subject-level benchmarking from Six Dimensions reports"
);


-- ---------------------------------------------------------------------
-- marts.fct_equity_gap
-- {{ doc("fct_equity_gap") }}
-- Demographic equity gaps from JEDI reports
-- Grain: One row per demographic category per academic year
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `marts.fct_equity_gap` (
    -- Primary key
    equity_gap_key                  INT64 NOT NULL OPTIONS(description="Surrogate key for equity gap fact"),

    -- Dimension foreign key
    academic_year_key               INT64 NOT NULL OPTIONS(description="FK to dim_academic_year"),

    -- Source identifier
    report_type                     STRING OPTIONS(description="Report type: 'JEDI'"),

    -- Demographic segmentation
    demographic_category            STRING NOT NULL OPTIONS(description="Category: 'Gender', 'Disadvantage', 'Ethnicity', 'SEND'"),
    demographic_value               STRING NOT NULL OPTIONS(description="Value: 'Male', 'Female', 'Disadvantaged', etc."),

    -- Intersectional analysis (optional)
    demographic_category_2          STRING OPTIONS(description="Second demographic category for intersection"),
    demographic_value_2             STRING OPTIONS(description="Second demographic value"),
    is_intersectional               BOOL OPTIONS(description="Flag indicating intersectional analysis"),

    -- Cohort metrics
    subgroup_cohort_count           INT64 OPTIONS(description="Subgroup cohort size"),
    subgroup_cohort_pct             NUMERIC(5,2) OPTIONS(description="Subgroup as percentage of total"),

    -- Subgroup attainment
    subgroup_pass_rate_pct          NUMERIC(5,2) OPTIONS(description="Subgroup pass rate"),
    subgroup_high_grade_pct         NUMERIC(5,2) OPTIONS(description="Subgroup high grade rate"),
    subgroup_avg_grade_points       NUMERIC(8,2) OPTIONS(description="Subgroup average grade points"),
    subgroup_avg_ucas_points        NUMERIC(8,2) OPTIONS(description="Subgroup average UCAS points"),

    -- Subgroup value-added
    subgroup_va_score               NUMERIC(8,4) OPTIONS(description="Subgroup VA score"),
    subgroup_va_band                STRING OPTIONS(description="Subgroup VA band"),
    subgroup_va_percentile          NUMERIC(5,2) OPTIONS(description="Subgroup VA percentile"),

    -- Overall cohort benchmarks
    overall_pass_rate_pct           NUMERIC(5,2) OPTIONS(description="Overall cohort pass rate"),
    overall_high_grade_pct          NUMERIC(5,2) OPTIONS(description="Overall cohort high grade rate"),
    overall_va_score                NUMERIC(8,4) OPTIONS(description="Overall cohort VA"),

    -- Gap calculations (subgroup - overall)
    pass_rate_gap_pct               NUMERIC(5,2) OPTIONS(description="Pass rate gap (subgroup - overall)"),
    high_grade_gap_pct              NUMERIC(5,2) OPTIONS(description="High grade gap"),
    va_gap                          NUMERIC(8,4) OPTIONS(description="VA gap"),

    -- Gender-specific gaps (when category = Gender)
    male_pass_rate_pct              NUMERIC(5,2) OPTIONS(description="Male pass rate"),
    female_pass_rate_pct            NUMERIC(5,2) OPTIONS(description="Female pass rate"),
    gender_gap_pass_rate_pct        NUMERIC(5,2) OPTIONS(description="Gender gap in pass rate (F-M)"),
    male_high_grade_pct             NUMERIC(5,2) OPTIONS(description="Male high grade rate"),
    female_high_grade_pct           NUMERIC(5,2) OPTIONS(description="Female high grade rate"),
    gender_gap_high_grade_pct       NUMERIC(5,2) OPTIONS(description="Gender gap in high grades (F-M)"),

    -- National benchmarks
    national_subgroup_pass_rate_pct NUMERIC(5,2) OPTIONS(description="National subgroup pass rate"),
    national_subgroup_high_grade_pct NUMERIC(5,2) OPTIONS(description="National subgroup high grade"),
    national_subgroup_va            NUMERIC(8,4) OPTIONS(description="National subgroup VA"),

    -- Performance vs national
    pass_rate_vs_national_pct       NUMERIC(5,2) OPTIONS(description="Subgroup pass rate vs national"),
    high_grade_vs_national_pct      NUMERIC(5,2) OPTIONS(description="Subgroup high grade vs national"),
    va_vs_national                  NUMERIC(8,4) OPTIONS(description="Subgroup VA vs national"),

    -- Gap trend analysis
    prior_year_gap_pct              NUMERIC(5,2) OPTIONS(description="Gap in prior year"),
    gap_change_yoy_pct              NUMERIC(5,2) OPTIONS(description="Year-over-year gap change"),
    gap_trend                       STRING OPTIONS(description="Gap trend: 'Narrowing', 'Stable', 'Widening'"),

    -- Metadata
    report_date                     DATE OPTIONS(description="Report date"),
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
CLUSTER BY academic_year_key, demographic_category
OPTIONS(
    description="Demographic equity gap analysis from JEDI reports"
);


-- =====================================================================
-- SEEDS LAYER: REFERENCE/MAPPING TABLES
-- Schema: seeds
-- =====================================================================

-- ---------------------------------------------------------------------
-- seeds.seed_subject_crosswalk
-- {{ doc("seed_subject_crosswalk") }}
-- Subject name mapping between systems
-- Grain: One row per subject mapping
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `seeds.seed_subject_crosswalk` (
    -- Primary key
    crosswalk_key                   INT64 NOT NULL OPTIONS(description="Surrogate key for crosswalk"),

    -- ProSolution identifiers
    course_header_id                INT64 OPTIONS(description="ProSolution CourseHeaderID"),
    offering_code                   STRING OPTIONS(description="ProSolution offering code"),
    prosolution_subject_name        STRING OPTIONS(description="Subject name in ProSolution"),

    -- ALPS identifiers
    alps_subject_name               STRING OPTIONS(description="Subject name in ALPS"),
    alps_qualification_type         STRING OPTIONS(description="ALPS qualification type"),

    -- Six Dimensions identifiers
    six_dimensions_subject_name     STRING OPTIONS(description="Subject name in Six Dimensions"),

    -- DfE identifiers
    dfe_qualification_code          STRING OPTIONS(description="DfE qualification code"),
    dfe_subject_name                STRING OPTIONS(description="DfE subject name"),

    -- Mapping metadata
    mapping_method                  STRING OPTIONS(description="Method: 'Exact', 'Fuzzy', 'Manual'"),
    match_confidence_pct            NUMERIC(5,2) OPTIONS(description="Match confidence (0-100)"),
    is_verified                     BOOL OPTIONS(description="Flag indicating SME verification"),
    verified_by                     STRING OPTIONS(description="Verifier name"),
    verified_date                   DATE OPTIONS(description="Verification date"),

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Subject name crosswalk for multi-system mapping"
);


-- ---------------------------------------------------------------------
-- seeds.seed_grade_points
-- {{ doc("seed_grade_points") }}
-- Grade to points conversion reference
-- Grain: One row per grade per qualification type
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `seeds.seed_grade_points` (
    grade                           STRING NOT NULL OPTIONS(description="Grade value"),
    qualification_type              STRING NOT NULL OPTIONS(description="Qualification type"),
    ucas_points                     INT64 OPTIONS(description="UCAS tariff points"),
    grade_points                    INT64 OPTIONS(description="Internal grade points"),
    grade_sort_order                INT64 OPTIONS(description="Sort order (1=highest)"),
    is_pass                         BOOL OPTIONS(description="Is passing grade"),
    is_high_grade                   BOOL OPTIONS(description="Is high grade")
)
OPTIONS(
    description="Grade to points conversion reference data"
);


-- =====================================================================
-- INTERMEDIATE LAYER: AGGREGATE TABLES
-- Schema: intermediate
-- =====================================================================

-- ---------------------------------------------------------------------
-- intermediate.int_course_performance_by_year
-- {{ doc("int_course_performance_by_year") }}
-- Pre-aggregated course performance for dashboard optimization
-- Grain: One row per offering per academic year
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `intermediate.int_course_performance_by_year` (
    -- Dimension keys
    academic_year_key               INT64 NOT NULL OPTIONS(description="FK to dim_academic_year"),
    offering_key                    INT64 NOT NULL OPTIONS(description="FK to dim_offering"),
    course_header_key               INT64 NOT NULL OPTIONS(description="FK to dim_course_header"),
    offering_type_key               INT64 NOT NULL OPTIONS(description="FK to dim_offering_type"),

    -- Natural keys
    academic_year_id                STRING OPTIONS(description="Academic year ID"),
    offering_code                   STRING OPTIONS(description="Offering code"),
    offering_name                   STRING OPTIONS(description="Offering name"),
    qualification_id                STRING OPTIONS(description="Qualification ID"),

    -- Cohort counts
    cohort_count                    INT64 OPTIONS(description="Total enrolments"),
    completed_count                 INT64 OPTIONS(description="Completed enrolments"),

    -- Demographic counts
    male_count                      INT64 OPTIONS(description="Male students"),
    female_count                    INT64 OPTIONS(description="Female students"),
    disadvantaged_count             INT64 OPTIONS(description="Disadvantaged students"),
    sen_count                       INT64 OPTIONS(description="SEN students"),
    pupil_premium_count             INT64 OPTIONS(description="Pupil premium students"),

    -- Prior attainment counts
    prior_low_count                 INT64 OPTIONS(description="Low prior attainment"),
    prior_mid_count                 INT64 OPTIONS(description="Mid prior attainment"),
    prior_high_count                INT64 OPTIONS(description="High prior attainment"),
    prior_na_count                  INT64 OPTIONS(description="No prior attainment data"),

    -- Grade counts
    grade_a_star_count              INT64,
    grade_a_count                   INT64,
    grade_b_count                   INT64,
    grade_c_count                   INT64,
    grade_d_count                   INT64,
    grade_e_count                   INT64,
    grade_u_count                   INT64,

    -- Cumulative counts
    a_star_to_a_count               INT64,
    a_star_to_b_count               INT64,
    a_star_to_c_count               INT64,
    a_star_to_e_count               INT64,

    -- Calculated rates
    pass_rate_pct                   NUMERIC(5,2) OPTIONS(description="Pass rate percentage"),
    high_grade_rate_pct             NUMERIC(5,2) OPTIONS(description="High grade rate percentage"),

    -- Averages
    avg_gcse_score                  NUMERIC(8,2) OPTIONS(description="Average GCSE score"),
    avg_grade_points                NUMERIC(8,2) OPTIONS(description="Average grade points"),
    avg_ucas_points                 NUMERIC(8,2) OPTIONS(description="Average UCAS points"),

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
CLUSTER BY academic_year_key, offering_key
OPTIONS(
    description="Pre-aggregated course performance for dashboard optimization"
);


-- ---------------------------------------------------------------------
-- intermediate.int_demographic_gaps_by_year
-- {{ doc("int_demographic_gaps_by_year") }}
-- Pre-aggregated demographic attainment gaps
-- Grain: One row per demographic category per academic year
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `intermediate.int_demographic_gaps_by_year` (
    -- Keys
    academic_year_key               INT64 NOT NULL OPTIONS(description="FK to dim_academic_year"),
    demographic_category            STRING NOT NULL OPTIONS(description="Category: Gender, Disadvantage, SEN, Ethnicity"),

    -- Overall cohort
    total_cohort_count              INT64 OPTIONS(description="Total cohort size"),
    total_pass_rate_pct             NUMERIC(5,2) OPTIONS(description="Overall pass rate"),
    total_high_grade_pct            NUMERIC(5,2) OPTIONS(description="Overall high grade rate"),

    -- Subgroup 1 (reference group)
    subgroup_1_name                 STRING OPTIONS(description="Reference group name"),
    subgroup_1_count                INT64 OPTIONS(description="Reference group count"),
    subgroup_1_pass_rate_pct        NUMERIC(5,2) OPTIONS(description="Reference group pass rate"),
    subgroup_1_high_grade_pct       NUMERIC(5,2) OPTIONS(description="Reference group high grade rate"),

    -- Subgroup 2 (comparison group)
    subgroup_2_name                 STRING OPTIONS(description="Comparison group name"),
    subgroup_2_count                INT64 OPTIONS(description="Comparison group count"),
    subgroup_2_pass_rate_pct        NUMERIC(5,2) OPTIONS(description="Comparison group pass rate"),
    subgroup_2_high_grade_pct       NUMERIC(5,2) OPTIONS(description="Comparison group high grade rate"),

    -- Gap calculations
    pass_rate_gap_pct               NUMERIC(5,2) OPTIONS(description="Pass rate gap (group2 - group1)"),
    high_grade_gap_pct              NUMERIC(5,2) OPTIONS(description="High grade gap"),

    -- Trend
    prior_year_gap_pct              NUMERIC(5,2) OPTIONS(description="Prior year gap"),
    gap_change_pct                  NUMERIC(5,2) OPTIONS(description="Gap change YoY"),
    gap_trend                       STRING OPTIONS(description="Trend: Narrowing, Stable, Widening"),

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
CLUSTER BY academic_year_key, demographic_category
OPTIONS(
    description="Pre-aggregated demographic gaps for equity dashboard"
);
