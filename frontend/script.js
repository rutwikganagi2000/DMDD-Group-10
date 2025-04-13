// Base URL for your FastAPI backend
const baseUrl = "http://localhost:8000";

document.addEventListener('DOMContentLoaded', () => {
    // Preloader Animation
    function preloaderAnimation() {
        const greetingElement = document.querySelector('.greeting');
        const greetings = [
            ". (NOVIS) (NOVIS)",
            ". Dennis Sharon Cheruvathoor",
            ". Sachin Vishaul Baskar",
            ". Rutwik Ganagi",
            ". Ashwin Badamikar",
            ". Chetan Warad"
        ];

        let currentIndex = 0;

        // Change greeting every 1.5 seconds
        const interval = setInterval(() => {
            currentIndex = (currentIndex + 1) % greetings.length;
            greetingElement.textContent = greetings[currentIndex];
        }, 1500);

        // Hide preloader after 8.2 seconds
        setTimeout(() => {
            clearInterval(interval);
            const preloader = document.querySelector('.preloader');
            preloader.style.opacity = '0';

            setTimeout(() => {
                preloader.style.display = 'none';
            }, 800);
        }, 8200);
    }

    preloaderAnimation();
    
    // Verify login on every page load
    checkUserAuthentication();
});

// Check user authentication and role-based access
function checkUserAuthentication() {
    if (!localStorage.getItem('loggedIn')) {
        window.location.href = 'login.html';
        return false;
    }
    
    // Get user data and role
    try {
        const userData = JSON.parse(localStorage.getItem('userData') || '{}');
        const userRole = localStorage.getItem('userRole');
        
        // Display welcome message
        const userWelcomeElement = document.getElementById('user-welcome');
        if (userWelcomeElement) {
            userWelcomeElement.textContent = `Welcome, ${userData.full_name} (${userRole})`;
        }
        
        // Role-based access control
        if (userRole === 'staff') {
            // Staff can see everything
            document.getElementById('staff-only-sections').style.display = 'block';
        } else if (userRole === 'member') {
            // Members can only see member sections (which are visible by default)
            document.getElementById('staff-only-sections').style.display = 'none';
        }
    } catch (error) {
        console.error("Error processing user data:", error);
    }
    
    return true;
}

// Response Message Handler
function showResponse(message, isError = false) {
    const responseDiv = document.getElementById('response');
    const messageEl = document.createElement('div');
    messageEl.className = `response-message ${isError ? 'error' : 'success'}`;
    messageEl.innerHTML = `
            <p>${message}</p>
            <button class="close-btn" onclick="this.parentElement.remove()">&times;</button>
        `;
    responseDiv.prepend(messageEl);
}

// Form Clearing Function
function clearForm(formId) {
    document.getElementById(formId).reset();
}

// Toggle visibility of content 
function toggleVisibility(elementId) {
    const element = document.getElementById(elementId);
    element.style.display = element.style.display === "none" ? "block" : "none";
}

// Fetch Books (GET Request) 
document.getElementById("fetch-books").addEventListener("click", async () => {
    if (!checkUserAuthentication()) return;

    const booksList = document.getElementById("books-list");
    toggleVisibility("books-list");

    if (booksList.style.display === "block") {
        try {
            const response = await fetch(`${baseUrl}/books/`);
            if (!response.ok) throw new Error(`Error: ${response.status}`);

            const books = await response.json();
            booksList.innerHTML = books.length ?
                books.map(book => `<li>Book ID: ${book.book_id}, ${book.title} - ${book.library_name}</li>`).join('') :
                '<li>No books found</li>';

            showResponse(`Found ${books.length} books`);
        } catch (error) {
            showResponse(`Failed to fetch books: ${error.message}`, true);
        }
    }
});

// Fetch Overdue Transactions (GET Request) 
if (document.getElementById("fetch-overdue-transactions")) {
    document.getElementById("fetch-overdue-transactions").addEventListener("click", async () => {
        if (!checkUserAuthentication()) return;
        
        const transactionsList = document.getElementById("transactions-list");
        toggleVisibility("transactions-list");

        if (transactionsList.style.display === "block") {
            try {
                const response = await fetch(`${baseUrl}/transactions/overdue/`);
                if (!response.ok) throw new Error(`Error: ${response.status}`);

                const transactions = await response.json();
                transactionsList.innerHTML = transactions.length ?
                    transactions.map(t => `<li>${t.member_name} borrowed "${t.book_title}" (Due: ${t.due_date})</li>`).join('') :
                    '<li>No overdue transactions</li>';

                showResponse(`Found ${transactions.length} overdue transactions`);
            } catch (error) {
                showResponse(`Failed to fetch transactions: ${error.message}`, true);
            }
        }
    });
}

// Fetch Book Authors (GET Request) 
document.getElementById("fetch-authors-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    if (!checkUserAuthentication()) return;
    
    const bookId = document.getElementById("book-id").value;
    const authorsList = document.getElementById("authors-list");
    toggleVisibility("authors-list");

    if (authorsList.style.display === "block") {
        try {
            const response = await fetch(`${baseUrl}/books/${bookId}/authors/`);
            if (!response.ok) throw new Error(`Error: ${response.status}`);

            const authors = await response.json();
            authorsList.innerHTML = authors.length ?
                authors.map(a => `<li>${a.first_name} ${a.last_name} (${a.author_role}) - Contribution: ${a.contribution_percentage}%</li>`).join('') :
                '<li>No authors found</li>';

            showResponse(`Found ${authors.length} authors for book #${bookId}`);
        } catch (error) {
            showResponse(`Failed to fetch authors: ${error.message}`, true);
        }
    }
});

// Add Book (POST Request)
if (document.getElementById("add-book-form")) {
    document.getElementById("add-book-form").addEventListener("submit", async (e) => {
        e.preventDefault();
        if (!checkUserAuthentication()) return;
        
        // Check if user is staff
        const userData = JSON.parse(localStorage.getItem('userData') || '{}');
        const userRole = localStorage.getItem('userRole');
        
        if (userRole !== 'staff') {
            showResponse("You don't have permission to add books", true);
            return;
        }
        
        const bookData = {
            library_id: document.getElementById("library-id").value,
            genre_id: document.getElementById("genre-id").value,
            publisher_id: document.getElementById("publisher-id").value,
            title: document.getElementById("title").value,
            isbn: document.getElementById("isbn").value,
            publication_date: document.getElementById("publication-date").value,
        };

        try {
            const response = await fetch(`${baseUrl}/books/`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(bookData),
            });

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.detail || "Failed to add book");
            }

            const result = await response.json();
            showResponse(`Book added successfully (ID: ${result.book_details.new_book_id})`);
            clearForm("add-book-form");
        } catch (error) {
            showResponse(`Failed to add book: ${error.message}`, true);
        }
    });
}

// Borrow Book (POST Request)
if (document.getElementById("borrow-book-form")) {
    document.getElementById("borrow-book-form").addEventListener("submit", async (e) => {
        e.preventDefault();
        if (!checkUserAuthentication()) return;

        // Check if user is staff
        const userData = JSON.parse(localStorage.getItem('userData') || '{}');
        const userRole = localStorage.getItem('userRole');
        
        if (userRole !== 'staff') {
            showResponse("You don't have permission to borrow books", true);
            return;
        }
        
        // Collect form data
        const transactionData = {
            member_id: document.getElementById("member-id").value,
            book_id: document.getElementById("book-id-borrow").value,
            staff_id: document.getElementById("staff-id").value,
        };

        try {
            // Send POST request to Borrow Book API
            const response = await fetch(`${baseUrl}/transactions/borrow/`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(transactionData),
            });

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.detail || "Failed to borrow book");
            }

            const result = await response.json();
            showResponse(`Transaction created successfully (ID: ${result.transaction_details.new_transaction_id})`);
            clearForm("borrow-book-form");
        } catch (error) {
            showResponse(`Failed to borrow book: ${error.message}`, true);
        }
    });
}

// Return Book (POST Request) 
if (document.getElementById("return-book-form")) {
    document.getElementById("return-book-form").addEventListener("submit", async (e) => {
        e.preventDefault();
        if (!checkUserAuthentication()) return;
        
        // Check if user is staff
        const userData = JSON.parse(localStorage.getItem('userData') || '{}');
        const userRole = localStorage.getItem('userRole');
        
        if (userRole !== 'staff') {
            showResponse("You don't have permission to return books", true);
            return;
        }
        
        const transactionId = document.getElementById("transaction-id").value;

        try {
            const response = await fetch(`${baseUrl}/transactions/return/`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ transaction_id: transactionId })
            });

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.detail || "Failed to return book");
            }

            const result = await response.json();
            showResponse(`Return processed. Late fee: $${result.return_details.late_fee}`);
            clearForm("return-book-form");
        } catch (error) {
            showResponse(`Failed to return book: ${error.message}`, true);
        }
    });
}

// Sign-out handler
document.getElementById('sign-out-btn').addEventListener('click', () => {
    // Clear login status
    localStorage.removeItem('loggedIn');
    localStorage.removeItem('userRole');
    localStorage.removeItem('userData');

    // Redirect to login page
    window.location.href = 'login.html';
});
