-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2018-10-19 17:31:48.014

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
DROP SCHEMA IF EXISTS med_img CASCADE;
CREATE SCHEMA med_img;

-- tables
-- Table: Instance
CREATE TABLE med_img.Instance (
    uuid uuid  NOT NULL DEFAULT uuid_generate_v4(),
    series_uuid uuid  NOT NULL,
    comment text  NULL,
    original boolean  NOT NULL DEFAULT true,
    image pgcv_core.ndarray_int4  NOT NULL,
    created_at timestamp  NOT NULL DEFAULT current_timestamp,
    updated_at timestamp  NOT NULL DEFAULT current_timestamp,
    active boolean  NOT NULL DEFAULT true,
    CONSTRAINT Instance_pk PRIMARY KEY (uuid)
);

COMMENT ON TABLE med_img.Instance IS 'This table stores basic instance/image information inspired by the DICOM standard.';
COMMENT ON COLUMN med_img.Instance.uuid IS 'Universally unique identifier of the instance in the database.';
COMMENT ON COLUMN med_img.Instance.series_uuid IS 'Reference to the uuid of the series.';
COMMENT ON COLUMN med_img.Instance.original IS 'Describes whether an image pixel values were based on source data or have been derived in some manner from the pixel value of one or more other images';
COMMENT ON COLUMN med_img.Instance.image IS 'The datatype containing the image data. Refer to the pgcv PostgreSQL extension.';
COMMENT ON COLUMN med_img.Instance.created_at IS 'Datetime the image pixel data creation started.';
COMMENT ON COLUMN med_img.Instance.updated_at IS 'Datetime the image pixel data was last updated';
COMMENT ON COLUMN med_img.Instance.active IS 'Defines whether an instance is active';

-- Table: Patient
CREATE TABLE med_img.Patient (
    uuid uuid  NOT NULL DEFAULT uuid_generate_v4(),
    given_name varchar(35)  NOT NULL,
    family_name varchar(35)  NOT NULL,
    other_ids jsonb  NULL,
    email varchar(320)  NULL,
    address jsonb  NOT NULL,
    sex smallint  NOT NULL,
    birthdate date  NOT NULL,
    created_at timestamp  NOT NULL DEFAULT current_timestamp,
    updated_at timestamp  NOT NULL DEFAULT current_timestamp,
    active boolean  NOT NULL DEFAULT true,
    CONSTRAINT Patient_pk PRIMARY KEY (uuid)
);

COMMENT ON TABLE med_img.Patient IS 'This table stores basic patient information inspired by the DICOM standard.';
COMMENT ON COLUMN med_img.Patient.uuid IS 'Universally unique identifier of the patient in the database.';
COMMENT ON COLUMN med_img.Patient.given_name IS 'The given name of the person.';
COMMENT ON COLUMN med_img.Patient.family_name IS 'The family name of the person, usually the last name.';
COMMENT ON COLUMN med_img.Patient.other_ids IS 'JSON array of alternate identifiers for the patient.';
COMMENT ON COLUMN med_img.Patient.email IS 'Email address of the patient';
COMMENT ON COLUMN med_img.Patient.address IS 'JSON object containing information about the region of the patient, for instance, country, state/province, city';
COMMENT ON COLUMN med_img.Patient.sex IS 'Sex of the patient, according to the ISO/IEC 5218: Codes for the representation of human sexes.';
COMMENT ON COLUMN med_img.Patient.birthdate IS 'Birthdate of the patient';
COMMENT ON COLUMN med_img.Patient.created_at IS 'Date and time when the patient was created';
COMMENT ON COLUMN med_img.Patient.updated_at IS 'Date and time when the patient was last updated';
COMMENT ON COLUMN med_img.Patient.active IS 'Defines whether the patient is active';

-- Table: Region
CREATE TABLE med_img.Region (
    instance_uuid uuid  NOT NULL,
    method varchar(70)  NOT NULL,
    props pgcv_core.regionprops  NOT NULL,
    category varchar(70)  NULL,
    created_at timestamp  NOT NULL DEFAULT current_timestamp,
    updated_at timestamp  NOT NULL DEFAULT current_timestamp,
    active boolean  NOT NULL DEFAULT true,
    CONSTRAINT Region_pk PRIMARY KEY (instance_uuid,method,props)
);

COMMENT ON TABLE med_img.Region IS 'This table stores information about the regions found in an image using a segmentation method';
COMMENT ON COLUMN med_img.Region.instance_uuid IS 'Reference to the uuid of the instance.';
COMMENT ON COLUMN med_img.Region.method IS 'Method used to extract the region properties. This allows for different segmentation functions';
COMMENT ON COLUMN med_img.Region.props IS 'The datatype containing properties of the region. Refer to the pgcv PostgreSQL extension.';
COMMENT ON COLUMN med_img.Region.category IS 'Class of region according to a classifier';
COMMENT ON COLUMN med_img.Region.created_at IS 'Datetime the region information was extracted from the image';
COMMENT ON COLUMN med_img.Region.updated_at IS 'Datetime the region was last updated';
COMMENT ON COLUMN med_img.Region.active IS 'Defines whether the region is active';

-- Table: Series
CREATE TABLE med_img.Series (
    uuid uuid  NOT NULL DEFAULT uuid_generate_v4(),
    study_uuid uuid  NOT NULL,
    laterality char(1)  NULL,
    description varchar(255)  NOT NULL,
    body_part varchar(35)  NOT NULL,
    created_at timestamp  NOT NULL DEFAULT current_timestamp,
    updated_at timestamp  NOT NULL DEFAULT current_timestamp,
    active boolean  NOT NULL DEFAULT true,
    CONSTRAINT Series_pk PRIMARY KEY (uuid)
);

COMMENT ON TABLE med_img.Series IS 'This table stores basic series information inspired by the DICOM standard.';
COMMENT ON COLUMN med_img.Series.uuid IS 'Universally unique identifier of the series in the database.';
COMMENT ON COLUMN med_img.Series.study_uuid IS 'Reference to the uuid of the study.';
COMMENT ON COLUMN med_img.Series.laterality IS 'Laterality of (paired) body part examined. Required if the body part examined is a paired structure. R = right, L = left';
COMMENT ON COLUMN med_img.Series.description IS 'User provided description of the Series';
COMMENT ON COLUMN med_img.Series.body_part IS 'Text description of the part of the body examined';
COMMENT ON COLUMN med_img.Series.created_at IS 'Date and time when the series started';
COMMENT ON COLUMN med_img.Series.updated_at IS 'Date and time when the series was last updated';
COMMENT ON COLUMN med_img.Series.active IS 'Defines whether the study is active';

-- Table: Study
CREATE TABLE med_img.Study (
    uuid uuid  NOT NULL DEFAULT uuid_generate_v4(),
    patient_uuid uuid  NOT NULL,
    description varchar(255)  NOT NULL,
    summary jsonb  NULL,
    created_at timestamp  NOT NULL DEFAULT current_timestamp,
    updated_at timestamp  NOT NULL DEFAULT current_timestamp,
    active boolean  NOT NULL DEFAULT true,
    CONSTRAINT Study_pk PRIMARY KEY (uuid)
);

COMMENT ON TABLE med_img.Study IS 'This table stores basic study information inspired by the DICOM standard.';
COMMENT ON COLUMN med_img.Study.uuid IS 'Universally unique identifier of the study in the database.';
COMMENT ON COLUMN med_img.Study.patient_uuid IS 'Reference to the uuid of the patient.';
COMMENT ON COLUMN med_img.Study.description IS 'Description or classification of the Study performed.';
COMMENT ON COLUMN med_img.Study.summary IS 'Stores information about the overall study and reporting information, for instance, the BI-RADS category';
COMMENT ON COLUMN med_img.Study.created_at IS 'Date and time when the study started';
COMMENT ON COLUMN med_img.Study.updated_at IS 'Date and time when the study was last updated';
COMMENT ON COLUMN med_img.Study.active IS 'Defines whether the study is active';

-- views
-- View: instance_thumbnails
CREATE MATERIALIZED VIEW med_img.instance_thumbnails AS
SELECT
       uuid,
       series_uuid,
       pgcv_core.thumbnail_uri_base64(image) AS thumbnail_uri,
       created_at
FROM med_img.Instance
WHERE active = true;

COMMENT ON MATERIALIZED VIEW med_img.instance_thumbnails IS 'Materialized view of the Instance thumbnails. This view provides access to the data URIs of each Instance';
COMMENT ON COLUMN med_img.instance_thumbnails.uuid IS 'Universally unique identifier of the instance in the database.';
COMMENT ON COLUMN med_img.instance_thumbnails.series_uuid IS 'Reference to the uuid of the series.';
COMMENT ON COLUMN med_img.instance_thumbnails.thumbnail_uri IS 'Data URIs of the thumbnail of each Instance';
COMMENT ON COLUMN med_img.instance_thumbnails.created_at IS 'Datetime the Instance was created';

CREATE OR REPLACE FUNCTION med_img.refreshInstanceThumbnails()
  RETURNS TRIGGER AS $_$
BEGIN
  REFRESH MATERIALIZED VIEW med_img.instance_thumbnails WITH DATA;
  RETURN NEW;
END;
$_$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS refreshInstanceThumbnails
ON med_img.Instance;

CREATE TRIGGER refreshInstanceThumbnails
  AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE
  ON med_img.Instance
EXECUTE PROCEDURE med_img.refreshInstanceThumbnails();

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

