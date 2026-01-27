import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thai_lottery/widgets/standard_app_bar.dart';
import 'package:thai_lottery/theme.dart';
import 'package:thai_lottery/services/storage_service.dart';
import 'package:thai_lottery/models/saved_ticket.dart';
import 'package:thai_lottery/models/lottery_result.dart';
import 'package:thai_lottery/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:thai_lottery/utils/lottery_utils.dart';
import 'dart:math';

class ProfileScreen extends StatefulWidget {
  final Function(String) onChangeView;
  final LotteryResult? initialLatestResult;

  const ProfileScreen({
    super.key, 
    required this.onChangeView,
    this.initialLatestResult,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _numberController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<SavedTicket> _tickets = [];
  LotteryResult? _latestResult;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _latestResult = widget.initialLatestResult;
    // 如果已经有数据，初始状态就不显示全屏 Loading
    _isLoading = _latestResult == null;
    _loadData();
  }

  @override
  void dispose() {
    _numberController.dispose();
    _focusNode.dispose();
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
      type: 'manual',
    );

    await StorageService.saveTicket(ticket);
    _numberController.clear();
    setState(() => _manualInput = "");
    FocusScope.of(context).unfocus();
    
    // 重新加载数据
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("✅ 已成功添加到我的彩票包"), 
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: "查看", 
            textColor: Colors.white, 
            onPressed: () => widget.onChangeView('saved_tickets'),
          ),
        ),
      );
    }
  }

  // 数据加载已完成结算
  Future<void> _handleScan() async {
    // 模拟扫码过程
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    
    // 模拟从码里读出的数字
    final fakeScannedNumber = (100000 + (Random().nextInt(899999))).toString().substring(0, 6);
    
    final ticket = SavedTicket(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      number: fakeScannedNumber,
      addDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      type: 'scan',
    );

    await StorageService.saveTicket(ticket);
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("📸 扫码录入成功: $fakeScannedNumber"), 
          backgroundColor: kPrimaryColor,
          action: SnackBarAction(label: "查看", textColor: Colors.white, onPressed: () => widget.onChangeView('saved_tickets')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: StandardAppBar(
        title: "个人中心",
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: () => widget.onChangeView('settings'),
          ),
        ],
      ),
      body: (_isLoading && _tickets.isEmpty)
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
    final pendingCount = _tickets.where((t) => t.isPending).length;

    return Container(
      width: double.infinity,
      height: 135,
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
            right: -10,
            top: -30,
            child: Icon(Icons.confirmation_number, size: 150, color: Colors.white12),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "我的彩票包",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  "$pendingCount 张待开奖",
                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => widget.onChangeView('saved_tickets'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kRoyalGold,
                        foregroundColor: kPrimaryDark,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        minimumSize: const Size(0, 36),
                      ),
                      child: const Text("查看全部", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
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

  String _manualInput = "";

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  const Text(
                    "手动输入 6 位数字",
                    style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: _handleScan,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Icon(Icons.qr_code_scanner_rounded, color: Colors.grey.shade600, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 为实现 3D 立体感，使用 Row 手动布局
              GestureDetector(
                onTap: () => _focusNode.requestFocus(),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    final hasDigit = index < _manualInput.length;
                    final digit = hasDigit ? _manualInput[index] : "-";
                    return Container(
                      width: 44,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: hasDigit ? kPrimaryColor : Colors.grey.shade100, 
                          width: hasDigit ? 2 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        digit,
                        style: TextStyle(
                          fontSize: 26, 
                          fontWeight: FontWeight.w900, 
                          color: hasDigit ? kPrimaryColor : Colors.grey.shade400,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // 隐藏的 TextField 用于接收输入
              SizedBox(
                height: 0,
                width: 0,
                child: TextField(
                  controller: _numberController,
                  focusNode: _focusNode,
                  readOnly: false,
                  autofocus: false,
                  keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  onChanged: (val) => setState(() => _manualInput = val),
                  decoration: const InputDecoration(border: InputBorder.none, counterText: ""),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _handleManualAdd,
                  icon: const Icon(Icons.add_task_rounded, size: 22),
                  label: const Text("添加到我的彩票包", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    elevation: 12,
                    shadowColor: kPrimaryColor.withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
      {'id': 'birthday', 'icon': Icons.cake, 'label': '生日幸运号', 'colors': [Colors.pink, Colors.pinkAccent]},
      {'id': 'phone', 'icon': Icons.auto_fix_high, 'label': '手机号魔法', 'colors': [Colors.amber, Colors.orange]},
      {'id': 'random', 'icon': Icons.casino, 'label': '随机生成', 'colors': [Colors.purple, Colors.indigo]},
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: GestureDetector(
            onTap: () => widget.onChangeView('generator:${item['id']}'),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ticket.number,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isWin ? kPrimaryColor : kPrimaryDark,
                  letterSpacing: 2,
                ),
              ),
              _buildStatusTag(isWin, isPending),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade50, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("添加日期: ${ticket.addDate}", style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              _buildSourceTag(ticket.type),
            ],
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
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
