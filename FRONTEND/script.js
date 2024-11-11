// Функція для входу
async function login() {
  const username = document.getElementById("username").value;
  const password = document.getElementById("password").value;
  const roleElement = document.getElementById("role");
  const role = roleElement.options[roleElement.selectedIndex].text;

  if (!username || !password || !role) {
    alert("Всі поля повинні бути заповнені!");
    return;
  }

  try {
    const response = await fetch("http://127.0.0.1:5000/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, password }),
    });

    const data = await response.json();

    if (response.ok) {
      // Зберігаємо токен у локальному сховищі браузера
      localStorage.setItem("access_token", data.access_token);

      // Перевіряємо роль користувача та перенаправляємо на відповідну сторінку
      if (data.role === "Адміністратор системи") {
        window.location.href = "admin.html";
      } else if (data.role === "Фармацевт") {
        window.location.href = "pharmacist.html";
      } else if (data.role === "Менеджер з продажу") {
        window.location.href = "sales_manager.html";
      } else {
        alert("Невідома роль користувача!");
      }
    } else {
      alert(data.error || "Авторизація не вдалася");
    }
  } catch (error) {
    console.error("Error during login:", error);
    alert("Помилка з'єднання із сервером");
  }
}

// Функція для доступу до захищених маршрутів
async function accessProtectedRoute(route) {
  const token = localStorage.getItem("access_token");

  if (!token) {
    alert("Спочатку необхідно увійти в систему!");
    return;
  }

  try {
    const response = await fetch(route, {
      method: "GET",
      headers: { Authorization: `Bearer ${token}` },
    });

    const data = await response.json();

    if (response.ok) {
      alert(data.message);
    } else {
      alert(data.error || "Доступ заборонено");
    }
  } catch (error) {
    console.error("Error:", error);
    alert("Помилка з'єднання із сервером");
  }
}

// Прив'язка до кнопки входу
document.getElementById("login-button").addEventListener("click", login);
