#hexnet
======

A PostgreSQL function that will create hexagonal bins of side length X bounding a collection of polygon geometry.

```PostgreSQL
SELECT * FROM ST_Hexnet(side_length, 'geometry_table', 'geometry_column', SRID);
```

**Note:** Side length is in the units of the specified SRID and must be an integer.
