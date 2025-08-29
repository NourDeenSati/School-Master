import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:school_mangmante/core/controllers/call/student_call_controller.dart';
import 'package:school_mangmante/core/controllers/student_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:school_mangmante/core/service/storage_service.dart';
import 'package:school_mangmante/views/quiz/student_quizzes_list_page.dart';
import 'package:school_mangmante/views/schedule/student_schedule_page.dart';
import 'package:school_mangmante/views/stream/student/student_scheduled_calls_page.dart';

class StudentHomeView extends StatefulWidget {
  const StudentHomeView({super.key});
  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  final controller = Get.put(StudentController());
  final PageController pageController = PageController();
  final StudentCallController stuController = Get.put(StudentCallController());
  int bottomNavIndex = 0;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();
    final name = storage.firstName;
    return GetBuilder<StudentController>(
      builder: (_) {
        if (controller.isLoading.value) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('مرحبا ${name}',
                style: const TextStyle(color: Colors.white)),
          ),
          body: PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (i) => setState(() => bottomNavIndex = i),
            children: [
              _StatsTab(controller),
              Center(child: StudentSchedulePage()),
              Center(child: StudentScheduledCallsPage()),
              Center(child: StudentQuizzesListPage()),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: bottomNavIndex,
            selectedItemColor: const Color(0xFF4B70F5),
            unselectedItemColor: Colors.grey,
            onTap: (i) {
              setState(() => bottomNavIndex = i);
              pageController.jumpToPage(i);
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.analytics), label: 'الإحصائيات'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.table_chart), label: 'برنامج الدوام'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.stream), label: 'البثوث'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.quiz), label: 'الإختبارات'),
            ],
          ),
        );
      },
    );
  }
}

class _AttendanceBarChart extends StatelessWidget {
  final StudentController c;
  const _AttendanceBarChart(this.c);

  @override
  Widget build(BuildContext context) {
    final s = c.stats.value;
    if (s.attendanceByType.isEmpty) {
      return const Center(child: Text('لا توجد بيانات حضور لعرضها'));
    }

    // ترتيب ثابت لأنواع الحضور إن وُجدت
    final order = ['present', 'late', 'absent'];
    final items = s.attendanceByType.toList()
      ..sort((a, b) => order.indexOf(a.name).compareTo(order.indexOf(b.name)));

    final groups = <BarChartGroupData>[];
    for (int i = 0; i < items.length; i++) {
      final t = items[i];
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: t.count.toDouble(),
              width: 18,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: Text('حضور حسب النوع',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: true, reservedSize: 36)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= items.length)
                              return const SizedBox.shrink();
                            final name = items[idx].name;
                            String label = name == 'present'
                                ? 'حضور'
                                : name == 'late'
                                    ? 'تأخر'
                                    : 'غياب';
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(label,
                                  style: const TextStyle(fontSize: 12)),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    barGroups: groups,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DictationLineChart extends StatelessWidget {
  final StudentController c;
  const _DictationLineChart(this.c);

  @override
  Widget build(BuildContext context) {
    final s = c.stats.value;
    if (s.dictations.isEmpty) {
      return const Center(child: Text('لا توجد إملاءات لعرضها'));
    }

    // ترتيب حسب التاريخ إن احتجت (القيمة لديك نص ISO)
    final dicts = s.dictations.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final spots = <FlSpot>[];
    for (int i = 0; i < dicts.length; i++) {
      spots.add(FlSpot(i.toDouble(), dicts[i].result));
    }

    return SizedBox(
      height: 220,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: Text('نتائج التسميعات بمرور الوقت',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: true, reservedSize: 36)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= dicts.length)
                              return const SizedBox.shrink();
                            // اختصار التاريخ: يوم/شهر
                            final date = dicts[idx].createdAt;
                            final mmdd = date.length >= 10
                                ? date.substring(5, 10)
                                : date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(mmdd,
                                  style: const TextStyle(fontSize: 11)),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                        spots: spots,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  final StudentController c;
  const _StatsTab(this.c);

  @override
  Widget build(BuildContext context) {
    final s = c.stats.value;

    return RefreshIndicator(
      onRefresh: () => c.fetchAll(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Notes
            _SectionTitle('الملاحظات'),
            _CardWrap(children: [
              _StatTile(
                title: 'إيجابي',
                value: '${s.notesSummary?.positiveCount ?? 0}',
                subtitle:
                    'نقاط: ${(s.notesSummary?.positivePoints ?? 0).toStringAsFixed(2)}',
                icon: Icons.thumb_up,
              ),
              _StatTile(
                title: 'سلبي',
                value: '${s.notesSummary?.negativeCount ?? 0}',
                subtitle:
                    'نقاط: ${(s.notesSummary?.negativePoints ?? 0).toStringAsFixed(2)}',
                icon: Icons.thumb_down,
              ),
              _StatTile(
                title: 'صافي',
                value: (s.notesSummary?.netPoints ?? 0).toStringAsFixed(2),
                subtitle: 'مجموع النقاط',
                icon: Icons.calculate,
              ),
            ]),
            const SizedBox(height: 8),
            _MiniList(
              title: 'آخر الملاحظات',
              headers: const ['السبب', 'النوع', 'القيمة', 'التاريخ'],
              rows: s.notes
                  .take(5)
                  .map((n) => [n.reason, n.type, n.value, n.createdAt])
                  .toList(),
              emptyText: 'لا توجد ملاحظات',
            ),

            const SizedBox(height: 24),

            // Attendance
            _SectionTitle('الحضور'),
            _AttendanceBarChart(c),
            const SizedBox(height: 24),

            _CardWrap(
              children: s.attendanceByType
                  .map((t) => _StatTile(
                        title: t.name,
                        value: '${t.count}',
                        subtitle: 'النقاط: ${t.points}',
                        icon: t.name == 'present'
                            ? Icons.check_circle
                            : (t.name == 'late' ? Icons.timer : Icons.cancel),
                      ))
                  .toList()
                ..add(_StatTile(
                  title: 'الإجمالي',
                  value: '${s.attendanceTotalCount}',
                  subtitle: 'النقاط: ${s.attendanceTotalPoints}',
                  icon: Icons.summarize,
                )),
            ),
            const SizedBox(height: 8),
            _MiniList(
              title: 'أحدث سجلات الحضور',
              headers: const ['التاريخ', 'النوع', 'سبب', 'القيمة'],
              rows: s.attendances
                  .take(5)
                  .map((a) => [
                        a.date,
                        a.typeName,
                        a.justification ?? '-',
                        a.typeValue.toString()
                      ])
                  .toList(),
              emptyText: 'لا يوجد بيانات حضور',
            ),

            const SizedBox(height: 24),

            // Dictations
            _SectionTitle('التسميعات'),
            _DictationLineChart(c),
            const SizedBox(height: 24),
            _CardWrap(children: [
              _StatTile(
                  title: 'عدد',
                  value: '${s.dictationSummary?.count ?? 0}',
                  subtitle: 'الكل',
                  icon: Icons.format_list_numbered),
              _StatTile(
                  title: 'متوسط',
                  value: (s.dictationSummary?.avg ?? 0).toStringAsFixed(2),
                  subtitle: 'متوسط النتيجة',
                  icon: Icons.show_chart),
              _StatTile(
                  title: 'أفضل',
                  value: (s.dictationSummary?.best ?? 0).toStringAsFixed(2),
                  subtitle: 'أعلى نتيجة',
                  icon: Icons.workspace_premium),
              _StatTile(
                  title: 'آخر',
                  value: (s.dictationSummary?.last ?? 0).toStringAsFixed(2),
                  subtitle: 'آخر نتيجة',
                  icon: Icons.update),
            ]),
            const SizedBox(height: 8),
            _MiniList(
              title: 'آخر التسميعات',
              headers: const ['#', 'النتيجة', 'التاريخ'],
              rows: s.dictations
                  .take(5)
                  .map((d) =>
                      ['${d.id}', d.result.toStringAsFixed(2), d.createdAt])
                  .toList(),
              emptyText: 'لا توجد تسميعات',
            ),

            const SizedBox(height: 24),

            // Exams
            _SectionTitle('الامتحانات'),
            _CardWrap(children: [
              _StatTile(
                  title: 'إجمالي',
                  value: '${s.examsSummary?.total ?? 0}',
                  subtitle: 'عدد المحاولات',
                  icon: Icons.ballot),
              _StatTile(
                  title: 'قيد المراجعة',
                  value: '${s.examsSummary?.pending ?? 0}',
                  subtitle: 'انتظار/معلقة',
                  icon: Icons.hourglass_empty),
              _StatTile(
                  title: 'معتمدة',
                  value: '${s.examsSummary?.approved ?? 0}',
                  subtitle: 'تم اعتمادها',
                  icon: Icons.verified),
              _StatTile(
                  title: 'متوسط',
                  value: (s.examsSummary?.avgResult ?? 0).toStringAsFixed(2),
                  subtitle: 'متوسط النتيجة',
                  icon: Icons.assessment),
            ]),
            const SizedBox(height: 8),
            _MiniList(
              title: 'آخر محاولات الامتحان',
              headers: const ['#', 'المادة', 'الحالة', 'النتيجة', 'التاريخ'],
              rows: s.attempts
                  .take(5)
                  .map((e) => [
                        '${e.attemptId}',
                        e.subjectName,
                        e.status,
                        e.result.toStringAsFixed(2),
                        e.submittedAt
                      ])
                  .toList(),
              emptyText: 'لا توجد محاولات',
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

class _CardWrap extends StatelessWidget {
  final List<Widget> children;
  const _CardWrap({required this.children});
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: children
          .map((w) => SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 22, child: w))
          .toList(),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  const _StatTile(
      {required this.title,
      required this.value,
      required this.subtitle,
      required this.icon});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            CircleAvatar(radius: 22, child: Icon(icon)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ]),
            ),
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _MiniList extends StatelessWidget {
  final String title;
  final List<String> headers;
  final List<List<String>> rows;
  final String emptyText;
  const _MiniList(
      {required this.title,
      required this.headers,
      required this.rows,
      required this.emptyText});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Align(
                alignment: Alignment.centerRight,
                child: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child:
                    Text(emptyText, style: TextStyle(color: Colors.grey[600])),
              )
            else
              Column(
                children: [
                  _MiniHeader(headers),
                  const Divider(height: 8),
                  ...rows.map((r) => _MiniRow(r)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _MiniHeader extends StatelessWidget {
  final List<String> headers;
  const _MiniHeader(this.headers);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: headers
          .map((h) => Expanded(
              child: Text(h,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600))))
          .toList(),
    );
  }
}

class _MiniRow extends StatelessWidget {
  final List<String> cells;
  const _MiniRow(this.cells);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: cells
            .map((c) => Expanded(
                child: Text(c,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12))))
            .toList(),
      ),
    );
  }
}
