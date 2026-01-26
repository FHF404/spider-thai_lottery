import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thai_lottery/models/saved_ticket.dart';

class StorageService {
  static const String _key = 'user_saved_tickets';

  static Future<void> saveTicket(SavedTicket ticket) async {
    final tickets = await getTickets();
    tickets.insert(0, ticket);
    await saveAllTickets(tickets);
  }

  static Future<void> saveAllTickets(List<SavedTicket> tickets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(tickets.map((t) => t.toJson()).toList()));
  }

  static Future<List<SavedTicket>> getTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    
    try {
      final List<dynamic> list = json.decode(jsonStr);
      return list.map((item) => SavedTicket.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> clearTickets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
