One approach you could take is to write a recursive function that deletes the related data in the child tables first, and then deletes the data in the parent table. This way, you don't have to worry about manually identifying and deleting the related data in each child table.

Here's an example of how you could write such a function in a procedural language like MySQL Stored Procedures:

```sql

CREATE PROCEDURE delete_data (IN p_table_name VARCHAR(100), IN p_column VARCHAR(100), IN p_value INT)
BEGIN
  DECLARE v_child_table VARCHAR(100);
  DECLARE v_child_column VARCHAR(100);
  DECLARE v_child_value INT;

  DECLARE cur CURSOR FOR
    SELECT referenced_table_name, referenced_column_name, referenced_id
    FROM information_schema.key_column_usage
    WHERE table_name = p_table_name AND column_name = p_column;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET @done = TRUE;

  SET @done = FALSE;
  OPEN cur;
  REPEAT
    FETCH cur INTO v_child_table, v_child_column, v_child_value;
    IF NOT @done THEN
      CALL delete_data(v_child_table, v_child_column, v_child_value);
    END IF;
  UNTIL @done END REPEAT;
  CLOSE cur;

  SET @sql = CONCAT('DELETE FROM ', p_table_name, ' WHERE ', p_column, ' = ', p_value);
  PREPARE stmt FROM @sql;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
END;

```

This stored procedure takes the name of the parent table, the name of the column to use as the reference, and the value to use as the reference. It uses the information_schema.key_column_usage table to identify the child tables and their foreign key relationships, and then recursively calls itself to delete the data in the child tables. Finally, it deletes the data in the parent table.

You can call this stored procedure to delete the data in your tables:

```
CALL delete_data('parent_table', 'some_column', some_value);

```
