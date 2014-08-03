#ST_Hexnet

A PL/pgSQL function that will create hexagonal bins of a specified side length bounding a collection of polygon geometries.

```PostgreSQL
SELECT * FROM ST_Hexnet(side_length, 'geometry_table', 'geometry_column', SRID);
```

_**Note:** Side length is in the units of the specified SRID **and** must be an integer._

<br>

<img src="https://raw.githubusercontent.com/DallasMorningNews/hexnet/master/examples/dallas.png" width="350px" style="max-width:50%;">

```PostgreSQL
SELECT * FROM ST_Hexnet(10805, 'DFW_census_blocks', 'geom_4269',32613)
```

<img src="https://raw.githubusercontent.com/DallasMorningNews/hexnet/master/examples/dallas_hex.png" width="350px" style="max-width:50%;">

<br><br>__Careful geometrists__ will notice a magic number in the formula at:
```
generate_series(xmin::integer - $1, (xmax*2)::integer + $1, $1*2) as x_series,
```
That number adds extra tessellated hexagons because the length around a regular polyhedron circumscribing a sphere is longer than that along the sphere's circumference. Most of the extra panels are dropped in the outer query.
```
xmax*1
```
<img src="https://raw.githubusercontent.com/DallasMorningNews/hexnet/master/examples/usa_1x.png" width="250px" style="max-width:50%;">
```
xmax*2
```
<img src="https://raw.githubusercontent.com/DallasMorningNews/hexnet/master/examples/usa_2x.png" width="270px" style="max-width:50%;">
```
ST_Intersects(...)
```
<img src="https://raw.githubusercontent.com/DallasMorningNews/hexnet/master/examples/usa.png" width="230px" style="max-width:50%;">
