import 'package:flutter/material.dart';
import 'package:thai_lottery/theme.dart';
import 'package:thai_lottery/services/storage_service.dart';
import 'package:thai_lottery/models/saved_ticket.dart';
import 'package:thai_lottery/models/lottery_result.dart';
import 'package:thai_lottery/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:thai_lottery/utils/lottery_utils.dart';

class ProfileScreen extends StatefulWidget {
  final Function(String) onChangeView;

  const ProfileScreen({super.key, required this.onChangeView});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _numberController = TextEditingController();
  List<SavedTicket> _tickets = [];
  LotteryResult? _latestResult;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final tickets = await StorageService.getTickets();
    final results = await ApiService.fetchLotteryData();
    
    final currentComparingResult = results['latest'];

    // 关键修正：结算并持久化
    if (currentComparingResult != null) {
      bool hasChanged = LotteryUtils.finalizePendingTickets(tickets, currentComparingResult);
      if (hasChanged) {
        await StorageService.saveAllTickets(tickets);
      }
    }

    setState(() {
      _tickets = tickets;
      _latestResult = currentComparingResult;
      _isLoading = false;
    });
  }

  Future<void> _handleManualAdd() async {
    final number = _numberController.text;
    if (number.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请输入6位完整的号码"), backgroundColor: Colors.orange),
      );
      return;
    }

    final ticket = SavedTicket(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      number: number,
      addDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );

    await StorageService.saveTicket(ticket);
    _numberController.clear();
    FocusScope.of(context).unfocus();
    
    // 重新加载数据
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ 彩票已成功添加到钱包"), backgroundColor: Colors.green),
      );
    }
  }

  // 数据加载已完成结算

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
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            color: kPrimaryColor,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
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
                  if (_tickets.isEmpty)
                    _buildEmptyTicketsHint()
                  else
                    ..._tickets.take(3).map((t) => _buildRecentTicketItem(t)),
                  const SizedBox(height: 100),
                ],
              ),
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
                    Text(
                      "${_tickets.length} 张已有彩票",
                      style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    ElevatedButton(
                      onPressed: () => widget.onChangeView('saved_tickets'),
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

  Widget _buildEmptyTicketsHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.style_outlined, size: 40, color: Colors.grey.shade200),
          const SizedBox(height: 12),
          Text("还没有彩票记录，快去添加吧", style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
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
              const SizedBox(height: 12),
              TextField(
                controller: _numberController,
                textAlign: TextAlign.center,
                maxLength: 6,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 12,
                  color: kPrimaryColor,
                ),
                decoration: InputDecoration(
                  hintText: "******",
                  hintStyle: TextStyle(color: Colors.grey.shade200),
                  counterText: "",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade100)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: kPrimaryColor, width: 2)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _handleManualAdd,
                  icon: const Icon(Icons.add_task_rounded, size: 20),
                  label: const Text("添加到彩票记录", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: kPrimaryColor.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            onTap: () => widget.onChangeView('generator'),
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
          onTap: () => widget.onChangeView('saved_tickets'),
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

  Widget _buildRecentTicketItem(SavedTicket ticket) {
    final isWin = ticket.status == 'won';
    final isPending = ticket.status == 'pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: isWin ? kRoyalGold : Colors.grey.shade200, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("添加日期: ${ticket.addDate}", style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                ticket.number,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isWin ? kPrimaryColor : kPrimaryDark,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          _buildStatusTag(isWin, isPending),
        ],
      ),
    );
  }

  Widget _buildStatusTag(bool isWin, bool isPending) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isWin ? kRoyalGold.withOpacity(0.12) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isWin ? kRoyalGold.withOpacity(0.3) : Colors.transparent),
      ),
      child: Row(
        children: [
          Icon(isWin ? Icons.emoji_events : Icons.schedule, size: 14, color: isWin ? kRoyalGold : Colors.grey),
          const SizedBox(width: 4),
          Text(
            isWin ? "已中奖" : (isPending ? "待开奖" : "未中奖"),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isWin ? kRoyalGold : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
