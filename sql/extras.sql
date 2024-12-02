-- Active: 1731167437977@@127.0.0.1@5432@pharmacy
-- Спочатку видаляємо тригер та функцію, якщо вони існують
DROP TRIGGER IF EXISTS check_and_update_drug_stock_trigger ON Order_Drug;

DROP FUNCTION IF EXISTS check_and_update_drug_stock ();

-- Створення функції для перевірки умов і оновлення запасу препарату

CREATE OR REPLACE FUNCTION check_and_update_drug_stock()
RETURNS TRIGGER AS $$
DECLARE
    drug_info RECORD;
    order_info RECORD;
BEGIN
    -- Отримуємо інформацію про препарат
    SELECT ID, Name, Total_amount, Requires_prescription
    INTO drug_info
    FROM Drug
    WHERE ID = NEW.Drug_ID;

    -- Перевірка наявності препарату на складі
    IF drug_info.Total_amount < NEW.Quantity THEN
        RAISE EXCEPTION 'Недостатньо препарату на складі';
    END IF;

    -- Отримуємо інформацію про замовлення для перевірки рецепта
    SELECT Prescription_ID INTO order_info
    FROM "Order"
    WHERE ID = NEW.Order_ID;

    -- Перевірка на рецепт, якщо він потрібен
    IF drug_info.Requires_prescription AND order_info.Prescription_ID IS NULL THEN
        RAISE EXCEPTION 'Для цього препарату потрібен рецепт';
    END IF;

    -- Оновлюємо кількість препарату на складі
    UPDATE Drug
    SET Total_amount = Total_amount - NEW.Quantity
    WHERE ID = NEW.Drug_ID;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Створення тригера, який викликає функцію перед вставкою запису у Order_Drug
CREATE TRIGGER check_and_update_drug_stock_trigger BEFORE
INSERT
    ON Order_Drug FOR EACH ROW
EXECUTE FUNCTION check_and_update_drug_stock ();

-- ------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trigger_apply_discount ON Order_Drug;

DROP FUNCTION IF EXISTS apply_discount ();



CREATE OR REPLACE FUNCTION apply_discount()
RETURNS TRIGGER AS $$
DECLARE
    full_passport_number TEXT;      
    order_date_day TEXT;            
    discount_percent DECIMAL(5, 2); 
    original_cost DECIMAL(10, 2);   
    final_cost DECIMAL(10, 2);      
    quantity_discount DECIMAL(5, 2); 
    total_quantity INT;             
    applied_discount_id INT;        
BEGIN

    SELECT Client.Passport_series || Client.Passport_number
    INTO full_passport_number
    FROM Client
    WHERE Client.ID = NEW.Client_ID;

    order_date_day := TO_CHAR(NEW.Order_date, 'DD');

    original_cost := NEW.Total_cost;

    discount_percent := 0;
    quantity_discount := 0;
    applied_discount_id := NULL;

    -- Знижка за "щасливе число"
    IF position(order_date_day IN full_passport_number) > 0 THEN
        SELECT Discount.ID, Discount.Discount_percent
        INTO applied_discount_id, discount_percent
        FROM Discount
        WHERE Discount.Discount_name = 'Щасливе число';
    END IF;

    -- Розрахунок загальної кількості товарів у замовленні
    SELECT SUM(Order_Drug.Quantity)
    INTO total_quantity
    FROM Order_Drug
    WHERE Order_Drug.Order_ID = NEW.ID;

    -- Знижка більше 15
    IF total_quantity > 15 THEN
        SELECT Discount.ID, Discount.Discount_percent
        INTO applied_discount_id, quantity_discount
        FROM Discount
        WHERE Discount.Discount_name = 'На великі замовлення';

        IF quantity_discount > discount_percent THEN
            discount_percent := quantity_discount;
        END IF;
    END IF;

    -- Обчислення вартості зі знижкою
    IF discount_percent > 0 THEN
        final_cost := original_cost - (original_cost * discount_percent / 100);

    ELSE
        -- Якщо знижки не застосовуються
        final_cost := original_cost;
    END IF;

    NEW.Total_cost := final_cost;
    NEW.Discount_ID := applied_discount_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE
OR REPLACE TRIGGER apply_discount_trigger BEFORE INSERT
OR
UPDATE ON "Order" FOR EACH ROW
EXECUTE FUNCTION apply_discount ();

SELECT * FROM discount