/*
ALTER TABLE ohio_libraries DROP COLUMN objectid_1;
ALTER TABLE ohio_libraries DROP COLUMN objectid;
ALTER TABLE ohio_libraries DROP COLUMN latitude;
ALTER TABLE ohio_libraries DROP COLUMN longitude;
ALTER TABLE ohio_libraries DROP COLUMN bbservice;
ALTER TABLE ohio_libraries DROP COLUMN transtech;
ALTER TABLE ohio_libraries DROP COLUMN maxadvdown;
ALTER TABLE ohio_libraries DROP COLUMN maxadvup;
ALTER TABLE ohio_libraries DROP COLUMN identifier;
ALTER TABLE ohio_libraries DROP COLUMN odeirn;
ALTER TABLE ohio_libraries DROP COLUMN irnnum;
ALTER TABLE ohio_libraries DROP COLUMN caicat;
ALTER TABLE ohio_libraries DROP COLUMN loc_conf;
ALTER TABLE ohio_libraries DROP COLUMN ref_org_ty;
ALTER TABLE ohio_libraries DROP COLUMN match_cd;
ALTER TABLE ohio_libraries DROP COLUMN loc_qual;

CREATE TABLE gisedu_point_item_contact
(
  id serial NOT NULL,
  address_id integer references gisedu_point_item_address,
  point_id integer references gisedu_point_item,
  contact_email character varying(254),
  contact_telephone character varying(254),
  CONSTRAINT gisedu_point_item_contact_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE gisedu_point_item_contact OWNER TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE, REFERENCES ON TABLE gisedu_point_item_contact TO "Gisedu Application Group";
GRANT ALL ON TABLE gisedu_point_item_contact TO postgres;

ALTER TABLE ohio_libraries ADD COLUMN point_id integer references gisedu_point_item;
ALTER TABLE ohio_libraries ADD COLUMN address_id integer references gisedu_point_item_address;
ALTER TABLE ohio_libraries ADD COLUMN contact_id integer references gisedu_point_item_contact;
ALTER TABLE ohio_libraries ADD COLUMN filter_id integer references gisedu_filters;

INSERT INTO gisedu_filters (gid, filter_name, filter_type, data_type, request_modifier) VALUES (16, 'Library', 'LIST', 'POINT', 'library');
INSERT INTO gisedu_filters (gid, filter_name, filter_type, data_type, request_modifier) VALUES (17, 'Library CAI', 'CHAR', 'REDUCE', 'library_cai');
INSERT INTO gisedu_filters (gid, filter_name, filter_type, data_type, request_modifier) VALUES (18, 'Library Served', 'BOOL', 'REDUCE', 'library_served');

UPDATE ohio_libraries SET filter_id = 16;

INSERT INTO gisedu_point_item_address (address_line_one, city, state, zip10) SELECT address, city, state, zip FROM ohio_libraries;

UPDATE ohio_libraries SET address_id = gisedu_point_item_address.gid FROM gisedu_point_item_address
	WHERE ohio_libraries.address = gisedu_point_item_address.address_line_one 
	AND ohio_libraries.city = gisedu_point_item_address.city
	AND ohio_libraries.state = gisedu_point_item_address.state
	AND ohio_libraries.zip = gisedu_point_item_address.zip10;

ALTER TABLE ohio_libraries DROP COLUMN address;
ALTER TABLE ohio_libraries DROP COLUMN city;
ALTER TABLE ohio_libraries DROP COLUMN state;
ALTER TABLE ohio_libraries DROP COLUMN zip;

-- YOU MAY HAVE TO RESET THE point_item sequence to 15099 or other.
-- SELECT MAX(id) FROM gisedu_point_item;


INSERT INTO gisedu_point_item (filter_id, item_name, item_address_id, the_geom) 
	SELECT filter_id, name, address_id, the_geom FROM ohio_libraries;

UPDATE ohio_libraries SET point_id = gisedu_point_item.id FROM gisedu_point_item
	WHERE ohio_libraries.filter_id = gisedu_point_item.filter_id
	AND ohio_libraries.name = gisedu_point_item.item_name
	AND ohio_libraries.address_id = gisedu_point_item.item_address_id
	AND ohio_libraries.the_geom = gisedu_point_item.the_geom;

ALTER TABLE ohio_libraries DROP COLUMN name;
ALTER TABLE ohio_libraries DROP COLUMN the_geom;

INSERT INTO gisedu_point_item_contact (address_id, point_id, contact_email, contact_telephone) 
	SELECT address_id, point_id, email, telephone FROM ohio_libraries;

UPDATE ohio_libraries SET contact_id = gisedu_point_item_contact.id FROM gisedu_point_item_contact
	WHERE ohio_libraries.address_id = gisedu_point_item_contact.address_id
	AND ohio_libraries.point_id = gisedu_point_item_contact.point_id
	AND ohio_libraries.email = gisedu_point_item_contact.contact_email
	AND ohio_libraries.telephone = gisedu_point_item_contact.contact_telephone;

ALTER TABLE ohio_libraries DROP COLUMN email;
ALTER TABLE ohio_libraries DROP COLUMN telephone;

ALTER TABLE ohio_libraries ADD COLUMN bserved boolean default False;
UPDATE ohio_libraries SET bserved = True WHERE served = 'Y';

ALTER TABLE ohio_libraries DROP COLUMN served;

INSERT INTO gisedu_boolean_attribute (attribute_name) VALUES ('library_served');

CREATE SEQUENCE gisedu_point_item_boolean_fields_id_seq START 44;
ALTER TABLE gisedu_point_item_boolean_fields ALTER COLUMN id SET DEFAULT nextval('gisedu_point_item_boolean_fields_id_seq'::regclass);

INSERT INTO gisedu_point_item_boolean_fields (point_id, attribute_id, value)
	SELECT ohio_libraries.point_id, gisedu_boolean_attribute.id, ohio_libraries.bserved 
	FROM ohio_libraries JOIN gisedu_boolean_attribute ON gisedu_boolean_attribute.attribute_name = 'library_served';

INSERT INTO gisedu_string_attribute (attribute_name) VALUES ('library_cai');

INSERT INTO gisedu_string_attribute_option (attribute_id, option) SELECT DISTINCT gisedu_string_attribute.id, ohio_libraries.id 
FROM ohio_libraries JOIN gisedu_string_attribute ON gisedu_string_attribute.attribute_name = 'library_cai' WHERE ohio_libraries.id is not null;

-- RESET SEQUENCE OF gisedu_point_item_string_fields
-- SELECT MAX(id) FROM gisedu_point_item_string_fields;


INSERT INTO gisedu_point_item_string_fields (point_id, attribute_id, option_id)
SELECT ohio_libraries.point_id, gisedu_string_attribute.id, gisedu_string_attribute_option.id
FROM ohio_libraries JOIN gisedu_string_attribute ON gisedu_string_attribute.attribute_name = 'library_cai'
JOIN gisedu_string_attribute_option ON gisedu_string_attribute_option.attribute_id = gisedu_string_attribute.id
AND gisedu_string_attribute_option.option = ohio_libraries.id
WHERE ohio_libraries.id is not null;

INSERT INTO gisedu_reduce_item (reduce_filter_id, target_filter_id, item_field)
	SELECT t2.gid, t1.gid, t2.request_modifier
	FROM gisedu_filters t1 JOIN gisedu_filters t2 ON t1.request_modifier = 'library' AND t2.request_modifier = 'library_cai';
INSERT INTO gisedu_reduce_item (reduce_filter_id, target_filter_id, item_field)
	SELECT t2.gid, t1.gid, t2.request_modifier
	FROM gisedu_filters t1 JOIN gisedu_filters t2 ON t1.request_modifier = 'library' AND t2.request_modifier = 'library_served';
*/

-- UPDATE filters, reduce_items, options, and excludes on PROD

