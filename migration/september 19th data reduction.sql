/*UPDATE gisedu_point_item_boolean_field SET field_id = 1385 FROM gisedu_boolean_field
WHERE gisedu_point_item_boolean_field.field_id = gisedu_boolean_field.id AND
      gisedu_boolean_field.field_name = 'has_atomic_learning' AND
      gisedu_boolean_field.field_value = True;

UPDATE gisedu_point_item_boolean_field SET field_id = 1423 FROM gisedu_boolean_field
WHERE gisedu_point_item_boolean_field.field_id = gisedu_boolean_field.id AND
      gisedu_boolean_field.field_name = 'has_atomic_learning' AND
      gisedu_boolean_field.field_value = True;

UPDATE gisedu_polygon_item_boolean_field SET field_id = 1385 FROM gisedu_boolean_field
WHERE gisedu_polygon_item_boolean_field.field_id = gisedu_boolean_field.id AND
      gisedu_boolean_field.field_name = 'has_atomic_learning' AND
      gisedu_boolean_field.field_value = False;

UPDATE gisedu_polygon_item_boolean_field SET field_id = 1423 FROM gisedu_boolean_field
WHERE gisedu_polygon_item_boolean_field.field_id = gisedu_boolean_field.id AND
      gisedu_boolean_field.field_name = 'has_atomic_learning' AND
      gisedu_boolean_field.field_value = True;
*/

SELECT * FROM gisedu_polygon_item_boolean_field t1 JOIN gisedu_boolean_field t2 ON t1.field_id = t2.id;