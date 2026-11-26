import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/run.dart';
import '../services/run_service.dart';
import '../utils/run_validator.dart';
import '../widgets/run_widgets.dart';

// หน้าแก้ไข/ลบข้อมูลการวิ่งที่เลือก
class UpdateDeleteRunUi extends StatefulWidget {
  const UpdateDeleteRunUi({super.key, required this.run});

  final Run run;

  @override
  State<UpdateDeleteRunUi> createState() => _UpdateDeleteRunUiState();
}

class _UpdateDeleteRunUiState extends State<UpdateDeleteRunUi> {
  late final _whereCtrl = TextEditingController(text: widget.run.runWhere);
  late final _personCtrl = TextEditingController(text: widget.run.runPerson);
  late final _distanceCtrl = TextEditingController(
    text: '${widget.run.runDistance}',
  );
  Uint8List? _newImage; // รูปใหม่ที่ถ่าย (ไม่ถ่าย = ใช้รูปเดิม)
  bool _busy = false;

  @override
  void dispose() {
    _whereCtrl.dispose();
    _personCtrl.dispose();
    _distanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final image = await takeRunPhoto();
    if (image != null) setState(() => _newImage = image);
  }

  Future<void> _update() async {
    final error = validateRunInput(
      runWhere: _whereCtrl.text,
      runPerson: _personCtrl.text,
      runDistance: _distanceCtrl.text,
    );
    if (error != null) {
      showRunMessage(context, error, color: Colors.red);
      return;
    }

    setState(() => _busy = true);
    try {
      await runService.updateRun(
        widget.run.copyWith(
          runWhere: _whereCtrl.text.trim(),
          runPerson: _personCtrl.text.trim(),
          runDistance: int.parse(_distanceCtrl.text.trim()),
        ),
        image: _newImage,
      );
      if (!mounted) return;
      showRunMessage(context, 'แก้ไขข้อมูลเรียบร้อยแล้ว', color: Colors.green);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showRunMessage(context, 'แก้ไขข้อมูลไม่สำเร็จ: $e', color: Colors.red);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('ต้องการลบข้อมูลการวิ่งนี้ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await runService.deleteRun(widget.run);
      if (!mounted) return;
      showRunMessage(context, 'ลบข้อมูลเรียบร้อยแล้ว', color: Colors.green);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showRunMessage(context, 'ลบข้อมูลไม่สำเร็จ: $e', color: Colors.red);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider? image = _newImage != null
        ? MemoryImage(_newImage!)
        : runService.imageOf(widget.run);

    return Scaffold(
      appBar: runAppBar(
        'Run Tracker (แก้ไข/ลบ)',
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(40, 50, 40, 50),
        child: Column(
          children: [
            RunPhoto(
              image: image,
              placeholder: Image.asset(AppStyle.logo, width: 150, height: 150),
              onTap: _takePhoto,
            ),
            const SizedBox(height: 50),
            RunTextField(
              label: 'วิ่งที่ไหน',
              hint: 'เช่น สวนสาธารณะ, สนามกีฬา หรือ อื่นๆ',
              controller: _whereCtrl,
            ),
            const SizedBox(height: 20),
            RunTextField(
              label: 'วิ่งกับใคร',
              hint: 'เช่น เพื่อน 3 คน, แฟน หรือ อื่นๆ',
              controller: _personCtrl,
            ),
            const SizedBox(height: 20),
            RunTextField(
              label: 'ระยะทาง',
              hint: 'เช่น 1, 5, 11 หรือ อื่นๆ',
              controller: _distanceCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 40),
            RunButton(
              text: 'บันทึกแก้ไขข้อมูล',
              color: Colors.green,
              onPressed: _busy ? null : _update,
            ),
            const SizedBox(height: 20),
            RunButton(
              text: 'ลบข้อมูล',
              color: Colors.red,
              onPressed: _busy ? null : _delete,
            ),
          ],
        ),
      ),
    );
  }
}
