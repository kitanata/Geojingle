-- DO SYNCDB

/*
INSERT INTO gisedu_integer_attribute (attribute_name) SELECT DISTINCT field_name FROM gisedu_integer_field;
*/

/*
INSERT INTO gisedu_point_item_integer_fields (point_id, attribute_id, value) 
	SELECT t1.gisedupointitem_id, t3.id, t2.field_value FROM gisedu_point_item_new_integer_fields t1 
	JOIN gisedu_integer_field t2 ON t1.giseduintegerfield_id = t2.id
	JOIN gisedu_integer_attribute t3 ON t2.field_name = t3.attribute_name WHERE t2.field_value is not null;

INSERT INTO gisedu_polygon_item_integer_fields (polygon_id, attribute_id, value) 
	SELECT t1.gisedupolygonitem_id, t3.id, t2.field_value FROM gisedu_polygon_item_new_integer_fields t1 
	JOIN gisedu_integer_field t2 ON t1.giseduintegerfield_id = t2.id
	JOIN gisedu_integer_attribute t3 ON t2.field_name = t3.attribute_name WHERE t2.field_value is not null;
*/

/*
DROP TABLE gisedu_point_item_new_integer_fields;
DROP TABLE gisedu_polygon_item_new_integer_fields;
DROP TABLE gisedu_integer_field;
*/

-- REMOVE _new from db names in Meta Classes

/*
INSERT INTO gisedu_string_attribute (attribute_name) SELECT DISTINCT field_name FROM gisedu_char_field;

INSERT INTO gisedu_point_item_string_fields (point_id, attribute_id, value) 
	SELECT t1.gisedupointitem_id, t3.id, t2.field_value FROM gisedu_point_item_new_string_fields t1 
	JOIN gisedu_char_field t2 ON t1.giseducharfield_id = t2.id
	JOIN gisedu_string_attribute t3 ON t2.field_name = t3.attribute_name WHERE t2.field_value is not null;

INSERT INTO gisedu_polygon_item_string_fields (polygon_id, attribute_id, value) 
	SELECT t1.gisedupolygonitem_id, t3.id, t2.field_value FROM gisedu_polygon_item_new_string_fields t1 
	JOIN gisedu_char_field t2 ON t1.giseducharfield_id = t2.id
	JOIN gisedu_string_attribute t3 ON t2.field_name = t3.attribute_name WHERE t2.field_value is not null;

DROP TABLE gisedu_point_item_new_string_fields;
DROP TABLE gisedu_polygon_item_new_string_fields;
DROP TABLE gisedu_char_field;
*/

-- SWITCH COMMENTS add _new to db names in Meta Classes
/*
INSERT INTO gisedu_string_attribute_option (attribute_id, option) SELECT DISTINCT attribute_id, value FROM gisedu_point_item_string_fields;
INSERT INTO gisedu_string_attribute_option (attribute_id, option) SELECT DISTINCT attribute_id, value FROM gisedu_polygon_item_string_fields;

INSERT INTO gisedu_point_item_string_fields_new (point_id, attribute_id, option_id) 
	SELECT t1.point_id, t1.attribute_id, t2.id FROM gisedu_point_item_string_fields t1 
	JOIN gisedu_string_attribute_option t2 ON t1.value = t2.option;

INSERT INTO gisedu_polygon_item_string_fields_new (polygon_id, attribute_id, option_id) 
	SELECT t1.polygon_id, t1.attribute_id, t2.id FROM gisedu_polygon_item_string_fields t1 
	JOIN gisedu_string_attribute_option t2 ON t1.value = t2.option;

DROP TABLE gisedu_point_item_string_fields;
DROP TABLE gisedu_polygon_item_string_fields;
*/

-- DO NEW SYNCDB - REMOVE NOT NULL CONSTAINT on point item address_id

/*

INSERT INTO gisedu_polygon_item SELECT * FROM gisedu_polygon_item_new;
INSERT INTO gisedu_point_item SELECT * FROM gisedu_point_item_new;
INSERT INTO gisedu_point_item_string_fields SELECT * FROM gisedu_point_item_string_fields_new;
INSERT INTO gisedu_polygon_item_string_fields SELECT * FROM gisedu_polygon_item_string_fields_new;

*/

/*
DROP TABLE gisedu_point_item_string_fields_new;
DROP TABLE gisedu_polygon_item_string_fields_new;
*/

-- FIX FKEYS on attribute objects

/*DROP TABLE gisedu_polygon_item_new;
DROP TABLE gisedu_point_item_new;*/
