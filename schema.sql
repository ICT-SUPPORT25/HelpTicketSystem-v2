-- Schema for HelpTicketSystem (MySQL)

-- Users table
CREATE TABLE `user` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(64) NOT NULL,
  `email` VARCHAR(120) NOT NULL,
  `password_hash` VARCHAR(256) NOT NULL,
  `full_name` VARCHAR(100) NOT NULL,
  `role` VARCHAR(20) NOT NULL DEFAULT 'user',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `is_verified` TINYINT(1) NOT NULL DEFAULT 0,
  `verification_token` VARCHAR(128),
  `phone_number` VARCHAR(20),
  `is_approved` TINYINT(1) NOT NULL DEFAULT 1,
  `approved_by_id` INT,
  `approved_at` DATETIME,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_user_username` (`username`),
  UNIQUE KEY `ux_user_email` (`email`),
  KEY `ix_user_role` (`role`),
  KEY `ix_user_created_at` (`created_at`),
  CONSTRAINT `fk_user_approved_by` FOREIGN KEY (`approved_by_id`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Categories
CREATE TABLE `category` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `description` VARCHAR(200),
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_category_name` (`name`),
  KEY `ix_category_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tickets
CREATE TABLE `ticket` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `location` VARCHAR(200) NOT NULL,
  `description` TEXT NOT NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'open',
  `priority` VARCHAR(20) NOT NULL DEFAULT 'medium',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `closed_at` DATETIME,
  `closed_by_id` INT,
  `due_date` DATETIME,
  `created_by_id` INT,
  `category_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_ticket_created_at` (`created_at`),
  KEY `ix_ticket_status` (`status`),
  CONSTRAINT `fk_ticket_closed_by` FOREIGN KEY (`closed_by_id`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_ticket_created_by` FOREIGN KEY (`created_by_id`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_ticket_category` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Association table ticket_assignees (many-to-many Ticket <-> User)
CREATE TABLE `ticket_assignees` (
  `ticket_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  PRIMARY KEY (`ticket_id`,`user_id`),
  CONSTRAINT `fk_ta_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `ticket` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ta_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Comments
CREATE TABLE `comment` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `content` TEXT NOT NULL,
  `is_internal` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `ticket_id` INT NOT NULL,
  `author_id` INT,
  PRIMARY KEY (`id`),
  KEY `ix_comment_created_at` (`created_at`),
  CONSTRAINT `fk_comment_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `ticket` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_comment_author` FOREIGN KEY (`author_id`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Attachments
CREATE TABLE `attachment` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `filename` VARCHAR(200) NOT NULL,
  `original_filename` VARCHAR(200) NOT NULL,
  `file_size` INT,
  `content_type` VARCHAR(100),
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `ticket_id` INT NOT NULL,
  `uploaded_by_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_attachment_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `ticket` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_attachment_uploaded_by` FOREIGN KEY (`uploaded_by_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Ticket history
CREATE TABLE `ticket_history` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `ticket_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `action` VARCHAR(100) NOT NULL,
  `field_changed` VARCHAR(100),
  `old_value` VARCHAR(200),
  `new_value` VARCHAR(200),
  `timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ix_ticket_history_timestamp` (`timestamp`),
  CONSTRAINT `fk_th_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `ticket` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_th_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Notifications
CREATE TABLE `notification` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `ticket_id` INT,
  `type` VARCHAR(50) NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `message` TEXT NOT NULL,
  `is_read` TINYINT(1) NOT NULL DEFAULT 0,
  `email_sent` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `read_at` DATETIME,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_notification_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_notification_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `ticket` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Notification settings (one-to-one with user)
CREATE TABLE `notification_settings` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `new_ticket_email` TINYINT(1) NOT NULL DEFAULT 1,
  `new_ticket_app` TINYINT(1) NOT NULL DEFAULT 1,
  `ticket_updated_email` TINYINT(1) NOT NULL DEFAULT 1,
  `ticket_updated_app` TINYINT(1) NOT NULL DEFAULT 1,
  `new_comment_email` TINYINT(1) NOT NULL DEFAULT 1,
  `new_comment_app` TINYINT(1) NOT NULL DEFAULT 1,
  `ticket_closed_email` TINYINT(1) NOT NULL DEFAULT 1,
  `ticket_closed_app` TINYINT(1) NOT NULL DEFAULT 1,
  `ticket_overdue_email` TINYINT(1) NOT NULL DEFAULT 1,
  `ticket_overdue_app` TINYINT(1) NOT NULL DEFAULT 1,
  `do_not_disturb` TINYINT(1) NOT NULL DEFAULT 0,
  `dnd_start_time` TIME,
  `dnd_end_time` TIME,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_notification_settings_user_id` (`user_id`),
  CONSTRAINT `fk_ns_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
