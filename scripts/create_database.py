#!/usr/bin/env python3
"""Create the MySQL database if it doesn't exist, then run SQLAlchemy table creation.

Usage:
  Activate the virtual env (PowerShell): .venv/Scripts/Activate.ps1
  python scripts/create_database.py
"""
from dotenv import load_dotenv
import os
import pymysql
import sys
from pathlib import Path


def create_database_if_not_exists(host, port, user, password, dbname):
    print(f"Connecting to MySQL server at {host}:{port} as {user} to ensure database '{dbname}' exists...")
    conn = pymysql.connect(host=host, port=port, user=user, password=password, autocommit=True)
    try:
        with conn.cursor() as cur:
            cur.execute(f"CREATE DATABASE IF NOT EXISTS `{dbname}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;")
            print(f"Database '{dbname}' ensured (created if it did not exist).")
    finally:
        conn.close()


def main():
    load_dotenv()
    host = os.environ.get('MYSQL_HOST', '127.0.0.1')
    port = int(os.environ.get('MYSQL_PORT', '3307'))
    user = os.environ.get('MYSQL_USER', 'root')
    password = os.environ.get('MYSQL_PASSWORD', '')
    dbname = os.environ.get('MYSQL_DATABASE', 'help_desk_db')

    try:
        create_database_if_not_exists(host, port, user, password, dbname)
    except Exception as e:
        print(f"Failed to create database: {e}")
        raise

    # Ensure the repo root is on sys.path so we can import init_db when running from scripts/
    repo_root = Path(__file__).resolve().parents[1]
    sys.path.insert(0, str(repo_root))

    # Now run the app's init_db to create tables via SQLAlchemy
    try:
        from init_db import init_db
        print("Running SQLAlchemy table creation (init_db)...")
        init_db()
        print("Table creation finished.")
    except Exception as e:
        print(f"Failed to create tables via SQLAlchemy: {e}")
        raise


if __name__ == '__main__':
    main()
