
from app import app, db
from models import User
from werkzeug.security import generate_password_hash

def create_admin():
    with app.app_context():
        # Check if admin already exists
        admin = User.query.filter_by(username='215030').first()
        if admin:
            print("Admin user already exists!")
            return
        
        # Create admin user
        admin_user = User(
            username='215030',
            email='admin@helpdesk.com',
            full_name='System Administrator',
            password_hash=generate_password_hash('admin123'),
            role='admin',
            is_verified=True,
            is_active=True,
            is_approved=True
        )
        
        db.session.add(admin_user)
        db.session.commit()
        print("Admin user created successfully!")
        print("Username: 215030")
        print("Password: admin123")

if __name__ == '__main__':
    create_admin()
