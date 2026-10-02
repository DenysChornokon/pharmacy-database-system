# Pharmacy Drug Sales Management System

## Overview
The Pharmacy Drug Sales Management System is a web-based application designed to automate and optimize the daily operations of a pharmacy. It provides robust tools for tracking drug inventory, managing customer orders, verifying prescription requirements, and automatically calculating purchase totals with conditional discounts. 

This project was developed as a course project detailed in the accompanying **Курсова.docx** file.

## Features

### Role-Based Access Control (RBAC)
The system uses JWT (JSON Web Tokens) for secure authentication and authorization, dividing users into two main roles:
*   **Administrator:** has full access to manage the system. Can add, edit, and delete drug records, and view comprehensive order histories for specific clients.
*   **Pharmacist:** handles the point-of-sale operations. Can view lists of clients and drugs, process customer orders, verify prescriptions, and finalize sales.

### Core Functionalities
*   **Inventory Management:** automatically deducts sold quantities from the central database to prevent overselling.
*   **Prescription Verification:** enforces prescription checks for restricted drugs. Validates that the prescription is assigned to the correct client, matches the requested drug, and is not expired.
*   **Automated Discounts:** database triggers automatically calculate and apply discounts based on predefined business rules:
    *   *Lucky Number (10%):* applied if the day of the order date matches a number in the client's passport.
    *   *Bulk Order (15%):* applied if the order contains more than 15 items.
    *   *(If both conditions are met, the system applies the highest discount).*

## Technologies Used
*   **Database:** PostgreSQL (Relational database with complex triggers, foreign keys, and stored procedures)
*   **Backend:** Python with Flask framework (RESTful API architecture)
*   **Frontend:** Vanilla HTML, CSS, and JavaScript
*   **Security:** `bcrypt` for password hashing, JWT for session management

## Database Architecture
The relational database (`pharmacy`) consists of several interconnected entities to ensure data integrity:
*   `Client`: stores customer details (Name, Passport info, Address).
*   `Drug`: stores medication details, pricing, stock levels, and prescription requirements.
*   `Manufacturer`: information about drug suppliers.
*   `Drug_Batch`: tracks manufacturing and expiry dates for specific batches.
*   `Prescription`: stores prescription validity and links them to specific clients and drugs.
*   `Order` & `Order_Drug`: handles transactional data and maps multiple drugs to a single client order.
*   `Discount`: stores available discount tiers.
*   `Roles` & `Users`: manages system access and credentials.

## Documentation
For an in-depth explanation of the system's logical and physical database models, ER diagrams, testing queries, and architectural choices, please refer to the **Курсова.docx** file included in the project documentation.

## Author
*   **Denys Chornokon** (Group MIT-41, Taras Shevchenko National University of Kyiv)
