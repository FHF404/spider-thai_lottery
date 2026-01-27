import 'package:flutter/material.dart';
import 'package:thai_lottery/widgets/standard_app_bar.dart';
import 'package:thai_lottery/widgets/result_card.dart';
import 'package:thai_lottery/theme.dart';

class CheckTicketScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(String) onCheck;

  const CheckTicketScreen({super.key, required this.onBack, required this.onCheck});

  @override
  State<CheckTicketScreen> createState() => _CheckTicketScreenState();
}

class _CheckTicketScreenState extends State<CheckTicketScreen> {
  String _input = "";

  void _handleNumber(String n) {
    if (_input.length < 6) {
      setState(() {
        _input += n;
      });
    }
  }

  void _handleDelete() {
    if (_input.isNotEmpty) {
      setState(() {
        _input = _input.substring(0, _input.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StandardAppBar(
        title: "核对我的彩票",
        showBackButton: true,
        onBack: widget.onBack,
      ),
      body: Column(
        children: [
          _buildDisplayArea(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildKeypad(),
                    const SizedBox(height: 24),
                    _buildScanButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: kRoyalGold.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.stars, color: kRoyalGold, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                "ROYAL THAI LOTTERY",
                style: TextStyle(
                  color: kRoyalGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              final active = index < _input.length;
              final val = active ? _input[index] : "";
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 46,
                height: 60,
                decoration: BoxDecoration(
                  color: active ? Colors.white : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active ? kPrimaryColor : Colors.grey.shade100,
                    width: active ? 2 : 1.5,
                  ),
                  boxShadow: active
                      ? [BoxShadow(color: kPrimaryColor.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4))]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  val,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: kPrimaryColor,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),
          Text(
            _input.length == 6 ? "号码录入完成，点击查询按钮" : "请输入您的 6 位彩票号码",
            style: TextStyle(
              color: _input.length == 6 ? kPrimaryColor : Colors.grey.shade400,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ...List.generate(9, (i) => _buildKeyItem((i + 1).toString())),
        _buildSpecialKey(Icons.backspace_outlined, _handleDelete),
        _buildKeyItem("0"),
        _buildSubmitKey(),
      ],
    );
  }

  Widget _buildKeyItem(String val) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _handleNumber(val),
        child: Center(
          child: Text(
            val,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kPrimaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Icon(icon, color: Colors.grey, size: 24),
        ),
      ),
    );
  }

  Widget _buildSubmitKey() {
    final active = _input.length == 6;
    return Material(
      color: active ? kRoyalGold : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(20),
      elevation: active ? 4 : 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: active ? () => widget.onCheck(_input) : null,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 24),
              SizedBox(height: 4),
              Text(
                "查询",
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kPrimaryColor, kPrimaryDark]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
          label: const Text(
            "扫描彩票二维码",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
