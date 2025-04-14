from sqlalchemy.sql import text
from sqlalchemy.orm import Session
from security import hash_password
from database import SessionLocal

def hash_existing_passwords():
    """
    Script to hash all existing passwords in the USER_AUTH table.
    This should be run once when implementing password hashing.
    """
    db = SessionLocal()
    try:
        # Get all users
        query_select = text("SELECT auth_id, password FROM USER_AUTH")
        users = db.execute(query_select).fetchall()
        
        # Update each user's password with a hashed version
        for user in users:
            auth_id = user[0]
            plain_password = user[1]
            
            # Hash the password
            hashed_password = hash_password(plain_password)
            
            # Update the user's password in the database
            query_update = text("""
                UPDATE USER_AUTH
                SET password = :password
                WHERE auth_id = :auth_id
            """)
            db.execute(query_update, {"auth_id": auth_id, "password": hashed_password})
        
        # Commit all changes
        db.commit()
        print("All passwords have been hashed successfully.")
    
    except Exception as e:
        db.rollback()
        print(f"An error occurred: {str(e)}")
    
    finally:
        db.close()

if __name__ == "__main__":
    hash_existing_passwords()