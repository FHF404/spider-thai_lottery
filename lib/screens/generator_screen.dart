import 'package:flutter/material.dart';
import 'package:thai_lottery/theme.dart';
import 'dart:async';
import 'dart:math';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  String _mode = 'birthday'; // 'phone' | 'birthday' | 'random'
  
  // Birthday state (B.E.)
  int _selectedYearBE = DateTime.now().year + 543;
  int _selectedMonth = DateTime.now().month;
  int _selectedDay = DateTime.now().day;
  
  // Phone state
  final TextEditingController _phoneController = TextEditingController();
  
  // Animation state
  bool _isCalculating = false;
  List<String> _displayNumbers = List.filled(6, "-");
  List<int> _finalNumbers = [];
  Timer? _animTimer;
  final List<bool> _lockedStates = List.filled(6, true);

  @override
  void dispose() {
    _animTimer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  void _startCalculation() {
    if (_isCalculating) return;

    // Generate deterministic final numbers based on input
    _finalNumbers = _mode == 'birthday' 
        ? _generateFromBirthday() 
        : (_mode == 'phone' ? _generateFromPhone() : _generateRandom());

    setState(() {
      _isCalculating = true;
      _displayNumbers = List.filled(6, "0");
      for (int i = 0; i < 6; i++) _lockedStates[i] = false;
    });

    int frameCount = 0;
    _animTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      frameCount++;
      
      setState(() {
        for (int i = 0; i < 6; i++) {
          if (!_lockedStates[i]) {
            _displayNumbers[i] = Random().nextInt(10).toString();
          }
        }
      });

      // Gradually lock numbers
      if (frameCount == 20) _lockedStates[0] = true;
      if (frameCount == 30) _lockedStates[1] = true;
      if (frameCount == 40) _lockedStates[2] = true;
      if (frameCount == 50) _lockedStates[3] = true;
      if (frameCount == 60) _lockedStates[4] = true;
      if (frameCount == 70) {
        _lockedStates[5] = true;
        timer.cancel();
        setState(() {
          for (int i = 0; i < 6; i++) {
            _displayNumbers[i] = _finalNumbers[i].toString();
          }
          _isCalculating = false;
        });
      }
      
      // Update those that are locked to their final value
      for(int i=0; i<6; i++) {
        if (_lockedStates[i]) {
          _displayNumbers[i] = _finalNumbers[i].toString();
        }
      }
    });
  }

  List<int> _generateFromBirthday() {
    // Seed random with date
    final seed = _selectedYearBE * 10000 + _selectedMonth * 100 + _selectedDay;
    final rand = Random(seed);
    return List.generate(6, (_) => rand.nextInt(10));
  }

  List<int> _generateFromPhone() {
    final phoneStr = _phoneController.text;
    final seed = int.tryParse(phoneStr.replaceAll(RegExp(r'\D'), '')) ?? 0;
    final rand = Random(seed);
    return List.generate(6, (_) => rand.nextInt(10));
  }

  List<int> _generateRandom() {
    final rand = Random();
    return List.generate(6, (_) => rand.nextInt(10));
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
          onPressed: () {
            // Navigator is handled in parent switch usually, 
            // but for safety in standalone test:
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          "幸运号码生成器",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildResultDisplay(),
                  const SizedBox(height: 32),
                  if (_mode == 'birthday') _buildBirthdayMode(),
                  if (_mode == 'phone') _buildPhoneMode(),
                  if (_mode == 'random') _buildRandomMode(),
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
          _displayNumbers = List.filled(6, "-");
          _isCalculating = false;
          _animTimer?.cancel();
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
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kPrimaryColor.withOpacity(0.1), width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Row(
            children: [
              _buildWheelPicker(
                label: "年份 (佛曆)", 
                items: List.generate(101, (i) => (DateTime.now().year + 543 - i)),
                selectedVal: _selectedYearBE,
                onChanged: (val) => setState(() => _selectedYearBE = val),
              ),
              _buildWheelPicker(
                label: "月份", 
                items: List.generate(12, (i) => i + 1),
                format: (v) => v.toString().padLeft(2, '0') + "月",
                selectedVal: _selectedMonth,
                onChanged: (val) => setState(() => _selectedMonth = val),
              ),
              _buildWheelPicker(
                label: "日期", 
                items: List.generate(31, (i) => i + 1),
                selectedVal: _selectedDay,
                onChanged: (val) => setState(() => _selectedDay = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildMagicButton("计算幸运号", Icons.stars),
      ],
    );
  }

  Widget _buildWheelPicker({
    required String label, 
    required List<int> items, 
    required int selectedVal,
    required ValueChanged<int> onChanged,
    String Function(int)? format,
  }) {
    final int initialIndex = items.indexOf(selectedVal);
    return Expanded(
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          Expanded(
            child: ListWheelScrollView.useDelegate(
              itemExtent: 40,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) => onChanged(items[index]),
              controller: FixedExtentScrollController(initialItem: initialIndex > -1 ? initialIndex : 0),
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: items.length,
                builder: (context, index) {
                  final val = items[index];
                  final isSelected = val == selectedVal;
                  return Center(
                    child: Text(
                      format != null ? format(val) : val.toString(),
                      style: TextStyle(
                        fontSize: isSelected ? 20 : 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? kPrimaryColor : Colors.grey.shade400,
                      ),
                    ),
                  );
                }
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
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
        const SizedBox(height: 32),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          onChanged: (_) => setState(() => _displayNumbers = List.filled(6, "-")),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryDark),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.phone_iphone, color: kPrimaryColor),
            hintText: "请输入手机号码",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: kPrimaryColor.withOpacity(0.1))),
          ),
        ),
        const SizedBox(height: 24),
        _buildMagicButton("开始魔法计算", Icons.auto_fix_high),
      ],
    );
  }

  Widget _buildRandomMode() {
    return Column(
      children: [
        const SizedBox(height: 24),
        _buildMagicButton("随机抽取幸运号", Icons.shuffle),
      ],
    );
  }

  Widget _buildMagicButton(String label, IconData icon) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isCalculating ? null : _startCalculation,
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: kRoyalGold.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          const Positioned(top: 0, left: 0, child: Icon(Icons.auto_awesome, size: 14, color: kRoyalGold)),
          const Positioned(top: 0, right: 0, child: Icon(Icons.auto_awesome, size: 14, color: kRoyalGold)),
          const Positioned(bottom: 0, left: 0, child: Icon(Icons.auto_awesome, size: 14, color: kRoyalGold)),
          const Positioned(bottom: 0, right: 0, child: Icon(Icons.auto_awesome, size: 14, color: kRoyalGold)),
          
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _mode == 'birthday' ? "✨ 您的生日幸运号 ✨" : (_mode == 'phone' ? "📱 您的手机幸运号 📱" : "🎲 随机幸运号 🎲"),
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _displayNumbers.map((n) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 44,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                      if (n != "-" && _isCalculating)
                        BoxShadow(
                          color: kPrimaryColor.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    n,
                    style: TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.w900, 
                      color: n == "-" ? Colors.grey.shade200 : kPrimaryColor,
                      fontFamily: 'monospace'
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 40, height: 1, color: kRoyalGold.withOpacity(0.2)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "ROYAL THAI BLESSING",
                      style: TextStyle(
                        fontSize: 9, 
                        color: kRoyalGold, 
                        fontWeight: FontWeight.w900, 
                        letterSpacing: 2.5
                      ),
                    ),
                  ),
                  Container(width: 40, height: 1, color: kRoyalGold.withOpacity(0.2)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
