import 'package:flutter/material.dart';
import 'package:thai_lottery/widgets/standard_app_bar.dart';
import 'package:thai_lottery/models/lottery_result.dart';
import 'package:thai_lottery/models/saved_ticket.dart';
import 'package:thai_lottery/services/storage_service.dart';
import 'package:thai_lottery/services/api_service.dart';
import 'package:thai_lottery/theme.dart';
import 'package:thai_lottery/utils/lottery_utils.dart';

class SavedTicketsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SavedTicketsScreen({super.key, required this.onBack});

  @override
  State<SavedTicketsScreen> createState() => _SavedTicketsScreenState();
}

class _SavedTicketsScreenState extends State<SavedTicketsScreen> {
  String _activeTab = 'all'; // 'all' | 'pending' | 'won' | 'lost'
  List<SavedTicket> _tickets = [];
  LotteryResult? _latestResult;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await ApiService.fetchLotteryData();
    final tickets = await StorageService.getTickets();
    
    final currentComparingResult = results['latest'];

    // 关键修正：对待开奖的进行结算并持久化存储
    if (currentComparingResult != null) {
      bool hasChanged = LotteryUtils.finalizePendingTickets(tickets, currentComparingResult);
      if (hasChanged) {
        await StorageService.saveAllTickets(tickets);
      }
    }
    
    setState(() {
      _latestResult = currentComparingResult;
      _tickets = tickets;
      _isLoading = false;
    });
  }

  List<SavedTicket> get _filteredTickets {
    if (_activeTab == 'all') return _tickets;
    return _tickets.where((t) => t.status == _activeTab).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: StandardAppBar(
        title: "我保存的彩票",
        showBackButton: true,
        onBack: widget.onBack,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              _buildTabs(),
              Expanded(
                child: _tickets.isEmpty 
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _filteredTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = _filteredTickets[index];
                          return _buildTicketCard(ticket);
                        },
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
                    color: isActive ? kPrimaryColor : Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTicketCard(SavedTicket ticket) {
    final isWon = ticket.status == 'won';
    final isLost = ticket.status == 'lost';
    final isPending = ticket.status == 'pending';
    final List<int> winIndices = ticket.winIndices ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isLost ? const Color(0xFFFAFAFA) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isWon ? kRoyalGold.withOpacity(0.4) : Colors.grey.shade100,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isWon ? kRoyalGold.withOpacity(0.08) : Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            if (isWon)
              Positioned(
                right: 20,
                bottom: 20,
                child: Opacity(
                  opacity: 0.1,
                  child: Image.network(
                    "https://cdn-icons-png.flaticon.com/512/1828/1828884.png", // Star icon
                    width: 80,
                    height: 80,
                    color: kRoyalGold,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isPending ? "下期开奖: ${LotteryUtils.getNextDrawDate()}" : "开奖日期: ${ticket.drawDate ?? '等待对比'}",
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      if (isWon)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: kRoyalGold,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.stars, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text("恭喜中奖", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        )
                      else if (isPending)
                        const Icon(Icons.more_horiz, color: Colors.grey, size: 20)
                      else if (isLost)
                        const Icon(Icons.cancel_outlined, color: Colors.grey, size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        isWon ? (ticket.winLabel ?? "已中奖") : (isPending ? "待开奖" : "未中奖"),
                        style: TextStyle(
                          color: isWon ? kRoyalGold : (isPending ? kPrimaryDark : Colors.grey),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (isWon && ticket.winAmount != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          "(${ticket.winAmount})",
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                      if (isPending) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "倒计时 ${LotteryUtils.getCountdownDays()}天",
                            style: const TextStyle(color: kPrimaryColor, fontSize: 10, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      final digit = ticket.number[index];
                      final isHighlighted = winIndices.contains(index);
                      return _buildDigitBox(digit, isHighlighted, isLost);
                    }),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Colors.grey.shade100, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "添加日期: ${ticket.addDate}",
                        style: TextStyle(color: Colors.grey.shade300, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      _buildSourceTag(ticket.type),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceTag(String type) {
    String label = "手动";
    IconData icon = Icons.edit_note;
    Color color = Colors.blue;

    switch (type) {
      case 'scan': label = "扫码"; icon = Icons.qr_code_scanner; color = Colors.orange; break;
      case 'birthday': label = "生日"; icon = Icons.cake; color = Colors.pink; break;
      case 'phone': label = "手机"; icon = Icons.phone_iphone; color = Colors.indigo; break;
      case 'random': label = "随机"; icon = Icons.casino; color = Colors.purple; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildDigitBox(String digit, bool isHighlighted, bool isLost) {
    return Container(
      width: 44,
      height: 54,
      decoration: BoxDecoration(
        color: isHighlighted ? kRoyalGold.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted ? kRoyalGold : Colors.grey.shade100,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: isLost ? Colors.grey.shade200 : (isHighlighted ? kRoyalGold : kPrimaryDark),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.style_outlined, size: 64, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text("暂无保存的彩票", style: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
