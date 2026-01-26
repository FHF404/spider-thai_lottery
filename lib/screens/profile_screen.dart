import 'package:flutter/material.dart';
import 'package:thai_lottery/theme.dart';
import 'package:thai_lottery/widgets/result_card.dart';

class ProfileScreen extends StatelessWidget {
  final Function(String) onChangeView;

  const ProfileScreen({super.key, required this.onChangeView});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: const Text(
          "我的彩票与模拟器",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade50, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCard(),
            const SizedBox(height: 24),
            _buildQuickAdd(),
            const SizedBox(height: 24),
            const Text(
              "幸运生成器",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor),
            ),
            const SizedBox(height: 12),
            _buildGeneratorShortcuts(),
            const SizedBox(height: 24),
            _buildRecentTicketsHeader(),
            const SizedBox(height: 12),
            _buildRecentTicketItem("2023年10月16日", "823491", true),
            _buildRecentTicketItem("2023年11月01日", "004812", false),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: kPrimaryDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kPrimaryColor.withOpacity(0.9), kPrimaryDark.withOpacity(0.9)],
                ),
              ),
            ),
          ),
          const Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.confirmation_number, size: 120, color: Colors.white10),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "概览",
                  style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 4),
                const Text(
                  "我保存的彩票",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "12 张有效彩票",
                      style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    ElevatedButton(
                    onPressed: () => onChangeView('saved_tickets'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kRoyalGold,
                        foregroundColor: kPrimaryDark,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text("查看历史", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAdd() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "添加新号码",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor),
        ),
        const SizedBox(height: 12),
        Container(
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
              const Text(
                "手动输入6位数字",
                style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 10,
                  color: kPrimaryColor,
                ),
                decoration: InputDecoration(
                  hintText: "000000",
                  counterText: "",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimaryColor, width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_circle, size: 20),
                  label: const Text("添加到钱包"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeneratorShortcuts() {
    final items = [
      {'icon': Icons.casino, 'label': '随机生成', 'colors': [Colors.purple, Colors.indigo]},
      {'icon': Icons.cake, 'label': '生日幸运号', 'colors': [Colors.pink, Colors.pinkAccent]},
      {'icon': Icons.auto_fix_high, 'label': '手机号魔法', 'colors': [Colors.amber, Colors.orange]},
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: GestureDetector(
            onTap: () => onChangeView('generator'),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: item['colors'] as List<Color>,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: (item['colors'] as List<Color>)[0].withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: Icon(item['icon'] as IconData, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['label'] as String,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF616161)),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentTicketsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "最近彩票",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor),
        ),
        GestureDetector(
          onTap: () => onChangeView('history'),
          child: const Text(
            "查看全部",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTicketItem(String date, String number, bool isWin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: isWin ? kRoyalGold : Colors.grey.shade300, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("开奖日期: $date", style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                number,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isWin ? kPrimaryColor : Colors.grey.shade600,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          _buildStatusTag(isWin),
        ],
      ),
    );
  }

  Widget _buildStatusTag(bool isWin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isWin ? const Color(0xFFFFFDE7) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isWin ? const Color(0xFFFFF9C4) : Colors.transparent),
      ),
      child: Row(
        children: [
          Icon(isWin ? Icons.emoji_events : Icons.schedule, size: 14, color: isWin ? kRoyalGold : Colors.grey),
          const SizedBox(width: 4),
          Text(
            isWin ? "已中奖" : "待开奖",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isWin ? Colors.brown : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
