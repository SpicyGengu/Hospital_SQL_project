USE HospitalDB;
## START DATA QUERIES ##

# Query 1
SELECT D.DoctorName, COUNT(*) AS SurgeryCount
FROM Surgery S
JOIN Doctor D ON S.DoctorID = D.DoctorID
GROUP BY D.DoctorName;

# Query 2
SELECT DeptName, COUNT(*) AS TotalNurses,
SUM(CASE WHEN CanMakeCoffee THEN 1 ELSE 0 END) AS CoffeeMakers
FROM Nurse
GROUP BY DeptName;

# Query 3
SELECT DeptName, SUM(Salary) AS "Total Salaries"
FROM (
SELECT DeptName, Salary FROM Doctor
UNION
SELECT DeptName, Salary FROM Nurse
) AS AllStaff
GROUP BY DeptName
ORDER BY SUM(Salary) DESC;

## END DATA QUERIES ##

## START FUNCTIONS, PROCEDURES, TRIGGERS & EVENTS ##

# Function that returns the title of a employee id
DROP FUNCTION IF EXISTS GetTitle; 
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


# Personel View
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

DELETE TRIGGER IF EXISTS delete_surgeon_after_doctor_delete
DELIMITER //
CREATE TRIGGER delete_surgeon_after_doctor_delete
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

# Function that gets occupancy for all rooms
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
DROP EVENT IF EXISTS RefreshOccupancy;
DELIMITER //
CREATE EVENT RefreshOccupancy 
ON SCHEDULE EVERY 1 hour
DO 
BEGIN
UPDATE ROOM 
SET Occupancy =GetOccupancy(RoomNumber,DeptName,RoomType);
END//
DELIMITER ;
## END FUNCTIONS, PROCEDURES, TRIGGERS & EVENTS ##

## START UPDATE / DELETE STATEMENTS ##

DELETE FROM Doctor WHERE Seniority < 2013;
UPDATE Doctor SET Salary =
	CASE 
    WHEN Seniority <= 2017
    THEN Salary + 84000
    ELSE Salary + 36000
    END;
## END UPDATE / DELETE STATEMENTS ##