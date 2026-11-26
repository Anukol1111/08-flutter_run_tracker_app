import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// สีและรูปที่ใช้ร่วมกันทุกหน้า
class AppStyle {
  static const Color navy = Color(0xFF001551);
  static const String logo = 'assets/images/runner_logo.png';
}

// AppBar สีกรมท่า ตัวหนังสือสีขาว
AppBar runAppBar(String title, {bool showBack = false, VoidCallback? onBack}) {
  return AppBar(
    backgroundColor: AppStyle.navy,
    foregroundColor: Colors.white,
    centerTitle: true,
    automaticallyImplyLeading: false,
    leading: showBack
        ? IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new),
          )
        : null,
    title: Text(title, style: const TextStyle(color: Colors.white)),
  );
}

// หัวข้อ + ช่องกรอก เช่น "วิ่งที่ไหน"
class RunTextField extends StatelessWidget {
  const RunTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18)),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

// ปุ่มเต็มความกว้าง สูง 50 เช่น บันทึก / ยกเลิก / ลบ
class RunButton extends StatelessWidget {
  const RunButton({
    super.key,
    required this.text,
    required this.color,
    required this.onPressed,
  });

  final String text;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Text(text),
      ),
    );
  }
}

// รูปขนาด 150x150 กดเพื่อเปิดกล้องถ่ายรูป
class RunPhoto extends StatelessWidget {
  const RunPhoto({
    super.key,
    required this.image,
    required this.placeholder,
    required this.onTap,
  });

  final ImageProvider? image; // รูปที่มีอยู่ หรือรูปที่เพิ่งถ่าย
  final Widget placeholder; // แสดงเมื่อยังไม่มีรูป
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        height: 150,
        child: image == null
            ? placeholder
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image(image: image!, fit: BoxFit.cover),
              ),
      ),
    );
  }
}

// เปิดกล้องถ่ายรูป คืนข้อมูลรูป หรือ null ถ้าไม่ได้ถ่าย
Future<Uint8List?> takeRunPhoto() async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.camera,
    maxWidth: 1024,
    imageQuality: 80,
  );
  return file?.readAsBytes();
}

// แจ้งเตือนด้านล่างจอ
void showRunMessage(BuildContext context, String message, {Color? color}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
}
