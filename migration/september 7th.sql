/* ALTER TABLE ohio_counties ADD COLUMN filter_id integer;
   UPDATE ohio_counties SET filter_id = 1 WHERE filter_id is null;
   SELECT updategeometrysrid('gisedu_polygon_item', 'the_geom', 4326);
   SELECT updategeometrysrid('ohio_counties', 'the_geom', 4326);
   INSERT INTO gisedu_polygon_item (filter_id, item_name, the_geom) SELECT filter_id, name, the_geom FROM ohio_counties;
   INSERT INTO gisedu_polygon_item_integer_field (polygon_id, field_value) SELECT id, fips_num FROM gisedu_polygon_item JOIN ohio_counties ON (gisedu_polygon_item.item_name = ohio_counties.name);
   UPDATE gisedu_polygon_item_integer_field SET field_name = 'fips_number' WHERE field_name is null;
   INSERT INTO gisedu_polygon_item_integer_field (polygon_id, field_value) SELECT id, cnty_num FROM gisedu_polygon_item JOIN ohio_counties ON (gisedu_polygon_item.item_name = ohio_counties.name);
   UPDATE gisedu_polygon_item_integer_field SET field_name = 'county_number' WHERE field_name is null;
   INSERT INTO gisedu_polygon_item_char_field (polygon_id, field_value) SELECT id, abbrev FROM gisedu_polygon_item JOIN ohio_counties ON (gisedu_polygon_item.item_name = ohio_counties.name);
   UPDATE gisedu_polygon_item_char_field SET field_name = 'county_abbreviation' WHERE field_name is null;
-- SELECT * FROM gisedu_polygon_item_char_field WHERE field_name is null;
-- SELECT * FROM gisedu_polygon_item JOIN ohio_counties ON (gisedu_polygon_item.item_name = ohio_counties.name);
   DROP TABLE ohio_counties;*/

/* ALTER TABLE ohio_school_districts ADD COLUMN filter_id integer;
   UPDATE ohio_school_districts SET filter_id = 4 WHERE filter_id is null;
   SELECT updategeometrysrid('ohio_school_districts', 'the_geom', 4326);
   INSERT INTO gisedu_polygon_item (filter_id, item_name, the_geom) SELECT filter_id, name, the_geom FROM ohio_school_districts;
   INSERT INTO gisedu_polygon_item_char_field (polygon_id, field_value) SELECT gisedu_polygon_item.id, beg_grade FROM gisedu_polygon_item JOIN ohio_school_districts ON (gisedu_polygon_item.item_name = ohio_school_districts.name);
   UPDATE gisedu_polygon_item_char_field SET field_name = 'beg_grade' WHERE field_name is null;
   INSERT INTO gisedu_polygon_item_char_field (polygon_id, field_value) SElECT gisedu_polygon_item.id, end_grade FROM gisedu_polygon_item JOIN ohio_school_districts ON (gisedu_polygon_item.item_name = ohio_school_districts.name);
   UPDATE gisedu_polygon_item_char_field SET field_name = 'end_grade' WHERE field_name is null;
   INSERT INTO gisedu_polygon_item_char_field (polygon_id, field_value) SElECT gisedu_polygon_item.id, taxid FROM gisedu_polygon_item JOIN ohio_school_districts ON (gisedu_polygon_item.item_name = ohio_school_districts.name);
   UPDATE gisedu_polygon_item_char_field SET field_name = 'taxid' WHERE field_name is null;
   INSERT INTO gisedu_polygon_item_integer_field (polygon_id, field_value) SElECT gisedu_polygon_item.id, district_irn FROM gisedu_polygon_item JOIN ohio_school_districts ON (gisedu_polygon_item.item_name = ohio_school_districts.name);
   UPDATE gisedu_polygon_item_integer_field SET field_name = 'district_irn' WHERE field_name is null;
   INSERT INTO gisedu_polygon_item_boolean_field (polygon_id, field_value) SElECT gisedu_polygon_item.id, comcast_coverage FROM gisedu_polygon_item JOIN ohio_school_districts ON (gisedu_polygon_item.item_name = ohio_school_districts.name);
   UPDATE gisedu_polygon_item_boolean_field SET field_name = 'comcast_coverage' WHERE field_name is null;
   INSERT INTO gisedu_polygon_item_boolean_field (polygon_id, field_value) SElECT gisedu_polygon_item.id, has_atomic_learning FROM gisedu_polygon_item JOIN ohio_school_districts ON (gisedu_polygon_item.item_name = ohio_school_districts.name);
   UPDATE gisedu_polygon_item_boolean_field SET field_name = 'has_atomic_learning' WHERE field_name is null;
   DROP TABLE ohio_school_districts;*/

/* ALTER TABLE ohio_house_districts ADD COLUMN filter_id integer;
   UPDATE ohio_house_districts SET filter_id = 2 WHERE filter_id is null;
   SELECT updategeometrysrid('ohio_house_districts', 'the_geom', 4326);
   INSERT INTO gisedu_polygon_item (filter_id, item_name, the_geom) SELECT filter_id, district, the_geom FROM ohio_house_districts;
   DROP TABLE ohio_house_districts;*/

/* ALTER TABLE ohio_senate_districts ADD COLUMN filter_id integer;
   UPDATE ohio_senate_districts SET filter_id = 3 WHERE filter_id is null;
   SELECT updategeometrysrid('ohio_senate_districts', 'the_geom', 4326);
   INSERT INTO gisedu_polygon_item (filter_id, item_name, the_geom) SELECT filter_id, district, the_geom FROM ohio_senate_districts;
   DROP TABLE ohio_senate_districts;*/

/* ALTER TABLE gisedu_school ADD COLUMN filter_id integer;
   UPDATE gisedu_school SET filter_id = 11 WHERE filter_id is null;
   SELECT updategeometrysrid('gisedu_school', 'the_geom', 4326);
   ALTER TABLE gisedu_point_item ADD COLUMN school_id integer;
   INSERT INTO gisedu_point_item (filter_id, item_name, item_type, item_address_id, the_geom, school_id) 
	SELECT filter_id, school_name, school_type, address_id, the_geom, gisedu_school.gid FROM 
	gisedu_school JOIN gisedu_school_info ON gisedu_school.building_info_id = gisedu_school_info.gid 
	JOIN gisedu_school_type ON gisedu_school.school_type_id = gisedu_school_type.gid;

   INSERT INTO gisedu_point_item_integer_field (point_id, field_value) SELECT gisedu_point_item.id, building_irn 
	FROM gisedu_point_item JOIN gisedu_school ON (gisedu_point_item.school_id = gisedu_school.gid);
   UPDATE gisedu_point_item_integer_field SET field_name = 'building_irn' WHERE field_name is null;

   INSERT INTO gisedu_point_item_integer_field (point_id, field_value) SELECT gisedu_point_item.id, mbit 
	FROM gisedu_point_item JOIN gisedu_school ON (gisedu_point_item.school_id = gisedu_school.gid)
	JOIN gisedu_school_info ON gisedu_school.building_info_id = gisedu_school_info.gid;
   UPDATE gisedu_point_item_integer_field SET field_name = 'school_connectivity' WHERE field_name is null;

   INSERT INTO gisedu_point_item_char_field (point_id, field_value) SELECT gisedu_point_item.id, classification 
	FROM gisedu_point_item JOIN gisedu_school ON (gisedu_point_item.school_id = gisedu_school.gid)
	JOIN gisedu_school_info ON gisedu_school.building_info_id = gisedu_school_info.gid
	JOIN school_area_classification ON gisedu_school_info.area_class_id = school_area_classification.gid;
   UPDATE gisedu_point_item_char_field SET field_name = 'school_classification' WHERE field_name is null;

   INSERT INTO gisedu_point_item_char_field (point_id, field_value) SELECT gisedu_point_item.id, itc 
	FROM gisedu_point_item JOIN gisedu_school ON (gisedu_point_item.school_id = gisedu_school.gid)
	JOIN gisedu_school_info ON gisedu_school.building_info_id = gisedu_school_info.gid
	JOIN school_itc ON gisedu_school_info.itc_id = school_itc.gid;
   UPDATE gisedu_point_item_char_field SET field_name = 'school_itc' WHERE field_name is null;

   INSERT INTO gisedu_point_item_char_field (point_id, field_value) SELECT gisedu_point_item.id, grade_name 
	FROM gisedu_point_item JOIN gisedu_school_grades ON (gisedu_point_item.school_id = gisedu_school_grades.giseduschool_id)
	JOIN grade ON gisedu_school_grades.grade_id = grade.gid;
   UPDATE gisedu_point_item_char_field SET field_name = 'school_grade' WHERE field_name is null;

   DROP TABLE gisedu_school_grades;
   DROP TABLE grade;
   DROP TABLE school_itc;
   DROP TABLE school_area_classification;
   ALTER TABLE gisedu_point_item DROP COLUMN school_id;
   DROP TABLE gisedu_school;
   DROP TABLE gisedu_school_info;
   DROP TABLE gisedu_school_type;
*/

/* ALTER TABLE gisedu_org ADD COLUMN filter_id integer;
UPDATE gisedu_org SET filter_id = 10 WHERE filter_id is null; 
SELECT updategeometrysrid('gisedu_org', 'the_geom', 4326);
ALTER TABLE gisedu_point_item ADD COLUMN org_id integer;

INSERT INTO gisedu_point_item (filter_id, item_name, item_type, item_address_id, the_geom, org_id) 
	SELECT filter_id, org_nm, org_type_name, address_id, the_geom, gisedu_org.gid 
	FROM gisedu_org JOIN gisedu_org_type ON gisedu_org.org_type_id = gisedu_org_type.gid;

INSERT INTO gisedu_point_item_integer_field (point_id, field_value) SELECT gisedu_point_item.id, building_irn 
	FROM gisedu_point_item JOIN gisedu_org ON (gisedu_point_item.org_id = gisedu_org.gid);
   UPDATE gisedu_point_item_integer_field SET field_name = 'building_irn' WHERE field_name is null;

   ALTER TABLE gisedu_point_item DROP COLUMN org_id;
   DROP TABLE gisedu_org;
   DROP TABLE gisedu_org_type;

   ALTER TABLE gisedu_org_address RENAME TO gisedu_point_item_address;
*/

/* INSERT INTO gisedu_reduce_item (reduce_filter_id, target_filter_id, item_field) VALUES (6, 11, 'school_connectivity');

   INSERT INTO gisedu_filters (gid, filter_name, filter_type, data_type, request_modifier) VALUES 
	(14, 'Building Irn', 'INTEGER', 'REDUCE', 'building_irn');

   INSERT INTO gisedu_reduce_item (reduce_filter_id, target_filter_id, item_field) VALUES (14, 10, 'building_irn'); 
   INSERT INTO gisedu_reduce_item (reduce_filter_id, target_filter_id, item_field) VALUES (14, 11, 'building_irn');

   INSERT INTO gisedu_filters (gid, filter_name, filter_type, data_type, request_modifier) VALUES 
	(15, 'School Grade', 'CHAR', 'REDUCE', 'school_grade');

   INSERT INTO gisedu_reduce_item (reduce_filter_id, target_filter_id, item_field) VALUES (15, 11, 'school_grade');
   INSERT INTO gisedu_reduce_item (reduce_filter_id, target_filter_id, item_field) VALUES (8, 11, 'school_itc');
   INSERT INTO gisedu_reduce_item (reduce_filter_id, target_filter_id, item_field) VALUES (9, 11, 'school_classification');

   INSERT INTO gisedu_reduce_item (reduce_filter_id, target_filter_id, item_field) VALUES (13, 4, 'has_atomic_learning');
   INSERT INTO gisedu_reduce_item (reduce_filter_id, target_filter_id, item_field) VALUES (12, 4, 'comcast_coverage');
*/

-- SELECT * FROM gisedu_reduce_item limit 10;

-- DON'T DO THIS DURING MIGRATION
/*
ALTER TABLE gisedu_point_item_boolean_field ADD COLUMN gisedu_boolean_field_id integer;
ALTER TABLE gisedu_point_item_char_field ADD COLUMN gisedu_char_field_id integer;
ALTER TABLE gisedu_point_item_integer_field ADD COLUMN gisedu_integer_field_id integer;

ALTER TABLE gisedu_polygon_item_boolean_field ADD COLUMN gisedu_boolean_field_id integer;
ALTER TABLE gisedu_polygon_item_char_field ADD COLUMN gisedu_char_field_id integer;
ALTER TABLE gisedu_polygon_item_integer_field ADD COLUMN gisedu_integer_field_id integer;
*/

-- DO THIS DURING MIGRATION
/*
INSERT INTO gisedu_boolean_field (field_name, field_value) SELECT DISTINCT field_name, field_value FROM gisedu_point_item_boolean_field;
INSERT INTO gisedu_boolean_field (field_name, field_value) SELECT DISTINCT field_name, field_value FROM gisedu_polygon_item_boolean_field;

UPDATE gisedu_point_item_boolean_field SET gisedu_boolean_field_id = gisedu_boolean_field.id 
	FROM gisedu_boolean_field WHERE gisedu_point_item_boolean_field.field_name = gisedu_boolean_field.field_name 
	AND gisedu_point_item_boolean_field.field_value = gisedu_boolean_field.field_value;

UPDATE gisedu_polygon_item_boolean_field SET gisedu_boolean_field_id = gisedu_boolean_field.id 
	FROM gisedu_boolean_field WHERE gisedu_polygon_item_boolean_field.field_name = gisedu_boolean_field.field_name 
	AND gisedu_polygon_item_boolean_field.field_value = gisedu_boolean_field.field_value;

	SELECT * FROM gisedu_boolean_field;

*/

/* 
INSERT INTO gisedu_char_field (field_name, field_value) SELECT DISTINCT field_name, field_value FROM gisedu_point_item_char_field;
INSERT INTO gisedu_char_field (field_name, field_value) SELECT DISTINCT field_name, field_value FROM gisedu_polygon_item_char_field;

UPDATE gisedu_point_item_char_field SET gisedu_char_field_id = gisedu_char_field.id 
	FROM gisedu_char_field WHERE gisedu_point_item_char_field.field_name = gisedu_char_field.field_name 
	AND gisedu_point_item_char_field.field_value = gisedu_char_field.field_value;

UPDATE gisedu_polygon_item_char_field SET gisedu_char_field_id = gisedu_char_field.id 
	FROM gisedu_char_field WHERE gisedu_polygon_item_char_field.field_name = gisedu_char_field.field_name 
	AND gisedu_polygon_item_char_field.field_value = gisedu_char_field.field_value;

SELECT * FROM gisedu_char_field;
*/

/*
INSERT INTO gisedu_integer_field (field_name, field_value) SELECT DISTINCT field_name, field_value FROM gisedu_point_item_integer_field;
INSERT INTO gisedu_integer_field (field_name, field_value) SELECT DISTINCT field_name, field_value FROM gisedu_polygon_item_integer_field;

UPDATE gisedu_point_item_integer_field SET gisedu_integer_field_id = gisedu_integer_field.id 
	FROM gisedu_integer_field WHERE gisedu_point_item_integer_field.field_name = gisedu_integer_field.field_name 
	AND gisedu_point_item_integer_field.field_value = gisedu_integer_field.field_value;

UPDATE gisedu_polygon_item_integer_field SET gisedu_integer_field_id = gisedu_integer_field.id 
	FROM gisedu_integer_field WHERE gisedu_polygon_item_integer_field.field_name = gisedu_integer_field.field_name 
	AND gisedu_polygon_item_integer_field.field_value = gisedu_integer_field.field_value;

SELECT * FROM gisedu_integer_field;
*/

/*
ALTER TABLE gisedu_point_item_boolean_field RENAME COLUMN gisedu_boolean_field_id TO field_id;
ALTER TABLE gisedu_point_item_char_field RENAME COLUMN gisedu_char_field_id TO field_id;
ALTER TABLE gisedu_point_item_integer_field RENAME COLUMN gisedu_integer_field_id TO field_id;

ALTER TABLE gisedu_polygon_item_boolean_field RENAME COLUMN gisedu_boolean_field_id TO field_id;
ALTER TABLE gisedu_polygon_item_char_field RENAME COLUMN gisedu_char_field_id TO field_id;
ALTER TABLE gisedu_polygon_item_integer_field RENAME COLUMN gisedu_integer_field_id TO field_id;
*/

/* ALTER TABLE gisedu_point_item ADD COLUMN jvsd_id integer;
ALTER TABLE gisedu_joint_vocational_school_district ADD COLUMN filter_id integer;
UPDATE gisedu_joint_vocational_school_district SET filter_id = 5 WHERE filter_id is null;
SELECT updategeometrysrid('gisedu_joint_vocational_school_district', 'the_geom', 4326);

INSERT INTO gisedu_point_item (filter_id, item_name, item_address_id, the_geom, jvsd_id) 
	SELECT filter_id, jvsd_name, address_id, the_geom, gid FROM gisedu_joint_vocational_school_district;

ALTER TABLE gisedu_boolean_field ADD COLUMN jvsd_id integer;
INSERT INTO gisedu_boolean_field (field_value, jvsd_id) SELECT has_atomic_learning, gid FROM gisedu_joint_vocational_school_district;
UPDATE gisedu_boolean_field SET field_name = 'has_atomic_learning' WHERE field_name is null;

INSERT INTO gisedu_point_item_boolean_field (point_id, field_id) 
	SELECT gisedu_point_item.id, gisedu_boolean_field.id FROM
	gisedu_point_item JOIN gisedu_boolean_field ON gisedu_point_item.jvsd_id = gisedu_boolean_field.jvsd_id;
ALTER TABLE gisedu_boolean_field DROP COLUMN jvsd_id;

ALTER TABLE gisedu_integer_field ADD COLUMN jvsd_id integer;
INSERT INTO gisedu_integer_field (field_value, jvsd_id) SELECT building_irn, gid FROM gisedu_joint_vocational_school_district;
UPDATE gisedu_integer_field SET field_name = 'building_irn' WHERE field_name is null;

INSERT INTO gisedu_point_item_integer_field (point_id, field_id)
	SELECT gisedu_point_item.id, gisedu_integer_field.id FROM
	gisedu_point_item JOIN gisedu_integer_field ON gisedu_point_item.jvsd_id = gisedu_integer_field.jvsd_id;
ALTER TABLE gisedu_integer_field DROP COLUMN jvsd_id;
*/

/* ALTER TABLE gisedu_point_item DROP COLUMN jvsd_id; */






SELECT * FROM gisedu_point_item 
	JOIN gisedu_point_item_boolean_field ON gisedu_point_item.id = gisedu_point_item_boolean_field.point_id
	JOIN gisedu_boolean_field ON gisedu_boolean_field.id = gisedu_point_item_boolean_field.field_id
	WHERE filter_id = 5;

/*
gisedu_boolean_field field_name field_value
gisedu_integer_field field_name field_value
gisedu_char_field field_name field_value
gisedu_point_item_boolean_field point_id, gisedu_boolean_field_id
gisedu_point_item_integer_field point_id, gisedu_integer_field_id
gisedu_point_item_char_field point_id, gisedu_char_field_id
gisedu_polygon_item_boolean_field polygon_id, gisedu_boolean_field_id
gisedu_polygon_item_integer_field polygon_id, gisedu_integer_field_id
gisedu_polygon_item_char_field polygon_id, gisedu_char_field_id
*/

-- SELECT DISTINCT field_name FROM gisedu_polygon_item_boolean_field;
-- SELECT DISTINCT filter_id FROM gisedu_point_item_char_field JOIN gisedu_point_item ON 
--	gisedu_point_item_char_field.point_id = gisedu_point_item.id WHERE field_name = 'building_irn';
-- SELECT * FROM gisedu_point_item_integer_field WHERE field_name = 'mbit';

-- SELECT * FROM gisedu_org JOIN gisedu_org_type ON gisedu_org.org_type_id = gisedu_org_type.gid limit 10;

-- SELECT * FROM gisedu_polygon_item_boolean_field WHERE field_name = 'comcast_coverage';


-- SELECT * FROM gisedu_char_field WHERE field_name = 'school_classification';



-- DO THIS TO CLEANUP THE STUFF AFTER THE MIGRATION IS DONE
/*
ALTER TABLE gisedu_point_item_boolean_field DROP COLUMN field_name;
ALTER TABLE gisedu_point_item_char_field DROP COLUMN field_name;
ALTER TABLE gisedu_point_item_integer_field DROP COLUMN field_name;

ALTER TABLE gisedu_point_item_boolean_field DROP COLUMN field_value;
ALTER TABLE gisedu_point_item_char_field DROP COLUMN field_value;
ALTER TABLE gisedu_point_item_integer_field DROP COLUMN field_value;

ALTER TABLE gisedu_polygon_item_boolean_field DROP COLUMN field_name;
ALTER TABLE gisedu_polygon_item_char_field DROP COLUMN field_name;
ALTER TABLE gisedu_polygon_item_integer_field DROP COLUMN field_name;

ALTER TABLE gisedu_polygon_item_boolean_field DROP COLUMN field_value;
ALTER TABLE gisedu_polygon_item_char_field DROP COLUMN field_value;
ALTER TABLE gisedu_polygon_item_integer_field DROP COLUMN field_value;
*/
