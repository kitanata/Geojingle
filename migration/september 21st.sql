/*
INSERT INTO gisedu_point_item_new SELECT * FROM gisedu_point_item;
INSERT INTO gisedu_point_item_new_boolean_fields SELECT * FROM gisedu_point_item_boolean_field;
INSERT INTO gisedu_point_item_new_integer_fields SELECT * FROM gisedu_point_item_integer_field;
INSERT INTO gisedu_point_item_new_string_fields SELECT * FROM gisedu_point_item_char_field;
*/

/*
DROP TABLE gisedu_point_item_boolean_field;
DROP TABLE gisedu_point_item_integer_field;
DROP TABLE gisedu_point_item_char_field;
DROP TABLE gisedu_point_item;
*/

/*
INSERT INTO gisedu_polygon_item_new SELECT * FROM gisedu_polygon_item;
INSERT INTO gisedu_polygon_item_new_boolean_fields (gisedupolygonitem_id, gisedubooleanfield_id) 
	SELECT DISTINCT polygon_id, field_id FROM gisedu_polygon_item_boolean_field;
INSERT INTO gisedu_polygon_item_new_integer_fields SELECT * FROM gisedu_polygon_item_integer_field;
INSERT INTO gisedu_polygon_item_new_string_fields (gisedupolygonitem_id, giseducharfield_id) 
	SELECT DISTINCT polygon_id, field_id FROM gisedu_polygon_item_char_field;
*/

/*
DROP TABLE gisedu_polygon_item_boolean_field;
DROP TABLE gisedu_polygon_item_integer_field;
DROP TABLE gisedu_polygon_item_char_field;
DROP TABLE gisedu_polygon_item;
*/

