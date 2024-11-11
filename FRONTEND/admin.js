// Функція для відображення форми додавання препарату
function showAddDrugForm() {
  const contentArea = document.getElementById("content-area");
  contentArea.innerHTML = `
        <h2>Додати препарат</h2>
        <form id="add-drug-form">
            <label for="drug-name">Назва препарату:</label>
            <input type="text" id="drug-name" name="drug-name" required>

            <label for="manufacturer-id">ID Виробника:</label>
            <input type="number" id="manufacturer-id" name="manufacturer-id" required>

            <label for="price">Ціна:</label>
            <input type="number" id="price" name="price" step="0.01" required>

            <label for="quantity">Кількість:</label>
            <input type="number" id="quantity" name="quantity" required>

            <label for="requires-prescription">Потребує рецепт:</label>
            <select id="requires-prescription" name="requires-prescription" required>
                <option value="true">Так</option>
                <option value="false">Ні</option>
            </select>

            <button type="button" onclick="addDrug()">Додати</button>
        </form>
        <p id="responseMessage"></p>
    `;
}

// Функція для відправки даних про препарат на сервер
async function addDrug() {
  const name = document.getElementById("drug-name").value;
  const manufacturer_id = parseInt(
    document.getElementById("manufacturer-id").value
  );
  const price = parseFloat(document.getElementById("price").value);
  const quantity = parseInt(document.getElementById("quantity").value);
  const requires_prescription =
    document.getElementById("requires-prescription").value === "true";

  // Отримуємо токен з localStorage
  const token = localStorage.getItem("access_token");

  if (!token) {
    console.error("Токен не знайдено. Будь ласка, авторизуйтесь заново.");
    document.getElementById("responseMessage").textContent =
      "Токен не знайдено. Авторизуйтесь заново.";
    return;
  }

  try {
    const response = await fetch("http://127.0.0.1:5000/add-drug", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        name,
        manufacturer_id,
        price,
        quantity,
        requires_prescription,
      }),
    });

    const result = await response.json();

    if (response.ok) {
      document.getElementById("responseMessage").textContent = result.message;
      document.getElementById("add-drug-form").reset();
    } else {
      document.getElementById("responseMessage").textContent = result.error;
    }
  } catch (error) {
    console.error("Error:", error);
    document.getElementById("responseMessage").textContent =
      "Помилка при додаванні препарату.";
  }
}

// Інші функції для редагування даних, управління знижками, даних про клієнтів
function showEditDataForm() {
  const contentArea = document.getElementById("content-area");
  contentArea.innerHTML =
    "<h2>Редагувати дані</h2><p>Тут буде форма для редагування даних...</p>";
}

function showManageDiscounts() {
  const contentArea = document.getElementById("content-area");
  contentArea.innerHTML =
    "<h2>Управління знижками</h2><p>Тут буде форма для управління знижками...</p>";
}

function showClientData() {
  const contentArea = document.getElementById("content-area");
  contentArea.innerHTML =
    "<h2>Дані про клієнтів</h2><p>Тут буде інформація про клієнтів...</p>";
}
