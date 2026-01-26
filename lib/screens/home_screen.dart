import 'package:flutter/material.dart';
import 'package:thai_lottery/models/lottery_result.dart';
import 'package:thai_lottery/widgets/result_card.dart';
import 'package:thai_lottery/theme.dart';
import 'package:thai_lottery/services/api_service.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onCheckTicket;
  final VoidCallback onViewHistory;
  final VoidCallback onOpenGenerator;
  final LotteryResult? latestResult;
  final List<LotteryResult> historyResults;
  final Future<void> Function() onRefresh;

  const HomeScreen({
    super.key,
    required this.onCheckTicket,
    required this.onViewHistory,
    required this.onOpenGenerator,
    this.latestResult,
    required this.historyResults,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: RefreshIndicator(
        onRefresh: onRefresh,
        color: kPrimaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    if (latestResult != null)
                      ResultCard(
                        result: latestResult!,
                        isHero: true,
                        onCheckTicket: onCheckTicket,
                      )
                    else
                      const Center(child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      )),
                    
                    if (historyResults.length > 1) 
                      ResultCard(result: historyResults[1]),
                    
                    const SizedBox(height: 10),
                    _buildSectionHeader("更多历史结果", onViewHistory),
                    const SizedBox(height: 10),
                    
                    ...historyResults.skip(2).take(4).map((r) => ResultCard(result: r)),
                    
                    const SizedBox(height: 100), // Bottom nav space
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "皇家泰国彩票",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "官方实时更新",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              _buildQuickAction(
                Icons.qr_code_scanner, 
                "扫码查号", 
                onCheckTicket
              ),
              const SizedBox(width: 15),
              _buildQuickAction(
                Icons.psychology, 
                "AI 选号", 
                onOpenGenerator
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: kPrimaryColor, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: const Text(
            "查看全部",
            style: TextStyle(color: kPrimaryColor),
          ),
        ),
      ],
    );
  }
}
