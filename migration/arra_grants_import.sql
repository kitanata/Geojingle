-- DO RESTORE FROM DEV

/*
ALTER TABLE arra_grants_2009_2010_round_1 RENAME TO arra_2009;
ALTER TABLE arra_grants_2010_2011_round_2 RENAME TO arra_2010;

INSERT INTO gisedu_boolean_attribute (attribute_name) VALUES ('arra2009');
INSERT INTO gisedu_boolean_attribute (attribute_name) VALUES ('arra2010');

INSERT INTO gisedu_filters (gid, filter_name, filter_type, data_type, request_modifier) 
	VALUES (19, 'Arra 2009-2010 Round 1 Participant', 'BOOL', 'REDUCE', 'arra2009');

INSERT INTO gisedu_filters (gid, filter_name, filter_type, data_type, request_modifier) 
	VALUES (20, 'Arra 2010-2011 Round 2 Participant', 'BOOL', 'REDUCE', 'arra2010');

-- The Following might take a few tries

INSERT INTO gisedu_reduce_item (reduce_filter_id, target_filter_id, item_field)
	VALUES (19, 11, 'arra2009');

INSERT INTO gisedu_reduce_item (reduce_filter_id, target_filter_id, item_field)
	VALUES (19, 10, 'arra2009');

INSERT INTO gisedu_reduce_item (reduce_filter_id, target_filter_id, item_field)
	VALUES (20, 11, 'arra2010');

INSERT INTO gisedu_reduce_item (reduce_filter_id, target_filter_id, item_field)
	VALUES (20, 10, 'arra2010');

-- The following might take a few tries

INSERT INTO gisedu_filters_option_filters (from_gisedufilters_id, to_gisedufilters_id)
	VALUES (10, 19);

INSERT INTO gisedu_filters_option_filters (from_gisedufilters_id, to_gisedufilters_id)
	VALUES (11, 19);

INSERT INTO gisedu_filters_option_filters (from_gisedufilters_id, to_gisedufilters_id)
	VALUES (10, 20);

INSERT INTO gisedu_filters_option_filters (from_gisedufilters_id, to_gisedufilters_id)
	VALUES (11, 20);

ALTER TABLE arra_2009 ADD COLUMN attribute_id integer;
UPDATE arra_2009 SET attribute_id = 4;

ALTER TABLE arra_2010 ADD COLUMN attribute_id integer;
UPDATE arra_2010 SET attribute_id = 5;

ALTER TABLE arra_2009 ADD COLUMN attribute_val boolean;
UPDATE arra_2009 SET attribute_val = True;

ALTER TABLE arra_2010 ADD COLUMN attribute_val boolean;
UPDATE arra_2010 SET attribute_val = True;

INSERT INTO gisedu_point_item_boolean_fields (point_id, attribute_id, value)
SELECT t1.point_id, t4.attribute_id, t4.attribute_val FROM gisedu_point_item_integer_fields t1 
	JOIN gisedu_integer_attribute t2 ON t1.attribute_id = t2.id 
	JOIN gisedu_point_item t3 ON t1.point_id = t3.id
	JOIN arra_2009 t4 ON t1.value = t4.building_irn
	WHERE t2.attribute_name = 'building_irn';

INSERT INTO gisedu_point_item_boolean_fields (point_id, attribute_id, value)	
SELECT t1.point_id, t4.attribute_id, t4.attribute_val FROM gisedu_point_item_integer_fields t1 
	JOIN gisedu_integer_attribute t2 ON t1.attribute_id = t2.id 
	JOIN gisedu_point_item t3 ON t1.point_id = t3.id
	JOIN arra_2010 t4 ON t1.value = t4.bldg_irn
	WHERE t2.attribute_name = 'building_irn';
*/

