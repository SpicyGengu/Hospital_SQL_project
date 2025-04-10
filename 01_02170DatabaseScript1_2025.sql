DROP DATABASE IF EXISTS HospitalDB;
CREATE DATABASE HospitalDB;
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
    FOREIGN KEY(RoomNumber,DeptName) REFERENCES Room(RoomNumber,DeptName)
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
    FOREIGN KEY(RoomNumber,DeptName) REFERENCES Room(RoomNumber,DeptName)
    );

CREATE TABLE Hospitalisation
	(PatientID		VARCHAR(15),
    StartTime		DATETIME,
    EndTime			DATETIME,
    RoomNumber		VARCHAR(15),
    DeptName 		VARCHAR(15),
    PRIMARY KEY(PatientID, StartTime),
    FOREIGN KEY(PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY(RoomNumber,DeptName) REFERENCES Room(RoomNumber,DeptName)
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
    FOREIGN KEY(DoctorID) REFERENCES Doctor(DoctorID) ON DELETE SET NULL,
    FOREIGN KEY(RoomNumber,DeptName) REFERENCES Room(RoomNumber,DeptName)
    );
    
## POPULATION SCRIPTS ## 

-- Populate Wing
INSERT INTO Wing (WingName) VALUES
('North Wing'),
('South Wing'),
('East Wing'),
('West Wing');

-- Populate Department
INSERT INTO Department (DeptName, WingName, Budget, HeadDoctor) VALUES
('Cardiology', 'North Wing', 500000, 'Dr. Smith'),
('Neurology', 'East Wing', 600000, 'Dr. Johnson'),
('Orthopedics', 'West Wing', 550000, 'Dr. Brown'),
('General Surgery', 'South Wing', 700000, 'Dr. Taylor'),
('Pediatrics', 'North Wing', 450000, 'Dr. Anderson'),
('Dermatology', 'East Wing', 480000, 'Dr. White'),
('Ophthalmology', 'West Wing', 460000, 'Dr. Green'),
('Psychiatry', 'South Wing', 490000, 'Dr. Hall'),
('Emergency', 'South Wing', 700000, 'Dr. H. Sterling');

-- Populate Room
INSERT INTO Room (RoomNumber, DeptName, RoomType, Capacity, Occupancy) VALUES
('101', 'Cardiology', 'Office', 1, 1),
('102', 'Neurology', 'Ward', 4, 0),
('201', 'Neurology', 'Surgery room', 1, 1),
('202', 'Neurology', 'Ward', 6, 0),
('301', 'Orthopedics', 'Office', 1, 1),
('302', 'Orthopedics', 'Ward', 5, 0),
('401', 'General Surgery', 'Surgery room', 1, 1),
('402', 'General Surgery', 'Ward', 4, 0),
('501', 'Pediatrics', 'Ward', 6, 0),
('502', 'Pediatrics', 'Office', 1, 1),
('601', 'Ophthalmology', 'Surgery room', 1, 1),
('602', 'Orthopedics', 'Ward', 4, 0),
('701', 'Emergency', 'Ward', 4, 0),
('702', 'Emergency', 'Ward', 10, 0),
('703', 'Emergency', 'Surgery room', 1,1),
('704', 'Emergency', 'Surgery room', 1,1),
('705', 'Emergency', 'Surgery room', 1,1),
('801', 'Psychiatry', 'Office', 1, 1),
('804', 'Psychiatry', 'Ward', 1, 0),
('104', 'Cardiology', 'Ward', 6, 0),
('106', 'Neurology', 'Office', 1, 0),
('805', 'General Surgery', 'Office', 1, 0),
('606', 'Dermatology', 'Office', 1, 0),
('303', 'Ophthalmology', 'Office', 1, 0),
('404', 'Psychiatry', 'Office', 1, 0);

-- Populate Doctor
INSERT INTO Doctor (DoctorID, DoctorName, DeptName, Seniority, RoomNumber, Salary) VALUES
('D001', 'Alice Kingsley', 'Cardiology', 2015, '101', 120000),
('D002', 'Bob Lancaster', 'Neurology', 2012, '106', 130000),
('D003', 'Charlie Whitmore', 'Orthopedics', 2018, '301', 115000),
('D004', 'David Mercer', 'General Surgery', 2010, '805', 140000),
('D005', 'Emma Harrington', 'Pediatrics', 2017, '502', 125000),
('D006', 'Frank Holloway', 'Dermatology', 2013, '606', 110000),
('D007', 'Grace Wexler', 'Ophthalmology', 2016, '303', 122000),
('D008', 'Henry Sterling', 'Psychiatry', 2009, '801', 135000),
('D009', 'Benry Sterling', 'Psychiatry', 2009, '404', 135000);


-- Populate Nurse
INSERT INTO Nurse (NurseID, NurseName, DeptName, CanMakeCoffee, Salary) VALUES
('N001', 'Amy McDoodle', 'Cardiology', TRUE, 50000),
('N002', 'Betty Thunderpants', 'Neurology', FALSE, 52000),
('N003', 'Clara Wobbleton', 'Orthopedics', TRUE, 51000),
('N004', 'Dana Snickerdoodle', 'General Surgery', FALSE, 53000),
('N005', 'Edward Pickleworth', 'Pediatrics', TRUE, 50500),
('N006', 'Fiona McFluff', 'Dermatology', FALSE, 49500),
('N007', 'George Bumblefizz', 'Ophthalmology', TRUE, 51500),
('N008', 'Hannah VonPumpernickel', 'Psychiatry', FALSE, 52500);

-- Populate Surgeon
INSERT INTO Surgeon (DoctorID, DeptName, Experience, Salary, Specialisation) VALUES
('D001', 'Cardiology', 10, 160000, 'Cardiac Surgery'),
('D002', 'Neurology', 12, 165000, 'Neurosurgery'),
('D003', 'Orthopedics', 9, 158000, 'Bone Surgery'),
('D004', 'General Surgery', 14, 170000, 'General Surgery'),
('D005', 'Pediatrics', 8, 150000, 'Child Surgery'),
('D006', 'Dermatology', 7, 148000, 'Skin Surgery'),
('D007', 'Ophthalmology', 11, 152000, 'Eye Surgery'),
('D008', 'Psychiatry', 15, 175000, 'Neurosurgery');

-- Populate Patient
INSERT INTO Patient (PatientID, PatientName, Birthday, DoctorID, PhoneNumber) VALUES
('P001', 'John Doe', '1985-06-15', 'D001', '+1-555-1234'),
('P002', 'Jane Smith', '1992-08-21', 'D002', '+1-555-5678'),
('P003', 'Robert Johnson', '1978-02-10', 'D003', '+1-555-9012'),
('P004', 'Emily Brown', '1989-11-30', 'D004', '+1-555-3456'),
('P005', 'William Davis', '1990-07-18', 'D005', '+1-555-7890'),
('P006', 'Sophia Wilson', '1983-03-25', 'D006', '+1-555-2345'),
('P007', 'James Martinez', '1975-12-05', 'D007', '+1-555-6789'),
('P008', 'Olivia Taylor', '2001-09-22', 'D008', '+1-555-4321'),
('P009', 'Lucas Bennett', '1991-05-14', 'D001', '+1-555-7812'),
('P010', 'Ella Walker', '1987-09-08', 'D002', '+1-555-3498'),
('P011', 'Daniel Harris', '1995-12-22', 'D003', '+1-555-2374'),
('P012', 'Madison Clark', '1980-07-17', 'D004', '+1-555-6591'),
('P013', 'Joshua Lewis', '1998-03-29', 'D005', '+1-555-4137'),
('P014', 'Ava Robinson', '1979-10-10', 'D006', '+1-555-8923'),
('P015', 'Mason King', '1984-06-19', 'D007', '+1-555-2058'),
('P016', 'Scarlett Adams', '1993-11-02', 'D008', '+1-555-7641'),
('P017', 'Noah White', '1975-04-25', 'D001', '+1-555-1239'),
('P018', 'Mia Scott', '1986-08-14', 'D002', '+1-555-6782'),
('P019', 'James Hall', '1992-01-30', 'D003', '+1-555-9457'),
('P020', 'Chloe Wright', '1981-09-18', 'D004', '+1-555-3216'),
('P021', 'Ethan Green', '1994-05-07', 'D005', '+1-555-8432'),
('P022', 'Sophia Nelson', '1978-12-11', 'D006', '+1-555-6789'),
('P023', 'Benjamin Carter', '1989-02-20', 'D007', '+1-555-2571'),
('P024', 'Lily Mitchell', '1985-07-05', 'D008', '+1-555-4319'),
('P025', 'Alexander Perez', '1997-06-24', 'D001', '+1-555-7523'),
('P026', 'Grace Brown', '1983-03-15', 'D002', '+1-555-9684'),
('P027', 'Jacob Simmons', '1990-10-28', 'D003', '+1-555-3265'),
('P028', 'Emma Diaz', '1982-09-09', 'D004', '+1-555-1987'),
('P029', 'Matthew Reed', '1976-11-23', 'D005', '+1-555-4521'),
('P030', 'Olivia Stewart', '1996-04-13', 'D006', '+1-555-6398');

-- Populate Appointment
INSERT INTO Appointment (PatientID, DoctorID, StartTime, EndTime, RoomNumber, DeptName) VALUES
('P001', 'D001', '2025-04-10 09:00:00', '2025-04-10 09:30:00', '101', 'Cardiology'),
('P002', 'D002', '2025-04-11 10:00:00', '2025-04-11 10:45:00', '106', 'Neurology'),
('P003', 'D003', '2025-04-12 14:00:00', '2025-04-12 14:30:00', '301', 'Orthopedics'),
('P004', 'D004', '2025-04-13 11:00:00', '2025-04-13 11:45:00', '805', 'General Surgery'),
('P005', 'D005', '2025-04-14 08:30:00', '2025-04-14 09:15:00', '502', 'Pediatrics'),
('P006', 'D006', '2025-04-15 12:00:00', '2025-04-15 12:45:00', '606', 'Dermatology'),
('P007', 'D007', '2025-04-16 13:30:00', '2025-04-16 14:15:00', '303', 'Ophthalmology'),
('P008', 'D008', '2025-04-17 15:00:00', '2025-04-17 15:45:00', '801', 'Psychiatry'),
('P011', 'D003', '2025-04-10 09:00:00', '2025-04-10 09:30:00', '301', 'Orthopedics'),
('P011', 'D001', '2025-04-12 10:00:00', '2025-04-12 10:30:00', '101', 'Cardiology'),
('P011', 'D006', '2025-04-14 11:00:00', '2025-04-14 11:30:00', '606', 'Dermatology'),
('P011', 'D004', '2025-04-16 13:00:00', '2025-04-16 13:30:00', '805', 'General Surgery'),
('P011', 'D008', '2025-04-18 14:00:00', '2025-04-18 14:30:00', '404', 'Psychiatry'),
('P011', 'D002', '2025-04-20 15:00:00', '2025-04-20 15:30:00', '106', 'Neurology'),
('P012', 'D005', '2025-04-10 09:00:00', '2025-04-10 09:30:00', '502', 'Pediatrics'),
('P012', 'D001', '2025-04-12 10:00:00', '2025-04-12 10:30:00', '101', 'Cardiology'),
('P012', 'D007', '2025-04-14 11:00:00', '2025-04-14 11:30:00', '303', 'Ophthalmology'),
('P012', 'D003', '2025-04-16 13:00:00', '2025-04-16 13:30:00', '301', 'Orthopedics'),
('P012', 'D004', '2025-04-18 14:00:00', '2025-04-18 14:30:00', '805', 'General Surgery'),
('P012', 'D006', '2025-04-20 15:00:00', '2025-04-20 15:30:00', '606', 'Dermatology'),
('P013', 'D008', '2025-04-11 09:00:00', '2025-04-11 09:30:00', '801', 'Psychiatry'),
('P013', 'D005', '2025-04-13 10:00:00', '2025-04-13 10:30:00', '502', 'Pediatrics'),
('P013', 'D002', '2025-04-15 11:00:00', '2025-04-15 11:30:00', '106', 'Neurology'),
('P013', 'D003', '2025-04-17 12:00:00', '2025-04-17 12:30:00', '301', 'Orthopedics'),
('P013', 'D004', '2025-04-19 13:00:00', '2025-04-19 13:30:00', '805', 'General Surgery'),
('P013', 'D006', '2025-04-21 14:00:00', '2025-04-21 14:30:00', '606', 'Dermatology'),
('P014', 'D003', '2025-04-11 09:00:00', '2025-04-11 09:30:00', '301', 'Orthopedics'),
('P014', 'D001', '2025-04-13 10:00:00', '2025-04-13 10:30:00', '101', 'Cardiology'),
('P014', 'D006', '2025-04-15 11:00:00', '2025-04-15 11:30:00', '606', 'Dermatology'),
('P014', 'D004', '2025-04-17 12:00:00', '2025-04-17 12:30:00', '805', 'General Surgery'),
('P014', 'D008', '2025-04-19 13:00:00', '2025-04-19 13:30:00', '404', 'Psychiatry'),
('P014', 'D002', '2025-04-21 14:00:00', '2025-04-21 14:30:00', '106', 'Neurology'),
('P015', 'D001', '2025-04-12 09:00:00', '2025-04-12 09:30:00', '101', 'Cardiology'),
('P015', 'D003', '2025-04-14 10:00:00', '2025-04-14 10:30:00', '301', 'Orthopedics'),
('P015', 'D002', '2025-04-16 11:00:00', '2025-04-16 11:30:00', '106', 'Neurology'),
('P015', 'D004', '2025-04-18 12:00:00', '2025-04-18 12:30:00', '805', 'General Surgery'),
('P015', 'D005', '2025-04-20 13:00:00', '2025-04-20 13:30:00', '502', 'Pediatrics'),
('P015', 'D006', '2025-04-22 14:00:00', '2025-04-22 14:30:00', '606', 'Dermatology'),
('P016', 'D007', '2025-04-12 09:00:00', '2025-04-12 09:30:00', '303', 'Ophthalmology'),
('P016', 'D003', '2025-04-14 10:00:00', '2025-04-14 10:30:00', '301', 'Orthopedics'),
('P016', 'D002', '2025-04-16 11:00:00', '2025-04-16 11:30:00', '106', 'Neurology'),
('P016', 'D004', '2025-04-18 12:00:00', '2025-04-18 12:30:00', '805', 'General Surgery'),
('P016', 'D005', '2025-04-20 13:00:00', '2025-04-20 13:30:00', '502', 'Pediatrics'),
('P016', 'D006', '2025-04-22 14:00:00', '2025-04-22 14:30:00', '606', 'Dermatology'),
('P017', 'D003', '2025-04-13 09:00:00', '2025-04-13 09:30:00', '301', 'Orthopedics'),
('P017', 'D001', '2025-04-15 10:00:00', '2025-04-15 10:30:00', '101', 'Cardiology'),
('P017', 'D002', '2025-04-17 11:00:00', '2025-04-17 11:30:00', '106', 'Neurology'),
('P017', 'D004', '2025-04-19 12:00:00', '2025-04-19 12:30:00', '805', 'General Surgery'),
('P017', 'D005', '2025-04-21 13:00:00', '2025-04-21 13:30:00', '502', 'Pediatrics'),
('P017', 'D008', '2025-04-23 14:00:00', '2025-04-23 14:30:00', '404', 'Psychiatry'),
('P018', 'D002', '2025-04-12 09:00:00', '2025-04-12 09:30:00', '106', 'Neurology'),
('P018', 'D007', '2025-04-14 10:00:00', '2025-04-14 10:30:00', '303', 'Ophthalmology'),
('P018', 'D003', '2025-04-16 11:00:00', '2025-04-16 11:30:00', '301', 'Orthopedics'),
('P018', 'D004', '2025-04-18 12:00:00', '2025-04-18 12:30:00', '805', 'General Surgery'),
('P018', 'D005', '2025-04-20 13:00:00', '2025-04-20 13:30:00', '502', 'Pediatrics'),
('P018', 'D006', '2025-04-22 14:00:00', '2025-04-22 14:30:00', '606', 'Dermatology'),
('P019', 'D007', '2025-04-11 09:00:00', '2025-04-11 09:30:00', '303', 'Ophthalmology'),
('P019', 'D003', '2025-04-13 10:00:00', '2025-04-13 10:30:00', '301', 'Orthopedics'),
('P019', 'D002', '2025-04-15 11:00:00', '2025-04-15 11:30:00', '106', 'Neurology'),
('P019', 'D004', '2025-04-17 12:00:00', '2025-04-17 12:30:00', '805', 'General Surgery'),
('P019', 'D005', '2025-04-19 13:00:00', '2025-04-19 13:30:00', '502', 'Pediatrics'),
('P019', 'D006', '2025-04-21 14:00:00', '2025-04-21 14:30:00', '606', 'Dermatology'),
('P020', 'D001', '2025-04-12 09:00:00', '2025-04-12 09:30:00', '101', 'Cardiology'),
('P020', 'D003', '2025-04-14 10:00:00', '2025-04-14 10:30:00', '301', 'Orthopedics'),
('P020', 'D002', '2025-04-16 11:00:00', '2025-04-16 11:30:00', '106', 'Neurology'),
('P020', 'D004', '2025-04-18 12:00:00', '2025-04-18 12:30:00', '805', 'General Surgery'),
('P020', 'D005', '2025-04-20 13:00:00', '2025-04-20 13:30:00', '502', 'Pediatrics'),
('P020', 'D006', '2025-04-22 14:00:00', '2025-04-22 14:30:00', '606', 'Dermatology'),
('P021', 'D001', '2025-04-10 09:00:00', '2025-04-10 09:30:00', '101', 'Cardiology'),
('P021', 'D003', '2025-04-12 10:00:00', '2025-04-12 10:30:00', '301', 'Orthopedics'),
('P021', 'D002', '2025-04-14 11:00:00', '2025-04-14 11:30:00', '106', 'Neurology'),
('P021', 'D004', '2025-04-16 12:00:00', '2025-04-16 12:30:00', '805', 'General Surgery'),
('P021', 'D005', '2025-04-18 13:00:00', '2025-04-18 13:30:00', '502', 'Pediatrics'),
('P021', 'D006', '2025-04-20 14:00:00', '2025-04-20 14:30:00', '606', 'Dermatology'),
('P022', 'D007', '2025-04-11 09:00:00', '2025-04-11 09:30:00', '303', 'Ophthalmology'),
('P022', 'D003', '2025-04-13 10:00:00', '2025-04-13 10:30:00', '301', 'Orthopedics'),
('P022', 'D002', '2025-04-15 11:00:00', '2025-04-15 11:30:00', '106', 'Neurology'),
('P022', 'D004', '2025-04-17 12:00:00', '2025-04-17 12:30:00', '805', 'General Surgery'),
('P022', 'D005', '2025-04-19 13:00:00', '2025-04-19 13:30:00', '502', 'Pediatrics'),
('P022', 'D006', '2025-04-21 14:00:00', '2025-04-21 14:30:00', '606', 'Dermatology'),
('P023', 'D001', '2025-04-12 09:00:00', '2025-04-12 09:30:00', '101', 'Cardiology'),
('P023', 'D003', '2025-04-14 10:00:00', '2025-04-14 10:30:00', '301', 'Orthopedics'),
('P023', 'D002', '2025-04-16 11:00:00', '2025-04-16 11:30:00', '106', 'Neurology'),
('P023', 'D004', '2025-04-18 12:00:00', '2025-04-18 12:30:00', '805', 'General Surgery'),
('P023', 'D005', '2025-04-20 13:00:00', '2025-04-20 13:30:00', '502', 'Pediatrics'),
('P023', 'D008', '2025-04-22 14:00:00', '2025-04-22 14:30:00', '801', 'Psychiatry'),
('P024', 'D007', '2025-04-13 09:00:00', '2025-04-13 09:30:00', '303', 'Ophthalmology'),
('P024', 'D003', '2025-04-15 10:00:00', '2025-04-15 10:30:00', '301', 'Orthopedics'),
('P024', 'D002', '2025-04-17 11:00:00', '2025-04-17 11:30:00', '106', 'Neurology'),
('P024', 'D004', '2025-04-19 12:00:00', '2025-04-19 12:30:00', '805', 'General Surgery'),
('P024', 'D005', '2025-04-21 13:00:00', '2025-04-21 13:30:00', '502', 'Pediatrics'),
('P024', 'D006', '2025-04-23 14:00:00', '2025-04-23 14:30:00', '606', 'Dermatology'),
('P025', 'D001', '2025-04-14 09:00:00', '2025-04-14 09:30:00', '101', 'Cardiology'),
('P025', 'D003', '2025-04-16 10:00:00', '2025-04-16 10:30:00', '301', 'Orthopedics'),
('P025', 'D002', '2025-04-18 11:00:00', '2025-04-18 11:30:00', '106', 'Neurology'),
('P025', 'D004', '2025-04-20 12:00:00', '2025-04-20 12:30:00', '805', 'General Surgery'),
('P025', 'D005', '2025-04-22 13:00:00', '2025-04-22 13:30:00', '502', 'Pediatrics'),
('P025', 'D006', '2025-04-24 14:00:00', '2025-04-24 14:30:00', '606', 'Dermatology'),
('P026', 'D007', '2025-04-15 09:00:00', '2025-04-15 09:30:00', '303', 'Ophthalmology'),
('P026', 'D003', '2025-04-17 10:00:00', '2025-04-17 10:30:00', '301', 'Orthopedics'),
('P026', 'D002', '2025-04-19 11:00:00', '2025-04-19 11:30:00', '106', 'Neurology'),
('P026', 'D004', '2025-04-21 12:00:00', '2025-04-21 12:30:00', '805', 'General Surgery'),
('P026', 'D005', '2025-04-23 13:00:00', '2025-04-23 13:30:00', '502', 'Pediatrics'),
('P026', 'D006', '2025-04-25 14:00:00', '2025-04-25 14:30:00', '606', 'Dermatology'),
('P027', 'D001', '2025-04-16 09:00:00', '2025-04-16 09:30:00', '101', 'Cardiology'),
('P027', 'D003', '2025-04-18 10:00:00', '2025-04-18 10:30:00', '301', 'Orthopedics'),
('P027', 'D002', '2025-04-20 11:00:00', '2025-04-20 11:30:00', '106', 'Neurology'),
('P027', 'D004', '2025-04-22 12:00:00', '2025-04-22 12:30:00', '805', 'General Surgery'),
('P027', 'D005', '2025-04-24 13:00:00', '2025-04-24 13:30:00', '502', 'Pediatrics'),
('P027', 'D006', '2025-04-26 14:00:00', '2025-04-26 14:30:00', '606', 'Dermatology'),
('P027', 'D008', '2025-04-17 09:00:00', '2025-04-17 09:30:00', '404', 'Psychiatry'),
('P028', 'D004', '2025-04-18 09:00:00', '2025-04-18 09:30:00', '805', 'General Surgery'),
('P029', 'D003', '2025-04-19 09:00:00', '2025-04-19 09:30:00', '301', 'Orthopedics'),
('P030', 'D007', '2025-04-20 09:00:00', '2025-04-20 09:30:00', '303', 'Ophthalmology');

-- Populate Hospitalisation
INSERT INTO Hospitalisation (PatientID, StartTime, EndTime, RoomNumber,DeptName) VALUES
('P001', '2025-03-01 08:00:00', '2025-03-05 10:00:00', '102','Neurology'),
('P002', '2025-03-06 12:00:00', '2025-03-10 14:00:00', '202','Neurology'),
('P003', '2025-03-11 16:00:00', '2025-03-15 18:00:00', '302','Orthopedics'),
('P004', '2025-03-16 09:00:00', '2025-03-20 11:00:00', '402','General Surgery'),
('P005', '2025-03-21 10:00:00', '2025-03-25 12:00:00', '102','Neurology'),
('P006', '2025-03-26 13:00:00', '2025-03-30 15:00:00', '202','Neurology'),
('P007', '2025-04-01 16:00:00', '2025-04-05 18:00:00', '302','Orthopedics'),
('P008', '2025-04-06 08:00:00', '2025-04-10 10:00:00', '402','General Surgery'),
('P018', '2025-04-11 09:00:00', '2025-04-15 11:00:00', '501','Pediatrics'),
('P005', '2025-04-16 14:00:00', '2025-04-20 16:00:00', '702','Emergency'),
('P014', '2025-04-21 08:00:00', '2025-04-25 10:00:00', '702','Emergency'),
('P022', '2025-04-26 12:00:00', '2025-04-30 14:00:00', '104','Cardiology'),
('P007', '2025-05-01 10:00:00', '2025-05-05 12:00:00', '104','Cardiology'),
('P019', '2025-05-06 16:00:00', '2025-05-10 18:00:00', '702','Emergency'),
('P002', '2025-05-11 09:00:00', '2025-05-15 11:00:00', '701','Emergency'),
('P011', '2025-05-16 08:00:00', '2025-05-20 10:00:00', '602','Orthopedics'),
('P026', '2025-05-21 13:00:00', '2025-05-25 15:00:00', '701','Emergency'),
('P008', '2025-05-26 14:00:00', '2025-05-30 16:00:00', '702','Emergency'),
('P030', '2025-06-01 10:00:00', '2025-06-05 12:00:00', '702','Emergency'),
('P012', '2025-06-06 16:00:00', '2025-06-10 18:00:00', '804','Psychiatry'),
('P017', '2025-06-11 09:00:00', '2025-06-15 11:00:00', '104','Cardiology'),
('P024', '2025-06-16 08:00:00', '2025-06-20 10:00:00', '501','Pediatrics');



-- Populate surgery
INSERT INTO Surgery (PatientID, DoctorID, StartTime,Endtime,RoomNumber,DeptName) VALUES
('P001', 'D001', '2025-03-01 09:00:00','2025-03-01 09:00:32','705','Emergency'),
('P003', 'D003', '2025-03-12 10:00:00','2025-03-12 17:00:27','705','Emergency'),
('P004', 'D004', '2025-03-17 14:00:00','2025-03-17 18:00:00','703','Emergency'),
('P006', 'D006', '2025-03-27 11:00:00','2025-03-27 18:00:00','201','Neurology'), 
('P007', 'D007', '2025-04-02 09:00:00','2025-04-02 14:00:0','601','Ophthalmology'), 
('P008', 'D008', '2025-04-07 10:30:00',null,'401','General Surgery'),
('P009', 'D002', '2025-04-15 13:00:00',null,'705','Emergency'),
('P011', 'D005', '2025-04-20 09:30:00',null,'401','General Surgery'),
('P013', 'D003', '2025-04-25 15:00:00','2025-04-25 17:00:00','703','Emergency'),
('P015', 'D004', '2025-05-02 11:45:00','2025-05-02 19:15:00','705','Emergency'),
('P017', 'D006', '2025-05-08 08:30:00','2025-05-08 15:00:30','201','Neurology'),
('P019', 'D007', '2025-05-12 10:15:00','2025-05-12 21:40:00','601','Ophthalmology'),
('P021', 'D001', '2025-05-18 14:45:00','2025-05-18 21:40:00','401','General Surgery'),
('P023', 'D002', '2025-05-25 09:00:00','2025-05-26 09:00:00','703','Emergency'),
('P025', 'D008', '2025-06-01 16:00:00','2025-06-01 20:00:00','201','Neurology');


