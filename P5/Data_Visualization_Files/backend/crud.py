from sqlalchemy.orm import Session
from sqlalchemy.sql import text

# Helper function to convert SQLAlchemy result rows into dictionaries
def convert_to_dict(results):
    return [dict(row._mapping) for row in results]  # Use _mapping attribute for conversion

# CRUD Operations for Book
def get_books(db: Session):
    query = text("SELECT * FROM vw_BookInformation")
    results = db.execute(query).fetchall()
    return convert_to_dict(results)

def get_book_authors(db: Session, book_id: int):
    query = text(f"SELECT * FROM dbo.fn_GetBookAuthors({book_id})")
    results = db.execute(query).fetchall()
    return convert_to_dict(results)

# CRUD Operations for Transactions
def get_overdue_transactions(db: Session):
    query = text("SELECT * FROM vw_OverdueTransactions")
    results = db.execute(query).fetchall()
    return convert_to_dict(results)

# Add a new book by calling sp_AddNewBook stored procedure
def add_new_book(db: Session, book_data: dict):
    query = text(
        """
        DECLARE @NewBookID INT;
        EXEC sp_AddNewBook 
            @LibraryID = :library_id,
            @GenreID = :genre_id,
            @PublisherID = :publisher_id,
            @Title = :title,
            @ISBN = :isbn,
            @PublicationDate = :publication_date,
            @NewBookID = @NewBookID OUTPUT;
        SELECT @NewBookID AS NewBookID;
        """
    )
    result = db.execute(query, book_data).fetchone()
    db.commit()
    # Unpack the tuple result
    new_book_id = result[0]  # Access the first element of the tuple
    return {"new_book_id": new_book_id}

# Create a new borrowing transaction by calling sp_BorrowBook stored procedure
def borrow_book(db: Session, transaction_data: dict):
    query = text(
        """
        DECLARE @NewTransactionID INT;
        EXEC sp_BorrowBook 
            @MemberID = :member_id,
            @BookID = :book_id,
            @StaffID = :staff_id,
            @NewTransactionID = @NewTransactionID OUTPUT;
        SELECT @NewTransactionID AS NewTransactionID;
        """
    )
    
    try:
        result = db.execute(query, transaction_data).fetchone()
        db.commit()  # Explicitly commit the transaction

        if result is None:
            raise Exception("No available copy for this book. Please reserve the book to borrow it when available.")
        
        new_transaction_id = result[0]  # Access the first element of the tuple
        return {"new_transaction_id": new_transaction_id}
    
    except Exception as e:
        db.rollback()  # Rollback in case of error
        raise e  # Re-raise the exception for FastAPI to handle
    
# Complete a transaction by calling sp_ReturnBook stored procedure
def return_book(db: Session, transaction_data: dict):
    query = text(
        """
        DECLARE @LateFee DECIMAL(10,2);
        EXEC sp_ReturnBook 
            @TransactionID = :transaction_id,
            @LateFee = @LateFee OUTPUT;
        SELECT @LateFee AS LateFee;
        """
    )
    
    try:
        result = db.execute(query, transaction_data).fetchone()
        db.commit()  # Explicitly commit the transaction

        if result is None:
            raise Exception("Transaction not found or unable to process return.")
        
        late_fee = result[0]  # Access the first element of the tuple
        return {"late_fee": late_fee}
    
    except Exception as e:
        db.rollback()  # Rollback in case of error
        raise e  # Re-raise the exception for FastAPI to handle