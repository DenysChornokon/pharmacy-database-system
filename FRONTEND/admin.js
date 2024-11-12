// Функція для відображення форми додавання препарату
function showAddDrugForm() {
  const contentArea = document.getElementById("content-area");
  contentArea.innerHTML = `
    <h2 class="form-title">Додати препарат</h2>
    <form id="add-drug-form" class="drug-form">
      <label for="drug-name">Назва препарату:</label>
      <input type="text" id="drug-name" class="form-input" name="drug-name" required>

      <label for="manufacturer-id">ID Виробника:</label>
      <input type="number" id="manufacturer-id" class="form-input" name="manufacturer-id" required>

      <label for="price">Ціна:</label>
      <input type="number" id="price" class="form-input" name="price" step="0.01" required>

      <label for="quantity">Кількість:</label>
      <input type="number" id="quantity" class="form-input" name="quantity" required>

      <label for="requires-prescription">Потребує рецепт:</label>
      <select id="requires-prescription" class="form-input" name="requires-prescription" required>
        <option value="true">Так</option>
        <option value="false">Ні</option>
      </select>

      <button type="button" class="submit-button" onclick="addDrug()">Додати</button>
      <p class="responseMessage"></p>
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

  const token = localStorage.getItem("access_token");

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
    document.querySelector(".responseMessage").textContent = response.ok
      ? result.message
      : result.error;
    document.getElementById("add-drug-form").reset();
  } catch (error) {
    console.error("Error:", error);
    document.querySelector(".responseMessage").textContent =
      "Помилка при додаванні препарату.";
  }
}

// Функція для відображення форми редагування препарату
function showEditDrugForm() {
  const contentArea = document.getElementById("content-area");
  contentArea.innerHTML = `
    <h2 class="form-title">Редагувати препарат</h2>
    <form id="edit-drug-form" class="drug-form">
      <label for="drug-id">ID препарату:</label>
      <input type="number" id="drug-id" class="form-input" name="drug-id" required>

      <label for="drug-name">Нова назва препарату:</label>
      <input type="text" id="drug-name" class="form-input" name="drug-name">

      <label for="manufacturer-id">Новий ID Виробника:</label>
      <input type="number" id="manufacturer-id" class="form-input" name="manufacturer-id">

      <label for="price">Нова ціна:</label>
      <input type="number" id="price" class="form-input" name="price" step="0.01">

      <label for="quantity">Нова кількість:</label>
      <input type="number" id="quantity" class="form-input" name="quantity">

      <label for="requires-prescription">Потребує рецепт:</label>
      <select id="requires-prescription" class="form-input" name="requires-prescription">
        <option value="">Не змінювати</option>
        <option value="true">Так</option>
        <option value="false">Ні</option>
      </select>

      <button type="button" class="submit-button" onclick="editDrug()">Змінити</button>
    </form>
    <p class="responseMessage"></p>
  `;
}

// Функція для редагування препарату
async function editDrug() {
  const drugId = parseInt(document.getElementById("drug-id").value);
  const name = document.getElementById("drug-name").value || null;
  const manufacturer_id =
    parseInt(document.getElementById("manufacturer-id").value) || null;
  const price = parseFloat(document.getElementById("price").value) || null;
  const quantity = parseInt(document.getElementById("quantity").value) || null;
  const requires_prescription =
    document.getElementById("requires-prescription").value || null;

  const token = localStorage.getItem("access_token");

  try {
    const response = await fetch(`http://127.0.0.1:5000/edit-drug/${drugId}`, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        name,
        manufacturer_id,
        price,
        quantity,
        requires_prescription:
          requires_prescription === ""
            ? null
            : requires_prescription === "true",
      }),
    });

    const result = await response.json();
    document.querySelector(".responseMessage").textContent = response.ok
      ? result.message
      : result.error;
  } catch (error) {
    console.error("Error:", error);
    document.querySelector(".responseMessage").textContent =
      "Помилка при редагуванні препарату.";
  }
}

// Функція для відображення форми видалення препарату
function showDeleteDrugForm() {
  const contentArea = document.getElementById("content-area");
  contentArea.innerHTML = `
    <h2 class="form-title">Видалити препарат</h2>
    <form id="delete-drug-form" class="drug-form">
      <label for="drug-id">ID препарату:</label>
      <input type="number" id="drug-id" class="form-input" name="drug-id" required>
      <button type="button" class="submit-button" onclick="deleteDrug()">Видалити</button>
    </form>
    <p class="responseMessage"></p>
  `;
}

// Функція для видалення препарату
async function deleteDrug() {
  const drugId = parseInt(document.getElementById("drug-id").value);
  const token = localStorage.getItem("access_token");

  try {
    const response = await fetch(
      `http://127.0.0.1:5000/delete-drug/${drugId}`,
      {
        method: "DELETE",
        headers: {
          Authorization: `Bearer ${token}`,
        },
      }
    );

    const result = await response.json();
    document.querySelector(".responseMessage").textContent = response.ok
      ? result.message
      : result.error;
  } catch (error) {
    console.error("Error:", error);
    document.querySelector(".responseMessage").textContent =
      "Помилка при видаленні препарату.";
  }
}


// Розширена функція для перегляду всіх препаратів
async function viewDrugs() {
  const token = localStorage.getItem("access_token");

  try {
    const response = await fetch("http://127.0.0.1:5000/view-drugs", {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    // Перевіряємо, чи успішна відповідь
    if (!response.ok) {
      throw new Error(`Помилка: ${response.status} ${response.statusText}`);
    }

    const drugs = await response.json();

    // Перевірка на те, що `drugs` є масивом
    if (!Array.isArray(drugs)) {
      throw new Error("Невірний формат даних: очікується масив");
    }

    const drugList = document.getElementById("drug-list");
    drugList.innerHTML = ""; // Очищаємо список перед додаванням нових препаратів

    drugs.forEach((drug) => {
      const drugItem = document.createElement("div");
      drugItem.className = "drug-item";
      drugItem.innerHTML = `
        <h3>${drug.id}. ${drug.name}</h3>
        <p><strong>Ціна:</strong> ${drug.price} грн</p>
        <p><strong>Кількість:</strong> ${drug.quantity}</p>
        <p><strong>ID Виробника:</strong> ${drug.manufacturer_id}</p>
        <p><strong>Потребує рецепт:</strong> ${
          drug.requires_prescription ? "Так" : "Ні"
        }</p>
      `;
      drugList.appendChild(drugItem);
    });
  } catch (error) {
    console.error("Error:", error);
    alert("Помилка при завантаженні списку препаратів: " + error.message);
  }
}

