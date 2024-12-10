CREATE SCHEMA IF NOT EXISTS ${flyway:defaultSchema};
SET SEARCH_PATH TO ${flyway:defaultSchema};
CREATE SEQUENCE IF NOT EXISTS "USER_SEQ"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 100;

CREATE TABLE IF NOT EXISTS USERS
(
    ID    numeric      not null
        constraint "USER_PK"
            primary key DEFAULT nextval('${flyway:defaultSchema}."USER_SEQ"'),
    NAME  varchar(200) not null,
    EMAIL varchar(200) not null
);
INSERT INTO USERS (NAME, EMAIL)
VALUES ('John', 'John.ipsum@test.com'),
       ('Jane', 'Jane.ipsum@test.com'),
       ('Jack', 'Jack.ipsum@test.com'),
       ('Jill', 'Jill.ipsum@test.com'),
       ('Joe', 'Joe.ipsum@test.com');

