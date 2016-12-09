# ST_Hexnet

PL/pgSQL functions to create and assign data to hexagonal bins across a set of polygon geometries.

## `ST_Hexnet` (found in `hexnet.sql`)

A PL/pgSQL function that will create hexagonal bins of a specified side length bounding a collection of polygon geometries.

#### Usage

```PostgreSQL
SELECT * FROM ST_Hexnet(side_length, 'geometry_table', 'geometry_column', SRID);
```

#### Required arguments

-   `side_length`: How long (in the units of your data's SRID) each hexagonal bin's sides will be.
-   `geometry_table`: The name of the table that holds your polygon geometry collection.
-   `geometry_column`: The field within `geometry_table` that stores polygons' geometric representations.
-   `SRID`: The spacial reference system identifier (or "coordinate system") in which your data is projected. You can explore different SRID values at [epsg.io](http://epsg.io/).

_**Note:**_ _Again, _`side_length`_ is in the units of the specified SRID. It **must** be passed as an integer._

#### Demonstration

```PostgreSQL
SELECT * FROM DFW_census_blocks;
```

<img src="https://raw.githubusercontent.com/DallasMorningNews/hexnet/master/examples/dallas.png" width="350px" style="max-width:50%;">

```PostgreSQL
SELECT * FROM ST_Hexnet(10805, 'DFW_census_blocks', 'geom_4269',32613);
```

<img src="https://raw.githubusercontent.com/DallasMorningNews/hexnet/master/examples/dallas_hex.png" width="350px" style="max-width:50%;">

#### Additional information

Careful geometrists will notice a magic number in the formula at:
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

## `ST_AllocateBins` (found in `allocate.sql`)

A PL/pgSQL function that will allocate already-created hexagonal bins into categories based on a second geographic dataset.

This function processes a list of points with a "number of nearby bins" parameter set for each point. If the first point in this list is allocated 50 bins, it selects the 50 nearest containers to the point and marks them as being allocated.

The process repeats with every listed geographic point that's been allocated 1 or more bins receiving its batch in turn. Allocations can't overlap, so if the second point in the list is originally assigned 10 bins that have already been designated for the first point, the function will find the 10 next-nearest unallocated bins and assign those to point #2 instead.

* _**Note:** This function was originally developed to allocate bins to point geographies, but it may be able to handle other geographic types including _`POLYGON`_ and _`MULTIPOLYGON`_._

#### Usage

```PostgreSQL
SELECT * FROM ST_AllocateBins(
    bin_table,
    bin_geo_column,
    alloc_table,
    alloc_geo_column,
    alloc_bin_count_column,
    allocated_value,
    max_distance
);
```

#### Required arguments


-   `bin_table`: The database table where your bins are stored.
-   `bin_geo_column`: The column in `bin_table` that holds each bin's geographic representation.
-   `alloc_table`: The table where your point allocation data is stored.
-   `alloc_geo_column`: The column within `geo_table` that holds your allocated geometry's geographic representation.
-   `alloc_bin_count_column`: The column within `alloc_table` that holds the number of bins allocated to each respective point/geometry. **Must be an integer.**
-   `allocated_value`: The string that should be saved in each allocated bin, to note that it's been assigned. More on this below.
-   `max_distance`: How far out the function should travel from your geometry when looking for unassigned bins. Uses the same units as your bins' SRID. **Must be an integer.** Lower values help the function finish more quickly, but can keep the function from allocating as many bins as it should.

#### Demonstration

TK

#### Additional information

The table returned by `ST_AllocateBins` is currently designed for binary conditions only. That means only one of two values should be returned in the `allocation` column — whatever was specified in the `allocated_value` parameter and `NULL`.

In the future, ST_AllocateBins will assign an ID from the appropriate `alloc_table`'s geometry to each bin that's been assigned to that geometry. (In county-by-county allocations, for instance, each bin allocated to a county could get that county's FIPS code as an additional parameter.) This ought to help generate more granular allocations, and should likely be added soon.
