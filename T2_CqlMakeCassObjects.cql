

DROP KEYSPACE IF EXISTS ks2;

CREATE KEYSPACE ks2
   WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};

USE ks2;

CREATE TABLE t2
   (
   col1 TEXT PRIMARY KEY,
   col2 TEXT,
   col3 TEXT,
   col4 TEXT
   );

INSERT INTO t1 (col1, col2, col3, col4)
   VALUES ('111', '111', '111', '111');
INSERT INTO t1 (col1, col2, col3, col4)
   VALUES ('222', '222', '222', '222');
INSERT INTO t1 (col1, col2, col3, col4)
   VALUES ('333', '333', '333', '333');
INSERT INTO t1 (col1, col2, col3, col4)
   VALUES ('444', '444', '444', '444');
INSERT INTO t1 (col1, col2, col3, col4)
   VALUES ('555', '555', '555', '555');

USE ks2;
SELECT COUNT(*) FROM t2;

