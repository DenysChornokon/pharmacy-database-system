# Pharmacy Drug Sales Management System

## Overview
The Pharmacy Drug Sales Management System is a web-based application designed to automate and optimize the daily operations of a pharmacy. It provides robust tools for tracking drug inventory, managing customer orders, verifying prescription requirements, and automatically calculating purchase totals with conditional discounts. 

This project was developed as a course project detailed in the accompanying **Курсова.docx** file.

## Features

### Role-Based Access Control (RBAC)
The system uses JWT (JSON Web Tokens) for secure authentication and authorization, dividing users into two main roles:
*   **Administrator:** Has full access to manage the system. Can add, edit, and delete drug records, and view comprehensive order histories for specific clients.
*   **Pharmacist:** Handles the point-of-sale operations. Can view lists of clients and drugs, process customer orders, verify prescriptions, and finalize sales.

### Core Functionalities
*   **Inventory Management:** Automatically deducts sold quantities from the central database to prevent overselling.
*   **Prescription Verification:** Enforces prescription checks for restricted drugs. Validates that the prescription is assigned to the correct client, matches the requested drug, and is not expired.
*   **Automated Discounts:** Database triggers automatically calculate and apply discounts based on predefined business rules:
    *   *Lucky Number (10%):* Applied if the day of the order date matches a number in the client's passport.
    *   *Bulk Order (15%):* Applied if the order contains more than 15 items.
    *   *(If both conditions are met, the system applies the highest discount).*

## Technologies Used
*   **Database:** PostgreSQL (Relational database with complex triggers, foreign keys, and stored procedures)
*   **Backend:** Python with Flask framework (RESTful API architecture)
*   **Frontend:** Vanilla HTML, CSS, and JavaScript
*   **Security:** `bcrypt` for password hashing, JWT for session management

## Database Architecture
The relational database (`pharmacy`) consists of several interconnected entities to ensure data integrity:
*   `Client`: Stores customer details (Name, Passport info, Address).
*   `Drug`: Stores medication details, pricing, stock levels, and prescription requirements.
*   `Manufacturer`: Information about drug suppliers.
*   `Drug_Batch`: Tracks manufacturing and expiry dates for specific batches.
*   `Prescription`: Stores prescription validity and links them to specific clients and drugs.
*   `Order` & `Order_Drug`: Handles transactional data and maps multiple drugs to a single client order.
*   `Discount`: Stores available discount tiers.
*   `Roles` & `Users`: Manages system access and credentials.

## System Requirements
*   **DBMS:** PostgreSQL 16+
*   **Python:** 3.8+
*   **Hardware (Minimum):** 2 GB RAM, multi-core processor, 10 GB free disk space.
*   **Browser:** Any modern web browser (Chrome, Firefox, Safari).

## Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/pharmacy-management-system.git
   cd pharmacy-management-system
   ```

2. **Database Setup:**
   * Open PostgreSQL (e.g., via pgAdmin) and create a new database named `pharmacy`.
   * Run the SQL scripts provided in the `create_tables.sql` file to generate the schema, triggers, and functions.
   * (Optional) Insert the sample data provided in the project files to populate the database for testing.

3. **Backend Setup:**
   * Create a virtual environment and install the required Python packages:
     ```bash
     python -m venv venv
     source venv/bin/activate  # On Windows: venv\Scripts\activate
     pip install flask flask-jwt-extended psycopg2 bcrypt
     ```
   * Update the database connection string in your Flask application file with your local PostgreSQL credentials.
   * Start the server:
     ```bash
     python app.py
     ```

4. **Frontend Setup:**
   * Open the `index.html` file in your preferred web browser, or use a tool like VS Code Live Server to serve the frontend files locally.

## Documentation
For an in-depth explanation of the system's logical and physical database models, ER diagrams, testing queries, and architectural choices, please refer to the **Курсова.docx** file included in the project documentation.

## Author
*   **Denys Chornokon** (Group MIT-41, Taras Shevchenko National University of Kyiv)