
USE DMDD_Group10
GO
----------------------------------------------encryption_script.sql:
-- Example column-level encryption for MEMBER.phone and MEMBER.email using a symmetric key approach in SQL Server.

-- Add encrypted columns for phone and email if they don't already exist
ALTER TABLE MEMBER
ADD phone_encrypted VARBINARY(256) NULL,
    email_encrypted VARBINARY(256) NULL;
GO


-- Create a Master Key (only once per database)
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'YourStrongPassword123!';
GO

-- Create a Certificate for encryption purposes
CREATE CERTIFICATE Cert_DMDD_Group10
WITH SUBJECT = 'Certificate for sensitive data encryption';
GO

-- Create a Symmetric Key protected by the certificate
CREATE SYMMETRIC KEY SymKey_DMDD_Group10
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE Cert_DMDD_Group10;
GO


-- Open the symmetric key to perform encryption
OPEN SYMMETRIC KEY SymKey_DMDD_Group10
DECRYPTION BY CERTIFICATE Cert_DMDD_Group10;

-- Update the table to encrypt the phone and email columns.
UPDATE MEMBER
SET 
    phone_encrypted = ENCRYPTBYKEY(KEY_GUID('SymKey_DMDD_Group10'), phone),
    email_encrypted = ENCRYPTBYKEY(KEY_GUID('SymKey_DMDD_Group10'), email);
    
CLOSE SYMMETRIC KEY SymKey_DMDD_Group10;
GO


-- Drop original columns
ALTER TABLE MEMBER
DROP COLUMN phone, email;
GO

-- Rename encrypted columns to original names
EXEC sp_rename 'MEMBER.phone_encrypted', 'phone', 'COLUMN';
EXEC sp_rename 'MEMBER.email_encrypted', 'email', 'COLUMN';
GO


-- Open the symmetric key for decryption

OPEN SYMMETRIC KEY SymKey_DMDD_Group10
DECRYPTION BY CERTIFICATE Cert_DMDD_Group10;

SELECT 
    member_id,
    CONVERT(VARCHAR(20), DECRYPTBYKEY(phone)) AS DecryptedPhone,
    CONVERT(VARCHAR(100), DECRYPTBYKEY(email)) AS DecryptedEmail
FROM MEMBER;

CLOSE SYMMETRIC KEY SymKey_DMDD_Group10;
GO

