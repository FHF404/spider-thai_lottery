import React, { useState } from 'react';
import { ViewState } from '../types';

interface CheckTicketProps {
  onBack: () => void;
  onCheck: (number: string) => void;
}

const CheckTicket: React.FC<CheckTicketProps> = ({ onBack, onCheck }) => {
  const [input, setInput] = useState<string>('582');

  const handleNumClick = (num: string) => {
    if (input.length < 6) setInput(prev => prev + num);
  };

  const handleBackspace = () => {
    setInput(prev => prev.slice(0, -1));
  };

  const handleSubmit = () => {
    if (input.length === 6) {
      onCheck(input);
    }
  };

  return (
    <div className="min-h-screen bg-white flex flex-col">
      <header className="p-4 flex items-center relative justify-center">
        <button onClick={onBack} className="absolute left-4 p-2 text-primary hover:bg-primary/5 rounded-full">
          <span className="material-symbols-outlined font-bold">arrow_back_ios_new</span>
        </button>
        <h1 className="text-lg font-bold text-gray-900">检查我的彩票</h1>
      </header>

      <main className="flex-1 flex flex-col w-full max-w-md mx-auto">
        {/* Display Area */}
        <section className="py-8 px-6 flex flex-col items-center">
          <div className="text-royal-gold mb-8 flex items-center gap-2">
             <span className="material-symbols-outlined icon-filled text-lg">stars</span>
             <span className="text-xs font-bold tracking-[0.2em] uppercase">Royal Thai Lottery</span>
          </div>

          <div className="flex gap-2 mb-4">
             {[0, 1, 2, 3, 4, 5].map((i) => {
               const char = input[i];
               const isActive = !!char;
               return (
                 <div 
                    key={i} 
                    className={`w-12 h-16 rounded-2xl flex items-center justify-center text-3xl font-bold transition-all shadow-sm
                    ${isActive ? 'border-2 border-primary bg-primary/5 text-primary shadow-ios' : 'border border-gray-100 bg-gray-50 text-gray-300'}`}
                 >
                   {char || '_'}
                 </div>
               );
             })}
          </div>
          <p className="text-gray-400 text-sm font-medium">请输入您的 6 位彩票号码</p>
        </section>

        {/* Keypad */}
        <section className="flex-1 bg-gray-50 rounded-t-[2.5rem] p-8 shadow-inner border-t border-gray-100">
           <div className="grid grid-cols-3 gap-4 max-w-[320px] mx-auto pt-2">
              {[1, 2, 3, 4, 5, 6, 7, 8, 9].map((num) => (
                <button 
                  key={num}
                  onClick={() => handleNumClick(num.toString())}
                  className="aspect-square bg-white rounded-2xl text-2xl font-bold text-primary shadow-ios hover:bg-primary/5 active:scale-90 transition-all"
                >
                  {num}
                </button>
              ))}
              <button 
                onClick={handleBackspace}
                className="aspect-square bg-white rounded-2xl text-gray-400 shadow-ios hover:text-red-500 active:scale-90 transition-all flex items-center justify-center"
              >
                 <span className="material-symbols-outlined">backspace</span>
              </button>
              <button 
                onClick={() => handleNumClick('0')}
                className="aspect-square bg-white rounded-2xl text-2xl font-bold text-primary shadow-ios hover:bg-primary/5 active:scale-90 transition-all"
              >
                0
              </button>
              <button 
                onClick={handleSubmit}
                disabled={input.length !== 6}
                className={`aspect-square flex flex-col items-center justify-center rounded-2xl text-white shadow-ios active:scale-90 transition-all ${input.length === 6 ? 'bg-royal-gold' : 'bg-gray-300'}`}
              >
                <span className="material-symbols-outlined text-2xl mb-1">check_circle</span>
                <span className="text-[10px] font-bold">查询</span>
              </button>
           </div>

           <div className="mt-8 flex justify-center pb-8">
              <button className="w-full max-w-[320px] h-14 bg-gradient-to-r from-primary to-primary-dark text-white rounded-2xl font-bold flex items-center justify-center gap-3 shadow-lg shadow-primary/20 active:scale-[0.98] transition-all">
                <span className="material-symbols-outlined text-xl">qr_code_scanner</span>
                <span className="text-base">扫描彩票二维码</span>
              </button>
           </div>
        </section>
      </main>
    </div>
  );
};

export default CheckTicket;