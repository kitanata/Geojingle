-- ALTER TABLE gisedu_point_item RENAME TO gisedu_point_item_old;
-- ALTER TABLE gisedu_point_item_boolean_field RENAME TO gisedu_point_item_boolean_field_old;
-- ALTER TABLE gisedu_point_item_integer_field RENAME TO gisedu_point_item_integer_field_old;
-- ALTER TABLE gisedu_point_item_char_field RENAME TO gisedu_point_item_char_field_old;

-- DO SYNCDB DROP CONSRAINT on point_item_address

-- INSERT INTO gisedu_point_item_new SELECT * FROM gisedu_point_item_old;
-- INSERT INTO gisedu_point_item_new_boolean_fields SELECT * FROM gisedu_point_item_boolean_field_old;
-- INSERT INTO gisedu_point_item_new_integer_fields SELECT * FROM gisedu_point_item_integer_field_old;
-- INSERT INTO gisedu_point_item_new_string_fields SELECT * FROM gisedu_point_item_char_field_old;

-- DROP TABLE gisedu_point_item_boolean_field_old;
-- DROP TABLE gisedu_point_item_integer_field_old;
-- DROP TABLE gisedu_point_item_char_field_old;
-- DROP TABLE gisedu_point_item_old;