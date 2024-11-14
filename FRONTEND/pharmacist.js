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

    const drugList = document.querySelector(".drug-list");
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

// Функція для перегляду всіх клієнтів
async function viewClients() {
  const token = localStorage.getItem("access_token");

  try {
    const response = await fetch("http://127.0.0.1:5000/view-clients", {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    // Перевіряємо, чи успішна відповідь
    if (!response.ok) {
      throw new Error(`Помилка: ${response.status} ${response.statusText}`);
    }

    const clients = await response.json();

    // Перевірка на те, що `clients` є масивом
    if (!Array.isArray(clients)) {
      throw new Error("Невірний формат даних: очікується масив");
    }

    const clientList = document.querySelector(".drug-list");
    clientList.innerHTML = ""; // Очищаємо список перед додаванням нових клієнтів

    clients.forEach((client) => {
      const clientItem = document.createElement("div");
      clientItem.className = "drug-item";
      clientItem.innerHTML = `
        <h3>${client.id}. ${client.full_name}</h3>
        <p><strong>Серія паспорта:</strong> ${client.passport_series}</p>
        <p><strong>Номер паспорта:</strong> ${client.passport_number}</p>
        <p><strong>Адреса:</strong> ${client.address}</p>
      `;
      clientList.appendChild(clientItem);
    });
  } catch (error) {
    console.error("Error:", error);
    alert("Помилка при завантаженні списку клієнтів: " + error.message);
  }
}

// Функція для відображення списку клієнтів
async function viewClients() {
  const token = localStorage.getItem("access_token");

  try {
    const response = await fetch("http://127.0.0.1:5000/view-clients", {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (!response.ok) {
      throw new Error(`Помилка: ${response.status} ${response.statusText}`);
    }

    const clients = await response.json();

    if (!Array.isArray(clients)) {
      throw new Error("Невірний формат даних: очікується масив");
    }

    const listContainer = document.getElementById("list-container");
    listContainer.innerHTML = ""; // Очищення контейнера

    clients.forEach((client) => {
      const clientItem = document.createElement("div");
      clientItem.className = "client-item drug-item";
      clientItem.innerHTML = `
        <h3>${client.id}. ${client.full_name}</h3>
        <p><strong>Серія паспорта:</strong> ${client.passport_series}</p>
        <p><strong>Номер паспорта:</strong> ${client.passport_number}</p>
        <p><strong>Адреса:</strong> ${client.address}</p>
      `;
      listContainer.appendChild(clientItem);
    });
  } catch (error) {
    console.error("Error fetching clients:", error);
    alert("Помилка при завантаженні списку клієнтів: " + error.message);
  }
}

// Функція для відображення списку препаратів
async function viewDrugs() {
  const token = localStorage.getItem("access_token");

  try {
    const response = await fetch("http://127.0.0.1:5000/view-drugs", {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (!response.ok) {
      throw new Error(`Помилка: ${response.status} ${response.statusText}`);
    }

    const drugs = await response.json();

    if (!Array.isArray(drugs)) {
      throw new Error("Невірний формат даних: очікується масив");
    }

    const listContainer = document.getElementById("list-container");
    listContainer.innerHTML = ""; // Очищення контейнера

    drugs.forEach((drug) => {
      const drugItem = document.createElement("div");
      drugItem.className = "drug-item";
      drugItem.innerHTML = `
        <h3>${drug.id}. ${drug.name}</h3>
        <p><strong>Ціна:</strong> ${drug.price} грн</p>
        <p><strong>Кількість:</strong> ${drug.quantity}</p>
        <p><strong>Виробник:</strong> ${drug.manufacturer_id}</p>
        <p><strong>Потребує рецепт:</strong> ${
          drug.requires_prescription ? "Так" : "Ні"
        }</p>
      `;
      listContainer.appendChild(drugItem);
    });
  } catch (error) {
    console.error("Error fetching drugs:", error);
    alert("Помилка при завантаженні списку препаратів: " + error.message);
  }
}

// Функція для продажу препарату (базова реалізація)
async function sellDrug() {
  const clientId = document.getElementById("client-id").value;
  const drugId = document.getElementById("drug-id").value;
  const quantity = document.getElementById("quantity").value;
  const prescriptionId = document.getElementById("prescription-id").value || null;
  const token = localStorage.getItem("access_token");

  try {
    const response = await fetch("http://127.0.0.1:5000/sell-drug", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        client_id: parseInt(clientId),
        drug_id: parseInt(drugId),
        quantity: parseInt(quantity),
        prescription_id: prescriptionId ? parseInt(prescriptionId) : null,
      }),
    });

    const result = await response.json();

    const orderSummary = document.getElementById("order-summary-text");
    if (response.ok) {
      orderSummary.textContent = `Замовлення #${result.order_id} успішно завершено`;
      // Очищення форми після успішного продажу
      document.getElementById("sell-drug-form").reset();
      // Оновлення списку препаратів, щоб відобразити нову кількість
      viewDrugs();
    } else {
      orderSummary.textContent = `Помилка: ${result.error}`;
    }
  } catch (error) {
    console.error("Помилка продажу:", error);
    alert("Помилка при продажу препарату: " + error.message);
  }
}

// Прив'язка події на форму продажу
document.getElementById("sell-drug-form").addEventListener("submit", (e) => {
  e.preventDefault();
  sellDrug();
});
