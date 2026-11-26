import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/run.dart';
import '../services/run_service.dart';
import '../widgets/run_widgets.dart';
import 'add_run_ui.dart';
import 'update_delete_run_ui.dart';

// หน้าแสดงข้อมูลการวิ่งทั้งหมด กดรายการเพื่อแก้ไข/ลบ กดปุ่ม + เพื่อเพิ่ม
class ShowAllRunUi extends StatefulWidget {
  const ShowAllRunUi({super.key});

  @override
  State<ShowAllRunUi> createState() => _ShowAllRunUiState();
}

class _ShowAllRunUiState extends State<ShowAllRunUi> {
  late Future<List<Run>> _runs = runService.getAllRuns();

  // ดึงข้อมูลใหม่หลังกลับมาจากหน้าเพิ่ม/แก้ไข
  void _reload() {
    setState(() {
      _runs = runService.getAllRuns();
    });
  }

  Future<void> _openAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddRunUi()),
    );
    _reload();
  }

  Future<void> _openEdit(Run run) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateDeleteRunUi(run: run)),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: runAppBar('Run Tracker'),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        backgroundColor: AppStyle.navy,
        foregroundColor: Colors.white,
        tooltip: 'เพิ่มข้อมูล',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: [
          const SizedBox(height: 50),
          Image.asset(AppStyle.logo, width: 200, height: 200),
          Text(
            'วิ่งกันเถอะ',
            style: GoogleFonts.prompt(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 17),
          Expanded(
            child: FutureBuilder<List<Run>>(
              future: _runs,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('โหลดข้อมูลไม่สำเร็จ: ${snapshot.error}'),
                  );
                }
                final runs = snapshot.data ?? [];
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 90),
                  itemCount: runs.length,
                  itemBuilder: (context, index) => _RunTile(
                    run: runs[index],
                    color: index.isEven ? Colors.green[50]! : Colors.grey[100]!,
                    onTap: () => _openEdit(runs[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// รายการวิ่ง 1 รายการ
class _RunTile extends StatelessWidget {
  const _RunTile({required this.run, required this.color, required this.onTap});

  final Run run;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          minVerticalPadding: 26,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.transparent,
            backgroundImage:
                runService.imageOf(run) ?? const AssetImage(AppStyle.logo),
          ),
          title: Text('วิ่งที่ไหน: ${run.runWhere}'),
          subtitle: Text('วิ่งไปเท่าไหร่: ${run.runDistance} กม.'),
          trailing: const Icon(Icons.info, color: Colors.red),
        ),
      ),
    );
  }
}
