CREATE DATABASE IF NOT EXISTS scms_db;
USE scms_db;

-- =========================================
-- 1. BASE SYSTEM & USER TABLES
-- =========================================

CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255) NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(120) NOT NULL UNIQUE,
    department_code VARCHAR(20) NOT NULL UNIQUE,
    department_email VARCHAR(150) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    department_id INT NULL,
    username VARCHAR(150) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    student_code VARCHAR(50) NULL UNIQUE,
    is_staff BOOLEAN DEFAULT FALSE,
    is_superuser BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    default_department_id INT NULL,
    description VARCHAR(255) NULL,
    is_active BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE subcategories (
    subcategory_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    subcategory_name VARCHAR(120) NOT NULL,
    description VARCHAR(255) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE (category_id, subcategory_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================
-- 2. CORE COMPLAINT TABLES
-- =========================================

CREATE TABLE complaints (
    complaint_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    language ENUM('EN','AR','MIXED') NOT NULL DEFAULT 'EN',
    final_category_id INT NULL,
    final_subcategory_id INT NULL,
    final_department_id INT NULL,
    priority ENUM('LOW','MEDIUM','HIGH','URGENT') DEFAULT 'MEDIUM',
    status ENUM('SUBMITTED','UNDER_REVIEW','ASSIGNED','IN_PROGRESS','RESOLVED','CLOSED','REOPENED') DEFAULT 'SUBMITTED',
    visibility ENUM('PUBLIC_FORUM','PRIVATE_TICKET') DEFAULT 'PRIVATE_TICKET',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    resolved_at DATETIME NULL,
    closed_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE complaint_attachments (
    attachment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    complaint_id BIGINT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    mime_type VARCHAR(100) NULL,
    file_size_bytes BIGINT NULL,
    uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE complaint_assignments (
    assignment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    complaint_id BIGINT NOT NULL,
    department_id INT NOT NULL,
    staff_id INT NULL,
    assigned_by INT NOT NULL,
    assigned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    unassigned_at DATETIME NULL,
    assignment_note VARCHAR(500) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE complaint_status_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    complaint_id BIGINT NOT NULL,
    old_status VARCHAR(30) NULL,
    new_status VARCHAR(30) NOT NULL,
    changed_by INT NOT NULL,
    change_note VARCHAR(500) NULL,
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE complaint_responses (
    response_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    complaint_id BIGINT NOT NULL,
    responder_id INT NOT NULL,
    response_text TEXT NOT NULL,
    is_internal_note BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE complaint_feedback (
    feedback_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    complaint_id BIGINT NOT NULL UNIQUE,
    student_id INT NOT NULL,
    rating TINYINT NOT NULL,
    comment TEXT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE complaint_upvotes (
    upvote_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    complaint_id BIGINT NOT NULL,
    user_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_complaint_upvote (complaint_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================
-- 3. AI, ANALYTICS & SYSTEM TABLES
-- =========================================

CREATE TABLE ai_predictions (
    prediction_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    complaint_id BIGINT NOT NULL,
    model_version VARCHAR(80) NOT NULL,
    predicted_category_id INT NULL,
    category_confidence DECIMAL(5,4) NULL,
    predicted_priority ENUM('LOW','MEDIUM','HIGH','URGENT') NULL,
    priority_confidence DECIMAL(5,4) NULL,
    suggested_department_id INT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE complaint_similarity (
    similarity_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    complaint_id BIGINT NOT NULL,
    similar_complaint_id BIGINT NOT NULL,
    similarity_score DECIMAL(5,4) NOT NULL,
    model_version VARCHAR(80) NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE dataset_annotations (
    annotation_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    complaint_id BIGINT NOT NULL,
    annotator_id INT NOT NULL,
    category_id INT NULL,
    subcategory_id INT NULL,
    priority ENUM('LOW','MEDIUM','HIGH','URGENT') NULL,
    department_id INT NULL,
    annotation_status ENUM('PENDING','AGREED','CONFLICT','VERIFIED') DEFAULT 'PENDING', 
    notes VARCHAR(500) NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE notifications (
    notification_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    complaint_id BIGINT NULL,
    notification_type VARCHAR(50) NOT NULL,
    message VARCHAR(500) NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    read_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE audit_logs (
    audit_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(60) NOT NULL,
    entity_id VARCHAR(60) NULL,
    details TEXT NULL,
    ip_address VARCHAR(45) NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================
-- 4. FOREIGN KEYS (ON UPDATE CASCADE everywhere it is allowed)
-- =========================================

-- Users Table
ALTER TABLE users
    ADD CONSTRAINT fk_users_role
        FOREIGN KEY (role_id)
        REFERENCES roles (role_id)
        ON UPDATE CASCADE,
    ADD CONSTRAINT fk_users_department
        FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL;

-- Categories Table
ALTER TABLE categories
    ADD CONSTRAINT fk_categories_department
        FOREIGN KEY (default_department_id)
        REFERENCES departments (department_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL;

-- Subcategories Table
ALTER TABLE subcategories
    ADD CONSTRAINT fk_subcategories_category
        FOREIGN KEY (category_id)
        REFERENCES categories (category_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE;

-- Complaints Table
ALTER TABLE complaints
    ADD CONSTRAINT fk_complaints_student
        FOREIGN KEY (student_id)
        REFERENCES users (user_id)
        ON UPDATE CASCADE,
    ADD CONSTRAINT fk_complaints_category
        FOREIGN KEY (final_category_id)
        REFERENCES categories (category_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    ADD CONSTRAINT fk_complaints_subcategory
        FOREIGN KEY (final_subcategory_id)
        REFERENCES subcategories (subcategory_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    ADD CONSTRAINT fk_complaints_department
        FOREIGN KEY (final_department_id)
        REFERENCES departments (department_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL;

-- Complaint Attachments Table
ALTER TABLE complaint_attachments
    ADD CONSTRAINT fk_attachments_complaint
        FOREIGN KEY (complaint_id)
        REFERENCES complaints (complaint_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE;

-- Complaint Assignments Table
ALTER TABLE complaint_assignments
    ADD CONSTRAINT fk_assignments_complaint
        FOREIGN KEY (complaint_id)
        REFERENCES complaints (complaint_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    ADD CONSTRAINT fk_assignments_department
        FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
        ON UPDATE CASCADE,
    ADD CONSTRAINT fk_assignments_staff
        FOREIGN KEY (staff_id)
        REFERENCES users (user_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    ADD CONSTRAINT fk_assignments_assigned_by
        FOREIGN KEY (assigned_by)
        REFERENCES users (user_id)
        ON UPDATE CASCADE;

-- Complaint Status History Table
ALTER TABLE complaint_status_history
    ADD CONSTRAINT fk_status_history_complaint
        FOREIGN KEY (complaint_id)
        REFERENCES complaints (complaint_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    ADD CONSTRAINT fk_status_history_user
        FOREIGN KEY (changed_by)
        REFERENCES users (user_id)
        ON UPDATE CASCADE;

-- Complaint Responses Table
ALTER TABLE complaint_responses
    ADD CONSTRAINT fk_responses_complaint
        FOREIGN KEY (complaint_id)
        REFERENCES complaints (complaint_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    ADD CONSTRAINT fk_responses_responder
        FOREIGN KEY (responder_id)
        REFERENCES users (user_id)
        ON UPDATE CASCADE;

-- Complaint Feedback Table
ALTER TABLE complaint_feedback
    ADD CONSTRAINT fk_feedback_complaint
        FOREIGN KEY (complaint_id)
        REFERENCES complaints (complaint_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    ADD CONSTRAINT fk_feedback_student
        FOREIGN KEY (student_id)
        REFERENCES users (user_id)
        ON UPDATE CASCADE;

-- Complaint Upvotes Table (forum)
ALTER TABLE complaint_upvotes
    ADD CONSTRAINT fk_upvotes_complaint
        FOREIGN KEY (complaint_id)
        REFERENCES complaints (complaint_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    ADD CONSTRAINT fk_upvotes_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE;

-- AI Predictions Table
ALTER TABLE ai_predictions
    ADD CONSTRAINT fk_ai_predictions_complaint
        FOREIGN KEY (complaint_id)
        REFERENCES complaints (complaint_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    ADD CONSTRAINT fk_ai_predictions_category
        FOREIGN KEY (predicted_category_id)
        REFERENCES categories (category_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    ADD CONSTRAINT fk_ai_predictions_department
        FOREIGN KEY (suggested_department_id)
        REFERENCES departments (department_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL;

-- Notifications Table
ALTER TABLE notifications
    ADD CONSTRAINT fk_notifications_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    ADD CONSTRAINT fk_notifications_complaint
        FOREIGN KEY (complaint_id)
        REFERENCES complaints (complaint_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL;

-- Audit Logs Table
ALTER TABLE audit_logs
    ADD CONSTRAINT fk_audit_logs_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL;

-- Dataset Annotations Table
ALTER TABLE dataset_annotations
    ADD CONSTRAINT fk_annotations_complaint
        FOREIGN KEY (complaint_id)
        REFERENCES complaints (complaint_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    ADD CONSTRAINT fk_annotations_annotator
        FOREIGN KEY (annotator_id)
        REFERENCES users (user_id)
        ON UPDATE CASCADE,
    ADD CONSTRAINT fk_annotations_category
        FOREIGN KEY (category_id)
        REFERENCES categories (category_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    ADD CONSTRAINT fk_annotations_subcategory
        FOREIGN KEY (subcategory_id)
        REFERENCES subcategories (subcategory_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    ADD CONSTRAINT fk_annotations_department
        FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL;

-- Complaint Similarity Table
-- No ON UPDATE / ON DELETE actions on purpose: MySQL does not allow referential
-- actions (CASCADE, SET NULL) on columns used in a CHECK (chk_similarity_different).
ALTER TABLE complaint_similarity
    ADD CONSTRAINT fk_similarity_source
        FOREIGN KEY (complaint_id)
        REFERENCES complaints (complaint_id),
    ADD CONSTRAINT fk_similarity_matched
        FOREIGN KEY (similar_complaint_id)
        REFERENCES complaints (complaint_id),
    ADD CONSTRAINT uq_similarity_pair UNIQUE (complaint_id, similar_complaint_id),
    ADD CONSTRAINT chk_similarity_different CHECK (complaint_id <> similar_complaint_id);

-- =========================================
-- 5. EXTRA VALIDATION RULES
-- =========================================

-- Extra validation rules (CHECK constraints)
-- Note: MySQL does not allow a CHECK on a column that has ON DELETE SET NULL/CASCADE,
-- so these rules only use columns that are not part of such a foreign key.

ALTER TABLE users
    ADD CONSTRAINT chk_users_email_format CHECK (email LIKE '%_@_%._%');

ALTER TABLE complaints
    ADD CONSTRAINT chk_complaints_title_not_blank CHECK (CHAR_LENGTH(TRIM(title)) > 0),
    ADD CONSTRAINT chk_complaints_resolved_after_created CHECK (resolved_at IS NULL OR resolved_at >= created_at),
    ADD CONSTRAINT chk_complaints_closed_after_created CHECK (closed_at IS NULL OR closed_at >= created_at);

ALTER TABLE complaint_attachments
    ADD CONSTRAINT chk_attachments_size CHECK (file_size_bytes IS NULL OR file_size_bytes >= 0);

ALTER TABLE complaint_assignments
    ADD CONSTRAINT chk_assignments_dates CHECK (unassigned_at IS NULL OR unassigned_at >= assigned_at);

ALTER TABLE complaint_similarity
    ADD CONSTRAINT chk_similarity_score CHECK (similarity_score BETWEEN 0 AND 1);

ALTER TABLE ai_predictions
    ADD CONSTRAINT chk_ai_category_confidence CHECK (category_confidence IS NULL OR category_confidence BETWEEN 0 AND 1),
    ADD CONSTRAINT chk_ai_priority_confidence CHECK (priority_confidence IS NULL OR priority_confidence BETWEEN 0 AND 1);

-- =========================================
-- 6. INDEXES
-- =========================================

CREATE INDEX idx_complaints_status_priority ON complaints (status, priority, created_at);
CREATE INDEX idx_complaints_dept_status ON complaints (final_department_id, status);
CREATE INDEX idx_assignments_complaint_unassigned ON complaint_assignments (complaint_id, unassigned_at);
CREATE INDEX idx_status_history_complaint_changed ON complaint_status_history (complaint_id, changed_at);
CREATE INDEX idx_ai_predictions_complaint_created ON ai_predictions (complaint_id, created_at);

-- =========================================
-- 7. LOOKUP DATA (ROLES, DEPARTMENTS, CATEGORIES)
-- =========================================

INSERT INTO roles (role_id, role_name, description) VALUES
(1, 'ADMIN', 'System Administrator with full access'),
(2, 'STAFF', 'Department staff member managing complaints'),
(3, 'STUDENT', 'Enrolled student submitting complaints and feedback')
ON DUPLICATE KEY UPDATE description=VALUES(description);

INSERT INTO departments (department_id, department_name, department_code, department_email) VALUES
(1, 'IT & Technical Support', 'IT', 'itsupport@sut.edu.eg'),
(2, 'Admissions & Registration', 'REG', 'registration@sut.edu.eg'),
(3, 'Academic Advising', 'ADV', 'advising@sut.edu.eg'),
(4, 'Finance & Student Accounts', 'FIN', 'finance@sut.edu.eg'),
(5, 'Campus Facilities', 'FAC', 'facilities@sut.edu.eg'),
(6, 'Library Services', 'LIB', 'library@sut.edu.eg'),
(7, 'Student Affairs & Activities', 'SA', 'studentaffairs@sut.edu.eg'),
(8, 'Security & Transportation', 'SEC', 'security@sut.edu.eg'),
(9, 'Health & Counseling Services', 'HLT', 'health@sut.edu.eg')
ON DUPLICATE KEY UPDATE department_name=VALUES(department_name), department_code=VALUES(department_code);

INSERT INTO categories (category_id, category_name, default_department_id, description) VALUES
(1, 'IT & Technical Support', 1, 'Issues with WiFi, network, portal, LMS, and hardware'),
(2, 'Admissions & Registration', 2, 'Issues with course registration, transcripts, and admissions'),
(3, 'Academic Advising', 3, 'Academic degree plans, advising, and GPA inquiries'),
(4, 'Finance & Student Accounts', 4, 'Tuition fees, billing, scholarships, and refunds'),
(5, 'Facilities & Maintenance', 5, 'Campus classrooms, labs, amenities, and maintenance'),
(6, 'General Inquiry', NULL, 'General questions or unclassified complaints'),
(7, 'Library Services', 6, 'Book borrowing, study rooms, digital resources, and library fines'),
(8, 'Student Affairs & Activities', 7, 'Clubs, events, student ID cards, and student support'),
(9, 'Security & Transportation', 8, 'Campus safety, parking, access cards, and bus services'),
(10, 'Health & Counseling', 9, 'Medical clinic, counseling, and wellbeing services')
ON DUPLICATE KEY UPDATE category_name=VALUES(category_name);

INSERT INTO subcategories (category_id, subcategory_name, description) VALUES
(1, 'WiFi & Network', 'Connectivity and speed issues on campus'),
(1, 'Student Portal & LMS', 'Access or bug issues with LMS or student portal'),
(1, 'Lab PC & Hardware', 'Hardware malfunction in computer laboratories'),
(2, 'Course Registration', 'Trouble adding or dropping courses during registration'),
(2, 'Transcripts & Records', 'Document requests and official transcripts'),
(3, 'Degree Plan & Advising', 'Academic plan review with advisor'),
(4, 'Tuition Payment & Invoices', 'Payment processing and tuition schedules'),
(5, 'Air Conditioning & Lighting', 'Classroom cooling, heating, or lighting problems'),
(5, 'Cleanliness & Restrooms', 'Sanitation and cleanliness on campus'),
-- Extra subcategories (appended after the first 9 so existing IDs 1-9 do not change)
(1, 'University Email & Accounts', 'Email access, password resets, and account lockouts'),
(1, 'Software & Licenses', 'Licensed software, installation, and activation problems'),
(1, 'Printing & Projectors', 'Printers, scanners, and classroom projector issues'),
(2, 'Withdrawal & Deferral', 'Course withdrawal, semester deferral, and re-enrollment'),
(2, 'Student ID & Enrollment Letters', 'Student ID cards and enrollment verification letters'),
(3, 'Grade Appeals & Re-marking', 'Requests to review or re-mark exam results'),
(3, 'Academic Warning & Probation', 'Academic standing, warnings, and probation questions'),
(4, 'Scholarships & Financial Aid', 'Scholarship eligibility, grants, and aid applications'),
(4, 'Refunds & Fee Errors', 'Incorrect charges, duplicate payments, and refund requests'),
(5, 'Cafeteria & Food Services', 'Food quality, prices, and cafeteria cleanliness'),
(5, 'Furniture & Classroom Equipment', 'Broken desks, boards, and teaching equipment'),
(6, 'Suggestions & Feedback', 'Ideas and suggestions to improve university services'),
(6, 'Other / Unclassified', 'Anything that does not fit another category'),
(7, 'Book Borrowing & Fines', 'Borrowing limits, late returns, and fine disputes'),
(7, 'Study Rooms & Seating', 'Study room booking and library seating availability'),
(7, 'Digital Library Access', 'E-books, journals, and database access problems'),
(8, 'Clubs & Activities', 'Student clubs, sports, and extracurricular activities'),
(8, 'Events & Registration', 'Campus events and event sign-up problems'),
(8, 'Staff Conduct & Discipline', 'Concerns about staff behavior or disciplinary procedures'),
(9, 'Parking & Vehicle Access', 'Parking permits, gates, and vehicle access'),
(9, 'Campus Safety & Lost Items', 'Safety concerns, lost and found, and incidents'),
(9, 'Bus & Transportation', 'University bus schedules, routes, and delays'),
(10, 'Medical Clinic', 'Clinic services, appointments, and first aid'),
(10, 'Counseling & Wellbeing', 'Counseling appointments and student wellbeing support')
ON DUPLICATE KEY UPDATE subcategory_name=VALUES(subcategory_name);

-- =========================================
-- 8. SAMPLE TEST DATA
-- =========================================

-- Sample data for testing. Safe to run again (rows have fixed IDs).
-- The password hashes are placeholders, so these accounts cannot log in until real hashes are set.
-- Subcategory IDs 1-9 below assume the lookup data above was inserted into an empty database.

INSERT INTO users (user_id, role_id, department_id, username, full_name, email, password_hash, student_code, is_staff, is_superuser) VALUES
(1, 1, NULL, 'admin', 'System Administrator', 'admin@sut.edu.eg', 'PLACEHOLDER_HASH_NOT_A_REAL_PASSWORD', NULL, 1, 1),
(2, 2, 1, 'it.staff', 'Omar Hassan', 'omar.hassan@sut.edu.eg', 'PLACEHOLDER_HASH_NOT_A_REAL_PASSWORD', NULL, 1, 0),
(3, 2, 2, 'reg.staff', 'Nour Ibrahim', 'nour.ibrahim@sut.edu.eg', 'PLACEHOLDER_HASH_NOT_A_REAL_PASSWORD', NULL, 1, 0),
(4, 2, 4, 'fin.staff', 'Karim Mostafa', 'karim.mostafa@sut.edu.eg', 'PLACEHOLDER_HASH_NOT_A_REAL_PASSWORD', NULL, 1, 0),
(5, 2, 5, 'fac.staff', 'Salma Adel', 'salma.adel@sut.edu.eg', 'PLACEHOLDER_HASH_NOT_A_REAL_PASSWORD', NULL, 1, 0),
(6, 3, NULL, 'ahmed.student', 'Ahmed Ali', 'ahmed.ali@student.sut.edu.eg', 'PLACEHOLDER_HASH_NOT_A_REAL_PASSWORD', '20260001', 0, 0),
(7, 3, NULL, 'mariam.student', 'Mariam Youssef', 'mariam.youssef@student.sut.edu.eg', 'PLACEHOLDER_HASH_NOT_A_REAL_PASSWORD', '20260002', 0, 0),
(8, 3, NULL, 'youssef.student', 'Youssef Khaled', 'youssef.khaled@student.sut.edu.eg', 'PLACEHOLDER_HASH_NOT_A_REAL_PASSWORD', '20260003', 0, 0),
(9, 3, NULL, 'hana.student', 'Hana Mahmoud', 'hana.mahmoud@student.sut.edu.eg', 'PLACEHOLDER_HASH_NOT_A_REAL_PASSWORD', '20260004', 0, 0),
(10, 3, NULL, 'tarek.student', 'Tarek Samir', 'tarek.samir@student.sut.edu.eg', 'PLACEHOLDER_HASH_NOT_A_REAL_PASSWORD', '20260005', 0, 0)
ON DUPLICATE KEY UPDATE full_name=VALUES(full_name);

INSERT INTO complaints (complaint_id, student_id, title, description, language, final_category_id, final_subcategory_id, final_department_id, priority, status, visibility, created_at, resolved_at, closed_at) VALUES
(1, 6, 'Wi-Fi not working in Building B', 'The Wi-Fi in Building B has been down since Monday and I cannot reach the LMS during lectures.', 'EN', 1, 1, 1, 'HIGH', 'RESOLVED', 'PUBLIC_FORUM', '2026-10-01 09:15:00', '2026-10-03 14:00:00', NULL),
(2, 7, 'Cannot log in to the LMS', 'I get an invalid credentials error on the LMS even after resetting my password.', 'EN', 1, 2, 1, 'MEDIUM', 'IN_PROGRESS', 'PUBLIC_FORUM', '2026-10-02 11:30:00', NULL, NULL),
(3, 8, 'Course registration page shows an error', 'The registration page shows error 500 when I try to add my elective course.', 'EN', 2, 4, 2, 'URGENT', 'ASSIGNED', 'PRIVATE_TICKET', '2026-10-04 08:45:00', NULL, NULL),
(4, 9, 'مشكلة في سداد المصروفات الدراسية', 'حاولت دفع المصروفات من خلال البوابة ولكن تم خصم المبلغ ولم يظهر في حسابي.', 'AR', 4, 7, 4, 'HIGH', 'UNDER_REVIEW', 'PRIVATE_TICKET', '2026-10-05 13:20:00', NULL, NULL),
(5, 10, 'Air conditioning broken in Lab 3', 'The air conditioning in Lab 3 has not worked for a week and the room is too hot to work in.', 'EN', 5, 8, 5, 'MEDIUM', 'RESOLVED', 'PUBLIC_FORUM', '2026-10-06 10:00:00', '2026-10-09 12:00:00', NULL),
(6, 6, 'Transcript request delayed for 3 weeks', 'I requested an official transcript three weeks ago and I still have not received it.', 'EN', 2, 5, 2, 'MEDIUM', 'CLOSED', 'PRIVATE_TICKET', '2026-09-20 09:00:00', '2026-10-08 15:00:00', '2026-10-10 09:00:00'),
(7, 7, 'No internet in Lab 3', 'There is no internet connection on the Lab 3 computers since this morning.', 'EN', 1, 1, 1, 'HIGH', 'SUBMITTED', 'PUBLIC_FORUM', '2026-10-12 08:30:00', NULL, NULL),
(8, 8, 'Need advice on my degree plan', 'I want to know if I can take two advanced courses together next semester.', 'EN', 3, 6, 3, 'LOW', 'SUBMITTED', 'PRIVATE_TICKET', '2026-10-12 12:00:00', NULL, NULL),
(9, 9, 'Restrooms in Building A are dirty', 'الحمامات في المبنى A محتاجة تنضيف and there is no soap.', 'MIXED', 5, 9, 5, 'LOW', 'REOPENED', 'PUBLIC_FORUM', '2026-10-03 09:30:00', NULL, NULL),
(10, 10, 'LMS grades are not showing', 'My midterm grades do not appear in the LMS gradebook.', 'EN', 1, 2, 1, 'MEDIUM', 'SUBMITTED', 'PUBLIC_FORUM', '2026-10-13 09:10:00', NULL, NULL),
(11, 6, 'Question about tuition installment plan', 'Can I split my tuition payment into three installments this semester?', 'EN', 4, 7, 4, 'LOW', 'RESOLVED', 'PRIVATE_TICKET', '2026-10-07 14:00:00', '2026-10-08 11:00:00', NULL),
(12, 8, 'General question about campus clubs', 'How can I join the robotics club?', 'EN', 6, NULL, NULL, 'LOW', 'SUBMITTED', 'PRIVATE_TICKET', '2026-10-13 15:00:00', NULL, NULL)
ON DUPLICATE KEY UPDATE title=VALUES(title);

INSERT INTO complaint_assignments (assignment_id, complaint_id, department_id, staff_id, assigned_by, assigned_at, unassigned_at, assignment_note) VALUES
(1, 1, 1, 2, 1, '2026-10-01 10:00:00', NULL, 'Network team to check Building B access points'),
(2, 2, 1, 2, 1, '2026-10-02 12:00:00', NULL, 'Check LMS account sync'),
(3, 3, 2, 3, 1, '2026-10-04 09:30:00', NULL, 'Urgent: registration window closes soon'),
(4, 4, 4, NULL, 1, '2026-10-05 14:00:00', NULL, 'Assigned to the department, staff member not chosen yet'),
(5, 5, 5, 5, 1, '2026-10-06 11:00:00', NULL, NULL),
(6, 6, 2, 3, 1, '2026-09-20 11:00:00', NULL, NULL),
(7, 9, 5, NULL, 1, '2026-10-03 10:00:00', '2026-10-04 09:00:00', 'First assignment, replaced by a named staff member'),
(8, 9, 5, 5, 1, '2026-10-04 09:00:00', NULL, 'Reassigned to the facilities supervisor'),
(9, 11, 4, 4, 1, '2026-10-07 15:00:00', NULL, NULL)
ON DUPLICATE KEY UPDATE assignment_note=VALUES(assignment_note);

INSERT INTO complaint_status_history (history_id, complaint_id, old_status, new_status, changed_by, change_note, changed_at) VALUES
(1, 1, NULL, 'SUBMITTED', 6, 'Complaint submitted', '2026-10-01 09:15:00'),
(2, 1, 'SUBMITTED', 'UNDER_REVIEW', 2, NULL, '2026-10-01 09:50:00'),
(3, 1, 'UNDER_REVIEW', 'ASSIGNED', 1, 'Assigned to IT', '2026-10-01 10:00:00'),
(4, 1, 'ASSIGNED', 'IN_PROGRESS', 2, 'Network team on site', '2026-10-02 08:00:00'),
(5, 1, 'IN_PROGRESS', 'RESOLVED', 2, 'Access point replaced', '2026-10-03 14:00:00'),
(6, 2, NULL, 'SUBMITTED', 7, 'Complaint submitted', '2026-10-02 11:30:00'),
(7, 2, 'SUBMITTED', 'UNDER_REVIEW', 2, NULL, '2026-10-02 11:50:00'),
(8, 2, 'UNDER_REVIEW', 'ASSIGNED', 1, NULL, '2026-10-02 12:00:00'),
(9, 2, 'ASSIGNED', 'IN_PROGRESS', 2, 'Investigating account sync', '2026-10-02 14:30:00'),
(10, 3, NULL, 'SUBMITTED', 8, 'Complaint submitted', '2026-10-04 08:45:00'),
(11, 3, 'SUBMITTED', 'UNDER_REVIEW', 3, NULL, '2026-10-04 09:10:00'),
(12, 3, 'UNDER_REVIEW', 'ASSIGNED', 1, NULL, '2026-10-04 09:30:00'),
(13, 4, NULL, 'SUBMITTED', 9, 'Complaint submitted', '2026-10-05 13:20:00'),
(14, 4, 'SUBMITTED', 'UNDER_REVIEW', 4, NULL, '2026-10-05 14:00:00'),
(15, 5, NULL, 'SUBMITTED', 10, 'Complaint submitted', '2026-10-06 10:00:00'),
(16, 5, 'SUBMITTED', 'UNDER_REVIEW', 5, NULL, '2026-10-06 10:40:00'),
(17, 5, 'UNDER_REVIEW', 'ASSIGNED', 1, NULL, '2026-10-06 11:00:00'),
(18, 5, 'ASSIGNED', 'IN_PROGRESS', 5, NULL, '2026-10-07 09:00:00'),
(19, 5, 'IN_PROGRESS', 'RESOLVED', 5, 'AC unit repaired', '2026-10-09 12:00:00'),
(20, 6, NULL, 'SUBMITTED', 6, 'Complaint submitted', '2026-09-20 09:00:00'),
(21, 6, 'SUBMITTED', 'UNDER_REVIEW', 3, NULL, '2026-09-20 10:00:00'),
(22, 6, 'UNDER_REVIEW', 'ASSIGNED', 1, NULL, '2026-09-20 11:00:00'),
(23, 6, 'ASSIGNED', 'IN_PROGRESS', 3, NULL, '2026-09-25 09:00:00'),
(24, 6, 'IN_PROGRESS', 'RESOLVED', 3, 'Transcript sent by email', '2026-10-08 15:00:00'),
(25, 6, 'RESOLVED', 'CLOSED', 1, 'Closed after student confirmation', '2026-10-10 09:00:00'),
(26, 7, NULL, 'SUBMITTED', 7, 'Complaint submitted', '2026-10-12 08:30:00'),
(27, 8, NULL, 'SUBMITTED', 8, 'Complaint submitted', '2026-10-12 12:00:00'),
(28, 9, NULL, 'SUBMITTED', 9, 'Complaint submitted', '2026-10-03 09:30:00'),
(29, 9, 'SUBMITTED', 'ASSIGNED', 1, 'Sent to Facilities', '2026-10-03 10:00:00'),
(30, 9, 'ASSIGNED', 'RESOLVED', 5, 'Cleaning done', '2026-10-05 10:00:00'),
(31, 9, 'RESOLVED', 'REOPENED', 9, 'Still dirty, no soap', '2026-10-07 11:00:00'),
(32, 10, NULL, 'SUBMITTED', 10, 'Complaint submitted', '2026-10-13 09:10:00'),
(33, 11, NULL, 'SUBMITTED', 6, 'Complaint submitted', '2026-10-07 14:00:00'),
(34, 11, 'SUBMITTED', 'UNDER_REVIEW', 4, NULL, '2026-10-07 14:30:00'),
(35, 11, 'UNDER_REVIEW', 'ASSIGNED', 1, NULL, '2026-10-07 15:00:00'),
(36, 11, 'ASSIGNED', 'RESOLVED', 4, 'Installment plan explained', '2026-10-08 11:00:00'),
(37, 12, NULL, 'SUBMITTED', 8, 'Complaint submitted', '2026-10-13 15:00:00')
ON DUPLICATE KEY UPDATE new_status=VALUES(new_status);

INSERT INTO complaint_responses (response_id, complaint_id, responder_id, response_text, is_internal_note, created_at) VALUES
(1, 1, 2, 'We have replaced the faulty access point in Building B. Please confirm it works for you.', 0, '2026-10-03 14:05:00'),
(2, 1, 2, 'Replaced AP-B2 and checked the signal in rooms 101 to 110.', 1, '2026-10-03 13:50:00'),
(3, 2, 2, 'We are checking your LMS account. Please do not reset your password again for now.', 0, '2026-10-02 15:00:00'),
(4, 3, 3, 'We can reproduce the error and are fixing it with the system vendor.', 0, '2026-10-04 10:15:00'),
(5, 5, 5, 'A technician fixed the AC unit today.', 0, '2026-10-09 12:05:00'),
(6, 6, 3, 'Your transcript was sent to your email today. Sorry for the delay.', 0, '2026-10-08 15:05:00'),
(7, 9, 5, 'The cleaning team has been notified.', 0, '2026-10-05 10:05:00'),
(8, 11, 4, 'Yes, a three-installment plan is available. Please visit the Finance office with your student card.', 0, '2026-10-08 11:05:00'),
(9, 4, 4, 'Check the bank record: the student may have paid twice.', 1, '2026-10-05 15:00:00')
ON DUPLICATE KEY UPDATE response_text=VALUES(response_text);

INSERT INTO complaint_feedback (feedback_id, complaint_id, student_id, rating, comment, created_at) VALUES
(1, 1, 6, 5, 'Fixed quickly, thank you.', '2026-10-04 09:00:00'),
(2, 5, 10, 4, 'Fixed, but it took a few days.', '2026-10-10 09:00:00'),
(3, 6, 6, 3, 'Took too long but it was solved.', '2026-10-11 10:00:00'),
(4, 11, 6, 5, 'Very helpful.', '2026-10-09 09:00:00')
ON DUPLICATE KEY UPDATE rating=VALUES(rating);

INSERT INTO complaint_attachments (attachment_id, complaint_id, file_name, file_path, mime_type, file_size_bytes, uploaded_at) VALUES
(1, 1, 'wifi_signal_screenshot.png', '/media/attachments/2026/10/wifi_signal_screenshot.png', 'image/png', 204800, '2026-10-01 09:16:00'),
(2, 3, 'registration_error.png', '/media/attachments/2026/10/registration_error.png', 'image/png', 153600, '2026-10-04 08:46:00'),
(3, 5, 'lab3_ac_photo.jpg', '/media/attachments/2026/10/lab3_ac_photo.jpg', 'image/jpeg', 512000, '2026-10-06 10:02:00'),
(4, 4, 'payment_receipt.pdf', '/media/attachments/2026/10/payment_receipt.pdf', 'application/pdf', 98304, '2026-10-05 13:22:00')
ON DUPLICATE KEY UPDATE file_name=VALUES(file_name);

INSERT INTO ai_predictions (prediction_id, complaint_id, model_version, predicted_category_id, category_confidence, predicted_priority, priority_confidence, suggested_department_id, created_at) VALUES
(1, 1, 'tfidf-logreg-v1', 1, 0.9421, 'HIGH', 0.812, 1, '2026-10-01 09:16:00'),
(2, 2, 'tfidf-logreg-v1', 1, 0.9133, 'MEDIUM', 0.7544, 1, '2026-10-02 11:31:00'),
(3, 3, 'tfidf-logreg-v1', 2, 0.965, 'URGENT', 0.7011, 2, '2026-10-04 08:46:00'),
(4, 4, 'tfidf-logreg-v1', 4, 0.887, 'HIGH', 0.652, 4, '2026-10-05 13:21:00'),
(5, 5, 'tfidf-logreg-v1', 5, 0.9312, 'MEDIUM', 0.7001, 5, '2026-10-06 10:01:00'),
(6, 6, 'tfidf-logreg-v1', 2, 0.8995, 'MEDIUM', 0.6804, 2, '2026-09-20 09:01:00'),
(7, 7, 'tfidf-logreg-v1', 1, 0.954, 'HIGH', 0.779, 1, '2026-10-12 08:31:00'),
(8, 8, 'tfidf-logreg-v1', 3, 0.871, 'LOW', 0.8021, 3, '2026-10-12 12:01:00'),
(9, 9, 'tfidf-logreg-v1', 5, 0.8402, 'LOW', 0.7312, 5, '2026-10-03 09:31:00'),
(10, 10, 'tfidf-logreg-v1', 1, 0.8903, 'MEDIUM', 0.701, 1, '2026-10-13 09:11:00'),
(11, 11, 'tfidf-logreg-v1', 4, 0.9024, 'LOW', 0.72, 4, '2026-10-07 14:01:00'),
(12, 12, 'tfidf-logreg-v1', 1, 0.312, 'LOW', 0.55, 1, '2026-10-13 15:01:00')
ON DUPLICATE KEY UPDATE model_version=VALUES(model_version);

INSERT INTO complaint_similarity (similarity_id, complaint_id, similar_complaint_id, similarity_score, model_version, created_at) VALUES
(1, 7, 1, 0.8812, 'minilm-embed-v1', '2026-10-12 08:32:00'),
(2, 10, 2, 0.914, 'minilm-embed-v1', '2026-10-13 09:12:00'),
(3, 7, 2, 0.7405, 'minilm-embed-v1', '2026-10-12 08:32:00')
ON DUPLICATE KEY UPDATE similarity_score=VALUES(similarity_score);

INSERT INTO dataset_annotations (annotation_id, complaint_id, annotator_id, category_id, subcategory_id, priority, department_id, annotation_status, notes, created_at) VALUES
(1, 1, 2, 1, 1, 'HIGH', 1, 'VERIFIED', 'Clear network issue', '2026-10-05 10:00:00'),
(2, 2, 2, 1, 2, 'MEDIUM', 1, 'AGREED', NULL, '2026-10-05 10:05:00'),
(3, 3, 3, 2, 4, 'URGENT', 2, 'AGREED', NULL, '2026-10-05 10:10:00'),
(4, 4, 4, 4, 7, 'HIGH', 4, 'PENDING', 'Arabic text, double-check the translation', '2026-10-06 09:00:00'),
(5, 5, 5, 5, 8, 'MEDIUM', 5, 'VERIFIED', NULL, '2026-10-10 09:00:00'),
(6, 12, 1, 6, NULL, 'LOW', NULL, 'CONFLICT', 'Annotators disagree: general inquiry or student affairs?', '2026-10-14 09:00:00')
ON DUPLICATE KEY UPDATE annotation_status=VALUES(annotation_status);

INSERT INTO notifications (notification_id, user_id, complaint_id, notification_type, message, is_read, created_at, read_at) VALUES
(1, 6, 1, 'STATUS_UPDATE', 'Your complaint "Wi-Fi not working in Building B" is now RESOLVED.', 1, '2026-10-03 14:01:00', '2026-10-03 18:30:00'),
(2, 7, 2, 'STATUS_UPDATE', 'Your complaint "Cannot log in to the LMS" is now IN_PROGRESS.', 0, '2026-10-02 14:31:00', NULL),
(3, 8, 3, 'ASSIGNED', 'Your complaint was assigned to Admissions & Registration.', 0, '2026-10-04 09:31:00', NULL),
(4, 3, 3, 'NEW_ASSIGNMENT', 'A new complaint was assigned to you: Course registration page shows an error.', 1, '2026-10-04 09:31:00', '2026-10-04 09:40:00'),
(5, 2, 1, 'NEW_ASSIGNMENT', 'A new complaint was assigned to you: Wi-Fi not working in Building B.', 1, '2026-10-01 10:01:00', '2026-10-01 10:10:00'),
(6, 10, 5, 'RESPONSE', 'Staff replied to your complaint about Lab 3.', 1, '2026-10-09 12:06:00', '2026-10-09 13:00:00'),
(7, 9, 9, 'REOPENED', 'Your complaint about the restrooms in Building A has been reopened.', 0, '2026-10-07 11:01:00', NULL),
(8, 6, 6, 'STATUS_UPDATE', 'Your complaint "Transcript request delayed for 3 weeks" is now CLOSED.', 1, '2026-10-10 09:01:00', '2026-10-10 12:00:00')
ON DUPLICATE KEY UPDATE message=VALUES(message);

INSERT INTO audit_logs (audit_id, user_id, action, entity_type, entity_id, details, ip_address, created_at) VALUES
(1, 6, 'LOGIN', 'user', '6', 'Successful login', '192.168.1.21', '2026-10-01 09:10:00'),
(2, 6, 'CREATE', 'complaint', '1', 'Complaint submitted', '192.168.1.21', '2026-10-01 09:15:00'),
(3, 1, 'ASSIGN', 'complaint', '1', 'Assigned to IT staff (user 2)', '10.0.0.5', '2026-10-01 10:00:00'),
(4, 2, 'STATUS_CHANGE', 'complaint', '1', 'IN_PROGRESS to RESOLVED', '10.0.0.12', '2026-10-03 14:00:00'),
(5, 9, 'CREATE', 'complaint', '4', 'Complaint submitted (Arabic)', '192.168.1.45', '2026-10-05 13:20:00'),
(6, NULL, 'SYSTEM_JOB', 'ai_prediction', '12', 'AI prediction created with low confidence', NULL, '2026-10-13 15:01:00'),
(7, 1, 'LOGIN', 'user', '1', 'Admin login', '10.0.0.5', '2026-10-13 08:00:00'),
(8, 9, 'REOPEN', 'complaint', '9', 'Student reopened complaint', '192.168.1.45', '2026-10-07 11:00:00')
ON DUPLICATE KEY UPDATE details=VALUES(details);

INSERT INTO complaint_upvotes (upvote_id, complaint_id, user_id, created_at) VALUES
(1, 1, 7, '2026-10-14 10:00:00'),
(2, 1, 8, '2026-10-14 10:00:00'),
(3, 1, 9, '2026-10-14 10:00:00'),
(4, 2, 6, '2026-10-14 10:00:00'),
(5, 2, 10, '2026-10-14 10:00:00'),
(6, 5, 6, '2026-10-14 10:00:00'),
(7, 5, 7, '2026-10-14 10:00:00'),
(8, 7, 6, '2026-10-14 10:00:00'),
(9, 7, 10, '2026-10-14 10:00:00'),
(10, 9, 6, '2026-10-14 10:00:00'),
(11, 9, 10, '2026-10-14 10:00:00'),
(12, 10, 7, '2026-10-14 10:00:00'),
(13, 10, 8, '2026-10-14 10:00:00')
ON DUPLICATE KEY UPDATE created_at=VALUES(created_at);
