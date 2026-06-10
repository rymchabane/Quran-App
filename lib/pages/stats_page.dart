import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String name = "";
  bool loading = true;
  double totalMinutes = 0;
  double goalHours = 0;
  List<double> monthlyData = [];
  List<Map<String, dynamic>> topSongs = [];

  @override
  void initState() {
    super.initState();
    loadGoal();
    loadUser();
    loadStats();
  }

  double get totalHours => totalMinutes / 60;

  Future<void> loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final data = await AuthService().getProfile(user.uid);
      setState(() {
        name = data["firstName"];
        loading = false;
      });
    } else {
      setState(() {
        name = "Guest";
        loading = false;
      });
    }
  }

  Future<void> loadStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final db = FirebaseFirestore.instance;
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    final listeningSnapshot = await db
        .collection("users")
        .doc(user.uid)
        .collection("listening")
        .get();

    double total = 0;
    List<double> monthly = List.filled(daysInMonth, 0);

    for (var doc in listeningSnapshot.docs) {
      total += (doc["duration"] as num? ?? 0).toDouble();
      final date = (doc["date"] as Timestamp?)?.toDate();
      if (date != null && date.year == now.year && date.month == now.month) {
        monthly[date.day - 1] += (doc["duration"] as num? ?? 0).toDouble();
      }
    }

    final songsSnapshot = await db
        .collection("users")
        .doc(user.uid)
        .collection("songs")
        .orderBy("plays", descending: true)
        .limit(5)
        .get();

    List<Map<String, dynamic>> songs =
        songsSnapshot.docs.map((doc) => doc.data()).toList();

    setState(() {
      totalMinutes = total;
      monthlyData = monthly;
      topSongs = songs.isEmpty ? [{"title": "No data", "plays": 0}] : songs;
    });
  }

  Future<void> loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => goalHours = prefs.getDouble("goal") ?? 20);
  }

  Future<void> saveGoal(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("goal", value);
    setState(() => goalHours = value);
  }

  void showGoalDialog() {
    double tempGoal = goalHours;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Set Monthly Goal",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            onChanged: (val) => tempGoal = double.tryParse(val) ?? goalHours,
            decoration: const InputDecoration(
              hintText: "Hours per month (e.g. 20)",
              hintStyle: TextStyle(color: Color(0xFF424242)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixText: "hrs",
              suffixStyle: TextStyle(color: Color(0xFF616161)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF616161))),
          ),
          TextButton(
            onPressed: () {
              saveGoal(tempGoal);
              Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = goalHours == 0 ? 0 : (totalHours / goalHours).clamp(0, 1);

    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D0D),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00C853), strokeWidth: 2)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome, $name ",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Your listening stats",
                          style: TextStyle(color: Color(0xFF616161), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Stat cards
              Row(
                children: [
                  Expanded(child: _statCard("Total Hours", "${totalHours.toStringAsFixed(1)}", "hrs", Icons.timer_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard("Total Plays", "${totalMinutes.toInt()}", "min", Icons.play_circle_outline_rounded)),
                ],
              ),

              const SizedBox(height: 28),

              // Monthly activity chart
              _sectionHeader("This Month's Activity"),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1E1E1E)),
                ),
                child: SizedBox(
                  height: 160,
                  child: monthlyData.every((v) => v == 0)
                      ? const Center(
                          child: Text(
                            "No activity this month",
                            style: TextStyle(color: Color(0xFF424242), fontSize: 13),
                          ),
                        )
                      : BarChart(
                          BarChartData(
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: const Color(0xFF1E1E1E),
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 5,
                                  getTitlesWidget: (value, meta) => Text(
                                    "${value.toInt() + 1}",
                                    style: const TextStyle(
                                      color: Color(0xFF424242),
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            barGroups: List.generate(monthlyData.length, (i) {
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: monthlyData[i],
                                    color: const Color(0xFF00C853),
                                    width: 6,
                                    borderRadius: BorderRadius.circular(4),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: monthlyData.reduce((a, b) => a > b ? a : b) * 1.2,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 28),

              // Top tracks
              _sectionHeader("Most Played"),
              const SizedBox(height: 14),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1E1E1E)),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topSongs.length,
                  separatorBuilder: (_, __) => const Divider(
                    color: Color(0xFF1A1A1A),
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final song = topSongs[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C853).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Color(0xFF00C853),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      title: Text(
                        song["title"] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Text(
                        "${song["plays"]} plays",
                        style: const TextStyle(color: Color(0xFF616161), fontSize: 12),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              // Monthly goal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionHeader("Monthly Goal"),
                  GestureDetector(
                    onTap: showGoalDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF00C853).withOpacity(0.2)),
                      ),
                      child: const Text(
                        "Edit",
                        style: TextStyle(
                          color: Color(0xFF00C853),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1E1E1E)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${totalHours.toStringAsFixed(1)}h",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          "/ ${goalHours.toStringAsFixed(0)}h",
                          style: const TextStyle(color: Color(0xFF424242), fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color(0xFF1E1E1E),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      progress >= 1
                          ? "🎉 Goal reached!"
                          : "${(progress * 100).toStringAsFixed(0)}% complete",
                      style: TextStyle(
                        color: progress >= 1 ? const Color(0xFF00C853) : const Color(0xFF616161),
                        fontSize: 13,
                      ),
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

  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _statCard(String label, String value, String unit, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E1E1E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF00C853).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF00C853), size: 18),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: const TextStyle(color: Color(0xFF616161), fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF424242), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
