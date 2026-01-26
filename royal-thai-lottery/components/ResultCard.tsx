import React from 'react';
import { LotteryResult } from '../types';

interface ResultCardProps {
  result: LotteryResult;
  isHero?: boolean;
  onCheckTicket?: () => void;
}

const ResultCard: React.FC<ResultCardProps> = ({ result, isHero = false, onCheckTicket }) => {
  if (isHero) {
    return (
      <div className="bg-white rounded-3xl p-5 border-2 border-[#FFD700] shadow-sm mb-6 relative overflow-hidden">
        {/* Top Section */}
        <div className="text-center pt-2">
          <h3 className="text-primary font-bold text-base mb-1">最新开奖结果</h3>
          <p className="text-gray-400 text-xs mb-2">一等奖</p>
          <div className="text-6xl font-bold text-primary tracking-wider mb-3 font-display drop-shadow-sm">
            {result.number}
          </div>
          <div className="flex items-center justify-center gap-2 text-gray-500 text-sm font-medium mb-6">
            <span className="material-symbols-outlined text-lg">calendar_today</span>
            <span>{result.drawDateFull}</span>
          </div>
        </div>

        {/* Grid Section */}
        <div className="grid grid-cols-3 divide-x divide-gray-100 border-y border-gray-100 py-4 mb-5">
          <div className="text-center px-1">
            <p className="text-xs text-[#D4AF37] font-bold mb-2">前三位</p>
            <p className="text-gray-800 font-bold text-lg leading-tight">{result.top3}</p>
          </div>
          <div className="text-center px-1">
            <p className="text-xs text-[#D4AF37] font-bold mb-2">后三位</p>
            <p className="text-gray-800 font-bold text-lg leading-tight">{result.bottom3}</p>
          </div>
          <div className="text-center px-1">
            <p className="text-xs text-primary font-bold mb-2">后两位</p>
            <p className="text-primary font-bold text-2xl leading-tight">{result.bottom2}</p>
          </div>
        </div>

        {/* Button */}
        <button 
          onClick={onCheckTicket}
          className="w-full h-12 bg-primary hover:bg-primary-dark text-white rounded-xl font-bold text-base shadow-lg shadow-primary/30 flex items-center justify-center gap-2 active:scale-[0.98] transition-all"
        >
            <span className="material-symbols-outlined icon-filled text-xl text-[#FFD700]">qr_code_scanner</span>
            检查我的彩票
        </button>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-3xl p-5 shadow-sm mb-4">
      <div className="flex gap-4">
        <div className="shrink-0 pt-1">
          <div className="w-12 h-12 rounded-2xl bg-[#FFF9C4] flex items-center justify-center">
            <span className="material-symbols-outlined text-2xl text-[#FBC02D] icon-filled">emoji_events</span>
          </div>
        </div>
        <div className="flex-1 min-w-0">
          <div className="mb-3">
            <h3 className="text-lg font-bold text-gray-900 mb-1">{result.date}</h3>
            <div className="flex items-center gap-3">
                <span className="bg-[#EDE7F6] text-primary text-[10px] font-bold px-2 py-0.5 rounded">一等奖</span>
                <span className="text-xl font-bold text-[#F9A825] tracking-wide">{result.number}</span>
                <span className="w-px h-3 bg-gray-200"></span>
                <span className="text-xs text-gray-400 font-medium">2位</span>
                <span className="text-lg font-bold text-primary">{result.bottom2}</span>
            </div>
          </div>
          
          <div className="h-px bg-gray-50 w-full mb-3"></div>

          <div className="grid grid-cols-2 gap-8">
            <div>
                <p className="text-[10px] text-gray-400 mb-0.5 font-medium">前3位</p>
                <p className="text-base font-bold text-gray-700">{result.top3}</p>
            </div>
            <div>
                <p className="text-[10px] text-gray-400 mb-0.5 font-medium">后3位</p>
                <p className="text-base font-bold text-gray-700">{result.bottom3}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ResultCard;