import React from 'react';
import ResultCard from '../components/ResultCard';
import { LotteryResult } from '../types';

const MOCK_RESULTS: LotteryResult[] = [
  {
    id: '1',
    date: '10月16日',
    drawDateFull: '2023年10月16日',
    number: '123456',
    top3: '789, 456',
    bottom3: '123, 789',
    bottom2: '45'
  },
  {
    id: '2',
    date: '10月01日',
    drawDateFull: '2023年10月01日',
    number: '987654',
    top3: '355, 955',
    bottom3: '815, 542',
    bottom2: '12'
  },
  {
    id: '3',
    date: '09月16日',
    drawDateFull: '2023年09月16日',
    number: '741085',
    top3: '125, 458',
    bottom3: '624, 731',
    bottom2: '91'
  },
  {
    id: '4',
    date: '09月01日',
    drawDateFull: '2023年09月01日',
    number: '523994',
    top3: '943, 110',
    bottom3: '259, 887',
    bottom2: '84'
  }
];

interface HomeProps {
    onCheckTicket: () => void;
    onViewHistory: () => void;
    onOpenGenerator: () => void;
}

const Home: React.FC<HomeProps> = ({ onCheckTicket, onViewHistory, onOpenGenerator }) => {
  return (
    <div className="min-h-screen pb-28 bg-background font-sans">
      {/* Header */}
      <header className="bg-primary px-4 py-4 flex justify-center items-center text-white sticky top-0 z-50 shadow-md relative">
        <h1 className="text-lg font-bold tracking-wide">泰国彩票开奖</h1>
        <button className="p-1 absolute right-4">
          <span className="material-symbols-outlined text-2xl icon-filled text-[#FFD700]">notifications</span>
          <span className="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full border border-primary"></span>
        </button>
      </header>

      <div className="p-4 pt-6">
        {/* Hero Card */}
        <ResultCard result={MOCK_RESULTS[0]} isHero={true} onCheckTicket={onCheckTicket} />

        {/* Recent History Header */}
        <div className="flex items-center justify-between mb-4 mt-8 px-1">
           <h2 className="text-xl font-bold text-primary-dark">最近开奖历史</h2>
           <button onClick={onViewHistory} className="text-sm font-bold text-[#D4AF37]">查看全部</button>
        </div>

        {/* List */}
        <div className="flex flex-col gap-4">
           {/* Item 1 */}
           <ResultCard result={MOCK_RESULTS[1]} />
           
           {/* AI Banner */}
           <div className="bg-[#F3E5F5] rounded-2xl p-4 flex items-center justify-between shadow-sm border border-purple-100 relative overflow-hidden">
               <div className="absolute top-0 right-0 w-16 h-16 bg-[#FFD700] opacity-10 rounded-full -mr-8 -mt-8"></div>
              <div className="flex items-center gap-4 relative z-10">
                 <div className="w-12 h-12 bg-white rounded-xl flex items-center justify-center shadow-sm text-primary">
                    <span className="material-symbols-outlined text-2xl icon-filled">psychology</span>
                 </div>
                 <div>
                    <div className="flex items-center gap-2 mb-0.5">
                       <span className="bg-[#FFD700] text-primary-dark text-[10px] font-bold px-1 rounded">广告</span>
                       <h3 className="font-bold text-primary-dark text-base">AI 号码预测工具</h3>
                    </div>
                    <p className="text-xs text-gray-500">试试我们全新的彩票模拟器</p>
                 </div>
              </div>
              <button 
                onClick={onOpenGenerator}
                className="bg-primary text-white text-xs font-bold px-5 py-2 rounded-full shadow-md active:scale-95 transition-transform relative z-10"
              >
                 打开
              </button>
           </div>

           {/* Remaining Items */}
           {MOCK_RESULTS.slice(2).map(result => (
             <ResultCard key={result.id} result={result} />
           ))}
        </div>
      </div>
    </div>
  );
};

export default Home;