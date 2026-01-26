import React, { useState } from 'react';

interface SavedTicketsProps {
  onBack: () => void;
}

const SavedTickets: React.FC<SavedTicketsProps> = ({ onBack }) => {
  const [activeTab, setActiveTab] = useState<'all' | 'pending' | 'won' | 'lost'>('all');

  return (
    <div className="min-h-screen bg-background font-sans pb-24 text-[#141118]">
      {/* Header */}
      <div className="sticky top-0 z-50 bg-white/80 backdrop-blur-md border-b border-gray-200">
        <div className="flex items-center p-4 justify-between max-w-md mx-auto">
          <div className="flex items-center gap-3">
            <button onClick={onBack} className="p-1 -ml-1">
                <span className="material-symbols-outlined text-[#141118]">arrow_back_ios</span>
            </button>
            <h2 className="text-xl font-bold leading-tight tracking-tight">我保存的彩票 (精简版)</h2>
          </div>
          <button className="flex items-center justify-center rounded-full h-10 w-10 hover:bg-gray-100 transition-colors">
            <span className="material-symbols-outlined">filter_list</span>
          </button>
        </div>
        
        {/* Tabs */}
        <div className="max-w-md mx-auto px-4">
          <div className="flex gap-6 overflow-x-auto no-scrollbar">
            {[
                { id: 'all', label: '全部' },
                { id: 'pending', label: '待开奖' },
                { id: 'won', label: '已中奖' },
                { id: 'lost', label: '未中奖' }
            ].map(tab => (
                <button 
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id as any)}
                    className={`flex flex-col items-center justify-center border-b-[3px] pb-3 pt-4 whitespace-nowrap transition-colors ${
                        activeTab === tab.id 
                        ? 'border-primary text-primary' 
                        : 'border-transparent text-gray-500'
                    }`}
                >
                    <p className="text-sm font-bold">{tab.label}</p>
                </button>
            ))}
          </div>
        </div>
      </div>

      <main className="max-w-md mx-auto p-4 space-y-4">
        
        {/* Winner Card (Gold) */}
        {(activeTab === 'all' || activeTab === 'won') && (
            <div className="relative overflow-hidden rounded-xl bg-white border-2 border-[#D4AF37]/30 shadow-lg shadow-[#D4AF37]/10">
            <div className="absolute top-0 right-0 p-2">
                <div className="bg-[#D4AF37] text-white text-[10px] font-bold px-2 py-0.5 rounded-full flex items-center gap-1">
                <span className="material-symbols-outlined text-xs">stars</span> 恭喜中奖
                </div>
            </div>
            <div className="p-4 pt-6">
                <div className="flex justify-between items-start mb-4">
                <div className="space-y-1">
                    <p className="text-gray-500 text-xs font-medium">开奖日期: 2023-10-16</p>
                    <p className="text-[#D4AF37] font-bold text-lg flex items-center gap-1">
                        一等奖 <span className="text-sm font-normal text-gray-500">(6,000,000 泰铢)</span>
                    </p>
                </div>
                </div>
                <div className="flex gap-2 mb-4 justify-between">
                    {['8', '8', '8', '8', '8', '8'].map((num, i) => (
                        <div key={i} className="flex items-center justify-center w-10 h-10 bg-white border border-gray-200 rounded-lg font-extrabold text-xl text-gray-900 shadow-sm">
                            {num}
                        </div>
                    ))}
                </div>
                <div className="flex items-center justify-between border-t border-gray-100 pt-4">
                <p className="text-xs text-gray-500">添加日期: 2023-10-01</p>
                </div>
            </div>
            <div className="absolute -bottom-4 -right-4 opacity-10 pointer-events-none">
                <span className="material-symbols-outlined text-8xl icon-filled">workspace_premium</span>
            </div>
            </div>
        )}

        {/* Pending Card */}
        {(activeTab === 'all' || activeTab === 'pending') && (
            <div className="rounded-xl bg-white border border-gray-200 shadow-sm">
            <div className="p-4">
                <div className="flex justify-between items-start mb-4">
                <div className="space-y-1">
                    <p className="text-gray-500 text-xs font-medium">下期开奖: 2023-11-01</p>
                    <div className="flex items-center gap-2">
                    <span className="text-lg font-bold">待开奖</span>
                    <span className="bg-primary/10 text-primary text-[10px] px-2 py-0.5 rounded-md font-bold">倒计时 2天</span>
                    </div>
                </div>
                <span className="material-symbols-outlined text-gray-300">more_horiz</span>
                </div>
                <div className="flex gap-2 mb-4 justify-between">
                    {['1', '2', '3', '4', '5', '6'].map((num, i) => (
                        <div key={i} className="flex items-center justify-center w-10 h-10 bg-white border border-gray-200 rounded-lg font-extrabold text-xl text-gray-900 shadow-sm">
                            {num}
                        </div>
                    ))}
                </div>
                <div className="flex items-center justify-between border-t border-gray-100 pt-4">
                <p className="text-xs text-gray-500">添加日期: 2023-10-20</p>
                </div>
            </div>
            </div>
        )}

        {/* Small Win Card */}
        {(activeTab === 'all' || activeTab === 'won') && (
            <div className="relative overflow-hidden rounded-xl bg-white border border-[#D4AF37]/20 shadow-sm">
            <div className="p-4">
                <div className="flex justify-between items-start mb-4">
                <div className="space-y-1">
                    <p className="text-gray-500 text-xs font-medium">开奖日期: 2023-10-16</p>
                    <p className="text-[#D4AF37] font-bold text-lg">后2位 (2,000 泰铢)</p>
                </div>
                <div className="bg-[#D4AF37]/10 text-[#D4AF37] text-[10px] font-bold px-2 py-0.5 rounded-full">已中奖</div>
                </div>
                <div className="flex gap-2 mb-4 justify-between">
                    {['4', '5', '6', '7', '8', '9'].map((num, i) => {
                        const isWinNum = num === '8' || num === '9';
                        return (
                            <div key={i} className={`flex items-center justify-center w-10 h-10 rounded-lg font-extrabold text-xl shadow-sm ${
                                isWinNum 
                                ? 'bg-[#D4AF37]/5 border border-[#D4AF37] text-gray-900' 
                                : 'bg-white border border-gray-200 text-gray-900'
                            }`}>
                                {num}
                            </div>
                        );
                    })}
                </div>
                <div className="flex items-center justify-between border-t border-gray-100 pt-4">
                <p className="text-xs text-gray-500">添加日期: 2023-10-10</p>
                </div>
            </div>
            </div>
        )}

        {/* Lost Card */}
        {(activeTab === 'all' || activeTab === 'lost') && (
            <div className="rounded-xl bg-gray-50/50 border border-dashed border-gray-200 opacity-70">
            <div className="p-4">
                <div className="flex justify-between items-start mb-4">
                <div className="space-y-1">
                    <p className="text-gray-500 text-xs font-medium">开奖日期: 2023-10-01</p>
                    <p className="text-gray-500 font-bold text-lg">未中奖</p>
                </div>
                <span className="material-symbols-outlined text-gray-400">cancel</span>
                </div>
                <div className="flex gap-2 mb-4 justify-between">
                    {['4', '5', '6', '7', '8', '9'].map((num, i) => (
                        <div key={i} className="flex items-center justify-center w-10 h-10 bg-white border border-gray-200 rounded-lg font-extrabold text-xl text-gray-900 shadow-sm grayscale opacity-60">
                            {num}
                        </div>
                    ))}
                </div>
                <div className="flex items-center justify-between border-t border-gray-200/50 pt-4">
                <p className="text-xs text-gray-500">添加日期: 2023-09-25</p>
                <button className="bg-white border border-primary text-primary px-4 py-2 rounded-lg text-sm font-bold">
                    再次购买
                </button>
                </div>
            </div>
            </div>
        )}
      </main>
    </div>
  );
};

export default SavedTickets;