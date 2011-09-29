SELECT * FROM gisedu_filters t1 JOIN gisedu_field_attributes t2 ON t1.request_modifier = t2.name;

-- CREATE A TABLE CALLED gisedu_filters_new with a new column enabled
-- INSERT ALL non-REDUCE filters into the new list (enable them all)
-- ADD A COLUMN TO field_attributes called 'data' SET this to 'REDUCE' for all items
-- INSERT ALL field_attributes into gisedu_filters_new (enable them all)

-- UPDATE EVERYTHING that references the filters objects to point to the appropriate new filter (LOTS of Joins)

-- UPDATE EVERYTHING that referenced the attribute objects t poin to the appropriate new filter (LOTS of Joins)

-- RENAME gisedu_filters_new to gisedu_filters

-- UPDATE CODE BASE

-- PUSH TO PRODUCTION