-- $Id$
--
CREATE OR REPLACE VIEW
rhnVisibleServerGroup
AS
  SELECT *
    FROM rhnServerGroup SG
   WHERE SG.group_type IS NULL;
