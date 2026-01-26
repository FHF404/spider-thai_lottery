import '../widgets/result_card.dart';
import '../theme.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  String _mode = 'phone'; // 'phone' | 'birthday' | 'random'
  List<int>? _generatedNumbers;

  void _handleGenerate() {
    setState(() {
      _generatedNumbers = [8, 2, 9, 5, 1, 7];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () {}, // Handled by MainScreen
        ),
        title: const Text(
          "幸运号码生成器",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (_mode == 'phone') _buildPhoneMode(),
                  if (_mode == 'birthday') _buildBirthdayMode(),
                  if (_mode == 'random') _buildRandomMode(),
                  if (_generatedNumbers != null) _buildResultDisplay(),
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
    return Container(
      color: kPrimaryColor.withOpacity(0.05),
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            _buildTabItem("birthday", "生日幸运号"),
            _buildTabItem("phone", "手机号生成"),
            _buildTabItem("random", "随机生成"),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String mode, String label) {
    final isActive = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _mode = mode;
          _generatedNumbers = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? kPrimaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [BoxShadow(color: kPrimaryColor.withOpacity(0.3), blurRadius: 4)]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneMode() {
    return Column(
      children: [
        const Text(
          "输入您的手机号",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimaryDark),
        ),
        const SizedBox(height: 8),
        Text(
          "将您的号码转化为繁荣与好运的象征",
          style: TextStyle(color: kPrimaryDark.withOpacity(0.6), fontSize: 14),
        ),
        const SizedBox(height: 32),
        TextField(
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryDark),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.phone_iphone, color: kPrimaryColor),
            hintText: "请输入11位手机号码",
            hintStyle: const TextStyle(fontWeight: FontWeight.normal, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: kPrimaryColor.withOpacity(0.2), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: kPrimaryColor.withOpacity(0.1), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: kPrimaryColor, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildMagicButton("开始魔法计算", Icons.auto_fix_high),
      ],
    );
  }

  Widget _buildBirthdayMode() {
    return Column(
      children: [
        const Text(
          "选择您的出生日期",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimaryDark),
        ),
        const SizedBox(height: 8),
        Text(
          "基于泰国皇家占星术为您计算幸运数字",
          style: TextStyle(color: kPrimaryDark.withOpacity(0.6), fontSize: 14),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kPrimaryColor.withOpacity(0.1), width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Row(
            children: [
              _buildPickerColumn("年份", "1995", "1996", "1997"),
              Container(width: 1, height: 80, color: Colors.grey.shade100),
              _buildPickerColumn("月份", "05月", "06月", "07月"),
              Container(width: 1, height: 80, color: Colors.grey.shade100),
              _buildPickerColumn("日期", "14", "15", "16"),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildMagicButton("计算幸运号", Icons.stars),
      ],
    );
  }

  Widget _buildPickerColumn(String label, String prev, String current, String next) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(prev, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.symmetric(horizontal: BorderSide(color: kPrimaryColor.withOpacity(0.3), width: 2)),
            ),
            child: Text(current, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),
          ),
          const SizedBox(height: 4),
          Text(next, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRandomMode() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Text(
          "点击生成幸运号码",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimaryDark),
        ),
        const SizedBox(height: 8),
        Text(
          "皇家占星随机算法为您即时演算",
          style: TextStyle(color: kPrimaryDark.withOpacity(0.6), fontSize: 14),
        ),
        const SizedBox(height: 60),
        GestureDetector(
          onTap: _handleGenerate,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kPrimaryColor.withOpacity(0.2), width: 2),
                ),
              ),
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimaryDark,
                  border: Border.all(color: kRoyalGold, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF673AB7).withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.stars, color: kRoyalGold, size: 48),
                    SizedBox(height: 8),
                    Text(
                      "开始生成",
                      style: TextStyle(
                        color: kRoyalGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMagicButton(String label, IconData icon) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _handleGenerate,
        icon: Icon(icon, color: kRoyalGold),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryDark,
          foregroundColor: kRoyalGold,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildResultDisplay() {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: kRoyalGold.withOpacity(0.2), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Stack(
        children: [
          // Corner accents (simplified for flutter)
          const Positioned(top: 0, left: 0, child: Icon(Icons.apps, size: 16, color: kRoyalGold)),
          const Positioned(top: 0, right: 0, child: Icon(Icons.apps, size: 16, color: kRoyalGold)),
          const Positioned(bottom: 0, left: 0, child: Icon(Icons.apps, size: 16, color: kRoyalGold)),
          const Positioned(bottom: 0, right: 0, child: Icon(Icons.apps, size: 16, color: kRoyalGold)),
          
          Column(
            children: [
              const Text(
                "您的手机幸运号",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _generatedNumbers!.map((n) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 40,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    n.toString(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimaryDark),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 32, height: 1, color: kPrimaryColor.withOpacity(0.2)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Royal Thai Blessing",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Container(width: 32, height: 1, color: kPrimaryColor.withOpacity(0.2)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
