INSERT INTO
  med_img.Patient(uuid, given_name, family_name, email, address, sex, birthdate)
VALUES
  ('d5c717ee-6202-4889-a042-059ecf649c5a', 'Maria', 'Hernandez', 'maria@gmail.com', '{"country": "Costa Rica", "state": "Alajuela", "city": "Grecia"}', 2, '1968-01-08'),
  ('13909736-3b71-443a-9dc5-64ce885653e3', 'Petra', 'Martinez', 'petra@gmail.com', '{"country": "Costa Rica", "state": "Heredia", "city": "San Francisco"}', 2, '1958-04-20');
-- SELECT * from med_img.Patient;
-- SELECT * from med_img.Patient where address->>'province' = 'Heredia';

INSERT INTO
  med_img.Study(uuid, patient_uuid, description)
VALUES
  ('a8e03b9a-3dc6-4c89-af16-4e7d659c724a', 'd5c717ee-6202-4889-a042-059ecf649c5a', 'Digital Mammogram'),
  ('9fd67171-b5e0-4165-a2a2-348d0a21b0e3', '13909736-3b71-443a-9dc5-64ce885653e3', 'Digital Mammogram');
-- SELECT * from med_img.Study;

INSERT INTO
  med_img.Series(uuid, study_uuid, laterality, description, body_part)
VALUES
  ('086c8575-49b8-47b4-82e5-4203a5064835', 'a8e03b9a-3dc6-4c89-af16-4e7d659c724a', 'L', 'MLO projections', 'BREAST'),
  ('873a975d-4a78-46b6-9516-9ab2be9445c2', '9fd67171-b5e0-4165-a2a2-348d0a21b0e3', 'R', 'MLO projections', 'BREAST');
-- SELECT * from med_img.Series;

-- WARNING: Don't 'SELECT *' with this table, you dont want to print 1048576 pixel values to the console. Instead do:
INSERT INTO
  med_img.Instance(series_uuid, image)
VALUES
  ('086c8575-49b8-47b4-82e5-4203a5064835', pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb155.pgm')),
  ('873a975d-4a78-46b6-9516-9ab2be9445c2', pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb134.pgm'));
-- SELECT i.uuid, i.series_uuid, i.created,i.comment, i.original, (i.image).shape FROM med_img.Instance i;

INSERT INTO
  med_img.Region(instance_uuid, created_at, method, props)
SELECT
    i.uuid,
    CURRENT_TIMESTAMP,
    'OTSU ENHANCEMENT',
    pgcv_bundle.mam_region_props(i.image)
FROM
  med_img.Instance i;
-- SELECT r.instance_uuid, r.method, (r.props).area from med_img.Region r;