import React from 'react';
import { ViewState } from '../types';

interface BottomNavProps {
  currentView: ViewState;
  onChange: (view: ViewState) => void;
}

const BottomNav: React.FC<BottomNavProps> = ({ currentView, onChange }) => {
  // Determine which tab should appear active based on current view
  const activeTab = (() => {
    if (currentView === 'profile') return 'profile';
    if (currentView === 'history') return 'history';
    if (currentView === 'generator') return 'generator';
    // For other views (home, check, results), we consider them under the "Home" context
    return 'home';
  })();

  return (
    <nav className="fixed bottom-0 max-w-[480px] w-full bg-white border-t border-gray-100 pb-6 pt-2 z-50 shadow-[0_-4px_20px_rgba(0,0,0,0.03)]">
      <div className="flex justify-around items-center h-14">
        <NavButton 
          isActive={activeTab === 'home'} 
          onClick={() => onChange('home')} 
          icon="home" 
          label="主页" 
        />
        <NavButton 
          isActive={activeTab === 'history'} 
          onClick={() => onChange('history')} 
          icon="history" 
          label="历史" 
        />
        <NavButton 
          isActive={activeTab === 'generator'} 
          onClick={() => onChange('generator')} 
          icon="casino" 
          label="选号" 
        />
        <NavButton 
          isActive={activeTab === 'profile'} 
          onClick={() => onChange('profile')} 
          icon="person" 
          label="我的" 
        />
      </div>
    </nav>
  );
};

interface NavButtonProps {
  isActive: boolean;
  onClick: () => void;
  icon: string;
  label: string;
}

const NavButton: React.FC<NavButtonProps> = ({ isActive, onClick, icon, label }) => (
  <button 
    onClick={onClick}
    className={`flex flex-col items-center justify-center w-20 relative transition-all duration-300 ${isActive ? 'text-primary' : 'text-gray-400 hover:text-gray-600'}`}
  >
    {isActive && (
      <span className="absolute -top-2 w-1.5 h-1.5 bg-[#FFD700] rounded-full shadow-[0_0_8px_rgba(255,215,0,0.6)] animate-in fade-in zoom-in duration-300"></span>
    )}
    <span className={`material-symbols-outlined text-[28px] mb-1 ${isActive ? 'icon-filled' : ''}`}>
      {icon}
    </span>
    <span className={`text-[10px] font-bold ${isActive ? 'scale-105' : ''}`}>
      {label}
    </span>
  </button>
);

export default BottomNav;