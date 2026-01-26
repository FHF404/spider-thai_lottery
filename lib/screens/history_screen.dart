import 'package:flutter/material.dart';
import 'package:thai_lottery/models/lottery_result.dart';
import 'package:thai_lottery/widgets/result_card.dart';
import 'package:thai_lottery/theme.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback onBack;
  final List<LotteryResult> historyResults;
  final Future<void> Function() onRefresh;

  const HistoryScreen({
    super.key,
    required this.onBack,
    required this.historyResults,
    required this.onRefresh,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? _selectedYear;
  List<String> _years = [];

  @override
  void initState() {
    super.initState();
    _extractYears();
  }

  @override
  void didUpdateWidget(HistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.historyResults != widget.historyResults) {
      _extractYears();
    }
  }

  void _extractYears() {
    final Set<String> yearSet = {};
    for (var result in widget.historyResults) {
      // 泰国日期的年份通常在字符串最后，例如 "17 มกราคม 2569"
      final parts = result.date.split(' ');
      if (parts.isNotEmpty) {
        final lastPart = parts.last;
        // 简单判断是否为 4 位数字年份
        if (RegExp(r'^\d{4}$').hasMatch(lastPart)) {
          yearSet.add(lastPart);
        }
      }
    }
    
    final sortedYears = yearSet.toList()..sort((a, b) => b.compareTo(a)); // 倒序
    
    setState(() {
      _years = sortedYears;
      if (_years.isNotEmpty && _selectedYear == null) {
        _selectedYear = _years.first; // 默认选择最新一年
      }
    });
  }

  List<LotteryResult> get _filteredResults {
    if (_selectedYear == null) return widget.historyResults;
    return widget.historyResults.where((r) => r.date.endsWith(_selectedYear!)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredResults;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: const Text(
          "历史开奖记录",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 年份筛选栏
          if (_years.isNotEmpty)
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _years.length,
                itemBuilder: (context, index) {
                  final year = _years[index];
                  final isSelected = year == _selectedYear;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        "$year 年",
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: kPrimaryColor,
                      backgroundColor: Colors.grey.shade100,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedYear = year;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          
          Expanded(
            child: RefreshIndicator(
              onRefresh: widget.onRefresh,
              color: kPrimaryColor,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // 增加底部边距，防止被导航条遮挡
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return ResultCard(result: filtered[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
