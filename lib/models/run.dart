// ข้อมูลการวิ่ง 1 รายการ (ตรงกับตาราง run_tb ใน Supabase)
class Run {
  const Run({
    this.id,
    this.createdAt,
    required this.runWhere,
    required this.runPerson,
    required this.runDistance,
    this.runImageUrl,
  });

  final String? id; // uuid
  final DateTime? createdAt; // created_at
  final String runWhere; // วิ่งที่ไหน
  final String runPerson; // วิ่งกับใคร
  final int runDistance; // ระยะทาง (กม.)
  final String? runImageUrl; // ลิงก์รูปใน Storage (ไม่มีรูป = null)

  bool get hasImage => runImageUrl != null && runImageUrl!.isNotEmpty;

  factory Run.fromJson(Map<String, dynamic> json) {
    return Run(
      id: json['id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      runWhere: json['runWhere'] as String? ?? '',
      runPerson: json['runPerson'] as String? ?? '',
      runDistance: (json['runDistance'] as num?)?.toInt() ?? 0,
      runImageUrl: json['runImageUrl'] as String?,
    );
  }

  // ข้อมูลที่ส่งไปบันทึก (id และ created_at ให้ฐานข้อมูลสร้างเอง)
  Map<String, dynamic> toJson() {
    return {
      'runWhere': runWhere,
      'runPerson': runPerson,
      'runDistance': runDistance,
      'runImageUrl': runImageUrl,
    };
  }

  Run copyWith({
    String? id,
    DateTime? createdAt,
    String? runWhere,
    String? runPerson,
    int? runDistance,
    String? runImageUrl,
  }) {
    return Run(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      runWhere: runWhere ?? this.runWhere,
      runPerson: runPerson ?? this.runPerson,
      runDistance: runDistance ?? this.runDistance,
      runImageUrl: runImageUrl ?? this.runImageUrl,
    );
  }
}
