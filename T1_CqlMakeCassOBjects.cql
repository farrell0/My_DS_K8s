

DROP KEYSPACE IF EXISTS ks1;

CREATE KEYSPACE ks1
   WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};

USE ks1;

CREATE TABLE t1
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
INSERT INTO t1 (col1, col2, col3, col4)
   VALUES ('666', '666', '666', '666');
INSERT INTO t1 (col1, col2, col3, col4)
   VALUES ('777', '777', '777', '777');
INSERT INTO t1 (col1, col2, col3, col4)
   VALUES ('888', '888', '888', '888');
INSERT INTO t1 (col1, col2, col3, col4)
   VALUES ('999', '999', '999', '999');
INSERT INTO t1 (col1, col2, col3, col4)
   VALUES ('000', '000', '000', '000');

USE ks1;
SELECT COUNT(*) FROM t1;

