import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/run.dart';
import 'supabase_run_service.dart';

// งานกับข้อมูลการวิ่ง: เพิ่ม (Create) ดู (Read) แก้ไข (Update) ลบ (Delete)
// หน้าจอทุกหน้าเรียกผ่าน runService ตัวเดียว
// แอปจริงใช้ SupabaseRunService (run_tb / run_bk) ส่วนเทสต์ใช้ LocalRunService
abstract class RunService {
  // ดึงข้อมูลทั้งหมด เรียงตามเวลาที่บันทึก
  Future<List<Run>> getAllRuns();

  // เพิ่มข้อมูล ถ้ามีรูปให้อัปโหลดรูปด้วย
  Future<void> addRun(Run run, {Uint8List? image});

  // แก้ไขข้อมูล ถ้ามีรูปใหม่ให้ลบรูปเก่าแล้วอัปโหลดรูปใหม่
  Future<void> updateRun(Run run, {Uint8List? image});

  // ลบข้อมูล และลบรูปของรายการนั้นด้วย
  Future<void> deleteRun(Run run);

  // รูปของรายการ (null = ไม่มีรูป)
  ImageProvider? imageOf(Run run);
}

// เก็บไว้ในหน่วยความจำ (ปิดแอปแล้วข้อมูลหาย) ใช้ในเทสต์
class LocalRunService implements RunService {
  final List<Run> _runs = [];
  final Map<String, Uint8List> _images = {};
  int _nextId = 1;

  static const String _scheme = 'local://';

  @override
  Future<List<Run>> getAllRuns() async => List.unmodifiable(_runs);

  @override
  Future<void> addRun(Run run, {Uint8List? image}) async {
    final id = 'run-${_nextId++}';
    if (image != null) _images[id] = image;
    _runs.add(
      run.copyWith(
        id: id,
        createdAt: DateTime.now(),
        runImageUrl: image != null ? '$_scheme$id' : null,
      ),
    );
  }

  @override
  Future<void> updateRun(Run run, {Uint8List? image}) async {
    final index = _runs.indexWhere((r) => r.id == run.id);
    if (index < 0) return;
    var updated = run;
    if (image != null) {
      _images[run.id!] = image; // แทนที่รูปเก่า
      updated = run.copyWith(runImageUrl: '$_scheme${run.id}');
    }
    _runs[index] = updated;
  }

  @override
  Future<void> deleteRun(Run run) async {
    _runs.removeWhere((r) => r.id == run.id);
    _images.remove(run.id);
  }

  @override
  ImageProvider? imageOf(Run run) {
    if (!run.hasImage) return null;
    final url = run.runImageUrl!;
    if (url.startsWith(_scheme)) {
      final bytes = _images[url.substring(_scheme.length)];
      return bytes == null ? null : MemoryImage(bytes);
    }
    return NetworkImage(url);
  }
}

RunService runService = SupabaseRunService();
