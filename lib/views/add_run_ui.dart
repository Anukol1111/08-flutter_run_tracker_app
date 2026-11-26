import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/run.dart';
import '../services/run_service.dart';
import '../utils/run_validator.dart';
import '../widgets/run_widgets.dart';

// หน้าเพิ่มข้อมูลการวิ่ง (ถ่ายรูปหรือไม่ก็ได้)
class AddRunUi extends StatefulWidget {
  const AddRunUi({super.key});

  @override
  State<AddRunUi> createState() => _AddRunUiState();
}

class _AddRunUiState extends State<AddRunUi> {
  final _whereCtrl = TextEditingController();
  final _personCtrl = TextEditingController();
  final _distanceCtrl = TextEditingController();
  Uint8List? _image; // รูปที่ถ่าย (ยังไม่ถ่าย = null)
  bool _saving = false;

  @override
  void dispose() {
    _whereCtrl.dispose();
    _personCtrl.dispose();
    _distanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final image = await takeRunPhoto();
    if (image != null) setState(() => _image = image);
  }

  Future<void> _save() async {
    final error = validateRunInput(
      runWhere: _whereCtrl.text,
      runPerson: _personCtrl.text,
      runDistance: _distanceCtrl.text,
    );
    if (error != null) {
      showRunMessage(context, error, color: Colors.red);
      return;
    }

    setState(() => _saving = true);
    try {
      await runService.addRun(
        Run(
          runWhere: _whereCtrl.text.trim(),
          runPerson: _personCtrl.text.trim(),
          runDistance: int.parse(_distanceCtrl.text.trim()),
        ),
        image: _image,
      );
      if (!mounted) return;
      showRunMessage(context, 'บันทึกข้อมูลเรียบร้อยแล้ว', color: Colors.green);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showRunMessage(context, 'บันทึกข้อมูลไม่สำเร็จ: $e', color: Colors.red);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ปุ่มยกเลิก: ล้างข้อมูลที่ป้อนและรูปที่ถ่าย
  void _clear() {
    _whereCtrl.clear();
    _personCtrl.clear();
    _distanceCtrl.clear();
    setState(() => _image = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: runAppBar(
        'Run Tracker (เพิ่ม)',
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(40, 50, 40, 50),
        child: Column(
          children: [
            RunPhoto(
              image: _image == null ? null : MemoryImage(_image!),
              placeholder: Icon(
                Icons.add_a_photo,
                size: 150,
                color: Colors.grey[300],
              ),
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
              text: 'บันทึกข้อมูล',
              color: Colors.green,
              onPressed: _saving ? null : _save,
            ),
            const SizedBox(height: 20),
            RunButton(
              text: 'ยกเลิก',
              color: Colors.red,
              onPressed: _saving ? null : _clear,
            ),
          ],
        ),
      ),
    );
  }
}
