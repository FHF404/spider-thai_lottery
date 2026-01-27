import 'package:flutter/material.dart';
import 'package:thai_lottery/models/lottery_result.dart';
import 'package:thai_lottery/widgets/standard_app_bar.dart';
import 'package:thai_lottery/widgets/result_card.dart';
import 'package:thai_lottery/theme.dart';
import 'package:thai_lottery/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
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
    required this.latestResult,
    required this.historyResults,
    required this.onRefresh,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  void _checkPermission() async {
    final service = NotificationService();
    bool granted = await service.isPermissionGranted();
    if (!granted) {
      // 稍微延迟一下
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _showCustomPermissionDialog();
      });
    }
  }

  void _showCustomPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PermissionDialog(
        onConfirm: () async {
          Navigator.pop(context);
          final service = NotificationService();
          await service.requestPermission();
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _handleNotificationClick() async {
    final service = NotificationService();
    await service.showTestNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: RefreshIndicator(
        onRefresh: widget.onRefresh,
        displacement: 100,
        color: kPrimaryColor,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  if (widget.latestResult != null)
                    ResultCard(
                      result: widget.latestResult!,
                      isHero: true,
                      onCheckTicket: widget.onCheckTicket,
                    )
                  else
                    const Center(child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    )),
                  _buildSectionHeader("最近开奖历史", widget.onViewHistory),
                  const SizedBox(height: 16),
                  if (widget.historyResults.length > 1) ResultCard(result: widget.historyResults[1]),
                  if (widget.historyResults.length > 2) ResultCard(result: widget.historyResults[2]),
                  const SizedBox(height: 100), // Bottom nav padding
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return StandardSliverAppBar(
      title: "泰国彩票开奖",
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Color(0xFFFFD700), size: 24),
              onPressed: _handleNotificationClick,
            ),
            Positioned(
              right: 14,
              top: 14,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: kPrimaryColor, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kPrimaryDark,
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: const Text(
            "查看全部",
            style: TextStyle(
              color: kRoyalGold,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _PermissionDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _PermissionDialog({required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: kPrimaryColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "开启中奖通知",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kPrimaryDark,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "不错过任何一次好运！\n开奖后我们将第一时间为您推送结果。",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "稍后再说",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "立即开启",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
