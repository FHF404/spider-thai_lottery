import 'package:flutter/material.dart';
import 'package:thai_lottery/models/lottery_result.dart';
import 'package:thai_lottery/models/saved_ticket.dart';
import 'package:thai_lottery/services/storage_service.dart';
import 'package:thai_lottery/services/api_service.dart';
import 'package:thai_lottery/theme.dart';

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
    
    setState(() {
      final history = results['history'] as List<LotteryResult>;
      // 使用历史第2条进行 UI 测试对比，如果需要真实数据改为 latest
      _latestResult = history.length > 1 ? history[1] : results['latest'];
      _tickets = tickets;
      _isLoading = false;
    });
  }

  Map<String, dynamic> _checkWinStatus(SavedTicket ticket) {
    if (_latestResult == null) return {'status': 'pending', 'label': '待开奖'};
    
    final number = ticket.number;
    final winNum = _latestResult!.number;
    final b2 = _latestResult!.bottom2;
    final t3 = _latestResult!.top3.split(', ').map((e) => e.replaceAll(' ', '')).toList();
    final b3 = _latestResult!.bottom3.split(', ').map((e) => e.replaceAll(' ', '')).toList();

    // 1st Prize
    if (number == winNum) {
      return {'status': 'won', 'label': '一等奖', 'prize': '1级', 'indices': [0, 1, 2, 3, 4, 5], 'amount': '6,000,000 泰铢'};
    }
    
    // Last 2
    if (number.endsWith(b2)) {
      return {'status': 'won', 'label': '后2位', 'prize': '末2', 'indices': [4, 5], 'amount': '2,000 泰铢'};
    }

    // Front 3
    final front3 = number.substring(0, 3);
    if (t3.contains(front3)) {
      return {'status': 'won', 'label': '前3位', 'prize': '前3', 'indices': [0, 1, 2], 'amount': '4,000 泰铢'};
    }

    // Back 3
    final back3 = number.substring(3);
    if (b3.contains(back3)) {
      return {'status': 'won', 'label': '后3位', 'prize': '后3', 'indices': [3, 4, 5], 'amount': '4,000 泰铢'};
    }

    return {'status': 'lost', 'label': '未中奖'};
  }

  List<SavedTicket> get _filteredTickets {
    if (_activeTab == 'all') return _tickets;
    return _tickets.where((t) {
      final winInfo = _checkWinStatus(t);
      return winInfo['status'] == _activeTab;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kPrimaryColor),
          onPressed: widget.onBack,
        ),
        title: const Text(
          "我保存的彩票",
          style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
                          final winInfo = _checkWinStatus(ticket);
                          return _buildTicketCard(ticket, winInfo);
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

  Widget _buildTicketCard(SavedTicket ticket, Map<String, dynamic> winInfo) {
    final isWon = winInfo['status'] == 'won';
    final isLost = winInfo['status'] == 'lost';
    final isPending = winInfo['status'] == 'pending';
    final List<int> winIndices = winInfo['indices'] ?? [];

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
                        isPending ? "下期开奖: 2023-11-01" : "开奖日期: ${_latestResult?.date ?? ticket.addDate}",
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
                        isWon ? winInfo['label'] : (isPending ? "待开奖" : "未中奖"),
                        style: TextStyle(
                          color: isWon ? kRoyalGold : (isPending ? kPrimaryDark : Colors.grey),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (isWon) ...[
                        const SizedBox(width: 8),
                        Text(
                          "(${winInfo['amount']})",
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ] else if (isPending) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "倒计时 2天",
                            style: TextStyle(color: kPrimaryColor, fontSize: 10, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ]
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
                  Text(
                    "添加日期: ${ticket.addDate}",
                    style: TextStyle(color: Colors.grey.shade300, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
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
