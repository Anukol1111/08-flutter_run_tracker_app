import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_run_tracker_app/main.dart';
import 'package:flutter_run_tracker_app/models/run.dart';
import 'package:flutter_run_tracker_app/services/run_service.dart';
import 'package:flutter_run_tracker_app/services/supabase_run_service.dart';
import 'package:flutter_run_tracker_app/utils/run_validator.dart';
import 'package:flutter_run_tracker_app/views/add_run_ui.dart';
import 'package:flutter_run_tracker_app/views/show_all_run_ui.dart';
import 'package:flutter_run_tracker_app/views/update_delete_run_ui.dart';

void main() {
  // ไม่ให้ google_fonts โหลดฟอนต์จากอินเทอร์เน็ตตอนรันเทสต์
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  // เริ่มทุกเทสต์ด้วยข้อมูลว่าง
  setUp(() => runService = LocalRunService());

  // ขนาดจอ iPhone 16 Pro Max (440 x 956)
  void useIphone16ProMax(WidgetTester tester) {
    tester.view.physicalSize = const Size(1320, 2868);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  test('validateRunInput checks every field', () {
    String? check(String w, String p, String d) =>
        validateRunInput(runWhere: w, runPerson: p, runDistance: d);
    expect(check('', 'คนเดียว', '2'), 'กรุณาป้อนวิ่งที่ไหน');
    expect(check('สวน', ' ', '2'), 'กรุณาป้อนวิ่งกับใคร');
    expect(check('สวน', 'คนเดียว', ''), 'กรุณาป้อนระยะทาง');
    expect(check('สวน', 'คนเดียว', '2.5'), isNotNull);
    expect(check('สวน', 'คนเดียว', '0'), isNotNull);
    expect(check('สวน', 'คนเดียว', ' 5 '), isNull);
  });

  test('Run.fromJson / toJson use the run_tb column names', () {
    final run = Run.fromJson({
      'id': 'a1',
      'created_at': '2026-11-26T08:00:00+00:00',
      'runWhere': 'ม.เอเชีย',
      'runPerson': 'คนเดียว',
      'runDistance': 2,
      'runImageUrl': null,
    });
    expect(run.runDistance, 2);
    expect(run.hasImage, isFalse);
    expect(run.toJson(), {
      'runWhere': 'ม.เอเชีย',
      'runPerson': 'คนเดียว',
      'runDistance': 2,
      'runImageUrl': null,
    });
  });

  test('LocalRunService adds, updates and deletes with images', () async {
    final service = LocalRunService();
    await service.addRun(
      const Run(runWhere: 'สวน', runPerson: 'เพื่อน', runDistance: 3),
      image: Uint8List.fromList([1, 2, 3]),
    );
    var runs = await service.getAllRuns();
    expect(runs.single.id, isNotNull);
    expect(service.imageOf(runs.single), isA<MemoryImage>());

    await service.updateRun(runs.single.copyWith(runDistance: 10));
    runs = await service.getAllRuns();
    expect(runs.single.runDistance, 10);
    expect(service.imageOf(runs.single), isNotNull); // รูปเดิมยังอยู่

    await service.deleteRun(runs.single);
    expect(await service.getAllRuns(), isEmpty);
  });

  test('imageFileName reads the file name from a run_bk public link', () {
    expect(
      imageFileName(
        'https://abc.supabase.co/storage/v1/object/public/run_bk/run_1.jpg',
      ),
      'run_1.jpg',
    );
    expect(imageFileName('https://example.com/other.png'), isNull);
  });

  test('logo asset exists', () {
    expect(File('assets/images/runner_logo.png').existsSync(), isTrue);
  });

  testWidgets('Splash → empty list → add → edit → delete', (tester) async {
    useIphone16ProMax(tester);
    await tester.pumpWidget(const FlutterRunTrackerApp());
    expect(find.text('RUN TRACKER'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(ShowAllRunUi), findsOneWidget);
    expect(find.text('วิ่งกันเถอะ'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);

    // เพิ่มข้อมูล: กดบันทึกโดยไม่กรอกจะมีคำเตือน
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(AddRunUi), findsOneWidget);
    await tester.tap(find.text('บันทึกข้อมูล'));
    await tester.pump();
    expect(find.text('กรุณาป้อนวิ่งที่ไหน'), findsOneWidget);

    // ยกเลิก = ล้างข้อมูลที่ป้อน
    await tester.enterText(find.byType(TextField).at(0), 'ทดสอบ');
    await tester.tap(find.text('ยกเลิก'));
    await tester.pump();
    expect(find.text('ทดสอบ'), findsNothing);

    await tester.enterText(find.byType(TextField).at(0), 'วิ่งที่ ม.เอเชีย');
    await tester.enterText(find.byType(TextField).at(1), 'วิ่งคนเดียว');
    await tester.enterText(find.byType(TextField).at(2), '2');
    await tester.tap(find.text('บันทึกข้อมูล'));
    await tester.pumpAndSettle();
    expect(find.byType(AddRunUi), findsNothing);
    expect(find.text('วิ่งที่ไหน: วิ่งที่ ม.เอเชีย'), findsOneWidget);
    expect(find.text('วิ่งไปเท่าไหร่: 2 กม.'), findsOneWidget);

    // แก้ไขระยะทาง
    await tester.tap(find.text('วิ่งที่ไหน: วิ่งที่ ม.เอเชีย'));
    await tester.pumpAndSettle();
    expect(find.byType(UpdateDeleteRunUi), findsOneWidget);
    expect(find.text('วิ่งคนเดียว'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(2), '7');
    await tester.tap(find.text('บันทึกแก้ไขข้อมูล'));
    await tester.pumpAndSettle();
    expect(find.text('วิ่งไปเท่าไหร่: 7 กม.'), findsOneWidget);

    // ลบ (ต้องยืนยันก่อน)
    await tester.tap(find.byIcon(Icons.info));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ลบข้อมูล'));
    await tester.pumpAndSettle();
    expect(find.text('ยืนยันการลบ'), findsOneWidget);
    await tester.tap(find.text('ลบ'));
    await tester.pumpAndSettle();
    expect(find.byType(ShowAllRunUi), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });
}
