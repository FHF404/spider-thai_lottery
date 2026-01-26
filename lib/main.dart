import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/generator_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/check_ticket_screen.dart';
import 'screens/result_screen.dart';
import 'screens/saved_tickets_screen.dart';
import 'widgets/result_card.dart';
import 'models/lottery_result.dart';
import 'services/api_service.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('th', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Royal Thai Lottery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          primary: kPrimaryColor,
          secondary: kRoyalGold,
          surface: const Color(0xFFF6F6F8),
        ),
        textTheme: GoogleFonts.publicSansTextTheme(),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _currentView = 'home'; // home, history, profile, generator, check, result
  String _resultStatus = 'loss';
  String _checkedTicket = "";
  
  // 数据状态
  LotteryResult? _latestResult;
  List<LotteryResult> _historyResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await ApiService.fetchLotteryData();
    setState(() {
      _latestResult = data['latest'];
      _historyResults = data['history'];
      _isLoading = false;
    });
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  void _changeView(String view) {
    setState(() {
      _currentView = view;
    });
  }

  void _handleCheckTicket(String number) {
    setState(() {
      _checkedTicket = number;
      // Simple logic: if ends in 6, win. Else loss.
      if (_latestResult != null && number == _latestResult!.number) {
        _resultStatus = 'win';
      } else if (number.endsWith('6')) {
         _resultStatus = 'win';
      } else {
        _resultStatus = 'loss';
      }
      _currentView = 'result';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildContent(),
          if (['home', 'history', 'generator', 'profile'].contains(_currentView))
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNav(),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
    }

    switch (_currentView) {
      case 'home':
        return HomeScreen(
          onCheckTicket: () => _changeView('check'),
          onViewHistory: () => _changeView('history'),
          onOpenGenerator: () => _changeView('generator'),
          latestResult: _latestResult,
          historyResults: _historyResults,
          onRefresh: _handleRefresh,
        );
      case 'history':
        return HistoryScreen(
          onBack: () => _changeView('home'),
          historyResults: _historyResults,
          onRefresh: _handleRefresh,
        );
      case 'generator':
        return const GeneratorScreen();
      case 'profile':
        return ProfileScreen(onChangeView: _changeView);
      case 'check':
        return CheckTicketScreen(
          onBack: () => _changeView('home'),
          onCheck: _handleCheckTicket,
        );
      case 'result':
        return ResultScreen(
          status: _resultStatus,
          ticketNumber: _checkedTicket,
          onBack: () => _changeView('check'),
        );
      case 'saved_tickets':
        return SavedTicketsScreen(onBack: () => _changeView('profile'));
      default:
        return HomeScreen(
          onCheckTicket: () => _changeView('check'),
          onViewHistory: () => _changeView('history'),
          onOpenGenerator: () => _changeView('generator'),
          latestResult: _latestResult,
          historyResults: _historyResults,
          onRefresh: _handleRefresh,
        );
    }
  }

  Widget _buildBottomNav() {
    // Determine active tab
    String activeTab = 'home';
    if (_currentView == 'profile' || _currentView == 'saved_tickets') activeTab = 'profile';
    if (_currentView == 'history') activeTab = 'history';
    if (_currentView == 'generator') activeTab = 'generator';

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 8, top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavButton(activeTab == 'home', Icons.home, "主页", () => _changeView('home')),
          _buildNavButton(activeTab == 'history', Icons.history, "历史", () => _changeView('history')),
          _buildNavButton(activeTab == 'generator', Icons.casino, "选号", () => _changeView('generator')),
          _buildNavButton(activeTab == 'profile', Icons.person, "我的", () => _changeView('profile')),
        ],
      ),
    );
  }

  Widget _buildNavButton(bool isActive, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: kRoyalGold,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: kRoyalGold.withOpacity(0.6), blurRadius: 8)],
                ),
              )
            else
              const SizedBox(height: 14),
            Icon(
              icon,
              size: 28,
              color: isActive ? kPrimaryColor : Colors.grey.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive ? kPrimaryColor : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
