-- ===========================================================
-- REAL ESTATE SKILLED WORKERS MARKETPLACE
-- Complete SQL Schema + Triggers + Procedures + Roles
-- Team: Aditya D Rao (PES2UG23CS031), Abhilash S Y (PES2UG23CS018)
-- ===========================================================

CREATE DATABASE IF NOT EXISTS Realestate;
USE Realestate;

CREATE TABLE Customer (
    Cust_Id     INT PRIMARY KEY,
    Name        VARCHAR(100) NOT NULL,
    Phone       VARCHAR(15) UNIQUE NOT NULL,
    Email       VARCHAR(100) UNIQUE NOT NULL,
    City        VARCHAR(50) NOT NULL,
    State       VARCHAR(50) NOT NULL,
    PINCODE     VARCHAR(10) NOT NULL
);

CREATE TABLE Workers (
    W_Id        INT PRIMARY KEY,
    Name        VARCHAR(100) NOT NULL,
    Phone       VARCHAR(15) UNIQUE NOT NULL,
    Email       VARCHAR(100) UNIQUE NOT NULL,
    State       VARCHAR(50) NOT NULL,
    PINCODE     VARCHAR(10) NOT NULL
);

CREATE TABLE Job (
    Job_Id      INT PRIMARY KEY,
    Title       VARCHAR(100) NOT NULL,
    Description TEXT,
    Status      ENUM('Open','Closed','Ongoing') DEFAULT 'Open',
    Cust_Id     INT,
    FOREIGN KEY (Cust_Id) REFERENCES Customer(Cust_Id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE Bids (
    Bid_Id      INT PRIMARY KEY,
    Amount      DECIMAL(12,2) NOT NULL,
    Date        DATE NOT NULL DEFAULT (CURDATE()),
    Job_Id      INT NOT NULL,
    FOREIGN KEY (Job_Id) REFERENCES Job(Job_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE Contract (
    Co_Id       INT PRIMARY KEY AUTO_INCREMENT,
    Start_date  DATE NOT NULL,
    End_date    DATE,
    Status      ENUM('Active','Completed','Cancelled') DEFAULT 'Active',
    Cust_Id     INT,
    Job_Id      INT,
    FOREIGN KEY (Cust_Id) REFERENCES Customer(Cust_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (Job_Id) REFERENCES Job(Job_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Payment (
    P_Id        INT PRIMARY KEY,
    Amount      DECIMAL(12,2) NOT NULL,
    Date        DATE NOT NULL DEFAULT (CURDATE()),
    Status      ENUM('Pending','Completed') DEFAULT 'Pending',
    Co_Id       INT,
    FOREIGN KEY (Co_Id) REFERENCES Contract(Co_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Location (
    L_Id        INT,
    Job_Id      INT,
    Street      VARCHAR(100) NOT NULL,
    City        VARCHAR(50) NOT NULL,
    State       VARCHAR(50) NOT NULL,
    PINCODE     VARCHAR(10) NOT NULL,
    PRIMARY KEY (L_Id, Job_Id),
    FOREIGN KEY (Job_Id) REFERENCES Job(Job_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Ratings (
    R_Id        INT PRIMARY KEY,
    Score       INT NOT NULL,
    Date        DATE NOT NULL DEFAULT (CURDATE()),
    Cust_Id     INT,
    W_Id        INT,
    Job_Id      INT,
    FOREIGN KEY (Cust_Id) REFERENCES Customer(Cust_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (W_Id) REFERENCES Workers(W_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (Job_Id) REFERENCES Job(Job_Id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CHECK (Score BETWEEN 1 AND 10)
);

-- ===========================
-- M:N Relationship Tables
-- ===========================
CREATE TABLE CustomerJob (
    Cust_Id INT,
    Job_Id  INT,
    Role    VARCHAR(50) NOT NULL,
    PRIMARY KEY (Cust_Id, Job_Id),
    FOREIGN KEY (Cust_Id) REFERENCES Customer(Cust_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (Job_Id) REFERENCES Job(Job_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE WorkerJob (
    W_Id    INT,
    Job_Id  INT,
    PRIMARY KEY (W_Id, Job_Id),
    FOREIGN KEY (W_Id) REFERENCES Workers(W_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (Job_Id) REFERENCES Job(Job_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE WorkerBid (
    W_Id    INT,
    Bid_Id  INT,
    PRIMARY KEY (W_Id, Bid_Id),
    FOREIGN KEY (W_Id) REFERENCES Workers(W_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (Bid_Id) REFERENCES Bids(Bid_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE WorkerContract (
    W_Id    INT,
    Co_Id   INT,
    PRIMARY KEY (W_Id, Co_Id),
    FOREIGN KEY (W_Id) REFERENCES Workers(W_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (Co_Id) REFERENCES Contract(Co_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE CustomerRatings (
    Cust_Id INT,
    R_Id    INT,
    PRIMARY KEY (Cust_Id, R_Id),
    FOREIGN KEY (Cust_Id) REFERENCES Customer(Cust_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (R_Id) REFERENCES Ratings(R_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ===========================
-- Sample Data
-- ===========================
INSERT INTO Customer VALUES 
(1, 'Ravi Kumar', '9876543210', 'ravi@example.com', 'Bangalore', 'Karnataka', '560001'),
(2, 'Sneha R', '9123456780', 'sneha@example.com', 'Mysore', 'Karnataka', '570001'),
(3, 'Arjun M', '9012345678', 'arjun@example.com', 'Chennai', 'Tamil Nadu', '600001'),
(4, 'Meena S', '9345678901', 'meena@example.com', 'Hyderabad', 'Telangana', '500001'),
(5, 'Vikas P', '9456789012', 'vikas@example.com', 'Delhi', 'Delhi', '110001');

INSERT INTO Workers VALUES 
(1, 'Ramesh W', '7890123456', 'ramesh@example.com', 'Karnataka', '560002'),
(2, 'Suresh W', '7980123456', 'suresh@example.com', 'Karnataka', '560003'),
(3, 'Anil W', '7990123456', 'anil@example.com', 'Tamil Nadu', '600002'),
(4, 'Deepak W', '7001234567', 'deepak@example.com', 'Telangana', '500002'),
(5, 'Venu W', '7111234567', 'venu@example.com', 'Delhi', '110002');

INSERT INTO Job VALUES
(101, 'Painting Work', 'House painting required', 'Open', 1),
(102, 'Plumbing Work', 'Bathroom pipe leakage fix', 'Open', 2),
(103, 'Electric Wiring', 'Rewiring full house', 'Ongoing', 3),
(104, 'Carpentry Work', 'Furniture fixing', 'Closed', 4),
(105, 'Roofing Work', 'Tile roof replacement', 'Open', 5);

INSERT INTO Bids VALUES
(1001, 5000, '2025-09-01', 101),
(1002, 15000, '2025-09-02', 102),
(1003, 8000, '2025-09-03', 103),
(1004, 12000, '2025-09-04', 104),
(1005, 6000, '2025-09-05', 105);

-- Insert sample contracts (explicit Co_Id values are allowed even with AUTO_INCREMENT)
INSERT INTO Contract (Co_Id, Start_date, End_date, Status, Cust_Id, Job_Id) VALUES
(201, '2025-09-01', '2025-09-10', 'Active', 1, 101),
(202, '2025-09-02', '2025-09-12', 'Completed', 2, 102),
(203, '2025-09-03', '2025-09-15', 'Active', 3, 103),
(204, '2025-09-04', '2025-09-14', 'Cancelled', 4, 104),
(205, '2025-09-05', '2025-09-20', 'Active', 5, 105);

INSERT INTO Payment VALUES
(301, 5000, '2025-09-02', 'Completed', 201),
(302, 15000, '2025-09-03', 'Pending', 202),
(303, 8000, '2025-09-04', 'Completed', 203),
(304, 12000, '2025-09-05', 'Pending', 204),
(305, 6000, '2025-09-06', 'Completed', 205);

INSERT INTO Location VALUES
(401, 101, 'MG Road', 'Bangalore', 'Karnataka', '560001'),
(402, 102, 'VV Mohalla', 'Mysore', 'Karnataka', '570001'),
(403, 103, 'Anna Nagar', 'Chennai', 'Tamil Nadu', '600001'),
(404, 104, 'Banjara Hills', 'Hyderabad', 'Telangana', '500001'),
(405, 105, 'Karol Bagh', 'Delhi', 'Delhi', '110001');

INSERT INTO Ratings VALUES
(501, 5, '2025-09-02', 1, 1, 101),
(502, 4, '2025-09-03', 2, 2, 102),
(503, 3, '2025-09-04', 3, 3, 103),
(504, 5, '2025-09-05', 4, 4, 104),
(505, 4, '2025-09-06', 5, 5, 105);

-- Map workers to existing contracts so GetWorkerEarnings can show non-zero values for sample data
INSERT INTO WorkerContract (W_Id, Co_Id) VALUES
(1, 201),
(2, 202),
(3, 203),
(4, 204),
(5, 205);

-- Ensure next AUTO_INCREMENT value is after existing sample data (next will be 206)
ALTER TABLE Contract AUTO_INCREMENT = 206;

-- ===========================
-- TRIGGERS
-- ===========================
DELIMITER //
CREATE TRIGGER trg_after_contract_insert
AFTER INSERT ON Contract
FOR EACH ROW
BEGIN
    UPDATE Job
    SET Status = 'Ongoing'
    WHERE Job_Id = NEW.Job_Id;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_before_payment_insert
BEFORE INSERT ON Payment
FOR EACH ROW
BEGIN
    DECLARE cnt INT;
    SELECT COUNT(*) INTO cnt FROM Contract WHERE Co_Id = NEW.Co_Id;
    IF cnt = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid Contract Id for Payment';
    END IF;
    IF NEW.Amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment amount must be positive';
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_after_payment_update
AFTER UPDATE ON Payment
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Completed' AND OLD.Status <> 'Completed' THEN
        UPDATE Contract
        SET Status = 'Completed'
        WHERE Co_Id = NEW.Co_Id;
    END IF;
END;
//
DELIMITER ;

CREATE TABLE IF NOT EXISTS ContractAudit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    co_id INT,
    action VARCHAR(20),
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    action_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER trg_contract_update_audit
AFTER UPDATE ON Contract
FOR EACH ROW
BEGIN
    INSERT INTO ContractAudit (co_id, action, old_status, new_status)
    VALUES (OLD.Co_Id, 'UPDATE', OLD.Status, NEW.Status);
END;
//
DELIMITER ;

-- ===========================
-- STORED PROCEDURES
-- ===========================
DELIMITER //
CREATE PROCEDURE GetWorkerEarnings(IN wid INT)
BEGIN
    SELECT W.W_Id, W.Name, COALESCE(SUM(P.Amount),0) AS Total_Earnings
    FROM Workers W
    LEFT JOIN WorkerContract WC ON W.W_Id = WC.W_Id -- Join Query
    LEFT JOIN Payment P ON WC.Co_Id = P.Co_Id AND P.Status = 'Completed'
    WHERE W.W_Id = wid
    GROUP BY W.W_Id, W.Name;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE GetOpenJobsByCity(IN cityName VARCHAR(100))
BEGIN
    SELECT J.Job_Id, J.Title, J.Description, L.City, J.Status
    FROM Job J
    JOIN Location L ON J.Job_Id = L.Job_Id
    WHERE J.Status = 'Open' AND L.City = cityName;
END;
//
DELIMITER ;

-- 
DELIMITER //
DROP PROCEDURE IF EXISTS CreateContractFromBid;
//
CREATE PROCEDURE CreateContractFromBid(
    IN in_bid_id INT,
    IN in_wid INT,
    IN in_start DATE,
    IN in_end DATE
)
BEGIN
    DECLARE theJob INT;
    DECLARE theCust INT;
    DECLARE theAmount DECIMAL(12,2);
    DECLARE new_co INT;

    SELECT Job_Id, Amount INTO theJob, theAmount FROM Bids WHERE Bid_Id = in_bid_id;
    IF theJob IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid Bid_Id';
    END IF;

    SELECT Cust_Id INTO theCust FROM Job WHERE Job_Id = theJob;

    -- Nested 
    INSERT INTO Contract (Start_date, End_date, Status, Cust_Id, Job_Id)
    VALUES (in_start, in_end, 'Active', theCust, theJob);

    
    SET new_co = LAST_INSERT_ID();

    INSERT INTO WorkerContract (W_Id, Co_Id) VALUES (in_wid, new_co);

    UPDATE Job SET Status = 'Ongoing' WHERE Job_Id = theJob;

    
    SELECT new_co AS NewCoId;
END;
//
DELIMITER ;

-- ===========================
-- FUNCTIONS
-- ===========================
DELIMITER //
CREATE FUNCTION avg_rating(worker_id INT)
RETURNS DECIMAL(3,2)
DETERMINISTIC
BEGIN
    DECLARE avg_r DECIMAL(3,2);
    -- AGGREGATE QUERY
    SELECT IFNULL(ROUND(AVG(Score),2),0) INTO avg_r FROM Ratings WHERE W_Id = worker_id;
    
    RETURN avg_r;
END;
//
DELIMITER ;

DELIMITER //
CREATE FUNCTION total_bids(jobid INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE cnt INT;
    -- AGGREGATE QUERY
    SELECT COUNT(*) INTO cnt FROM Bids WHERE Job_Id = jobid;
    RETURN cnt;
END;
//
DELIMITER ;

-- ===========================
-- USER ROLES AND ACCOUNTS
-- ===========================
CREATE ROLE IF NOT EXISTS admin_role;
GRANT ALL PRIVILEGES ON Realestate.* TO admin_role;
CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY 'admin123';
GRANT admin_role TO 'admin'@'localhost';
SET DEFAULT ROLE admin_role TO 'admin'@'localhost';

CREATE ROLE IF NOT EXISTS user_role;
GRANT SELECT ON Realestate.* TO user_role;
CREATE USER IF NOT EXISTS 'user'@'localhost' IDENTIFIED BY 'user123';
GRANT user_role TO 'user'@'localhost';
SET DEFAULT ROLE user_role TO 'user'@'localhost';

FLUSH PRIVILEGES;
