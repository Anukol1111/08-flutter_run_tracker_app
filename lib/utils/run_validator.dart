// ตรวจข้อมูลก่อนบันทึก คืนข้อความเตือน หรือ null ถ้าข้อมูลถูกต้อง
String? validateRunInput({
  required String runWhere,
  required String runPerson,
  required String runDistance,
}) {
  if (runWhere.trim().isEmpty) return 'กรุณาป้อนวิ่งที่ไหน';
  if (runPerson.trim().isEmpty) return 'กรุณาป้อนวิ่งกับใคร';
  if (runDistance.trim().isEmpty) return 'กรุณาป้อนระยะทาง';
  final distance = int.tryParse(runDistance.trim());
  if (distance == null || distance <= 0) {
    return 'ระยะทางต้องเป็นตัวเลขจำนวนเต็มที่มากกว่า 0';
  }
  return null;
}
