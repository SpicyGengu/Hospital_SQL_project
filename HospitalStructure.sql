#CREATE DATABASE HospitalDB;
USE HospitalDB;
SET FOREIGN_KEY_CHECKS = 0;

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
    FOREIGN KEY(DoctorID) REFERENCES Doctor(DoctorID)
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
    FOREIGN KEY(DoctorID) REFERENCES Doctor(DoctorID),
    FOREIGN KEY(RoomNumber) REFERENCES Room(RoomNumber) #Do we need to include deptname in the structure?
    );

CREATE TABLE Hospitalisation
	(PatientID		VARCHAR(15),
    StartTime		DATETIME,
    EndTime			DATETIME,
    RoomNumber		VARCHAR(15),
    PRIMARY KEY(PatientID, StartTime),
    FOREIGN KEY(PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY(RoomNumber) REFERENCES Room(RoomNumber)
    );

CREATE TABLE Surgery
	(PatientID		VARCHAR(15),
    DoctorID		VARCHAR(15),
    StartTime		DATETIME,
    PRIMARY KEY(PatientID, StartTime),
    FOREIGN KEY(PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY(DoctorID) REFERENCES Doctor(DoctorID)
    );
   
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

DROP VIEW IF EXISTS Personel; 
CREATE VIEW Personel AS 
(SELECT DoctorID,DoctorName AS employeename ,Salary, GetTitle(DoctorID) as Title FROM Doctor 
NATURAL LEFT OUTER JOIN Surgeon) 
UNION 
(SELECT NurseId,NurseName AS employeename,Salary, GetTitle(NurseID) as Title FROM Nurse ) ORDER BY Title ASC, employeename ASC ; 
    