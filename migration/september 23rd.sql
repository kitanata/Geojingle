/*
ALTER TABLE gisedu_point_item_new_boolean_fields ADD COLUMN value boolean;
ALTER TABLE gisedu_polygon_item_new_boolean_fields ADD COLUMN value boolean;

UPDATE gisedu_point_item_new_boolean_fields SET value = gisedu_boolean_field.field_value FROM gisedu_boolean_field
	WHERE gisedu_point_item_new_boolean_fields.gisedubooleanfield_id = gisedu_boolean_field.id;

UPDATE gisedu_polygon_item_new_boolean_fields SET value = gisedu_boolean_field.field_value FROM gisedu_boolean_field
	WHERE gisedu_polygon_item_new_boolean_fields.gisedubooleanfield_id = gisedu_boolean_field.id;

CREATE TABLE gisedu_boolean_attribute
(
  id serial NOT NULL,
  attribute_name character varying(254),
  CONSTRAINT gisedu_boolean_attribute_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE gisedu_boolean_attribute OWNER TO gisedu;

INSERT INTO gisedu_boolean_attribute (attribute_name) SELECT DISTINCT field_name FROM gisedu_boolean_field;

UPDATE gisedu_point_item_new_boolean_fields SET gisedubooleanfield_id = 1;

ALTER TABLE gisedu_polygon_item_new_boolean_fields ADD COLUMN gisedubooleanattribute_id integer references gisedu_boolean_attribute;

UPDATE gisedu_polygon_item_new_boolean_fields SET gisedubooleanattribute_id = gisedu_boolean_attribute.id FROM gisedu_boolean_attribute 
	JOIN gisedu_boolean_field ON gisedu_boolean_attribute.attribute_name = gisedu_boolean_field.field_name
	WHERE gisedu_boolean_attribute.attribute_name = gisedu_boolean_field.field_name AND
	gisedu_polygon_item_new_boolean_fields.gisedubooleanfield_id = gisedu_boolean_field.id;

ALTER TABLE gisedu_polygon_item_new_boolean_fields DROP COLUMN gisedubooleanfield_id;

DROP TABLE gisedu_boolean_field;
*/

-- DO SYNC DB
/*
INSERT INTO gisedu_point_item_boolean_fields SELECT * FROM gisedu_point_item_new_boolean_fields;
INSERT INTO gisedu_polygon_item_boolean_fields (id, polygon_id, attribute_id, value) 
	SELECT id, gisedupolygonitem_id, gisedubooleanattribute_id, value FROM gisedu_polygon_item_new_boolean_fields;

DROP TABLE gisedu_point_item_new_boolean_fields;
DROP TABLE gisedu_polygon_item_new_boolean_fields;
*/

