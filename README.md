<<<<<<< HEAD
# 💊 نظام إدارة الصيدلية المتكامل (Pharmacy Management System)

نظام برمجى متكامل مبني باستخدام إطار عمل **Laravel 11**، مصمم لإدارة العمليات اليومية للصيدليات بفعالية عالية. يهدف النظام إلى أتمتة عمليات البيع، الشراء، تتبع المخزون، وإدارة الحسابات المالية للموردين والعملاء.

---

## 🚀 المميزات الرئيسية (Features)

### 📦 إدارة المخزون (Inventory Management)
* **تتبع التشغيلات (Batch Tracking):** إدارة الأدوية بناءً على رقم التشغيلة لضمان دقة تتبع تواريخ الصلاحية.
* **تنبيهات انتهاء الصلاحية:** نظام ذكي لمراقبة الأدوية القريبة من الانتهاء.
* **حد إعادة الطلب (Reorder Level):** تنبيه تلقائي عند وصول كمية الدواء لمستوى معين لضمان عدم نفاذ المخزون.
* **تعدد الوحدات:** دعم بيع الدواء بوحدات مختلفة (شريط، علبة، زجاجة).

### 💰 المبيعات والمشتريات (Sales & Purchases)
* **نظام فواتير متطور:** إصدار فواتير البيع والشراء مع دعم ضريبة القيمة المضافة والخصومات.
* **إدارة المرتجعات:** معالجة مرتجعات المبيعات والمشتريات وتحديث المخزون تلقائياً.
* **نقاط البيع (POS):** واجهة سريعة وسهلة الاستخدام لعمليات البيع اليومية.

### 👥 الإدارة المالية والحسابات
* **حسابات الموردين:** تتبع الأرصدة المستحقة للشركات والموردين.
* **حسابات العملاء:** إدارة الحد الائتماني (Credit Limit) لكل عميل وتتبع المديونيات.
* **المدفوعات:** سجل كامل لجميع المقبوضات والمدفوعات المالية.

### 📊 التقارير والإحصائيات
* **تقارير يومية:** ملخص العمليات المالية والمبيعات اليومية.
* **تقارير PDF:** إمكانية تصدير التقارير وفواتير الطباعة بصيغة PDF.

---

## 🛠 المتطلبات التقنية (Technical Stack)

| التقنية | النوع |
| :--- | :--- |
| **Laravel 11** | Framework |
| **MySQL / MariaDB** | Database |
| **Tailwind CSS** | Frontend CSS |
| **Blade Templates** | Templating Engine |
| **Laravel Breeze** | Authentication |
| **Vite** | Asset Bundler |

---

## 🏗 هيكل قاعدة البيانات (Database Schema)

النظام يعتمد على قاعدة بيانات مترابطة تشمل الجداول التالية:
* `Medicines`: البيانات الأساسية للأدوية (الاسم، الباركود، الفئة).
* `Batches`: تفاصيل الكميات المتاحة، أسعار الشراء والبيع، وتواريخ الصلاحية.
* `Suppliers & Customers`: بيانات الجهات الخارجية وحساباتهم المالية.
* `Invoices (Sales/Purchase)`: سجلات العمليات التجارية وعناصرها.
* `Branches`: لدعم إدارة الصيدلية عبر مواقع متعددة.

---

## ⚙️ التثبيت والتشغيل (Installation)

1.  **تحميل المشروع:**
    ```bash
    git clone [repository-url]
    cd pharmacy-management-system
    ```

2.  **تثبيت المكتبات البرمجية:**
    ```bash
    composer install
    npm install
    ```

3.  **إعداد ملف البيئة:**
    * قم بنسخ `.env.example` إلى `.env`.
    * قم بتعديل بيانات قاعدة البيانات في ملف `.env`.

4.  **توليد مفتاح التشفير وتهجير البيانات:**
    ```bash
    php artisan key:generate
    php artisan migrate --seed
    ```

5.  **تشغيل المشروع:**
    ```bash
    php artisan serve
    # في نافذة أخرى
    npm run dev
    ```

---

## 📂 هيكل المجلدات (Project Structure)

* `app/Models`: تحتوي على منطق البيانات والعلاقات بين الجداول (مثل Medicine, Batch).
* `app/Http/Controllers`: تحتوي على منطق التحكم في العمليات (مثل SalesInvoiceController).
* `resources/views`: واجهات المستخدم المصممة باستخدام Tailwind CSS.
* `routes/web.php`: مسارات النظام الأساسية.

---

## 📝 ملاحظات
> [!NOTE]
> * تأكد من إعداد رابط التخزين لرفع الملفات: `php artisan storage:link`.
> * كلمة مرور الإدارة الافتراضية بعد الـ Seed هي: `password`.

---
=======
# Pharmacy Management System

## Overview
The Pharmacy Management System is a comprehensive and robust web application built with Laravel and Tailwind CSS. It is designed to streamline and automate the daily operations of a pharmacy, ranging from inventory management and sales to supplier and customer account management.

## Key Features
- **User Management**: Role-based access control for Admins, Pharmacists, and Cashiers.
- **Branch Management**: Support for managing multiple pharmacy branches and their respective operations.
- **Inventory Management**:
  - Manage Medicines and specific tracking via Batches (including production and expiry dates).
  - Stock level monitoring and automated system notifications for low stock.
- **Purchases (Suppliers & Invoices)**:
  - Register suppliers and handle purchase invoices.
  - Process purchase returns.
- **Sales (Customers & Invoices)**:
  - Manage customer profiles and continuous credit accounts (Customer Accounts, Account Transactions).
  - Point of Sale (POS) functionality supporting cash and credit sales (Sales Invoices, Sales Returns).
- **Financial Management**: Track incoming and outgoing payments.
- **Reports**: Generate detailed, real-time reports for sales, purchases, stock, and financials.
  
## Tech Stack
- **Backend Framework**: Laravel (PHP)
- **Frontend Framework**: HTML, Blade Templates, Tailwind CSS, Vite
- **Database**: MySQL / MariaDB

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd pharmacy-management-system-main
   ```

2. **Install Composer dependencies**
   ```bash
   composer install
   ```

3. **Install NPM dependencies**
   ```bash
   npm install
   npm run build
   ```

4. **Environment Setup**
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```
   Update the `.env` file with your database credentials.

5. **Run Migrations**
   ```bash
   php artisan migrate --seed
   ```

6. **Serve the application**
   ```bash
   php artisan serve
   ```

## Documentation
The system's architecture and behavioral flow are documented using PlantUML. You can find all the UML diagrams in the `docs/` folder:
- **Use Case Diagram**: `docs/usecase_diagram.pdf`
- **Class Diagram**: `docs/class_diagram.pdf`
- **Sequence Diagram**: `docs/sequence_diagram.pdf`
- **State Diagram**: `docs/state_diagram.pdf`
- **Activity Diagram**: `docs/activity_diagram.pdf`
- **Component Diagram**: `docs/component_diagram.pdf`

>>>>>>> 165f91f (docs)
