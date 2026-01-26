import 'package:flutter/material.dart';
import 'package:thai_lottery/models/lottery_result.dart';
import 'package:thai_lottery/widgets/result_card.dart';
import 'package:thai_lottery/theme.dart';

class HistoryScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: onBack,
        ),
        title: const Text(
          "历史开奖记录",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        color: kPrimaryColor,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: historyResults.length,
          itemBuilder: (context, index) {
            return ResultCard(result: historyResults[index]);
          },
        ),
      ),
    );
  }
}
