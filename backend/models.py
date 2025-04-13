from sqlalchemy import Column, Integer, String, Date
from sqlalchemy.ext.declarative import declarative_base
from pydantic import BaseModel

Base = declarative_base()

class Book(Base):
    __tablename__ = "BOOK"
    book_id = Column(Integer, primary_key=True, index=True)
    library_id = Column(Integer, nullable=False)
    genre_id = Column(Integer, nullable=False)
    publisher_id = Column(Integer, nullable=False)
    title = Column(String(255), nullable=False)
    isbn = Column(String(20), nullable=False)
    publication_date = Column(Date, nullable=False)

class Transaction(Base):
    __tablename__ = "TRANSACTION"
    transaction_id = Column(Integer, primary_key=True, index=True)
    member_id = Column(Integer, nullable=False)
    copy_id = Column(Integer, nullable=False)
    staff_id = Column(Integer, nullable=False)
    borrow_date = Column(Date, nullable=False)
    due_date = Column(Date, nullable=False)
    return_date = Column(Date)
    transaction_status = Column(String(20), nullable=False)

class Reservation(Base):
    __tablename__ = "RESERVATION"
    reservation_id = Column(Integer, primary_key=True, index=True)
    member_id = Column(Integer, nullable=False)
    book_id = Column(Integer, nullable=False)
    staff_id = Column(Integer, nullable=False)
    reservation_date = Column(Date, nullable=False)
    reservation_status = Column(String(20), nullable=False)

# Pydantic model for adding a new book
class BookCreate(BaseModel):
    library_id: int
    genre_id: int
    publisher_id: int
    title: str
    isbn: str
    publication_date: str

# Pydantic model for borrowing a book
class BorrowTransactionCreate(BaseModel):
    member_id: int
    book_id: int
    staff_id: int

# Pydantic model for returning a book transaction
class ReturnTransactionCreate(BaseModel):
    transaction_id: int

# Pydantic model for user login
class UserLogin(BaseModel):
    username: str
    password: str
    role: str