USE ${database};

CREATE USER IF NOT EXISTS '${username}'@'%' IDENTIFIED BY '${db_password}';
GRANT CREATE, ALTER, USAGE ON `${database}`.* TO `${username}`;
GRANT INSERT, INDEX, REFERENCES, EXECUTE, SELECT, UPDATE, DELETE, DROP ON `${database}`.* TO `${username}`;


CREATE USER IF NOT EXISTS '${database}_rduser'@'%' IDENTIFIED BY '${db_readonlypassword}';
GRANT USAGE ON *.* TO `${database}_rduser@%`;
GRANT SELECT ON `${database}`.*  TO `${database}_rduser`;