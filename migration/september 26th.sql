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

