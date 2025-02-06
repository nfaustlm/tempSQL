-- Create Employee Table
CREATE TABLE Employees (
    EmployeeID NUMBER PRIMARY KEY,
    FirstName VARCHAR2(50),
    LastName VARCHAR2(50),
    Email VARCHAR2(100) UNIQUE,
    PhoneNumber VARCHAR2(15),
    HireDate DATE,
    JobTitle VARCHAR2(50),
    Salary NUMBER(10,2),
    DepartmentID NUMBER,
    CONSTRAINT fk_department FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

-- Create Departments Table
CREATE TABLE Departments (
    DepartmentID NUMBER PRIMARY KEY,
    DepartmentName VARCHAR2(100) NOT NULL
);

-- Insert sample data into Departments
INSERT INTO Departments VALUES (1, 'HR');
INSERT INTO Departments VALUES (2, 'IT');
INSERT INTO Departments VALUES (3, 'Finance');

-- Insert sample data into Employees
INSERT INTO Employees VALUES (101, 'John', 'Doe', 'johndoe@example.com', '1234567890', TO_DATE('2020-01-15', 'YYYY-MM-DD'), 'Manager', 75000, 1);
INSERT INTO Employees VALUES (102, 'Jane', 'Smith', 'janesmith@example.com', '0987654321', TO_DATE('2019-03-22', 'YYYY-MM-DD'), 'Developer', 80000, 2);
INSERT INTO Employees VALUES (103, 'Alice', 'Brown', 'alicebrown@example.com', '1112223333', TO_DATE('2021-07-18', 'YYYY-MM-DD'), 'Analyst', 65000, 3);

-- Create an index on Employees Email
CREATE INDEX idx_email ON Employees (Email);

-- Create a view for high salary employees
CREATE VIEW HighSalaryEmployees AS
SELECT FirstName, LastName, Salary FROM Employees WHERE Salary > 70000;

-- Create a stored procedure to give a raise
CREATE OR REPLACE PROCEDURE GiveRaise(empID NUMBER, percentage NUMBER) AS
BEGIN
    UPDATE Employees
    SET Salary = Salary + (Salary * percentage / 100)
    WHERE EmployeeID = empID;
    COMMIT;
END;
/

-- Create a trigger to log salary updates
CREATE TABLE SalaryChanges (
    ChangeID NUMBER PRIMARY KEY,
    EmployeeID NUMBER,
    OldSalary NUMBER(10,2),
    NewSalary NUMBER(10,2),
    ChangeDate DATE DEFAULT SYSDATE
);

CREATE OR REPLACE TRIGGER trg_SalaryUpdate
BEFORE UPDATE ON Employees
FOR EACH ROW
BEGIN
    INSERT INTO SalaryChanges (ChangeID, EmployeeID, OldSalary, NewSalary)
    VALUES (seq_SalaryChange.NEXTVAL, :OLD.EmployeeID, :OLD.Salary, :NEW.Salary);
END;
/

-- Query all employees
SELECT * FROM Employees;

-- Query high salary employees from the view
SELECT * FROM HighSalaryEmployees;

-- Update an employee salary
EXEC GiveRaise(102, 10);

-- Query salary changes log
SELECT * FROM SalaryChanges;
