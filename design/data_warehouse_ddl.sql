-- =====================================================================
-- Barton Peveril Sixth Form College - Data Warehouse DDL
-- Google BigQuery Dimensional Model
-- Version: 3.0 (Updated to match deployed marts/intermediate schemas)
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
-- Schema: marts (analytics in BigQuery)
-- =====================================================================

-- ---------------------------------------------------------------------
-- marts.dim_academic_year
-- Academic year reference dimension supporting 6-year trend analysis
-- Grain: One row per academic year
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `analytics.dim_academic_year` (
    -- Primary key
    academic_year_key               INT64 NOT NULL OPTIONS(description="Surrogate key for academic year dimension"),

    -- Natural key
    academic_year_id                STRING NOT NULL OPTIONS(description="Source system academic year identifier, e.g., '23/24'"),

    -- Attributes
    academic_year_name              STRING OPTIONS(description="Full academic year name, e.g., '2023/2024'"),
    academic_year_start_date        DATE OPTIONS(description="First day of academic year (Sept 1)"),
    academic_year_end_date          DATE OPTIONS(description="Last day of academic year (Aug 31)"),
    calendar_year_start             INT64 OPTIONS(description="Calendar year when academic year begins"),
    calendar_year_end               INT64 OPTIONS(description="Calendar year when academic year ends"),
    is_current_year                 BOOL OPTIONS(description="Flag indicating if this is the current academic year"),
    years_from_current              INT64 OPTIONS(description="Number of years from current year (0=current, 1=prior year, etc.)"),

    -- Metadata
    record_source                   STRING OPTIONS(description="Source system identifier"),
    loaded_at                       TIMESTAMP OPTIONS(description="Timestamp when record was loaded")
)
OPTIONS(
    description="Academic year dimension table supporting 6-year historical analysis"
);


-- ---------------------------------------------------------------------
-- marts.dim_offering_type
-- Types of educational offerings (A-Level, BTEC, etc.)
-- Grain: One row per offering type
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `analytics.dim_offering_type` (
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
-- Course/programme master dimension
-- Grain: One row per course header
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `analytics.dim_course_header` (
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
-- Individual course offerings (course + academic year instance)
-- Grain: One row per offering
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `analytics.dim_offering` (
    -- Primary key
    offering_key                    INT64 NOT NULL OPTIONS(description="Surrogate key for offering dimension"),

    -- Natural key
    offering_id                     INT64 NOT NULL OPTIONS(description="ProSolution OfferingID"),

    -- Attributes
    offering_code                   STRING OPTIONS(description="Offering code"),
    offering_name                   STRING OPTIONS(description="Full offering name"),
    qualification_id                STRING OPTIONS(description="QualID from ProSolution"),
    study_year                      INT64 OPTIONS(description="Current year of study within programme"),
    duration_years                  INT64 OPTIONS(description="Total programme duration in years"),
    is_final_year                   BOOL OPTIONS(description="Flag indicating final year of study"),

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
-- Student dimension with demographics
-- Grain: One row per student
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `analytics.dim_student` (
    -- Primary key
    student_key                     INT64 NOT NULL OPTIONS(description="Surrogate key for student dimension"),

    -- Natural key
    student_id                      INT64 NOT NULL OPTIONS(description="ProSolution StudentID"),

    -- Identifiers
    uln                             STRING OPTIONS(description="Unique Learner Number"),

    -- Demographics
    first_name                      STRING OPTIONS(description="First name"),
    last_name                       STRING OPTIONS(description="Last name"),
    full_name                       STRING OPTIONS(description="Full name (concatenated)"),
    date_of_birth                   DATE OPTIONS(description="Date of birth"),
    gender                          STRING OPTIONS(description="Student gender: 'Male', 'Female'"),
    ethnicity                       STRING OPTIONS(description="Ethnicity description"),

    -- Status
    is_active                       BOOL OPTIONS(description="Active student flag"),

    -- Dates
    first_enrolment_date            TIMESTAMP OPTIONS(description="First enrolment date at college"),

    -- SCD Type 2 tracking
    valid_from_date                 DATE OPTIONS(description="Date this version became effective"),
    valid_to_date                   DATE OPTIONS(description="Date this version expired (NULL if current)"),
    is_current                      BOOL OPTIONS(description="Flag indicating current version of student record"),

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Student dimension with demographic information"
);


-- ---------------------------------------------------------------------
-- marts.dim_student_detail
-- Extended student demographic attributes for equity analysis
-- Grain: One row per student per academic year
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `analytics.dim_student_detail` (
    -- Primary key
    student_detail_key              INT64 NOT NULL OPTIONS(description="Surrogate key for student detail dimension"),

    -- Natural keys
    student_detail_id               INT64 NOT NULL OPTIONS(description="ProSolution StudentDetailID"),
    student_id                      INT64 OPTIONS(description="ProSolution StudentID"),
    academic_year_id                STRING OPTIONS(description="Academic year for these details"),

    -- Core demographics
    full_name                       STRING OPTIONS(description="Student full name"),
    gender                          STRING OPTIONS(description="Gender"),
    ethnicity                       STRING OPTIONS(description="Ethnicity description"),

    -- Demographic flags for equity analysis (JEDI)
    is_free_meals                   BOOL OPTIONS(description="Free School Meals (FSM) eligible flag"),
    is_bursary                      BOOL OPTIONS(description="Bursary recipient flag"),
    is_lac                          BOOL OPTIONS(description="Looked After Child flag"),
    is_send                         BOOL OPTIONS(description="Special Educational Needs flag"),
    is_high_needs                   BOOL OPTIONS(description="High needs flag"),
    is_young_carer                  BOOL OPTIONS(description="Young carer flag"),

    -- SEND details
    primary_send_type               STRING OPTIONS(description="Primary SEND type"),
    secondary_send_type             STRING OPTIONS(description="Secondary SEND type"),

    -- Geographic attributes
    postcode_area                   STRING OPTIONS(description="Student postcode area"),
    imd_decile                      INT64 OPTIONS(description="Index of Multiple Deprivation decile (1-10)"),
    polar4_quintile                 INT64 OPTIONS(description="POLAR4 quintile"),
    tundra_classification           STRING OPTIONS(description="TUNDRA classification"),

    -- Background
    nationality                     STRING OPTIONS(description="Nationality"),
    country_of_birth                STRING OPTIONS(description="Country of birth"),
    first_language                  STRING OPTIONS(description="First language"),
    religion                        STRING OPTIONS(description="Religion"),

    -- Prior attainment
    average_gcse_score              NUMERIC OPTIONS(description="Average GCSE score"),
    prior_attainment_band           STRING OPTIONS(description="Prior attainment band"),

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Student demographic details for equity and diversity analysis"
);


-- ---------------------------------------------------------------------
-- marts.dim_prior_attainment
-- Prior attainment (GCSE) dimension for value-added analysis
-- Grain: One row per student per academic year
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `analytics.dim_prior_attainment` (
    -- Primary key
    prior_attainment_key            INT64 NOT NULL OPTIONS(description="Surrogate key for prior attainment dimension"),

    -- Natural keys
    average_gcse_id                 INT64 NOT NULL OPTIONS(description="Average GCSE ID"),
    student_id                      INT64 NOT NULL OPTIONS(description="ProSolution StudentID"),
    academic_year_id                STRING OPTIONS(description="Academic year"),

    -- GCSE score metrics
    average_gcse_score              NUMERIC OPTIONS(description="Average GCSE point score"),

    -- Prior attainment banding (ALPS-style)
    prior_attainment_band           STRING OPTIONS(description="Prior attainment band: 'Low', 'Mid', 'High', 'N/A'"),
    prior_attainment_band_code      INT64 OPTIONS(description="Numeric band code: 0=N/A, 1=Low, 2=Mid, 3=High"),

    -- Band thresholds (configurable)
    low_threshold                   NUMERIC OPTIONS(description="Upper boundary for Low band (default 4.77)"),
    high_threshold                  NUMERIC OPTIONS(description="Lower boundary for High band (default 6.09)"),

    -- Additional GCSE metrics
    gcse_english_grade              INT64 OPTIONS(description="GCSE English grade (numeric)"),
    gcse_maths_grade                INT64 OPTIONS(description="GCSE Maths grade (numeric)"),
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
-- Grade reference dimension for all grading scales
-- Grain: One row per grade per grading scale
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `analytics.dim_grade` (
    -- Primary key
    grade_key                       INT64 NOT NULL OPTIONS(description="Surrogate key for grade dimension"),

    -- Natural key
    grade                           STRING NOT NULL OPTIONS(description="Grade value, e.g., 'A*', 'A', 'D*', 'M'"),
    grading_scale                   STRING NOT NULL OPTIONS(description="Grading scale: 'A-Level', 'BTEC'"),

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
-- MARTS LAYER: FACT TABLES
-- Schema: marts (analytics in BigQuery)
-- =====================================================================

-- ---------------------------------------------------------------------
-- marts.fct_enrolment
-- Student enrolment fact table for internal performance analysis
-- Grain: One row per student per offering (student-enrolment)
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `analytics.fct_enrolment` (
    -- Primary key
    enrolment_key                   INT64 NOT NULL OPTIONS(description="Surrogate key for enrolment fact"),

    -- Dimension foreign keys (surrogate)
    academic_year_key               INT64 NOT NULL OPTIONS(description="FK to dim_academic_year"),
    offering_type_key               INT64 NOT NULL OPTIONS(description="FK to dim_offering_type"),
    course_header_key               INT64 NOT NULL OPTIONS(description="FK to dim_course_header"),
    offering_key                    INT64 NOT NULL OPTIONS(description="FK to dim_offering"),
    student_key                     INT64 NOT NULL OPTIONS(description="FK to dim_student"),
    student_detail_key              INT64 OPTIONS(description="FK to dim_student_detail"),
    prior_attainment_key            INT64 OPTIONS(description="FK to dim_prior_attainment"),
    grade_key                       INT64 OPTIONS(description="FK to dim_grade"),

    -- Natural/degenerate keys (for debugging)
    academic_year_id                STRING OPTIONS(description="Academic year natural key"),
    offering_id                     INT64 OPTIONS(description="Offering natural key"),
    student_id                      INT64 OPTIONS(description="Student natural key"),
    student_detail_id               INT64 OPTIONS(description="Student detail natural key"),

    -- For partitioning
    academic_year_start_date        DATE OPTIONS(description="Academic year start date for partitioning"),

    -- Enrolment status
    completion_status_id            INT64 OPTIONS(description="Completion status code"),
    completion_status               STRING OPTIONS(description="Completion status: 'Completed', 'Continuing', etc."),
    is_completed                    BOOL OPTIONS(description="Flag indicating completed enrolment"),

    -- Grade measures
    grade                           STRING OPTIONS(description="Achieved grade"),
    target_grade                    STRING OPTIONS(description="Target grade"),
    predicted_grade                 STRING OPTIONS(description="Predicted grade"),

    -- A-Level grade flags (1/0 for aggregation)
    is_grade_a_star                 INT64 OPTIONS(description="1 if grade is A*, else 0"),
    is_grade_a                      INT64 OPTIONS(description="1 if grade is A, else 0"),
    is_grade_b                      INT64 OPTIONS(description="1 if grade is B, else 0"),
    is_grade_c                      INT64 OPTIONS(description="1 if grade is C, else 0"),
    is_grade_d                      INT64 OPTIONS(description="1 if grade is D, else 0"),
    is_grade_e                      INT64 OPTIONS(description="1 if grade is E, else 0"),
    is_grade_u                      INT64 OPTIONS(description="1 if grade is U (unclassified), else 0"),

    -- BTEC grade flags
    is_grade_distinction_star       INT64 OPTIONS(description="1 if BTEC D*, else 0"),
    is_grade_distinction            INT64 OPTIONS(description="1 if BTEC D (Distinction), else 0"),
    is_grade_merit                  INT64 OPTIONS(description="1 if BTEC M (Merit), else 0"),
    is_grade_pass                   INT64 OPTIONS(description="1 if BTEC P (Pass), else 0"),

    -- Cumulative grade flags
    is_high_grade                   INT64 OPTIONS(description="1 if high grade (A*-B or D*-M), else 0"),
    is_pass                         INT64 OPTIONS(description="1 if pass grade, else 0"),

    -- Prior attainment measures (denormalized)
    average_gcse_score              NUMERIC OPTIONS(description="Student average GCSE score"),
    prior_attainment_band           STRING OPTIONS(description="Prior attainment band"),

    -- Demographic flags (denormalized for performance)
    gender                          STRING OPTIONS(description="Student gender"),
    ethnicity                       STRING OPTIONS(description="Student ethnicity"),
    is_send                         BOOL OPTIONS(description="SEN flag"),
    is_free_meals                   BOOL OPTIONS(description="Free meals eligible flag"),
    is_bursary                      BOOL OPTIONS(description="Bursary recipient flag"),
    is_lac                          BOOL OPTIONS(description="Looked After Child flag"),
    is_young_carer                  BOOL OPTIONS(description="Young carer flag"),

    -- Attendance
    attendance_pct                  NUMERIC OPTIONS(description="Attendance percentage"),

    -- Counting measure
    enrolment_count                 INT64 OPTIONS(description="Always 1, for counting enrolments"),

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
PARTITION BY DATE_TRUNC(academic_year_start_date, YEAR)
CLUSTER BY offering_key, student_key
OPTIONS(
    description="Student enrolment fact table at student-offering grain"
);


-- ---------------------------------------------------------------------
-- marts.fct_alps_subject_performance
-- ALPS provider benchmarking at subject level
-- Grain: One row per subject per academic year
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `analytics.fct_alps_subject_performance` (
    -- Primary key
    alps_subject_performance_key    INT64 NOT NULL OPTIONS(description="Surrogate key for ALPS performance fact"),

    -- Dimension foreign keys
    academic_year_key               INT64 NOT NULL OPTIONS(description="FK to dim_academic_year"),
    offering_key                    INT64 OPTIONS(description="FK to dim_offering (via mapping)"),

    -- ALPS identifiers
    alps_subject_name               STRING NOT NULL OPTIONS(description="Subject name from ALPS report"),
    alps_qualification_type         STRING OPTIONS(description="Qualification type: 'A-Level', 'BTEC'"),

    -- Subject mapping status
    subject_mapping_status          STRING OPTIONS(description="Mapping status: 'Matched', 'Unmapped'"),
    mapping_confidence_pct          NUMERIC OPTIONS(description="Mapping confidence score (0-100)"),

    -- Cohort measure
    cohort_count                    INT64 OPTIONS(description="Number of students in cohort"),
    average_gcse_on_entry           NUMERIC OPTIONS(description="Average GCSE on entry"),

    -- ALPS benchmarking metrics
    alps_band                       INT64 OPTIONS(description="ALPS band (1-9, 1=best)"),
    alps_score                      NUMERIC OPTIONS(description="ALPS score"),
    value_added_score               NUMERIC OPTIONS(description="Value-added score"),
    national_benchmark_grade        STRING OPTIONS(description="National benchmark grade"),

    -- Performance percentages
    pass_rate_pct                   NUMERIC OPTIONS(description="Pass rate percentage"),
    high_grades_pct                 NUMERIC OPTIONS(description="High grades percentage"),

    -- Metadata
    alps_report_date                DATE OPTIONS(description="Date of ALPS report"),
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
CLUSTER BY academic_year_key, alps_subject_name
OPTIONS(
    description="ALPS subject-level benchmarking fact table"
);


-- ---------------------------------------------------------------------
-- marts.fct_college_performance
-- College-level performance from Six Dimensions reports
-- Grain: One row per report type per academic year
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `analytics.fct_college_performance` (
    -- Primary key
    college_performance_key         INT64 NOT NULL OPTIONS(description="Surrogate key for college performance fact"),

    -- Dimension foreign key
    academic_year_key               INT64 NOT NULL OPTIONS(description="FK to dim_academic_year"),

    -- Source identifiers
    report_type                     STRING OPTIONS(description="Report type: 'VA', 'Sixth Sense'"),
    report_name                     STRING OPTIONS(description="Full report name"),

    -- Cohort measures
    total_cohort_count              INT64 OPTIONS(description="Total student cohort"),

    -- Performance metrics (aggregated from Sixth Sense)
    avg_pass_rate_pct               NUMERIC OPTIONS(description="Average pass rate"),
    avg_high_grades_pct             NUMERIC OPTIONS(description="Average high grade rate"),
    avg_completion_rate_pct         NUMERIC OPTIONS(description="Average completion rate"),
    avg_retention_rate_pct          NUMERIC OPTIONS(description="Average retention rate"),
    avg_achievement_rate_pct        NUMERIC OPTIONS(description="Average achievement rate"),
    avg_attendance_rate_pct         NUMERIC OPTIONS(description="Average attendance rate"),

    -- Value-added metrics (from VA reports)
    avg_value_added_score           NUMERIC OPTIONS(description="Average VA score"),
    avg_confidence_lower            NUMERIC OPTIONS(description="Average VA confidence lower bound"),
    avg_confidence_upper            NUMERIC OPTIONS(description="Average VA confidence upper bound"),

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
-- Subject-level benchmarking from Six Dimensions reports
-- Grain: One row per subject per report type per academic year
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `analytics.fct_subject_benchmark` (
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
    mapping_confidence_pct          NUMERIC OPTIONS(description="Mapping confidence score"),

    -- Cohort
    cohort_count                    INT64 OPTIONS(description="Subject cohort size"),
    average_gcse_on_entry           NUMERIC OPTIONS(description="Average GCSE on entry"),

    -- Performance metrics
    pass_rate_pct                   NUMERIC OPTIONS(description="Subject pass rate"),
    high_grades_pct                 NUMERIC OPTIONS(description="Subject high grade rate"),
    completion_rate_pct             NUMERIC OPTIONS(description="Completion rate"),
    achievement_rate_pct            NUMERIC OPTIONS(description="Achievement rate"),

    -- Value-added metrics (from VA reports)
    value_added_score               NUMERIC OPTIONS(description="Subject VA score"),
    residual_score                  NUMERIC OPTIONS(description="VA residual"),
    expected_grade                  STRING OPTIONS(description="Expected grade"),
    actual_avg_grade                STRING OPTIONS(description="Actual average grade"),
    performance_band                STRING OPTIONS(description="VA performance band"),
    confidence_interval_lower       NUMERIC OPTIONS(description="VA confidence lower"),
    confidence_interval_upper       NUMERIC OPTIONS(description="VA confidence upper"),

    -- Sixth Sense metrics
    performance_quartile            STRING OPTIONS(description="Performance quartile"),

    -- Trend indicators
    performance_trajectory          STRING OPTIONS(description="Trajectory: 'Improving', 'Stable', 'Declining'"),
    yoy_change_pct                  NUMERIC OPTIONS(description="Year-over-year change"),

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
-- Demographic equity gaps from JEDI reports
-- Grain: One row per demographic comparison per academic year
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `analytics.fct_equity_gap` (
    -- Primary key
    equity_gap_key                  INT64 NOT NULL OPTIONS(description="Surrogate key for equity gap fact"),

    -- Dimension foreign key
    academic_year_key               INT64 NOT NULL OPTIONS(description="FK to dim_academic_year"),

    -- Source identifier
    report_type                     STRING OPTIONS(description="Report type: 'JEDI'"),
    dimension_name                  STRING NOT NULL OPTIONS(description="Dimension: 'Gender', 'Disadvantage', 'Ethnicity', 'SEND'"),

    -- Group comparison
    student_group                   STRING NOT NULL OPTIONS(description="Student group being analysed"),
    comparison_group                STRING OPTIONS(description="Comparison group"),

    -- Cohort metrics
    student_count                   INT64 OPTIONS(description="Student group count"),
    comparison_count                INT64 OPTIONS(description="Comparison group count"),

    -- Performance metrics
    student_avg_grade_points        NUMERIC OPTIONS(description="Student group average grade points"),
    comparison_avg_grade_points     NUMERIC OPTIONS(description="Comparison group average grade points"),

    -- Gap analysis
    gap_grade_points                NUMERIC OPTIONS(description="Gap in grade points"),
    gap_significance                STRING OPTIONS(description="Gap significance"),
    performance_band                STRING OPTIONS(description="Performance band classification"),

    -- Trend indicators
    prior_year_gap                  NUMERIC OPTIONS(description="Gap in prior year"),
    gap_change_yoy                  NUMERIC OPTIONS(description="Year-over-year gap change"),
    gap_trend                       STRING OPTIONS(description="Gap trend: 'Narrowing', 'Stable', 'Widening'"),

    -- Metadata
    report_date                     DATE OPTIONS(description="Report date"),
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
CLUSTER BY academic_year_key, dimension_name
OPTIONS(
    description="Demographic equity gap analysis from JEDI reports"
);


-- =====================================================================
-- SEEDS LAYER: REFERENCE/MAPPING TABLES
-- Schema: seeds (analytics_seed in BigQuery)
-- =====================================================================

-- ---------------------------------------------------------------------
-- seeds.seed_subject_crosswalk
-- Subject name mapping between systems
-- Grain: One row per subject mapping
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `analytics_seed.seed_subject_crosswalk` (
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
    match_confidence_pct            NUMERIC OPTIONS(description="Match confidence (0-100)"),
    is_verified                     BOOL OPTIONS(description="Flag indicating SME verification"),
    verified_by                     STRING OPTIONS(description="Verifier name"),
    verified_date                   DATE OPTIONS(description="Verification date")
)
OPTIONS(
    description="Subject name crosswalk for multi-system mapping"
);


-- ---------------------------------------------------------------------
-- seeds.seed_grade_points
-- Grade to points conversion reference
-- Grain: One row per grade per qualification type
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `analytics_seed.seed_grade_points` (
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
-- INTERMEDIATE LAYER: INTEGRATION VIEWS
-- Schema: intermediate (analytics_integration in BigQuery)
-- =====================================================================

-- ---------------------------------------------------------------------
-- intermediate.int_alps_performance_unioned
-- Union of A-Level and BTEC ALPS performance data
-- Grain: One row per subject per qualification type per academic year
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW `analytics_integration.int_alps_performance_unioned` AS
-- Union A-Level and BTEC ALPS data with common columns
-- See dbt model for implementation
SELECT * FROM UNNEST([]) -- Placeholder
OPTIONS(
    description="Unioned ALPS performance data (A-Level and BTEC)"
);


-- ---------------------------------------------------------------------
-- intermediate.int_six_dimensions_college_unioned
-- Aggregated college-level performance from Six Dimensions
-- Grain: One row per report type per academic year
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW `analytics_integration.int_six_dimensions_college_unioned` AS
-- Aggregate college-level metrics from VA and Sixth Sense reports
-- See dbt model for implementation
SELECT * FROM UNNEST([]) -- Placeholder
OPTIONS(
    description="Aggregated college-level Six Dimensions performance"
);


-- ---------------------------------------------------------------------
-- intermediate.int_six_dimensions_subject_unioned
-- Unioned subject-level performance from Six Dimensions
-- Grain: One row per subject per report type per academic year
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW `analytics_integration.int_six_dimensions_subject_unioned` AS
-- Union subject-level metrics from VA, Sixth Sense, and Vocational reports
-- See dbt model for implementation
SELECT * FROM UNNEST([]) -- Placeholder
OPTIONS(
    description="Unioned subject-level Six Dimensions performance"
);


-- ---------------------------------------------------------------------
-- intermediate.int_student_demographics_joined
-- Joined student demographics from multiple sources
-- Grain: One row per student per academic year
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW `analytics_integration.int_student_demographics_joined` AS
-- Join student, student_detail, extended_data, and prior_attainment
-- See dbt model for implementation
SELECT * FROM UNNEST([]) -- Placeholder
OPTIONS(
    description="Joined student demographic data from all sources"
);


-- ---------------------------------------------------------------------
-- intermediate.int_enrolment_with_context
-- Enriched enrolment data with offering and student context
-- Grain: One row per enrolment
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW `analytics_integration.int_enrolment_with_context` AS
-- Join enrolment with offering, student, and demographic context
-- See dbt model for implementation
SELECT * FROM UNNEST([]) -- Placeholder
OPTIONS(
    description="Enriched enrolment data with full context"
);
