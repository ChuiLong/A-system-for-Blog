# migrate_passwords.py
from app import app, db
from app import User
from werkzeug.security import generate_password_hash

with app.app_context():
    users = User.query.all()
    for u in users:
        raw = u.password_hash         # 这里拿到的就是明文
        # 请根据你想要的算法调整 method，比如 'pbkdf2:sha256', 'bcrypt' 等
        hashed = generate_password_hash(raw, method='pbkdf2:sha256', salt_length=8)
        u.password_hash = hashed
    db.session.commit()
    print(f"总共处理了 {len(users)} 条用户记录，已更新为哈希密码。")