CREATE OR REPLACE FUNCTION ST_AllocateBins(
    bin_table varchar,
    bin_geo_column varchar,
    geo_table varchar,
    centroid_column varchar,
    bin_count varchar,
    allocated_value varchar,
    max_distance numeric
)
RETURNS Table(id int4, geom geometry, allocation varchar(30)) AS $$
DECLARE
    row RECORD;
BEGIN
    EXECUTE format(
        concat_ws(
            '',
            'CREATE TEMP TABLE temp_allocated_bins',
            '    ON COMMIT DROP',
            '    AS SELECT * FROM %I'
        ),
        $1
    );
    EXECUTE 'ALTER TABLE temp_allocated_bins ADD COLUMN allocation varchar(30) DEFAULT NULL';

    FOR row IN EXECUTE format(
        'SELECT %I AS centroid, %I AS num_bins FROM %I WHERE %I > 0',
        $4,
        $5,
        $3,
        $5
    )
    LOOP
        EXECUTE format(
            concat_ws(
                ' ',
                'CREATE TEMP TABLE temp_county_bin_allocations',
                '    AS SELECT *',
                '        FROM temp_allocated_bins',
                '        WHERE allocation IS NULL',
                '            AND ST_DWithin(%I, %L, %s)',
                '        ORDER BY ST_Distance(%I, %L)',
                '        LIMIT %L'
            ),
            $2,
            row.centroid,
            $7,
            $2,
            row.centroid,
            row.num_bins
        );

        EXECUTE format(
            concat_ws(
                ' ',
                'UPDATE temp_allocated_bins',
                '    SET allocation = %L',
                '    FROM temp_county_bin_allocations',
                '    WHERE temp_allocated_bins.id = temp_county_bin_allocations.id'
            ),
            $6
        );

        DROP TABLE temp_county_bin_allocations;
    END LOOP;

    RETURN QUERY EXECUTE format(
        concat_ws(
            ' ',
            'SELECT',
            '        b.id,',
            '        b.%I AS geom,',
            '        b.allocation',
            '    FROM temp_allocated_bins b'
        ),
        $2
    );
END
$$
LANGUAGE plpgsql;