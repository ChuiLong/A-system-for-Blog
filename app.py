from flask import Flask, render_template, request, redirect, url_for, flash, session,jsonify
import flask
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
import uuid
import os
from datetime import datetime
from werkzeug.utils import secure_filename
from sqlalchemy.exc import IntegrityError
from sqlalchemy.exc import DBAPIError
from sqlalchemy import text 
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:150125cxh@localhost:3307/blog_str'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)
app.config['SECRET_KEY'] = 'your-very-secret-key-123'


with app.app_context():
    db.session.execute(text("""
    CREATE OR REPLACE VIEW v_user_info AS
      SELECT
        u.user_id,
        u.username,
        u.email,
        u.registered_at,
        u.user_type,
        u.points,    -- 直接从 users 表读取 points
        u.avatar
      FROM users u;
    """))
    
    db.session.execute(text("""
    CREATE OR REPLACE VIEW v_my_posts AS
      SELECT thread_id, author_id, title, created_at, like_count, comment_count
      FROM threads;
    """))
    
    db.session.execute(text("""
    CREATE OR REPLACE VIEW v_liked_posts AS
      SELECT tl.user_id, t.thread_id, t.title, t.created_at AS posted_at, tl.liked_at
      FROM thread_likes tl
      JOIN threads t ON tl.thread_id=t.thread_id;
    """))
    db.session.commit()
    
class User(db.Model):
    __tablename__ = 'users'
    user_id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    username = db.Column(db.String(50), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    registered_at = db.Column(db.DateTime, server_default=db.func.now())
    user_type = db.Column(db.Enum('guest', 'normal', 'member', 'admin'), nullable=False)
    avatar = db.Column(db.String(255), nullable=False, server_default='default.png')
    def verify_password(self, raw_pwd):
        return check_password_hash(self.password_hash, raw_pwd)


@app.template_filter('level_class')
def level_class(points):
    if points < 10:   return 'novice'
    if points < 50:   return 'beginner'
    if points < 200:  return 'intermediate'
    if points < 500:  return 'advanced'
    if points < 1000: return 'master'
    return 'legend'

@app.template_filter('level_name')
def level_name(points):
    mapping = {
      'novice': '新手',
      'beginner': '入门',
      'intermediate': '熟手',
      'advanced': '高手',
      'master': '大师',
      'legend': '宗师'
    }
    return mapping.get(level_class(points), '未知')

@app.context_processor
def inject_user_points():
    if 'user_id' in session:
        row = db.session.execute(
            text("SELECT points FROM users WHERE user_id=:u"),  # 改为 users 表
            {'u': session['user_id']}
        ).fetchone()
        pts = row.points if row else 0
    else:
        pts = 0
    return {'g_points': pts}


class Notification(db.Model):
    __tablename__ = 'notifications'
    notification_id = db.Column(db.String(36), primary_key=True)
    user_id         = db.Column(db.String(36),
                          db.ForeignKey('users.user_id'), nullable=False)
    type            = db.Column(db.Enum('comment'), nullable=False)
    comment_id       = db.Column(db.String(36), nullable=False)
    thread_id       = db.Column(db.String(36), nullable=False)
    created_at      = db.Column(db.DateTime,
                          server_default=db.func.now())
    is_read         = db.Column(db.Boolean,
                          default=False, nullable=False)

@app.context_processor
def inject_notif_count():
    cnt = 0
    if 'user_id' in session:
        cnt = db.session.query(db.func.count())\
            .select_from(Notification)\
            .filter_by(user_id=session['user_id'], is_read=False)\
            .scalar() or 0
    return {'notif_unread_count': cnt}

@app.route('/notifications')
def notifications():
    if 'user_id' not in session:
        flash('请先登录','warning')
        return redirect(url_for('login'))
    notes = Notification.query\
        .filter_by(user_id=session['user_id'])\
        .order_by(Notification.created_at.desc())\
        .all()
    return render_template('notifications.html', notifications=notes)

@app.route('/api/notifications/mark_read', methods=['POST'])
def mark_read():
    if 'user_id' not in session:
        return jsonify(error='未登录'),401
    Notification.query.filter_by(
        user_id=session['user_id'], is_read=False
    ).update({'is_read':True})
    db.session.commit()
    return jsonify(success=True)
@app.route('/')
def index():
    db.session.execute(text("""
        UPDATE threads AS t
        LEFT JOIN (
            SELECT thread_id, COUNT(*) AS cnt
            FROM comments
            GROUP BY thread_id
        ) AS c ON t.thread_id = c.thread_id
        SET t.comment_count = IFNULL(c.cnt, 0)
    """))
    db.session.commit()

    selected_board = request.args.get('board_id')
    search_query = request.args.get('search', '').strip()

    sql = """
    SELECT
      t.thread_id,
      t.title,
      LEFT(t.content,200) AS excerpt,
      v.username,
      v.points   AS author_points,
      v.user_id  AS author_id,
      t.created_at,
      t.like_count,
      t.comment_count,
      b.name     AS board_name
    FROM threads t
    JOIN v_user_info v ON t.author_id = v.user_id
    JOIN boards b      ON t.board_id = b.board_id
    WHERE t.status='published'
    """
    params = {}
    
    if selected_board:
        sql += " AND t.board_id = :board_id"
        params['board_id'] = selected_board
        
    if search_query:
        sql += " AND (t.title LIKE :search OR t.content LIKE :search)"
        params['search'] = f'%{search_query}%'

    sql += " ORDER BY t.created_at DESC LIMIT 20"

    threads = db.session.execute(text(sql), params).fetchall()
    
    announcements = db.session.execute(text("""
        SELECT announcement_id, title, content, created_at, is_pinned, 
               u.username as author_name
        FROM announcements a
        JOIN users u ON a.author_id = u.user_id
        WHERE a.is_active = TRUE
        ORDER BY a.is_pinned DESC, a.created_at DESC
        LIMIT 3
    """)).fetchall()
    
    stats = {}
    
    stats['total_threads'] = db.session.execute(text("""
        SELECT COUNT(*) FROM threads WHERE status = 'published'
    """)).scalar()
    
    stats['total_users'] = db.session.execute(text("""
        SELECT COUNT(*) FROM users
    """)).scalar()
    
    stats['active_boards'] = db.session.execute(text("""
        SELECT COUNT(DISTINCT board_id) FROM threads WHERE status = 'published'
    """)).scalar()
    
    stats['today_active_users'] = db.session.execute(text("""
        SELECT COUNT(DISTINCT user_id) FROM (
            SELECT author_id as user_id FROM threads 
            WHERE DATE(created_at) = CURDATE()
            UNION
            SELECT user_id FROM comments 
            WHERE DATE(created_at) = CURDATE()
        ) as active_users
    """)).scalar()
    
    stats['week_active_users'] = db.session.execute(text("""
        SELECT COUNT(DISTINCT user_id) FROM (
            SELECT author_id as user_id FROM threads 
            WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
            UNION
            SELECT user_id FROM comments 
            WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
        ) as active_users
    """)).scalar()
    
    stats['total_comments'] = db.session.execute(text("""
        SELECT COUNT(*) FROM comments
    """)).scalar()
    
    stats['today_threads'] = db.session.execute(text("""
        SELECT COUNT(*) FROM threads 
        WHERE DATE(created_at) = CURDATE() AND status = 'published'
    """)).scalar()
    
    return render_template(
        'index.html',
        threads=threads,
        announcements=announcements,
        search_query=search_query,
        selected_board=selected_board,
        stats=stats 
    )


@app.route('/messages')
def messages():
    if 'user_id' not in session:
        flash('请先登录', 'warning')
        return redirect(url_for('login'))

    uid = session['user_id']
    conversations = db.session.execute(text("""
        SELECT
            -- 计算对方 ID
            CASE
              WHEN vc.sender_id   = :uid THEN vc.receiver_id
              ELSE vc.sender_id
            END AS other_user_id,
            -- 视图中已经包含最后内容和时间
            vc.last_content,
            vc.last_message_time,
            -- 如果需要头像/名字，可选取 sender 或 receiver 字段
            CASE
              WHEN vc.sender_id   = :uid THEN vc.receiver_name
              ELSE vc.sender_name
            END AS other_username,
            CASE
              WHEN vc.sender_id   = :uid THEN vc.receiver_avatar
              ELSE vc.sender_avatar
            END AS other_avatar,
            -- 计算未读数
            (SELECT COUNT(*) FROM messages 
             WHERE receiver_id = :uid 
               AND is_read     = FALSE
               AND CONCAT(
                     LEAST(sender_id,receiver_id),':', 
                     GREATEST(sender_id,receiver_id)
                   ) = vc.conversation_id
            ) AS unread_count
        FROM v_conversations vc
        WHERE vc.sender_id   = :uid 
           OR vc.receiver_id = :uid
        ORDER BY vc.last_message_time DESC
    """), {'uid': uid}).fetchall()

    total_unread = db.session.execute(text("""
        SELECT COUNT(*) FROM messages
         WHERE receiver_id = :uid AND is_read = FALSE
    """), {'uid': uid}).scalar()

    return render_template('messages.html',
                           conversations=conversations,
                           total_unread=total_unread)

@app.route('/messages/<other_user_id>')
def chat_with_user(other_user_id):
    if 'user_id' not in session:
        flash('请先登录', 'warning')
        return redirect(url_for('login'))
    
    other_user = db.session.execute(text(
        "SELECT user_id, username, avatar FROM users WHERE user_id = :uid"
    ), {'uid': other_user_id}).fetchone()
    
    if not other_user:
        flash('用户不存在', 'warning')
        return redirect(url_for('messages'))
    
    chat_messages = db.session.execute(text("""
        SELECT m.message_id, m.content, m.created_at, m.sender_id, m.is_read,
               u.username as sender_name, u.avatar as sender_avatar
        FROM messages m
        JOIN users u ON m.sender_id = u.user_id
        WHERE (m.sender_id = :uid AND m.receiver_id = :other)
           OR (m.sender_id = :other AND m.receiver_id = :uid)
        ORDER BY m.created_at ASC
    """), {'uid': session['user_id'], 'other': other_user_id}).fetchall()
    
    db.session.execute(text("""
        UPDATE messages SET is_read = TRUE
        WHERE sender_id = :other AND receiver_id = :uid AND is_read = FALSE
    """), {'other': other_user_id, 'uid': session['user_id']})
    db.session.commit()
    
    return render_template('chat.html', 
                         messages=chat_messages, 
                         other_user=other_user, 
                         other_user_id=other_user_id)

@app.route('/messages/<other_user_id>/send', methods=['POST'])
def send_message(other_user_id):
    if 'user_id' not in session:
        return jsonify({'error': '未登录'}), 401
    
    content = request.form.get('content', '').strip()
    if not content:
        return jsonify({'error': '消息内容不能为空'}), 400
    
    other_user = db.session.execute(text(
        "SELECT 1 FROM users WHERE user_id = :uid"
    ), {'uid': other_user_id}).fetchone()
    
    if not other_user:
        return jsonify({'error': '用户不存在'}), 404
    
    if other_user_id == session['user_id']:
        return jsonify({'error': '不能给自己发消息'}), 400
    
    try:
        message_id = str(uuid.uuid4())
        db.session.execute(text("""
            INSERT INTO messages (message_id, sender_id, receiver_id, content, created_at)
            VALUES (:mid, :sender, :receiver, :content, :at)
        """), {
            'mid': message_id,
            'sender': session['user_id'],
            'receiver': other_user_id,
            'content': content,
            'at': datetime.now()
        })
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message_id': message_id,
            'content': content,
            'created_at': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'sender_name': session['username'],
            'sender_avatar': session['avatar']
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': '发送失败'}), 500

@app.route('/messages/<message_id>/delete', methods=['POST'])
def delete_message(message_id):
    if 'user_id' not in session:
        return jsonify({'error': '未登录'}), 401
    
    try:
        result = db.session.execute(text("""
            DELETE FROM messages 
            WHERE message_id = :mid AND sender_id = :uid
        """), {'mid': message_id, 'uid': session['user_id']})
        
        if result.rowcount == 0:
            return jsonify({'error': '消息不存在或无权删除'}), 403
        
        db.session.commit()
        return jsonify({'success': True})
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': '删除失败'}), 500

@app.route('/api/unread_messages_count')
def unread_messages_count():
    """API接口：获取未读消息数量，用于导航栏显示"""
    if 'user_id' not in session:
        return jsonify({'count': 0})
    
    count = db.session.execute(text("""
        SELECT COUNT(*) FROM messages 
        WHERE receiver_id = :uid AND is_read = FALSE
    """), {'uid': session['user_id']}).scalar()
    
    return jsonify({'count': count})

@app.route('/start_chat/<user_id>')
def start_chat(user_id):
    """从用户主页发起私信"""
    if 'user_id' not in session:
        flash('请先登录', 'warning')
        return redirect(url_for('login'))
    
    if user_id == session['user_id']:
        flash('不能给自己发消息', 'warning')
        return redirect(url_for('user_space', uid=user_id))
    
    user = db.session.execute(text(
        "SELECT username FROM users WHERE user_id = :uid"
    ), {'uid': user_id}).fetchone()
    
    if not user:
        flash('用户不存在', 'warning')
        return redirect(url_for('index'))
    
    return redirect(url_for('chat_with_user', other_user_id=user_id))
@app.route('/admin/announcements')
def admin_announcements():
    if 'user_id' not in session:
        flash('请先登录', 'warning')
        return redirect(url_for('login'))
    
    if session.get('user_type') != 'admin':
        flash('权限不足', 'danger')
        return redirect(url_for('index'))
    
    announcements = db.session.execute(text("""
        SELECT a.announcement_id, a.title, a.content, a.created_at, 
               a.is_pinned, a.is_active, u.username as author_name
        FROM announcements a
        JOIN users u ON a.author_id = u.user_id
        ORDER BY a.is_pinned DESC, a.created_at DESC
    """)).fetchall()
    
    return render_template('admin_announcements.html', announcements=announcements)

@app.route('/admin/announcements/create', methods=['GET', 'POST'])
def create_announcement():
    if 'user_id' not in session:
        flash('请先登录', 'warning')
        return redirect(url_for('login'))
    
    if session.get('user_type') != 'admin':
        flash('权限不足', 'danger')
        return redirect(url_for('index'))
    
    if request.method == 'POST':
        title = request.form.get('title', '').strip()
        content = request.form.get('content', '').strip()
        is_pinned = bool(request.form.get('is_pinned'))
        
        if not title or not content:
            flash('标题和内容不能为空', 'danger')
            return render_template('create_announcement.html')
        
        try:
            announcement_id = str(uuid.uuid4())
            db.session.execute(text("""
                INSERT INTO announcements (announcement_id, title, content, author_id, is_pinned, created_at)
                VALUES (:aid, :title, :content, :author_id, :is_pinned, :created_at)
            """), {
                'aid': announcement_id,
                'title': title,
                'content': content,
                'author_id': session['user_id'],
                'is_pinned': is_pinned,
                'created_at': datetime.now()
            })
            db.session.commit()
            flash('公告发布成功', 'success')
            return redirect(url_for('admin_announcements'))
        except Exception as e:
            db.session.rollback()
            flash('发布失败，请重试', 'danger')
            return render_template('create_announcement.html')
    
    return render_template('create_announcement.html')

@app.route('/admin/announcements/<announcement_id>/toggle', methods=['POST'])
def toggle_announcement(announcement_id):
    if 'user_id' not in session:
        return jsonify({'error': '未登录'}), 401
    
    if session.get('user_type') != 'admin':
        return jsonify({'error': '权限不足'}), 403
    
    try:
        db.session.execute(text("""
            UPDATE announcements 
            SET is_active = NOT is_active 
            WHERE announcement_id = :aid
        """), {'aid': announcement_id})
        db.session.commit()
        return jsonify({'success': True})
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': '操作失败'}), 500

@app.route('/admin/announcements/<announcement_id>/delete', methods=['POST'])
def delete_announcement(announcement_id):
    if 'user_id' not in session:
        return jsonify({'error': '未登录'}), 401
    
    if session.get('user_type') != 'admin':
        return jsonify({'error': '权限不足'}), 403
    
    try:
        db.session.execute(text(
            "DELETE FROM announcements WHERE announcement_id = :aid"
        ), {'aid': announcement_id})
        db.session.commit()
        return jsonify({'success': True})
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': '删除失败'}), 500
@app.route('/profile/avatar', methods=['POST'])
def upload_avatar():
    if 'user_id' not in session:
        flash('请先登录', 'warning')
        return redirect(url_for('login'))

    f = request.files.get('avatar')
    if f and f.filename:
        fn  = secure_filename(f.filename)
        ext = fn.rsplit('.',1)[-1].lower()
        if ext not in ('png','jpg','jpeg','gif'):
            flash('只支持 png/jpg/gif 格式', 'danger')
            return redirect(url_for('profile'))

        new_fn = f"{session['user_id']}.{ext}"
        save_path = os.path.join(app.root_path, 'static', 'avatars', new_fn)
        f.save(save_path)

        db.session.execute(text(
          "UPDATE users SET avatar=:a WHERE user_id=:uid"
        ), {'a': new_fn, 'uid': session['user_id']})
        db.session.commit()

        session['avatar'] = new_fn
        flash('头像已更新', 'success')

    return redirect(url_for('profile'))

@app.route('/board/<board_id>/follow', methods=['POST'])
def follow_board(board_id):
    """关注板块"""
    if 'user_id' not in session:
        if request.is_json:
            return jsonify({'error': '请先登录'}), 401
        flash('请先登录', 'warning')
        return redirect(url_for('login'))
    
    board = db.session.execute(text(
        "SELECT name FROM boards WHERE board_id = :bid"
    ), {'bid': board_id}).fetchone()
    
    if not board:
        if request.is_json:
            return jsonify({'error': '板块不存在'}), 404
        flash('板块不存在', 'warning')
        return redirect(url_for('all_boards'))
    
    try:
        db.session.execute(text("""
            INSERT INTO board_follows (user_id, board_id, follow_time)
            VALUES (:uid, :bid, :at)
        """), {
            'uid': session['user_id'],
            'bid': board_id,
            'at': datetime.now()
        })
        db.session.commit()
        
        if request.is_json:
            return jsonify({'success': True, 'message': f'已关注 {board.name}'})
        flash(f'已关注板块 "{board.name}"', 'success')
        
    except IntegrityError:
        db.session.rollback()
        if request.is_json:
            return jsonify({'error': '您已关注过该板块'}), 400
        flash('您已关注过该板块', 'info')
    except Exception as e:
        db.session.rollback()
        if request.is_json:
            return jsonify({'error': '关注失败'}), 500
        flash('关注失败，请重试', 'danger')
    
    return redirect(request.referrer or url_for('all_boards'))

@app.route('/board/<board_id>/unfollow', methods=['POST'])
def unfollow_board(board_id):
    """取消关注板块"""
    if 'user_id' not in session:
        if request.is_json:
            return jsonify({'error': '请先登录'}), 401
        flash('请先登录', 'warning')
        return redirect(url_for('login'))
    
    board = db.session.execute(text(
        "SELECT name FROM boards WHERE board_id = :bid"
    ), {'bid': board_id}).fetchone()
    
    if not board:
        if request.is_json:
            return jsonify({'error': '板块不存在'}), 404
        flash('板块不存在', 'warning')
        return redirect(url_for('all_boards'))
    
    try:
        result = db.session.execute(text("""
            DELETE FROM board_follows 
            WHERE user_id = :uid AND board_id = :bid
        """), {'uid': session['user_id'], 'bid': board_id})
        
        if result.rowcount == 0:
            if request.is_json:
                return jsonify({'error': '您未关注该板块'}), 400
            flash('您未关注该板块', 'info')
        else:
            db.session.commit()
            if request.is_json:
                return jsonify({'success': True, 'message': f'已取消关注 {board.name}'})
            flash(f'已取消关注板块 "{board.name}"', 'success')
            
    except Exception as e:
        db.session.rollback()
        if request.is_json:
            return jsonify({'error': '取消关注失败'}), 500
        flash('取消关注失败，请重试', 'danger')
    
    return redirect(request.referrer or url_for('all_boards'))

@app.route('/my/followed_boards')
def my_followed_boards():
    """我关注的板块列表"""
    if 'user_id' not in session:
        flash('请先登录', 'warning')
        return redirect(url_for('login'))
    
    followed_boards = db.session.execute(text("""
        SELECT b.board_id, b.name, b.description, bf.follow_time,
               COUNT(DISTINCT t.thread_id) as thread_count,
               COUNT(DISTINCT bf2.user_id) as follower_count
        FROM board_follows bf
        JOIN boards b ON bf.board_id = b.board_id
        LEFT JOIN threads t ON b.board_id = t.board_id AND t.status = 'published'
        LEFT JOIN board_follows bf2 ON b.board_id = bf2.board_id
        WHERE bf.user_id = :uid
        GROUP BY b.board_id, b.name, b.description, bf.follow_time
        ORDER BY bf.follow_time DESC
    """), {'uid': session['user_id']}).fetchall()
    
    return render_template('my_followed_boards.html', followed_boards=followed_boards)

@app.route('/api/board/<board_id>/follow_status')
def board_follow_status(board_id):
    """获取板块关注状态 API"""
    if 'user_id' not in session:
        return jsonify({'is_followed': False, 'follower_count': 0})
    
    is_followed = db.session.execute(text("""
        SELECT 1 FROM board_follows 
        WHERE user_id = :uid AND board_id = :bid
    """), {'uid': session['user_id'], 'bid': board_id}).fetchone()
    
    follower_count = db.session.execute(text("""
        SELECT COUNT(*) FROM board_follows WHERE board_id = :bid
    """), {'bid': board_id}).scalar()
    
    return jsonify({
        'is_followed': bool(is_followed),
        'follower_count': follower_count or 0
    })

@app.route('/user/<uid>')
def user_space(uid):

    user = db.session.execute(text(
        "SELECT user_id, username, email, registered_at, user_type, points, avatar "  # 添加了 user_id
        "FROM v_user_info WHERE user_id=:uid"
    ), {'uid': uid}).fetchone()
    if not user:
        flask.abort(404)


    my_posts = db.session.execute(text(
        "SELECT thread_id,title,created_at,like_count,comment_count "
        "FROM v_my_posts WHERE author_id=:uid ORDER BY created_at DESC"
    ), {'uid': uid}).fetchall()


    show_likes = session.get('user_id') == uid
    liked_posts = []
    if show_likes:
        liked_posts = db.session.execute(text(
            "SELECT thread_id,title,posted_at,liked_at "
            "FROM v_liked_posts WHERE user_id=:uid ORDER BY liked_at DESC"
        ), {'uid': uid}).fetchall()
    
    show_self = session.get('user_id') == uid
    favorite_posts = []
    if show_self:
        favorite_posts = db.session.execute(text(
            "SELECT thread_id,title,posted_at,favorited_at "
            "FROM v_favorited_posts WHERE user_id=:uid ORDER BY favorited_at DESC"
        ), {'uid': uid}).fetchall()
    
    return render_template('profile.html',
                           user=user,
                           my_posts=my_posts,
                           liked_posts=liked_posts,
                           favorite_posts=favorite_posts,
                           is_self=show_likes,
                           points=user.points)


@app.context_processor
def inject_user():
    """注入用户信息和板块数据到所有模板"""
    print("=== inject_user 被调用 ===") 
    
    user_data = {
        'session': session,
        'username': session.get('username'),
        'avatar': session.get('avatar', 'default.png')
    }
    

    try:
        if 'user_id' in session:
            print(f"用户已登录：{session['user_id']}")

            boards = db.session.execute(text("""
                SELECT b.board_id, b.name,
                       IF(bf.user_id IS NOT NULL, 1, 0) as is_followed
                FROM boards b
                LEFT JOIN board_follows bf ON (b.board_id = bf.board_id AND bf.user_id = :uid)
                ORDER BY IF(bf.user_id IS NOT NULL, 1, 0) DESC, b.name ASC
            """), {'uid': session['user_id']}).fetchall()
            
            print(f"查询到 {len(boards)} 个板块")
            for board in boards[:5]:  
                print(f"  - {board.name}: 关注状态={board.is_followed}")
                
        else:
            print("用户未登录")
            boards = db.session.execute(text(
                "SELECT board_id, name, 0 as is_followed FROM boards ORDER BY name"
            )).fetchall()
            print(f"查询到 {len(boards)} 个板块（未登录）")
        
        user_data['boards'] = boards
        
    except Exception as e:
        print(f"查询板块时出错：{e}")
        import traceback
        traceback.print_exc()
        user_data['boards'] = []
    
    user_data['selected_board'] = request.args.get('board_id')
    
    is_admin = False
    if 'user_id' in session:
        try:
            admin_check = db.session.execute(text(
                "SELECT user_type FROM users WHERE user_id = :uid AND user_type = 'admin'"
            ), {'uid': session['user_id']}).fetchone()
            is_admin = bool(admin_check)
        except:
            is_admin = False
    user_data['is_admin'] = is_admin
    
    print(f"返回数据：boards数量={len(user_data['boards'])}")
    return user_data

@app.route('/login/', methods=['GET', 'POST'])
def login():
    if request.method == 'GET':
        return render_template('login.html')


    username = request.form.get('username', '').strip()
    password = request.form.get('password', '').strip()

    if not username or not password:
        flash('用户名和密码不能为空', 'danger')
        return redirect(url_for('login'))

    user = User.query.filter_by(username=username).first()
    if not user or not user.verify_password(password):
        flash('用户名或密码错误', 'danger')
        return redirect(url_for('login'))


    session['user_id'] = user.user_id
    session['username'] = user.username
    session['user_type'] = user.user_type
    session['avatar']    = user.avatar
    flash(f'欢迎回来，{user.username}！', 'success')
    return redirect(url_for('index'))
@app.route('/thread/<thread_id>/favorite', methods=['POST'])
def favorite_thread(thread_id):
    if 'user_id' not in session:
        flash('请先登录才能收藏', 'warning')
        return redirect(url_for('login'))
    try:
        db.session.execute(text(
            "INSERT INTO thread_favorites(user_id,thread_id,favorited_at) "
            "VALUES(:uid,:tid,:at)"
        ), {'uid': session['user_id'], 'tid': thread_id, 'at': datetime.now()})
        db.session.commit()
        flash('收藏成功', 'success')
    except IntegrityError:
        db.session.rollback()
        flash('您已收藏过该帖子', 'info')
    return redirect(url_for('thread_detail', thread_id=thread_id))

@app.route('/thread/<thread_id>/unfavorite', methods=['POST'])
def unfavorite_thread(thread_id):
    if 'user_id' not in session:
        flash('请先登录', 'warning')
        return redirect(url_for('login'))
    db.session.execute(text(
        "DELETE FROM thread_favorites WHERE user_id=:uid AND thread_id=:tid"
    ), {'uid': session['user_id'], 'tid': thread_id})
    db.session.commit()
    flash('已取消收藏', 'success')
    return redirect(url_for('thread_detail', thread_id=thread_id))

@app.route('/logout/')
def logout():
    session.clear()
    flash('您已退出登录', 'info')
    return redirect(url_for('login'))

@app.route('/register/', methods=['GET', 'POST'])
def register():
    if request.method == 'GET':
        return render_template('register.html')

    username = request.form.get('username', '').strip()
    email = request.form.get('email', '').strip()
    pwd = request.form.get('password', '').strip()
    pwd2 = request.form.get('confirm_password', '').strip()
    if not username or not email or not pwd or not pwd2:
        flash('请完整填写所有字段', 'danger')
        return redirect(url_for('register'))
    if pwd != pwd2:
        flash('两次输入的密码不一致', 'danger')
        return redirect(url_for('register'))
    if User.query.filter((User.username==username)|(User.email==email)).first():
        flash('用户名或邮箱已被使用', 'danger')
        return redirect(url_for('register'))

    user = User(username=username,
                email=email,
                password_hash=generate_password_hash(pwd),
                user_type='normal')
    db.session.add(user)
    db.session.commit()

    flash('注册成功，请登录', 'success')
    return redirect(url_for('login'))


    
@app.route('/thread/<thread_id>/', methods=['GET','POST'])
def thread_detail(thread_id):
    if request.method == 'POST':
        if 'user_id' not in session:
            flash('请先登录！','warning')
            return redirect(url_for('login'))

        content   = request.form.get('content','').strip()
        parent_id = request.form.get('parent_comment_id') or None
        if not content:
            flash('评论内容不能为空','danger')
            return redirect(url_for('thread_detail', thread_id=thread_id))

        new_cid = str(uuid.uuid4())
        try:

            db.session.execute(text(
                "INSERT INTO comments "
                "(comment_id,thread_id,user_id,content,parent_comment_id,created_at) "
                "VALUES(:cid,:tid,:uid,:ct,:pid,:at)"
            ), {
                'cid': new_cid,
                'tid': thread_id,
                'uid': session['user_id'],
                'ct':  content,
                'pid': parent_id,
                'at':  datetime.now()
            })

            db.session.execute(text(
                "UPDATE threads SET comment_count = comment_count + 1 "
                "WHERE thread_id=:tid"
            ), {'tid': thread_id})
            db.session.commit()
            flash('评论提交成功','success')
            return redirect(
                url_for('thread_detail', thread_id=thread_id) + f'#comment-{new_cid}'
            )

        except DBAPIError as e:
            db.session.rollback()

            orig = getattr(e, 'orig', None)
            msg = orig.args[1] if getattr(orig, 'args', None) else str(e)
            flash(f'评论失败：{msg}', 'danger')
            return redirect(url_for('thread_detail', thread_id=thread_id))

    db.session.execute(text(
        "UPDATE threads AS t "
        "SET t.comment_count = (SELECT COUNT(*) FROM comments c WHERE c.thread_id = :tid) "
        "WHERE t.thread_id = :tid"
    ), {'tid': thread_id})
    db.session.commit()


    th = db.session.execute(text("""
SELECT
  t.thread_id, t.title, t.content,
  v.username, v.points AS author_points, v.avatar,
  t.created_at, t.like_count, t.comment_count, t.author_id
FROM threads t
JOIN v_user_info v ON t.author_id = v.user_id
WHERE t.thread_id = :tid AND t.status='published';
        """), {'tid': thread_id}).fetchone()


    rows = db.session.execute(text(
        "SELECT c.comment_id, c.content, c.created_at, "
        "v.username, v.points AS comment_points,c.parent_comment_id "
        "FROM comments c "
        "JOIN v_user_info v ON c.user_id=v.user_id "
        "WHERE c.thread_id=:tid "
        "ORDER BY c.created_at"
    ), {'tid': thread_id}).fetchall()

    comment_map = {r.comment_id: {'data': r, 'children': []} for r in rows}
    roots = []
    for r in rows:
        node = comment_map[r.comment_id]
        if r.parent_comment_id and r.parent_comment_id in comment_map:
            comment_map[r.parent_comment_id]['children'].append(node)
        else:
            roots.append(node)

    is_favorited = False
    if 'user_id' in session:
        row = db.session.execute(text(
            "SELECT 1 FROM thread_favorites WHERE user_id=:uid AND thread_id=:tid"
        ), {'uid': session['user_id'], 'tid': thread_id}).fetchone()
        is_favorited = bool(row)

    return render_template(
        'thread_detail.html',
        thread=th,
        comments=roots,
        is_favorited=is_favorited
    )
    
    
    

@app.route('/boards/')
def all_boards():
    """
    显示所有板块的页面，关注的板块会被置顶显示
    """
    if 'user_id' in session:
        boards = db.session.execute(text("""
            SELECT b.board_id, b.name, b.description,
                   CASE WHEN bf.user_id IS NOT NULL THEN 1 ELSE 0 END as is_followed,
                   COUNT(DISTINCT t.thread_id) as thread_count,
                   COUNT(DISTINCT bf2.user_id) as follower_count
            FROM boards b
            LEFT JOIN board_follows bf ON b.board_id = bf.board_id AND bf.user_id = :uid
            LEFT JOIN threads t ON b.board_id = t.board_id AND t.status = 'published'
            LEFT JOIN board_follows bf2 ON b.board_id = bf2.board_id
            GROUP BY b.board_id, b.name, b.description, is_followed
            ORDER BY is_followed DESC, b.name ASC
        """), {'uid': session['user_id']}).fetchall()
    else:
        boards = db.session.execute(text("""
            SELECT b.board_id, b.name, b.description, 0 as is_followed,
                   COUNT(DISTINCT t.thread_id) as thread_count,
                   COUNT(DISTINCT bf.user_id) as follower_count
            FROM boards b
            LEFT JOIN threads t ON b.board_id = t.board_id AND t.status = 'published'
            LEFT JOIN board_follows bf ON b.board_id = bf.board_id
            GROUP BY b.board_id, b.name, b.description
            ORDER BY b.name ASC
        """)).fetchall()
    
    return render_template('boards.html', boards=boards)
@app.route('/thread/<thread_id>/delete', methods=['POST'])
def delete_thread(thread_id):

    if 'user_id' not in session:
        flash('请先登录！', 'warning')
        return redirect(url_for('login'))

    user_id = session['user_id']

    try:
       
        db.session.execute(text(
            "CALL delete_thread_sp(:tid, :uid)"
        ), {'tid': thread_id, 'uid': user_id})

        db.session.commit()
        flash('帖子已成功删除（及其所有点赞和评论）', 'success')
        return redirect(url_for('index'))

    except DBAPIError as e:

        db.session.rollback()

        msg = str(e.orig) if hasattr(e, 'orig') else str(e)
        flash(f'删除失败：{msg}', 'danger')
        return redirect(url_for('thread_detail', thread_id=thread_id))
@app.route('/thread/<thread_id>/like', methods=['POST'])
def like_thread(thread_id):
    if 'user_id' not in session:

        if request.is_json:
            return jsonify({'error': 'not_login'}), 401
        flash('请先登录才能点赞', 'warning')
        return redirect(url_for('login'))

    try:

        sql_like = """
        INSERT INTO thread_likes (user_id, thread_id, liked_at)
        VALUES (:user_id, :thread_id, :liked_at)
        """
        db.session.execute(text(sql_like), {
            'user_id': session['user_id'],
            'thread_id': thread_id,
            'liked_at': datetime.now()
        })

        db.session.execute(text("""
            UPDATE threads
            SET like_count = like_count + 1
            WHERE thread_id = :thread_id
        """), {'thread_id': thread_id})
        db.session.commit()

    except IntegrityError:
        db.session.rollback()

        if request.is_json:
            return jsonify({'status': 'already_liked'}), 200
        flash('您已点赞过该帖子', 'info')
    else:
        if request.is_json:

            new_count = db.session.execute(text("""
                SELECT like_count FROM threads WHERE thread_id=:thread_id
            """), {'thread_id': thread_id}).scalar_one()
            return jsonify({'status': 'ok', 'like_count': new_count})
        flash('点赞成功', 'success')

    return redirect(url_for('thread_detail', thread_id=thread_id))

@app.route('/thread/create', methods=['GET','POST'])
def create_thread():
        if 'user_id' not in session:
            flash('请先登录！', 'warning')
            return redirect(url_for('login'))
        if request.method == 'POST':
            board_id = request.form.get('board_id')
            title    = request.form.get('title','').strip()
            content  = request.form.get('content','').strip()
            if not board_id or not title or not content:
                flash('请填写所有字段', 'danger')
                return redirect(url_for('create_thread'))
            tid = str(uuid.uuid4())
            db.session.execute(text(
                "INSERT INTO threads "
                "(thread_id, board_id, author_id, title, content, created_at, status) "
                "VALUES (:tid,:bid,:uid,:title,:content,:at,'published')"
            ), {
                'tid': tid,
                'bid': board_id,
                'uid': session['user_id'],
                'title': title,
                'content': content,
                'at': datetime.now()
            })
            db.session.commit()
            flash('发帖成功', 'success')
            return redirect(url_for('thread_detail', thread_id=tid))

        boards = db.session.execute(text(
            "SELECT board_id, name FROM boards ORDER BY name"
        )).fetchall()
        return render_template('thread_create.html', boards=boards)


@app.route('/profile')
def profile():

    if 'user_id' not in session:
        flash('请先登录', 'warning')
        return redirect(url_for('login'))


    return redirect(url_for('user_space', uid=session['user_id']))



@app.route('/search')
def search():
    q = request.args.get('q', '').strip()
    if not q:
        flash('请输入搜索关键词', 'warning')
        return redirect(url_for('index'))


    boards = db.session.execute(text(
        "SELECT board_id, name FROM boards ORDER BY name"
    )).fetchall()


    sql = """
    SELECT
      t.thread_id,
      t.title,
      LEFT(t.content,200) AS excerpt,
      v.username,
      v.points AS author_points,
      v.user_id AS author_id,
      t.created_at,
      t.like_count,
      t.comment_count,
      b.name AS board_name
    FROM threads t
    JOIN v_user_info v ON t.author_id = v.user_id
    JOIN boards b ON t.board_id = b.board_id
    WHERE t.status='published'
      AND (t.title LIKE :kw OR t.content LIKE :kw)
    ORDER BY t.created_at DESC
    LIMIT 50
    """
    kw = f"%{q}%"
    threads = db.session.execute(text(sql), {'kw': kw}).fetchall()


    announcements = db.session.execute(text("""
        SELECT announcement_id, title, content, created_at, is_pinned, 
               u.username as author_name
        FROM announcements a
        JOIN users u ON a.author_id = u.user_id
        WHERE a.is_active = TRUE
        ORDER BY a.is_pinned DESC, a.created_at DESC
        LIMIT 3
    """)).fetchall()


    stats = {}
    

    stats['total_threads'] = db.session.execute(text("""
        SELECT COUNT(*) FROM threads WHERE status = 'published'
    """)).scalar()
    
    stats['total_users'] = db.session.execute(text("""
        SELECT COUNT(*) FROM users
    """)).scalar()
    

    stats['active_boards'] = db.session.execute(text("""
        SELECT COUNT(DISTINCT board_id) FROM threads WHERE status = 'published'
    """)).scalar()
    

    stats['today_active_users'] = db.session.execute(text("""
        SELECT COUNT(DISTINCT user_id) FROM (
            SELECT author_id as user_id FROM threads 
            WHERE DATE(created_at) = CURDATE()
            UNION
            SELECT user_id FROM comments 
            WHERE DATE(created_at) = CURDATE()
        ) as active_users
    """)).scalar()
    

    stats['week_active_users'] = db.session.execute(text("""
        SELECT COUNT(DISTINCT user_id) FROM (
            SELECT author_id as user_id FROM threads 
            WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
            UNION
            SELECT user_id FROM comments 
            WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
        ) as active_users
    """)).scalar()
    

    stats['total_comments'] = db.session.execute(text("""
        SELECT COUNT(*) FROM comments
    """)).scalar()
    

    stats['today_threads'] = db.session.execute(text("""
        SELECT COUNT(*) FROM threads 
        WHERE DATE(created_at) = CURDATE() AND status = 'published'
    """)).scalar()


    return render_template('index.html',
                           threads=threads,
                           announcements=announcements,
                           search_query=q,
                           selected_board=None,
                           stats=stats) 
@app.route('/admin/')
def admin_dashboard():
    if session.get('user_type')!='admin':
        flash('无权访问', 'danger')
        return redirect(url_for('index'))

    posts = db.session.execute(text("""
      SELECT t.thread_id, t.title, u.username, t.created_at
      FROM threads t 
      JOIN users u ON t.author_id=u.user_id
      ORDER BY t.created_at DESC
    """)).fetchall()

    comments = db.session.execute(text("""
      SELECT c.comment_id, c.content, u.username, c.created_at, t.title AS thread_title
      FROM comments c
      JOIN users u ON c.user_id=u.user_id
      JOIN threads t ON c.thread_id=t.thread_id
      ORDER BY c.created_at DESC
    """)).fetchall()
    boards = db.session.execute(text("""
      SELECT board_id, name FROM boards ORDER BY name
    """)).fetchall()
    return render_template('admin.html', posts=posts, comments=comments, boards=boards)

@app.route('/admin/thread/<thread_id>/delete', methods=['POST'])
def admin_delete_thread(thread_id):

    if session.get('user_type') != 'admin':
        flash('无权操作', 'danger')
        return redirect(url_for('admin_dashboard'))
    next_url = request.args.get('next', url_for('admin_dashboard'))
    try:

        db.session.execute(
            text("CALL delete_thread_sp(:tid, :uid)"),
            {'tid': thread_id, 'uid': session['user_id']}
        )
        db.session.commit()
        flash('帖子及其所有点赞和评论已删除', 'success')
    except DBAPIError as e:
        db.session.rollback()

        msg = str(e.orig) if hasattr(e, 'orig') else '删除失败'
        flash(f'删除失败：{msg}', 'danger')

    return redirect(next_url)


@app.route('/admin/comment/<comment_id>/delete', methods=['POST'])
def admin_delete_comment(comment_id):

    if session.get('user_type') != 'admin':
        flash('无权操作', 'danger')
        return redirect(url_for('admin_dashboard'))
    next_url = request.args.get('next', url_for('admin_dashboard'))
    try:

        db.session.execute(
            text("CALL delete_comment_sp(:cid, :uid)"),
            {'cid': comment_id, 'uid': session['user_id']}
        )
        db.session.commit()
        flash('评论及其回复已删除', 'success')
    except DBAPIError as e:
        db.session.rollback()
        msg = str(e.orig) if hasattr(e, 'orig') else '删除失败'
        flash(f'删除失败：{msg}', 'danger')

    return redirect(next_url)


@app.route('/admin/merge_boards', methods=['GET','POST'])
def admin_merge_boards():

    if session.get('user_type') != 'admin':
        flash('权限不足','danger')
        return redirect(url_for('admin_dashboard'))


    if request.method=='GET':
        boards = db.session.execute(text(
            "SELECT board_id,name FROM boards ORDER BY name"
        )).fetchall()
        return render_template('merge_boards.html', boards=boards)


    src = request.form.get('src_board')
    dst = request.form.get('dst_board')
    if not src or not dst or src==dst:
        flash('请选择不同的源和目标板块','danger')
        return redirect(url_for('admin_merge_boards'))

    try:
        db.session.execute(text("CALL merge_boards_sp(:src,:dst,:admin)"),
                           {'src': src,'dst': dst,'admin': session['user_id']})
        db.session.commit()
        flash('板块合并成功','success')
    except DBAPIError as e:
        db.session.rollback()
        err = e.orig.args[1] if hasattr(e.orig,'args') else str(e)
        flash(f'合并失败：{err}','danger')
    return redirect(url_for('admin_dashboard'))


if __name__ == '__main__':
    app.run(debug=True)