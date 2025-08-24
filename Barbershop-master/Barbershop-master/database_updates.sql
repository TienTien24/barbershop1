-- Cập nhật cơ sở dữ liệu cho chức năng hủy lịch và đánh giá
-- Chạy script này sau khi đã tạo database ban đầu

USE barbershop;

-- Thêm trường note cho appointment (để ghi chú khi hủy)
ALTER TABLE appointment ADD COLUMN note TEXT AFTER status;

-- Thêm trường review_date cho review (ngày đánh giá)
ALTER TABLE review ADD COLUMN review_date DATE NOT NULL DEFAULT (CURRENT_DATE) AFTER comment;

-- Thêm index cho việc tìm kiếm appointment theo user và status
CREATE INDEX idx_appt_user_status ON appointment(user_id, status);

-- Thêm index cho việc tìm kiếm review theo appointment
CREATE INDEX idx_review_appointment ON review(appointment_id);

-- Thêm index cho việc tìm kiếm review theo employee
CREATE INDEX idx_review_employee ON review(appointment_id, employee_id);

-- Cập nhật dữ liệu mẫu nếu cần
-- Ví dụ: thêm một số lịch hẹn đã hoàn thành để test chức năng đánh giá
-- INSERT INTO appointment (user_id, employee_id, service_id, appointment_date, start_time, end_time, status) 
-- VALUES (1, 1, 1, '2024-01-15', '09:00:00', '09:30:00', 'COMPLETED');

-- Kiểm tra cấu trúc bảng sau khi cập nhật
DESCRIBE appointment;
DESCRIBE review;

-- Kiểm tra các index đã tạo
SHOW INDEX FROM appointment;
SHOW INDEX FROM review;
