from app import app
from extensions import db

def init_db():
    with app.app_context():
        # import models so tables are registered with SQLAlchemy metadata
        try:
            import models  # noqa: F401
        except Exception:
            pass

        try:
            db.create_all()
            print("Database tables created (or already exist).")
        except Exception as e:
            print("Error creating tables:", e)
            raise

if __name__ == '__main__':
    init_db()
