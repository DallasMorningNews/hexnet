#hexnet
======
A PostgreSQL function that will create hexagonal bins of side length X bounding a collection of polygon geometry.

```PostgreSQL
SELECT * FROM ST_Hexnet(side_length, 'geometry_table', 'geometry_column', SRID);
```

**Note:** Side length is in the units of the specified SRID and must be an integer.

<img src="https://raw.githubusercontent.com/DallasMorningNews/hexnet/master/dallas.png" style="max-width:50%;">

```
SELECT * FROM ST_Hexnet(10805, 'tabblock2010_dfw_pophu', 'geom_4269',32613)
```

<img src="https://raw.githubusercontent.com/DallasMorningNews/hexnet/master/dallas_hex.png" style="max-width:50%;">
