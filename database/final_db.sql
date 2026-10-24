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
-- 4. FOREIGN KEYS & CONSTRAINTS
-- =========================================

-- 1. Users Constraints
ALTER TABLE users 
    ADD CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles (role_id),
    ADD CONSTRAINT fk_users_department FOREIGN KEY (department_id) REFERENCES departments (department_id) ON DELETE SET NULL;

-- 2. Categories & Subcategories Constraints
ALTER TABLE categories 
    ADD CONSTRAINT fk_categories_department FOREIGN KEY (default_department_id) REFERENCES departments (department_id) ON DELETE SET NULL;

ALTER TABLE subcategories 
    ADD CONSTRAINT fk_subcategories_category FOREIGN KEY (category_id) REFERENCES categories (category_id) ON DELETE CASCADE;

-- 3. Complaints Constraints
ALTER TABLE complaints 
    ADD CONSTRAINT fk_complaints_student FOREIGN KEY (student_id) REFERENCES users (user_id),
    ADD CONSTRAINT fk_complaints_category FOREIGN KEY (final_category_id) REFERENCES categories (category_id) ON DELETE SET NULL,
    ADD CONSTRAINT fk_complaints_subcategory FOREIGN KEY (final_subcategory_id) REFERENCES subcategories (subcategory_id) ON DELETE SET NULL,
    ADD CONSTRAINT fk_complaints_department FOREIGN KEY (final_department_id) REFERENCES departments (department_id) ON DELETE SET NULL;

-- 4. Supporting Tables Constraints
ALTER TABLE complaint_attachments 
    ADD CONSTRAINT fk_attachments_complaint FOREIGN KEY (complaint_id) REFERENCES complaints (complaint_id) ON DELETE CASCADE;

ALTER TABLE complaint_assignments 
    ADD CONSTRAINT fk_assignments_complaint FOREIGN KEY (complaint_id) REFERENCES complaints (complaint_id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_assignments_department FOREIGN KEY (department_id) REFERENCES departments (department_id),
    ADD CONSTRAINT fk_assignments_staff FOREIGN KEY (staff_id) REFERENCES users (user_id) ON DELETE SET NULL,
    ADD CONSTRAINT fk_assignments_assigned_by FOREIGN KEY (assigned_by) REFERENCES users (user_id);

ALTER TABLE complaint_status_history 
    ADD CONSTRAINT fk_status_history_complaint FOREIGN KEY (complaint_id) REFERENCES complaints (complaint_id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_status_history_user FOREIGN KEY (changed_by) REFERENCES users (user_id);

ALTER TABLE complaint_responses 
    ADD CONSTRAINT fk_responses_complaint FOREIGN KEY (complaint_id) REFERENCES complaints (complaint_id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_responses_responder FOREIGN KEY (responder_id) REFERENCES users (user_id);

ALTER TABLE complaint_feedback 
    ADD CONSTRAINT fk_feedback_complaint FOREIGN KEY (complaint_id) REFERENCES complaints (complaint_id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_feedback_student FOREIGN KEY (student_id) REFERENCES users (user_id);

ALTER TABLE complaint_upvotes
    ADD CONSTRAINT fk_upvotes_complaint FOREIGN KEY (complaint_id) REFERENCES complaints (complaint_id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_upvotes_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE;

-- 5. AI & Analytics Constraints
ALTER TABLE ai_predictions 
    ADD CONSTRAINT fk_ai_predictions_complaint FOREIGN KEY (complaint_id) REFERENCES complaints (complaint_id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_ai_predictions_category FOREIGN KEY (predicted_category_id) REFERENCES categories (category_id) ON DELETE SET NULL,
    ADD CONSTRAINT fk_ai_predictions_department FOREIGN KEY (suggested_department_id) REFERENCES departments (department_id) ON DELETE SET NULL;

ALTER TABLE complaint_similarity 
    ADD CONSTRAINT fk_similarity_source FOREIGN KEY (complaint_id) REFERENCES complaints (complaint_id),
    ADD CONSTRAINT fk_similarity_matched FOREIGN KEY (similar_complaint_id) REFERENCES complaints (complaint_id),
    ADD CONSTRAINT uq_similarity_pair UNIQUE (complaint_id, similar_complaint_id),
    ADD CONSTRAINT chk_similarity_different CHECK (complaint_id <> similar_complaint_id);
-- Note: no ON DELETE CASCADE here, MySQL does not allow it on columns used in a CHECK.

ALTER TABLE notifications 
    ADD CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_notifications_complaint FOREIGN KEY (complaint_id) REFERENCES complaints (complaint_id) ON DELETE SET NULL;

ALTER TABLE audit_logs 
    ADD CONSTRAINT fk_audit_logs_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE SET NULL;

ALTER TABLE dataset_annotations 
    ADD CONSTRAINT fk_annotations_complaint FOREIGN KEY (complaint_id) REFERENCES complaints (complaint_id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_annotations_annotator FOREIGN KEY (annotator_id) REFERENCES users (user_id),
    ADD CONSTRAINT fk_annotations_category FOREIGN KEY (category_id) REFERENCES categories (category_id) ON DELETE SET NULL,
    ADD CONSTRAINT fk_annotations_subcategory FOREIGN KEY (subcategory_id) REFERENCES subcategories (subcategory_id) ON DELETE SET NULL,
    ADD CONSTRAINT fk_annotations_department FOREIGN KEY (department_id) REFERENCES departments (department_id) ON DELETE SET NULL;

-- =========================================
-- 5. INDEXES
-- =========================================

CREATE INDEX idx_complaints_status_priority ON complaints (status, priority, created_at);
CREATE INDEX idx_complaints_dept_status ON complaints (final_department_id, status);
CREATE INDEX idx_assignments_complaint_unassigned ON complaint_assignments (complaint_id, unassigned_at);
CREATE INDEX idx_status_history_complaint_changed ON complaint_status_history (complaint_id, changed_at);
CREATE INDEX idx_ai_predictions_complaint_created ON ai_predictions (complaint_id, created_at);

-- =========================================
-- 6. DEFAULT SEED DATA (ROLES & DEPARTMENTS)
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
(5, 'Campus Facilities', 'FAC', 'facilities@sut.edu.eg')
ON DUPLICATE KEY UPDATE department_name=VALUES(department_name), department_code=VALUES(department_code);

INSERT INTO categories (category_id, category_name, default_department_id, description) VALUES
(1, 'IT & Technical Support', 1, 'Issues with WiFi, network, portal, LMS, and hardware'),
(2, 'Admissions & Registration', 2, 'Issues with course registration, transcripts, and admissions'),
(3, 'Academic Advising', 3, 'Academic degree plans, advising, and GPA inquiries'),
(4, 'Finance & Student Accounts', 4, 'Tuition fees, billing, scholarships, and refunds'),
(5, 'Facilities & Maintenance', 5, 'Campus classrooms, labs, amenities, and maintenance'),
(6, 'General Inquiry', NULL, 'General questions or unclassified complaints')
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
(5, 'Cleanliness & Restrooms', 'Sanitation and cleanliness on campus')
ON DUPLICATE KEY UPDATE subcategory_name=VALUES(subcategory_name);


