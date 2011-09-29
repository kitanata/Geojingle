/*
DROP TABLE arra_2009;
DROP TABLE arra_2010;

INSERT INTO gisedu_field_attributes (name) SELECT attribute_name FROM gisedu_boolean_attribute;
INSERT INTO gisedu_field_attributes (name) SELECT attribute_name FROM gisedu_integer_attribute;
INSERT INTO gisedu_field_attributes (name) SELECT attribute_name FROM gisedu_string_attribute;

ALTER TABLE gisedu_point_item_boolean_fields ADD COLUMN attribute_id_new integer references gisedu_field_attributes;
ALTER TABLE gisedu_point_item_integer_fields ADD COLUMN attribute_id_new integer references gisedu_field_attributes;
ALTER TABLE gisedu_point_item_string_fields ADD COLUMN attribute_id_new integer references gisedu_field_attributes;

ALTER TABLE gisedu_polygon_item_boolean_fields ADD COLUMN attribute_id_new integer references gisedu_field_attributes;
ALTER TABLE gisedu_polygon_item_integer_fields ADD COLUMN attribute_id_new integer references gisedu_field_attributes;
ALTER TABLE gisedu_polygon_item_string_fields ADD COLUMN attribute_id_new integer references gisedu_field_attributes;

ALTER TABLE gisedu_string_attribute_option ADD COLUMN attribute_id_new integer references gisedu_field_attributes;

UPDATE gisedu_point_item_boolean_fields t1 SET attribute_id_new = t3.id
	FROM gisedu_boolean_attribute t2 JOIN gisedu_field_attributes t3
	ON t2.attribute_name = t3.name
	WHERE  t1.attribute_id = t2.id
	AND t2.attribute_name = t3.name;

UPDATE gisedu_point_item_string_fields t1 SET attribute_id_new = t3.id
	FROM gisedu_string_attribute t2 JOIN gisedu_field_attributes t3
	ON t2.attribute_name = t3.name
	WHERE  t1.attribute_id = t2.id
	AND t2.attribute_name = t3.name;

UPDATE gisedu_point_item_integer_fields t1 SET attribute_id_new = t3.id
	FROM gisedu_integer_attribute t2 JOIN gisedu_field_attributes t3
	ON t2.attribute_name = t3.name
	WHERE  t1.attribute_id = t2.id
	AND t2.attribute_name = t3.name;

UPDATE gisedu_polygon_item_boolean_fields t1 SET attribute_id_new = t3.id
	FROM gisedu_boolean_attribute t2 JOIN gisedu_field_attributes t3
	ON t2.attribute_name = t3.name
	WHERE  t1.attribute_id = t2.id
	AND t2.attribute_name = t3.name;

UPDATE gisedu_polygon_item_string_fields t1 SET attribute_id_new = t3.id
	FROM gisedu_string_attribute t2 JOIN gisedu_field_attributes t3
	ON t2.attribute_name = t3.name
	WHERE  t1.attribute_id = t2.id
	AND t2.attribute_name = t3.name;

UPDATE gisedu_polygon_item_integer_fields t1 SET attribute_id_new = t3.id
	FROM gisedu_integer_attribute t2 JOIN gisedu_field_attributes t3
	ON t2.attribute_name = t3.name
	WHERE  t1.attribute_id = t2.id
	AND t2.attribute_name = t3.name;

UPDATE gisedu_string_attribute_option t1 SET attribute_id_new = t3.id
	FROM gisedu_string_attribute t2 JOIN gisedu_field_attributes t3
	ON t2.attribute_name = t3.name
	WHERE  t1.attribute_id = t2.id
	AND t2.attribute_name = t3.name;

ALTER TABLE gisedu_point_item_boolean_fields DROP COLUMN attribute_id;
ALTER TABLE gisedu_point_item_integer_fields DROP COLUMN attribute_id;
ALTER TABLE gisedu_point_item_string_fields DROP COLUMN attribute_id;

ALTER TABLE gisedu_polygon_item_boolean_fields DROP COLUMN attribute_id;
ALTER TABLE gisedu_polygon_item_integer_fields DROP COLUMN attribute_id;
ALTER TABLE gisedu_polygon_item_string_fields DROP COLUMN attribute_id;

ALTER TABLE gisedu_string_attribute_option DROP COLUMN attribute_id;

ALTER TABLE gisedu_point_item_boolean_fields RENAME COLUMN attribute_id_new TO attribute_id;
ALTER TABLE gisedu_point_item_integer_fields RENAME COLUMN attribute_id_new TO attribute_id;
ALTER TABLE gisedu_point_item_string_fields RENAME COLUMN attribute_id_new TO attribute_id;

ALTER TABLE gisedu_polygon_item_boolean_fields RENAME COLUMN attribute_id_new TO attribute_id;
ALTER TABLE gisedu_polygon_item_integer_fields RENAME COLUMN attribute_id_new TO attribute_id;
ALTER TABLE gisedu_polygon_item_string_fields RENAME COLUMN attribute_id_new TO attribute_id;

ALTER TABLE gisedu_string_attribute_option RENAME COLUMN attribute_id_new TO attribute_id;

DROP TABLE gisedu_boolean_attribute;
DROP TABLE gisedu_integer_attribute;
DROP TABLE gisedu_string_attribute;
*/

-- MANUALLY ASSIGN description and type to attribute fields

