USE HospitalDB;

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
('Psychiatry', 'South Wing', 490000, 'Dr. Hall');

-- Populate Room
INSERT INTO Room (RoomNumber, DeptName, RoomType, Capacity, Occupancy) VALUES
('101', 'Cardiology', 'Office', 1, 1),
('102', 'Cardiology', 'Ward', 4, 2),
('201', 'Neurology', 'Surgery room', 1, 1),
('202', 'Neurology', 'Ward', 3, 2),
('301', 'Orthopedics', 'Office', 1, 1),
('302', 'Orthopedics', 'Ward', 5, 3),
('401', 'General Surgery', 'Surgery room', 1, 1),
('402', 'General Surgery', 'Ward', 4, 2);

-- Populate Doctor
INSERT INTO Doctor (DoctorID, DoctorName, DeptName, Seniority, RoomNumber, Salary) VALUES
('D001', 'Alice Kingsley', 'Cardiology', 2015, '101', 120000),
('D002', 'Bob Lancaster', 'Neurology', 2012, '201', 130000),
('D003', 'Charlie Whitmore', 'Orthopedics', 2018, '301', 115000),
('D004', 'David Mercer', 'General Surgery', 2010, '401', 140000),
('D005', 'Emma Harrington', 'Pediatrics', 2017, '101', 125000),
('D006', 'Frank Holloway', 'Dermatology', 2013, '201', 110000),
('D007', 'Grace Wexler', 'Ophthalmology', 2016, '301', 122000),
('D008', 'Henry Sterling', 'Psychiatry', 2009, '401', 135000),
('D009', 'Benry Sterling', 'Psychiatry', 2009, '401', 135000);


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
('P008', 'Olivia Taylor', '2001-09-22', 'D008', '+1-555-4321');

-- Populate Appointment
INSERT INTO Appointment (PatientID, DoctorID, StartTime, EndTime, RoomNumber, DeptName) VALUES
('P001', 'D001', '2025-04-10 09:00:00', '2025-04-10 09:30:00', '101', 'Cardiology'),
('P002', 'D002', '2025-04-11 10:00:00', '2025-04-11 10:45:00', '201', 'Neurology'),
('P003', 'D003', '2025-04-12 14:00:00', '2025-04-12 14:30:00', '301', 'Orthopedics'),
('P004', 'D004', '2025-04-13 11:00:00', '2025-04-13 11:45:00', '401', 'General Surgery'),
('P005', 'D005', '2025-04-14 08:30:00', '2025-04-14 09:15:00', '101', 'Pediatrics'),
('P006', 'D006', '2025-04-15 12:00:00', '2025-04-15 12:45:00', '201', 'Dermatology'),
('P007', 'D007', '2025-04-16 13:30:00', '2025-04-16 14:15:00', '301', 'Ophthalmology'),
('P008', 'D008', '2025-04-17 15:00:00', '2025-04-17 15:45:00', '401', 'Psychiatry');

-- Populate Hospitalisation
INSERT INTO Hospitalisation (PatientID, StartTime, EndTime, RoomNumber) VALUES
('P001', '2025-03-01 08:00:00', '2025-03-05 10:00:00', '102'),
('P002', '2025-03-06 12:00:00', '2025-03-10 14:00:00', '202'),
('P003', '2025-03-11 16:00:00', '2025-03-15 18:00:00', '302'),
('P004', '2025-03-16 09:00:00', '2025-03-20 11:00:00', '402'),
('P005', '2025-03-21 10:00:00', '2025-03-25 12:00:00', '102'),
('P006', '2025-03-26 13:00:00', '2025-03-30 15:00:00', '202'),
('P007', '2025-04-01 16:00:00', '2025-04-05 18:00:00', '302'),
('P008', '2025-04-06 08:00:00', '2025-04-10 10:00:00', '402');
