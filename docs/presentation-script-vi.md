# Lời thoại Checkpoint 1 — một người nói toàn bộ

> Bản tham khảo cho deck 11 slide trước đây. Deck hiện tại có 13 slide; dùng
> [script tiếng Anh đã cập nhật](presentation-script-en.md) để khớp slide và thời gian.

**Người trình bày:** Trần Anh Dũng · 20226031

**Deck:** `presentation/checkpoint-1.pdf` hoặc bản HTML hiện tại, gồm 11 slide.

**Mục tiêu:** 15 phút trình bày, không tính hỏi đáp.

Phần nằm giữa các dấu `speech:start` và `speech:end` là lời để nói. Chỉ dẫn trong
ngoặc vuông là thao tác/ngắt nhịp, không đọc thành tiếng. Dùng đồng hồ và canh
mốc chuyển slide trong bảng. Bản này có gần 3.000 đơn vị tách bằng khoảng trắng,
được canh cho nhịp nói chậm, rõ khoảng 200 đơn vị/phút, gồm cả nhịp chỉ sơ đồ và
chuyển ý. Tốc độ thực tế cần được kiểm tra qua một lần tập có đồng hồ.

| Slide | Nội dung | Thời lượng | Mốc đồng hồ |
| --- | --- | --- | --- |
| 1 | Giới thiệu đề tài | 45 giây | 00:00–00:45 |
| 2 | Mục tiêu và chức năng | 1 phút 15 giây | 00:45–02:00 |
| 3 | Công nghệ và kiến trúc | 1 phút 30 giây | 02:00–03:30 |
| 4 | Định dạng và framing | 1 phút 30 giây | 03:30–05:00 |
| 5 | Message và phân quyền | 1 phút 15 giây | 05:00–06:15 |
| 6 | Luồng Test/Practice | 1 phút 30 giây | 06:15–07:45 |
| 7 | Sequence của một bài thi | 1 phút 30 giây | 07:45–09:15 |
| 8 | Data model: tài khoản/câu hỏi | 1 phút 30 giây | 09:15–10:45 |
| 9 | Data model: test/attempt/answer | 1 phút 45 giây | 10:45–12:30 |
| 10 | Filter, history và statistics | 1 phút 15 giây | 12:30–13:45 |
| 11 | Phân công, tiến độ, kế hoạch | 1 phút 15 giây | 13:45–15:00 |

## Slide 1 — Giới thiệu đề tài · 00:00–00:45

<!-- speech:start -->
Dạ em chào thầy và các bạn. Em là Trần Anh Dũng, đại diện nhóm trình bày
Checkpoint 1 của đề tài xây dựng ứng dụng thi trắc nghiệm trực tuyến.

Nhóm em có bốn thành viên là Trần Hữu Đức, Trần Anh Dũng, Trần Cao Phong và Lê
Diễm Hằng. Sản phẩm dự kiến hỗ trợ cả phòng thi nhiều người và chế độ tự luyện
tập, sử dụng mô hình client–server.

Trong bài này, em sẽ trình bày phạm vi chức năng, công nghệ, thiết kế giao tiếp,
data model, rồi đến phân công và tiến độ. Hiện nhóm đang ở giai đoạn thiết kế và
chuẩn bị môi trường, nên các sơ đồ là phương án triển khai dự kiến của nhóm.

Trọng tâm của nhóm là làm rõ cách nhiều client giao tiếp và dùng chung trạng thái
phòng thi trước khi bắt đầu triển khai các màn hình.
<!-- speech:end -->

[Dừng một nhịp, nhìn lớp. Chuyển slide khi đồng hồ khoảng 00:45.]

## Slide 2 — Mục tiêu và chức năng · 00:45–02:00

<!-- speech:start -->
Về mục tiêu, nhóm muốn xây dựng một ứng dụng mà người dùng có thể tổ chức một
bài thi có thời gian, hoặc tự làm bài luyện tập và theo dõi kết quả của mình.

Ở Test Mode, người dùng tạo phòng, chọn số câu hỏi và thời lượng. Những người
khác xem danh sách phòng cùng trạng thái, rồi tham gia khi bài thi chưa bắt đầu.
Người tạo phòng quyết định thời điểm bắt đầu hoặc kết thúc bài thi.

Trong khi làm bài, người tham gia được thay đổi lựa chọn và có thể nộp sớm. Nếu
chưa nộp khi hết giờ, server tự kết thúc bài và tính số câu đúng. Kết quả được lưu
để xem lại sau đó.

Practice Mode dành cho một người. Người dùng chọn số câu, thời gian, làm bài và
nhận điểm khi kết thúc. Các phần dùng chung gồm tài khoản, đăng nhập, phân quyền,
lọc câu hỏi theo chủ đề và độ khó, lịch sử, biểu đồ thống kê và giao diện đồ họa.

Nhóm xác định những chức năng này đều nằm trong phạm vi cần hoàn thành. Tiếp
theo em xin trình bày cách chia chúng giữa client và server.

Một điểm nhóm cần phân biệt là kết quả cá nhân và kết quả của cả phòng. Người
nộp sớm có thể nhận điểm của mình trước, nhưng phòng vẫn tiếp tục cho những người
chưa nộp. Bảng kết quả chung chỉ được mở khi phòng đã kết thúc.
<!-- speech:end -->

[Chỉ cột Test Mode rồi cột Practice. Không đọc lại nguyên các bullet. Mốc 02:00.]

## Slide 3 — Công nghệ và kiến trúc · 02:00–03:30

<!-- speech:start -->
Kiến trúc dự kiến có ba thành phần như trên hình: GUI client, C server và SQLite.

Phần server dùng C và POSIX TCP sockets. Đây cũng là cách lập trình socket nhóm
đã dùng trong các bài homework, với các lời gọi như socket, bind, listen, accept,
send và recv. Nhóm vẫn tự xử lý kết nối và dữ liệu TCP ở phía server.

Phần giao diện dự kiến dùng Python với Tkinter. Client kết nối TCP trực tiếp tới
C server, gửi thao tác của người dùng và hiển thị dữ liệu nhận về. Việc dùng
Tkinter giúp nhóm triển khai màn hình đăng nhập, phòng thi và bài làm thuận tiện
hơn, trong khi phần xử lý networking chính vẫn ở C.

SQLite lưu tài khoản, câu hỏi, bài thi, đáp án đã chọn và kết quả. cJSON hỗ trợ
đọc, tạo JSON; libsodium dùng để hash mật khẩu. Môi trường Linux và các thư viện
được đóng trong Docker Compose để thành viên có thể build với cùng công cụ.

Về xử lý nhiều người, nhóm dự kiến dùng pthread cho các connection và một bộ
kiểm tra deadline. Trạng thái dùng chung được bảo vệ bằng mutex. Server là nơi
quyết định quyền, thời gian và điểm; giao diện không tự quyết định bài còn được
nộp hay người dùng được bao nhiêu điểm.

Với quy mô project, SQLite giúp nhóm không cần vận hành một database server
riêng. File dữ liệu vẫn được giữ qua volume của Compose. Phía Tkinter, việc đọc
socket sẽ chạy ngoài luồng giao diện, để lúc chờ dữ liệu từ server thì người dùng
vẫn chuyển câu hỏi và thao tác được bình thường.
<!-- speech:end -->

[Chỉ client → server → database. Nói chậm các tên công nghệ; mốc 03:30.]

## Slide 4 — Định dạng và framing · 03:30–05:00

<!-- speech:start -->
Về application-layer protocol, nhóm chọn TCP với JSON Lines. Cần phân biệt hai
việc: JSON là định dạng biểu diễn dữ liệu, còn JSON Lines quy định mỗi message
là một JSON object kết thúc bằng một byte xuống dòng LF.

Trên slide, ký hiệu backslash n màu nâu là cách hiển thị byte LF có giá trị hex
không A. Khi truyền thật, server gửi byte xuống dòng, không gửi hai ký tự
backslash và chữ n.

Lý do cần framing là TCP chỉ cung cấp một luồng byte. Một lần recv có thể nhận
một phần message, hoặc nhận nhiều message cùng lúc. Vì vậy server phải giữ
buffer, xử lý các dòng hoàn chỉnh và giữ phần chưa đủ cho lần đọc tiếp theo.
Tương tự, send cũng có thể gửi chưa hết dữ liệu, nên nhóm dùng hàm send_all.

Dòng đầu là ví dụ client yêu cầu nộp một attempt. Request có request_id để ghép
với response tương ứng. Dòng dưới minh họa một event server chủ động gửi khi
phòng kết thúc; nó không phải response trực tiếp của dòng phía trên.

Nhóm giới hạn mỗi frame là sáu mươi tư KiB. Bộ câu hỏi được lấy theo từng trang
nhỏ, tối đa năm câu, để tránh một message chứa cả đề vượt giới hạn này.

Ví dụ, client gửi hai câu trả lời liên tiếp thì server có thể nhận cả hai trong
một recv. Ngược lại, một câu trả lời có thể bị chia sang hai lần recv. Ở cả hai
trường hợp, nội dung sau khi ghép vẫn phải được xử lý thành đúng số message,
không được dựa vào số lần recv để đếm request.
<!-- speech:end -->

[Chỉ dấu `\n`, rồi hai hướng gửi. Dừng một nhịp sau phần TCP không giữ ranh giới. Mốc 05:00.]

## Slide 5 — Message và quyền truy cập · 05:00–06:15

<!-- speech:start -->
Từ định dạng đó, nhóm đã chia message thành các nhóm theo chức năng. Slide chỉ
hiển thị những lệnh chính; tài liệu protocol có bảng field, response và lỗi cho
từng lệnh.

Nhóm tài khoản có đăng ký và đăng nhập. Sau khi đăng nhập thành công, server gắn
người dùng với connection hiện tại. Các request tiếp theo không được tự chọn một
user ID khác để thực hiện thao tác thay người đó.

Nhóm phòng thi có tạo, liệt kê, tham gia, bắt đầu và kết thúc. Ai đã đăng nhập
cũng có thể tạo phòng, nhưng chỉ chủ của phòng đó mới được bắt đầu hoặc kết
thúc nó.

Nhóm bài làm có lấy câu hỏi, lưu đáp án và nộp bài. Khi lưu, request chỉ rõ
attempt, câu hỏi và lựa chọn; server kiểm tra attempt thuộc người đang đăng nhập,
câu hỏi nằm trong đề và thời gian vẫn còn.

Response dùng chung một cấu trúc thành công hoặc mã lỗi. Ví dụ, không có quyền
và hết thời gian là hai mã khác nhau để giao diện hiển thị đúng. Nhóm cũng có
các lệnh riêng để lấy kết quả phòng, lịch sử và dữ liệu thống kê.

Quyền chủ phòng cũng không phải một loại tài khoản cố định. Cùng một người có
thể là chủ phòng do mình tạo, nhưng chỉ là người tham gia ở phòng của người khác.
Vì vậy server phải kiểm tra quan hệ với từng phòng, chứ không chỉ kiểm tra đã
đăng nhập hay chưa.
<!-- speech:end -->

[Không đọc từng tên command; lấy ROOM_START và ANSWER_SET làm ví dụ. Mốc 06:15.]

## Slide 6 — Luồng Test và Practice · 06:15–07:45

<!-- speech:start -->
Đối với Test Mode, nhóm chia vòng đời phòng thành ba trạng thái: chưa bắt đầu,
đang diễn ra và đã kết thúc.

Khi tạo phòng, chủ phòng nhập số câu, thời lượng và bộ lọc. Chủ phòng cũng được
thêm vào danh sách thành viên. Người khác chỉ được tham gia khi phòng chưa bắt
đầu. Server kiểm tra số câu trong ngân hàng có đủ với bộ lọc hay không; nếu không
đủ thì báo lỗi, thay vì tự thay đổi yêu cầu của người tạo.

Khi chủ phòng bắt đầu, server chọn bộ câu hỏi, cố định thứ tự, đặt deadline chung
và tạo bài làm riêng cho từng thành viên. Từ thời điểm này, thành viên không thể
tham gia thêm vào phòng.

Trong lúc làm bài, lưu lại cùng một câu sẽ thay đáp án trước đó. Nếu một người
nộp sớm, chỉ bài của người đó bị khóa. Những người khác vẫn tiếp tục làm tới khi
nộp hoặc hết giờ. Phòng kết thúc khi chủ phòng kết thúc, khi hết giờ, hoặc khi
tất cả mọi người đã nộp.

Practice Mode sử dụng cùng cách lưu đáp án và chấm điểm, nhưng chỉ có một người
và bắt đầu ngay sau khi chọn thiết lập. Cách dùng chung này giúp nhóm tránh viết
hai bộ logic chấm điểm khác nhau cho hai chế độ.

Ví dụ, phòng chọn hai mươi câu trong mười phút. Cả ba người nhận cùng bộ câu hỏi
và deadline. Nếu một người nộp ở phút thứ sáu, hai người còn lại vẫn có thể làm
tới phút thứ mười. Client hiển thị đồng hồ, còn quyền nhận đáp án tại thời điểm
nào vẫn do server quyết định.
<!-- speech:end -->

[Chỉ lần lượt ba trạng thái; nhấn mạnh nộp cá nhân khác kết thúc phòng. Mốc 07:45.]

## Slide 7 — Sequence một bài thi · 07:45–09:15

<!-- speech:start -->
Slide này ghép các thao tác vừa rồi thành một sequence rút gọn giữa GUI, server
và database. Em sẽ đi từ trên xuống dưới.

Đầu tiên, chủ phòng gửi ROOM_START. Server xác nhận quyền và trạng thái, rồi lưu
bộ câu hỏi, deadline và các attempt trong một transaction. Chỉ sau khi lưu thành
công, server mới báo TEST_STARTED cho các thành viên.

Client nhận được attempt ID và deadline, sau đó dùng QUESTIONS_GET để lấy các
trang câu hỏi. Trên hình, phần thông báo bắt đầu và trả trang được gộp cho dễ
theo dõi. Đáp án đúng không nằm trong dữ liệu câu hỏi gửi xuống.

Khi người dùng chọn một đáp án, client gửi ANSWER_SET. Server kiểm tra điều kiện,
ghi lựa chọn vào database rồi mới xác nhận đã lưu. Như vậy, giao diện không nên
hiện đã lưu khi dữ liệu chưa được commit.

Khi nhận ATTEMPT_SUBMIT, server chấm bài và lưu kết quả cuối. Nếu người dùng gửi
lại yêu cầu nộp cho bài đã kết thúc, server trả kết quả đã lưu, không tạo thêm
một bài làm hay chấm thành hai lần.

Trường hợp hết giờ cũng đi vào cùng đường xử lý kết thúc. Mọi request lưu hoặc
nộp đều kiểm tra giờ của server, nên việc giao diện chạy chậm hay sửa đồng hồ
client không làm kéo dài thời gian thi.

Nếu client bị mất kết nối, những đáp án đã được xác nhận vẫn còn trong database.
Thời gian thi cũng không dừng lại. Sau khi đăng nhập lại, người dùng lấy lại
attempt đang hoạt động và các lựa chọn đã lưu, với cùng deadline như trước.
<!-- speech:end -->

[Dùng con trỏ đi theo từng mũi tên. Không bỏ qua khoảng ngắt khi chuyển từ lưu đáp án sang nộp bài. Mốc 09:15.]

## Slide 8 — Data model tài khoản và câu hỏi · 09:15–10:45

<!-- speech:start -->
Phần data model được tách thành hai slide. Slide đầu tập trung vào tài khoản và
ngân hàng câu hỏi; slide sau là dữ liệu bài thi và bài làm.

Ở phía trên, users lưu tài khoản với username duy nhất và password hash. sessions
lưu các lần đăng nhập, thời điểm hết hạn và lý do kết thúc. Một tài khoản có thể
có nhiều session trong lịch sử, nhưng thiết kế ban đầu chỉ cho phép một session
đang hoạt động tại một thời điểm.

Quan hệ một–nhiều ở đây vì vậy không có nghĩa người dùng đang đăng nhập đồng
thời trên nhiều máy. Khi logout, connection ngắt hoặc session hết hạn, session
đó được đóng lại và người dùng có thể đăng nhập lần mới.

Ở phía dưới, mỗi câu hỏi thuộc một topic và có một mức độ khó. question_choices
lưu bốn lựa chọn A đến D. Câu hỏi có một correct key tham chiếu tới một lựa chọn
của chính câu đó. Khi chuẩn bị ngân hàng, server còn phải kiểm tra đủ bốn lựa
chọn, vì chỉ có foreign key thì chưa đảm bảo đủ số lượng.

Một quy tắc quan trọng nữa là nội dung câu hỏi đã được dùng trong bài thi sẽ
không bị sửa trực tiếp. Nếu cần chỉnh, nhóm tạo bản ghi câu hỏi mới. Điều này giữ
cho kết quả và lịch sử cũ vẫn phản ánh đúng đề mà người dùng từng làm.

Password hash ở đây bảo vệ dữ liệu mật khẩu được lưu, không có nghĩa kết nối TCP
tự được mã hóa. Bản đầu dự kiến chạy trong môi trường lớp học hoặc mạng nội bộ.
Nhóm sẽ không mô tả hệ thống hiện tại như một kết nối đã có bảo mật truyền tải
khi chưa triển khai phần đó.
<!-- speech:end -->

[Chỉ users–sessions trước, rồi topics–questions–choices. Mốc 10:45.]

## Slide 9 — Data model test, attempt và answer · 10:45–12:30

<!-- speech:start -->
Ở slide này, điểm chính là tách test dùng chung và attempt của từng người.

tests lưu cấu hình của bộ đề: chế độ phòng thi hay luyện tập, số câu, thời lượng,
trạng thái và deadline. test_members lưu ai đã tham gia. Khi phòng còn chờ, một
thành viên đã có membership nhưng chưa có attempt. Khi phòng bắt đầu, server mới
tạo attempt cho từng thành viên.

Ví dụ, một phòng có ba người thì có một test và ba attempt. Nếu người thứ nhất
nộp sớm, trạng thái attempt của người đó chuyển sang đã nộp. Hai attempt còn lại
vẫn đang làm, nên không thể dùng trạng thái của phòng để thay cho trạng thái
từng bài làm.

test_questions cố định những câu hỏi được chọn và thứ tự của chúng. answers lưu
lựa chọn theo attempt và câu hỏi. Mỗi câu chỉ có một đáp án hiện tại trong một
attempt; việc chọn lại sẽ cập nhật bản ghi đó.

Các foreign key kết hợp bảo đảm một answer thuộc đúng test của attempt, câu hỏi
nằm trong bộ đề đã chọn và lựa chọn tồn tại cho câu hỏi đó. Những điều kiện phụ
thuộc vào thời gian hoặc quyền, như còn được sửa đáp án hay không, vẫn phải được
C service kiểm tra khi xử lý request.

Practice cũng dùng các bảng này, nhưng test riêng chỉ có một thành viên và một
attempt. Ngoài phần chính trên hình, schema còn có bảng lưu bộ lọc topic, độ khó
và activity log. Nhóm đã viết schema SQL cụ thể, còn slide chỉ giữ các quan hệ
quan trọng để dễ theo dõi.

Chẳng hạn, nếu client gửi đáp án cho câu ở một phòng khác, việc biết question ID
chưa đủ để được ghi dữ liệu. Nó phải khớp cả test và attempt của người đó. Đây
là lý do nhóm dùng quan hệ và ràng buộc kết hợp, thay vì chỉ có một bảng answer
trỏ trực tiếp tới user và question.
<!-- speech:end -->

[Chỉ sơ đồ theo tests → members → attempts, rồi test_questions → answers. Dừng sau ví dụ ba người. Mốc 12:30.]

## Slide 10 — Filter, history và statistics · 12:30–13:45

<!-- speech:start -->
Từ data model đó, nhóm triển khai phần chọn câu hỏi và xem lại kết quả.

Khi tạo test hoặc practice, người dùng chọn topic, difficulty và số câu. Server
lọc ngân hàng theo các điều kiện này rồi chọn các câu khác nhau. Trong cùng một
phòng, các thành viên nhận cùng bộ câu hỏi và cùng thứ tự.

Sau khi bài đã kết thúc, history lưu lại loại bài, thời gian, số câu đúng, tổng
số câu và lý do kết thúc, chẳng hạn nộp sớm hay hết giờ. Người dùng chỉ xem được
lịch sử và thống kê cá nhân của mình.

Biểu đồ bên phải là dữ liệu minh họa: năm lần làm bài có điểm lần lượt là năm,
sáu, bốn, bảy và tám trên mười. Tổng là ba mươi câu đúng trên năm mươi câu, tương
ứng sáu mươi phần trăm.

Nếu các bài có số câu khác nhau, nhóm dùng tỷ lệ phần trăm để so sánh. Thống kê
chỉ tính attempt đã kết thúc; câu không trả lời vẫn tính sai. Khi chưa có lịch
sử thì giao diện hiện chưa có dữ liệu, không tạo điểm mẫu cho người dùng.

Ví dụ một bài đúng tám trên mười và bài khác đúng mười trên hai mươi: tổng là
mười tám trên ba mươi, tức sáu mươi phần trăm. Nhóm tính từ tổng số câu để phản
ánh chính xác kết quả, thay vì cộng hai điểm thô hoặc lấy trung bình phần trăm
mà không xét số câu của từng bài.
<!-- speech:end -->

[Chỉ vài cột để minh họa, không đọc nhãn trục. Nhấn mạnh chart hiện là sample. Mốc 13:45.]

## Slide 11 — Phân công, tiến độ và kế hoạch · 13:45–15:00

<!-- speech:start -->
Cuối cùng là phân công và tiến độ của nhóm.

Em phụ trách điều phối, kiến trúc, thống nhất protocol và tích hợp. Đức phụ trách
phần C TCP server và vòng đời phòng thi. Phong phụ trách database, tài khoản,
session, phân quyền và log. Hằng phụ trách GUI client, lịch sử, thống kê và kiểm
thử đầu cuối.

Đến checkpoint này, nhóm đã chuẩn bị repo riêng, môi trường Docker Compose, luồng
chức năng, ERD, schema SQL và bản thiết kế protocol. Có mười hai kiểm tra schema
đã chạy qua, chủ yếu kiểm tra quan hệ, ràng buộc và query chấm điểm minh họa.

Phần này chưa phải kiểm thử end-to-end của ứng dụng. Hiện các C handler và GUI
chưa được triển khai. Bước tiếp theo là làm TCP framing và một vòng request–response
tối thiểu, rồi tới tài khoản, ngân hàng câu hỏi và phần attempt/chấm điểm dùng
chung. Sau đó nhóm tích hợp phòng thi, deadline, GUI và history/statistics.

Khi có các phần chạy được, nhóm sẽ kiểm tra thêm nhiều người cùng tham gia,
đổi đáp án sát deadline và nộp sớm. Đây là các tình huống dễ làm lệch trạng thái,
nên cần kiểm tra trên client và server thực tế, ngoài các ràng buộc database.

Trên đây là phương án thiết kế và kế hoạch hiện tại của nhóm. Nhóm mong nhận được
góp ý của thầy về kiến trúc, protocol và cách tổ chức dữ liệu trước khi triển
khai. Em cảm ơn thầy và các bạn đã lắng nghe.
<!-- speech:end -->

[Kết thúc khoảng 15:00, nhìn thầy và dừng. Hỏi đáp bắt đầu sau phần trình bày.]

## Cách tập và điều chỉnh thời gian

- Tập một lượt có đồng hồ, không dừng để sửa câu. Ghi thời điểm kết thúc mỗi slide.
- Nếu nhanh hơn mốc dưới 10 giây: dừng, chỉ sơ đồ và để người nghe nhìn trước khi
  chuyển. Không đọc thêm tên field/command để lấp thời gian.
- Nếu chậm hơn 10–20 giây: bỏ một ví dụ hoặc câu chuyển ý ở slide tiếp theo, giữ
  định nghĩa và quyết định thiết kế chính.
- Nếu chậm hơn 30 giây từ slide 9: bỏ đoạn giải thích schema ngoài hình; ở slide
  10 chỉ nói nguyên tắc phần trăm và dữ liệu mẫu. Giữ phần tiến độ thật ở slide 11.
- Không chạy demo ứng dụng trong bài nói: hiện chưa có C server/GUI hoàn chỉnh.
