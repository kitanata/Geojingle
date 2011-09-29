/*
CREATE TABLE gisedu_filters_new
(
  id serial NOT NULL, --gid
  name character varying(254) NOT NULL, --Request Modifier
  description character varying(254) NOT NULL, -- Filter Name
  filter_type character varying(254) NOT NULL, -- Data Type
  data_type character varying(254) NOT NULL, -- Filter Type
  enabled boolean NOT NULL DEFAULT True,
  CONSTRAINT gisedu_filters_new_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE gisedu_filters_new OWNER TO gisedu;
GRANT ALL ON TABLE gisedu_filters_new TO gisedu;
GRANT SELECT, UPDATE, INSERT, DELETE, REFERENCES ON TABLE gisedu_filters_new TO "gisedu group";

INSERT INTO gisedu_filters_new (name, description, filter_type, data_type)
	SELECT request_modifier, filter_name, data_type, filter_type FROM gisedu_filters WHERE data_type != 'REDUCE';

ALTER TABLE gisedu_field_attributes ADD COLUMN filter_type character varying(254);
UPDATE gisedu_field_attributes SET filter_type = 'REDUCE';

INSERT INTO gisedu_filters_new (name, description, filter_type, data_type)
	SELECT name, description, filter_type, type FROM gisedu_field_attributes;
*/

-- NEW FILTER TABLES
/*
CREATE TABLE gisedu_filters_exclude_filters_new
(
  id serial NOT NULL,
  from_gisedufilters_id integer NOT NULL references gisedu_filters_new,
  to_gisedufilters_id integer NOT NULL references gisedu_filters_new
)
WITH (
  OIDS=FALSE
);
ALTER TABLE gisedu_filters_exclude_filters_new OWNER TO gisedu;
GRANT ALL ON TABLE gisedu_filters_exclude_filters_new TO gisedu;
GRANT SELECT, UPDATE, INSERT, DELETE, REFERENCES ON TABLE gisedu_filters_exclude_filters_new TO "gisedu group";

CREATE TABLE gisedu_filters_option_filters_new
(
  id serial NOT NULL,
  from_gisedufilters_id integer NOT NULL references gisedu_filters_new,
  to_gisedufilters_id integer NOT NULL references gisedu_filters_new
)
WITH (
  OIDS=FALSE
);
ALTER TABLE gisedu_filters_option_filters_new OWNER TO gisedu;
GRANT ALL ON TABLE gisedu_filters_option_filters_new TO gisedu;
GRANT SELECT, UPDATE, INSERT, DELETE, REFERENCES ON TABLE gisedu_filters_option_filters_new TO "gisedu group";

CREATE TABLE gisedu_reduce_item_new
(
  id serial NOT NULL,
  reduce_filter_id integer NOT NULL references gisedu_filters_new,
  target_filter_id integer NOT NULL references gisedu_filters_new
)
WITH (
  OIDS=FALSE
);
ALTER TABLE gisedu_reduce_item_new OWNER TO gisedu;
GRANT ALL ON TABLE gisedu_reduce_item_new TO gisedu;
GRANT SELECT, UPDATE, INSERT, DELETE, REFERENCES ON TABLE gisedu_reduce_item_new TO "gisedu group";

INSERT INTO gisedu_filters_exclude_filters_new (from_gisedufilters_id, to_gisedufilters_id)
SELECT t4.id, t5.id 
	FROM gisedu_filters_exclude_filters t1 
	JOIN gisedu_filters t2 ON t1.from_gisedufilters_id = t2.gid
	JOIN gisedu_filters t3 ON t1.to_gisedufilters_id = t3.gid
	JOIN gisedu_filters_new t4 ON t2.request_modifier = t4.name
	JOIN gisedu_filters_new t5 ON t3.request_modifier = t5.name;

INSERT INTO gisedu_filters_option_filters_new (from_gisedufilters_id, to_gisedufilters_id)
SELECT t4.id, t5.id 
	FROM gisedu_filters_option_filters t1 
	JOIN gisedu_filters t2 ON t1.from_gisedufilters_id = t2.gid
	JOIN gisedu_filters t3 ON t1.to_gisedufilters_id = t3.gid
	JOIN gisedu_filters_new t4 ON t2.request_modifier = t4.name
	JOIN gisedu_filters_new t5 ON t3.request_modifier = t5.name;

INSERT INTO gisedu_reduce_item_new (reduce_filter_id, target_filter_id)
SELECT t4.id, t5.id 
	FROM gisedu_reduce_item t1 
	JOIN gisedu_filters t2 ON t1.reduce_filter_id = t2.gid
	JOIN gisedu_filters t3 ON t1.target_filter_id = t3.gid
	JOIN gisedu_filters_new t4 ON t2.request_modifier = t4.name
	JOIN gisedu_filters_new t5 ON t3.request_modifier = t5.name;

DROP TABLE gisedu_filters_exclude_filters;
DROP TABLE gisedu_filters_option_filters;
DROP TABLE gisedu_reduce_item;

ALTER TABLE gisedu_point_item DROP CONSTRAINT gisedu_point_item_filter_id_fkey;

ALTER TABLE gisedu_point_item
  ADD CONSTRAINT gisedu_point_item_filter_id_fkey FOREIGN KEY (filter_id)
      REFERENCES gisedu_filters_new (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
      
UPDATE gisedu_point_item SET filter_id = gisedu_filters_new.id
	FROM gisedu_filters_new JOIN gisedu_filters ON
	gisedu_filters_new.name = gisedu_filters.request_modifier
	WHERE gisedu_point_item.filter_id = gisedu_filters.gid
	AND gisedu_filters_new.name = gisedu_filters.request_modifier;

ALTER TABLE gisedu_polygon_item DROP CONSTRAINT gisedu_polygon_item_filter_id_fkey;

ALTER TABLE gisedu_polygon_item
  ADD CONSTRAINT gisedu_polygon_item_filter_id_fkey FOREIGN KEY (filter_id)
      REFERENCES gisedu_filters_new (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;

UPDATE gisedu_polygon_item SET filter_id = gisedu_filters_new.id
	FROM gisedu_filters_new JOIN gisedu_filters ON
	gisedu_filters_new.name = gisedu_filters.request_modifier
	WHERE gisedu_polygon_item.filter_id = gisedu_filters.gid
	AND gisedu_filters_new.name = gisedu_filters.request_modifier;

DROP TABLE gisedu_filters;
ALTER TABLE gisedu_filters_new RENAME TO gisedu_filters;
ALTER TABLE gisedu_filters_exclude_filters_new RENAME TO gisedu_filters_exclude_filters;
ALTER TABLE gisedu_filters_option_filters_new RENAME TO gisedu_filters_option_filters;
ALTER TABLE gisedu_reduce_item_new RENAME TO gisedu_reduce_item;
*/

/*
CREATE TABLE gisedu_point_item_boolean_fields_new
(
  id serial NOT NULL primary key,
  point_id integer NOT NULL references gisedu_point_item,
  value boolean NOT NULL,
  attribute_filter_id integer references gisedu_filters
)
WITH (
  OIDS=FALSE
);
ALTER TABLE gisedu_point_item_boolean_fields_new OWNER TO gisedu;
GRANT ALL ON TABLE gisedu_point_item_boolean_fields_new TO gisedu;
GRANT SELECT, UPDATE, INSERT, DELETE, REFERENCES ON TABLE gisedu_point_item_boolean_fields_new TO "gisedu group";

CREATE TABLE gisedu_point_item_integer_fields_new
(
  id serial NOT NULL primary key,
  point_id integer NOT NULL references gisedu_point_item,
  value integer NOT NULL,
  attribute_filter_id integer references gisedu_filters
)
WITH (
  OIDS=FALSE
);
ALTER TABLE gisedu_point_item_integer_fields_new OWNER TO gisedu;
GRANT ALL ON TABLE gisedu_point_item_integer_fields_new TO gisedu;
GRANT SELECT, UPDATE, INSERT, DELETE, REFERENCES ON TABLE gisedu_point_item_integer_fields_new TO "gisedu group";

CREATE TABLE gisedu_point_item_string_fields_new
(
  id serial NOT NULL primary key,
  point_id integer NOT NULL references gisedu_point_item,
  option_id integer NOT NULL,
  attribute_filter_id integer references gisedu_filters
)
WITH (
  OIDS=FALSE
);
ALTER TABLE gisedu_point_item_string_fields_new OWNER TO gisedu;
GRANT ALL ON TABLE gisedu_point_item_string_fields_new TO gisedu;
GRANT SELECT, UPDATE, INSERT, DELETE, REFERENCES ON TABLE gisedu_point_item_string_fields_new TO "gisedu group";

ALTER TABLE gisedu_point_item_boolean_fields ADD COLUMN filter_id integer references gisedu_filters;
ALTER TABLE gisedu_point_item_integer_fields ADD COLUMN filter_id integer references gisedu_filters;
ALTER TABLE gisedu_point_item_string_fields ADD COLUMN filter_id integer references gisedu_filters;
*/

/*
CREATE TABLE gisedu_string_attribute_option_new
(
  id serial NOT NULL primary key,
  option character varying(254) NOT NULL,
  attribute_filter_id integer references gisedu_filters
)
WITH (
  OIDS=FALSE
);
ALTER TABLE gisedu_string_attribute_option_new OWNER TO gisedu;
GRANT ALL ON TABLE gisedu_string_attribute_option_new TO gisedu;
GRANT SELECT, UPDATE, INSERT, DELETE, REFERENCES ON TABLE gisedu_string_attribute_option_new TO "gisedu group";

ALTER TABLE gisedu_string_attribute_option ADD COLUMN filter_id integer references gisedu_filters;

UPDATE gisedu_string_attribute_option SET filter_id = gisedu_filters.id
	FROM gisedu_filters JOIN gisedu_field_attributes ON
	gisedu_filters.name = gisedu_field_attributes.name
	WHERE gisedu_string_attribute_option.attribute_id = gisedu_field_attributes.id
	AND gisedu_filters.name = gisedu_field_attributes.name;
	
INSERT INTO gisedu_string_attribute_option_new (option, attribute_filter_id)
	SELECT option, filter_id FROM gisedu_string_attribute_option;
*/

/*
UPDATE gisedu_point_item_boolean_fields SET filter_id = gisedu_filters.id
	FROM gisedu_filters JOIN gisedu_field_attributes ON
	gisedu_filters.name = gisedu_field_attributes.name
	WHERE gisedu_point_item_boolean_fields.attribute_id = gisedu_field_attributes.id
	AND gisedu_filters.name = gisedu_field_attributes.name;

UPDATE gisedu_point_item_integer_fields SET filter_id = gisedu_filters.id
	FROM gisedu_filters JOIN gisedu_field_attributes ON
	gisedu_filters.name = gisedu_field_attributes.name
	WHERE gisedu_point_item_integer_fields.attribute_id = gisedu_field_attributes.id
	AND gisedu_filters.name = gisedu_field_attributes.name;

UPDATE gisedu_point_item_string_fields SET filter_id = gisedu_filters.id
	FROM gisedu_filters JOIN gisedu_field_attributes ON
	gisedu_filters.name = gisedu_field_attributes.name
	WHERE gisedu_point_item_string_fields.attribute_id = gisedu_field_attributes.id
	AND gisedu_filters.name = gisedu_field_attributes.name;
*/

/*
ALTER TABLE gisedu_point_item_string_fields ADD COLUMN new_option_id integer references gisedu_string_attribute_option_new;

UPDATE gisedu_point_item_string_fields SET new_option_id = gisedu_string_attribute_option_new.id
	FROM gisedu_string_attribute_option_new JOIN gisedu_string_attribute_option ON
	gisedu_string_attribute_option_new.option = gisedu_string_attribute_option.option AND
	gisedu_string_attribute_option_new.attribute_filter_id = gisedu_string_attribute_option.filter_id
	WHERE gisedu_point_item_string_fields.option_id = gisedu_string_attribute_option.id AND
	gisedu_string_attribute_option_new.option = gisedu_string_attribute_option.option AND
	gisedu_string_attribute_option_new.attribute_filter_id = gisedu_string_attribute_option.filter_id;
*/

/*
INSERT INTO gisedu_point_item_boolean_fields_new (point_id, value, attribute_filter_id)
	SELECT point_id, value, filter_id FROM gisedu_point_item_boolean_fields;

INSERT INTO gisedu_point_item_integer_fields_new (point_id, value, attribute_filter_id)
	SELECT point_id, value, filter_id FROM gisedu_point_item_integer_fields;

INSERT INTO gisedu_point_item_string_fields_new (point_id, option_id, attribute_filter_id)
	SELECT point_id, new_option_id, filter_id FROM gisedu_point_item_string_fields;
*/

/*
DROP TABLE gisedu_point_item_boolean_fields;
DROP TABLE gisedu_point_item_integer_fields;
DROP TABLE gisedu_point_item_string_fields;

ALTER TABLE gisedu_point_item_boolean_fields_new RENAME TO gisedu_point_item_boolean_fields;
ALTER TABLE gisedu_point_item_integer_fields_new RENAME TO gisedu_point_item_integer_fields;
ALTER TABLE gisedu_point_item_string_fields_new RENAME TO gisedu_point_item_string_fields;
*/


-- POLYGON ITEMS
/*
CREATE TABLE gisedu_polygon_item_boolean_fields_new
(
  id serial NOT NULL primary key,
  polygon_id integer NOT NULL references gisedu_polygon_item,
  value boolean NOT NULL,
  attribute_filter_id integer references gisedu_filters
)
WITH (
  OIDS=FALSE
);
ALTER TABLE gisedu_polygon_item_boolean_fields_new OWNER TO gisedu;
GRANT ALL ON TABLE gisedu_polygon_item_boolean_fields_new TO gisedu;
GRANT SELECT, UPDATE, INSERT, DELETE, REFERENCES ON TABLE gisedu_polygon_item_boolean_fields_new TO "gisedu group";

CREATE TABLE gisedu_polygon_item_integer_fields_new
(
  id serial NOT NULL primary key,
  polygon_id integer NOT NULL references gisedu_polygon_item,
  value integer NOT NULL,
  attribute_filter_id integer references gisedu_filters
)
WITH (
  OIDS=FALSE
);
ALTER TABLE gisedu_polygon_item_integer_fields_new OWNER TO gisedu;
GRANT ALL ON TABLE gisedu_polygon_item_integer_fields_new TO gisedu;
GRANT SELECT, UPDATE, INSERT, DELETE, REFERENCES ON TABLE gisedu_polygon_item_integer_fields_new TO "gisedu group";

CREATE TABLE gisedu_polygon_item_string_fields_new
(
  id serial NOT NULL primary key,
  polygon_id integer NOT NULL references gisedu_polygon_item,
  option_id integer NOT NULL,
  attribute_filter_id integer references gisedu_filters
)
WITH (
  OIDS=FALSE
);
ALTER TABLE gisedu_polygon_item_string_fields_new OWNER TO gisedu;
GRANT ALL ON TABLE gisedu_polygon_item_string_fields_new TO gisedu;
GRANT SELECT, UPDATE, INSERT, DELETE, REFERENCES ON TABLE gisedu_polygon_item_string_fields_new TO "gisedu group";

ALTER TABLE gisedu_polygon_item_boolean_fields ADD COLUMN filter_id integer references gisedu_filters;
ALTER TABLE gisedu_polygon_item_integer_fields ADD COLUMN filter_id integer references gisedu_filters;
ALTER TABLE gisedu_polygon_item_string_fields ADD COLUMN filter_id integer references gisedu_filters;
*/


/*
UPDATE gisedu_polygon_item_boolean_fields SET filter_id = gisedu_filters.id
	FROM gisedu_filters JOIN gisedu_field_attributes ON
	gisedu_filters.name = gisedu_field_attributes.name
	WHERE gisedu_polygon_item_boolean_fields.attribute_id = gisedu_field_attributes.id
	AND gisedu_filters.name = gisedu_field_attributes.name;

UPDATE gisedu_polygon_item_integer_fields SET filter_id = gisedu_filters.id
	FROM gisedu_filters JOIN gisedu_field_attributes ON
	gisedu_filters.name = gisedu_field_attributes.name
	WHERE gisedu_polygon_item_integer_fields.attribute_id = gisedu_field_attributes.id
	AND gisedu_filters.name = gisedu_field_attributes.name;

UPDATE gisedu_polygon_item_string_fields SET filter_id = gisedu_filters.id
	FROM gisedu_filters JOIN gisedu_field_attributes ON
	gisedu_filters.name = gisedu_field_attributes.name
	WHERE gisedu_polygon_item_string_fields.attribute_id = gisedu_field_attributes.id
	AND gisedu_filters.name = gisedu_field_attributes.name;
*/

/*
ALTER TABLE gisedu_polygon_item_string_fields ADD COLUMN new_option_id integer references gisedu_string_attribute_option_new;

UPDATE gisedu_polygon_item_string_fields SET new_option_id = gisedu_string_attribute_option_new.id
	FROM gisedu_string_attribute_option_new JOIN gisedu_string_attribute_option ON
	gisedu_string_attribute_option_new.option = gisedu_string_attribute_option.option AND
	gisedu_string_attribute_option_new.attribute_filter_id = gisedu_string_attribute_option.filter_id
	WHERE gisedu_polygon_item_string_fields.option_id = gisedu_string_attribute_option.id AND
	gisedu_string_attribute_option_new.option = gisedu_string_attribute_option.option AND
	gisedu_string_attribute_option_new.attribute_filter_id = gisedu_string_attribute_option.filter_id;
*/

/*
INSERT INTO gisedu_polygon_item_boolean_fields_new (polygon_id, value, attribute_filter_id)
	SELECT polygon_id, value, filter_id FROM gisedu_polygon_item_boolean_fields;

INSERT INTO gisedu_polygon_item_integer_fields_new (polygon_id, value, attribute_filter_id)
	SELECT polygon_id, value, filter_id FROM gisedu_polygon_item_integer_fields;

INSERT INTO gisedu_polygon_item_string_fields_new (polygon_id, option_id, attribute_filter_id)
	SELECT polygon_id, new_option_id, filter_id FROM gisedu_polygon_item_string_fields;
*/

/*
DROP TABLE gisedu_polygon_item_boolean_fields;
DROP TABLE gisedu_polygon_item_integer_fields;
DROP TABLE gisedu_polygon_item_string_fields;

ALTER TABLE gisedu_polygon_item_boolean_fields_new RENAME TO gisedu_polygon_item_boolean_fields;
ALTER TABLE gisedu_polygon_item_integer_fields_new RENAME TO gisedu_polygon_item_integer_fields;
ALTER TABLE gisedu_polygon_item_string_fields_new RENAME TO gisedu_polygon_item_string_fields;
*/

/*
DROP TABLE gisedu_string_attribute_option;
ALTER TABLE gisedu_string_attribute_option_new RENAME TO gisedu_string_attribute_option;
DROP TABLE gisedu_field_attributes;
*/

/*
ALTER TABLE gisedu_reduce_item ADD CONSTRAINT gisedu_reduce_item_pkey PRIMARY KEY(id);
*/

-- UPDATE CODE BASE

-- PUSH TO PRODUCTION

-- DO SYNCDB AT THE END