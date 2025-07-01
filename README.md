# 📚 Library Management System

🚀 A web application developed using **FastAPI**, **HTML**, **CSS**, and **JavaScript** with a robust SQL Server (Azure Data Studio) backend featuring advanced database operations like stored procedures, triggers, views, and UDFs.

---

## ✨ Features

- 🔁 **Borrow & Return Books** — Fully automated flow using stored procedures like `sp_BorrowBook` and `sp_ReturnBook`
- 🧠 **Late Fee Calculation** — Auto-calculated using UDFs like `fn_CalculateLateFee`
- 📊 **Interactive Dashboards** — Created using **Power BI** to monitor borrowing trends, overdue fines, and feedback stats
- 📥 **Encrypted User Data** — Email and phone fields encrypted using AES-256 to ensure privacy
- 🔄 **Triggers for Automation**  
  - Late fine inserted automatically when book is returned late  
  - Book copy marked as unavailable if condition is set to ‘Damaged’
- 🧮 **Views & UDFs** for real-time data insights like:
  - Book rating averages  
  - Active membership status  
  - Membership duration
- 🔐 **Security & Constraints**  
  - Primary & Foreign Keys  
  - Check constraints  
  - Many-to-Many relationships via junction tables

---

## 🛠️ Tech Stack

| Layer            | Tech Used                          |
|------------------|------------------------------------|
| 💻 Frontend      | HTML, CSS, JavaScript              |
| 🧠 Backend       | Python with FastAPI                |
| 🗃️ Database      | SQL Server (Azure Data Studio)     |
| 📈 Visualization | Power BI                           |

---

## 🗄️ Database Design

- ✅ **Primary Keys** on identity columns (e.g., `library_id`, `book_id`, `member_id`)
- 🔗 **Foreign Keys** ensuring referential integrity
- 🔄 **Many-to-Many Relations** handled with junction tables (e.g., `BOOK_AUTHOR`)
- 🔍 **Views** for aggregating and simplifying query logic
- ⚙️ **Stored Procedures** to encapsulate business logic
- 🧮 **UDFs** for reusable computation logic
- 🧨 **Triggers** to automate post-update actions

---

## 👥 Team Members

- Rutwik Ganagi  
- Sachin Vishaul Baskar  
- Dennis Sharon  
- Ashwin Badamikar  
- Chetan Warad

👨‍🏫 **Professor**: Manuel Montrond

---

## 🧠 Learnings

- Integrated frontend and backend for a real-time web-based system
- Applied FastAPI for scalable RESTful API development
- Explored advanced SQL Server features: encryption, triggers, and stored procs
- Built data visualizations for insight-driven decisions using Power BI

---

## 📬 Contact

📧 ganagi.r@northeastern.edu  
🔗 [LinkedIn](https://linkedin.com/in/rutwik-ganagi)  

---

> 🌟 “Centralized. Automated. Secure. Your library experience, redefined.” 🌟

---

## 📊 Power BI Visualizations

Power BI was used to design **interactive dashboards** that provide real-time insights into the library’s operations. These visual reports enable stakeholders to make informed decisions based on data.

### 📌 Key Dashboards:

- 📈 **Borrowing Trends Over Time**
  - Track how borrowing rates change month-over-month
  - Identify peak borrowing periods 📅

- ⏳ **Overdue Book Statistics**
  - Monitor the number and type of overdue books
  - Evaluate the effectiveness of fine policies 💰

- ⭐ **Book Ratings & Feedback**
  - Visualize average ratings for books
  - Highlight popular or poorly rated titles

- 📚 **Inventory Breakdown**
  - Distribution by genre, publisher, and condition
  - Identify understocked categories 📦

- 🧾 **Fine Collection Report**
  - Total fines collected weekly/monthly
  - Average fine per transaction

### 🧠 Tools & Techniques Used:

- 🛠️ Power BI Desktop for design and data transformation
- 🔗 SQL Server views and stored procedures as data sources
- 🧩 Filters, slicers, and DAX measures for interactive controls
