import 'package:flutter/material.dart';
import 'package:thai_lottery/widgets/standard_app_bar.dart';
import 'package:thai_lottery/theme.dart';

class LegalDetailScreen extends StatelessWidget {
  final String type; // 'privacy', 'disclaimer', 'about'
  final VoidCallback onBack;

  const LegalDetailScreen({super.key, required this.type, required this.onBack});

  @override
  Widget build(BuildContext context) {
    String title = "";
    List<Widget> content = [];

    switch (type) {
      case 'privacy':
        title = "隐私协议";
        content = _buildPrivacyContent();
        break;
      case 'disclaimer':
        title = "非赌博声明";
        content = _buildDisclaimerContent();
        break;
      case 'about':
        title = "关于我们";
        content = _buildAboutContent();
        break;
    }

    return Scaffold(
      backgroundColor: kBackground,
      appBar: StandardAppBar(
        title: title,
        showBackButton: true,
        onBack: onBack,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: content,
        ),
      ),
    );
  }

  List<Widget> _buildPrivacyContent() {
    return [
      _buildSectionTitle("数据存储与安全"),
      _buildParagraph("本应用（泰彩助手）高度重视您的隐私。我们在此郑重承诺：所有由您手动录入或通过扫码保存的彩票数据，**均仅存储在您本地设备的持久化数据库中**。"),
      _buildParagraph("我们**不会**将您的任何彩票号码、开奖记录、中奖信息或个人偏好上传至任何远程服务器、云端或第三方平台。"),
      const SizedBox(height: 20),
      _buildSectionTitle("相机与扫码权限"),
      _buildParagraph("当您使用“扫码录入”功能时，应用将请求访问您的相机权限。"),
      _buildParagraph("相机采集的原始图像数据**仅用于本地 OCR（光学字符识别）识别彩票号码**。识别完成后，图像数据会被立即从缓存中丢弃，不会被保存为图片文件，更不会向外传输。"),
      const SizedBox(height: 20),
      _buildSectionTitle("第三方服务"),
      _buildParagraph("本应用仅在获取开奖结果时请求公共的开奖数据接口。该请求不包含任何您的个人身份信息。"),
    ];
  }

  List<Widget> _buildDisclaimerContent() {
    return [
      _buildSectionTitle("非赌博性质声明"),
      _buildParagraph("本应用（泰彩助手）仅作为泰国官方彩票（Thai Government Lottery）的查询、管理与模拟分析工具。"),
      _buildParagraph("1. **无交易功能**：应用内不提供任何彩票购买、投注、资金充值或提现等金融交易服务。"),
      _buildParagraph("2. **无关联关系**：本应用不是泰国彩票官方机构的正式合作伙伴，所有数据均采集自公开合法渠道，仅供参考，不具有法律效力。"),
      _buildParagraph("3. **理性分析**：应用内提供的“幸运生成器”功能均基于伪随机算法，结果仅供娱乐。彩票开奖具有高度偶然性，请勿过度投注，远离赌博，享受理性生活。"),
    ];
  }

  List<Widget> _buildAboutContent() {
    return [
       Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.confirmation_number, size: 60, color: kPrimaryColor),
            ),
            const SizedBox(height: 16),
            const Text(
              "泰彩助手",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimaryDark),
            ),
            const Text("Version 1.0.0", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
          ],
        ),
      ),
      _buildParagraph("泰彩助手是一款专为泰国彩票爱好者打造的本地管理工具。"),
      _buildParagraph("我们通过极简的设计与流畅的交互，为您提供开奖查询、手机/生日选号、以及便捷的本地号码记账功能。"),
      _buildParagraph("我们的宗旨是：让查号更简单，让公益彩票回归娱乐本质。"),
    ];
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryDark),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey.shade800),
      ),
    );
  }
}
