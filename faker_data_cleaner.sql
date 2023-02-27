CREATE PROCEDURE clean_faker_data(
    IN table_name VARCHAR(64),
    IN column_name_with_faker_info VARCHAR(64)
) BEGIN -- Declare variables
DECLARE total_rows INT DEFAULT 0;

DECLARE offset_count INT DEFAULT 0;

DECLARE limit_count INT DEFAULT 60;

DECLARE current_row INT DEFAULT 0;

-- MariaDB only allows 61 joins
-- so adding a limit and offset and deleting records in batches
-- this one was necessary for tables which has 100+ related tables
-- Create a temporary table to store the list of related tables
DROP TEMPORARY TABLE IF EXISTS tmp_related_tables;

CREATE TEMPORARY TABLE IF NOT EXISTS tmp_related_tables (
    table_schema VARCHAR(64),
    table_name VARCHAR(64),
    foreign_key_column VARCHAR(64),
    referenced_table_schema VARCHAR(64),
    referenced_table_name VARCHAR(64),
    referenced_column_name VARCHAR(64),
    idx_number INT
);

-- Insert the list of related tables into the temporary table
SET
    @rn = 0;

INSERT INTO
    tmp_related_tables
SELECT
    kcu.TABLE_SCHEMA,
    kcu.TABLE_NAME,
    kcu.COLUMN_NAME,
    kcu.REFERENCED_TABLE_SCHEMA,
    kcu.REFERENCED_TABLE_NAME,
    kcu.REFERENCED_COLUMN_NAME,
    (@rn := @rn + 1) AS idx_number
FROM
    information_schema.KEY_COLUMN_USAGE kcu
WHERE
    kcu.REFERENCED_TABLE_SCHEMA = DATABASE()
    AND kcu.REFERENCED_TABLE_NAME COLLATE utf8_general_ci = table_name;

-- Check the total number of rows in the temporary table
SELECT
    COUNT(*) INTO total_rows
FROM
    tmp_related_tables;

SET
    SQL_BIG_SELECTS = 1;

SET
    FOREIGN_KEY_CHECKS = 0;

IF total_rows > 0 THEN -- Loop through the related tables and generate the DELETE statement with limit and offset
WHILE current_row < total_rows DO -- Generate the DELETE statement based on the list of related tables
SET
    @delete_statement = CONCAT('DELETE x, ');

SELECT
    GROUP_CONCAT(
        DISTINCT CONCAT(
            rt.table_name,
            '_',
            rt.foreign_key_column,
            '_',
            rt.referenced_column_name
        ) SEPARATOR ', \n'
    ) INTO @related_tables
FROM
    tmp_related_tables rt
where
    rt.idx_number > offset_count
    and rt.idx_number <= offset_count + limit_count;

SET
    @delete_statement = CONCAT(@delete_statement, @related_tables);

SET
    @delete_statement = CONCAT(
        @delete_statement,
        ' FROM ',
        table_name,
        ' AS x '
    );

SELECT
    GROUP_CONCAT(
        DISTINCT CONCAT(
            'LEFT JOIN ',
            rt.table_name,
            ' AS ',
            rt.table_name,
            '_',
            rt.foreign_key_column,
            '_',
            rt.referenced_column_name,
            ' ON ',
            rt.table_name,
            '_',
            rt.foreign_key_column,
            '_',
            rt.referenced_column_name,
            '.',
            rt.foreign_key_column,
            ' = ',
            'x.',
            rt.referenced_column_name
        ) SEPARATOR '\n'
    ) INTO @related_joins
FROM
    tmp_related_tables AS rt
where
    rt.idx_number > offset_count
    and rt.idx_number <= offset_count + limit_count;

SET
    @delete_statement = CONCAT(@delete_statement, @related_joins);

SET
    @delete_statement = CONCAT(
        @delete_statement,
        ' WHERE x.',
        column_name_with_faker_info,
        ' like ',
        ' ''[FAKER]%'' '
    );

-- Execute the DELETE statement
SET
    @sql_statement = @delete_statement;

PREPARE stmt
FROM
    @sql_statement;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

-- Update the offset and current row count
SET
    offset_count = offset_count + limit_count;

SET
    current_row = current_row + limit_count;

END WHILE;

END IF;

SET
    FOREIGN_KEY_CHECKS = 1;

-- Drop the temporary table
DROP TEMPORARY TABLE IF EXISTS tmp_related_tables;

END;

# drop procedure clean_faker_data;
CALL clean_faker_data('tbl_example_1', 'description');