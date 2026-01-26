import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lottery_result.dart';

class ApiService {
  // 注意：用户需要将此 URL 替换为其实际的 GitHub 仓库 Raw URL
  static const String dataUrl = "https://raw.githubusercontent.com/FHF404/spider-thai_lottery/main/lotto_results.json";
  static const String cacheKey = "cached_lotto_data";

  static Future<Map<String, dynamic>> fetchLotteryData() async {
    try {
      final response = await http.get(Uri.parse(dataUrl)).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        
        // 保存到缓存
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, response.body);
        
        return _processData(data);
      } else {
        return await _loadFromCache();
      }
    } catch (e) {
      print("Fetch error: $e");
      return await _loadFromCache();
    }
  }

  static Future<Map<String, dynamic>> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(cacheKey);
    
    if (cachedString != null) {
      final data = json.decode(cachedString);
      return _processData(data);
    }
    
    // 如果没有缓存，返回 Mock 数据作为兜底
    return {
      'latest': MockData.latest,
      'history': MockData.history,
    };
  }

  static Map<String, dynamic> _processData(Map<String, dynamic> json) {
    final historyRaw = json['history'] as List;
    final history = historyRaw.map((item) => LotteryResult.fromJson(item)).toList();
    
    // 1. 过滤掉包含 "X" 或 "x" 的数据（尚未开奖的占位数据）
    final filteredHistory = history.where((item) {
      final numbers = "${item.number}${item.bottom2}${item.top3}${item.bottom3}".toLowerCase();
      return !numbers.contains('x');
    }).toList();

    // 2. 去重（基于日期），防止抓取过程中的重复录入
    final Map<String, LotteryResult> uniqueHistoryMap = {};
    for (var item in filteredHistory) {
      if (!uniqueHistoryMap.containsKey(item.date)) {
        uniqueHistoryMap[item.date] = item;
      }
    }
    final validHistory = uniqueHistoryMap.values.toList();
    
    return {
      'latest': validHistory.isNotEmpty ? validHistory.first : (history.isNotEmpty ? history.first : null),
      'history': validHistory,
      'last_updated': json['last_updated'] ?? '未知',
    };
  }
}
