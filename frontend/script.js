document.addEventListener('DOMContentLoaded', () => {
    // Preloader Animation - Fixed
    function preloaderAnimation() {
        const greetingElement = document.querySelector('.greeting');
        const greetings = [
            ". Dennis Sharon (NOVIS)",
         ". Dennis Sharon Cheruvathoor",//starts
            ". Sachin Vishaul Baskar",
            ". Rutwik Ganagi",
            ". Ashwin Badamikar", 
            ". Chetan Warad ",//ends
        ];
        
        let currentIndex = 0;
        
        // Change greeting every 1.5 seconds
        const interval = setInterval(() => {
            currentIndex = (currentIndex + 1) % greetings.length;
            greetingElement.textContent = greetings[currentIndex];
        }, 1500);
        
        // Hide preloader after 6 seconds
        setTimeout(() => {
            const preloader = document.querySelector('.preloader');
            preloader.style.opacity = '0';
            
            // Remove preloader from DOM after fade out
            setTimeout(() => {
                preloader.style.display = 'none';
                clearInterval(interval);
            }, 800);
        }, 8200);
    }
    
    preloaderAnimation();

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

    const baseUrl = "http://localhost:8000";

    // Toggle visibility of content 
    function toggleVisibility(elementId) {
        const element = document.getElementById(elementId);
        element.style.display = element.style.display === "none" ? "block" : "none";
    }

    // Fetch Books (GET Request) 
    document.getElementById("fetch-books").addEventListener("click", async () => {
        const booksList = document.getElementById("books-list");
        toggleVisibility("books-list");

        if (booksList.style.display === "block") {
            try {
                const response = await fetch(`${baseUrl}/books/`);
                if (!response.ok) throw new Error(`Error: ${response.status}`);
                
                const books = await response.json();
                booksList.innerHTML = books.length ? 
                    books.map(book => `<li>${book.title} - ${book.library_name}</li>`).join('') :
                    '<li>No books found</li>';
                
                showResponse(`Found ${books.length} books`);
            } catch (error) {
                showResponse(`Failed to fetch books: ${error.message}`, true);
            }
        }
    });

    // Fetch Overdue Transactions (GET Request) 
    document.getElementById("fetch-overdue-transactions").addEventListener("click", async () => {
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

    // Fetch Book Authors (GET Request) - Updated
    document.getElementById("fetch-authors-form").addEventListener("submit", async (e) => {
        e.preventDefault();
        const bookId = document.getElementById("book-id").value;
        const authorsList = document.getElementById("authors-list");
        toggleVisibility("authors-list");

        if (authorsList.style.display === "block") {
            try {
                const response = await fetch(`${baseUrl}/books/${bookId}/authors/`);
                if (!response.ok) throw new Error(`Error: ${response.status}`);
                
                const authors = await response.json();
                authorsList.innerHTML = authors.length ? 
                    authors.map(a => `<li>${a.first_name} ${a.last_name} (${a.contribution_percentage}%)</li>`).join('') :
                    '<li>No authors found</li>';
                
                showResponse(`Found ${authors.length} authors for book #${bookId}`);
                clearForm("fetch-authors-form");
            } catch (error) {
                showResponse(`Failed to fetch authors: ${error.message}`, true);
            }
        }
    });

    // Add Book (POST Request)
    document.getElementById("add-book-form").addEventListener("submit", async (e) => {
        e.preventDefault();

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
        } catch (error) {
            showResponse(`Failed to add book: ${error.message}`, true);
        }
    });

    // Borrow Book (POST Request)
    document.getElementById("borrow-book-form").addEventListener("submit", async (e) => {
        e.preventDefault();

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
        } catch (error) {
            showResponse(`Failed to borrow book: ${error.message}`, true);
        }
    });

    // Return Book (POST Request) 
    document.getElementById("return-book-form").addEventListener("submit", async (e) => {
        e.preventDefault();
        const transactionId = document.getElementById("transaction-id").value;

        try {
            const response = await fetch(`${baseUrl}/transactions/return/`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ transaction_id: transactionId })
            });
            
            const result = await response.json();
            if (!response.ok) throw new Error(result.detail);
            
            showResponse(`Return processed. Late fee: $${result.return_details.late_fee}`);
            clearForm("return-book-form");
        } catch (error) {
            showResponse(`Failed to return book: ${error.message}`, true);
        }
    });
});
