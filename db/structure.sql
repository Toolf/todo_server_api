CREATE TABLE Todo (
    todoId int NOT NULL AUTO_INCREMENT,
    title varchar(64) NOT NULL,
    description text NOT NULL,
    completed boolean NOT NULL DEFAULT false,
    CONSTRAINT todoPk PRIMARY KEY (todoId)
);