# Sổ tay Dart & Flutter cho dự án `dat_chat`

> Tài liệu này tổng hợp **toàn bộ** kiến thức Dart/Flutter/Firebase/Riverpod đang được dùng trong dự án này,
> giải thích từ cú pháp đến kiến trúc, kèm chính đoạn code trong repo làm ví dụ.
> Đọc xong file này là đủ để code tiếp mà không cần mở lại tài liệu ngoài.

---

## Mục lục

1. [Bản đồ dự án](#1-bản-đồ-dự-án)
2. [Kiến trúc 3 tầng: Screen → Controller → Repository](#2-kiến-trúc-3-tầng-screen--controller--repository)
3. [Dart: nền tảng ngôn ngữ](#3-dart-nền-tảng-ngôn-ngữ)
4. [Dart: bất đồng bộ — Future & Stream](#4-dart-bất-đồng-bộ--future--stream)
5. [Flutter: Widget & cây widget](#5-flutter-widget--cây-widget)
6. [Flutter: layout & các widget dùng trong dự án](#6-flutter-layout--các-widget-dùng-trong-dự-án)
7. [Flutter: điều hướng (Navigator & Routes)](#7-flutter-điều-hướng-navigator--routes)
8. [Riverpod: quản lý state](#8-riverpod-quản-lý-state)
9. [Firebase: Auth, Firestore, Storage](#9-firebase-auth-firestore-storage)
10. [Cấu trúc dữ liệu Firestore của app](#10-cấu-trúc-dữ-liệu-firestore-của-app)
11. [Đa ngôn ngữ (l10n)](#11-đa-ngôn-ngữ-l10n)
12. [Các package bên thứ ba](#12-các-package-bên-thứ-ba)
13. [Đi hết 1 luồng: gửi tin nhắn từ A đến Z](#13-đi-hết-1-luồng-gửi-tin-nhắn-từ-a-đến-z)
14. [Nợ kỹ thuật & bug đang tồn tại](#14-nợ-kỹ-thuật--bug-đang-tồn-tại)
15. [Công thức thêm 1 feature mới](#15-công-thức-thêm-1-feature-mới)
16. [Cheatsheet lệnh](#16-cheatsheet-lệnh)

---

## 1. Bản đồ dự án

```
lib/
├── main.dart                    # Điểm khởi động: init Firebase + ProviderScope + MaterialApp
├── router.dart                  # Bảng định tuyến (onGenerateRoute)
├── colors.dart                  # Bảng màu tĩnh (class Coloors)
├── firebase_options.dart        # File sinh tự động bởi FlutterFire CLI
├── info.dart                    # Data giả (mock) từ thời làm UI — không còn dùng
├── constant/size.dart           # getSize(context)  ← trùng với common/utils/size_screen.dart
│
├── models/                      # Lớp dữ liệu thuần (POJO) + toMap/fromMap
│   ├── user_model.dart
│   ├── chat_contact.dart
│   ├── message_model.dart
│   └── group_model.dart
│
├── common/                      # Thứ dùng chung nhiều feature
│   ├── config/theme.dart
│   ├── enum/message_enum.dart          # enum nâng cao + extension
│   ├── provider/                       # Provider state toàn cục nhỏ
│   ├── repositories/                   # Repository dùng chung (Storage)
│   ├── utils/                          # Hàm tiện ích: snackbar, pick ảnh, size
│   └── widgets/                        # Widget tái sử dụng: nút, appbar, ô nhập chat
│
├── screens/                     # Màn hình "trơ": Loader, ErrorScreen, layout
│
└── features/                    # Mỗi feature 1 thư mục, gồm screen + controller + repository
    ├── auth/                    # Đăng nhập SĐT + OTP + nhập thông tin
    ├── landing/                 # Màn hình chào
    ├── list_chat/               # Danh sách hội thoại + nhóm
    ├── chat/                    # Màn hình chat
    ├── create_group/            # Tạo nhóm
    └── select_contacts/         # Chọn danh bạ
```

**Quy ước đặt tên trong repo:** mỗi feature có 3 file lõi
`<feature>_screen.dart` (UI) · `<feature>_controller.dart` (logic + provider) · `<feature>_repository.dart` (gọi Firebase).

---

## 2. Kiến trúc 3 tầng: Screen → Controller → Repository

Đây là xương sống của dự án. Nắm được cái này là hiểu 80% code.

```
┌──────────────┐  ref.read(xProvider)   ┌─────────────┐   gọi trực tiếp   ┌──────────────┐
│   Screen     │ ─────────────────────▶ │ Controller  │ ────────────────▶ │  Repository  │ ──▶ Firebase
│ (Consumer*)  │ ◀───── Stream/Future ──│             │ ◀──── Stream ─────│              │
└──────────────┘                        └─────────────┘                   └──────────────┘
```

- **Repository** — *chỉ* biết Firebase. Nhận/trả `Future`/`Stream` và `Model`. Không biết gì về UI.
- **Controller** — cầu nối. Đôi khi có thêm logic nhỏ (ví dụ chuyển `0` → `+84` ở `CreateGroupController.getUserByPhone`).
- **Screen** — vẽ UI, lắng nghe stream, đọc controller qua `ref`.

Mỗi tầng được *đóng gói* trong một Riverpod `Provider` để tầng trên lấy ra:

```dart
// lib/features/chat/chat_repository.dart:12
final chatRepositoryProvider = Provider((ref) {
  return ChatRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

// lib/features/chat/chat_controller.dart:11
final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider); // ← lấy tầng dưới ra
  return ChatController(ref: ref, chatRepository: chatRepository);
});
```

Ở màn hình:

```dart
// lib/features/chat/chat_screen.dart:56
ref.read(chatControllerProvider).setStatus(true);
```

> **Vì sao lồng provider vào nhau?** Để đổi implementation (ví dụ dùng Firestore giả khi test)
> chỉ cần override 1 provider ở `ProviderScope(overrides: [...])`, không phải sửa code màn hình.

---

## 3. Dart: nền tảng ngôn ngữ

### 3.1 Khai báo biến: `var`, `final`, `const`, `late`

```dart
var contacts = [];                     // kiểu được suy ra, giá trị đổi được
final phoneController = TextEditingController();  // gán 1 lần, lúc chạy
const routeName = '/login-screen';     // hằng số biết được lúc BIÊN DỊCH
late TabController tabBarController;   // hứa "sẽ gán trước khi dùng"
```

- `final` vs `const`: `final` gán 1 lần khi chạy; `const` phải tính được lúc compile.
  `Coloors.backgroundColor` là `const` nên có thể dùng trong `const` constructor.
- `late` dùng khi biến không thể khởi tạo ngay ở chỗ khai báo, ví dụ `TabController` cần `vsync: this`
  mà `this` chỉ có trong `initState`:

```dart
// lib/features/list_chat/list_chat_screen.dart:18
late TabController tabBarController;

@override
void initState() {
  super.initState();
  tabBarController = TabController(length: 3, vsync: this);
}
```

> Cảnh báo: đọc biến `late` trước khi gán → crash `LateInitializationError` lúc chạy, không phải lỗi biên dịch.

### 3.2 Null safety — dấu `?`, `!`, `??`, `?.`, `??=`

Dart bật null-safety mặc định. `String` **không bao giờ** null; muốn null phải viết `String?`.

| Ký hiệu | Ý nghĩa | Ví dụ trong repo |
|---|---|---|
| `Type?` | có thể null | `Country? country;` (login_screen.dart:23) |
| `!` | *khẳng định* không null (crash nếu sai) | `auth.currentUser!.uid` |
| `?.` | gọi an toàn, null thì trả null | `auth.currentUser?.uid` |
| `??` | giá trị mặc định khi null | `map['name'] ?? ''` |
| `??=` | gán nếu đang null | (chưa dùng trong repo) |

Ví dụ đầy đủ trong repo:

```dart
// lib/models/user_model.dart:51 — dùng ?? để chống dữ liệu thiếu field
factory UserModel.fromMap(Map<String, dynamic> map) {
  return UserModel(
    uid: map['uid'] ?? '',
    isOnline: map['isOnline'] ?? false,
    ...
  );
}
```

```dart
// lib/features/auth/repository/auth_repository.dart:26 — kiểm null rồi mới dùng !
var userData = await firestore.collection('users').doc(auth.currentUser?.uid).get();
UserModel? user;
if (userData.data() != null) {
  user = UserModel.fromMap(userData.data()!);   // đã check ở trên nên ! an toàn
}
return user;   // kiểu trả về là UserModel? — có thể null
```

**Quy tắc thực dụng:** `!` chỉ dùng khi bạn *vừa* kiểm tra null ở dòng trên, hoặc chắc chắn về invariant
(ví dụ `auth.currentUser!` ở màn hình chỉ vào được sau khi đăng nhập).

### 3.3 Class, constructor, named parameters, `required`

```dart
// lib/models/message_model.dart
class Message {
  final String senderId;      // final field → immutable object
  final MessageEnum type;
  final DateTime timeSent;

  Message({                   // ← constructor với NAMED parameters (trong {})
    required this.senderId,   // required = bắt buộc truyền
    required this.type,
    required this.timeSent,
  });
}
```

Ba kiểu tham số trong Dart:

```dart
void a(String x, int y)              // positional bắt buộc:  a('hi', 1)
void b(String x, [int y = 0])        // positional tuỳ chọn:  b('hi')
void c({required String x, int y = 0}) // named:              c(x: 'hi')
```

Dự án dùng **named + required** gần như ở mọi nơi vì nó tự-tài-liệu-hoá:

```dart
// lib/features/chat/chat_controller.dart:26
void sendMessage({
  required BuildContext context,
  required String text,
  required String recieverUserId,
  required String repliedTo,
  required String repliedMessage,
  required String groupId,
}) { ... }
```

`this.senderId` trong danh sách tham số là **initializing formal** — viết tắt của "nhận giá trị rồi gán vào field".

### 3.4 `factory` constructor

`factory` là constructor **không bắt buộc tạo instance mới** — nó chỉ cần *trả về* một instance.
Dùng để "chế biến" dữ liệu trước khi tạo object:

```dart
// lib/models/chat_contact.dart:49
factory ChatContactModel.fromMap(Map<String, dynamic> map) {
  return ChatContactModel(
    name: map['name'] as String,
    profilePic: map['profilePic'] as String,
    ...
  );
}

// lib/models/chat_contact.dart:62 — factory gọi factory khác
factory ChatContactModel.fromJson(String source) =>
    ChatContactModel.fromMap(json.decode(source) as Map<String, dynamic>);
```

Constructor thường (`ChatContactModel({...})`) **không** được có thân hàm chứa `return`.
Vì `fromMap` cần tính toán rồi mới `return` → phải là `factory`.

### 3.5 `copyWith` — cập nhật object bất biến

Vì field là `final`, muốn "sửa" phải tạo bản sao mới:

```dart
// lib/models/user_model.dart:22
UserModel copyWith({
  String? uid,
  String? name,
  ...
}) {
  return UserModel(
    uid: uid ?? this.uid,        // truyền gì thì lấy cái đó, không thì giữ nguyên
    name: name ?? this.name,
    ...
  );
}
```

Dùng: `user.copyWith(isOnline: false)` → object mới, chỉ khác 1 field.

### 3.6 Serialize: `toMap` / `fromMap` / `toJson` / `fromJson`

Firestore nhận và trả về `Map<String, dynamic>`. Model phải tự chuyển đổi:

```dart
// lib/models/message_model.dart:28
Map<String, dynamic> toMap() {
  return {
    'senderId': senderId,
    'type': type.type,                              // enum → String
    'timeSent': timeSent.millisecondsSinceEpoch,    // DateTime → int
    'isSeen': isSeen,
  };
}

factory Message.fromMap(Map<String, dynamic> map) {
  return Message(
    senderId: map['senderId'] ?? '',
    type: (map['type'] as String).toEnum(),                        // String → enum
    timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']), // int → DateTime
    isSeen: map['isSeen'] ?? false,
  );
}
```

> Firestore **không** lưu được `DateTime` của Dart hay `enum`. Phải quy về kiểu nguyên thuỷ:
> `String`, `int`, `double`, `bool`, `List`, `Map`, `null`, `Timestamp`, `GeoPoint`, `Blob`.
>
> Trong repo có **2 cách lưu thời gian song song** (nên biết để tránh nhầm):
> - `Message.timeSent` → `millisecondsSinceEpoch` (int)
> - `ChatContactModel.timeSend`, `GroupModel.timeSent` → `toIso8601String()` (String)

`toJson`/`fromJson` là lớp bọc thêm dùng `dart:convert`:

```dart
import 'dart:convert';
String toJson() => json.encode(toMap());
factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));
```

### 3.7 Override `toString`, `==`, `hashCode`

Mặc định `==` trong Dart là so sánh **địa chỉ** (identity). Hai object cùng dữ liệu vẫn `!=`.
`CreateGroupScreen` cần `listMember.contains(user)` hoạt động đúng → `UserModel` phải override `==`:

```dart
// lib/models/user_model.dart:72
@override
bool operator ==(Object other) {
  if (identical(this, other)) return true;                    // cùng object → true ngay
  final listEquals = const DeepCollectionEquality().equals;   // so sánh List sâu

  return other is UserModel &&
      other.uid == uid &&
      other.name == name &&
      ...
      listEquals(other.groupIds, groupIds);
}

@override
int get hashCode => uid.hashCode ^ name.hashCode ^ ... ;
```

**Luật bắt buộc:** override `==` thì *phải* override `hashCode`, nếu không `Set`/`Map` sẽ hỏng.
`^` là XOR — cách gộp hash phổ biến (không phải cách tốt nhất, nhưng đủ dùng).

`GroupModel` dùng biến thể khác:

```dart
// lib/models/group_model.dart:79
@override
bool operator ==(covariant GroupModel other) { ... }
```

`covariant` cho phép thu hẹp kiểu tham số từ `Object` xuống `GroupModel` — tiện hơn nhưng
mất an toàn nếu so sánh với kiểu khác. `listEquals` ở đây đến từ `package:flutter/foundation.dart`.

`toString()` override để `debugPrint(user)` in ra dữ liệu thay vì `Instance of 'UserModel'`.

### 3.8 Enum nâng cao (enhanced enum) + Extension

Dart 2.17+ cho phép enum có field và constructor:

```dart
// lib/common/enum/message_enum.dart
enum MessageEnum {
  text('text'),      // ← mỗi hằng số gọi constructor
  image('image'),
  audio('audio'),
  video('video'),
  gif('gif');

  const MessageEnum(this.type);   // constructor phải là const
  final String type;
}
```

Dùng: `MessageEnum.text.type` → `'text'`.

**Extension** = thêm method vào class có sẵn mà không sửa class đó:

```dart
extension ConvertMessage on String {
  MessageEnum toEnum() {
    switch (this) {          // `this` chính là String đang gọi
      case 'audio': return MessageEnum.audio;
      case 'image': return MessageEnum.image;
      ...
      default: return MessageEnum.text;
    }
  }
}
```

Nhờ vậy viết được `(map['type'] as String).toEnum()` — như thể `String` có sẵn method `toEnum`.
Extension chỉ có hiệu lực khi file định nghĩa nó được `import`.

> Có thể thay bằng `MessageEnum.values.byName('text')` (built-in), nhưng nó **ném exception**
> nếu tên sai, còn extension ở đây trả về `text` mặc định — an toàn hơn với dữ liệu bẩn.

### 3.9 Private constructor & class chỉ chứa hằng

```dart
// lib/colors.dart
class Coloors {
  const Coloors._();          // constructor private → không ai new được Coloors()
  static const backgroundColor = Color.fromRGBO(19, 28, 33, 1);
  static const tabColor        = Color.fromRGBO(0, 167, 131, 1);
  ...
}
```

Dấu `_` đầu tên = **private với library (file)**, không phải private với class như Java.
`Coloors._()` chặn việc khởi tạo vô nghĩa; class chỉ đóng vai namespace cho hằng số.

`Color.fromRGBO(r, g, b, opacity)` — opacity là `double` 0.0–1.0.

### 3.10 Collection: spread, `if` trong collection, các method hay dùng

```dart
// lib/features/create_group/create_group_repository.dart:55
membersUid: [...membersIds, auth.currentUser!.uid],   // spread operator
```

`...` "đổ" các phần tử của list này vào list kia. Có `...?` cho list nullable.

```dart
// lib/features/chat/widgets/my_message_card.dart:41
Stack(
  children: [
    if (replyMessage != '')       // ← collection-if: chỉ thêm widget khi điều kiện đúng
      Positioned(...),
    Column(...),
  ],
)
```

Đây là cú pháp cực kỳ hay dùng trong Flutter để hiện/ẩn widget mà không cần ternary với `SizedBox()`.
Cũng có `for` trong collection: `[for (var u in users) Text(u.name)]`.

Method hay dùng trong repo:

```dart
List<String>.from(map['membersUid'] ?? [])  // ép List<dynamic> → List<String>
phoneController.text.trim()                 // bỏ khoảng trắng 2 đầu
phoneNumber.replaceAll(' ', '')             // thay tất cả
phoneNumber.replaceFirst('0', '+84')        // thay lần đầu tiên
listMember.contains(user)                   // cần == override
listMember.removeAt(index)
contacts.add(item)
querySnapshot.docs.first
snapshot.data!.isEmpty
```

> `List<String>.from(...)` cần thiết vì Firestore trả `List<dynamic>`; gán thẳng vào `List<String>` sẽ crash.

### 3.11 Interpolation chuỗi

```dart
debugPrint('+${country!.phoneCode}$phoneNumber');   // ${biểu thức} và $biến
'Replying to ${messageReply!.username}'
'Group data: ${document.data()}'
```

`$ten` cho biến đơn giản, `${...}` khi có dấu chấm/biểu thức.

### 3.12 Arrow function & closure

```dart
void showKeyboard() => focusNode.requestFocus();   // => là "return <biểu thức>;"

onPressed: () {},                    // hàm vô danh không tham số
onSelect: (Country c) { ... },       // hàm vô danh có tham số
(route) => false,                    // predicate cho Navigator
```

`VoidCallback` là typedef của `void Function()` — dùng ở `CustomButton`:

```dart
// lib/common/widgets/custom_button.dart:6
final VoidCallback? onPress;
```

### 3.13 Generics

```dart
Stream<List<Message>> getListMessages(String id)     // Stream chứa List chứa Message
Future<UserModel?> getUserData()
Map<String, dynamic> toMap()
StreamBuilder<List<GroupModel>>( ... )
Provider<ListChatController>((ref) => ...)
FutureProvider.family<UserModel?, String>(...)       // 2 tham số kiểu
```

Khi khai báo `StreamBuilder<T>`, `snapshot.data` sẽ có kiểu `T?` — nếu bỏ `<T>` thì thành `dynamic`
và mất hết type-check. Luôn ghi rõ.

### 3.14 Try / catch / on / rethrow

```dart
// lib/features/auth/repository/auth_repository.dart:55
try {
  await auth.verifyPhoneNumber(...);
} on FirebaseAuthException catch (e) {     // bắt đúng loại exception
  showSnackbar(context: context, content: e.message ?? "");
}
```

```dart
// lib/features/create_group/create_group_repository.dart:36
} catch (e) {                              // bắt mọi thứ
  print('Lỗi khi tìm user: $e');
  rethrow;                                 // ném lại cho tầng trên xử lý
}
```

- `on X catch (e)` — chỉ bắt exception kiểu `X`.
- `catch (e, stackTrace)` — lấy thêm stack trace.
- `rethrow` giữ nguyên stack trace gốc, khác với `throw e` (reset stack).
- `finally { }` — luôn chạy.

### 3.15 `as`, `is`, ép kiểu

```dart
final verificationId = setting.arguments as String;              // ép kiểu, crash nếu sai
final args = setting.arguments as Map<String, dynamic>;
if (other is UserModel && other.uid == uid)                      // is: kiểm tra + tự động promote
```

Sau `if (x is UserModel)`, Dart **tự động** coi `x` là `UserModel` trong khối đó (type promotion).

---

## 4. Dart: bất đồng bộ — Future & Stream

Đây là phần quan trọng nhất khi làm app chat.

### 4.1 `Future` = một giá trị sẽ có trong tương lai

```dart
// lib/features/create_group/create_group_repository.dart:22
Future<UserModel?> findUserByPhoneNumber(String phoneNumber) async {
  final querySnapshot = await firestore
      .collection('users')
      .where('phoneNumber', isEqualTo: phoneNumber)
      .limit(1)
      .get();                      // .get() trả Future → await để lấy kết quả

  if (querySnapshot.docs.isEmpty) return null;
  return UserModel.fromMap(querySnapshot.docs.first.data());
}
```

Luật:
- Hàm có `await` bên trong **phải** đánh dấu `async`.
- Hàm `async` luôn trả `Future<T>` (kể cả khi bạn viết `return 5`, nó thành `Future<int>`).
- `Future<void>` cho hàm async không trả giá trị.

**Bẫy `async` + `void`** — repo dùng rất nhiều:

```dart
// lib/features/chat/chat_repository.dart:169
void sendTextMessage({...}) async { ... }
```

Kiểu trả về là `void` chứ không phải `Future<void>` → **người gọi không thể `await`**.
Hệ quả: `createGroup()` gọi `creatGroup()` mà không đợi xong, nên `Navigator.pop` ở
`create_group_screen.dart:88` có thể chạy trước khi Firestore ghi xong.
Nên đổi thành `Future<void>` khi refactor.

### 4.2 `Stream` = nhiều giá trị theo thời gian

Chat realtime = stream. Firestore `.snapshots()` trả `Stream<QuerySnapshot>`:

```dart
// lib/features/chat/chat_repository.dart:27
Stream<List<Message>> getListMessages(String recieverUserId) {
  return firestore
      .collection('users')
      .doc(auth.currentUser!.uid)
      .collection('chats')
      .doc(recieverUserId)
      .collection('messages')
      .orderBy('timeSent', descending: false)
      .snapshots()                       // Stream<QuerySnapshot>
      .asyncMap((event) {                // biến đổi từng "lần bắn"
        List<Message> messages = [];
        for (var doc in event.docs) {
          messages.add(Message.fromMap(doc.data()));
        }
        return messages;                 // Stream<List<Message>>
      });
}
```

Mỗi khi có tin nhắn mới trong Firestore → `.snapshots()` bắn 1 giá trị mới → `asyncMap` chuyển
thành `List<Message>` → `StreamBuilder` trên UI rebuild. Không cần refresh thủ công.

**`map` vs `asyncMap`:**

| | `map` | `asyncMap` |
|---|---|---|
| Callback | đồng bộ, trả `T` | có thể `async`, trả `Future<T>` |
| Khi nào dùng | chuyển đổi thuần | cần `await` bên trong |

Repo dùng cả hai:

```dart
// map — thuần chuyển đổi (chat_repository.dart:45)
.snapshots().map((event) { ... return messages; });

// asyncMap — cần await gọi thêm Firestore (list_chat_repository.dart:31)
.snapshots().asyncMap((event) async {
  for (var doc in event.docs) {
    var userData = await firestore.collection('users').doc(chatContact.contactId).get();
    ...
  }
  return contacts;
});
```

> Lưu ý hiệu năng: `getChatContacts()` gọi thêm 1 request Firestore **cho mỗi contact, mỗi lần stream bắn**.
> Có 20 cuộc trò chuyện = 20 request mỗi lần ai đó nhắn tin. Đây là chỗ tối ưu rõ ràng
> (nên lưu sẵn `name`/`profilePic` vào document chat contact — mà thực ra repo đã lưu rồi, chỉ là không dùng).

`Stream.value([])` tạo một stream bắn đúng 1 giá trị rồi đóng — dùng làm fallback:

```dart
// lib/features/list_chat/list_chat_repository.dart:68
return Stream.value([]);
```

### 4.3 `await` trong vòng lặp vs song song

```dart
for (var doc in event.docs) {
  var userData = await firestore...get();   // tuần tự, chậm
}
```

Muốn nhanh hơn: `await Future.wait(docs.map((d) => firestore...get()))`. Repo chưa dùng, nhưng nên biết.

---

## 5. Flutter: Widget & cây widget

### 5.1 Mọi thứ đều là Widget

Widget là **mô tả bất biến** của một phần UI. Flutter dựng cây widget → cây element → cây render.
Bạn không "sửa" widget, bạn **tạo lại** widget mới và Flutter so sánh (diff) để cập nhật màn hình.

### 5.2 `StatelessWidget`

Không có state nội bộ. Vẽ lại chỉ khi tham số đầu vào đổi.

```dart
// lib/common/widgets/custom_button.dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPress;
  const CustomButton({super.key, required this.text, this.onPress});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: Coloors.tabColor,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text, style: TextStyle(color: Coloors.blackColor)),
    );
  }
}
```

`super.key` — cú pháp Dart 2.17 "super parameter", tương đương `Key? key}) : super(key: key)`.
`Key` giúp Flutter nhận diện widget khi danh sách bị sắp xếp lại; hầu hết trường hợp không cần đụng tới.

Trong repo dùng: `CustomButton`, `CustomAppbar`, `Loader`, `ErrorScreen`, `LandingScreen`,
`ResponsiveLayout`, `MobileLayoutScreen`, `WebLayoutScreen`.

### 5.3 `StatefulWidget` + vòng đời

Có state thay đổi theo thời gian. Tách làm 2 class: Widget (bất biến, giữ tham số) và State (giữ dữ liệu thay đổi).

```dart
// lib/features/auth/screens/login_screen.dart
class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login-screen';
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  Country? country;                        // ← state

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
  }

  void pickCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country c) {
        setState(() { country = c; });     // ← báo Flutter vẽ lại
      },
    );
  }
  ...
}
```

**Vòng đời State:**

| Method | Khi nào chạy | Dùng để |
|---|---|---|
| `initState()` | 1 lần, khi State được tạo | khởi tạo controller, đăng ký listener/observer |
| `didChangeDependencies()` | sau `initState` và mỗi khi InheritedWidget đổi | lấy `Theme.of`, `MediaQuery.of` an toàn |
| `build()` | mỗi lần cần vẽ | trả về widget tree |
| `didUpdateWidget()` | khi widget cha truyền tham số mới | so sánh `oldWidget` với `widget` |
| `setState()` | bạn gọi | đánh dấu "bẩn" → schedule `build()` |
| `dispose()` | khi State bị gỡ vĩnh viễn | huỷ controller, gỡ listener |

Trong State, truy cập tham số của widget qua `widget.<tên>`:

```dart
// lib/features/chat/chat_screen.dart:67
widget.groupId != '' ? Text(widget.name) : StreamBuilder(...)
```

**`initState` / `dispose` trong repo:**

```dart
// lib/features/chat/chat_screen.dart:39
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);   // đăng ký nghe app lifecycle
}

@override
void dispose() {
  super.dispose();
  messageController.dispose();
  WidgetsBinding.instance.removeObserver(this);
}
```

> ⚠️ **Thứ tự sai.** Đúng phải là dọn dẹp *trước*, rồi `super.dispose()` **cuối cùng**:
> ```dart
> @override
> void dispose() {
>   messageController.dispose();
>   WidgetsBinding.instance.removeObserver(this);
>   super.dispose();     // ← luôn ở cuối
> }
> ```
> Lỗi này lặp lại ở `login_screen.dart:26`, `bottom_chat_field.dart:44`, `chat_screen.dart:47`,
> `list_chat_screen.dart:28`. `create_group_screen.dart:49` thì làm **đúng**.

### 5.4 `setState` — nguyên tắc

```dart
setState(() {
  isShowEmoji = !isShowEmoji;    // CHỈ đổi biến ở đây, không gọi async/IO
});
```

- Không gọi `setState` trong `build()` → vòng lặp vô hạn.
- Không gọi `setState` sau khi widget đã `dispose` → dùng `if (mounted)` để chắn.
- `setState` vẽ lại **toàn bộ** subtree của State đó → State càng nhỏ càng tốt cho hiệu năng.

### 5.5 `BuildContext`

Là "vị trí của widget này trong cây". Dùng để đi ngược lên tìm dữ liệu tổ tiên:

```dart
MediaQuery.of(context).size          // kích thước màn hình
Theme.of(context)                    // theme hiện tại
Navigator.of(context).push(...)      // navigator gần nhất
ScaffoldMessenger.of(context)        // để show snackbar
AppLocalizations.of(context)!.chat   // chuỗi đã dịch
```

Cơ chế bên dưới là `InheritedWidget`: `MaterialApp` đặt các widget này lên đỉnh cây, `of(context)` đi
ngược lên tìm cái gần nhất.

**Bẫy `context` qua async gap:** sau `await`, widget có thể đã bị gỡ khỏi cây → dùng `context` sẽ lỗi.
Repo có xử lý đúng ở một chỗ:

```dart
// lib/features/create_group/create_group_screen.dart:87
await ref.read(createGroupControllerProvider).createGroup(...);
if (context.mounted) {          // ← kiểm tra trước khi dùng context
  Navigator.pop(context);
  Navigator.pop(context);
}
```

Nhưng **thiếu** ở các repository (`auth_repository.dart:51`, `:68`, `:100`; `select_contact_repository.dart:53`).

### 5.6 `WidgetsBindingObserver` — nghe vòng đời ứng dụng

Dùng để set trạng thái online/offline:

```dart
// lib/features/chat/chat_screen.dart:35
class _ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {                      // ← mixin

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(chatControllerProvider).setStatus(true);   // đang mở app
    } else {
      ref.read(chatControllerProvider).setStatus(false);  // ẩn/đóng
    }
  }
}
```

`with X` là **mixin** — cách tái sử dụng code không cần kế thừa. Một class có thể `with` nhiều mixin.

Các trạng thái: `resumed` (đang dùng), `inactive`, `paused` (nền), `detached`, `hidden`.

### 5.7 `TickerProviderStateMixin` — cung cấp nhịp cho animation

```dart
// lib/features/list_chat/list_chat_screen.dart:16
class _ListChatScreenState extends ConsumerState<ListChatScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {

  late TabController tabBarController;

  @override
  void initState() {
    super.initState();
    tabBarController = TabController(length: 3, vsync: this);   // vsync: this ← từ mixin
  }
}
```

`vsync` cho animation biết khi nào nên vẽ frame; nếu màn hình bị ẩn thì dừng lại (tiết kiệm pin).
- `TickerProviderStateMixin` — nhiều AnimationController.
- `SingleTickerProviderStateMixin` — đúng 1 cái (nhẹ hơn).

> Lưu ý: `tabBarController` chưa được `dispose()` trong repo → rò rỉ bộ nhớ nhẹ.

### 5.8 Controller: `TextEditingController`, `ScrollController`, `FocusNode`

```dart
final phoneController = TextEditingController();   // đọc/ghi nội dung TextField
final messageController = ScrollController();      // điều khiển vị trí cuộn ListView
FocusNode focusNode = FocusNode();                 // điều khiển bàn phím
```

```dart
phoneController.text.trim()                  // đọc
_messageController.text = '';                // ghi (xoá ô nhập sau khi gửi)
focusNode.requestFocus();                    // bật bàn phím
focusNode.unfocus();                         // tắt bàn phím
focusNode.addListener(() { ... });           // nghe sự kiện focus
messageController.jumpTo(messageController.position.maxScrollExtent);  // nhảy xuống đáy
```

**Tất cả controller đều phải `dispose()`** nếu không sẽ rò rỉ bộ nhớ.
(Repo quên `focusNode.dispose()` trong `bottom_chat_field.dart`.)

Ví dụ nghe focus để tự ẩn bảng emoji:

```dart
// lib/common/widgets/bottom_chat_field.dart:34
focusNode.addListener(() {
  if (focusNode.hasFocus) {
    setState(() { isShowEmoji = false; });
  }
});
```

### 5.9 `SchedulerBinding.addPostFrameCallback`

Chạy 1 hàm **sau khi** frame hiện tại vẽ xong. Dùng khi cần thao tác lên thứ chưa tồn tại lúc `build`:

```dart
// lib/features/chat/chat_screen.dart:126
SchedulerBinding.instance.addPostFrameCallback((_) {
  messageController.jumpTo(messageController.position.maxScrollExtent);
});
```

Mục đích: tự cuộn xuống tin mới nhất. Không thể gọi ngay trong `build` vì `ListView` chưa được layout.

> ⚠️ Đoạn này crash nếu `ListView` chưa gắn (`ScrollController not attached`). Nên bọc:
> ```dart
> if (messageController.hasClients) {
>   messageController.jumpTo(messageController.position.maxScrollExtent);
> }
> ```

`(_)` — dấu gạch dưới là quy ước "tham số này tôi không dùng".

---

## 6. Flutter: layout & các widget dùng trong dự án

### 6.1 Khung màn hình: `Scaffold`

```dart
Scaffold(
  appBar: AppBar(...),              // thanh trên
  body: SafeArea(child: ...),       // nội dung chính
  floatingActionButton: FloatingActionButton(...),
  // còn: drawer, bottomNavigationBar, bottomSheet
)
```

`SafeArea` chừa chỗ cho tai thỏ, thanh trạng thái, thanh home indicator.

### 6.2 `AppBar` + `TabBar` + `TabBarView`

```dart
// lib/features/list_chat/list_chat_screen.dart:39
DefaultTabController(
  length: 3,
  child: Scaffold(
    appBar: AppBar(
      centerTitle: false,
      title: const Text('WhatsApp', style: TextStyle(...)),
      bottom: TabBar(                          // bottom nhận PreferredSizeWidget
        controller: tabBarController,
        indicatorColor: Coloors.tabColor,
        indicatorWeight: 4,
        labelColor: Coloors.tabColor,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: [
          Tab(text: AppLocalizations.of(context)!.chat),
          Tab(text: 'STATUS'),
          Tab(text: 'CONTACT'),
        ],
      ),
    ),
    body: TabBarView(
      controller: tabBarController,            // CÙNG controller với TabBar
      children: [ListChatWidget(), Center(...), Center(...)],
    ),
  ),
)
```

Số lượng `tabs` phải bằng số `children` của `TabBarView` và bằng `length`.

> Ở đây vừa dùng `DefaultTabController` vừa tự tạo `tabBarController` — thừa một cái.
> Chọn 1 trong 2: `DefaultTabController` (không cần controller thủ công) **hoặc** `TabController` tự quản.

`actions` trong AppBar = danh sách nút bên phải:

```dart
actions: [
  IconButton(onPressed: () {}, icon: const Icon(Icons.video_call)),
  IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
  IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
],
```

### 6.3 Layout theo trục: `Column`, `Row`, `Expanded`, `Flexible`

```dart
Column(                                     // xếp dọc
  mainAxisAlignment: MainAxisAlignment.spaceBetween,   // trục dọc (chính)
  crossAxisAlignment: CrossAxisAlignment.center,       // trục ngang (phụ)
  children: [...],
)

Row(                                        // xếp ngang — trục chính/phụ đảo lại
  mainAxisAlignment: MainAxisAlignment.center,
  children: [...],
)
```

`MainAxisAlignment`: `start`, `end`, `center`, `spaceBetween`, `spaceAround`, `spaceEvenly`.
`CrossAxisAlignment`: `start`, `end`, `center`, `stretch`, `baseline`.

`Expanded` — chiếm hết chỗ còn thừa trên trục chính:

```dart
// lib/features/chat/chat_screen.dart:116
Column(
  children: [
    Expanded(child: StreamBuilder<List<Message>>(...)),  // list chiếm hết phần trên
    MessageReply(),                                       // chiều cao tự nhiên
    SizedBox(width: double.infinity, child: BottomChatField(...)),
  ],
)
```

Không có `Expanded`, `ListView` bên trong `Column` sẽ báo lỗi "unbounded height".

`Expanded` chỉ dùng được làm con trực tiếp của `Row`/`Column`/`Flex`.

### 6.4 Kích thước & khoảng cách

```dart
SizedBox(width: 60, height: 60, child: ...)     // hộp kích thước cố định
SizedBox(width: double.infinity)                 // "ép chiều rộng tối đa" — thủ thuật trong repo
SizedBox.shrink()                                // hộp 0x0, dùng để "ẩn" widget
Gap(12)                                          // khoảng trắng 12px (package gap)
Padding(padding: EdgeInsets.all(18), child: ...)
```

`EdgeInsets` các dạng:

```dart
EdgeInsets.all(18)
EdgeInsets.symmetric(horizontal: 16, vertical: 8)
EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 16)
```

**`Gap` vs `SizedBox`:** `Gap(12)` tự biết mình đang trong `Row` hay `Column` để tạo khoảng cách
đúng trục — gọn hơn `SizedBox(height: 12)`.

`ConstrainedBox` giới hạn kích thước tối đa/tối thiểu:

```dart
// lib/features/chat/widgets/my_message_card.dart:81
ConstrainedBox(
  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 45),
  child: Card(...),
)
```

Dùng để bong bóng chat không tràn hết màn hình.

### 6.5 `Stack` + `Positioned` — xếp chồng

```dart
// lib/features/auth/screens/user_information_screen.dart:49
Stack(
  children: [
    SizedBox(width: 120, height: 120, child: CircleAvatar(...)),   // lớp dưới
    Positioned(                                                     // lớp trên
      bottom: 4,
      right: 4,
      child: InkWell(onTap: selectImage, child: Icon(Iconsax.add_circle, size: 30)),
    ),
  ],
)
```

`Positioned` chỉ dùng được bên trong `Stack`. Đặt vị trí bằng `top`/`bottom`/`left`/`right`.

Trong `my_message_card.dart`, `Stack` được dùng để vẽ khung "reply" nằm sau bong bóng tin nhắn.

### 6.6 Trang trí: `Container`, `BoxDecoration`, `Card`

```dart
Container(
  width: MediaQuery.of(context).size.width,
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  decoration: BoxDecoration(
    color: Coloors.webAppBarColor,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(10),
      topRight: Radius.circular(10),
    ),
  ),
  child: ...,
)
```

> Quy tắc: đặt `color` **hoặc** trong `decoration` **hoặc** ở `Container.color`, không được cả hai (crash).

`BorderRadius.circular(8)` bo đều 4 góc; `BorderRadius.only(...)` bo từng góc.

```dart
Card(
  elevation: 2,                                             // đổ bóng
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
  color: Coloors.messageColor,
  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
  child: Padding(...),
)
```

### 6.7 Text & TextStyle

```dart
Text(
  message,
  style: const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,     // w100..w900, hoặc FontWeight.bold
    color: Colors.white60,           // white60 = trắng 60% opacity
  ),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,   // tràn thì hiện "..."
  textAlign: TextAlign.center,
)
```

### 6.8 Danh sách: `ListView.builder`, `ListView.separated`, `ListTile`

```dart
// lib/features/chat/chat_screen.dart:130
ListView.builder(
  controller: messageController,
  itemCount: snapshot.data?.length ?? 0,
  itemBuilder: (context, index) {
    final message = snapshot.data![index];
    return ...;
  },
)
```

`.builder` chỉ dựng item đang hiển thị → dùng cho list dài/không biết trước độ dài.

Khi đặt `ListView` bên trong `Column`/`SingleChildScrollView`:

```dart
// lib/features/list_chat/widgets/list_chat_widget.dart:27
ListView.builder(
  shrinkWrap: true,                            // co lại vừa nội dung thay vì chiếm vô hạn
  itemCount: snapshot.data!.length,
  itemBuilder: ...,
)
```

Và thêm `physics: NeverScrollableScrollPhysics()` để không cuộn lồng nhau:

```dart
// lib/features/create_group/create_group_screen.dart:238
ListView.separated(
  shrinkWrap: true,
  itemCount: listMember.length,
  physics: NeverScrollableScrollPhysics(),
  separatorBuilder: (context, index) => SizedBox(height: 10),
  itemBuilder: (context, index) { ... },
)
```

> `shrinkWrap: true` bắt Flutter dựng **toàn bộ** item ngay → chậm với list dài.
> Với list dài nên dùng `CustomScrollView` + `SliverList` thay vì `SingleChildScrollView` + `shrinkWrap`.

`ListTile` — dòng danh sách chuẩn Material:

```dart
ListTile(
  leading: CachedNetworkImage(...),   // bên trái (avatar)
  title: Text(groupData.name),
  subtitle: Text(groupData.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
  trailing: ...,                       // bên phải
)
```

`SingleChildScrollView` — bọc 1 child để cuộn được (dùng ở `landing_screen`, `create_group_screen`).

### 6.9 Ảnh: `Image.asset`, `CircleAvatar`, `FileImage`, `CachedNetworkImage`

```dart
Image.asset('assets/bg.png', width: 340, height: 340, color: Coloors.tabColor)
```

Asset phải khai báo trong `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/backgroundImage.png
    - assets/bg.png
    - lib/l10n/
```

```dart
CircleAvatar(backgroundImage: FileImage(image!))        // ảnh từ file local (dart:io File)
CircleAvatar(backgroundColor: Coloors.colorGrey, child: Icon(Iconsax.user))
```

`CachedNetworkImage` — tải ảnh mạng + cache đĩa:

```dart
// lib/features/list_chat/widgets/list_chat_widget.dart:56
CachedNetworkImage(
  imageUrl: groupData.groupPic,
  fit: BoxFit.cover,
  width: 60,
  height: 60,
  imageBuilder: (context, imageProvider) => CircleAvatar(backgroundImage: imageProvider),
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

`BoxFit`: `cover` (đầy khung, có thể cắt), `contain` (vừa khung, có thể thừa), `fill` (méo).

### 6.10 Nhập liệu: `TextField`, `TextFormField`, `InputDecoration`

```dart
// lib/features/auth/screens/login_screen.dart:97
TextField(
  controller: phoneController,
  decoration: InputDecoration(hintText: 'Phone number'),
  keyboardType: TextInputType.phone,
  inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],  // chỉ cho nhập số
)
```

`inputFormatters` cần `import 'package:flutter/services.dart';`.

Sự kiện:

```dart
onChanged: (val) { if (val.length == 6) verifyOTP(...); }   // mỗi ký tự
onSubmitted: (value) { ... }                                 // nhấn Enter/Search
```

`InputDecoration` đầy đủ (ô nhập tin nhắn):

```dart
// lib/common/widgets/bottom_chat_field.dart:105
InputDecoration(
  hintText: 'Enter your message ...',
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide(width: 0),
  ),
  enabledBorder: OutlineInputBorder(...),
  fillColor: Coloors.chatBarMessage,
  filled: true,                          // BẮT BUỘC để fillColor có tác dụng
  prefixIcon: Container(...),            // icon emoji + gif bên trái
  suffixIcon: SizedBox(...),             // icon đính kèm + camera bên phải
)
```

Muốn bỏ viền hẳn: `border: OutlineInputBorder(borderSide: BorderSide.none)` (dùng ở `create_group_screen`).

`TextField` vs `TextFormField`: cái sau dùng được trong `Form` với `validator`. Repo chưa dùng `Form`.

### 6.11 Chạm & tương tác: `InkWell`, `GestureDetector`, `IconButton`, buttons

```dart
InkWell(onTap: selectImage, child: Icon(...))          // có hiệu ứng gợn sóng (ripple)
GestureDetector(onTap: () {...}, child: Text('Add'))   // không có hiệu ứng, nhẹ hơn
IconButton(onPressed: () {}, icon: Icon(Icons.search))
TextButton(onPressed: pickCountry, child: Text('Pick country'))
ElevatedButton(onPressed: onPress, style: ..., child: ...)
FloatingActionButton(
  onPressed: _handleNavigateCreategroup,
  foregroundColor: Coloors.textColor,
  backgroundColor: Coloors.tabColor,
  shape: CircleBorder(),
  child: const Icon(Icons.message),
)
```

`onTap: isSendIcon ? sendMessage : () {}` — truyền `null` thay vì `() {}` sẽ khiến nút bị disable (xám).

### 6.12 Builder theo dữ liệu: `StreamBuilder`, `FutureBuilder`, `LayoutBuilder`

**`StreamBuilder`** — rebuild mỗi khi stream bắn giá trị:

```dart
// lib/features/chat/chat_screen.dart:72
StreamBuilder<UserModel>(
  stream: ref.read(authControllerProvider).getUser(widget.uid),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return SizedBox(width: 30, height: 30, child: CircularProgressIndicator());
    }
    return Column(children: [
      Text(snapshot.data!.name),
      Text(snapshot.data!.isOnline ? 'Online' : 'Offline'),
    ]);
  },
)
```

`AsyncSnapshot` có:
- `connectionState`: `none` / `waiting` / `active` / `done`
- `hasData` / `data`
- `hasError` / `error`

Thứ tự kiểm tra chuẩn:

```dart
if (snapshot.connectionState == ConnectionState.waiting) return Loader();
if (snapshot.hasError) return Text('Lỗi: ${snapshot.error}');
if (!snapshot.hasData || snapshot.data!.isEmpty) return Text('Chưa có dữ liệu');
return ListView.builder(...);
```

> ⚠️ Ở `chat_screen.dart:130` các kiểm tra `waiting`/`hasError`/`isEmpty` bị đặt **bên trong**
> `itemBuilder`. Khi `itemCount == 0` thì `itemBuilder` không bao giờ chạy → các nhánh đó chết.
> Nên chuyển ra ngoài, đặt trước `return ListView.builder(...)`.

**Bẫy lớn:** không tạo stream mới ngay trong `build`:

```dart
// SAI — mỗi lần rebuild là một stream mới, resubscribe, nháy màn hình
stream: ref.watch(chatControllerProvider).getListMessages(widget.uid),
```

Nên tạo stream 1 lần trong `initState` và lưu vào field, hoặc dùng `StreamProvider` của Riverpod.

**`LayoutBuilder`** — biết được ràng buộc kích thước cha cho:

```dart
// lib/common/utils/responsive_layout.dart:14
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) return webScreenLayout;
    return mobileScreenLayout;
  },
)
```

### 6.13 `MediaQuery` — thông tin màn hình

```dart
MediaQuery.of(context).size.width
MediaQuery.of(context).size.height
```

Repo bọc lại thành hàm tiện ích (bị lặp ở 2 file):

```dart
// lib/constant/size.dart  VÀ  lib/common/utils/size_screen.dart
Size getSize(BuildContext context) => MediaQuery.of(context).size;
```

Dùng: `size.width * 0.75`, `size.height / 12`, `size.width / 3`.

> Nên xoá 1 trong 2 file trùng. Và với Flutter mới, `MediaQuery.sizeOf(context)` hiệu quả hơn
> (chỉ rebuild khi size đổi, không rebuild khi bàn phím bật/tắt).

### 6.14 Theme

```dart
// lib/main.dart:37
MaterialApp(
  theme: ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Coloors.backgroundColor,
    appBarTheme: AppBarTheme(color: Coloors.appBarColor),
  ),
)
```

`lib/common/config/theme.dart` định nghĩa sẵn `lightTheme` và `darkTheme` nhưng **chưa được dùng**.
Muốn bật chế độ sáng/tối, sửa `MaterialApp`:

```dart
theme: lightTheme,
darkTheme: darkTheme,
themeMode: ThemeMode.system,   // hoặc .light / .dark
```

### 6.15 `showDialog` — hộp thoại

```dart
// lib/features/create_group/create_group_screen.dart:75
showDialog(
  context: context,
  barrierDismissible: false,          // không cho bấm ra ngoài để đóng
  builder: (context) => const Center(child: CircularProgressIndicator()),
);
```

Đóng bằng `Navigator.pop(context)` — vì dialog cũng là 1 route trong Navigator.

### 6.16 `ScaffoldMessenger` — SnackBar

```dart
// lib/common/utils/utils.dart:5
void showSnackbar({required BuildContext context, required String content}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
}
```

Dùng `ScaffoldMessenger` (không phải `Scaffold.of`) để snackbar sống sót khi màn hình đổi.

---

## 7. Flutter: điều hướng (Navigator & Routes)

### 7.1 Đặt tên route

Quy ước trong repo: mỗi màn hình có hằng số static:

```dart
class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login-screen';
  ...
}
```

### 7.2 Bảng định tuyến: `onGenerateRoute`

```dart
// lib/router.dart
Route<dynamic> generateRoute(RouteSettings setting) {
  switch (setting.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(builder: (context) => const LoginScreen());

    case OtpScreen.routeName:
      final verificationId = setting.arguments as String;      // ép kiểu arguments
      return MaterialPageRoute(
        builder: (context) => OtpScreen(verificationid: verificationId),
      );

    case ChatScreen.routeName:
      final args = setting.arguments as Map<String, dynamic>;  // nhiều tham số → Map
      return MaterialPageRoute(
        builder: (context) => ChatScreen(
          name: args['name'],
          uid: args['uid'],
          groupId: args['groupId'],
        ),
      );

    default:
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: ErrorScreen(error: "This page does't exist"),
        ),
      );
  }
}
```

Nối vào app:

```dart
// lib/main.dart:40
onGenerateRoute: (settings) => generateRoute(settings),
```

### 7.3 Các lệnh điều hướng

```dart
// Đi tới màn hình theo tên
Navigator.pushNamed(context, LoginScreen.routeName);

// Đi tới, kèm dữ liệu
Navigator.pushNamed(context, OtpScreen.routeName, arguments: verificationId);

// Đi tới, XOÁ toàn bộ stack cũ ((route) => false nghĩa là "không giữ route nào")
Navigator.pushNamedAndRemoveUntil(
    context, UserInfomationScreen.routeName, (route) => false);

// Đi tới bằng widget trực tiếp (không qua bảng route)
Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => ChatScreen(name: ..., uid: ..., groupId: ...)),
);

// Đi tới bằng widget + xoá stack
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => const ListChatScreen()),
  (route) => false,
);

// Quay lại
Navigator.pop(context);
```

Dùng `pushNamedAndRemoveUntil` sau khi verify OTP để người dùng không bấm back về màn OTP được.

> Repo trộn 2 phong cách: có route đi qua `router.dart` (`pushNamed`), có route push widget trực tiếp
> (`select_contact_repository.dart:53`, `:76`). Cả hai đều chạy; nên thống nhất về `pushNamed` để dễ quản lý.

---

## 8. Riverpod: quản lý state

Dự án dùng `flutter_riverpod: ^2.6.1`.

### 8.1 `ProviderScope` — gốc của mọi provider

```dart
// lib/main.dart:22
runApp(
  const ProviderScope(
    child: MyApp(),
  ),
);
```

Bắt buộc phải có, nếu không mọi `ref.watch` sẽ ném lỗi.

### 8.2 Các loại Provider dùng trong repo

| Loại | Trả về | Dùng khi | Ví dụ trong repo |
|---|---|---|---|
| `Provider` | giá trị bất biến | inject service/controller/repository | `chatControllerProvider` |
| `StateProvider` | giá trị đơn giản, sửa được | cờ, filter, object nhỏ | `messageReplyProvider` |
| `FutureProvider` | `AsyncValue<T>` từ Future | tải dữ liệu 1 lần | `userDataAuthProvider`, `getContactProvider` |
| `FutureProvider.family` | như trên, có tham số | truy vấn theo tham số | `searchUserProvider` |
| `StreamProvider` | `AsyncValue<T>` từ Stream | dữ liệu realtime | *chưa dùng — repo dùng `StreamBuilder` thay thế* |

**`Provider`** — giá trị chỉ tạo 1 lần, cache lại:

```dart
// lib/features/list_chat/list_chat_controller.dart:6
final listChatControllerProvider = Provider<ListChatController>((ref) {
  final listChatRepository = ref.watch(listChatRepositoryProvider);
  return ListChatController(listChatRepository: listChatRepository, ref: ref);
});
```

**`StateProvider`** — state đơn giản có thể ghi:

```dart
// lib/common/provider/message_reply_provider.dart:19
final messageReplyProvider = StateProvider<MessageReplyProvider?>((ref) => null);

// lib/common/provider/current_user.dart:4
final currentUserProvider = StateProvider<UserModel?>((ref) => null);
```

Đọc và ghi:

```dart
final messageReply = ref.watch(messageReplyProvider);        // đọc giá trị

// Cách repo đang viết (API cũ, còn chạy nhưng deprecated):
ref.read(messageReplyProvider.state).update((state) => null);

// Cách khuyến nghị với Riverpod 2.x:
ref.read(messageReplyProvider.notifier).state = null;
// hoặc
ref.read(messageReplyProvider.notifier).update((state) => null);
```

**`FutureProvider`** — bọc `Future`, tự sinh trạng thái loading/error/data:

```dart
// lib/features/auth/controller/auth_controller.dart:16
final userDataAuthProvider = FutureProvider((ref) {
  final authController = ref.read(authControllerProvider);
  return authController.getUserData();
});
```

**`FutureProvider.family`** — provider nhận tham số:

```dart
// lib/features/create_group/create_group_screen.dart:18
final searchUserProvider = FutureProvider.family<UserModel?, String>(
  (ref, phoneNumber) async {
    final controller = ref.watch(createGroupControllerProvider);
    return await controller.getUserByPhone(phoneNumber);
  },
);
```

`family<TrảVề, ThamSố>`. Dùng: `ref.watch(searchUserProvider('0912345678'))`.
Mỗi giá trị tham số tạo một instance provider riêng, có cache riêng.

`ref.invalidate(searchUserProvider(phone))` — xoá cache, buộc chạy lại:

```dart
// lib/features/create_group/create_group_screen.dart:143
ref.invalidate(searchUserProvider(phone));
```

### 8.3 `ref.watch` vs `ref.read` vs `ref.listen`

| | Hành vi | Dùng ở đâu |
|---|---|---|
| `ref.watch(p)` | đọc + **đăng ký rebuild** khi p đổi | trong `build()` |
| `ref.read(p)` | đọc 1 lần, KHÔNG rebuild | trong callback (`onTap`, `initState`) |
| `ref.listen(p, cb)` | chạy side-effect khi p đổi | trong `build()`, để show dialog/snackbar |

Nguyên tắc vàng: **`watch` trong build, `read` trong callback.**

```dart
// ĐÚNG — read trong callback
onTap: () => ref.read(chatControllerProvider).clearReplyMessage(),

// ĐÚNG — watch trong build
final messageReply = ref.watch(messageReplyProvider);
```

> ⚠️ `bottom_chat_field.dart:50` và `:59` dùng `ref.watch` bên trong hàm `sendMessage()` (một callback).
> Nên đổi sang `ref.read`. Dùng `watch` ngoài `build` gây đăng ký thừa và cảnh báo.

### 8.4 `ConsumerWidget` & `ConsumerStatefulWidget`

**`ConsumerWidget`** — như `StatelessWidget` nhưng `build` có thêm `ref`:

```dart
// lib/features/chat/widgets/message_reply.dart:8
class MessageReply extends ConsumerWidget {
  const MessageReply({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {   // ← 2 tham số
    final messageReply = ref.watch(messageReplyProvider);
    if (messageReply?.message == null) return const SizedBox.shrink();
    return Container(...);
  }
}
```

**`ConsumerStatefulWidget` + `ConsumerState`** — như `StatefulWidget`, `ref` là field của State:

```dart
// lib/features/chat/chat_screen.dart:19
class ChatScreen extends ConsumerStatefulWidget {
  ...
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  // dùng ref ở bất cứ đâu trong class: initState, dispose, build, callback
  ref.read(chatControllerProvider).setStatus(true);
}
```

**`Consumer`** — widget bọc để *thu hẹp phạm vi rebuild*:

```dart
// lib/features/create_group/create_group_screen.dart:167
Consumer(builder: (context, ref, child) {
  final userAsync = ref.watch(searchUserProvider(_searchPhone!));
  return userAsync.when(...);
}),
```

Chỉ phần bên trong `Consumer` rebuild khi provider đổi — phần còn lại của màn hình đứng yên.
Rất hữu ích cho hiệu năng.

### 8.5 `AsyncValue` & `.when()`

`FutureProvider`/`StreamProvider` trả `AsyncValue<T>` — một union 3 trạng thái:

```dart
// lib/main.dart:51
home: ref.watch(userDataAuthProvider).when(
      data: (user) {
        if (user != null) return ListChatScreen();
        return LandingScreen();
      },
      error: (error, trace) => ErrorScreen(error: error.toString()),
      loading: () => Loader(),
    ),
```

Đây chính là cơ chế **auto-login**: mở app → gọi Firestore lấy user → có thì vào danh sách chat,
không có thì ra màn chào.

```dart
// lib/features/select_contacts/screens/select_contact_screen.dart:40
body: ref.watch(getContactProvider).when(
      data: (contactsList) => ListView.builder(...),
      error: (err, trace) => ErrorScreen(error: err.toString()),
      loading: () => Loader(),
    ),
```

`.whenData()` — chỉ chạy khi có data, bỏ qua loading/error:

```dart
// lib/features/chat/chat_controller.dart:34
ref.read(userDataAuthProvider).whenData(
      (value) => chatRepository.sendTextMessage(..., senderUser: value!, ...),
    );
```

Các API khác: `.value` (T? — null nếu chưa có), `.hasValue`, `.isLoading`, `.maybeWhen(orElse: ...)`.

### 8.6 `ProviderRef` vs `Ref`

Repo khai báo:

```dart
final ProviderRef ref;    // chat_controller.dart:17, auth_controller.dart:23, ...
```

`ProviderRef` đã **deprecated** từ Riverpod 2.x. Thay bằng `Ref`:

```dart
final Ref ref;
```

Đây là thay đổi an toàn, chỉ đổi tên kiểu.

---

## 9. Firebase: Auth, Firestore, Storage

### 9.1 Khởi tạo

```dart
// lib/main.dart:17
void main() async {
  WidgetsFlutterBinding.ensureInitialized();     // bắt buộc trước khi gọi plugin native
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}
```

`firebase_options.dart` do lệnh `flutterfire configure` sinh ra — chứa apiKey, appId cho từng nền tảng.
**Không sửa tay file này.**

> Trong repo có file rác `lib/ firebase_options.dart` (có dấu cách ở đầu tên) — nên xoá.

### 9.2 Auth bằng số điện thoại (2 bước)

**Bước 1 — gửi SMS:**

```dart
// lib/features/auth/repository/auth_repository.dart:38
void singInWithPhone(BuildContext context, String phoneNumber) async {
  try {
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,                    // định dạng E.164: +84912345678

      verificationCompleted: (PhoneAuthCredential credential) async {
        // Android tự động đọc SMS → đăng nhập luôn, không cần nhập tay
        await auth.signInWithCredential(credential);
      },

      verificationFailed: (e) {
        throw Exception(e.message!);
      },

      codeSent: ((String verificationId, int? resendToken) async {
        // SMS đã gửi → chuyển sang màn nhập OTP, mang theo verificationId
        Navigator.pushNamed(context, OtpScreen.routeName, arguments: verificationId);
      }),

      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  } on FirebaseAuthException catch (e) {
    showSnackbar(context: context, content: e.message ?? "");
  }
}
```

**Bước 2 — xác thực mã:**

```dart
// lib/features/auth/repository/auth_repository.dart:60
void verifyOTP({required BuildContext context, required String verificationId, required String userOTP}) async {
  try {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: userOTP,
    );
    await auth.signInWithCredential(credential);
    Navigator.pushNamedAndRemoveUntil(context, UserInfomationScreen.routeName, (route) => false);
  } on FirebaseAuthException catch (e) {
    showSnackbar(context: context, content: e.message!);
  }
}
```

Số điện thoại được ghép từ mã quốc gia + số nhập:

```dart
// lib/features/auth/screens/login_screen.dart:52
.signInWithPhone(context, '+${country!.phoneCode}$phoneNumber');
```

**API auth hay dùng:**

```dart
FirebaseAuth.instance
auth.currentUser          // User? — null nếu chưa đăng nhập
auth.currentUser!.uid
auth.currentUser!.phoneNumber
auth.signOut()            // repo CHƯA có nút đăng xuất
auth.authStateChanges()   // Stream<User?> — nghe trạng thái đăng nhập
```

### 9.3 Firestore — mô hình dữ liệu

Cấu trúc: **collection → document → (sub)collection → document → ...** (luôn xen kẽ).

```dart
firestore.collection('users')                        // collection
         .doc(uid)                                   // document
         .collection('chats')                        // subcollection
         .doc(recieverUserId)                        // document
         .collection('messages')                     // subcollection
         .doc(messageId)                             // document
```

### 9.4 Ghi dữ liệu

```dart
// set — tạo mới hoặc GHI ĐÈ toàn bộ document
await firestore.collection('users').doc(uid).set(user.toMap());

// set merge — ghi đè các field truyền vào, giữ các field khác
await ref.set(data, SetOptions(merge: true));

// update — chỉ sửa field chỉ định; LỖI nếu document không tồn tại
await firestore.collection('users').doc(uid).update({'isOnline': isOnline});
await firestore.collection('groups').doc(groupId).update({
  'lastMessage': text,
  'timeSent': DateTime.now().toIso8601String(),
});

// add — tạo document với id ngẫu nhiên
await firestore.collection('groups').add(group.toMap());

// delete
await firestore.collection('users').doc(uid).delete();
```

Repo tự sinh id bằng `uuid` thay vì để Firestore tự sinh:

```dart
final messageId = Uuid().v1();          // chat_repository.dart:187
final groupId = const Uuid().v1();      // create_group_repository.dart:46
```

`v1` = dựa trên timestamp + MAC; `v4` = ngẫu nhiên. Với id tin nhắn thì `v4` cũng ổn.

### 9.5 Đọc 1 lần

```dart
// 1 document
var userData = await firestore.collection('users').doc(uid).get();
if (userData.data() != null) {
  user = UserModel.fromMap(userData.data()!);
}

// cả collection
var users = await firestore.collection('users').get();
for (var userDoc in users.docs) {
  user = UserModel.fromMap(userDoc.data());
}

// có điều kiện
final querySnapshot = await firestore
    .collection('users')
    .where('phoneNumber', isEqualTo: phoneNumber)
    .limit(1)
    .get();
if (querySnapshot.docs.isEmpty) return null;
final doc = querySnapshot.docs.first;
```

**Kiểu dữ liệu trả về:**
- `.doc(...).get()` → `DocumentSnapshot` — có `.data()` (`Map?`), `.exists`, `.id`
- `.collection(...).get()` → `QuerySnapshot` — có `.docs` (`List<QueryDocumentSnapshot>`)

### 9.6 Đọc realtime — `.snapshots()`

```dart
firestore.collection('users').doc(userID).snapshots()          // Stream<DocumentSnapshot>
    .map((el) => UserModel.fromMap(el.data()!));               // → Stream<UserModel>

firestore.collection('groups').snapshots()                     // Stream<QuerySnapshot>
```

### 9.7 Query: `where`, `orderBy`, `limit`

```dart
.where('phoneNumber', isEqualTo: phoneNumber)
.orderBy('timeSent', descending: false)      // tin cũ trên, mới dưới
.orderBy('timeSend', descending: true)       // hội thoại mới nhất lên đầu
.limit(1)
```

Toán tử `where` khác: `isNotEqualTo`, `isGreaterThan`, `isLessThan`, `arrayContains`,
`arrayContainsAny`, `whereIn`, `isNull`.

> **Câu query đang thiếu — bug bảo mật:**
> `getGroupsChat()` (`list_chat_repository.dart:57`) lấy **tất cả** group của **tất cả** người dùng.
> Phải lọc theo thành viên:
> ```dart
> firestore.collection('groups')
>     .where('membersUid', arrayContains: auth.currentUser!.uid)
>     .snapshots()
> ```
> Firestore sẽ yêu cầu tạo composite index nếu kết hợp `where` + `orderBy` khác field —
> nó in link tạo index sẵn trong log, chỉ cần bấm vào.

### 9.8 Firebase Storage

```dart
// lib/common/repositories/common_firebase_storage_repository.dart:16
Future<String> storeFileToFirebase(String ref, File file) async {
  UploadTask uploadTask = firebaseStorage.ref().child(ref).putFile(file);
  TaskSnapshot snap = await uploadTask;
  String downloadUrl = await snap.ref.getDownloadURL();
  return downloadUrl;
}
```

`ref` ở đây là **đường dẫn trong bucket**, ví dụ `'profilePic/$uid'`.

> Đoạn gọi hàm này ở `auth_repository.dart:85-88` đang **bị comment**, nên ảnh đại diện người dùng
> chọn không được upload — mọi người đều dùng chung ảnh Ronaldo hardcode. Đây là việc còn dở.
> Bỏ comment và bỏ luôn URL hardcode là xong:
> ```dart
> if (profilePic != null) {
>   photoUrl = await ref
>       .read(CommonFirebaseStorageRepositoryProvider)
>       .storeFileToFirebase('profilePic/$uid', profilePic);
> }
> ```

---

## 10. Cấu trúc dữ liệu Firestore của app

```
users/{uid}
  ├─ uid, name, profilePic, isOnline, phoneNumber, groupIds[]
  └─ chats/{contactUid}                        ← 1 document / 1 người đang chat
       ├─ name, profilePic, contactId, timeSend(ISO String), lastMessage, phone
       └─ messages/{messageId}
            └─ senderId, recieverid, text, type, timeSent(int ms),
               messageId, isSeen, repliedMessage, repliedTo

groups/{groupId}
  ├─ senderId, name, groupId, lastMessage, groupPic, membersUid[], timeSent(ISO String)
  └─ chats/{messageId}                          ← lưu ý: tên là "chats", không phải "messages"
       └─ (giống document message ở trên)
```

**Điểm quan trọng — tin nhắn 1-1 được lưu 2 bản:**

```dart
// lib/features/chat/chat_repository.dart:145-165
// bản của người gửi
users/{senderUid}/chats/{receiverUid}/messages/{messageId}
// bản của người nhận
users/{receiverUid}/chats/{senderUid}/messages/{messageId}
```

Đây là kỹ thuật **denormalization** (nhân bản dữ liệu) rất phổ biến với NoSQL: đọc nhanh, query đơn giản,
đổi lại phải ghi 2 lần và giữ đồng bộ thủ công (xem `setSeenMessage` phải update cả 2 bản).

Chat nhóm thì chỉ lưu **1 bản** dưới `groups/{groupId}/chats/`.

**Cách phân biệt chat 1-1 và chat nhóm trong code:** dựa vào `groupId != ''`.

```dart
if (groupId != '') {
  // luồng nhóm
} else {
  // luồng 1-1
}
```

Chuỗi rỗng làm sentinel — hơi thô nhưng nhất quán khắp repo. Nếu refactor, cân nhắc `String? groupId`.

---

## 11. Đa ngôn ngữ (l10n)

### 11.1 Cấu hình

`pubspec.yaml`:

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

flutter:
  generate: true          # ← bật sinh code l10n
  assets:
    - lib/l10n/
```

`l10n.yaml` ở gốc dự án khai báo nơi đọc `.arb` và nơi ghi file Dart sinh ra:

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-dir: lib/l10n
```

> **Quan trọng — thay đổi lớn của Flutter.** Trước đây localization được sinh vào một *synthetic package*
> tên `flutter_gen` và import bằng `package:flutter_gen/gen_l10n/app_localizations.dart`.
> Cơ chế này bị deprecated ở Flutter 3.29 và **gỡ bỏ hẳn ở Flutter 3.32**.
> Từ đó trở đi file được sinh ra là file Dart thật trong `output-dir`, import bằng package name của dự án.
> Nếu bạn thấy lỗi `Couldn't resolve the package 'flutter_gen'` thì đây chính là nguyên nhân.

### 11.2 File dịch (.arb — JSON có metadata)

```json
// lib/l10n/app_en.arb
{ "whatsApp": "whatsApp", "chat": "Chat", "status": "status", "contact": "contact" }

// lib/l10n/app_vi.arb
{ "whatsApp": "Nhắn tin", "chat": "Tin nhắn", "status": "Trạng thái", "contact": "Liên lạc" }
```

### 11.3 Đăng ký trong `MaterialApp`

```dart
// lib/main.dart:41
supportedLocales: [
  Locale('en', 'US'),
  Locale('vi', 'VI'),
],
localizationsDelegates: [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  AppLocalizations.delegate,
],
```

> Thiếu `GlobalCupertinoLocalizations.delegate` — nên thêm, nếu không các widget kiểu iOS
> (date picker...) sẽ báo lỗi thiếu localization.
>
> Mã vùng `'VI'` cho tiếng Việt cũng sai chuẩn — ISO country code của Việt Nam là `VN`.
> Đúng ra là `Locale('vi', 'VN')`.

### 11.4 Sử dụng

```dart
import 'package:dat_chat/l10n/app_localizations.dart';

Tab(text: AppLocalizations.of(context)!.chat),
```

Ba file được **sinh tự động** vào `lib/l10n/` khi chạy `flutter gen-l10n` (hoặc `flutter run`,
vì `pubspec.yaml` có `generate: true`):

```
lib/l10n/app_localizations.dart      ← class trừu tượng + delegate
lib/l10n/app_localizations_en.dart   ← bản tiếng Anh
lib/l10n/app_localizations_vi.dart   ← bản tiếng Việt
```

Đây là code sinh ra, **không sửa tay** — sửa `.arb` rồi generate lại.

Thêm chuỗi mới: thêm key vào **cả hai** file `.arb` → chạy `flutter gen-l10n` (hoặc `flutter run`) → dùng.

### 11.5 `intl` — định dạng ngày giờ

```dart
// lib/features/chat/chat_screen.dart:150
import 'package:intl/intl.dart';
String time = DateFormat.Hm().format(message.timeSent);   // → "14:30"
```

Các mẫu khác: `DateFormat.yMd()`, `DateFormat('dd/MM/yyyy HH:mm')`, `DateFormat.jm()` (12h AM/PM).

---

## 12. Các package bên thứ ba

| Package | Vai trò trong dự án | File dùng |
|---|---|---|
| `firebase_core` | khởi tạo Firebase | `main.dart` |
| `firebase_auth` | đăng nhập bằng SĐT | `auth_repository.dart` |
| `cloud_firestore` | database realtime | mọi repository |
| `firebase_storage` | upload ảnh | `common_firebase_storage_repository.dart` |
| `flutter_riverpod` / `riverpod` | quản lý state & DI | toàn bộ |
| `gap` | `Gap(12)` — khoảng cách gọn | mọi màn hình |
| `country_picker` | `showCountryPicker` chọn mã vùng | `login_screen.dart` |
| `image_picker` | chọn ảnh từ thư viện | `utils.dart` |
| `flutter_contacts` | đọc danh bạ máy (**phải dùng 2.x** — xem 12.3) | `select_contact_repository.dart` |
| `uuid` | sinh id tin nhắn/nhóm | `chat_repository.dart`, `create_group_repository.dart` |
| `intl` | format giờ | `chat_screen.dart` |
| `cached_network_image` | ảnh mạng + cache | `list_chat_widget.dart` |
| `emoji_picker_flutter` | bảng chọn emoji | `bottom_chat_field.dart` |
| `swipe_to` | vuốt để trả lời | `my_message_card.dart`, `send_message_card.dart` |
| `iconsax` | bộ icon phụ | `user_information_screen.dart`, `create_group_screen.dart` |
| `cupertino_icons` | icon kiểu iOS | (chưa dùng trực tiếp) |
| `redacted` | hiệu ứng skeleton loading | **khai báo nhưng chưa dùng** |
| `intl_translation` | (dev) công cụ dịch cũ | **thừa — l10n hiện đại không cần** |

### 12.1 `country_picker`

```dart
showCountryPicker(
  context: context,
  showPhoneCode: true,
  onSelect: (Country c) {
    setState(() { country = c; });
  },
);
```

`Country` có `.phoneCode` (`"84"`), `.name`, `.countryCode`, `.flagEmoji`.

### 12.2 `image_picker`

```dart
// lib/common/utils/utils.dart:9
Future<File?> pickImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);        // XFile → dart:io File
    }
  } catch (e) {
    showSnackbar(context: context, content: e.toString());
  }
  return image;
}
```

`ImageSource.camera` để chụp trực tiếp. Cần khai báo quyền trong
`ios/Runner/Info.plist` (`NSPhotoLibraryUsageDescription`) và `AndroidManifest.xml`.

### 12.3 `flutter_contacts`

```dart
// lib/features/select_contacts/repository/select_contact_repository.dart:21
Future<List<Contact>> getContacts() async {
  List<Contact> contacts = [];
  try {
    final status = await FlutterContacts.permissions.request(PermissionType.read);
    if (status == PermissionStatus.granted || status == PermissionStatus.limited) {
      contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.name, ContactProperty.phone},
      );
    }
  } catch (e) {
    debugPrint('--------------$e');
  }
  return contacts;
}
```

Mặc định `getAll()` chỉ trả về `id` + `displayName`. Muốn có số điện thoại phải khai báo
`properties: {ContactProperty.phone}` — nếu quên, `contact.phones` sẽ rỗng.

`PermissionStatus.limited` là trạng thái riêng của iOS: người dùng chỉ cho phép truy cập **một phần**
danh bạ. Phải chấp nhận trạng thái này cùng với `granted`, nếu không app sẽ coi như bị từ chối.

Dùng: `contact.displayName` (kiểu `String?` — phải `?? ''`), `contact.phones[0].number`.

> **Lịch sử — vì sao phải nâng lên 2.x.** Bản `1.1.x` dùng API cũ
> `FlutterContacts.requestPermission()` / `getContacts(withProperties: true)`, và ở phía iOS nó
> force-unwrap `UIApplication.shared.delegate!.window!!.rootViewController!` ngay lúc đăng ký plugin.
> Từ Flutter 3.44+ app chạy trên **UIScene lifecycle**, cửa sổ thuộc về `UIWindowScene` chứ không
> thuộc app delegate → `delegate.window` là `nil` → **app crash ngay khi khởi động**
> (`EXC_BREAKPOINT`, `Fatal error: Unexpectedly found nil`). Bản `2.0.0-beta.4` đã migrate sang
> `UISceneDelegate` và Swift Package Manager, sửa đúng lỗi này.

### 12.4 `emoji_picker_flutter`

```dart
// lib/common/widgets/bottom_chat_field.dart:186
SizedBox(
  height: 310,
  child: EmojiPicker(
    textEditingController: _messageController,
    onEmojiSelected: (category, emoji) {
      _messageController.text = _messageController.text + emoji.emoji;
      setState(() { isSendIcon = true; });
    },
  ),
)
```

Logic phối hợp bàn phím & emoji:

```dart
void _handleToggeShowEmoji() {
  setState(() { isShowEmoji = !isShowEmoji; });
  if (isShowEmoji) hideKeyboard();      // mở emoji → tắt bàn phím
}

focusNode.addListener(() {
  if (focusNode.hasFocus) {
    setState(() { isShowEmoji = false; });   // bật bàn phím → đóng emoji
  }
});
```

### 12.5 `swipe_to` — vuốt để trả lời

```dart
// lib/features/chat/widgets/my_message_card.dart:27
SwipeTo(
  onLeftSwipe: (details) {
    ref.read(chatControllerProvider).onSwipeMessage(
      message: message, isMe: true, messageEnum: MessageEnum.text, username: username,
    );
  },
  iconOnLeftSwipe: Icons.reply,
  swipeSensitivity: 8,
  animationDuration: const Duration(milliseconds: 120),
  child: Stack(...),
)
```

Tin của mình vuốt trái (`onLeftSwipe`), tin của người khác vuốt phải (`onRightSwipe`).

---

## 13. Đi hết 1 luồng: gửi tin nhắn từ A đến Z

Đây là bài tập tổng hợp — hiểu luồng này là hiểu cả app.

**1. Người dùng gõ chữ** → `TextFormField.onChanged` bật cờ hiện nút Gửi:

```dart
// bottom_chat_field.dart:93
onChanged: ((val) {
  setState(() { isSendIcon = val.isNotEmpty; });
}),
```

**2. Bấm nút gửi** → `sendMessage()`:

```dart
// bottom_chat_field.dart:49
void sendMessage() {
  String messageReplied = ref.watch(messageReplyProvider)?.message ?? "";
  ref.read(chatControllerProvider).sendMessage(
      context: context,
      text: _messageController.text,
      recieverUserId: widget.recieverUserId,
      repliedTo: '',
      repliedMessage: messageReplied,
      groupId: widget.groupId);
  hideKeyboard();
  ref.watch(messageReplyProvider.state).update((state) => null);   // xoá khung reply
  setState(() { _messageController.text = ''; isSendIcon = false; });
}
```

**3. Controller** lấy thông tin người gửi từ `userDataAuthProvider` rồi chuyển xuống repository:

```dart
// chat_controller.dart:26
ref.read(userDataAuthProvider).whenData(
  (value) => chatRepository.sendTextMessage(..., senderUser: value!, ...),
);
```

**4. Repository** làm 3 việc:

```dart
// chat_repository.dart:169
final timeSend = DateTime.now();

// a) nếu là chat 1-1 → lấy thông tin người nhận
if (groupId == '') {
  final userDataMap = await firestore.collection('users').doc(recieverUserId).get();
  recieverUserData = UserModel.fromMap(userDataMap.data()!);
}

final messageId = Uuid().v1();

// b) cập nhật "hội thoại gần đây" (lastMessage, timeSend)
_saveDataToChatsSubcollection(senderUser, recieverUserData, text, timeSend, recieverUserId, groupId);

// c) ghi document tin nhắn
_saveDataToMessageSubcollection(...);
```

**5. Firestore bắn `.snapshots()`** → `StreamBuilder` ở `chat_screen.dart` nhận `List<Message>` mới.

**6. `ListView.builder` dựng lại**, phân loại tin của mình / của người khác:

```dart
// chat_screen.dart:161
if (message.senderId == ref.watch(chatRepositoryProvider).auth.currentUser!.uid) {
  return MyMessageCard(...);       // bong bóng bên phải, màu xanh
}
return SendMessageCard(...);       // bong bóng bên trái, màu xám
```

**7. Đồng thời đánh dấu đã xem** nếu mình là người nhận:

```dart
// chat_screen.dart:152
if (!message.isSeen && FirebaseAuth.instance.currentUser!.uid == message.recieverid) {
  ref.read(chatControllerProvider).setSeenMessage(
    messageId: message.messageId,
    recieverUserId: message.senderId,
  );
}
```

> ⚠️ Đây là **side-effect trong `build`** — mỗi lần rebuild lại bắn write lên Firestore.
> `setSeenMessage` update 2 document, và write đó lại làm stream bắn lại → rebuild → ...
> May là có điều kiện `!message.isSeen` chặn vòng lặp, nhưng vẫn tốn quota.
> Nên chuyển ra `addPostFrameCallback` hoặc gom lại thành 1 batch write khi mở màn hình.

**8. Tự cuộn xuống đáy** qua `addPostFrameCallback` (đã nói ở mục 5.9).

---

## 14. Nợ kỹ thuật & bug đang tồn tại

Danh sách này là "việc cần làm" khi quay lại dự án. Sắp theo mức nghiêm trọng.

### 🔴 Nghiêm trọng

1. **`getGroupsChat()` trả về mọi group của mọi người** — `list_chat_repository.dart:57`.
   Ai cũng thấy nhóm của người khác. Cần `.where('membersUid', arrayContains: auth.currentUser!.uid)`.

2. **`import 'dart:ffi';` thừa** ở `chat_screen.dart:1` — không dùng và sẽ **fail build trên web**. Xoá.

3. **`ScrollController.jumpTo` không kiểm tra `hasClients`** — `chat_screen.dart:127`.
   Crash khi màn hình mới mở hoặc list rỗng.

4. **`UserModel.fromMap` crash nếu thiếu `groupIds`** — `user_model.dart:58`:
   `List<String>.from(map['groupIds'])` ném lỗi khi null. Sửa: `List<String>.from(map['groupIds'] ?? [])`
   (như `GroupModel` đã làm đúng ở dòng 63).

5. **`BuildContext` dùng sau `await` mà không kiểm tra `mounted`** — `auth_repository.dart:51, 68, 100`;
   `select_contact_repository.dart:53, 76`.

### 🟠 Bug logic

6. **`ChatContactModel.copyWith` sai** — `chat_contact.dart:21`: thiếu tham số `phone` trong danh sách,
   và dòng 34 viết `phone: phone ?? phone` (luôn là chính nó). Sửa:
   ```dart
   ChatContactModel copyWith({..., String? phone}) => ChatContactModel(..., phone: phone ?? this.phone);
   ```

7. **Kiểm tra `waiting`/`hasError`/`isEmpty` nằm trong `itemBuilder`** — `chat_screen.dart:134-148`.
   Không bao giờ chạy khi list rỗng. Chuyển ra ngoài `ListView.builder`.

8. **`setSeenMessage` gọi trong `build`** — `chat_screen.dart:152` (xem mục 13.7).

9. **Thứ tự `dispose()` sai** — `super.dispose()` bị gọi trước khi dọn controller ở
   `login_screen.dart:26`, `chat_screen.dart:47`, `bottom_chat_field.dart:44`, `list_chat_screen.dart:28`.

10. **Rò rỉ: chưa `dispose()`** — `focusNode` (`bottom_chat_field.dart`), `tabBarController` (`list_chat_screen.dart`).

11. **Số điện thoại xử lý bằng `replaceAll('0', '+84')`** — `select_contact_repository.dart:46`.
    Thay **mọi** số 0, nên `0901230456` → `+84901230+84456`. Phải dùng `replaceFirst`
    (như `create_group_controller.dart:21` đã làm đúng), hoặc tốt hơn là chuẩn hoá về E.164 một chỗ duy nhất.

12. **Hardcode `'Reply to Dat'`** — `my_message_card.dart:60`, `send_message_card.dart:57`.
    Nên dùng `repliedTo` từ `Message` (field đã có nhưng luôn được truyền `''`).

### 🟡 Chất lượng / dọn dẹp

13. **`ProviderRef` đã deprecated** → đổi sang `Ref` ở tất cả controller.

14. **`ref.read(p.state).update(...)` là API cũ** → `ref.read(p.notifier).state = ...`.

15. **`ref.watch` dùng trong callback** — `bottom_chat_field.dart:50, 59` → đổi sang `ref.read`.

16. **Hàm `async` khai báo `void`** thay vì `Future<void>` — khắp các repository. Người gọi không await được.

17. **Upload ảnh đại diện đang bị comment** — `auth_repository.dart:85-88`. Mọi user dùng chung ảnh hardcode.

18. **Trùng lặp `getSize`** — `lib/constant/size.dart` và `lib/common/utils/size_screen.dart` giống hệt nhau.

19. **File rác:** `lib/ firebase_options.dart` (có dấu cách đầu tên), `lib/info.dart` (mock data cũ),
    `lib/screens/mobile_layout_screen.dart` + `web_layout_screen.dart` (rỗng), `common/utils/responsive_layout.dart` (chưa dùng).

20. **`test/widget_test.dart` vẫn là template mặc định** — test này chắc chắn fail (`MyApp` không có counter,
    lại còn thiếu `ProviderScope` và Firebase). Nên xoá hoặc viết lại.

21. **`print()` thay vì `debugPrint()`** — `create_group_repository.dart:37`. `print` không bị strip khi release.

22. **`_LoginScreenState` private trong API public** — `createState()` trả về kiểu private → lint
    `library_private_types_in_public_api`. Sửa: `@override State<LoginScreen> createState() => _LoginScreenState();`

23. **Vừa `DefaultTabController` vừa `TabController` thủ công** — `list_chat_screen.dart:39` (thừa một cái).

24. **`Locale('vi', 'VI')` sai mã quốc gia** → `Locale('vi', 'VN')`. Thiếu `GlobalCupertinoLocalizations.delegate`.

25. **`lightTheme`/`darkTheme` định nghĩa nhưng chưa dùng** — `common/config/theme.dart`.

26. **`package:collection` import mà không khai báo trong `pubspec.yaml`** — `user_model.dart:3`
    dùng `DeepCollectionEquality`. Đang chạy nhờ transitive dependency; nên khai báo tường minh.

27. **`redacted` và `intl_translation` khai báo nhưng không dùng** — nên gỡ khỏi `pubspec.yaml`.

### 🔵 Tính năng còn dở

- Chưa có nút **đăng xuất** (`auth.signOut()`).
- Chỉ gửi được **tin nhắn text**; `MessageEnum` đã có `image`/`audio`/`video`/`gif` nhưng chưa xử lý.
  Các icon đính kèm/camera trong `bottom_chat_field.dart` chưa gắn `onTap`.
- `repliedMessageType` và `repliedTo` bị comment/luôn rỗng trong `Message` — reply chỉ hiện text.
- Tab **STATUS** và **CONTACT** là `Center(child: Text(...))` rỗng.
- Nút video call / call chỉ là icon trơ.
- Chat nhóm: chưa hiện tên người gửi trong bong bóng, chưa có màn quản lý thành viên.
- Chưa có Firestore Security Rules (mọi client đọc/ghi được mọi thứ nếu rules đang ở test mode).

---

## 15. Công thức thêm 1 feature mới

Ví dụ: thêm chức năng "gửi ảnh".

**Bước 1 — Model** (nếu cần field mới). `Message` đã có `type: MessageEnum` → không cần sửa.

**Bước 2 — Repository:** thêm method gọi Firebase.

```dart
// lib/features/chat/chat_repository.dart
Future<void> sendFileMessage({
  required BuildContext context,
  required File file,
  required String recieverUserId,
  required UserModel senderUser,
  required MessageEnum messageEnum,
  required String groupId,
  required Ref ref,
}) async {
  try {
    final timeSent = DateTime.now();
    final messageId = const Uuid().v1();

    final imageUrl = await ref
        .read(CommonFirebaseStorageRepositoryProvider)
        .storeFileToFirebase(
          'chat/${messageEnum.type}/${senderUser.uid}/$recieverUserId/$messageId',
          file,
        );

    UserModel? recieverUserData;
    if (groupId == '') {
      final doc = await firestore.collection('users').doc(recieverUserId).get();
      recieverUserData = UserModel.fromMap(doc.data()!);
    }

    _saveDataToChatsSubcollection(
        senderUser, recieverUserData, '📷 Photo', timeSent, recieverUserId, groupId);
    _saveDataToMessageSubcollection(
      recieverUserId: recieverUserId,
      text: imageUrl,                    // với ảnh, `text` chứa URL
      timeSent: timeSent,
      messageId: messageId,
      username: senderUser.name,
      messageType: messageEnum,
      recieverUserName: recieverUserData?.name,
      repliedMessage: '',
      repliedTo: '',
      groupId: groupId,
    );
  } catch (e) {
    showSnackbar(context: context, content: e.toString());
  }
}
```

**Bước 3 — Controller:** bọc lại, lấy user hiện tại.

```dart
// lib/features/chat/chat_controller.dart
void sendFileMessage({
  required BuildContext context,
  required File file,
  required String recieverUserId,
  required MessageEnum messageEnum,
  required String groupId,
}) {
  ref.read(userDataAuthProvider).whenData(
        (value) => chatRepository.sendFileMessage(
          context: context,
          file: file,
          recieverUserId: recieverUserId,
          senderUser: value!,
          messageEnum: messageEnum,
          groupId: groupId,
          ref: ref,
        ),
      );
}
```

**Bước 4 — UI:** gắn `onTap` cho icon camera trong `bottom_chat_field.dart`.

```dart
InkWell(
  onTap: () async {
    final file = await pickImageFromGallery(context);
    if (file != null && context.mounted) {
      ref.read(chatControllerProvider).sendFileMessage(
        context: context,
        file: file,
        recieverUserId: widget.recieverUserId,
        messageEnum: MessageEnum.image,
        groupId: widget.groupId,
      );
    }
  },
  child: Icon(Icons.camera_alt_outlined, color: Coloors.colorGrey, size: 24),
),
```

**Bước 5 — Hiển thị:** trong `MyMessageCard` / `SendMessageCard`, phân nhánh theo `type`.
(Cần truyền thêm `MessageEnum type` vào 2 widget này — hiện chúng chỉ nhận `String message`.)

```dart
type == MessageEnum.text
    ? Text(message)
    : CachedNetworkImage(imageUrl: message)
```

**Bước 6 — Thêm route** (nếu là màn hình mới): thêm `static const routeName`, thêm `case` vào `router.dart`.

---

## 16. Cheatsheet lệnh

```bash
# Cài dependency
flutter pub get

# Chạy app (chọn thiết bị)
flutter devices
flutter run
flutter run -d chrome

# Chạy chế độ release để đo hiệu năng thật
flutter run --release

# Phân tích lint / lỗi tĩnh — CHẠY CÁI NÀY TRƯỚC KHI COMMIT
flutter analyze

# Format code theo chuẩn Dart
dart format lib/

# Chạy test
flutter test

# Sinh lại file l10n sau khi sửa .arb
flutter gen-l10n

# Dọn cache khi build lỗi lạ
flutter clean && flutter pub get

# Kiểm tra package cũ
flutter pub outdated
flutter pub upgrade --major-versions

# Cấu hình lại Firebase (sinh firebase_options.dart)
dart pub global activate flutterfire_cli
flutterfire configure
```

**Phím tắt khi `flutter run` đang chạy:**

| Phím | Tác dụng |
|---|---|
| `r` | Hot reload — giữ state, áp dụng thay đổi `build()` |
| `R` | Hot restart — mất state, chạy lại `main()` |
| `p` | Bật/tắt lưới debug layout |
| `o` | Đổi qua lại Android/iOS platform |
| `q` | Thoát |

> **Hot reload không áp dụng được cho:** thay đổi trong `main()`, `initState()`,
> khai báo biến global/static, thêm/sửa field của class có sẵn, thay đổi enum.
> Gặp hành vi lạ sau khi sửa → bấm `R` (hot restart).

---

## Ghi chú cuối

Ba thứ nên làm ngay khi mở lại dự án:

1. `flutter pub get && flutter analyze` — xem danh sách cảnh báo hiện tại làm điểm xuất phát.
2. Sửa nhóm 🔴 ở [mục 14](#14-nợ-kỹ-thuật--bug-đang-tồn-tại) (đặc biệt là query group và `dart:ffi`).
3. Viết Firestore Security Rules trước khi cho ai dùng thật.
