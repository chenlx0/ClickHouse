SET use_analyzer = 1;

DROP TABLE IF EXISTS test_table_join_1;
CREATE TABLE test_table_join_1
(
    id UInt64,
    value String
) ENGINE = TinyLog;

DROP TABLE IF EXISTS test_table_join_2;
CREATE TABLE test_table_join_2
(
    id UInt64,
    value String
) ENGINE = TinyLog;

DROP TABLE IF EXISTS test_table_join_3;
CREATE TABLE test_table_join_3
(
    id UInt64,
    value String
) ENGINE = TinyLog;

INSERT INTO test_table_join_1 VALUES (0, 'Join_1_Value_0');
INSERT INTO test_table_join_1 VALUES (1, 'Join_1_Value_1');
INSERT INTO test_table_join_1 VALUES (3, 'Join_1_Value_3');

INSERT INTO test_table_join_2 VALUES (0, 'Join_2_Value_0');
INSERT INTO test_table_join_2 VALUES (1, 'Join_2_Value_1');
INSERT INTO test_table_join_2 VALUES (2, 'Join_2_Value_2');

INSERT INTO test_table_join_3 VALUES (0, 'Join_3_Value_0');
INSERT INTO test_table_join_3 VALUES (1, 'Join_3_Value_1');
INSERT INTO test_table_join_3 VALUES (2, 'Join_3_Value_2');

SELECT 'Join without ON conditions';

SELECT test_table_join_1.id, test_table_join_1.value, test_table_join_2.id, test_table_join_2.value
FROM test_table_join_1 INNER JOIN test_table_join_2 ON test_table_join_1.id = test_table_join_2.id;

SELECT '--';

SELECT test_table_join_1.id, test_table_join_1.value, test_table_join_2.id, test_table_join_2.value
FROM test_table_join_1 AS t1 INNER JOIN test_table_join_2 AS t2 ON test_table_join_1.id = test_table_join_2.id;

SELECT '--';

SELECT t1.id, t1.value, t2.id, t2.value
FROM test_table_join_1 AS t1 INNER JOIN test_table_join_2 AS t2 ON t1.id = t2.id;

SELECT '--';

SELECT t1.id, test_table_join_1.id, t1.value, test_table_join_1.value, t2.id, test_table_join_2.id, t2.value, test_table_join_2.value
FROM test_table_join_1 AS t1 INNER JOIN test_table_join_2 AS t2 ON t1.id = t2.id;

SELECT '--';

SELECT test_table_join_1.id, test_table_join_1.value, test_table_join_2.id, test_table_join_2.value, test_table_join_3.id, test_table_join_3.value
FROM test_table_join_1 INNER JOIN test_table_join_2 ON test_table_join_1.id = test_table_join_2.id
    INNER JOIN test_table_join_3 ON test_table_join_2.id = test_table_join_3.id;

SELECT '--';

SELECT t1.id, t1.value, t2.id, t2.value, t3.id, t3.value
FROM test_table_join_1 AS t1 INNER JOIN test_table_join_2 AS t2 ON t1.id = t2.id
    INNER JOIN test_table_join_3 AS t3 ON t2.id = t3.id;

SELECT '--';

SELECT t1.id, test_table_join_1.id, t1.value, test_table_join_1.value, t2.id, test_table_join_2.id, t2.value, test_table_join_2.value,
t3.id, test_table_join_3.id, t3.value, test_table_join_3.value
FROM test_table_join_1 AS t1 INNER JOIN test_table_join_2 AS t2 ON t1.id = t2.id
    INNER JOIN test_table_join_3 AS t3 ON t2.id = t3.id;

SELECT id FROM test_table_join_1 INNER JOIN test_table_join_2 ON test_table_join_1.id = test_table_join_2.id; -- { serverError 36 }

SELECT value FROM test_table_join_1 INNER JOIN test_table_join_2 ON test_table_join_1.id = test_table_join_2.id; -- { serverError 36 }

SELECT 'Join with ON conditions';

SELECT t1.id, t1.value, t2.id, t2.value
FROM test_table_join_1 AS t1 INNER JOIN test_table_join_2 AS t2 ON t1.id = t2.id AND t1.value = 'Join_1_Value_0';

SELECT '--';

SELECT t1.id, t1.value, t2.id, t2.value
FROM test_table_join_1 AS t1 INNER JOIN test_table_join_2 AS t2 ON t1.id = t2.id AND t2.value = 'Join_2_Value_0';

SELECT '--';

SELECT t1.id, t1.value, t2.id, t2.value
FROM test_table_join_1 AS t1 INNER JOIN test_table_join_2 AS t2 ON t1.id = t2.id AND t1.value = 'Join_1_Value_0' AND t2.value = 'Join_2_Value_0';

SELECT '--';

SELECT t1.id, t1.value, t2.id, t2.value
FROM test_table_join_1 AS t1 INNER JOIN test_table_join_2 AS t2 ON toString(t1.id) = toString(t2.id) AND t1.value = 'Join_1_Value_0' AND t2.value = 'Join_2_Value_0';

SELECT '--';

SELECT t1.id, t1.value, t2.id, t2.value, t3.id, t3.value
FROM test_table_join_1 AS t1 INNER JOIN test_table_join_2 AS t2 ON t1.id = t2.id AND t2.value == 'Join_2_Value_0'
INNER JOIN test_table_join_3 AS t3 ON t2.id = t3.id AND t3.value == 'Join_3_Value_0';

SELECT '--';

SELECT t1.id, t1.value, t2.id, t2.value, t3.id, t3.value
FROM test_table_join_1 AS t1 INNER JOIN test_table_join_2 AS t2 ON t1.id = t2.id AND t1.value == 'Join_1_Value_0' AND t2.value == 'Join_2_Value_0'
INNER JOIN test_table_join_3 AS t3 ON t2.id = t3.id AND t2.value == 'Join_2_Value_0' AND t3.value == 'Join_3_Value_0';

SELECT '--';

SELECT t1.id, t1.value, t2.id, t2.value, t3.id, t3.value
FROM test_table_join_1 AS t1 INNER JOIN test_table_join_2 AS t2 ON t1.id = t2.id AND t2.value == 'Join_2_Value_0'
INNER JOIN test_table_join_3 AS t3 ON t1.id = t3.id AND t3.value == 'Join_3_Value_0';

SELECT '--';

SELECT t1.id, t1.value, t2.id, t2.value, t3.id, t3.value
FROM test_table_join_1 AS t1 INNER JOIN test_table_join_2 AS t2 ON t1.id = t2.id AND t1.value == 'Join_1_Value_0' AND t2.value == 'Join_2_Value_0'
INNER JOIN test_table_join_3 AS t3 ON t1.id = t3.id AND t2.value == 'Join_2_Value_0' AND t3.value == 'Join_3_Value_0';

SELECT '--';

SELECT t1.id, t1.value, t2.id, t2.value, t3.id, t3.value
FROM test_table_join_1 AS t1 INNER JOIN test_table_join_2 AS t2 ON toString(t1.id) = toString(t2.id) AND t2.value == 'Join_2_Value_0'
    INNER JOIN test_table_join_3 AS t3 ON toString(t2.id) = toString(t3.id) AND t3.value == 'Join_3_Value_0';

SELECT 'Join only join expression use keys';

SELECT t1.value, t2.value
FROM test_table_join_1 AS t1 INNER JOIN test_table_join_2 AS t2 ON t1.id = t2.id;

SELECT '--';

SELECT t1.value, t2.value
FROM test_table_join_1 AS t1 INNER JOIN test_table_join_2 AS t2 ON t1.id = t2.id;

SELECT '--';

SELECT t1.value, t2.value, t3.value
FROM test_table_join_1 AS t1
INNER JOIN test_table_join_2 AS t2 ON t1.id = t2.id
INNER JOIN test_table_join_2 AS t3 ON t2.id = t3.id;

SELECT '--';

SELECT t1.value, t2.value, t3.value
FROM test_table_join_1 AS t1
INNER JOIN test_table_join_2 AS t2 ON t1.id = t2.id
INNER JOIN test_table_join_2 AS t3 ON t1.id = t3.id;


DROP TABLE test_table_join_1;
DROP TABLE test_table_join_2;
DROP TABLE test_table_join_3;
