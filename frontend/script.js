const baseUrl = "http://localhost:8000"; // Base URL for your FastAPI backend

// Toggle visibility of content
function toggleVisibility(elementId) {
    const element = document.getElementById(elementId);
    if (element.style.display === "none") {
        element.style.display = "block";
    } else {
        element.style.display = "none";
    }
}

// Fetch Books (GET Request)
document.getElementById("fetch-books").addEventListener("click", async () => {
    const booksList = document.getElementById("books-list");
    toggleVisibility("books-list");

    if (booksList.style.display === "block") {
        try {
            const response = await fetch(`${baseUrl}/books/`, { method: "GET" });

            if (!response.ok) {
                throw new Error(`Error fetching books: ${response.status}`);
            }

            const books = await response.json();
            booksList.innerHTML = "";

            books.forEach(book => {
                const listItem = document.createElement("li");
                listItem.textContent = `${book.title} - ${book.library_name}`;
                booksList.appendChild(listItem);
            });
        } catch (error) {
            console.error(error.message);
            alert("Failed to fetch books.");
        }
    }
});

// Fetch Overdue Transactions (GET Request)
document.getElementById("fetch-overdue-transactions").addEventListener("click", async () => {
    const transactionsList = document.getElementById("transactions-list");
    toggleVisibility("transactions-list");

    if (transactionsList.style.display === "block") {
        try {
            const response = await fetch(`${baseUrl}/transactions/overdue/`, { method: "GET" });

            if (!response.ok) {
                throw new Error(`Error fetching transactions: ${response.status}`);
            }

            const transactions = await response.json();
            transactionsList.innerHTML = "";

            transactions.forEach(transaction => {
                const listItem = document.createElement("li");
                listItem.textContent =
                    `${transaction.member_name} borrowed "${transaction.book_title}" and is overdue since ${transaction.due_date}`;
                transactionsList.appendChild(listItem);
            });
        } catch (error) {
            console.error(error.message);
            alert("Failed to fetch overdue transactions.");
        }
    }
});

// Fetch Book Authors (GET Request)
document.getElementById("fetch-authors-form").addEventListener("submit", async (e) => {
    e.preventDefault(); // Prevent form submission

    const bookId = document.getElementById("book-id").value;
    const authorsList = document.getElementById("authors-list");
    toggleVisibility("authors-list");

    if (authorsList.style.display === "block") {
        try {
            const response = await fetch(`${baseUrl}/books/${bookId}/authors/`, { method: "GET" });

            if (!response.ok) {
                throw new Error(`Error fetching authors for book ID ${bookId}: ${response.status}`);
            }

            const authors = await response.json();
            authorsList.innerHTML = "";

            authors.forEach(author => {
                const listItem = document.createElement("li");
                listItem.textContent =
                    `${author.first_name} ${author.last_name} (${author.author_role}) - Contribution: ${author.contribution_percentage}%`;
                authorsList.appendChild(listItem);
            });
        } catch (error) {
            console.error(error.message);
            alert(`Failed to fetch authors for book ID ${bookId}.`);
        }
    }
});

// Add Book (POST Request)
document.getElementById("add-book-form").addEventListener("submit", async (e) => {
    e.preventDefault(); // Prevent form submission

    const libraryId = document.getElementById("library-id").value;
    const genreId = document.getElementById("genre-id").value;
    const publisherId = document.getElementById("publisher-id").value;
    const title = document.getElementById("title").value;
    const isbn = document.getElementById("isbn").value;
    const publicationDate = document.getElementById("publication-date").value;

    const bookData = { library_id: libraryId, genre_id: genreId, publisher_id: publisherId, title, isbn, publication_date: publicationDate };

    try {
        const response = await fetch(`${baseUrl}/books/`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(bookData),
        });

        if (!response.ok) {
            throw new Error(`Error adding book: ${response.status}`);
        }

        const result = await response.json();
        document.getElementById("response").innerHTML =
            `<p>${result.message}</p><p>New Book ID: ${result.book_details.new_book_id}</p>`;
    } catch (error) {
        console.error(error.message);
        alert("Failed to add book.");
    }
});

// Borrow Book (POST Request)
document.getElementById("borrow-book-form").addEventListener("submit", async (e) => {
    e.preventDefault(); // Prevent form submission

    const memberId = document.getElementById("member-id").value;
    const bookIdBorrow = document.getElementById("book-id-borrow").value;
    const staffId = document.getElementById("staff-id").value;

    const transactionData = { member_id: memberId, book_id: bookIdBorrow, staff_id: staffId };

    try {
        const response = await fetch(`${baseUrl}/transactions/borrow/`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(transactionData),
        });

        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.detail);
        }

        const result = await response.json();
        document.getElementById("response").innerHTML =
            `<p>${result.message}</p><p>New Transaction ID: ${result.transaction_details.new_transaction_id}</p>`;
    
    } catch (error) {
        console.error(error.message);
        document.getElementById("response").innerHTML =
            `<p style="color: red;">${error.message}</p>`;
    }
});

// Return Book (POST Request)
document.getElementById("return-book-form").addEventListener("submit", async (e) => {
    e.preventDefault(); // Prevent form submission

    const transactionId = document.getElementById("transaction-id").value;

    const transactionData = { transaction_id: transactionId };

    try {
        const response = await fetch(`${baseUrl}/transactions/return/`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(transactionData),
        });

        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.detail);
        }

        const result = await response.json();
        document.getElementById("response").innerHTML =
            `<p>${result.message}</p><p>Late Fee: $${result.return_details.late_fee}</p>`;
    
    } catch (error) {
        console.error(error.message);
        document.getElementById("response").innerHTML =
            `<p style="color: red;">${error.message}</p>`;
    }
});