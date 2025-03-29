from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi.middleware.cors import CORSMiddleware

from .database import SessionLocal
from .crud import get_books, get_book_authors, get_overdue_transactions, add_new_book, borrow_book, return_book
from .models import BookCreate, BorrowTransactionCreate, ReturnTransactionCreate

app = FastAPI()

# Enable CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins during development; restrict in production
    allow_credentials=True,
    allow_methods=["*"],  # Allow all HTTP methods
    allow_headers=["*"],  # Allow all headers
)

# Dependency to get DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/books/")
def fetch_books(db: Session = Depends(get_db)):
    books = get_books(db=db)
    return books

@app.get("/books/{book_id}/authors/")
def fetch_book_authors(book_id: int, db: Session = Depends(get_db)):
    authors = get_book_authors(db=db, book_id=book_id)
    return authors

@app.get("/transactions/overdue/")
def fetch_overdue_transactions(db: Session = Depends(get_db)):
    transactions = get_overdue_transactions(db=db)
    return transactions

@app.post("/books/")
def create_book(book: BookCreate, db: Session = Depends(get_db)):
    try:
        new_book = add_new_book(db=db, book_data=book.dict())
        return {"message": "Book added successfully", "book_details": new_book}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@app.post("/transactions/borrow/")
def create_borrow_transaction(transaction: BorrowTransactionCreate, db: Session = Depends(get_db)):
    try:
        new_transaction = borrow_book(db=db, transaction_data=transaction.dict())
        return {"message": "Borrowing transaction created successfully", "transaction_details": new_transaction}
    
    except Exception as e:
        # Simplify error message for frontend
        if "No available copy for this book" in str(e):
            raise HTTPException(status_code=400, detail="No available copy for this book. Please reserve the book to borrow it when available.")
        raise HTTPException(status_code=500, detail="An unexpected error occurred.")
    
@app.post("/transactions/return/")
def complete_return_transaction(transaction: ReturnTransactionCreate, db: Session = Depends(get_db)):
    try:
        return_details = return_book(db=db, transaction_data=transaction.dict())
        return {"message": "Transaction completed successfully", "return_details": return_details}
    
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
