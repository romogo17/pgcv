-- Last modification date: 2018-09-14 18:19:12.158

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
DROP SCHEMA IF EXISTS med_img CASCADE;
CREATE SCHEMA med_img;

-- tables
-- Table: Instance
CREATE TABLE med_img.Instance (
    uuid uuid  NOT NULL DEFAULT uuid_generate_v4(),
    series_uuid uuid  NOT NULL,
    created timestamp  NOT NULL DEFAULT current_timestamp,
    comment text  NULL,
    original boolean  NOT NULL DEFAULT true,
    image pgcv_core.ndarray_int4  NOT NULL,
    CONSTRAINT Instance_pk PRIMARY KEY (uuid)
);

COMMENT ON TABLE med_img.Instance IS 'This table stores basic instance/image information inspired by the DICOM standard.';
COMMENT ON COLUMN med_img.Instance.uuid IS 'Universally unique identifier of the instance in the database.';
COMMENT ON COLUMN med_img.Instance.series_uuid IS 'Reference to the uuid of the series.';
COMMENT ON COLUMN med_img.Instance.created IS 'Datetime the image pixel data creation started.';
COMMENT ON COLUMN med_img.Instance.original IS 'Describes whether an image pixel values were based on source data or have been derived in some manner from the pixel value of one or more other images';
COMMENT ON COLUMN med_img.Instance.image IS 'The datatype containing the image data. Refer to the pgcv PostgreSQL extension.';

-- Table: Patient
CREATE TABLE med_img.Patient (
    uuid uuid  NOT NULL DEFAULT uuid_generate_v4(),
    given_name varchar(35)  NOT NULL,
    family_name varchar(35)  NOT NULL,
    other_ids jsonb  NULL,
    email varchar(320)  NULL,
    region jsonb  NOT NULL,
    sex smallint  NOT NULL,
    birthdate date  NOT NULL,
    CONSTRAINT Patient_pk PRIMARY KEY (uuid)
);

COMMENT ON TABLE med_img.Patient IS 'This table stores basic patient information inspired by the DICOM standard.';
COMMENT ON COLUMN med_img.Patient.uuid IS 'Universally unique identifier of the patient in the database.';
COMMENT ON COLUMN med_img.Patient.given_name IS 'The given name of the person.';
COMMENT ON COLUMN med_img.Patient.family_name IS 'The family name of the person, usually the last name.';
COMMENT ON COLUMN med_img.Patient.other_ids IS 'JSON array of alternate identifiers for the patient.';
COMMENT ON COLUMN med_img.Patient.email IS 'Email address of the patient';
COMMENT ON COLUMN med_img.Patient.region IS 'JSON object containing information about the region of the patient, for instance, country, state/province, city';
COMMENT ON COLUMN med_img.Patient.sex IS 'Sex of the patient, according to the ISO/IEC 5218: Codes for the representation of human sexes.';
COMMENT ON COLUMN med_img.Patient.birthdate IS 'Birthdate of the patient';

-- Table: Region
CREATE TABLE med_img.Region (
    instance_uuid uuid  NOT NULL,
    created timestamp  NOT NULL DEFAULT current_timestamp,
    method varchar(70)  NOT NULL,
    props pgcv_core.regionprops  NOT NULL,
    category varchar(70)  NULL,
    CONSTRAINT Region_pk PRIMARY KEY (instance_uuid,method,props)
);

COMMENT ON TABLE med_img.Region IS 'This table stores information about the regions found in an image using a segmentation method';
COMMENT ON COLUMN med_img.Region.instance_uuid IS 'Reference to the uuid of the instance.';
COMMENT ON COLUMN med_img.Region.created IS 'Datetime the region information was extracted from the image';
COMMENT ON COLUMN med_img.Region.method IS 'Method used to extract the region properties. This allows for different segmentation functions';
COMMENT ON COLUMN med_img.Region.props IS 'The datatype containing properties of the region. Refer to the pgcv PostgreSQL extension.';
COMMENT ON COLUMN med_img.Region.category IS 'Class of region according to a classifier';

-- Table: Series
CREATE TABLE med_img.Series (
    uuid uuid  NOT NULL DEFAULT uuid_generate_v4(),
    study_uuid uuid  NOT NULL,
    created timestamp  NOT NULL DEFAULT current_timestamp,
    laterality char(1)  NULL,
    description varchar(255)  NOT NULL,
    body_part varchar(35)  NOT NULL,
    CONSTRAINT Series_pk PRIMARY KEY (uuid)
);

COMMENT ON TABLE med_img.Series IS 'This table stores basic series information inspired by the DICOM standard.';
COMMENT ON COLUMN med_img.Series.uuid IS 'Universally unique identifier of the series in the database.';
COMMENT ON COLUMN med_img.Series.study_uuid IS 'Reference to the uuid of the study.';
COMMENT ON COLUMN med_img.Series.created IS 'Date and time when the series started';
COMMENT ON COLUMN med_img.Series.laterality IS 'Laterality of (paired) body part examined. Required if the body part examined is a paired structure. R = right, L = left';
COMMENT ON COLUMN med_img.Series.description IS 'User provided description of the Series';
COMMENT ON COLUMN med_img.Series.body_part IS 'Text description of the part of the body examined';

-- Table: Study
CREATE TABLE med_img.Study (
    uuid uuid  NOT NULL DEFAULT uuid_generate_v4(),
    patient_uuid uuid  NOT NULL,
    created timestamp  NOT NULL DEFAULT current_timestamp,
    description varchar(255)  NOT NULL,
    summary jsonb  NULL,
    CONSTRAINT Study_pk PRIMARY KEY (uuid)
);

COMMENT ON TABLE med_img.Study IS 'This table stores basic study information inspired by the DICOM standard.';
COMMENT ON COLUMN med_img.Study.uuid IS 'Universally unique identifier of the study in the database.';
COMMENT ON COLUMN med_img.Study.patient_uuid IS 'Reference to the uuid of the patient.';
COMMENT ON COLUMN med_img.Study.created IS 'Date and time when the study started';
COMMENT ON COLUMN med_img.Study.description IS 'Description or classification of the Study performed.';
COMMENT ON COLUMN med_img.Study.summary IS 'Stores information about the overall study and reporting information, for instance, the BI-RADS category';

-- foreign keys
-- Reference: Image_Series (table: Instance)
ALTER TABLE med_img.Instance ADD CONSTRAINT Image_Series
    FOREIGN KEY (series_uuid)
    REFERENCES med_img.Series (uuid)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: Region_Instance (table: Region)
ALTER TABLE med_img.Region ADD CONSTRAINT Region_Instance
    FOREIGN KEY (instance_uuid)
    REFERENCES med_img.Instance (uuid)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: Series_Study (table: Series)
ALTER TABLE med_img.Series ADD CONSTRAINT Series_Study
    FOREIGN KEY (study_uuid)
    REFERENCES med_img.Study (uuid)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: Study_Patient (table: Study)
ALTER TABLE med_img.Study ADD CONSTRAINT Study_Patient
    FOREIGN KEY (patient_uuid)
    REFERENCES med_img.Patient (uuid)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- End of file.

