import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thai_lottery/widgets/standard_app_bar.dart';
import 'package:thai_lottery/theme.dart';
import 'package:thai_lottery/services/storage_service.dart';
import 'package:thai_lottery/models/saved_ticket.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math';

class GeneratorScreen extends StatefulWidget {
  final VoidCallback? onViewWallet;
  final String? initialMode;

  const GeneratorScreen({
    super.key, 
    this.onViewWallet,
    this.initialMode,
  });

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  late String _mode; // 'birthday' | 'phone' | 'random'
  
  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode ?? 'birthday';
  }
  
  // Birthday state (B.E.)
  int _selectedYearBE = DateTime.now().year + 543;
  int _selectedMonth = DateTime.now().month;
  int _selectedDay = DateTime.now().day;
  
  // Phone state
  final TextEditingController _phoneController = TextEditingController();
  
  // Animation state
  bool _isCalculating = false;
  bool _isSaved = false;
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

    if (_mode == 'phone' && _phoneController.text.replaceAll(RegExp(r'\D'), '').length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("📱 请先输入有效的手机号码"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Generate deterministic final numbers based on input
    _finalNumbers = _mode == 'birthday' 
        ? _generateFromBirthday() 
        : (_mode == 'phone' ? _generateFromPhone() : _generateRandom());

    setState(() {
      _isCalculating = true;
      _isSaved = false;
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

  Future<void> _handleSave() async {
    if (_isSaved || _isCalculating || _displayNumbers.contains("-")) return;

    final ticket = SavedTicket(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      number: _finalNumbers.join(''),
      addDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      type: _mode,
    );

    await StorageService.saveTicket(ticket);
    
    setState(() {
      _isSaved = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("✅ 彩票已保存到您的包中"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: widget.onViewWallet != null 
            ? SnackBarAction(
                label: "去查看", 
                textColor: Colors.white, 
                onPressed: widget.onViewWallet!,
              )
            : null,
        ),
      );
    }
  }

  List<int> _generateFromBirthday() {
    // Seed random with date
    final seed = _selectedYearBE * 10000 + _selectedMonth * 100 + _selectedDay;
    final rand = Random(seed);
    return List.generate(6, (_) => rand.nextInt(10));
  }

  List<int> _generateFromPhone() {
    final phoneStr = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (phoneStr.isEmpty) return List.generate(6, (index) => Random().nextInt(10));
    
    // 算法：将手机号每一位相加作为初始种子，再结合号码本身进行混淆
    int digitSum = 0;
    for (int i = 0; i < phoneStr.length; i++) {
      digitSum += int.parse(phoneStr[i]);
    }
    
    final seed = digitSum * 1234567 + int.parse(phoneStr.substring(max(0, phoneStr.length - 4)));
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
      appBar: const StandardAppBar(
        title: "幸运号码生成器",
        showBackButton: false,
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
          _isSaved = false;
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
          keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
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
    bool isDisabled = _mode == 'phone' && _phoneController.text.trim().isEmpty;
    
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDisabled 
            ? [Colors.grey.shade300, Colors.grey.shade400] 
            : [kPrimaryColor, kPrimaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: isDisabled ? null : [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: (_isCalculating || isDisabled) ? null : _startCalculation,
        icon: Icon(icon, color: kRoyalGold, size: 22),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 1.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: kRoyalGold,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
          const Positioned(top: 12, left: 12, child: Icon(Icons.auto_awesome, size: 12, color: kRoyalGold)),
          const Positioned(top: 12, right: 12, child: Icon(Icons.auto_awesome, size: 12, color: kRoyalGold)),
          const Positioned(bottom: 12, left: 12, child: Icon(Icons.auto_awesome, size: 12, color: kRoyalGold)),
          const Positioned(bottom: 12, right: 12, child: Icon(Icons.auto_awesome, size: 12, color: kRoyalGold)),
          
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _mode == 'birthday' ? "您的生日幸运号" : (_mode == 'phone' ? "您的手机幸运号" : "随机幸运号"),
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
              const SizedBox(height: 38),
              SizedBox(
                height: 32,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(width: 30, height: 1, color: kRoyalGold.withOpacity(0.2)),
                    const SizedBox(width: 12),
                    if (!_displayNumbers.contains("-") && !_isCalculating) 
                      GestureDetector(
                        onTap: _isSaved ? null : _handleSave,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isSaved ? Colors.grey.shade50 : kRoyalGold.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isSaved ? Icons.check_circle : Icons.bookmark_add, 
                                size: 14, 
                                color: _isSaved ? Colors.grey : kRoyalGold
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isSaved ? "已保存记录" : "保存到我的彩票包",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: _isSaved ? Colors.grey : kRoyalGold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const Text(
                        "ROYAL THAI BLESSING",
                        style: TextStyle(
                          fontSize: 10, 
                          color: kRoyalGold, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 2.5
                        ),
                      ),
                    const SizedBox(width: 12),
                    Container(width: 30, height: 1, color: kRoyalGold.withOpacity(0.2)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
