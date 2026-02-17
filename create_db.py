import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

DB_NAME = "adaptive_english"
DB_USER = "postgres"
DB_PASSWORD = "Group30"
DB_HOST = "localhost"
DB_PORT = 5432

def create_database():
    
    conn = psycopg2.connect(
        dbname="postgres",
        user=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT,
    )
    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    cur = conn.cursor()

   
    cur.execute("SELECT 1 FROM pg_database WHERE datname = %s;", (DB_NAME,))
    exists = cur.fetchone()

    if exists:
        print(f"✅ Database '{DB_NAME}' already exists.")
    else:
        cur.execute(f'CREATE DATABASE "{DB_NAME}";')
        print(f"✅ Database '{DB_NAME}' created successfully!")

    cur.close()
    conn.close()

if __name__ == "__main__":
    create_database()
