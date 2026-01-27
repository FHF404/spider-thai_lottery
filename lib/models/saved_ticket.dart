class SavedTicket {
  final String id;
  final String number;
  final String addDate;
  final String type; // 'manual', 'scan', 'birthday', 'random', 'phone'
  String? drawDate; // The date of the draw it was compared against
  String status; // 'pending', 'won', 'lost'
  String? winLabel; // e.g. "一等奖、后2位"
  String? winAmount; // e.g. "6,002,000 泰铢"
  List<int>? winIndices; // e.g. [0, 1, 2, 3, 4, 5]

  bool get isPending => status == 'pending';
  bool get isWon => status == 'won';
  bool get isLost => status == 'lost';

  SavedTicket({
    required this.id,
    required this.number,
    required this.addDate,
    required this.type,
    this.drawDate,
    this.status = 'pending',
    this.winLabel,
    this.winAmount,
    this.winIndices,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'addDate': addDate,
    'type': type,
    'drawDate': drawDate,
    'status': status,
    'winLabel': winLabel,
    'winAmount': winAmount,
    'winIndices': winIndices,
  };

  factory SavedTicket.fromJson(Map<String, dynamic> json) => SavedTicket(
    id: json['id'],
    number: json['number'],
    addDate: json['addDate'],
    type: json['type'] ?? 'manual',
    drawDate: json['drawDate'],
    status: json['status'] ?? 'pending',
    winLabel: json['winLabel'],
    winAmount: json['winAmount'],
    winIndices: json['winIndices'] != null ? List<int>.from(json['winIndices']) : null,
  );
}
