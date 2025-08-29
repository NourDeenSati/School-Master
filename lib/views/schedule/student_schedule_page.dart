import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_mangmante/core/service/api/student_schedule_controller.dart';
import 'package:school_mangmante/models/student_schedule_model.dart';

class StudentSchedulePage extends StatelessWidget {
  StudentSchedulePage({super.key});

  final StudentScheduleController controller = Get.put(StudentScheduleController());

  final Map<String, String> arabicDays = const {
    "saturday": "السبت",
    "sunday": "الأحد",
    "monday": "الاثنين",
    "tuesday": "الثلاثاء",
    "wednesday": "الأربعاء",
    "thursday": "الخميس",
  };

  int _columnsForWidth(double w) {
    if (w >= 1100) return 3; // Desktop
    if (w >= 720) return 2;  // Tablet
    return 1;                // Mobile
  }

  EdgeInsets _outerPadding(double w) {
    if (w >= 1100) return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    if (w >= 720) return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
    return const EdgeInsets.all(12);
  }

  double _cardPadding(double w) => w >= 720 ? 16 : 12;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      // appBar: AppBar(title: const Text("جدول الدوام")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final model = controller.schedule.value;
        if (model == null || model.schedule.isEmpty) {
          return const Center(child: Text("لا توجد بيانات"));
        }

        final scheduleMap = model.schedule;

        return LayoutBuilder(
          builder: (context, constraints) {
            final cols = _columnsForWidth(constraints.maxWidth);
            final padOut = _outerPadding(constraints.maxWidth);
            final padIn = _cardPadding(constraints.maxWidth);

            return RefreshIndicator(
              onRefresh: controller.fetchSchedule,
              child: ListView.builder(
                padding: padOut,
                itemCount: controller.daysOrder.length,
                itemBuilder: (context, index) {
                  final dayKey = controller.daysOrder[index];
                  final dayItems = scheduleMap[dayKey] ?? <ScheduleItem>[];
                  if (dayItems.isEmpty) return const SizedBox.shrink();

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: EdgeInsets.all(padIn),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // رأس اليوم
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  arabicDays[dayKey] ?? dayKey,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              _CountChip(count: dayItems.length),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // شبكة الحصص
                          GridView.builder(
                            itemCount: dayItems.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cols,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              mainAxisExtent: cols == 1 ? 122 : 104,
                            ),
                            itemBuilder: (context, i) {
                              final item = dayItems[i];
                              return _ScheduleCard(item: item, color: color);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}

class _CountChip extends StatelessWidget {
  final int count;
  const _CountChip({required this.count});
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.primary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event, size: 16),
          const SizedBox(width: 6),
          Text('$count', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleItem item;
  final ColorScheme color;
  const _ScheduleCard({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.primary.withOpacity(0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // الفترة
              CircleAvatar(
                radius: 20,
                backgroundColor: color.primary.withOpacity(0.15),
                child: Text(
                  item.period,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color.primary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // المادة + الأستاذ + القسم
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: -6,
                      children: [
                        _InfoChip(icon: Icons.person, text: item.teacher),
                        if ((item.section ?? '').isNotEmpty)
                          _InfoChip(icon: Icons.groups_2, text: 'القسم: ${item.section}'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // الوقت
              Flexible(
                flex: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(Icons.schedule, size: 16),
                    const SizedBox(height: 4),
                    Text(
                      item.time,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: cs.secondaryContainer.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
                softWrap: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
