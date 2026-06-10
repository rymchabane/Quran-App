import 'package:flutter/material.dart';
import '../../models/reciter_model.dart';
import '../../services/api_service.dart';
import 'surah_list_page.dart';

class RecitersPage extends StatefulWidget {
  const RecitersPage({super.key});

  @override
  State<RecitersPage> createState() => _RecitersPageState();
}

class _RecitersPageState extends State<RecitersPage> {
  List<Reciter> _reciters = [];
  List<Reciter> _filtered = [];
  bool _loading = true;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(() {
      final q = _search.text.toLowerCase();
      setState(() {
        _filtered = _reciters
            .where((r) => r.name.toLowerCase().contains(q))
            .toList();
      });
    });
  }

  Future<void> _load() async {
    try {
      final reciters = await QuranService.fetchReciters();
      setState(() {
        _reciters = reciters;
        _filtered = reciters;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Reciters",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: TextField(
                controller: _search,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "Search reciters...",
                  hintStyle: TextStyle(color: Color(0xFF424242), fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF424242), size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00C853),
                strokeWidth: 2,
              ),
            )
          : _filtered.isEmpty
              ? const Center(
                  child: Text(
                    "No reciters found",
                    style: TextStyle(color: Color(0xFF616161), fontSize: 15),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final reciter = _filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SurahListPage(reciter: reciter),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161616),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFF222222)),
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00C853).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFF00C853).withOpacity(0.2),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    reciter.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFF00C853),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reciter.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (reciter.style.isNotEmpty) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        reciter.style,
                                        style: const TextStyle(
                                          color: Color(0xFF616161),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF222222),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF616161),
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
