-- PrototypeDO Database Schema converted for MySQL
-- Target: MySQL / MariaDB (utf8mb4)
-- NOTE: This is a best-effort conversion from SQL Server T-SQL. Review triggers and complex T-SQL logic.


-- -----------------------------
-- Table structure for `users`
-- -----------------------------
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `full_name` VARCHAR(100) NOT NULL,
  `role` VARCHAR(20) NOT NULL,
  `contact_number` VARCHAR(20),
  `is_active` TINYINT(1) DEFAULT 1,
  `last_login` DATETIME NULL,
  `remember_token` VARCHAR(64) NULL,
  `remember_token_expiry` DATETIME NULL,
  `terms_accepted_version` INT DEFAULT 0,
  `terms_accepted_date` DATETIME NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------
-- Table structure for `students`
-- -----------------------------
CREATE TABLE IF NOT EXISTS `students` (
  `student_id` VARCHAR(20) NOT NULL,
  `user_id` INT NULL,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `middle_name` VARCHAR(50) NULL,
  `grade_year` VARCHAR(20) NOT NULL,
  `track_course` VARCHAR(100) NULL,
  `section` VARCHAR(50) NULL,
  `student_type` VARCHAR(20) NULL,
  `status` VARCHAR(20) DEFAULT 'Good Standing',
  `total_offenses` INT DEFAULT 0,
  `major_offenses` INT DEFAULT 0,
  `minor_offenses` INT DEFAULT 0,
  `last_incident_date` DATE NULL,
  `guardian_name` VARCHAR(100) NULL,
  `guardian_contact` VARCHAR(20) NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`student_id`),
  UNIQUE KEY `uq_students_user` (`user_id`),
  CONSTRAINT `fk_students_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------
-- Table structure for `offense_types`
-- -----------------------------
CREATE TABLE IF NOT EXISTS `offense_types` (
  `offense_id` INT NOT NULL AUTO_INCREMENT,
  `offense_name` VARCHAR(100) NOT NULL,
  `category` VARCHAR(20) NOT NULL,
  `description` VARCHAR(500) NULL,
  `is_active` TINYINT(1) DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`offense_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------
-- Table structure for `cases`
-- -----------------------------
CREATE TABLE IF NOT EXISTS `cases` (
  `case_id` VARCHAR(20) NOT NULL,
  `student_id` VARCHAR(20) NOT NULL,
  `offense_id` INT NULL,
  `case_type` VARCHAR(100) NOT NULL,
  `severity` VARCHAR(20) NOT NULL,
  `offense_category` VARCHAR(50) NULL,
  `status` VARCHAR(50) DEFAULT 'Pending',
  `date_reported` DATE NOT NULL DEFAULT (CURRENT_DATE),
  `time_reported` TIME NULL,
  `location` VARCHAR(200) NULL,
  `reported_by` INT NULL,
  `assigned_to` INT NULL,
  `description` LONGTEXT NULL,
  `witnesses` VARCHAR(500) NULL,
  `action_taken` VARCHAR(500) NULL,
  `notes` LONGTEXT NULL,
  `attachments` LONGTEXT NULL,
  `next_hearing_date` DATETIME NULL,
  `resolved_date` DATE NULL,
  `is_archived` TINYINT(1) DEFAULT 0,
  `manually_restored` TINYINT(1) DEFAULT 0,
  `archived_at` DATETIME NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`case_id`),
  CONSTRAINT `fk_cases_student` FOREIGN KEY (`student_id`) REFERENCES `students`(`student_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cases_offense` FOREIGN KEY (`offense_id`) REFERENCES `offense_types`(`offense_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_cases_reported_by` FOREIGN KEY (`reported_by`) REFERENCES `users`(`user_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_cases_assigned_to` FOREIGN KEY (`assigned_to`) REFERENCES `users`(`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------
-- Table structure for `sanctions`
-- -----------------------------
CREATE TABLE IF NOT EXISTS `sanctions` (
  `sanction_id` INT NOT NULL AUTO_INCREMENT,
  `sanction_name` VARCHAR(200) NOT NULL,
  `severity_level` INT NOT NULL,
  `description` VARCHAR(500) NULL,
  `requires_schedule` TINYINT(1) DEFAULT 0,
  `is_active` TINYINT(1) DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`sanction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------
-- Table structure for `case_sanctions`
-- -----------------------------
CREATE TABLE IF NOT EXISTS `case_sanctions` (
  `case_sanction_id` INT NOT NULL AUTO_INCREMENT,
  `case_id` VARCHAR(20) NULL,
  `sanction_id` INT NULL,
  `applied_date` DATE DEFAULT (CURRENT_DATE),
  `duration_days` INT NULL,
  `duration_extra_hours` INT NOT NULL DEFAULT 0,
  `is_completed` TINYINT(1) DEFAULT 0,
  `completion_date` DATE NULL,
  `notes` VARCHAR(500) NULL,
  `scheduled_date` DATE NULL,
  `scheduled_time` TIME NULL,
  `scheduled_end_time` TIME NULL,
  `schedule_notes` VARCHAR(500) NULL,
  `deadline` DATETIME NULL,
  `original_duration_days` INT NULL,
  `days_extended` INT DEFAULT 0,
  `extension_count` INT DEFAULT 0,
  `extension_notes` LONGTEXT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`case_sanction_id`),
  CONSTRAINT `fk_case_sanctions_case` FOREIGN KEY (`case_id`) REFERENCES `cases`(`case_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_case_sanctions_sanction` FOREIGN KEY (`sanction_id`) REFERENCES `sanctions`(`sanction_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------
-- Table structure for `case_checkins`
-- -----------------------------
CREATE TABLE IF NOT EXISTS `case_checkins` (
  `checkin_id` INT NOT NULL AUTO_INCREMENT,
  `case_sanction_id` INT NOT NULL,
  `day_number` INT NOT NULL,
  `check_in_time` DATETIME NULL,
  `check_out_time` DATETIME NULL,
  `check_in_date` DATE NOT NULL DEFAULT (CURRENT_DATE),
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`checkin_id`),
  CONSTRAINT `fk_checkins_case_sanction` FOREIGN KEY (`case_sanction_id`) REFERENCES `case_sanctions`(`case_sanction_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------
-- Table structure for `community_service_submissions`
-- -----------------------------
CREATE TABLE IF NOT EXISTS `community_service_submissions` (
  `submission_id` INT NOT NULL AUTO_INCREMENT,
  `case_id` VARCHAR(20) NOT NULL,
  `case_sanction_id` INT NOT NULL,
  `student_id` VARCHAR(20) NOT NULL,
  `uploaded_by` INT NULL,
  `file_name` VARCHAR(255) NOT NULL,
  `original_file_name` VARCHAR(255) NOT NULL,
  `file_path` VARCHAR(500) NOT NULL,
  `file_size_bytes` BIGINT NULL,
  `mime_type` VARCHAR(120) NULL,
  `remarks` VARCHAR(1000) NULL,
  `is_seen_by_do` TINYINT(1) NOT NULL DEFAULT 0,
  `seen_by_do_at` DATETIME NULL,
  `seen_by_do_user_id` INT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`submission_id`),
  CONSTRAINT `fk_css_case` FOREIGN KEY (`case_id`) REFERENCES `cases`(`case_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_css_case_sanction` FOREIGN KEY (`case_sanction_id`) REFERENCES `case_sanctions`(`case_sanction_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_css_student` FOREIGN KEY (`student_id`) REFERENCES `students`(`student_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_css_uploaded_by` FOREIGN KEY (`uploaded_by`) REFERENCES `users`(`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------
-- Table structure for `case_history`
-- -----------------------------
CREATE TABLE IF NOT EXISTS `case_history` (
  `history_id` INT NOT NULL AUTO_INCREMENT,
  `case_id` VARCHAR(20) NULL,
  `changed_by` INT NULL,
  `action` VARCHAR(50) NOT NULL,
  `old_value` LONGTEXT NULL,
  `new_value` LONGTEXT NULL,
  `notes` VARCHAR(500) NULL,
  `timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`history_id`),
  CONSTRAINT `fk_case_history_case` FOREIGN KEY (`case_id`) REFERENCES `cases`(`case_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_case_history_user` FOREIGN KEY (`changed_by`) REFERENCES `users`(`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------
-- Table structure for `lost_found_items`
-- -----------------------------
CREATE TABLE IF NOT EXISTS `lost_found_items` (
  `item_id` VARCHAR(20) NOT NULL,
  `item_name` VARCHAR(200) NOT NULL,
  `category` VARCHAR(50) NOT NULL,
  `description` LONGTEXT NULL,
  `found_location` VARCHAR(200) NOT NULL,
  `date_found` DATE NOT NULL DEFAULT (CURRENT_DATE),
  `time_found` TIME NULL,
  `finder_name` VARCHAR(100) NULL,
  `finder_student_id` VARCHAR(20) NULL,
  `status` VARCHAR(20) DEFAULT 'Unclaimed',
  `claimer_name` VARCHAR(100) NULL,
  `claimer_student_id` VARCHAR(20) NULL,
  `date_claimed` DATE NULL,
  `image_path` VARCHAR(500) NULL,
  `is_archived` TINYINT(1) DEFAULT 0,
  `archived_at` DATETIME NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`item_id`),
  CONSTRAINT `fk_lf_finder_student` FOREIGN KEY (`finder_student_id`) REFERENCES `students`(`student_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_lf_claimer_student` FOREIGN KEY (`claimer_student_id`) REFERENCES `students`(`student_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------
-- Table structure for `lost_found_categories`
-- -----------------------------
CREATE TABLE IF NOT EXISTS `lost_found_categories` (
  `category_id` INT NOT NULL AUTO_INCREMENT,
  `category_name` VARCHAR(100) NOT NULL UNIQUE,
  `description` VARCHAR(500) NULL,
  `is_active` TINYINT(1) DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert default categories
INSERT INTO `lost_found_categories` (`category_name`, `description`) VALUES
('Electronics', 'Electronic devices, gadgets, and accessories'),
('Books', 'Textbooks, notebooks, and reading materials'),
('Accessories', 'Bags, belts, scarves, and other accessories'),
('Clothing', 'Uniforms, jackets, shoes, and apparel'),
('ID/Documents', 'School IDs, documents, and important papers'),
('Keys', 'House keys, locker keys, and car keys'),
('Sports Equipment', 'Sports gear, balls, and athletic equipment'),
('Personal Items', 'Wallets, phones, and personal belongings'),
('School Supplies', 'Pens, folders, pencils, and stationery'),
('Others', 'Miscellaneous items');

-- -----------------------------
-- Table structure for `notifications`
-- -----------------------------
CREATE TABLE IF NOT EXISTS `notifications` (
  `notification_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NULL,
  `title` VARCHAR(200) NOT NULL,
  `message` LONGTEXT NOT NULL,
  `type` VARCHAR(50) NOT NULL,
  `related_id` VARCHAR(50) NULL,
  `is_read` TINYINT(1) DEFAULT 0,
  `read_at` DATETIME NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`),
  CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------
-- Table structure for `reports`
-- -----------------------------
CREATE TABLE IF NOT EXISTS `reports` (
  `report_id` INT NOT NULL AUTO_INCREMENT,
  `report_name` VARCHAR(200) NOT NULL,
  `report_type` VARCHAR(50) NOT NULL,
  `format` VARCHAR(10) NOT NULL,
  `file_path` VARCHAR(500) NULL,
  `generated_by` INT NULL,
  `date_generated` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `parameters` LONGTEXT NULL,
  `file_size_kb` INT NULL,
  PRIMARY KEY (`report_id`),
  CONSTRAINT `fk_reports_user` FOREIGN KEY (`generated_by`) REFERENCES `users`(`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------
-- Table structure for `calendar_events`
-- -----------------------------
CREATE TABLE IF NOT EXISTS `calendar_events` (
  `event_id` INT NOT NULL AUTO_INCREMENT,
  `event_name` VARCHAR(200) NOT NULL,
  `event_date` DATE NOT NULL,
  `event_time` TIME NULL,
  `event_end_time` TIME NULL,
  `category` VARCHAR(50) NOT NULL,
  `description` LONGTEXT NULL,
  `location` VARCHAR(200) NULL,
  `created_by` INT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`event_id`),
  CONSTRAINT `fk_calendar_user` FOREIGN KEY (`created_by`) REFERENCES `users`(`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------
-- Table structure for `handbook_sections`
-- -----------------------------
CREATE TABLE IF NOT EXISTS `handbook_sections` (
  `section_id` INT NOT NULL AUTO_INCREMENT,
  `section_title` VARCHAR(200) NOT NULL,
  `section_order` INT NOT NULL,
  `content` LONGTEXT NOT NULL,
  `last_edited_by` INT NULL,
  `last_edited_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`section_id`),
  CONSTRAINT `fk_handbook_user` FOREIGN KEY (`last_edited_by`) REFERENCES `users`(`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------
-- Table structure for `watch_list`
-- -----------------------------
CREATE TABLE IF NOT EXISTS `watch_list` (
  `watch_id` INT NOT NULL AUTO_INCREMENT,
  `student_id` VARCHAR(20) NULL,
  `reason` VARCHAR(500) NOT NULL,
  `added_by` INT NULL,
  `added_date` DATE DEFAULT (CURRENT_DATE),
  `is_active` TINYINT(1) DEFAULT 1,
  `removed_date` DATE NULL,
  `removed_by` INT NULL,
  `notes` LONGTEXT NULL,
  PRIMARY KEY (`watch_id`),
  CONSTRAINT `fk_watch_student` FOREIGN KEY (`student_id`) REFERENCES `students`(`student_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_watch_user` FOREIGN KEY (`added_by`) REFERENCES `users`(`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------
-- Table structure for `audit_log`
-- -----------------------------
CREATE TABLE IF NOT EXISTS `audit_log` (
  `log_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NULL,
  `action` VARCHAR(100) NOT NULL,
  `table_name` VARCHAR(50) NULL,
  `record_id` VARCHAR(50) NULL,
  `old_values` LONGTEXT NULL,
  `new_values` LONGTEXT NULL,
  `ip_address` VARCHAR(50) NULL,
  `user_agent` VARCHAR(500) NULL,
  `timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  CONSTRAINT `fk_audit_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------
-- Indexes
-- -----------------------------
CREATE INDEX IF NOT EXISTS `idx_cases_student` ON `cases` (`student_id`);
CREATE INDEX IF NOT EXISTS `idx_cases_status` ON `cases` (`status`);
CREATE INDEX IF NOT EXISTS `idx_cases_date` ON `cases` (`date_reported`);
CREATE INDEX IF NOT EXISTS `idx_cases_archived` ON `cases` (`is_archived`);
CREATE INDEX IF NOT EXISTS `idx_students_status` ON `students` (`status`);
CREATE INDEX IF NOT EXISTS `idx_notifications_user` ON `notifications` (`user_id`, `is_read`);
CREATE INDEX IF NOT EXISTS `idx_audit_user` ON `audit_log` (`user_id`);
CREATE INDEX IF NOT EXISTS `idx_lost_found_status` ON `lost_found_items` (`status`);
CREATE INDEX IF NOT EXISTS `idx_case_sanctions_case` ON `case_sanctions` (`case_id`);

-- -----------------------------
-- Triggers (commented out)
-- -----------------------------
-- Original SQL Server triggers use T-SQL features that need careful conversion. Implement in app or convert manually.
/*
DELIMITER $$
CREATE TRIGGER trg_enforce_sanction_on_active_case
AFTER UPDATE ON cases
FOR EACH ROW
BEGIN
  -- convert logic here if needed
END$$
DELIMITER ;
*/

-- -----------------------------
-- Seed data (examples). Replace or expand as needed.
-- Default password hash used in original: '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'

INSERT INTO `users` (`username`, `password_hash`, `email`, `full_name`, `role`, `contact_number`)
VALUES
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin@sti.edu', 'System Administrator', 'super_admin', '09123456789'),
('do_staff', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'do@sti.edu', 'John Doe', 'discipline_office', '09187654321'),
('teacher', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'teacher1@sti.edu', 'Maria Santos', 'teacher', '09171234567'),
('security', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'security1@sti.edu', 'Carlos Dela Cruz', 'security', '09184561234'),
('student', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'student1@sti.edu', 'Alex Reyes', 'student', '09193456781');

-- Example student insert (adjust user_id values as necessary after seeding users)
INSERT INTO `students` (`student_id`, `user_id`, `first_name`, `last_name`, `middle_name`, `grade_year`, `track_course`, `section`, `student_type`, `status`, `guardian_name`, `guardian_contact`)
VALUES
('02000000001', 6, 'Juan', 'Dela Cruz', 'Santos', '11', 'STEM', 'A', 'SHS', 'Good Standing', 'Maria Dela Cruz', '09171234001');

-- Update student offense counts
UPDATE `students` s
SET
  s.total_offenses = (SELECT COUNT(*) FROM `cases` c WHERE c.student_id = s.student_id AND c.is_archived = 0),
  s.major_offenses = (SELECT COUNT(*) FROM `cases` c WHERE c.student_id = s.student_id AND c.severity = 'Major' AND c.is_archived = 0),
  s.minor_offenses = (SELECT COUNT(*) FROM `cases` c WHERE c.student_id = s.student_id AND c.severity = 'Minor' AND c.is_archived = 0),
  s.last_incident_date = (SELECT MAX(c.date_reported) FROM `cases` c WHERE c.student_id = s.student_id)
WHERE s.student_id IN (SELECT DISTINCT c.student_id FROM `cases` c);

-- Insert case history using CONCAT
INSERT INTO `case_history` (`case_id`, `changed_by`, `action`, `new_value`, `notes`, `timestamp`)
SELECT
  `case_id`,
  2,
  'Created',
  CONCAT('Status: ', `status`),
  'Case created and logged into system',
  DATE_ADD(CAST(CONCAT(`date_reported`, ' 00:00:00') AS DATETIME), INTERVAL 5 MINUTE)
FROM `cases`;

-- Lost & Found sample rows
INSERT INTO `lost_found_items` (`item_id`, `item_name`, `category`, `found_location`, `date_found`, `status`, `description`)
VALUES
('LF-1001', 'Backpack', 'Electronics', 'Cafeteria', '2023-10-14', 'Unclaimed', 'Blue JanSport backpack with laptop'),
('LF-1002', 'Water Bottle', 'Accessories', 'Gym', '2023-10-13', 'Unclaimed', 'Stainless steel water bottle'),
('LF-1003', 'Textbook', 'Books', 'Library', '2023-10-12', 'Claimed', 'Grade 11 Math textbook'),
('LF-1004', 'Calculator', 'Electronics', 'Room C401', '2023-10-08', 'Claimed', 'Scientific calculator Casio fx-991');

-- Notifications sample
INSERT INTO `notifications` (`user_id`, `title`, `message`, `type`, `related_id`, `is_read`)
VALUES
(2, 'New Case Reported', 'New cyberbullying case C-2026008 requires immediate attention', 'case_update', 'C-2026008', 0),
(2, 'Major Violation', 'Case C-2026007 (Vaping on Campus) requires decision on sanctions', 'case_update', 'C-2026007', 0),
(2, 'Active Investigation', 'Case C-2026005 (Cheating) is currently under investigation', 'case_update', 'C-2026005', 1),
(2, 'Pending Action', 'Case C-2026010 (ID Violation) awaits disciplinary action', 'case_update', 'C-2026010', 0);

-- End of conversion notes
-- Review and expand seed data as needed. Re-implement triggers or move logic into application code.
