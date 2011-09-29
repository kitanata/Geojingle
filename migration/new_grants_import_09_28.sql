-- DO RESTORE FROM DEV

/*
INSERT INTO gisedu_field_attributes (name, description, type) VALUES ('sivdl_2009_2011', 'SIVDL Grant Participant 2009-2011', 'BOOL');
INSERT INTO gisedu_field_attributes (name, description, type) VALUES ('tpg_2011_2012', 'TPG Grant Participant 2011-2012', 'BOOL');

INSERT INTO gisedu_filters (gid, filter_name, filter_type, data_type, request_modifier) 
	VALUES (21, 'SIVDL Grant Participant 2009-2011', 'BOOL', 'REDUCE', 'sivdl_2009_2011');

INSERT INTO gisedu_filters (gid, filter_name, filter_type, data_type, request_modifier) 
	VALUES (22, 'TPG Grant Participant 2011-2012', 'BOOL', 'REDUCE', 'tpg_2011_2012');

-- The Following might take a few tries

-- TPG = School Districts
-- SIVDL = Individual Schools

INSERT INTO gisedu_reduce_item (reduce_filter_id, target_filter_id, item_field)
	VALUES (21, 11, 'sivdl_2009_2011');

INSERT INTO gisedu_reduce_item (reduce_filter_id, target_filter_id, item_field)
	VALUES (22, 4, 'tpg_2011_2012');

-- The following might take a few tries

INSERT INTO gisedu_filters_option_filters (from_gisedufilters_id, to_gisedufilters_id)
	VALUES (11, 21);

INSERT INTO gisedu_filters_option_filters (from_gisedufilters_id, to_gisedufilters_id)
	VALUES (4, 22);

INSERT INTO gisedu_reduce_item (reduce_filter_id, target_filter_id, item_field)
	VALUES (21, 10, 'sivdl_2009_2011');

INSERT INTO gisedu_reduce_item (reduce_filter_id, target_filter_id, item_field)
	VALUES (22, 10, 'tpg_2011_2012');

INSERT INTO gisedu_filters_option_filters (from_gisedufilters_id, to_gisedufilters_id)
	VALUES (10, 21);

INSERT INTO gisedu_filters_option_filters (from_gisedufilters_id, to_gisedufilters_id)
	VALUES (10, 22);

ALTER TABLE new_grants ADD COLUMN attribute_id integer references gisedu_field_attributes;
ALTER TABLE new_grants ADD COLUMN attribute_val boolean;
UPDATE new_grants SET attribute_val = True;

UPDATE new_grants SET attribute_id = gisedu_field_attributes.id FROM
	gisedu_field_attributes WHERE new_grants.attribute_type = gisedu_field_attributes.name;

INSERT INTO gisedu_point_item_boolean_fields (point_id, attribute_id, value)
SELECT t1.point_id, t4.attribute_id, t4.attribute_val FROM gisedu_point_item_integer_fields t1 
	JOIN gisedu_field_attributes t2 ON t1.attribute_id = t2.id 
	JOIN gisedu_point_item t3 ON t1.point_id = t3.id
	JOIN new_grants t4 ON t1.value = t4.irn
	WHERE t2.name = 'building_irn';

CREATE SEQUENCE gisedu_polygon_item_boolean_fields_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1253
  CACHE 1;
ALTER TABLE gisedu_polygon_item_boolean_fields_id_seq OWNER TO postgres;
GRANT ALL ON TABLE gisedu_polygon_item_boolean_fields_id_seq TO postgres;
GRANT SELECT, UPDATE ON TABLE gisedu_polygon_item_boolean_fields_id_seq TO "Gisedu Application Group";

ALTER TABLE gisedu_polygon_item_boolean_fields ALTER COLUMN id SET DEFAULT nextval('gisedu_polygon_item_boolean_fields_id_seq');

INSERT INTO gisedu_polygon_item_boolean_fields (polygon_id, attribute_id, value)
SELECT t1.polygon_id, t4.attribute_id, t4.attribute_val FROM gisedu_polygon_item_integer_fields t1 
	JOIN gisedu_field_attributes t2 ON t1.attribute_id = t2.id 
	JOIN gisedu_point_item t3 ON t1.polygon_id = t3.id
	JOIN new_grants t4 ON t1.value = t4.irn
	WHERE t2.name = 'district_irn';

DROP TABLE new_grants;
*/




