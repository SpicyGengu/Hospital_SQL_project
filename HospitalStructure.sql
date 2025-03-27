#CREATE DATABASE HospitalDB;
USE HospitalDB;
SET FOREIGN_KEY_CHECKS = 0;
SET SQL_SAFE_UPDATES = 0;

DROP TABLE IF EXISTS Appointment;
DROP TABLE IF EXISTS Department;
DROP TABLE IF EXISTS Doctor;
DROP TABLE IF EXISTS Hospitalisation;
DROP TABLE IF EXISTS Nurse;
DROP TABLE IF EXISTS Patient;
DROP TABLE IF EXISTS Room;
DROP TABLE IF EXISTS Surgeon;
DROP TABLE IF EXISTS Surgery;
DROP TABLE IF EXISTS Wing;


SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Wing
	(WingName		VARCHAR(15),
    PRIMARY KEY(WingName)
	);
    
    
CREATE TABLE Department
	(DeptName		VARCHAR(15),
    WingName		VARCHAR(15),
    Budget 			INT,
    HeadDoctor		VARCHAR(20) NOT NULL,
    PRIMARY KEY(DeptName),
    FOREIGN KEY(WingName) REFERENCES Wing(WingName)
    
	);
    
CREATE TABLE Room
	(RoomNumber		VARCHAR(15),
    DeptName		VARCHAR(15),
    RoomType		ENUM("Office", "Surgery room", "Ward"),
    Capacity		INT,
    Occupancy		INT,
    PRIMARY KEY(RoomNumber, DeptName),
    FOREIGN KEY(DeptName) REFERENCES Department(DeptName)
	);
    
CREATE TABLE Doctor
	(DoctorID		VARCHAR(15),
    DoctorName		VARCHAR(30),
    DeptName		VARCHAR(15),
    Seniority		YEAR, #maybe date
    RoomNumber		VARCHAR(15),
    Salary			INT,
    PRIMARY KEY(DoctorID),
    FOREIGN KEY(DeptName) REFERENCES Department(DeptName),
    FOREIGN KEY(RoomNumber) REFERENCES Room(RoomNumber)
	);

CREATE TABLE Nurse
	(NurseID		VARCHAR(15),
    NurseName		VARCHAR(30),
    DeptName		VARCHAR(15),
    CanMakeCoffee	BOOL,
    Salary			INT,
    PRIMARY KEY(NurseID),
    FOREIGN KEY(DeptName) REFERENCES Department(DeptName)
	);
    
CREATE TABLE Surgeon
	(DoctorID		VARCHAR(15),
    DeptName		VARCHAR(15),
    Experience		YEAR, #maybe date
    Salary			INT, #Remove?
    Specialisation	VARCHAR(20),
    PRIMARY KEY(DoctorID),
    FOREIGN KEY(DeptName) REFERENCES Department(DeptName),
    FOREIGN KEY(DoctorID) REFERENCES Doctor(DoctorID)
	);
    
CREATE TABLE Patient
	(PatientID		VARCHAR(15),
    PatientName		VARCHAR(30),
    Birthday		DATE,
	DoctorID		VARCHAR(15),
    PhoneNumber		VARCHAR(17), #So North korean people can also be patients
    
    PRIMARY KEY(PatientID),
    FOREIGN KEY(DoctorID) REFERENCES Doctor(DoctorID) ON DELETE SET NULL
    );

CREATE TABLE Appointment
	(PatientID		VARCHAR(15),
    DoctorID		VARCHAR(15),
    StartTime		DATETIME,
    EndTime			DATETIME,
    RoomNumber		VARCHAR(15),
    DeptName		VARCHAR(15),
    PRIMARY KEY(PatientID,StartTime),
    FOREIGN KEY(PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY(DoctorID) REFERENCES Doctor(DoctorID) ON DELETE SET NULL,
    FOREIGN KEY(RoomNumber) REFERENCES Room(RoomNumber) #Do we need to include deptname in the structure?
    );

CREATE TABLE Hospitalisation
	(PatientID		VARCHAR(15),
    StartTime		DATETIME,
    EndTime			DATETIME,
    RoomNumber		VARCHAR(15),
    DeptName 		VARCHAR(15),
    PRIMARY KEY(PatientID, StartTime),
    FOREIGN KEY(PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY(RoomNumber) REFERENCES Room(RoomNumber)
    );

CREATE TABLE Surgery
	(PatientID		VARCHAR(15),
    DoctorID		VARCHAR(15),
    StartTime		DATETIME,
    EndTime			DATETIME,
    RoomNumber		VARCHAR(15),
    DeptName 		VARCHAR(15),
    PRIMARY KEY(PatientID, StartTime),
    FOREIGN KEY(PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY(DoctorID) REFERENCES Doctor(DoctorID) ON DELETE SET NULL
    );
   
DROP FUNCTION IF EXISTS GetTitle; # Function that returns the title of a employee id
DELIMITER //
CREATE FUNCTION GetTitle(vID VARCHAR(15)) RETURNS VARCHAR(15)
BEGIN
    IF 
    vID IN (SELECT NurseID FROM Nurse) THEN RETURN 'Nurse';
    ELSEIF vID IN (SELECT DoctorID FROM Surgeon) THEN RETURN 'Surgeon';
    ELSE RETURN 'Doctor';
    END IF;
END //
DELIMITER ;

DROP VIEW IF EXISTS Personel; 
CREATE VIEW Personel AS 
(SELECT DoctorID,DoctorName AS employeename ,Salary, GetTitle(DoctorID) as Title FROM Doctor 
NATURAL LEFT OUTER JOIN Surgeon) 
UNION 

(SELECT NurseId,NurseName AS employeename,Salary, GetTitle(NurseID) as Title FROM Nurse ) ORDER BY Title ASC, employeename ASC ; 

# Procedure that given a patient id returns their appointment and hospitalization history
DROP PROCEDURE IF EXISTS GetPatientHistory;
CREATE PROCEDURE GetPatientHistory(IN patID VARCHAR(15))
SELECT 'Appointment' AS Type, StartTime, EndTime, RoomNumber
FROM Appointment WHERE PatientID = patID
UNION ALL
SELECT 'Hospitalisation', StartTime, EndTime, RoomNumber
FROM Hospitalisation WHERE PatientID = patID;


# Trigger that listens to insertions on Hospitalization, updates the occupancy on successful insertions and 
DROP TRIGGER IF EXISTS Before_Hospitalisation_Insert;
DELIMITER //

CREATE TRIGGER Before_Hospitalisation_Insert
BEFORE INSERT ON Hospitalisation
FOR EACH ROW
BEGIN
    DECLARE room_capacity INT;
    DECLARE room_occupancy INT;
    DECLARE error_message VARCHAR(255);

    
    -- Get current capacity and occupancy of the room
    SELECT Capacity, Occupancy INTO room_capacity, room_occupancy
    FROM Room
    WHERE RoomNumber = NEW.RoomNumber;
    
    -- Check hospitalization time conditions
    IF NEW.StartTime <= NOW() AND NEW.EndTime > NOW() THEN
        -- Current hospitalization, check room capacity
        IF room_occupancy >= room_capacity THEN
            SET error_message = 'Room ';
            SET error_message = CONCAT(error_message, NEW.RoomNumber, ' is at full capacity (Capacity: ');
            SET error_message = CONCAT(error_message, room_capacity, ', Occupancy: ', room_occupancy, ')');
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = error_message;
        ELSE
            -- Update occupancy count
            UPDATE Room
            SET Occupancy = Occupancy + 1
            WHERE RoomNumber = NEW.RoomNumber;
        END IF;
    END IF;
END //

DELIMITER ;

DELIMITER //
CREATE TRIGGER delete_surgen_after_doctor_delete
BEFORE DELETE ON Doctor
FOR EACH ROW
BEGIN
    DELETE FROM Surgeon WHERE DoctorID = OLD.DoctorID;
    DELETE FROM Appointment WHERE (DoctorID = OLD.DoctorID AND StartTime > NOW());
END//
DELIMITER ;

# Trigger that listens to insertions on Hospitalization, updates the occupancy on successful insertions and 
DROP TRIGGER IF EXISTS Before_Surgery_Insert;
DELIMITER //






CREATE TRIGGER Before_Surgery_Insert
BEFORE INSERT ON Surgery
FOR EACH ROW
BEGIN
    DECLARE room_capacity INT;
    DECLARE room_occupancy INT;
    DECLARE error_message VARCHAR(255);

    
    -- Get current capacity and occupancy of the room
    SELECT Capacity, Occupancy INTO room_capacity, room_occupancy
    FROM Room
    WHERE RoomNumber = NEW.RoomNumber;
    
    -- Check surgery time conditions
    IF NEW.StartTime >= NEW.EndTime THEN 
		SET error_message = 'Invalid Time Period';
        SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = error_message;
	ELSEIF 
		NEW.StartTime <= NOW() AND NEW.EndTime = NULL THEN
        -- Current surgery, check room capacity
        IF room_occupancy >= room_capacity THEN
            SET error_message = 'Room ';
            SET error_message = CONCAT(error_message, NEW.RoomNumber, ' is at full capacity (Capacity: ');
            SET error_message = CONCAT(error_message, room_capacity, ', Occupancy: ', room_occupancy, ')');
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = error_message;
        ELSE
            -- Update occupancy count
            UPDATE Room
            SET Occupancy = Occupancy + 1
            WHERE RoomNumber = NEW.RoomNumber;
        END IF;
    END IF;
END //

DELIMITER ;

#SELECT * FROM Appointment;
#SELECT * FROM Doctor;
DELETE FROM Doctor WHERE Seniority < 2013;
UPDATE Doctor SET Salary =
	CASE 
    WHEN Seniority <= 2017
    THEN Salary + 84000
    ELSE Salary + 36000
    END;

DROP FUNCTION IF EXISTS GetOccupancy;
DELIMITER //

CREATE FUNCTION GetOccupancy (
    RoomNo VARCHAR(15), 
    DName VARCHAR(15), 
    RoomType VARCHAR(15)
) RETURNS INTEGER 
DETERMINISTIC  -- Add this to indicate consistent results
BEGIN
    DECLARE occupancy_count INT;

    IF RoomType = 'Office' THEN 
        SELECT COUNT(*) INTO occupancy_count 
        FROM Doctor 
        WHERE DeptName = DName AND RoomNumber = RoomNo;
    
    ELSEIF RoomType = 'Surgery room' THEN 
        SELECT COUNT(*) INTO occupancy_count 
        FROM Surgery 
        WHERE DeptName = DName AND RoomNumber = RoomNo 
              AND StartTime < NOW() AND EndTime > NOW();
    ELSEIF RoomType = 'Ward' Then
        SELECT COUNT(*) INTO occupancy_count 
        FROM Hospitalisation 
        WHERE DeptName = DName AND RoomNumber = RoomNo 
              AND StartTime < NOW() AND EndTime > NOW();
	ELSE  
          SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = "FAILED TO GET OCCUPANCY";
	END IF;
    RETURN occupancy_count;
 
END//

DELIMITER ;
DELIMITER //
DROP EVENT IF EXISTS RefreshOccupancy;
CREATE EVENT RefreshOccupancy 
ON SCHEDULE EVERY 1 hour
DO 
BEGIN
UPDATE ROOM 
SET Occupancy =GetOccupancy(RoomNumber,DeptName,RoomType);
END//
DELIMITER ;

SELECT D.DoctorName, COUNT(*) AS SurgeryCount
FROM Surgery S
JOIN Doctor D ON S.DoctorID = D.DoctorID
GROUP BY D.DoctorName;

SELECT DeptName, COUNT(*) AS TotalNurses,
SUM(CASE WHEN CanMakeCoffee THEN 1 ELSE 0 END) AS CoffeeMakers
FROM Nurse
GROUP BY DeptName;

SELECT DeptName, SUM(Salary) AS "Total Salaries"
FROM (
    SELECT DeptName, Salary FROM Doctor
    UNION
    SELECT DeptName, Salary FROM Nurse
) AS AllStaff
GROUP BY DeptName
ORDER BY SUM(Salary) DESC;

SELECT (GetOccupancy('701', 'Emergency', 'Ward')) as Occupancy FROM Room;


SELECT RoomNumber, DeptName, RoomType, GetOccupancy(RoomNumber,DeptName,RoomType) AS occupancy FROM Room;
SELECT * FROM ROOM;