-- CREATE A VULNERABLE HR DATABASE

-- Creating Employee Table with Hardcoded Sensitive Data
CREATE TABLE Employees (
    EmployeeID NUMBER PRIMARY KEY,
    FirstName VARCHAR2(50),
    LastName VARCHAR2(50),
    SSN VARCHAR2(11),  -- Storing sensitive data in plaintext (No encryption)
    Salary NUMBER, -- No access control (should be restricted)
    Password VARCHAR2(100), -- Storing passwords in plaintext (Highly insecure)
    Role VARCHAR2(20) -- Should be ENUM-like but is open for modification
);

-- Hardcoded admin user with plaintext password (critical security bug)
INSERT INTO Employees (EmployeeID, FirstName, LastName, SSN, Salary, Password, Role)
VALUES (1, 'Admin', 'User', '123-45-6789', 100000, 'admin123', 'Admin');

-- Creating a table for login attempts (without rate limiting)
CREATE TABLE LoginAttempts (
    AttemptID NUMBER PRIMARY KEY,
    EmployeeID NUMBER,
    AttemptTime TIMESTAMP DEFAULT SYSTIMESTAMP,
    IPAddress VARCHAR2(45), -- No validation (could allow spoofing)
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Giving excessive privileges to public users (Security risk)
GRANT SELECT, INSERT, UPDATE, DELETE ON Employees TO PUBLIC;

-- SQL Injection Vulnerability: Dynamic SQL without Bind Variables
CREATE OR REPLACE PROCEDURE GetEmployeeInfo(empID IN VARCHAR2) 
IS
    empRecord Employees%ROWTYPE;
    sqlQuery VARCHAR2(500);
BEGIN
    -- Constructing SQL Query insecurely (Vulnerable to SQL Injection)
    sqlQuery := 'SELECT * FROM Employees WHERE EmployeeID = ' || empID;
    EXECUTE IMMEDIATE sqlQuery INTO empRecord;
    DBMS_OUTPUT.PUT_LINE('Employee Name: ' || empRecord.FirstName || ' ' || empRecord.LastName);
END;
/

-- Logging failed login attempts (No hashing, easy enumeration attacks)
CREATE OR REPLACE TRIGGER LogFailedLogin
AFTER INSERT ON LoginAttempts
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM LoginAttempts WHERE EmployeeID = :NEW.EmployeeID AND AttemptTime > SYSTIMESTAMP - INTERVAL '10' MINUTE) > 5 THEN
        -- No alerting mechanism, just printing (not effective security monitoring)
        DBMS_OUTPUT.PUT_LINE('Multiple failed login attempts for Employee ID: ' || :NEW.EmployeeID);
    END IF;
END;
/
