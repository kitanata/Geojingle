INSERT INTO gisedu_point_item_address_new SELECT * FROM gisedu_point_item_address;

ALTER TABLE gisedu_point_item DROP CONSTRAINT gisedu_point_item_item_address_id_fkey;

ALTER TABLE gisedu_point_item
  ADD CONSTRAINT gisedu_point_item_item_address_id_fkey FOREIGN KEY (item_address_id)
      REFERENCES gisedu_point_item_address_new (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE gisedu_point_item_contact DROP CONSTRAINT gisedu_point_item_contact_address_id_fkey;

ALTER TABLE gisedu_point_item_contact
  ADD CONSTRAINT gisedu_point_item_contact_address_id_fkey FOREIGN KEY (address_id)
      REFERENCES gisedu_point_item_address_new (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

DROP TABLE gisedu_point_item_address;

-- Manually set the sequence of the new table to be that of...

SELECT MAX(id) from gisedu_point_item_address_new