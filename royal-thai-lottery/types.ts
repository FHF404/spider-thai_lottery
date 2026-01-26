export type ViewState = 'home' | 'history' | 'profile' | 'check' | 'generator' | 'result_win' | 'result_loss' | 'saved_tickets';

export interface LotteryResult {
  id: string;
  date: string;
  drawDateFull: string;
  number: string;
  top3: string;
  bottom3: string;
  bottom2: string;
}

export interface SavedTicket {
  id: string;
  number: string;
  date: string;
  status: 'pending' | 'won' | 'lost';
  prizeAmount?: string;
}

export type GeneratorMode = 'random' | 'birthday' | 'phone';