-- =====================================================
-- LAWVIKSH JOINING LIST DATABASE SCHEMA (UPDATED)
-- MySQL Workbench compatible
-- =====================================================

-- Create database
CREATE DATABASE IF NOT EXISTS lawviksh_db;
USE lawviksh_db;

-- =====================================================
-- 1. USERS TABLE (for "Join as USER" and "Join as CREATOR" forms)
-- =====================================================

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone_number VARCHAR(20) NOT NULL,
    gender ENUM('Male', 'Female', 'Other', 'Prefer not to say') NULL,
    profession ENUM('Student', 'Lawyer', 'Other') NULL,
    interest_reason TEXT NULL,
    user_type ENUM('user', 'creator') NOT NULL DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_created_at (created_at)
);
GRANT ALL PRIVILEGES ON lawviksh_db.* TO 'root'@'localhost';
FLUSH PRIVILEGES;

-- =====================================================
-- 2. NOT INTERESTED TABLE (for "Not Interested" form)
-- =====================================================

CREATE TABLE not_interested_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    gender ENUM('Male', 'Female', 'Other', 'Prefer not to say') NULL,
    profession ENUM('Student', 'Lawyer', 'Other') NULL,
    not_interested_reason ENUM('Too complex', 'Not relevant', 'Other') NULL,
    improvement_suggestions TEXT NULL,
    interest_reason TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_reason (not_interested_reason),
    INDEX idx_created_at (created_at)
);

-- =====================================================
-- 3. FEEDBACK FORMS TABLE (for all feedback data)
-- =====================================================

CREATE TABLE feedback_forms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_email VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_email (user_email),
    INDEX idx_created_at (created_at)
);

-- =====================================================
-- 4. DIGITAL WORK & BLOGGING FEEDBACK TABLE
-- =====================================================

CREATE TABLE digital_work_feedback (
    id INT AUTO_INCREMENT PRIMARY KEY,
    feedback_form_id INT NOT NULL,
    -- Digital Work Showcase Effectiveness (Rating 1-5)
    digital_work_showcase_effectiveness INT CHECK (digital_work_showcase_effectiveness BETWEEN 1 AND 5),
    -- Legal Persons Online Recognition (Yes/No)
    legal_persons_online_recognition ENUM('yes', 'no'),
    -- Digital Work Sharing Difficulty (Rating 1-5)
    digital_work_sharing_difficulty INT CHECK (digital_work_sharing_difficulty BETWEEN 1 AND 5),
    -- Regular Blogging (Yes/No)
    regular_blogging ENUM('yes', 'no'),
    -- AI Tools Blogging Frequency
    ai_tools_blogging_frequency ENUM('never', 'rarely', 'sometimes', 'often', 'always'),
    -- Blogging Tools Familiarity (Rating 1-5)
    blogging_tools_familiarity INT CHECK (blogging_tools_familiarity BETWEEN 1 AND 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (feedback_form_id) REFERENCES feedback_forms(id) ON DELETE CASCADE,
    INDEX idx_feedback_form (feedback_form_id),
    INDEX idx_ratings (digital_work_showcase_effectiveness, digital_work_sharing_difficulty, blogging_tools_familiarity)
);

-- =====================================================
-- 5. PLATFORM FEATURES & OPINIONS TABLE
-- =====================================================

CREATE TABLE platform_features_opinions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    feedback_form_id INT NOT NULL,
    -- Core Platform Features (Text)
    core_platform_features TEXT NULL,
    -- AI Research Opinion (Text)
    ai_research_opinion TEXT NULL,
    -- Ideal Reading Features (Text)
    ideal_reading_features TEXT NULL,
    -- Portfolio Presentation Preference (Text)
    portfolio_presentation_preference TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (feedback_form_id) REFERENCES feedback_forms(id) ON DELETE CASCADE,
    INDEX idx_feedback_form (feedback_form_id)
);

-- =====================================================
-- 7. FORM SUBMISSIONS LOG TABLE (for tracking all submissions)
-- =====================================================

CREATE TABLE form_submissions_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    form_type ENUM('join_as_user', 'not_interested', 'feedback') NOT NULL,
    user_ip VARCHAR(45) NULL, -- IPv6 compatible
    user_agent TEXT NULL,
    submission_data JSON NULL, -- Store complete JSON for backup/audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_form_type (form_type),
    INDEX idx_created_at (created_at),
    INDEX idx_user_ip (user_ip)
);

-- =====================================================
-- 8. ANALYTICS VIEWS (for easy reporting)
-- =====================================================

-- View for user/creator registration analytics
CREATE OR REPLACE VIEW user_registration_analytics AS
SELECT 
    DATE(created_at) as registration_date,
    COUNT(*) as total_registrations,
    COUNT(CASE WHEN user_type = 'user' THEN 1 END) as user_count,
    COUNT(CASE WHEN user_type = 'creator' THEN 1 END) as creator_count,
    COUNT(CASE WHEN gender = 'Male' THEN 1 END) as male_count,
    COUNT(CASE WHEN gender = 'Female' THEN 1 END) as female_count,
    COUNT(CASE WHEN gender = 'Other' THEN 1 END) as other_count,
    COUNT(CASE WHEN gender = 'Prefer not to say' THEN 1 END) as prefer_not_to_say_count,
    COUNT(CASE WHEN profession = 'Student' THEN 1 END) as student_count,
    COUNT(CASE WHEN profession = 'Lawyer' THEN 1 END) as lawyer_count,
    COUNT(CASE WHEN profession = 'Other' THEN 1 END) as other_profession_count
FROM users 
GROUP BY DATE(created_at)
ORDER BY registration_date DESC;

-- View for feedback analytics
CREATE OR REPLACE VIEW feedback_analytics AS
SELECT 
    f.id as feedback_id,
    f.user_email,
    f.created_at,
    -- Digital Work & Blogging Feedback
    dwf.digital_work_showcase_effectiveness,
    dwf.legal_persons_online_recognition,
    dwf.digital_work_sharing_difficulty,
    dwf.regular_blogging,
    dwf.ai_tools_blogging_frequency,
    dwf.blogging_tools_familiarity,
    -- Platform Features & Opinions
    pfo.core_platform_features,
    pfo.ai_research_opinion,
    pfo.ideal_reading_features,
    pfo.portfolio_presentation_preference,
    -- Average ratings
    ROUND((dwf.digital_work_showcase_effectiveness + dwf.digital_work_sharing_difficulty + dwf.blogging_tools_familiarity) / 3, 2) as avg_rating
FROM feedback_forms f
LEFT JOIN digital_work_feedback dwf ON f.id = dwf.feedback_form_id
LEFT JOIN platform_features_opinions pfo ON f.id = pfo.feedback_form_id
ORDER BY f.created_at DESC;

-- =====================================================
-- 9. SAMPLE DATA INSERTION (for testing)
-- =====================================================

-- Sample user registrations
INSERT INTO users (name, email, phone_number, gender, profession, interest_reason, user_type) VALUES
('John Doe', 'john.doe@example.com', '+1234567890', 'Male', 'Student', 'Interested in learning about legal processes', 'user'),
('Jane Smith', 'jane.smith@example.com', '+1234567891', 'Female', 'Lawyer', 'Looking for legal resources', 'creator'),
('Alex Johnson', 'alex.johnson@example.com', '+1234567892', 'Other', 'Other', 'General interest in law', 'user');

-- Sample not interested users
INSERT INTO not_interested_users (name, email, phone_number, gender, profession, not_interested_reason, improvement_suggestions, interest_reason) VALUES
('Bob Wilson', 'bob.wilson@example.com', '+1234567893', 'Male', 'Other', 'Too complex', 'Please simplify the interface', 'Not interested in legal resources'),
('Sarah Brown', 'sarah.brown@example.com', '+1234567894', 'Female', 'Lawyer', 'Not relevant', 'Not applicable to my needs', 'No interest');

-- Sample feedback forms
INSERT INTO feedback_forms (user_email) VALUES
('feedback.user1@example.com'),
('feedback.user2@example.com'),
('feedback.user3@example.com');

-- Sample digital work feedback
INSERT INTO digital_work_feedback (
    feedback_form_id, 
    digital_work_showcase_effectiveness,
    legal_persons_online_recognition,
    digital_work_sharing_difficulty,
    regular_blogging,
    ai_tools_blogging_frequency,
    blogging_tools_familiarity
) VALUES 
(1, 4, 'no', 3, 'yes', 'sometimes', 4),
(2, 3, 'yes', 2, 'no', 'rarely', 2),
(3, 5, 'no', 4, 'yes', 'often', 5);

-- Sample platform features and opinions
INSERT INTO platform_features_opinions (
    feedback_form_id,
    core_platform_features,
    ai_research_opinion,
    ideal_reading_features,
    portfolio_presentation_preference
) VALUES 
(1, 'Easy content creation, legal templates, citation tools', 'AI can help with research but human judgment is crucial', 'Searchable content, bookmarking, offline reading', 'Professional portfolio with case studies and testimonials'),
(2, 'Collaboration tools, version control, legal compliance', 'AI is useful for initial research but needs verification', 'Mobile-friendly reading, audio summaries, highlighting', 'Clean, minimalist design with easy navigation'),
(3, 'AI-powered writing assistance, legal database integration', 'AI research tools are essential for modern legal practice', 'Advanced search, related content suggestions, annotations', 'Interactive portfolio with multimedia content');

-- =====================================================
-- 10. USEFUL QUERIES FOR ANALYSIS
-- =====================================================

-- Query to get total registrations by month
-- SELECT 
--     DATE_FORMAT(created_at, '%Y-%m') as month,
--     COUNT(*) as registrations
-- FROM users 
-- GROUP BY DATE_FORMAT(created_at, '%Y-%m')
-- ORDER BY month DESC;

-- Query to get average feedback ratings
-- SELECT 
--     AVG(digital_work_showcase_effectiveness) as avg_showcase_effectiveness,
--     AVG(digital_work_sharing_difficulty) as avg_sharing_difficulty,
--     AVG(blogging_tools_familiarity) as avg_blogging_familiarity
-- FROM digital_work_feedback;

-- Query to get AI tools usage statistics
-- SELECT 
--     ai_tools_blogging_frequency,
--     COUNT(*) as frequency
-- FROM digital_work_feedback 
-- WHERE ai_tools_blogging_frequency IS NOT NULL 
-- GROUP BY ai_tools_blogging_frequency 
-- ORDER BY frequency DESC;

-- Query to get most common platform feature requests
-- SELECT 
--     core_platform_features,
--     COUNT(*) as frequency
-- FROM platform_features_opinions 
-- WHERE core_platform_features IS NOT NULL 
-- GROUP BY core_platform_features 
-- ORDER BY frequency DESC 
-- LIMIT 10;

-- =====================================================
-- END OF SCHEMA
-- =====================================================
