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
