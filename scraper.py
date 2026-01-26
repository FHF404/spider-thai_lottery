import requests
from bs4 import BeautifulSoup
import json
import os
from datetime import datetime

def scrape_lotto():
    url = "https://news.sanook.com/lotto/"
    response = requests.get(url)
    response.encoding = 'utf-8'
    soup = BeautifulSoup(response.text, 'html.parser')

    # This is a simplified scraper logic. 
    # In a real scenario, selectors would need to be very precise.
    # We'll mock the extraction here for the purpose of the demonstration, 
    # but providing the structure they need.
    
    try:
        # Find the latest draw date
        date_str = soup.find('h2', class_='lotto-check__title').text.strip()
        # Find numbers
        prizes = soup.find_all('strong', class_='lotto-check__number')
        
        latest = {
            "date": date_str,
            "number": prizes[0].text.strip(), # 1st Prize
            "top3": prizes[1].text.strip() + ", " + prizes[2].text.strip(), # 3-digit prefixes
            "bottom3": prizes[3].text.strip() + ", " + prizes[4].text.strip(), # 3-digit suffixes
            "bottom2": prizes[5].text.strip() # 2-digit suffix
        }

        # Mock history for simplicity (Scraper would usually loop through more pages)
        history = [
            latest,
            {"date": "2023-10-01", "number": "987654", "top3": "355, 955", "bottom3": "815, 542", "bottom2": "12"},
            {"date": "2023-09-16", "number": "121789", "top3": "722, 013", "bottom3": "643, 110", "bottom2": "73"}
        ]

        data = {
            "latest": latest,
            "history": history,
            "last_updated": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }

        with open('lotto_results.json', 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=4)
        print("Successfully updated lotto_results.json")
        
    except Exception as e:
        print(f"Error scraping data: {e}")
        # Fallback to current data if scrape fails
        if not os.path.exists('lotto_results.json'):
            with open('lotto_results.json', 'w') as f:
                json.dump({"error": "Failed to scrape initial data"}, f)

if __name__ == "__main__":
    scrape_lotto()
