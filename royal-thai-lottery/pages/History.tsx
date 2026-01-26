import React from 'react';
import { ViewState } from '../types';

interface HistoryProps {
  onBack: () => void;
}

const HISTORY_DATA = [
  {
    month: '2023年10月',
    results: [
      {
        id: 'h1',
        date: '10月16日',
        number: '931446',
        top3: '122, 350',
        bottom3: '608, 210',
        bottom2: '44',
        prizeTag: '一等奖'
      },
      {
        id: 'h2',
        date: '10月01日',
        number: '727202',
        top3: '355, 955',
        bottom3: '815, 542',
        bottom2: '66',
        prizeTag: '一等奖'
      }
    ]
  },
  {
    month: '2023年09月',
    results: [
      {
        id: 'h3',
        date: '09月16日',
        number: '320812',
        top3: '038, 421',
        bottom3: '057, 344',
        bottom2: '46',
        prizeTag: '一等奖'
      },
      {
        id: 'h4',
        date: '09月01日',
        number: '915478',
        top3: '521, 596',
        bottom3: '692, 291',
        bottom2: '91',
        prizeTag: '一等奖'
      }
    ]
  }
];

const History: React.FC<HistoryProps> = ({ onBack }) => {
  return (
    <div className="min-h-screen bg-background pb-24 font-sans">
      {/* Header */}
      <header className="bg-primary px-4 py-4 flex justify-center items-center text-white sticky top-0 z-50 shadow-md">
        <h1 className="text-lg font-bold tracking-wide">历史开奖记录</h1>
      </header>

      {/* Filter Section */}
      <div className="bg-white p-4">
         {/* Search */}
         <div className="bg-gray-50 rounded-xl h-12 flex items-center px-4 mb-4 border border-gray-100">
            <span className="material-symbols-outlined text-gray-400 mr-2 text-xl">search</span>
            <input 
               type="text" 
               placeholder="搜索日期或年份" 
               className="bg-transparent flex-1 outline-none text-sm text-gray-700 placeholder:text-gray-400"
            />
         </div>
         {/* Dropdowns */}
         <div className="flex gap-4">
            <div className="flex-1 bg-gray-50 rounded-xl h-12 flex items-center justify-between px-4 border border-gray-100">
               <span className="text-sm font-bold text-gray-700">2024年</span>
               <span className="material-symbols-outlined text-gray-400">expand_more</span>
            </div>
            <div className="flex-1 bg-gray-50 rounded-xl h-12 flex items-center justify-between px-4 border border-gray-100">
               <span className="text-sm font-bold text-gray-700">10月</span>
               <span className="material-symbols-outlined text-gray-400">expand_more</span>
            </div>
         </div>
      </div>

      {/* List */}
      <div className="px-4">
         {HISTORY_DATA.map((group, index) => (
            <div key={index} className="mb-2">
               <h3 className="text-primary font-bold text-sm mb-3 mt-4 px-1">{group.month}</h3>
               <div className="space-y-3">
                  {group.results.map(item => (
                     <div key={item.id} className="bg-white rounded-3xl p-5 shadow-sm">
                        <div className="flex gap-4">
                           {/* Icon */}
                           <div className="shrink-0 pt-1">
                              <div className="w-12 h-12 rounded-2xl bg-[#FFF9C4] flex items-center justify-center">
                                 <span className="material-symbols-outlined text-2xl text-[#FBC02D] icon-filled">emoji_events</span>
                              </div>
                           </div>
                           {/* Content */}
                           <div className="flex-1 min-w-0">
                              <div className="mb-3">
                                 <div className="text-gray-900 font-bold text-lg mb-1">{item.date}</div>
                                 <div className="flex items-center gap-3">
                                    <span className="bg-[#EDE7F6] text-primary text-[10px] font-bold px-2 py-0.5 rounded">
                                       {item.prizeTag}
                                    </span>
                                    <span className="text-xl font-bold text-[#F9A825] tracking-wide">{item.number}</span>
                                    <span className="w-px h-3 bg-gray-200"></span>
                                    <span className="text-xs text-gray-400 font-medium">2位</span>
                                    <span className="text-lg font-bold text-primary">{item.bottom2}</span>
                                 </div>
                              </div>
                              
                              <div className="h-px bg-gray-50 w-full mb-3"></div>

                              <div className="grid grid-cols-2 gap-4">
                                 <div>
                                    <p className="text-[10px] text-gray-400 mb-0.5 font-medium">前3位</p>
                                    <p className="text-base font-bold text-gray-700">{item.top3}</p>
                                 </div>
                                 <div>
                                    <p className="text-[10px] text-gray-400 mb-0.5 font-medium">后3位</p>
                                    <p className="text-base font-bold text-gray-700">{item.bottom3}</p>
                                 </div>
                              </div>
                           </div>
                        </div>
                     </div>
                  ))}
               </div>
            </div>
         ))}
      </div>

      {/* FAB */}
      <button className="fixed bottom-24 right-4 w-14 h-14 bg-[#FFD700] rounded-full shadow-lg shadow-orange-500/20 flex items-center justify-center text-primary z-40 active:scale-90 transition-transform border-2 border-white/20">
         <span className="material-symbols-outlined text-2xl">grid_view</span>
      </button>
    </div>
  );
};

export default History;