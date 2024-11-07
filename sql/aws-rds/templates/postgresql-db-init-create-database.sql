SELECT 'CREATE DATABASE "${database}"' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${database}')\gexec
