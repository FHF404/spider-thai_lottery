import React, { useState } from 'react';
import { GeneratorMode } from '../types';

const Generator: React.FC = () => {
  const [mode, setMode] = useState<GeneratorMode>('phone');
  const [generatedNumbers, setGeneratedNumbers] = useState<number[] | null>(null);

  const handleGenerate = () => {
    // Simulate generation
    setGeneratedNumbers([8, 2, 9, 5, 1, 7]);
  };

  return (
    <div className="min-h-screen pb-32 bg-background flex flex-col">
       <header className="bg-primary-dark p-4 flex items-center justify-between shadow-md">
          <button className="text-royal-gold"><span className="material-symbols-outlined text-2xl">arrow_back_ios</span></button>
          <h1 className="text-royal-gold text-lg font-bold">幸运号码生成器</h1>
          <button className="text-royal-gold"><span className="material-symbols-outlined text-2xl">info</span></button>
       </header>

       {/* Tabs */}
       <div className="bg-primary-dark/5 p-4">
          <div className="bg-white rounded-xl p-1 flex shadow-sm border border-gray-200">
             <button 
                onClick={() => { setMode('birthday'); setGeneratedNumbers(null); }}
                className={`flex-1 py-2 text-sm font-bold rounded-lg transition-all ${mode === 'birthday' ? 'bg-primary text-white shadow-md' : 'text-gray-500'}`}
             >
                生日幸运号
             </button>
             <button 
                onClick={() => { setMode('phone'); setGeneratedNumbers(null); }}
                className={`flex-1 py-2 text-sm font-bold rounded-lg transition-all ${mode === 'phone' ? 'bg-primary text-white shadow-md' : 'text-gray-500'}`}
             >
                手机号生成
             </button>
             <button 
                onClick={() => { setMode('random'); setGeneratedNumbers(null); }}
                className={`flex-1 py-2 text-sm font-bold rounded-lg transition-all ${mode === 'random' ? 'bg-primary text-white shadow-md' : 'text-gray-500'}`}
             >
                随机生成
             </button>
          </div>
       </div>

       <div className="flex-1 px-6 py-8 flex flex-col items-center">
          
          {/* CONTENT AREA BASED ON MODE */}
          {mode === 'phone' && (
             <div className="w-full text-center">
                <h3 className="text-2xl font-bold text-primary-dark mb-2">输入您的手机号</h3>
                <p className="text-primary-dark/60 text-sm mb-8">将您的号码转化为繁荣与好运的象征</p>
                
                <div className="relative w-full mb-6">
                   <span className="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-primary">phone_iphone</span>
                   <input type="tel" placeholder="请输入11位手机号码" className="w-full h-16 pl-12 pr-4 bg-white rounded-2xl border-2 border-primary/20 focus:border-primary text-xl font-bold text-primary-dark placeholder:text-gray-300 placeholder:font-normal outline-none shadow-sm transition-all" />
                </div>
                
                <button onClick={handleGenerate} className="w-full h-14 bg-primary-dark text-royal-gold text-lg font-bold rounded-xl shadow-lg flex items-center justify-center gap-2 active:scale-95 transition-transform">
                   <span className="material-symbols-outlined">auto_fix_high</span>
                   开始魔法计算
                </button>
             </div>
          )}

          {mode === 'birthday' && (
             <div className="w-full text-center">
                <h3 className="text-2xl font-bold text-primary-dark mb-2">选择您的出生日期</h3>
                <p className="text-primary-dark/60 text-sm mb-8">基于泰国皇家占星术为您计算幸运数字</p>

                <div className="flex gap-2 w-full mb-8 bg-white p-4 rounded-2xl border-2 border-primary/10 shadow-lg">
                   <div className="flex-1 flex flex-col items-center gap-1">
                      <span className="text-[10px] font-bold text-gray-400 uppercase">年份</span>
                      <div className="h-10 flex items-center text-gray-300 font-medium text-sm">1995</div>
                      <div className="h-12 w-full bg-primary/10 rounded-lg flex items-center justify-center text-primary font-bold border-y-2 border-primary/30 text-lg">1996</div>
                      <div className="h-10 flex items-center text-gray-300 font-medium text-sm">1997</div>
                   </div>
                   <div className="flex-1 flex flex-col items-center gap-1 border-x border-gray-100 px-2">
                      <span className="text-[10px] font-bold text-gray-400 uppercase">月份</span>
                      <div className="h-10 flex items-center text-gray-300 font-medium text-sm">05月</div>
                      <div className="h-12 w-full bg-primary/10 rounded-lg flex items-center justify-center text-primary font-bold border-y-2 border-primary/30 text-lg">06月</div>
                      <div className="h-10 flex items-center text-gray-300 font-medium text-sm">07月</div>
                   </div>
                   <div className="flex-1 flex flex-col items-center gap-1">
                      <span className="text-[10px] font-bold text-gray-400 uppercase">日期</span>
                      <div className="h-10 flex items-center text-gray-300 font-medium text-sm">14</div>
                      <div className="h-12 w-full bg-primary/10 rounded-lg flex items-center justify-center text-primary font-bold border-y-2 border-primary/30 text-lg">15</div>
                      <div className="h-10 flex items-center text-gray-300 font-medium text-sm">16</div>
                   </div>
                </div>

                <button onClick={handleGenerate} className="w-full h-14 bg-primary-dark text-royal-gold text-lg font-bold rounded-xl shadow-lg flex items-center justify-center gap-2 active:scale-95 transition-transform">
                   <span className="material-symbols-outlined">stars</span>
                   计算幸运号
                </button>
             </div>
          )}

          {mode === 'random' && (
            <div className="w-full text-center flex flex-col items-center justify-center h-full">
                <div className="mb-10">
                   <h3 className="text-2xl font-bold text-primary-dark mb-2">点击生成幸运号码</h3>
                   <p className="text-primary-dark/60 text-sm">皇家占星随机算法为您即时演算</p>
                </div>

                <div className="relative group cursor-pointer" onClick={handleGenerate}>
                   <div className="absolute inset-0 -m-4 border-2 border-primary/20 rounded-full animate-ping opacity-20"></div>
                   <div className="absolute inset-0 -m-2 border border-primary/40 rounded-full"></div>
                   <button className="w-48 h-48 rounded-full bg-primary-dark border-4 border-royal-gold shadow-[0_0_40px_rgba(103,58,183,0.4)] flex flex-col items-center justify-center active:scale-95 transition-transform">
                      <span className="material-symbols-outlined text-royal-gold text-5xl mb-2 icon-filled">stars</span>
                      <span className="text-royal-gold font-bold text-xl tracking-widest">开始生成</span>
                   </button>
                </div>
            </div>
          )}

          {/* RESULT DISPLAY */}
          {generatedNumbers && (
             <div className="w-full mt-10 animate-in fade-in slide-in-from-bottom-10 duration-700">
                <div className="relative bg-white rounded-[2.5rem] border-2 border-royal-gold/20 p-8 text-center shadow-xl">
                   {/* Decorative Corners */}
                   <div className="absolute top-3 left-3 w-4 h-4 border-t-2 border-l-2 border-royal-gold rounded-tl"></div>
                   <div className="absolute top-3 right-3 w-4 h-4 border-t-2 border-r-2 border-royal-gold rounded-tr"></div>
                   <div className="absolute bottom-3 left-3 w-4 h-4 border-b-2 border-l-2 border-royal-gold rounded-bl"></div>
                   <div className="absolute bottom-3 right-3 w-4 h-4 border-b-2 border-r-2 border-royal-gold rounded-br"></div>

                   <p className="text-primary-dark/40 text-xs font-bold tracking-[0.2em] mb-6 uppercase">您的手机幸运号</p>
                   
                   <div className="flex justify-center gap-2">
                      {generatedNumbers.map((num, i) => (
                         <div key={i} className="w-10 h-14 bg-gray-50 rounded-xl flex items-center justify-center border border-gray-100 text-2xl font-bold text-primary-dark shadow-sm">
                            {num}
                         </div>
                      ))}
                   </div>

                   <div className="mt-8 flex items-center justify-center gap-2 text-[10px] text-primary/30 uppercase tracking-[0.25em] font-bold">
                      <span className="w-8 h-px bg-primary/20"></span>
                      <span>Royal Thai Blessing</span>
                      <span className="w-8 h-px bg-primary/20"></span>
                   </div>
                </div>
             </div>
          )}
       </div>
    </div>
  );
};

export default Generator;