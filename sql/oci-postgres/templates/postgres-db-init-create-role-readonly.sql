REVOKE ALL ON SCHEMA public FROM PUBLIC;
DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles  -- SELECT list can be empty for this
      WHERE  rolname = '${username}') THEN

CREATE USER "${username}" WITH ENCRYPTED PASSWORD '${db_password}';
GRANT CONNECT, CREATE ON DATABASE "${database}" TO "${username}";
GRANT CREATE, USAGE ON SCHEMA public TO "${username}";
ALTER DEFAULT PRIVILEGES FOR USER ${admin_user} IN SCHEMA public GRANT INSERT, REFERENCES, SELECT, UPDATE, DELETE, TRUNCATE ON TABLES TO "${username}";
ALTER DEFAULT PRIVILEGES FOR USER ${admin_user} IN SCHEMA public GRANT SELECT, UPDATE ON SEQUENCES TO "${username}";
ELSE
ALTER USER "${username}" PASSWORD '${db_password}';
END IF;

   IF NOT EXISTS(
           SELECT FROM pg_catalog.pg_roles  -- SELECT list can be empty for this
           WHERE  rolname = '${database}_rduser') THEN
CREATE USER "${database}_rduser" WITH ENCRYPTED PASSWORD '${db_readonlypassword}';
GRANT CONNECT ON DATABASE "${database}" TO "${database}_rduser";
GRANT USAGE ON SCHEMA public TO "${database}_rduser";
ALTER DEFAULT PRIVILEGES FOR USER ${admin_user} IN SCHEMA public GRANT SELECT ON TABLES TO "${database}_rduser";
ELSE
ALTER USER "${database}_rduser" PASSWORD '${db_readonlypassword}';
END IF;

END
$do$;