import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/run.dart';
import 'run_service.dart';
import 'supabase_config.dart';

// เก็บข้อมูลจริงใน Supabase: ตาราง run_tb (Database) และ bucket run_bk (Storage)
class SupabaseRunService implements RunService {
  SupabaseClient get _client => Supabase.instance.client;

  // R: ดึงข้อมูลทั้งหมด เรียงตามเวลาที่บันทึก
  @override
  Future<List<Run>> getAllRuns() async {
    final rows = await _client
        .from(runTable)
        .select()
        .order('created_at', ascending: true);
    return rows.map(Run.fromJson).toList();
  }

  // C: อัปโหลดรูป (ถ้ามี) แล้วเพิ่มข้อมูล
  @override
  Future<void> addRun(Run run, {Uint8List? image}) async {
    final imageUrl = image == null ? null : await _uploadImage(image);
    await _client
        .from(runTable)
        .insert(run.copyWith(runImageUrl: imageUrl).toJson());
  }

  // U: ถ้ามีรูปใหม่ ลบรูปเก่าออกจาก Storage ก่อน แล้วอัปโหลดรูปใหม่
  @override
  Future<void> updateRun(Run run, {Uint8List? image}) async {
    var updated = run;
    if (image != null) {
      if (run.hasImage) await _removeImage(run.runImageUrl!);
      updated = run.copyWith(runImageUrl: await _uploadImage(image));
    }
    await _client.from(runTable).update(updated.toJson()).eq('id', run.id!);
  }

  // D: ลบรูป (ถ้ามี) ออกจาก Storage แล้วลบข้อมูล
  @override
  Future<void> deleteRun(Run run) async {
    if (run.hasImage) await _removeImage(run.runImageUrl!);
    await _client.from(runTable).delete().eq('id', run.id!);
  }

  @override
  ImageProvider? imageOf(Run run) {
    return run.hasImage ? NetworkImage(run.runImageUrl!) : null;
  }

  // อัปโหลดรูปไปที่ run_bk คืนลิงก์สาธารณะของรูป
  Future<String> _uploadImage(Uint8List image) async {
    final isPng = image.length > 4 && image[0] == 0x89 && image[1] == 0x50;
    final fileName =
        'run_${DateTime.now().millisecondsSinceEpoch}.${isPng ? 'png' : 'jpg'}';
    final bucket = _client.storage.from(runBucket);
    await bucket.uploadBinary(
      fileName,
      image,
      fileOptions: FileOptions(contentType: isPng ? 'image/png' : 'image/jpeg'),
    );
    return bucket.getPublicUrl(fileName);
  }

  // ลบรูปจาก run_bk ตามลิงก์ที่เก็บไว้ในตาราง
  Future<void> _removeImage(String imageUrl) async {
    final fileName = imageFileName(imageUrl);
    if (fileName == null) return;
    await _client.storage.from(runBucket).remove([fileName]);
  }
}

// ชื่อไฟล์ใน run_bk จากลิงก์สาธารณะ เช่น .../object/public/run_bk/run_1.jpg → run_1.jpg
String? imageFileName(String imageUrl) {
  const marker = '/$runBucket/';
  final path = Uri.parse(imageUrl).path;
  final index = path.indexOf(marker);
  if (index < 0) return null;
  return Uri.decodeComponent(path.substring(index + marker.length));
}
