import React from 'react';
import { ViewState } from '../types';

interface ResultProps {
  status: 'win' | 'loss';
  onBack: () => void;
  onTryAgain: () => void;
}

const Result: React.FC<ResultProps> = ({ status, onBack, onTryAgain }) => {
  const isWin = status === 'win';

  if (isWin) {
    return (
      <div className="min-h-screen bg-background text-gray-900 font-sans pb-10">
        {/* Confetti Background would go here */}
        <div className="sticky top-0 z-50 flex items-center justify-between p-4 bg-white/80 backdrop-blur-md">
           <button onClick={onBack} className="text-primary"><span className="material-symbols-outlined">arrow_back_ios</span></button>
           <h2 className="text-lg font-bold">中奖结果查询</h2>
           <button className="size-10 flex items-center justify-center bg-primary/10 rounded-full text-primary">
              <span className="material-symbols-outlined">share</span>
           </button>
        </div>

        <div className="px-4 py-8 text-center relative">
           <div className="inline-flex p-3 rounded-full bg-royal-gold/20 mb-4 animate-bounce">
              <span className="material-symbols-outlined text-4xl text-royal-gold icon-filled">stars</span>
           </div>
           <h1 className="text-3xl font-extrabold text-gray-900 mb-2">恭喜您中奖了！</h1>
           <p className="text-sm text-gray-500">✨ 皇家泰国抽奖 - 2023年10月1日 ✨</p>
        </div>

        <div className="px-4">
           {/* Ticket Card */}
           <div className="bg-primary-dark rounded-xl p-6 relative overflow-hidden shadow-2xl border border-royal-gold/30">
              <div className="absolute inset-0 bg-gradient-to-br from-[#211c27] to-primary-dark z-0"></div>
              {/* Pattern overlay simulation */}
              <div className="absolute inset-0 opacity-10" style={{backgroundImage: 'radial-gradient(#FFD700 1px, transparent 1px)', backgroundSize: '10px 10px'}}></div>
              
              <div className="relative z-10">
                  <div className="flex justify-between items-start mb-4">
                     <span className="text-[10px] uppercase tracking-widest text-white/50 font-bold border border-white/20 px-2 py-1 rounded">Official Winner</span>
                     <span className="size-8 rounded-full border border-royal-gold/50 flex items-center justify-center text-royal-gold bg-black/20">
                        <span className="material-symbols-outlined text-sm icon-filled">verified</span>
                     </span>
                  </div>
                  
                  <div className="text-center py-4 border-y border-white/10 my-4">
                     <p className="text-xs text-white/60 mb-1 uppercase tracking-wider">官方中奖票据</p>
                     <p className="text-5xl font-display font-black text-white tracking-tight">123456</p>
                  </div>

                  <div className="flex justify-between items-center">
                     <p className="text-xs text-white/60">您的中奖号码已验证</p>
                     <button className="bg-white text-primary px-3 py-1 rounded-full text-xs font-bold">查看详情</button>
                  </div>
              </div>
           </div>

           {/* Stats */}
           <div className="mt-6 space-y-4">
              <div className="bg-white p-6 rounded-xl border-l-4 border-royal-gold shadow-sm flex flex-col gap-1 relative overflow-hidden">
                 <span className="material-symbols-outlined absolute -right-4 -top-4 text-9xl text-royal-gold/10 rotate-12">military_tech</span>
                 <p className="text-gray-500 font-medium">一等奖奖金 (First Prize)</p>
                 <p className="text-4xl font-black text-transparent bg-clip-text bg-gradient-to-r from-royal-gold to-yellow-600">฿6,000,000</p>
              </div>

              <div className="grid grid-cols-2 gap-4">
                 <div className="bg-white p-4 rounded-xl shadow-sm">
                    <p className="text-xs text-gray-400 mb-1">扣税 (Tax 1%)</p>
                    <p className="text-lg font-bold text-gray-800">-฿60,000</p>
                 </div>
                 <div className="bg-white p-4 rounded-xl shadow-sm">
                    <p className="text-xs text-gray-400 mb-1">实到奖金 (Net)</p>
                    <p className="text-lg font-bold text-primary">฿5,940,000</p>
                 </div>
              </div>
           </div>

           <div className="mt-8 space-y-3 pb-8">
              <button className="w-full h-14 rounded-full bg-gradient-to-r from-royal-gold via-yellow-200 to-royal-gold text-black font-bold text-lg shadow-glow flex items-center justify-center gap-2">
                 <span className="material-symbols-outlined">share_windows</span>
                 立即分享喜悦
              </button>
              <button onClick={onBack} className="w-full h-14 rounded-full border-2 border-primary/20 text-primary font-bold hover:bg-primary/5 transition-colors">
                 返回主页
              </button>
           </div>
        </div>
      </div>
    );
  }

  // LOSS VIEW
  return (
    <div className="min-h-screen bg-white flex flex-col">
       <div className="sticky top-0 z-50 flex items-center p-4 bg-white border-b border-gray-100">
           <button onClick={onBack} className="text-primary"><span className="material-symbols-outlined">arrow_back_ios</span></button>
           <h2 className="text-lg font-bold text-gray-900 ml-2">查询结果</h2>
       </div>

       <div className="flex-1 overflow-y-auto pb-8">
          <div className="px-6 py-12 flex flex-col items-center text-center">
             <div className="relative size-24 bg-primary/5 rounded-full flex items-center justify-center border-2 border-primary/10 mb-6">
                <span className="material-symbols-outlined text-6xl text-primary/30">search_off</span>
                <div className="absolute -top-1 -right-1 bg-royal-gold/20 p-1.5 rounded-full">
                   <span className="material-symbols-outlined text-royal-gold text-xl icon-filled">star</span>
                </div>
             </div>
             <h2 className="text-2xl font-bold text-gray-900 mb-2">很抱歉，未中奖</h2>
             <p className="text-gray-500 text-sm">别气馁，好运在后面！</p>
          </div>

          <div className="px-4">
             <div className="bg-white rounded-xl shadow-ios border border-royal-gold/20 p-6">
                <div className="flex justify-between items-center border-b border-gray-100 pb-4 mb-4">
                   <div className="flex items-center gap-2">
                      <span className="material-symbols-outlined text-royal-gold">confirmation_number</span>
                      <span className="text-sm font-medium text-gray-500">第 20240512 期</span>
                   </div>
                   <span className="text-[10px] font-bold bg-gray-100 text-gray-500 px-2 py-0.5 rounded uppercase">Closed</span>
                </div>

                <div className="flex justify-between items-stretch">
                   <div className="flex-1 flex flex-col items-center border-r border-gray-100">
                      <p className="text-xs font-bold text-gray-400 uppercase mb-1">您的号码</p>
                      <p className="text-2xl font-bold text-primary tracking-widest">123456</p>
                   </div>
                   <div className="flex-1 flex flex-col items-center">
                      <p className="text-xs font-bold text-gray-400 uppercase mb-1">中奖号码</p>
                      <p className="text-2xl font-bold text-royal-gold tracking-widest">987654</p>
                   </div>
                </div>
                
                <div className="mt-4 bg-gray-50 p-3 rounded-lg flex gap-2">
                   <span className="material-symbols-outlined text-primary text-sm mt-0.5">info</span>
                   <p className="text-xs text-gray-500 leading-relaxed">中奖结果依据泰国政府彩票办公室官方数据。祝您下次好运。</p>
                </div>
             </div>
          </div>
          
          <div className="px-10 text-center mt-8">
             <div className="h-px w-full bg-gradient-to-r from-transparent via-royal-gold/30 to-transparent mb-6"></div>
             <p className="text-primary/80 text-sm italic font-medium">“每一次机会都是通往幸运的阶梯”</p>
          </div>
       </div>

       <div className="p-6 flex flex-col gap-3 border-t border-gray-50">
           <button onClick={onTryAgain} className="w-full h-14 bg-primary text-white text-lg font-bold rounded-xl shadow-lg shadow-primary/20 active:scale-[0.98] transition-all">
              再试一次
           </button>
           <button onClick={onBack} className="w-full h-14 border-2 border-primary/10 text-primary text-lg font-bold rounded-xl hover:bg-primary/5 active:scale-[0.98] transition-all">
              返回主页
           </button>
       </div>
    </div>
  );
};

export default Result;