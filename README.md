# 🏦 BankEase – Smart Bank Management System

**A Smart Bank Management System Using Rule-Based Automation and Role-Based Access Control**

BankEase is a web-based banking management application developed to simplify banking operations using rule-based automation and role-based access control (RBAC). It provides a secure and user-friendly platform for managing bank accounts, financial transactions, customer services, and administrative activities.

## 🚀 Key Features

- **User Authentication:** Secure login and registration.
- **JWT Authentication:** Token-based authentication using JSON Web Tokens.
- **Role-Based Access Control:** Different permissions for Admin, Employee, and Customer.
- **Account Management:** Manage Savings and Current accounts.
- **Transaction Management:** Deposit, Withdraw, and Transfer money.
- **Rule-Based Automation:** Automatic validation of banking transactions.
- **Transaction History:** View and track transaction records.
- **Service Requests:** Submit and track customer service requests.
- **Account Status Management:** Active, Blocked, and Closed account statuses.
- **Balance Validation:** Prevent transactions when sufficient balance is unavailable.
- **Admin Dashboard:** Monitor users, accounts, and banking activities.
- **Employee Management:** Support customer banking operations.

## 🛠️ Technology Stack

### Backend
- Java 21
- Spring Boot 4.1.1
- Spring Security
- JWT (JSON Web Token)
- Maven
- REST APIs

### Frontend
- HTML5
- CSS3
- JavaScript

### Database
- MySQL 8.0

### Development Tools
- Visual Studio Code
- IntelliJ IDEA (if used)
- MySQL Workbench
- Postman (if used)
- Git & GitHub

## 🔐 Security Implementation

BankEase implements multiple security mechanisms:

- JWT-based Authentication
- Spring Security
- Role-Based Access Control (RBAC)
- Role-based authorization for ADMIN, EMPLOYEE, and CUSTOMER
- Secure password handling
- Protected banking operations
- Transaction validation

## 👥 User Roles

### 1. Admin
- Manage customers and employees.
- Monitor banking transactions.
- Manage customer accounts.
- Oversee banking operations.

### 2. Employee
- Assist customers.
- Handle banking operations.
- Manage customer service requests.

### 3. Customer
- View account details.
- Deposit and withdraw money.
- Transfer funds.
- View transaction history.
- Submit service requests.
- Track service request status.

## ⚙️ Rule-Based Automation

The system uses predefined business rules to validate banking operations.

| Rule | Description |
|---|---|
| BLOCKED_ACCOUNT | Prevents transactions on blocked accounts. |
| INSUFFICIENT_BALANCE | Rejects transactions when balance is insufficient. |
| ACCOUNT_STATUS | Checks whether an account is active. |
| TRANSACTION_VALIDATION | Validates banking transaction operations. |

## 🗄️ Database Management

MySQL is used to store and manage banking information, including:

- User details
- Customer accounts
- Account types
- Transaction records
- Service requests
- Banking rules

## ⚙️ Installation and Setup

### Prerequisites

- Java JDK 21
- MySQL 8.0
- Maven
- Git

### Step 1: Clone Repository

```bash
git clone https://github.com/aryanyadav196/BankEase.git
```

### Step 2: Navigate to Project

```bash
cd BankEase
```

### Step 3: Configure MySQL

Create the database using the database name configured in your application.

```sql
CREATE DATABASE bankease;
```

### Step 4: Configure Application Properties

Update your MySQL username, password, and database configuration in `application.properties`.

### Step 5: Run the Application

```bash
mvn spring-boot:run
```

Backend URL:

`http://localhost:8082`

## 🎯 Project Objectives

- To develop a secure banking management system.
- To implement JWT authentication and role-based authorization.
- To automate banking operations using predefined business rules.
- To manage customer accounts and financial transactions.
- To improve banking service management and transaction reliability.

## 🎓 Academic Project Details

**Project Name:** BankEase – Smart Bank Management System

**Course:** Web and Mobile Application Development

**Department:** Computer Science and Engineering

**Academic Year:** 2026–27

**Sustainable Development Goal:** SDG 8 – Decent Work and Economic Growth

**SDG Target:** 8.10 – Strengthen the capacity of domestic financial institutions.

## 👨‍💻 Developer

**Aryan Yadav**

GitHub: https://github.com/aryanyadav196

---

⭐ If you find this project useful, consider giving it a star!

