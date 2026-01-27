import React from 'react';
import { ViewState } from '../types';

interface ProfileProps {
   onChangeView: (view: ViewState) => void;
}

const Profile: React.FC<ProfileProps> = ({ onChangeView }) => {
   return (
      <div className="min-h-screen pb-32 bg-background">
         <header className="bg-white sticky top-0 z-20 px-4 py-4 flex items-center justify-center relative border-b border-gray-50">
            <h1 className="text-lg font-bold text-primary-dark">个人中心</h1>
            <button className="absolute right-4 size-10 rounded-full flex items-center justify-center text-gray-400">
               <span className="material-symbols-outlined">settings</span>
            </button>
         </header>

         <div className="p-5 space-y-6">
            {/* Saved Tickets Hero */}
            <div className="bg-primary-dark rounded-2xl overflow-hidden relative shadow-lg">
               <div className="absolute inset-0 bg-gradient-to-br from-primary to-primary-dark opacity-90"></div>
               <div className="absolute -right-4 -top-4 text-white/5">
                  <span className="material-symbols-outlined text-[120px]">confirmation_number</span>
               </div>

               <div className="relative z-10 p-6">
                  <div className="text-white/60 text-xs font-bold uppercase tracking-widest mb-1">概览</div>
                  <h2 className="text-white text-2xl font-bold mb-4">我的彩票</h2>
                  <div className="flex items-center justify-between">
                     <span className="text-white/80 text-sm font-medium">12 张有效彩票</span>
                     <button
                        onClick={() => onChangeView('saved_tickets')}
                        className="bg-royal-gold text-primary-dark text-xs font-black px-4 py-2 rounded-full shadow-lg active:scale-95 transition-transform"
                     >
                        查看历史
                     </button>
                  </div>
               </div>
            </div>

            {/* Quick Add */}
            <div>
               <h3 className="text-lg font-bold text-primary-dark mb-3">添加新号码</h3>
               <div className="bg-white p-5 rounded-2xl border border-gray-100 shadow-sm flex flex-col gap-4">
                  <div className="flex-1">
                     <label className="text-xs text-gray-400 font-bold block mb-2">手动输入6位数字</label>
                     <input
                        type="text"
                        placeholder="000000"
                        maxLength={6}
                        className="w-full text-center text-2xl font-bold tracking-[0.3em] text-primary bg-gray-50 border border-gray-200 rounded-xl h-14 outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                     />
                  </div>
                  <button className="w-full h-12 bg-primary text-white rounded-xl font-bold flex items-center justify-center gap-2 shadow-md hover:bg-primary-dark transition-colors">
                     <span className="material-symbols-outlined">add_circle</span>
                     添加到我的彩票包
                  </button>
               </div>
            </div>

            {/* Lucky Generators Shortcuts */}
            <div>
               <h3 className="text-lg font-bold text-primary-dark mb-3">幸运生成器</h3>
               <div className="grid grid-cols-3 gap-3">
                  {[
                     { icon: 'casino', label: '随机生成', color: 'from-purple-500 to-indigo-500' },
                     { icon: 'cake', label: '生日幸运号', color: 'from-pink-500 to-rose-500' },
                     { icon: 'magic_button', label: '手机号魔法', color: 'from-amber-400 to-orange-500' }
                  ].map((item, idx) => (
                     <button
                        key={idx}
                        onClick={() => onChangeView('generator')}
                        className="bg-white p-3 rounded-2xl border border-gray-100 shadow-sm flex flex-col items-center gap-3 active:bg-gray-50 transition-colors"
                     >
                        <div className={`size-12 rounded-full bg-gradient-to-br ${item.color} text-white flex items-center justify-center shadow-inner`}>
                           <span className="material-symbols-outlined text-2xl">{item.icon}</span>
                        </div>
                        <span className="text-[11px] font-bold text-gray-600">{item.label}</span>
                     </button>
                  ))}
               </div>
            </div>

            {/* Recent Tickets List */}
            <div>
               <div className="flex items-center justify-between mb-3">
                  <h3 className="text-lg font-bold text-primary-dark">最近彩票</h3>
                  <button className="text-xs font-bold text-primary underline decoration-2 underline-offset-4">查看全部</button>
               </div>

               <div className="space-y-3">
                  <div className="bg-white p-4 rounded-xl border-l-4 border-royal-gold shadow-sm flex justify-between items-center">
                     <div>
                        <div className="text-[10px] text-gray-400 font-bold mb-1">开奖日期: 2023年10月16日</div>
                        <div className="text-xl font-bold text-primary tracking-widest">823491</div>
                     </div>
                     <div className="flex items-center gap-1 bg-yellow-50 border border-yellow-100 px-2 py-1 rounded-full">
                        <span className="material-symbols-outlined text-royal-gold text-sm icon-filled">emoji_events</span>
                        <span className="text-[10px] font-bold text-yellow-700">已中奖</span>
                     </div>
                  </div>

                  <div className="bg-white p-4 rounded-xl border-l-4 border-gray-300 shadow-sm flex justify-between items-center">
                     <div>
                        <div className="text-[10px] text-gray-400 font-bold mb-1">开奖日期: 2023年11月01日</div>
                        <div className="text-xl font-bold text-gray-600 tracking-widest">004812</div>
                     </div>
                     <div className="flex items-center gap-1 bg-gray-100 px-2 py-1 rounded-full">
                        <span className="material-symbols-outlined text-gray-400 text-sm">schedule</span>
                        <span className="text-[10px] font-bold text-gray-500">待开奖</span>
                     </div>
                  </div>
               </div>
            </div>
         </div>
      </div>
   );
};

export default Profile;