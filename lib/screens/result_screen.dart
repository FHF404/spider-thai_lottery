import '../widgets/result_card.dart';
import '../theme.dart';

class ResultScreen extends StatelessWidget {
  final String status; // 'win' | 'loss'
  final VoidCallback onBack;
  final String ticketNumber;

  const ResultScreen({
    super.key,
    required this.status,
    required this.onBack,
    required this.ticketNumber,
  });

  @override
  Widget build(BuildContext context) {
    bool isWin = status == 'win';

    return Scaffold(
      backgroundColor: isWin ? const Color(0xFFF6F6F8) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kPrimaryColor),
          onPressed: onBack,
        ),
        title: Text(
          isWin ? "中奖结果查询" : "查询结果",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: isWin
            ? [
                IconButton(
                  icon: const Icon(Icons.share, color: kPrimaryColor),
                  onPressed: () {},
                )
              ]
            : null,
      ),
      body: isWin ? _buildWinView(context) : _buildLossView(context),
    );
  }

  Widget _buildWinView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          _buildWinHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                _buildWinningTicket(),
                const SizedBox(height: 24),
                _buildPrizeInfo(),
                const SizedBox(height: 32),
                _buildWinActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kRoyalGold.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stars, color: kRoyalGold, size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            "恭喜您中奖了！",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF212121)),
          ),
          const SizedBox(height: 8),
          const Text(
            "✨ 皇家泰国抽奖 - 10月16日 ✨",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildWinningTicket() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kPrimaryDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF211C27), kPrimaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Pattern overlay (simplified)
          Opacity(
            opacity: 0.1,
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: 40,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10),
              itemBuilder: (_, __) => const Icon(Icons.circle, size: 2, color: kRoyalGold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "OFFICIAL WINNER",
                        style: TextStyle(color: Colors.white54, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                    ),
                    const Icon(Icons.verified, color: kRoyalGold, size: 24),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.symmetric(horizontal: BorderSide(color: Colors.white.withOpacity(0.1))),
                  ),
                  child: Column(
                    children: [
                      const Text("官方中奖票据", style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 2)),
                      const SizedBox(height: 8),
                      Text(
                        ticketNumber,
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("您的中奖号码已验证", style: TextStyle(color: Colors.white60, fontSize: 10)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: const Text("查看详情", style: TextStyle(color: kPrimaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
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

  Widget _buildPrizeInfo() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: const Border(left: BorderSide(color: kRoyalGold, width: 4)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("一等奖奖金 (First Prize)", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              ShaderMask(
                shaderCallback: (Rect bounds) => const LinearGradient(
                  colors: [kRoyalGold, Color(0xFFE6AF2E)],
                ).createShader(bounds),
                child: const Text(
                  "฿6,000,000",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildSmallInfoCard("扣税 (Tax 1%)", "-฿60,000", Colors.redAccent),
            const SizedBox(width: 16),
            _buildSmallInfoCard("实到奖金 (Net)", "฿5,940,000", kPrimaryColor),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallInfoCard(String label, String val, Color valColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildWinActions() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [kRoyalGold, Color(0xFFFFD700), kRoyalGold]),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: kRoyalGold.withOpacity(0.4), blurRadius: 15, spreadRadius: 2)],
          ),
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share, color: Colors.black),
            label: const Text("立即分享喜悦", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kPrimaryColor, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("返回主页", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
      ],
    );
  }

  Widget _buildLossView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              children: [
                _buildLossHeader(),
                const SizedBox(height: 40),
                _buildLossComparison(),
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 24),
                const Text(
                  "“每一次机会都是通往幸运的阶梯”",
                  style: TextStyle(color: kPrimaryColor, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        _buildLossActions(),
      ],
    );
  }

  Widget _buildLossHeader() {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(color: kPrimaryColor.withOpacity(0.1), width: 2),
          ),
          child: const Icon(Icons.search_off, size: 56, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        const Text("很抱歉，未中奖", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
        const SizedBox(height: 8),
        const Text("别气馁，好运在后面！", style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildLossComparison() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kRoyalGold.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.confirmation_number, color: kRoyalGold, size: 20),
                  SizedBox(width: 8),
                  Text("第 20240512 期", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                child: const Text("CLOSED", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildComparisonCol("您的号码", ticketNumber, kPrimaryColor),
              Container(width: 1, height: 40, color: Colors.grey.shade100),
              _buildComparisonCol("中奖号码", "987654", kRoyalGold),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.info_outline, color: kPrimaryColor, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "中奖结果依据泰国政府彩票办公室官方数据。祝您下次好运。",
                    style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCol(String label, String number, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            number,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildLossActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade50)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("再试一次", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("返回主页", style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
