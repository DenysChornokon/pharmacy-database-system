import bcrypt
import psycopg2
from psycopg2.extras import RealDictCursor
from flask import Flask, g, jsonify, request
from flask_cors import CORS
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity

# Ініціалізація Flask застосунку
app = Flask(__name__)
app.config['JWT_SECRET_KEY'] = 'your_secret_key'  # Змініть це на складний секретний ключ
CORS(app)

# Ініціалізація JWT
jwt = JWTManager(app)

# Налаштування підключення до PostgreSQL
DATABASE = {
    'dbname': 'pharmacy',
    'user': 'postgres',
    'password': '12345',
    'host': '127.0.0.1',
    'port': '5432'
}

# Функція підключення до бази даних
def get_db_connection():
    if 'db_conn' not in g:
        g.db_conn = psycopg2.connect(
            dbname=DATABASE['dbname'],
            user=DATABASE['user'],
            password=DATABASE['password'],
            host=DATABASE['host'],
            port=DATABASE['port']
        )
        g.db_conn.autocommit = True
    return g.db_conn

# Закриття з'єднання після завершення роботи
@app.teardown_appcontext
def close_db_connection(exception):
    db_conn = g.pop('db_conn', None)
    if db_conn is not None:
        db_conn.close()

# Декоратор для перевірки ролі
def role_required(required_role):
    def wrapper(fn):
        @jwt_required()
        def decorator(*args, **kwargs):
            claims = get_jwt_identity()
            if claims["role"] != required_role:
                return jsonify({"error": "Access denied"}), 403
            return fn(*args, **kwargs)
        decorator.__name__ = fn.__name__  # Додаємо ім'я функції, щоб уникнути конфліктів
        return decorator
    return wrapper

# Маршрут для реєстрації користувача
@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    role_name = data.get('role_name')  # Наприклад, "Адміністратор системи"

    if not username or not password or not role_name:
        return jsonify({"error": "Missing data"}), 400

    # Хешування паролю
    password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)

        # Отримуємо role_id на основі role_name
        cursor.execute('SELECT role_id FROM Roles WHERE role_name = %s', (role_name,))
        role = cursor.fetchone()
        if not role:
            return jsonify({"error": "Invalid role"}), 400
        role_id = role['role_id']

        # Додавання користувача в базу
        cursor.execute(
            'INSERT INTO Users (username, password_hash, role_id) VALUES (%s, %s, %s)',
            (username, password_hash, role_id)
        )
    except psycopg2.IntegrityError:
        return jsonify({"error": "Username already exists"}), 400
    finally:
        cursor.close()
        conn.close()

    return jsonify({"message": "User registered successfully"}), 201

# Маршрут для входу користувача
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({"error": "Missing username or password"}), 400

    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)

    # Перевірка користувача у базі даних
    cursor.execute('SELECT * FROM Users JOIN Roles ON Users.role_id = Roles.role_id WHERE username = %s', (username,))
    user = cursor.fetchone()
    cursor.close()
    conn.close()

    if user and bcrypt.checkpw(password.encode('utf-8'), user['password_hash'].encode('utf-8')):
        # Створення JWT токена з ідентифікацією користувача
        access_token = create_access_token(identity={"username": user["username"], "role": user["role_name"]})
        return jsonify({"message": "Login successful", "access_token": access_token, "role": user["role_name"]})  # Передаємо роль у відповіді
    else:
        return jsonify({"error": "Invalid username or password"}), 401

# Захищений маршрут для адміністратора
@app.route('/admin', methods=['GET'], endpoint='admin_page')
@role_required("Адміністратор системи")
def admin_page():
    return jsonify({"message": "Welcome to the Admin Page"})

# Захищений маршрут для фармацевта
@app.route('/pharmacist', methods=['GET'], endpoint='pharmacist_page')
@role_required("Фармацевт")
def pharmacist_page():
    return jsonify({"message": "Welcome to the Pharmacist Page"})

# Захищений маршрут для менеджера з продажу
@app.route('/sales_manager', methods=['GET'], endpoint='sales_manager_page')
@role_required("Менеджер з продажу")
def sales_manager_page():
    return jsonify({"message": "Welcome to the Sales Manager Page"})

# Запуск сервера
if __name__ == '__main__':
    app.run(debug=True)
