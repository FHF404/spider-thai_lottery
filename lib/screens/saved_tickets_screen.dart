import 'package:flutter/material.dart';
import 'package:thai_lottery/widgets/result_card.dart';
import 'package:thai_lottery/models/lottery_result.dart';
import 'package:thai_lottery/theme.dart';

class SavedTicketsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SavedTicketsScreen({super.key, required this.onBack});

  @override
  State<SavedTicketsScreen> createState() => _SavedTicketsScreenState();
}

class _SavedTicketsScreenState extends State<SavedTicketsScreen> {
  String _activeTab = 'all'; // 'all' | 'pending' | 'won' | 'lost'

  @override
  Widget build(BuildContext context) {
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
          "我保存的彩票",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (_activeTab == 'all' || _activeTab == 'won') _buildWinningCard(),
                  if (_activeTab == 'all' || _activeTab == 'pending') _buildPendingCard(),
                  if (_activeTab == 'all' || _activeTab == 'won') _buildSmallWinCard(),
                  if (_activeTab == 'all' || _activeTab == 'lost') _buildLostCard(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = [
      {'id': 'all', 'label': '全部'},
      {'id': 'pending', 'label': '待开奖'},
      {'id': 'won', 'label': '已中奖'},
      {'id': 'lost', 'label': '未中奖'},
    ];

    return Container(
      color: Colors.white,
      child: Row(
        children: tabs.map((tab) {
          final isActive = _activeTab == tab['id'];
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _activeTab = tab['id']!),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? kPrimaryColor : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  tab['label']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isActive ? kPrimaryColor : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWinningCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kRoyalGold.withOpacity(0.3), width: 2),
        boxShadow: [BoxShadow(color: kRoyalGold.withOpacity(0.1), blurRadius: 10)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.workspace_premium, size: 100, color: kRoyalGold.withOpacity(0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("开奖日期: 2023-10-16", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: kRoyalGold, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: const [
                          Icon(Icons.stars, color: Colors.white, size: 10),
                          SizedBox(width: 4),
                          Text("恭喜中奖", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(color: kRoyalGold, fontWeight: FontWeight.bold, fontSize: 18),
                    children: [
                      TextSpan(text: "一等奖 "),
                      TextSpan(text: "(6,000,000 泰铢)", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildNumberRow(['8', '8', '8', '8', '8', '8']),
                const SizedBox(height: 12),
                const Divider(),
                const Text("添加日期: 2023-10-01", style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
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
                  const Text("下期开奖: 2023-11-01", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text("待开奖", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: const Text("倒计时 2天", style: TextStyle(color: kPrimaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          _buildNumberRow(['1', '2', '3', '4', '5', '6']),
          const SizedBox(height: 12),
          const Divider(),
          const Text("添加日期: 2023-10-20", style: TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSmallWinCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kRoyalGold.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("开奖日期: 2023-10-16", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("后2位 (2,000 泰铢)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kRoyalGold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: kRoyalGold.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: const Text("已中奖", style: TextStyle(color: kRoyalGold, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNumberRow(['4', '5', '6', '7', '8', '9'], winIndices: [4, 5]),
          const SizedBox(height: 12),
          const Divider(),
          const Text("添加日期: 2023-10-10", style: TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildLostCard() {
    return Opacity(
      opacity: 0.7,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid), // BorderStyle.dashed is not natively available in BoxDecoration easily
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("开奖日期: 2023-10-01", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("未中奖", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ],
                ),
                const Icon(Icons.cancel, color: Colors.grey, size: 24),
              ],
            ),
            const SizedBox(height: 16),
            _buildNumberRow(['4', '5', '6', '7', '8', '9'], isGrayscale: true),
            const SizedBox(height: 12),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("添加日期: 2023-09-25", style: TextStyle(color: Colors.grey, fontSize: 10)),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kPrimaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("再次购买", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberRow(List<String> numbers, {List<int>? winIndices, bool isGrayscale = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(numbers.length, (index) {
        final isWin = winIndices?.contains(index) ?? false;
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isWin ? kRoyalGold.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isWin ? kRoyalGold : Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
          ),
          alignment: Alignment.center,
          child: Text(
            numbers[index],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isGrayscale ? Colors.grey : (isWin ? kRoyalGold : Colors.black),
            ),
          ),
        );
      }),
    );
  }
}
