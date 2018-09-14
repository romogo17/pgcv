INSERT INTO
  med_img.Patient(given_name, family_name, email, region, sex, birthdate)
VALUES
  ('Maria', 'Hernandez', 'maria@gmail.com', '{"country": "Costa Rica", "province": "Alajuela", "canton": "Grecia"}', 2, '1968-01-08'),
  ('Petra', 'Martinez', 'petra@gmail.com', '{"country": "Costa Rica", "province": "Heredia", "canton": "San Francisco"}', 2, '1958-04-20');
-- SELECT * from med_img.Patient;
-- SELECT * from med_img.Patient where region->>'province' = 'Heredia';

INSERT INTO
  med_img.Study(patient_uuid, description)
VALUES
  ('d5c717ee-6202-4889-a042-059ecf649c5a', 'Digital Mammogram'),
  ('13909736-3b71-443a-9dc5-64ce885653e3', 'Digital Mammogram');
-- SELECT * from med_img.Study;

INSERT INTO
  med_img.Series(study_uuid, laterality, description, body_part)
VALUES
  ('a8e03b9a-3dc6-4c89-af16-4e7d659c724a', 'L', 'MLO projections', 'BREAST'),
  ('9fd67171-b5e0-4165-a2a2-348d0a21b0e3', 'R', 'MLO projections', 'BREAST');
-- SELECT * from med_img.Series;

-- WARNING: Don't 'SELECT *' with this table, you dont want to print 1048576 pixel values to the console. Instead do:
INSERT INTO
  med_img.Instance(series_uuid, image)
VALUES
  ('086c8575-49b8-47b4-82e5-4203a5064835', pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb155.pgm')),
  ('873a975d-4a78-46b6-9516-9ab2be9445c2', pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb134.pgm'));
-- SELECT i.uuid, i.series_uuid, i.created,i.comment, i.original, (i.image).shape FROM med_img.Instance i;

INSERT INTO
  med_img.Region(instance_uuid, created, method, props)
SELECT
    i.uuid,
    CURRENT_TIMESTAMP,
    'OTSU ENHANCEMENT',
    pgcv_bundle.mam_region_props(i.image)
FROM
  med_img.Instance i;
-- SELECT r.instance_uuid, r.method, (r.props).area from med_img.Region r;