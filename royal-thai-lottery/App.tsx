import React, { useState } from 'react';
import { ViewState } from './types';
import Home from './pages/Home';
import Profile from './pages/Profile';
import CheckTicket from './pages/CheckTicket';
import Result from './pages/Result';
import Generator from './pages/Generator';
import History from './pages/History';
import SavedTickets from './pages/SavedTickets';
import BottomNav from './components/BottomNav';

const App: React.FC = () => {
  const [currentView, setCurrentView] = useState<ViewState>('home');

  // Logic to simulate checking ticket result
  const handleCheckTicket = (number: string) => {
    // Simple logic: if ends in 6, win. Else loss.
    if (number === '123456' || number.endsWith('6')) {
      setCurrentView('result_win');
    } else {
      setCurrentView('result_loss');
    }
  };

  const renderContent = () => {
    switch (currentView) {
      case 'home':
        return (
          <Home 
            onCheckTicket={() => setCurrentView('check')} 
            onViewHistory={() => setCurrentView('history')}
            onOpenGenerator={() => setCurrentView('generator')}
          />
        );
      case 'history':
        return <History onBack={() => setCurrentView('home')} />;
      case 'profile':
        return <Profile onChangeView={setCurrentView} />;
      case 'saved_tickets':
        return <SavedTickets onBack={() => setCurrentView('profile')} />;
      case 'check':
        return <CheckTicket onBack={() => setCurrentView('home')} onCheck={handleCheckTicket} />;
      case 'result_win':
        return <Result status="win" onBack={() => setCurrentView('check')} onTryAgain={() => setCurrentView('check')} />;
      case 'result_loss':
        return <Result status="loss" onBack={() => setCurrentView('check')} onTryAgain={() => setCurrentView('check')} />;
      case 'generator':
        return <Generator />;
      default:
        return (
          <Home 
            onCheckTicket={() => setCurrentView('check')} 
            onViewHistory={() => setCurrentView('history')}
            onOpenGenerator={() => setCurrentView('generator')}
          />
        );
    }
  };

  const showBottomNav = ['home', 'history', 'profile', 'generator'].includes(currentView);

  return (
    <div className="min-h-screen relative font-sans bg-background">
      {renderContent()}
      
      {showBottomNav && (
        <BottomNav 
          currentView={currentView} 
          onChange={setCurrentView} 
        />
      )}
    </div>
  );
};

export default App;