CONNECT TEST/test@//localhost:1521/CUSTOMSCRIPTS;
-- Create starter set
CREATE TABLE PEOPLE(name VARCHAR2(10));
INSERT INTO PEOPLE (name) VALUES ('Larry');
INSERT INTO PEOPLE (name) VALUES ('Bruno');
INSERT INTO PEOPLE (name) VALUES ('Gerald');
COMMIT;
exit;
