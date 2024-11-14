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