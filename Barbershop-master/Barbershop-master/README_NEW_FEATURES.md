# Chức năng mới - Barbershop Management System

## Tổng quan
Đã thêm 2 chức năng chính vào hệ thống quản lý tiệm cắt tóc:

1. **Hủy lịch/xem lịch đã đặt** - Cho phép khách hàng xem và hủy lịch hẹn
2. **Đánh giá sau khi hoàn thành dịch vụ** - Cho phép khách hàng đánh giá chất lượng dịch vụ

## Cơ sở dữ liệu

### Cập nhật cơ sở dữ liệu
Chạy script `database_updates.sql` để cập nhật cơ sở dữ liệu:

```sql
-- Thêm trường note cho appointment
ALTER TABLE appointment ADD COLUMN note TEXT AFTER status;

-- Thêm trường review_date cho review  
ALTER TABLE review ADD COLUMN review_date DATE NOT NULL DEFAULT (CURRENT_DATE) AFTER comment;

-- Thêm các index cần thiết
CREATE INDEX idx_appt_user_status ON appointment(user_id, status);
CREATE INDEX idx_review_appointment ON review(appointment_id);
CREATE INDEX idx_review_employee ON review(appointment_id, employee_id);
```

### Cấu trúc mới
- **Appointment**: Thêm trường `note` để lưu lý do hủy
- **Review**: Thêm trường `review_date` để lưu ngày đánh giá
- **AppointmentStatus**: Enum mới với 3 trạng thái: BOOKED, CANCELLED, COMPLETED

## Chức năng mới

### 1. Xem lịch hẹn đã đặt
- **URL**: `/appointments/my-appointments`
- **Chức năng**: Hiển thị tất cả lịch hẹn của user đang đăng nhập
- **Quyền**: Chỉ user đã đăng nhập
- **Tính năng**:
  - Hiển thị trạng thái lịch hẹn (Đã đặt, Đã hủy, Đã hoàn thành)
  - Nút hủy lịch cho lịch hẹn đã đặt
  - Nút đánh giá cho lịch hẹn đã hoàn thành
  - Xem đánh giá nhân viên

### 2. Hủy lịch hẹn
- **URL**: `POST /appointments/{appointmentId}/cancel`
- **Chức năng**: Cho phép user hủy lịch hẹn đã đặt
- **Quyền**: Chỉ user đã đặt lịch hẹn đó
- **Tính năng**:
  - Yêu cầu nhập lý do hủy
  - Chỉ hủy được lịch hẹn có trạng thái "BOOKED"
  - Cập nhật trạng thái thành "CANCELLED"

### 3. Hoàn thành lịch hẹn (Admin)
- **URL**: `POST /appointments/{appointmentId}/complete`
- **Chức năng**: Admin có thể đánh dấu lịch hẹn đã hoàn thành
- **Quyền**: Chỉ ADMIN
- **Tính năng**:
  - Cập nhật trạng thái từ "BOOKED" thành "COMPLETED"
  - Cho phép user đánh giá sau khi hoàn thành

### 4. Tạo đánh giá
- **URL**: `GET/POST /reviews/{appointmentId}/create`
- **Chức năng**: Form tạo đánh giá cho lịch hẹn đã hoàn thành
- **Quyền**: User đã đặt lịch hẹn và lịch hẹn đã hoàn thành
- **Tính năng**:
  - Đánh giá 1-5 sao
  - Nhận xét (không bắt buộc)
  - Chỉ đánh giá được 1 lần cho mỗi lịch hẹn

### 5. Xem đánh giá nhân viên
- **URL**: `/reviews/employee/{employeeId}`
- **Chức năng**: Hiển thị tất cả đánh giá của một nhân viên
- **Quyền**: Tất cả user
- **Tính năng**:
  - Hiển thị điểm đánh giá trung bình
  - Danh sách tất cả đánh giá
  - Thông tin chi tiết nhân viên

### 6. Xem đánh giá lịch hẹn
- **URL**: `/reviews/appointment/{appointmentId}`
- **Chức năng**: Hiển thị đánh giá của một lịch hẹn cụ thể
- **Quyền**: User đã đặt lịch hẹn
- **Tính năng**:
  - Hiển thị chi tiết đánh giá
  - Thông tin lịch hẹn

## Cách sử dụng

### Cho khách hàng:
1. **Đặt lịch**: Truy cập `/appointments/new`
2. **Xem lịch hẹn**: Truy cập `/appointments/my-appointments`
3. **Hủy lịch**: Click nút "Hủy lịch" và nhập lý do
4. **Đánh giá**: Sau khi hoàn thành, click nút "Đánh giá"

### Cho admin:
1. **Quản lý lịch hẹn**: Truy cập `/admin/appointments`
2. **Hoàn thành lịch hẹn**: Click nút "Hoàn thành" cho lịch hẹn đã thực hiện

## Giao diện

### Các trang JSP mới:
- `myAppointments.jsp` - Danh sách lịch hẹn của user
- `createReview.jsp` - Form tạo đánh giá
- `employeeReviews.jsp` - Đánh giá của nhân viên
- `appointmentReview.jsp` - Chi tiết đánh giá lịch hẹn

### Tính năng giao diện:
- Responsive design với Bootstrap 5
- Icon Font Awesome
- Modal để hủy lịch hẹn
- Hệ thống đánh giá sao tương tác
- Hiển thị trạng thái với màu sắc khác nhau

## Bảo mật

### Kiểm tra quyền:
- User chỉ có thể hủy lịch hẹn của mình
- Chỉ đánh giá được lịch hẹn đã hoàn thành
- Admin mới có thể hoàn thành lịch hẹn
- Mỗi lịch hẹn chỉ đánh giá được 1 lần

### Validation:
- Kiểm tra trạng thái lịch hẹn trước khi thực hiện hành động
- Yêu cầu lý do khi hủy lịch hẹn
- Kiểm tra quyền đánh giá

## Triển khai

### Bước 1: Cập nhật cơ sở dữ liệu
```bash
mysql -u username -p < database_updates.sql
```

### Bước 2: Build và deploy
```bash
mvn clean package
# Deploy file WAR vào Tomcat
```

### Bước 3: Kiểm tra
- Truy cập `/appointments/my-appointments`
- Test chức năng hủy lịch
- Test chức năng đánh giá

## Lưu ý

- Đảm bảo user đã đăng nhập trước khi sử dụng các chức năng mới
- Cần có ít nhất 1 lịch hẹn đã hoàn thành để test chức năng đánh giá
- Các chức năng mới tương thích với hệ thống hiện tại
- Có thể mở rộng thêm tính năng như: thống kê đánh giá, báo cáo, v.v.
