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
    role_name = data.get('role_name')

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
    selected_role = data.get('selectedRole')  # Отримуємо вибрану роль з запиту

    if not username or not password or not selected_role:
        return jsonify({"error": "Missing username, password, or role"}), 400

    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)

    # Перевірка користувача у базі даних
    cursor.execute('SELECT * FROM Users JOIN Roles ON Users.role_id = Roles.role_id WHERE username = %s', (username,))
    user = cursor.fetchone()
    cursor.close()
    conn.close()

    if user and bcrypt.checkpw(password.encode('utf-8'), user['password_hash'].encode('utf-8')):
        # Виведення значень ролей для діагностики
        print(f"Роль з бази даних: {user['role_name']}, Вибрана роль: {selected_role}")

        # Перевірка з нормалізацією тексту
        if user["role_name"].strip().lower() != selected_role.strip().lower():
            return jsonify({"error": "Selected role does not match user role"}), 403

        # Створення JWT токена з ідентифікацією користувача
        access_token = create_access_token(identity={"username": user["username"], "role": user["role_name"]})
        return jsonify({"message": "Login successful", "access_token": access_token, "role": user["role_name"]})
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

# Маршрут для перегляду препаратів
@app.route("/view-drugs", methods=["GET"])
@jwt_required()
def view_drugs():
    try:
        # Виконуємо SQL-запит для отримання даних про всі препарати
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT ID, Name, Price, Total_amount, Manufacturer_ID, Requires_prescription
            FROM Drug ORDER BY id
        """)

        # Отримуємо результат у вигляді списку словників
        drugs = [
            {
                "id": row[0],
                "name": row[1],
                "price": float(row[2]),
                "quantity": row[3],
                "manufacturer_id": row[4],
                "requires_prescription": row[5]
            }
            for row in cursor.fetchall()
        ]

        cursor.close()
        return jsonify(drugs), 200

    except Exception as e:
        print("Error fetching drugs:", e)
        return jsonify({"error": "Не вдалося завантажити дані про препарати"}), 500


# Маршрут для перегляду клієнтів
@app.route("/view-clients", methods=["GET"])
@jwt_required()
def view_clients():
    try:
        # Виконуємо SQL-запит для отримання даних про всіх клієнтів
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT ID, Full_name, Passport_series, Passport_number, Client_address
            FROM Client
        """)

        # Отримуємо результат у вигляді списку словників
        clients = [
            {
                "id": row[0],
                "full_name": row[1],
                "passport_series": row[2],
                "passport_number": row[3],
                "address": row[4]
            }
            for row in cursor.fetchall()
        ]

        cursor.close()
        return jsonify(clients), 200

    except Exception as e:
        print("Error fetching clients:", e)
        return jsonify({"error": "Не вдалося завантажити дані про клієнтів"}), 500


# Захищений маршрут для додавання препарату
@app.route('/add-drug', methods=['POST'])
@jwt_required()
@role_required("Адміністратор системи")  # Перевірка ролі адміністратора
def add_drug():
    data = request.get_json()
    name = data.get('name')
    manufacturer_id = data.get('manufacturer_id')
    price = data.get('price')
    quantity = data.get('quantity')
    requires_prescription = data.get('requires_prescription')

    if not all([name, manufacturer_id, price is not None, quantity is not None, requires_prescription is not None]):
        return jsonify({"error": "Неповні дані"}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)

        # Додавання препарату в базу даних
        cursor.execute(
            '''
            INSERT INTO Drug (Name, Manufacturer_ID, Price, Total_amount, Requires_prescription)
            VALUES (%s, %s, %s, %s, %s)
            ''',
            (name, manufacturer_id, price, quantity, requires_prescription)
        )

        return jsonify({"message": "Препарат успішно додано"}), 201
    except psycopg2.IntegrityError:
        return jsonify({"error": "Назва препарату вже існує"}), 400
    finally:
        cursor.close()
        conn.close()


# Маршрут для редагування препарату
@app.route('/edit-drug/<int:drug_id>', methods=['PUT'])
@jwt_required()
@role_required("Адміністратор системи")
def edit_drug(drug_id):
    data = request.get_json()
    updates = {
        "Name": data.get('name'),
        "Manufacturer_ID": data.get('manufacturer_id'),
        "Price": data.get('price'),
        "Total_amount": data.get('quantity'),
        "Requires_prescription": data.get('requires_prescription')
    }

    # Видаляємо з `updates` елементи, які мають значення `None`
    updates = {key: value for key, value in updates.items() if value is not None}

    if not updates:
        return jsonify({"error": "Не вказано жодного параметра для оновлення"}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Створення SQL запиту для оновлення динамічно з параметрами
        set_clause = ", ".join([f"{key} = %s" for key in updates.keys()])
        sql = f"UPDATE Drug SET {set_clause} WHERE ID = %s"

        cursor.execute(sql, list(updates.values()) + [drug_id])

        # Перевіряємо, чи було видалено хоча б один рядок
        if cursor.rowcount == 0:
            return jsonify({"error": "Препарата з таким ID не існує"}), 404
        
        return jsonify({"message": "Препарат успішно оновлено"}), 200
    except psycopg2.Error as e:
        return jsonify({"error": "Помилка при оновленні препарату"}), 400
    finally:
        cursor.close()
        conn.close()


# Маршрут для видалення препарату
@app.route('/delete-drug/<int:drug_id>', methods=['DELETE'])
@jwt_required()
@role_required("Адміністратор системи")
def delete_drug(drug_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("DELETE FROM Drug WHERE ID = %s", (drug_id,))

        # Перевіряємо, чи було видалено хоча б один рядок
        if cursor.rowcount == 0:
            return jsonify({"error": "Препарата з таким ID не існує"}), 404

        cursor.execute("SELECT setval('Drug_ID_seq', (SELECT MAX(ID) FROM Drug))")

        if cursor.rowcount == 0:
            return jsonify({"error": "Препарат не знайдено"}), 404

        return jsonify({"message": "Препарат успішно видалено"}), 200
    except psycopg2.Error:
        return jsonify({"error": "Помилка при видаленні препарату"}), 400
    finally:
        cursor.close()
        conn.close()

# Маршрут для перегляду історії замовлень
@app.route("/client-orders/<int:client_id>", methods=["GET"])
@jwt_required()
def get_client_orders(client_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Перевіряємо, чи існує клієнт з таким ID
        cursor.execute("SELECT * FROM Client WHERE ID = %s", (client_id,))
        client = cursor.fetchone()
        if not client:
            return jsonify({"error": "Клієнта з таким ID не існує"}), 404

        # Отримуємо історію замовлень для клієнта
        cursor.execute("""
            SELECT o.ID as order_id, o.Order_date as date, o.Total_cost as total_cost,
                   d.Name as drug_name, od.Quantity as quantity, od.Total_price as total_price
            FROM "Order" o
            LEFT JOIN Order_Drug od ON o.ID = od.Order_ID
            LEFT JOIN Drug d ON od.Drug_ID = d.ID
            WHERE o.Client_ID = %s
            ORDER BY o.Order_date DESC
        """, (client_id,))

        orders = cursor.fetchall()

        # Форматуємо дані для відправлення в JSON
        order_history = []
        for order in orders:
            order_history.append({
                "order_id": order[0],
                "date": order[1].strftime("%Y-%m-%d"),
                "total_cost": order[2],
                "drug_name": order[3],
                "quantity": order[4],
                "total_price": order[5]
            })

        cursor.close()
        conn.close()
        return jsonify(order_history), 200
    except Exception as e:
        print("Error retrieving client orders:", e)
        return jsonify({"error": "Не вдалося отримати історію замовлень"}), 500

@app.route("/sell-drug", methods=["POST"])
@jwt_required()
def sell_drug():
    try:
        data = request.get_json()
        client_id = data.get("client_id")
        drug_id = data.get("drug_id")
        quantity = data.get("quantity")
        prescription_id = data.get("prescription_id") or None

        if not client_id or not drug_id or not quantity:
            return jsonify({"error": "Відсутні необхідні дані"}), 400

        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)

        # 1. Перевірка наявності препарату
        cursor.execute("""
            SELECT ID, Name, Price, Total_amount, Requires_prescription 
            FROM Drug 
            WHERE ID = %s
        """, (drug_id,))
        drug = cursor.fetchone()

        print("Дані про препарат:", drug)

        if not drug:
            return jsonify({"error": "Препарат не знайдено"}), 404

        if drug["total_amount"] < quantity:
            return jsonify({"error": "Недостатньо препарату на складі"}), 400

        # 2. Перевірка на рецепт, якщо він потрібен
        if drug["requires_prescription"]:
            if not prescription_id:
                return jsonify({"error": "Для цього препарату потрібен рецепт"}), 400

            # Перевірка, чи існує рецепт для зазначеного клієнта та препарату
            cursor.execute("""
                    SELECT ID 
                    FROM Prescription 
                    WHERE ID = %s AND Client_ID = %s AND Drug_ID = %s AND Expiry_date >= CURRENT_DATE
                """, (prescription_id, client_id, drug_id))
            valid_prescription = cursor.fetchone()

            if not valid_prescription:
                return jsonify({"error": "Неприпустимий рецепт для цього клієнта або препарату"}), 400

        # 3. Створення замовлення
        cursor.execute("""
            INSERT INTO "Order" (Order_date, Total_cost, Client_ID, Prescription_ID) 
            VALUES (CURRENT_DATE, 0, %s, %s) 
            RETURNING ID
        """, (client_id, prescription_id))
        order = cursor.fetchone()

        if not order:
            return jsonify({"error": "Не вдалося створити замовлення"}), 500

        order_id = order["id"]

        # 4. Додавання препарату до замовлення
        total_price = round(drug["price"] * quantity, 2)
        cursor.execute("""
            INSERT INTO Order_Drug (Order_ID, Drug_ID, Quantity, Total_price)
            VALUES (%s, %s, %s, %s)
        """, (order_id, drug_id, quantity, total_price))

        # 6. Оновлення загальної вартості замовлення
        cursor.execute("""
            UPDATE "Order" 
            SET Total_cost = %s 
            WHERE ID = %s
        """, (total_price, order_id))

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({"message": "Продаж завершено", "order_id": order_id}), 200

    except Exception as e:
        print("Error processing sale:", e)
        return jsonify({"error": "Не вдалося завершити продаж"}), 500


# Запуск сервера
if __name__ == '__main__':
    app.run(debug=True)
