# Pharmacy Management System — Monorepo

Welcome to the Pharmacy Management System repository. This repository is structured as a monorepo containing both the backend system (Laravel) and the upcoming desktop client application (Flutter).

---

## 📂 Project Structure

This repository is organized into the following main directories:

*   **[`backend/`](file:///d:/pharmacy-management-system-main/backend)**: Contains the Laravel 12 application. This acts as both the Web client (Blade templates) and the REST API provider (with a versioned API structure `/api/v1/` and Service layer architecture).
*   **[`flutter_desktop/`](file:///d:/pharmacy-management-system-main/flutter_desktop)**: The upcoming Desktop client application built with Flutter (currently an empty placeholder).

---

## 🚀 Getting Started

### Backend (Laravel)

To run the backend application locally:

1.  **Navigate to the backend directory**:
    ```bash
    cd backend
    ```

2.  **Install dependencies**:
    ```bash
    composer install
    npm install
    ```

3.  **Environment Configuration**:
    Copy the sample environment file and configure your database settings:
    ```bash
    copy .env.example .env
    ```
    Then run:
    ```bash
    php artisan key:generate
    ```

4.  **Database Migrations & Seeding**:
    Run migrations along with the database seeders to populate initial lookup data and user accounts:
    ```bash
    php artisan migrate --seed
    ```

5.  **Run the Server**:
    Start the local development server and Vite asset compiler:
    ```bash
    # Command 1: Run the Laravel local server
    php artisan serve

    # Command 2: Run the Vite development server (in a separate terminal)
    npm run dev
    ```

### Desktop Client (Flutter Desktop)

The desktop application is located in the `flutter_desktop` directory. When development starts, the client will connect directly to the REST APIs defined in the `/api/v1/` routes of the `backend` application.

---

## 🛠️ Architecture Overview (Backend)

The backend has been refactored into a **Service-oriented clean architecture**:
*   **Controllers** (`app/Http/Controllers/Web/` and `app/Http/Controllers/Api/V1/`): Extremely thin, responsible only for receiving requests, invoking service classes, and returning views or standard JSON API Resources.
*   **Services** (`app/Services/`): Contain all the core business logic, database transactions, stock calculations, and state modifications.
*   **Form Requests** (`app/Http/Requests/`): Abstract all validation logic out of the controllers.
*   **API Resources** (`app/Http/Resources/`): Control and format the JSON outputs for mobile/desktop integrations.
