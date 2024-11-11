-- Active: 1731167437977@@127.0.0.1@5432@pharmacy

CREATE TABLE Roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL, -- для зберігання захешованого паролю
    role_id INT REFERENCES Roles (role_id) -- зв’язок з таблицею ролей
);

-- Додавання ролей у таблицю Roles
INSERT INTO
    Roles (role_name)
VALUES ('Адміністратор системи'),
    ('Фармацевт'),
    ('Менеджер з продажу');

select * from Users