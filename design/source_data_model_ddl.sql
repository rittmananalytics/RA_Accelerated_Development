-- =====================================================================
-- Barton Peveril Sixth Form College - Source Data Model DDL
-- Google BigQuery Staging Layer
-- Version: 1.0
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
-- These tables mirror the source system structure
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

    -- Additional attributes (inferred from typical MIS systems)
    start_date                      DATE OPTIONS(description="Offering start date"),
    end_date                        DATE OPTIONS(description="Offering end date"),
    planned_hours                   INT64 OPTIONS(description="Planned guided learning hours"),
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
    offering_id                     INT64 NOT NULL OPTIONS(description="FK to Offering"),
    student_detail_id               INT64 NOT NULL OPTIONS(description="FK to StudentDetail"),
    completion_status_id            INT64 OPTIONS(description="FK to CompletionStatus - 1=Completed, 2=Continuing"),

    -- Grade attributes
    grade                           STRING OPTIONS(description="Achieved grade (A*, A, B, C, D, E, U, X, D*, M, P, etc.)"),
    grade_date                      DATE OPTIONS(description="Date grade was awarded"),
    predicted_grade                 STRING OPTIONS(description="Predicted/target grade"),

    -- Enrolment attributes
    enrolment_date                  DATE OPTIONS(description="Date of enrolment"),
    withdrawal_date                 DATE OPTIONS(description="Date of withdrawal if applicable"),
    withdrawal_reason               STRING OPTIONS(description="Reason for withdrawal"),

    -- Component grades (for modular qualifications)
    component_1_grade               STRING OPTIONS(description="Component 1 grade"),
    component_2_grade               STRING OPTIONS(description="Component 2 grade"),
    component_3_grade               STRING OPTIONS(description="Component 3 grade"),
    coursework_grade                STRING OPTIONS(description="Coursework/NEA grade"),
    exam_grade                      STRING OPTIONS(description="Exam grade"),

    -- Re-sit tracking
    is_resit                        BOOL OPTIONS(description="Re-sit attempt flag"),
    original_enrolment_id           INT64 OPTIONS(description="FK to original enrolment for re-sits"),

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

    -- Demographics
    sex                             STRING OPTIONS(description="Gender code: 'M', 'F'"),
    date_of_birth                   DATE OPTIONS(description="Student date of birth"),
    ethnicity_code                  STRING OPTIONS(description="Ethnicity code"),
    ethnicity_description           STRING OPTIONS(description="Ethnicity description"),

    -- Contact details
    postcode                        STRING OPTIONS(description="Student postcode"),
    home_postcode                   STRING OPTIONS(description="Home postcode"),

    -- Status flags
    is_current                      BOOL OPTIONS(description="Current student flag"),
    learner_status                  STRING OPTIONS(description="Learner status code"),

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
-- raw_prosolution.student
-- Source: ProSolution.dbo.Student
-- Student master record
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_prosolution.student` (
    -- Primary key
    student_id                      INT64 NOT NULL OPTIONS(description="Primary key - ProSolution StudentID"),

    -- Unique identifiers
    uln                             STRING OPTIONS(description="Unique Learner Number"),
    student_ref                     STRING OPTIONS(description="Internal student reference"),

    -- Personal details
    forename                        STRING OPTIONS(description="First name"),
    surname                         STRING OPTIONS(description="Last name"),
    preferred_name                  STRING OPTIONS(description="Preferred name"),
    title                           STRING OPTIONS(description="Title (Mr, Ms, etc.)"),

    -- Dates
    date_of_birth                   DATE OPTIONS(description="Date of birth"),
    first_enrolment_date            DATE OPTIONS(description="First enrolment date at college"),

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
    -- Primary/Foreign key
    student_detail_id               INT64 NOT NULL OPTIONS(description="FK to StudentDetail"),

    -- Disadvantage flags (ED = Economically Disadvantaged)
    ed                              INT64 OPTIONS(description="Economically Disadvantaged flag (1/0)"),

    -- SEN flags
    sen                             INT64 OPTIONS(description="SEN + Additional Adjustments flag (1/0)"),
    sen_type                        STRING OPTIONS(description="SEN type classification"),

    -- Pupil Premium / Free School Meals
    pp_or_fcm                       INT64 OPTIONS(description="Pupil Premium or Free School Meals flag (1/0)"),
    is_pupil_premium                BOOL OPTIONS(description="Pupil Premium eligible"),
    is_free_school_meals            BOOL OPTIONS(description="Free School Meals eligible"),

    -- Bursary
    is_bursary                      BOOL OPTIONS(description="Bursary recipient flag"),
    bursary_type                    STRING OPTIONS(description="Type of bursary"),

    -- Access arrangements
    is_access_plus                  BOOL OPTIONS(description="AccessPlus composite flag"),
    has_additional_adjustments      BOOL OPTIONS(description="Additional Adjustments flag"),

    -- EHCP (Education, Health and Care Plan)
    has_ehcp                        BOOL OPTIONS(description="Has EHCP flag"),

    -- Looked After Children
    is_lac                          BOOL OPTIONS(description="Looked After Child flag"),
    is_care_leaver                  BOOL OPTIONS(description="Care leaver flag"),

    -- Young Carer
    is_young_carer                  BOOL OPTIONS(description="Young carer flag"),

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
    -- Primary/Foreign key
    student_id                      INT64 NOT NULL OPTIONS(description="FK to Student"),

    -- GCSE metrics
    average_gcse                    NUMERIC(8,2) OPTIONS(description="Average GCSE point score"),

    -- Individual subject grades (if available)
    gcse_english_grade              STRING OPTIONS(description="GCSE English grade"),
    gcse_english_points             INT64 OPTIONS(description="GCSE English points"),
    gcse_maths_grade                STRING OPTIONS(description="GCSE Maths grade"),
    gcse_maths_points               INT64 OPTIONS(description="GCSE Maths points"),

    -- Aggregate metrics
    total_gcse_points               INT64 OPTIONS(description="Total GCSE points"),
    gcse_count                      INT64 OPTIONS(description="Number of GCSEs"),
    gcse_a_star_to_c_count          INT64 OPTIONS(description="Number of GCSEs at A*-C/9-4"),

    -- Source information
    gcse_year                       STRING OPTIONS(description="Year GCSEs were taken"),
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
-- RAW LAYER: ALPS SOURCE TABLES (Stage 2)
-- Schema: raw_alps
-- External benchmarking data parsed from ALPS PDF reports
-- =====================================================================

-- ---------------------------------------------------------------------
-- raw_alps.provider_report_a_level
-- Source: ALPS Provider Report (A-Level) - Parsed CSV
-- A-Level subject benchmarking data
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_alps.provider_report_a_level` (
    -- Composite key
    report_year                     STRING NOT NULL OPTIONS(description="Academic year of report"),
    subject_name                    STRING NOT NULL OPTIONS(description="ALPS subject name"),

    -- Cohort
    cohort_size                     INT64 OPTIONS(description="Number of students"),

    -- Grade distribution (counts)
    grade_a_star                    INT64 OPTIONS(description="Count of A* grades"),
    grade_a                         INT64 OPTIONS(description="Count of A grades"),
    grade_b                         INT64 OPTIONS(description="Count of B grades"),
    grade_c                         INT64 OPTIONS(description="Count of C grades"),
    grade_d                         INT64 OPTIONS(description="Count of D grades"),
    grade_e                         INT64 OPTIONS(description="Count of E grades"),
    grade_u                         INT64 OPTIONS(description="Count of U grades"),

    -- Grade distribution (percentages - as parsed from PDF)
    pct_a_star                      STRING OPTIONS(description="Percentage A* (raw string from PDF)"),
    pct_a                           STRING OPTIONS(description="Percentage A"),
    pct_b                           STRING OPTIONS(description="Percentage B"),
    pct_c                           STRING OPTIONS(description="Percentage C"),
    pct_d                           STRING OPTIONS(description="Percentage D"),
    pct_e                           STRING OPTIONS(description="Percentage E"),
    pct_u                           STRING OPTIONS(description="Percentage U"),

    -- ALPS metrics
    alps_grade                      STRING OPTIONS(description="ALPS grade/band (1-9)"),
    alps_score                      STRING OPTIONS(description="ALPS score (raw)"),
    t_score                         STRING OPTIONS(description="T-score"),

    -- Averages
    avg_points                      STRING OPTIONS(description="Average points"),
    avg_grade                       STRING OPTIONS(description="Average grade"),

    -- Source metadata
    report_filename                 STRING OPTIONS(description="Source PDF filename"),
    report_date                     DATE OPTIONS(description="Report generation date"),
    parsed_at                       TIMESTAMP OPTIONS(description="When PDF was parsed"),

    -- Metadata
    _sdc_extracted_at               TIMESTAMP,
    _sdc_received_at                TIMESTAMP,
    _sdc_batched_at                 TIMESTAMP
)
OPTIONS(
    description="Raw ALPS A-Level provider benchmarking data parsed from PDF"
);


-- ---------------------------------------------------------------------
-- raw_alps.provider_report_btec
-- Source: ALPS Provider Report (BTEC) - Parsed CSV
-- BTEC subject benchmarking data
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_alps.provider_report_btec` (
    -- Composite key
    report_year                     STRING NOT NULL OPTIONS(description="Academic year of report"),
    subject_name                    STRING NOT NULL OPTIONS(description="ALPS subject name"),
    qualification_size              STRING OPTIONS(description="Single, Double, Extended"),

    -- Cohort
    cohort_size                     INT64 OPTIONS(description="Number of students"),

    -- Single Award grade distribution
    grade_d_star                    INT64 OPTIONS(description="Count of D* (Distinction*)"),
    grade_d                         INT64 OPTIONS(description="Count of D (Distinction)"),
    grade_m                         INT64 OPTIONS(description="Count of M (Merit)"),
    grade_p                         INT64 OPTIONS(description="Count of P (Pass)"),

    -- Double Award grade distribution
    grade_d_star_d_star             INT64 OPTIONS(description="Count of D*D*"),
    grade_d_star_d                  INT64 OPTIONS(description="Count of D*D"),
    grade_dd                        INT64 OPTIONS(description="Count of DD"),
    grade_dm                        INT64 OPTIONS(description="Count of DM"),
    grade_mm                        INT64 OPTIONS(description="Count of MM"),
    grade_mp                        INT64 OPTIONS(description="Count of MP"),
    grade_pp                        INT64 OPTIONS(description="Count of PP"),

    -- Percentages (raw strings from PDF)
    pct_d_star                      STRING OPTIONS(description="Percentage D*"),
    pct_d                           STRING OPTIONS(description="Percentage D"),
    pct_m                           STRING OPTIONS(description="Percentage M"),
    pct_p                           STRING OPTIONS(description="Percentage P"),

    -- ALPS metrics
    alps_grade                      STRING OPTIONS(description="ALPS grade/band"),
    alps_score                      STRING OPTIONS(description="ALPS score (raw)"),

    -- Source metadata
    report_filename                 STRING OPTIONS(description="Source PDF filename"),
    report_date                     DATE OPTIONS(description="Report generation date"),
    parsed_at                       TIMESTAMP OPTIONS(description="When PDF was parsed"),

    -- Metadata
    _sdc_extracted_at               TIMESTAMP,
    _sdc_received_at                TIMESTAMP,
    _sdc_batched_at                 TIMESTAMP
)
OPTIONS(
    description="Raw ALPS BTEC provider benchmarking data parsed from PDF"
);


-- =====================================================================
-- RAW LAYER: SIX DIMENSIONS SOURCE TABLES (Stage 3)
-- Schema: raw_six_dimensions
-- External benchmarking data parsed from Six Dimensions PDF reports
-- =====================================================================

-- ---------------------------------------------------------------------
-- raw_six_dimensions.jedi_report
-- Source: Six Dimensions JEDI Reports (7 PDFs) - Parsed CSV
-- Justice, Equity, Diversity, Inclusion analysis
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_six_dimensions.jedi_report` (
    -- Composite key
    report_year                     STRING NOT NULL OPTIONS(description="Academic year of report"),
    demographic_category            STRING NOT NULL OPTIONS(description="Category: Gender, Disadvantage, Ethnicity, SEND"),
    demographic_value               STRING NOT NULL OPTIONS(description="Specific value within category"),

    -- Cohort metrics
    cohort_size                     STRING OPTIONS(description="Cohort size (raw string)"),
    pct_of_total                    STRING OPTIONS(description="Percentage of total cohort"),

    -- Attainment metrics (raw strings)
    pass_rate                       STRING OPTIONS(description="Pass rate"),
    high_grade_rate                 STRING OPTIONS(description="High grade rate (A*-B / D*-M)"),
    avg_points                      STRING OPTIONS(description="Average points"),

    -- Value-added metrics
    va_score                        STRING OPTIONS(description="Value-added score"),
    va_band                         STRING OPTIONS(description="VA band classification"),

    -- Gap metrics
    gap_vs_overall                  STRING OPTIONS(description="Gap vs overall cohort"),
    gap_vs_national                 STRING OPTIONS(description="Gap vs national"),

    -- National benchmarks
    national_pass_rate              STRING OPTIONS(description="National pass rate for subgroup"),
    national_high_grade             STRING OPTIONS(description="National high grade rate"),

    -- Source metadata
    report_filename                 STRING OPTIONS(description="Source PDF filename"),
    report_type                     STRING OPTIONS(description="Report type identifier"),
    report_date                     DATE OPTIONS(description="Report generation date"),
    parsed_at                       TIMESTAMP OPTIONS(description="When PDF was parsed"),

    -- Metadata
    _sdc_extracted_at               TIMESTAMP,
    _sdc_received_at                TIMESTAMP,
    _sdc_batched_at                 TIMESTAMP
)
OPTIONS(
    description="Raw Six Dimensions JEDI equity analysis data parsed from PDF"
);


-- ---------------------------------------------------------------------
-- raw_six_dimensions.va_report
-- Source: Six Dimensions VA Reports (9 PDFs) - Parsed CSV
-- Value-Added analysis at subject and college level
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_six_dimensions.va_report` (
    -- Composite key
    report_year                     STRING NOT NULL OPTIONS(description="Academic year of report"),
    level                           STRING NOT NULL OPTIONS(description="Level: College, Subject"),
    subject_name                    STRING OPTIONS(description="Subject name (NULL for college level)"),

    -- Cohort
    cohort_size                     STRING OPTIONS(description="Cohort size (raw)"),

    -- Attainment metrics
    pass_rate                       STRING OPTIONS(description="Pass rate"),
    high_grade_rate                 STRING OPTIONS(description="High grade rate"),
    avg_grade                       STRING OPTIONS(description="Average grade"),
    avg_points                      STRING OPTIONS(description="Average points"),

    -- Value-added metrics
    va_score                        STRING OPTIONS(description="VA score"),
    va_residual                     STRING OPTIONS(description="VA residual"),
    va_band                         STRING OPTIONS(description="VA band"),
    va_percentile                   STRING OPTIONS(description="VA percentile rank"),
    va_confidence_lower             STRING OPTIONS(description="VA confidence interval lower"),
    va_confidence_upper             STRING OPTIONS(description="VA confidence interval upper"),

    -- National comparison
    national_percentile             STRING OPTIONS(description="National percentile"),
    national_rank                   STRING OPTIONS(description="National rank"),

    -- Source metadata
    report_filename                 STRING,
    report_type                     STRING,
    report_date                     DATE,
    parsed_at                       TIMESTAMP,

    -- Metadata
    _sdc_extracted_at               TIMESTAMP,
    _sdc_received_at                TIMESTAMP,
    _sdc_batched_at                 TIMESTAMP
)
OPTIONS(
    description="Raw Six Dimensions Value-Added analysis data parsed from PDF"
);


-- ---------------------------------------------------------------------
-- raw_six_dimensions.sixth_sense_report
-- Source: Six Dimensions Sixth Sense Reports (16 PDFs) - Parsed CSV
-- Comprehensive performance analysis similar to VA with high grades focus
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_six_dimensions.sixth_sense_report` (
    -- Composite key
    report_year                     STRING NOT NULL OPTIONS(description="Academic year of report"),
    level                           STRING NOT NULL OPTIONS(description="Level: College, Subject"),
    subject_name                    STRING OPTIONS(description="Subject name"),
    qualification_type              STRING OPTIONS(description="A-Level, BTEC, etc."),

    -- Cohort
    cohort_size                     STRING OPTIONS(description="Cohort size"),

    -- Attainment metrics
    pass_rate                       STRING OPTIONS(description="Pass rate"),
    high_grade_rate                 STRING OPTIONS(description="High grade rate (A*-B)"),
    a_star_rate                     STRING OPTIONS(description="A* rate"),
    a_star_a_rate                   STRING OPTIONS(description="A*-A rate"),
    avg_points                      STRING OPTIONS(description="Average points"),

    -- Sixth Sense score
    sixth_sense_score               STRING OPTIONS(description="Sixth Sense composite score"),
    sixth_sense_band                STRING OPTIONS(description="Sixth Sense band"),

    -- Value-added
    va_score                        STRING OPTIONS(description="VA score"),
    va_band                         STRING OPTIONS(description="VA band"),

    -- National comparison
    national_pass_rate              STRING OPTIONS(description="National pass rate"),
    national_high_grade             STRING OPTIONS(description="National high grade rate"),
    percentile_rank                 STRING OPTIONS(description="Percentile rank"),

    -- Source metadata
    report_filename                 STRING,
    report_type                     STRING,
    report_date                     DATE,
    parsed_at                       TIMESTAMP,

    -- Metadata
    _sdc_extracted_at               TIMESTAMP,
    _sdc_received_at                TIMESTAMP,
    _sdc_batched_at                 TIMESTAMP
)
OPTIONS(
    description="Raw Six Dimensions Sixth Sense analysis data parsed from PDF"
);


-- ---------------------------------------------------------------------
-- raw_six_dimensions.vocational_report
-- Source: Six Dimensions Vocational Reports (12 PDFs) - Parsed CSV
-- Vocational qualification benchmarking (5 datasets per PDF)
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `raw_six_dimensions.vocational_report` (
    -- Composite key
    report_year                     STRING NOT NULL OPTIONS(description="Academic year of report"),
    dataset_name                    STRING NOT NULL OPTIONS(description="Dataset within report (1 of 5)"),
    level                           STRING OPTIONS(description="Level: College, Subject"),
    subject_name                    STRING OPTIONS(description="Subject/qualification name"),
    qualification_type              STRING OPTIONS(description="BTEC, Cambridge Technical, etc."),
    qualification_size              STRING OPTIONS(description="Certificate, Extended Certificate, Diploma"),

    -- Cohort
    cohort_size                     STRING OPTIONS(description="Cohort size"),

    -- Grade distribution (BTEC-style)
    pct_distinction_star            STRING OPTIONS(description="% D*"),
    pct_distinction                 STRING OPTIONS(description="% D"),
    pct_merit                       STRING OPTIONS(description="% M"),
    pct_pass                        STRING OPTIONS(description="% P"),

    -- Attainment metrics
    pass_rate                       STRING OPTIONS(description="Pass rate"),
    high_grade_rate                 STRING OPTIONS(description="High grade rate (D*-M)"),
    avg_points                      STRING OPTIONS(description="Average points"),

    -- Value-added
    va_score                        STRING OPTIONS(description="VA score"),
    va_band                         STRING OPTIONS(description="VA band"),

    -- National comparison
    national_pass_rate              STRING OPTIONS(description="National pass rate"),
    national_high_grade             STRING OPTIONS(description="National high grade"),
    percentile_rank                 STRING OPTIONS(description="Percentile rank"),

    -- Source metadata
    report_filename                 STRING,
    report_type                     STRING,
    dataset_index                   INT64 OPTIONS(description="Dataset index within PDF (1-5)"),
    report_date                     DATE,
    parsed_at                       TIMESTAMP,

    -- Metadata
    _sdc_extracted_at               TIMESTAMP,
    _sdc_received_at                TIMESTAMP,
    _sdc_batched_at                 TIMESTAMP
)
OPTIONS(
    description="Raw Six Dimensions Vocational benchmarking data parsed from PDF"
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

    -- Derived
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
    offering_id                     INT64 NOT NULL,
    student_detail_id               INT64 NOT NULL,
    completion_status_id            INT64,

    -- Grade (cleaned and validated)
    grade                           STRING,
    grade_date                      DATE,
    predicted_grade                 STRING,

    -- Status flags
    is_completed                    BOOL,
    is_continuing                   BOOL,
    is_withdrawn                    BOOL,

    -- Re-sit tracking
    is_resit                        BOOL,
    original_enrolment_id           INT64,

    -- Component grades
    component_1_grade               STRING,
    component_2_grade               STRING,
    component_3_grade               STRING,

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Staged enrolment data from ProSolution"
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

    -- Demographics (cleaned)
    gender_code                     STRING OPTIONS(description="Normalized: 'M', 'F'"),
    gender                          STRING OPTIONS(description="Expanded: 'Male', 'Female'"),
    date_of_birth                   DATE,
    ethnicity_code                  STRING,
    ethnicity_description           STRING,
    ethnicity_group                 STRING OPTIONS(description="Grouped ethnicity for analysis"),

    -- Location
    postcode                        STRING,
    postcode_area                   STRING OPTIONS(description="First part of postcode"),

    -- Flags
    is_current                      BOOL,

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Staged student detail data from ProSolution"
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
    student_ref                     STRING,

    -- Dates
    date_of_birth                   DATE,
    first_enrolment_date            DATE,

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Staged student master data from ProSolution"
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
    subject_area                    STRING,
    department                      STRING,

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
    offering_type_category          STRING,
    qualification_level             STRING,
    grading_scale                   STRING,

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
    -- Foreign key
    student_detail_id               INT64 NOT NULL,

    -- Demographic flags (converted to BOOL)
    is_disadvantaged                BOOL OPTIONS(description="Economically Disadvantaged"),
    is_sen                          BOOL OPTIONS(description="SEN + Additional Adjustments"),
    is_pupil_premium                BOOL OPTIONS(description="Pupil Premium eligible"),
    is_free_school_meals            BOOL OPTIONS(description="Free School Meals eligible"),
    is_pp_or_fcm                    BOOL OPTIONS(description="PP or FSM"),
    is_bursary_recipient            BOOL,
    is_access_plus                  BOOL,
    has_additional_adjustments      BOOL,
    has_ehcp                        BOOL,
    is_lac                          BOOL OPTIONS(description="Looked After Child"),
    is_care_leaver                  BOOL,
    is_young_carer                  BOOL,

    -- Classification
    sen_type                        STRING,
    bursary_type                    STRING,

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
    -- Foreign key
    student_id                      INT64 NOT NULL,

    -- GCSE metrics (typed)
    average_gcse_score              NUMERIC(8,2),

    -- Prior attainment band (derived)
    prior_attainment_band           STRING OPTIONS(description="Low (<4.77), Mid (4.77-6.09), High (>6.09), N/A"),
    prior_attainment_band_code      INT64 OPTIONS(description="0=N/A, 1=Low, 2=Mid, 3=High"),

    -- Individual subjects
    gcse_english_grade              STRING,
    gcse_maths_grade                STRING,

    -- Aggregates
    total_gcse_points               INT64,
    gcse_count                      INT64,

    -- Source
    gcse_year                       STRING,

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
    academic_year_id                STRING NOT NULL,
    alps_subject_name               STRING NOT NULL,

    -- Cohort
    cohort_count                    INT64,

    -- Grade distribution (typed)
    grade_a_star_count              INT64,
    grade_a_count                   INT64,
    grade_b_count                   INT64,
    grade_c_count                   INT64,
    grade_d_count                   INT64,
    grade_e_count                   INT64,
    grade_u_count                   INT64,

    -- Percentages (cleaned and typed)
    grade_a_star_pct                NUMERIC(5,2),
    grade_a_pct                     NUMERIC(5,2),
    grade_b_pct                     NUMERIC(5,2),
    grade_c_pct                     NUMERIC(5,2),
    grade_d_pct                     NUMERIC(5,2),
    grade_e_pct                     NUMERIC(5,2),
    grade_u_pct                     NUMERIC(5,2),

    -- ALPS metrics (typed)
    alps_band                       INT64,
    alps_score                      NUMERIC(5,2),
    t_score                         NUMERIC(5,2),

    -- Averages
    average_grade_points            NUMERIC(8,2),

    -- Source metadata
    report_filename                 STRING,
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
    academic_year_id                STRING NOT NULL,
    alps_subject_name               STRING NOT NULL,
    qualification_size              STRING,

    -- Cohort
    cohort_count                    INT64,

    -- Single Award grades (typed)
    btec_distinction_star_count     INT64,
    btec_distinction_count          INT64,
    btec_merit_count                INT64,
    btec_pass_count                 INT64,

    -- Double Award grades (typed)
    btec_d_star_d_star_count        INT64,
    btec_d_star_d_count             INT64,
    btec_dd_count                   INT64,
    btec_dm_count                   INT64,
    btec_mm_count                   INT64,
    btec_mp_count                   INT64,
    btec_pp_count                   INT64,

    -- Percentages
    btec_distinction_star_pct       NUMERIC(5,2),
    btec_distinction_pct            NUMERIC(5,2),
    btec_merit_pct                  NUMERIC(5,2),
    btec_pass_pct                   NUMERIC(5,2),

    -- ALPS metrics
    alps_band                       INT64,
    alps_score                      NUMERIC(5,2),

    -- Source metadata
    report_filename                 STRING,
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
    academic_year_id                STRING NOT NULL,
    demographic_category            STRING NOT NULL,
    demographic_value               STRING NOT NULL,

    -- Cohort (typed)
    cohort_count                    INT64,
    cohort_pct                      NUMERIC(5,2),

    -- Attainment (typed)
    pass_rate_pct                   NUMERIC(5,2),
    high_grade_rate_pct             NUMERIC(5,2),
    average_points                  NUMERIC(8,2),

    -- Value-added (typed)
    va_score                        NUMERIC(8,4),
    va_band                         STRING,

    -- Gaps (typed)
    gap_vs_overall_pct              NUMERIC(5,2),
    gap_vs_national_pct             NUMERIC(5,2),

    -- National benchmarks
    national_pass_rate_pct          NUMERIC(5,2),
    national_high_grade_pct         NUMERIC(5,2),

    -- Source metadata
    report_filename                 STRING,
    report_type                     STRING,
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
    academic_year_id                STRING NOT NULL,
    level                           STRING NOT NULL,
    subject_name                    STRING,

    -- Cohort
    cohort_count                    INT64,

    -- Attainment (typed)
    pass_rate_pct                   NUMERIC(5,2),
    high_grade_rate_pct             NUMERIC(5,2),
    average_points                  NUMERIC(8,2),

    -- Value-added (typed)
    va_score                        NUMERIC(8,4),
    va_residual                     NUMERIC(8,4),
    va_band                         STRING,
    va_percentile                   NUMERIC(5,2),
    va_confidence_lower             NUMERIC(8,4),
    va_confidence_upper             NUMERIC(8,4),

    -- National comparison
    national_percentile             NUMERIC(5,2),
    national_rank                   INT64,

    -- Source metadata
    report_filename                 STRING,
    report_type                     STRING,
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
    academic_year_id                STRING NOT NULL,
    level                           STRING NOT NULL,
    subject_name                    STRING,
    qualification_type              STRING,

    -- Cohort
    cohort_count                    INT64,

    -- Attainment (typed)
    pass_rate_pct                   NUMERIC(5,2),
    high_grade_rate_pct             NUMERIC(5,2),
    a_star_rate_pct                 NUMERIC(5,2),
    a_star_a_rate_pct               NUMERIC(5,2),
    average_points                  NUMERIC(8,2),

    -- Sixth Sense metrics
    sixth_sense_score               NUMERIC(8,4),
    sixth_sense_band                STRING,

    -- Value-added
    va_score                        NUMERIC(8,4),
    va_band                         STRING,

    -- National comparison
    national_pass_rate_pct          NUMERIC(5,2),
    national_high_grade_pct         NUMERIC(5,2),
    percentile_rank                 NUMERIC(5,2),

    -- Source metadata
    report_filename                 STRING,
    report_type                     STRING,
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
    academic_year_id                STRING NOT NULL,
    dataset_name                    STRING NOT NULL,
    level                           STRING,
    subject_name                    STRING,
    qualification_type              STRING,
    qualification_size              STRING,

    -- Cohort
    cohort_count                    INT64,

    -- Grade distribution (typed)
    distinction_star_pct            NUMERIC(5,2),
    distinction_pct                 NUMERIC(5,2),
    merit_pct                       NUMERIC(5,2),
    pass_pct                        NUMERIC(5,2),

    -- Attainment
    pass_rate_pct                   NUMERIC(5,2),
    high_grade_rate_pct             NUMERIC(5,2),
    average_points                  NUMERIC(8,2),

    -- Value-added
    va_score                        NUMERIC(8,4),
    va_band                         STRING,

    -- National comparison
    national_pass_rate_pct          NUMERIC(5,2),
    national_high_grade_pct         NUMERIC(5,2),
    percentile_rank                 NUMERIC(5,2),

    -- Source metadata
    report_filename                 STRING,
    report_type                     STRING,
    dataset_index                   INT64,
    report_date                     DATE,

    -- Metadata
    record_source                   STRING,
    loaded_at                       TIMESTAMP
)
OPTIONS(
    description="Staged Six Dimensions Vocational data"
);
