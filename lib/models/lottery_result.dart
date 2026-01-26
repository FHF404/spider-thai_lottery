import 'package:intl/intl.dart';

class LotteryResult {
  final String id;
  final String date;
  final String drawDateFull;
  final String number;
  final String top3;
  final String bottom3;
  final String bottom2;

  LotteryResult({
    required this.id,
    required this.date,
    required this.drawDateFull,
    required this.number,
    required this.top3,
    required this.bottom3,
    required this.bottom2,
  });

  factory LotteryResult.fromJson(Map<String, dynamic> json) {
    return LotteryResult(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: json['date'] ?? '',
      drawDateFull: json['drawDateFull'] ?? (json['date'] ?? ''),
      number: json['number'] ?? '',
      top3: json['top3'] ?? '',
      bottom3: json['bottom3'] ?? '',
      bottom2: json['bottom2'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'drawDateFull': drawDateFull,
      'number': number,
      'top3': top3,
      'bottom3': bottom3,
      'bottom2': bottom2,
    };
  }
}

class MockData {
  static List<LotteryResult> get history => [
        LotteryResult(
          id: '1',
          date: '10月16日',
          drawDateFull: '2023年10月16日',
          number: '123456',
          top3: '789, 456',
          bottom3: '123, 789',
          bottom2: '45',
        ),
        LotteryResult(
          id: '2',
          date: '10月01日',
          drawDateFull: '2023年10月01日',
          number: '987654',
          top3: '355, 955',
          bottom3: '815, 542',
          bottom2: '12',
        ),
        LotteryResult(
          id: '3',
          date: '09月16日',
          drawDateFull: '2023年09月16日',
          number: '741085',
          top3: '125, 458',
          bottom3: '624, 731',
          bottom2: '91',
        ),
        LotteryResult(
          id: '4',
          date: '09月01日',
          drawDateFull: '2023年09月01日',
          number: '523994',
          top3: '943, 110',
          bottom3: '259, 887',
          bottom2: '84',
        ),
      ];

  static LotteryResult get latest => history.first;
}
