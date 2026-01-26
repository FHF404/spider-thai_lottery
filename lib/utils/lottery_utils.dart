import 'package:intl/intl.dart';
import '../models/lottery_result.dart';
import '../models/saved_ticket.dart';

class LotteryUtils {
  static Map<String, dynamic> checkWinStatus(SavedTicket ticket, LotteryResult? latestResult) {
    if (latestResult == null) return {'status': 'pending', 'label': '待开奖'};
    
    final number = ticket.number;
    final winNum = latestResult.number;
    final b2 = latestResult.bottom2;
    final t3 = latestResult.top3.split(', ').map((e) => e.replaceAll(' ', '')).toList();
    final b3 = latestResult.bottom3.split(', ').map((e) => e.replaceAll(' ', '')).toList();

    List<String> winningPrizes = [];
    Set<int> winningIndices = {};
    int totalPrizeValue = 0;
    bool hasWon = false;

    // 1st Prize (6,000,000 THB)
    if (number == winNum) {
      hasWon = true;
      winningPrizes.add('一等奖');
      winningIndices.addAll([0, 1, 2, 3, 4, 5]);
      totalPrizeValue += 6000000;
    }
    
    // Front 3 (4,000 THB)
    final front3 = number.substring(0, 3);
    if (t3.contains(front3)) {
      hasWon = true;
      winningPrizes.add('前3位');
      winningIndices.addAll([0, 1, 2]);
      totalPrizeValue += 4000;
    }

    // Back 3 (4,000 THB)
    final back3 = number.substring(3);
    if (b3.contains(back3)) {
      hasWon = true;
      winningPrizes.add('后3位');
      winningIndices.addAll([3, 4, 5]);
      totalPrizeValue += 4000;
    }

    // Last 2 (2,000 THB)
    if (number.endsWith(b2)) {
      hasWon = true;
      winningPrizes.add('后2位');
      winningIndices.addAll([4, 5]);
      totalPrizeValue += 2000;
    }

    if (hasWon) {
      final NumberFormat formatter = NumberFormat('#,###');
      return {
        'status': 'won',
        'label': winningPrizes.join('、'),
        'indices': winningIndices.toList(),
        'amount': '${formatter.format(totalPrizeValue)} 泰铢',
        'prizes': winningPrizes,
      };
    }

    return {'status': 'lost', 'label': '未中奖'};
  }
}
