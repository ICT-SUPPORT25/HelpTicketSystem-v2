from app import app, db
from models import Category

DEFAULT_CATEGORIES = [
    'Network',
    'Hardware',
    'Software',
    'Printer',
    'Email',
    'University MIS System Issue',
    'Account/Access',
    'Other'
]

with app.app_context():
    added = 0
    for name in DEFAULT_CATEGORIES:
        if not Category.query.filter_by(name=name).first():
            c = Category(name=name, description=f'Default category: {name}')
            db.session.add(c)
            added += 1
    db.session.commit()
    print(f'Added {added} categories (if any were missing).')
