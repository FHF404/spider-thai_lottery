import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:thai_lottery/widgets/standard_app_bar.dart';
import 'package:thai_lottery/theme.dart';
import 'package:thai_lottery/services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(String) onChangeView;

  const SettingsScreen({super.key, required this.onBack, required this.onChangeView});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentLang = 'zh'; // 默认北京时间/中文环境

  void _handleOpenNotificationSettings() {
    AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  void _handleClearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("确定要清除缓存吗？"),
        content: const Text("清除缓存后，您保存的所有彩票记录将被永久清空，无法找回。"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await StorageService.clearTickets();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ 缓存已清空"), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text("确定清除", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: StandardAppBar(
        title: "设置",
        showBackButton: true,
        onBack: widget.onBack,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle("通用设置"),
                _buildLanguageSelector(),
                const SizedBox(height: 16),
                _buildSectionTitle("消息通知"),
                _buildSettingTile(
                  icon: Icons.notifications_none_outlined,
                  title: "开奖通知设置",
                  subtitle: "管理系统通知权限及开关",
                  onTap: _handleOpenNotificationSettings,
                ),
                const SizedBox(height: 16),
                _buildSectionTitle("数据管理"),
                _buildSettingTile(
                  icon: Icons.delete_outline,
                  title: "清除缓存",
                  subtitle: "清空所有保存的彩票记录",
                  onTap: _handleClearCache,
                  isDestructive: true,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle("关于与法律"),
                _buildSettingTile(
                  icon: Icons.privacy_tip_outlined,
                  title: "隐私协议",
                  onTap: () => widget.onChangeView('legal_detail:privacy'),
                ),
                _buildSettingTile(
                  icon: Icons.gavel_outlined,
                  title: "非赌博声明",
                  onTap: () => widget.onChangeView('legal_detail:disclaimer'),
                ),
                _buildSettingTile(
                  icon: Icons.info_outline,
                  title: "关于我们",
                  onTap: () => widget.onChangeView('legal_detail:about'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                Text(
                  "泰彩助手",
                  style: TextStyle(color: kPrimaryDark.withOpacity(0.5), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Version 1.0.0",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: const Icon(Icons.language, color: kPrimaryColor),
        title: const Text("切换语言", style: TextStyle(fontWeight: FontWeight.w600)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFlagButton("🇹🇭", "th"),
            const SizedBox(width: 8),
            _buildFlagButton("🇬🇧", "en"),
            const SizedBox(width: 8),
            _buildFlagButton("🇨🇳", "zh"),
          ],
        ),
      ),
    );
  }

  Widget _buildFlagButton(String emoji, String code) {
    final bool isSelected = _currentLang == code;
    return GestureDetector(
      onTap: () => setState(() => _currentLang = code),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? kPrimaryColor : Colors.transparent),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
        leading: Icon(icon, color: isDestructive ? Colors.redAccent : kPrimaryColor),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.redAccent : kPrimaryDark,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
