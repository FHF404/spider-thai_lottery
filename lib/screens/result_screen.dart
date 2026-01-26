import 'package:flutter/material.dart';
import 'package:thai_lottery/theme.dart';
import 'package:thai_lottery/models/lottery_result.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> winStatus;
  final String ticketNumber;
  final LotteryResult? latestResult;
  final VoidCallback onBack;

  const ResultScreen({
    super.key,
    required this.winStatus,
    required this.ticketNumber,
    this.latestResult,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWin = winStatus['status'] == 'won';
    final List<int> winIndices = winStatus['indices'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kPrimaryColor),
          onPressed: onBack,
        ),
        title: Text(
          isWin ? "核对结果：恭喜中奖！" : "核对结果",
          style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            _buildStatusHeader(isWin),
            const SizedBox(height: 32),
            _buildTicketDisplay(isWin, winIndices),
            const SizedBox(height: 32),
            if (isWin) _buildPrizeDetails() else _buildLossMessage(),
            const SizedBox(height: 48),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(bool isWin) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: isWin ? kRoyalGold.withOpacity(0.1) : Colors.grey.shade100,
            shape: BoxShape.circle,
            border: Border.all(color: isWin ? kRoyalGold : Colors.grey.shade200, width: 2),
            boxShadow: isWin ? [BoxShadow(color: kRoyalGold.withOpacity(0.2), blurRadius: 20)] : null,
          ),
          child: Icon(
            isWin ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            size: 50,
            color: isWin ? kRoyalGold : Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          isWin ? "🎉 幸运降临！" : "很抱歉，未中奖",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: isWin ? kRoyalGold : kPrimaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "开奖日期：${latestResult?.date ?? '未知'}",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTicketDisplay(bool isWin, List<int> winIndices) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          const Text(
            "您核对的号码",
            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              final digit = ticketNumber[index];
              final isHighlighted = winIndices.contains(index);
              return Container(
                width: 44,
                height: 56,
                decoration: BoxDecoration(
                  color: isHighlighted ? kRoyalGold.withOpacity(0.12) : const Color(0xFFF9F9FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isHighlighted ? kRoyalGold : Colors.transparent, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  digit,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: isHighlighted ? kRoyalGold : kPrimaryDark,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizeDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kRoyalGold, const Color(0xFFD4A017)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: kRoyalGold.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.military_tech, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                "中奖项详情",
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            winStatus['label'] ?? "已中奖",
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const Divider(color: Colors.white30, height: 32),
          const Text(
            "累计预估奖金",
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            winStatus['amount'] ?? "未知",
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildLossMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: kPrimaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "该号码与本期官方开奖结果未匹配。每一份坚持都是好运的开始！",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: onBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 8,
              shadowColor: kPrimaryColor.withOpacity(0.4),
            ),
            child: const Text("再试一个号码", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: Text(
            "返回主页",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
