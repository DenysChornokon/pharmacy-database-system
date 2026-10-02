-- Active: 1731167437977@@127.0.0.1@5432@pharmacy

-- Створення таблиці клієнтів
CREATE TABLE Client (
    ID SERIAL PRIMARY KEY,
    Full_name VARCHAR(255) NOT NULL,
    Passport_series VARCHAR(10) NOT NULL,
    Passport_number VARCHAR(10) NOT NULL,
    Client_address VARCHAR(255),
    UNIQUE (
        Passport_series,
        Passport_number
    ) -- Унікальна комбінація серії та номеру паспорта
);

-- Створення таблиці виробників
CREATE TABLE Manufacturer (
    ID SERIAL PRIMARY KEY,
    Company_name VARCHAR(255) NOT NULL UNIQUE,
    Company_address VARCHAR(255),
    Phone VARCHAR(20),
    Email VARCHAR(255)
);

-- Створення таблиці препаратів
CREATE TABLE Drug (
    ID SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL UNIQUE, -- Назва препарату має бути унікальною
    Price DECIMAL(10, 2) CHECK (Price >= 0), -- Перевірка, щоб вартість не була від'ємною
    Total_amount INT CHECK (Total_amount >= 0), -- Перевірка, щоб кількість не була від'ємною
    Requires_prescription BOOLEAN NOT NULL, -- Вказує, чи потрібний рецепт
    Manufacturer_ID INT REFERENCES Manufacturer (ID) -- Зовнішній ключ на виробника
);

-- Створення таблиці партій препаратів
CREATE TABLE Drug_Batch (
    ID SERIAL PRIMARY KEY,
    Drug_ID INT REFERENCES Drug (ID) ON DELETE CASCADE, -- Зовнішній ключ на препарат
    Manufacture_date DATE NOT NULL,
    Expiry_date DATE NOT NULL CHECK (
        Expiry_date > Manufacture_date
    ) -- Перевірка терміну дії
);

-- Створення таблиці рецептів
CREATE TABLE Prescription (
    ID SERIAL PRIMARY KEY,
    Issue_date DATE NOT NULL CHECK (Issue_date <= CURRENT_DATE), -- Дата не повинна бути в майбутньому
    Expiry_date DATE NOT NULL CHECK (Expiry_date >= Issue_date), -- Перевірка терміну дії
    Client_ID INT REFERENCES Client (ID) ON DELETE SET NULL, -- Зовнішній ключ на клієнта
    Drug_ID INT REFERENCES Drug (ID) ON DELETE SET NULL -- Зовнішній ключ на препарат
);

-- Створення таблиці знижок
CREATE TABLE Discount (
    ID SERIAL PRIMARY KEY,
    Discount_name VARCHAR(255) NOT NULL,
    Discount_percent DECIMAL(5, 2) CHECK (
        Discount_percent >= 0
        AND Discount_percent <= 100
    ) -- Відсоток знижки не від'ємний і не більше 100
);

-- Створення таблиці замовлень
CREATE TABLE "Order" (
    ID SERIAL PRIMARY KEY,
    Order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    Total_cost DECIMAL(10, 2),
    Client_ID INT REFERENCES Client (ID) ON DELETE SET NULL, -- Зовнішній ключ на клієнта
    Discount_ID INT REFERENCES Discount (ID) ON DELETE SET NULL, -- Зовнішній ключ на знижку
    Prescription_ID INT REFERENCES Prescription (ID) ON DELETE SET NULL -- Зовнішній ключ на рецепт
);

-- Створення таблиці зв'язку замовлення-препарат
CREATE TABLE Order_Drug (
    ID SERIAL PRIMARY KEY,
    Order_ID INT REFERENCES "Order" (ID) ON DELETE CASCADE, -- Зовнішній ключ на замовлення
    Drug_ID INT REFERENCES Drug (ID) ON DELETE CASCADE, -- Зовнішній ключ на препарат
    Quantity INT NOT NULL CHECK (Quantity > 0), -- Кількість повинна бути додатною
    Total_price DECIMAL(10, 2) -- Розраховується на основі кількості та ціни препарату
);

-- ------------------------------------------------------------------------------------------------------------

-- Заповнення таблиць даними

-- TRUNCATE TABLE Order_Drug,
-- "Order",
-- Prescription,
-- Client,
-- Drug_Batch,
-- Drug,
-- Manufacturer,
-- Discount RESTART IDENTITY CASCADE;

INSERT INTO
    Client (
        Full_name,
        Passport_series,
        Passport_number,
        Client_address
    )
VALUES (
        'Ivan Petrov',
        'AA',
        '123456',
        'Kyiv, Shevchenko str, 10'
    ),
    (
        'Olha Ivanova',
        'BB',
        '654321',
        'Lviv, Hrushevskogo str, 22'
    ),
    (
        'Pavlo Sydorenko',
        'CC',
        '789012',
        'Odesa, Primorsky Blvd, 5'
    ),
    (
        'Oksana Semenova',
        'DD',
        '345678',
        'Kharkiv, Sumskaya str, 7'
    ),
    (
        'Dmytro Shevchenko',
        'EE',
        '234567',
        'Dnipro, Gagarina Ave, 13'
    ),
    (
        'Anna Kovalenko',
        'FF',
        '112233',
        'Zaporizhzhia, Sobornyi Ave, 21'
    ),
    (
        'Serhiy Melnyk',
        'GG',
        '998877',
        'Vinnytsia, Khmelnitske Hwy, 14'
    ),
    (
        'Natalia Tkachenko',
        'HH',
        '556677',
        'Chernihiv, Popudrenka str, 9'
    ),
    (
        'Andriy Vorobyov',
        'II',
        '443322',
        'Poltava, Polovka str, 15'
    ),
    (
        'Larysa Zhuk',
        'JJ',
        '221100',
        'Ivano-Frankivsk, Nezalezhnosti str, 8'
    ),
    (
        'Viktor Ryabov',
        'KK',
        '334455',
        'Cherkasy, Smilyanska str, 10'
    ),
    (
        'Kateryna Kravchenko',
        'LL',
        '667788',
        'Khmelnytskyi, Bandera str, 12'
    ),
    (
        'Mykola Honchar',
        'MM',
        '990011',
        'Chernivtsi, Holovna str, 16'
    ),
    (
        'Tetiana Ponomarenko',
        'NN',
        '778899',
        'Rivne, Soborna str, 18'
    ),
    (
        'Yurii Bondarenko',
        'OO',
        '445566',
        'Sumy, Kharkivska str, 11'
    ),
    (
        'Inna Matsko',
        'PP',
        '223344',
        'Zhytomyr, Berdychivska str, 2'
    ),
    (
        'Oleh Vasyliev',
        'QQ',
        '556688',
        'Uzhhorod, Zankovetska str, 3'
    ),
    (
        'Vira Pavlova',
        'RR',
        '998822',
        'Ternopil, Chornovola str, 7'
    ),
    (
        'Diana Samoilova',
        'SS',
        '554433',
        'Kropyvnytskyi, Vokzalna str, 4'
    ),
    (
        'Artem Kharchenko',
        'TT',
        '889900',
        'Lutsk, Kovel str, 13'
    );

INSERT INTO
    Manufacturer (
        Company_name,
        Company_address,
        Phone,
        Email
    )
VALUES (
        'PharmaPlus',
        'Kyiv, Kyivska str, 17',
        '+380441234567',
        'info@pharmaplus.ua'
    ),
    (
        'MedTech',
        'Lviv, Science Park, Bld. 4',
        '+380322223344',
        'contact@medtech.com'
    ),
    (
        'BioPharm',
        'Odesa, Levitsky str, 22',
        '+380482334455',
        'sales@biopharm.com.ua'
    ),
    (
        'HealthCorp',
        'Dnipro, Pobedy str, 11',
        '+380561112233',
        'support@healthcorp.ua'
    ),
    (
        'EcoMedic',
        'Kharkiv, Lenina str, 7',
        '+380577887766',
        'office@ecomedic.com'
    ),
    (
        'LifeScience',
        'Zaporizhzhia, Khortytsia str, 2',
        '+380612223344',
        'lifescience@ls.ua'
    ),
    (
        'NaturoCare',
        'Vinnytsia, Zelena str, 9',
        '+380432445566',
        'help@naturocare.ua'
    ),
    (
        'NeoPharma',
        'Poltava, Industrial Park',
        '+380532778899',
        'info@neopharma.ua'
    ),
    (
        'MedikaGroup',
        'Chernihiv, Hospital str, 14',
        '+380462335577',
        'support@medikagroup.ua'
    ),
    (
        'SafePharm',
        'Ivano-Frankivsk, Central str, 10',
        '+380342556677',
        'sales@safepharm.com'
    );

INSERT INTO
    Drug (
        Name,
        Price,
        Total_amount,
        Requires_prescription,
        Manufacturer_ID
    )
VALUES (
        'Paracetamol',
        45.00,
        100,
        FALSE,
        1
    ),
    (
        'Ibuprofen',
        60.50,
        150,
        FALSE,
        2
    ),
    (
        'Amoxicillin',
        120.00,
        200,
        TRUE,
        3
    ),
    (
        'Loratadine',
        85.75,
        300,
        FALSE,
        4
    ),
    (
        'Omeprazole',
        70.25,
        250,
        TRUE,
        5
    ),
    (
        'Aspirin',
        35.00,
        500,
        FALSE,
        6
    ),
    (
        'Metformin',
        110.80,
        350,
        TRUE,
        7
    ),
    (
        'Ciprofloxacin',
        150.50,
        120,
        TRUE,
        8
    ),
    (
        'Azithromycin',
        160.75,
        90,
        TRUE,
        9
    ),
    (
        'Cetirizine',
        45.60,
        180,
        FALSE,
        10
    );

INSERT INTO
    Drug_Batch (
        Drug_ID,
        Manufacture_date,
        Expiry_date
    )
VALUES (1, '2023-01-15', '2025-01-15'),
    (2, '2023-03-10', '2025-03-10'),
    (3, '2022-11-01', '2024-11-01'),
    (4, '2023-05-20', '2025-05-20'),
    (5, '2022-09-25', '2024-09-25'),
    (6, '2023-02-14', '2025-02-14'),
    (7, '2022-08-30', '2024-08-30'),
    (8, '2023-07-01', '2025-07-01'),
    (9, '2022-10-15', '2024-10-15'),
    (
        10,
        '2023-06-25',
        '2025-06-25'
    );

INSERT INTO
    Prescription (
        Issue_date,
        Expiry_date,
        Client_ID,
        Drug_ID
    )
VALUES (
        '2023-04-01',
        '2023-10-01',
        1,
        3
    ),
    (
        '2023-05-05',
        '2023-11-05',
        2,
        5
    ),
    (
        '2023-06-15',
        '2023-12-15',
        3,
        7
    ),
    (
        '2023-07-10',
        '2024-01-10',
        4,
        8
    ),
    (
        '2023-08-20',
        '2024-02-20',
        5,
        9
    ),
    (
        '2023-09-25',
        '2024-03-25',
        6,
        3
    ),
    (
        '2023-10-30',
        '2024-04-30',
        7,
        5
    ),
    (
        '2023-11-15',
        '2024-05-15',
        8,
        7
    ),
    (
        '2023-12-05',
        '2024-06-05',
        9,
        8
    ),
    (
        '2024-01-20',
        '2024-07-20',
        10,
        9
    );

INSERT INTO
    Discount (
        Discount_name,
        Discount_percent
    )
VALUES ('Щасливе число', 10.00),
    ('На великі замовлення', 15.00);

INSERT INTO
    "Order" (
        Order_date,
        Total_cost,
        Client_ID,
        Discount_ID,
        Prescription_ID
    )
VALUES ('2023-06-15', 250.00, 1, 1, 1),
    ('2023-07-20', 300.50, 2, 2, 2),
    (
        '2023-08-10',
        175.75,
        3,
        3,
        NULL
    ), -- Discount_ID = 3 тепер доступний
    (
        '2023-09-05',
        220.00,
        4,
        NULL,
        4
    ), -- Без знижки
    ('2023-10-01', 480.25, 5, 1, 5), -- Застосовується знижка з ID = 1
    (
        '2023-10-25',
        150.00,
        6,
        2,
        NULL
    ), -- Знижка з ID = 2
    (
        '2023-11-10',
        295.80,
        7,
        NULL,
        6
    ), -- Без знижки
    ('2023-11-30', 365.00, 8, 1, 7), -- Знижка з ID = 1
    ('2023-12-15', 410.00, 9, 3, 8), -- Знижка з ID = 3
    (
        '2024-01-10',
        530.75,
        10,
        NULL,
        9
    );

INSERT INTO
    Order_Drug (
        Order_ID,
        Drug_ID,
        Quantity,
        Total_price
    )
VALUES (1, 1, 2, 90.00), -- Order_ID = 1
    (1, 3, 1, 120.00), -- Order_ID = 1
    (2, 2, 3, 181.50), -- Order_ID = 2
    (2, 5, 1, 70.25), -- Order_ID = 2
    (3, 4, 2, 171.50), -- Order_ID = 3
    (4, 6, 5, 175.00), -- Order_ID = 4
    (5, 7, 3, 332.40), -- Order_ID = 5
    (5, 9, 2, 321.50), -- Order_ID = 5
    (6, 8, 1, 150.50), -- Order_ID = 6
    (7, 10, 2, 91.20), -- Order_ID = 7
    (8, 2, 4, 242.00), -- Order_ID = 8
    (9, 3, 1, 120.00), -- Order_ID = 9
    (10, 5, 2, 140.50); -- Order_ID = 10


-- Додаткові дані

INSERT INTO
    "Order" (
        Order_date,
        Total_cost,
        Client_ID,
        Discount_ID,
        Prescription_ID
    )
VALUES (
        '2024-11-01',
        200.00,
        1,
        NULL,
        1
    ),
    (
        '2024-10-02',
        150.00,
        2,
        NULL,
        2
    ),
    (
        '2024-8-03',
        300.00,
        3,
        1,
        NULL
    ),
    ('2024-11-04', 250.00, 1, 2, 3),
    (
        '2024-11-05',
        400.00,
        4,
        NULL,
        NULL
    );

INSERT INTO
    Order_Drug (
        Order_ID,
        Drug_ID,
        Quantity,
        Total_price
    )
VALUES (1, 1, 5, 50.00), 
    (2, 2, 3, 75.00), 
    (3, 3, 2, 60.00), 
    (4, 4, 1, 65.00), 
    (5, 5, 4, 80.00);


INSERT INTO
    Drug (
        Name,
        Price,
        Total_amount,
        Requires_prescription,
        Manufacturer_ID
    )
VALUES 
    (
        'Antibiotic A',
        25.00,
        200,
        true,
        2
    ),
    (
        'Drug B',
        30.00,
        100,
        true,
        2
    ),
    (
        'Vitamins C',
        20.00,
        400,
        false,
        1
    );


    INSERT INTO
    Prescription (
        Issue_date,
        Expiry_date,
        Client_ID,
        Drug_ID
    )
VALUES (
        '2023-04-01',
        '2025-10-01',
        1,
        3
    ),
    (
        '2023-05-05',
        '2025-11-05',
        2,
        5
    ),
    (
        '2023-06-15',
        '2025-12-15',
        3,
        7
    )



    INSERT INTO
    Client (
        Full_name,
        Passport_series,
        Passport_number,
        Client_address
    )
VALUES (
        'Natasha Znyjka',
        'AA',
        '250971',
        'Kyiv, Shevchenko str, 10'
    )

SELECT * from "Order"


-- 1. Індекс для таблиці Drug по колонці Name
CREATE INDEX idx_drug_name ON Drug (Name);

-- 2. Індекс для таблиці Order по колонці Client_ID
CREATE INDEX idx_order_client_id ON "Order" (Client_ID);

-- 3. Комбінований індекс для таблиці Order по колонках Order_Date та Total_cost
CREATE INDEX idx_order_date_cost ON "Order" (Order_Date, Total_cost);

SELECT
    SEGMENT_NAME AS Index_Name,
    BYTES / 1024 AS Size_KB
FROM USER_SEGMENTS
WHERE
    SEGMENT_NAME = 'IDX_DRUG_NAME';

