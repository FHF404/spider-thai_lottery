import requests
from bs4 import BeautifulSoup
import json
import os
from datetime import datetime
import time
import random
from urllib3.util.retry import Retry
from requests.adapters import HTTPAdapter

# ==========================================
# Configuration & Constants
# ==========================================
BASE_URL = "https://lotto.api.rayriffy.com"
FILE_PATH = 'lotto_results.json'

# Anti-Scraping Headers
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Referer": "https://lotto.api.rayriffy.com/",
    "Accept-Language": "en-US,en;q=0.9,th;q=0.8,zh-CN;q=0.7,zh;q=0.6"
}

# ==========================================
# Helper Functions
# ==========================================

def get_session():
    """Create a requests session with retry mechanism."""
    session = requests.Session()
    retry = Retry(
        total=3,
        backoff_factor=1,
        status_forcelist=[429, 500, 502, 503, 504],
        allowed_methods=["GET"]
    )
    adapter = HTTPAdapter(max_retries=retry)
    session.mount("http://", adapter)
    session.mount("https://", adapter)
    session.headers.update(HEADERS)
    return session

def is_valid_result(item):
    """
    Validate data integrity.
    Checks if critical fields are present and do not contain placeholders.
    """
    if not item:
        return False
        
    required_fields = ['date', 'number', 'top3', 'bottom3', 'bottom2']
    for field in required_fields:
        val = str(item.get(field, '')).strip().lower()
        if not val or val in ['n/a', 'nan', 'null', 'x', 'xx', 'xxx']:
            return False
            
    # Additional logic: 'number' should be 6 digits (for Thai Lottery First Prize)
    # But some APIs might return comma separated if multiple, so we just check it's not empty/placeholder
    return True

def find_running_number(runs, rid):
    """Extraction helper for running numbers from API response."""
    for n in runs:
        if n.get("id") == rid:
            return ", ".join(n.get("number", []))
    return "N/A"

# ==========================================
# Phase A: Data Fetcher Logic
# ==========================================

def run_scraper():
    session = get_session()
    
    # 1. Load existing data
    existing_data = {}
    if os.path.exists(FILE_PATH):
        try:
            with open(FILE_PATH, 'r', encoding='utf-8') as f:
                existing_data = json.load(f)
        except Exception as e:
            print(f"Warning: Failed to load existing data: {e}")

    print(f"[{datetime.now()}] Checking for latest draw updates...")
    
    try:
        # Check latest first (Incremental Update Strategy)
        resp = session.get(f"{BASE_URL}/latest", timeout=15)
        resp.raise_for_status()
        api_data = resp.json().get("response", {})
        
        prizes = api_data.get("prizes", [])
        runs = api_data.get("runningNumbers", [])
        
        new_item = {
            "date": api_data.get("date"),
            "number": prizes[0]["number"][0] if prizes and prizes[0].get("number") else "N/A",
            "top3": find_running_number(runs, "runningNumberFrontThree"),
            "bottom3": find_running_number(runs, "runningNumberBackThree"),
            "bottom2": find_running_number(runs, "runningNumberBackTwo")
        }
        
        # Data Integrity Check
        if not is_valid_result(new_item):
            print("Latest result is incomplete or pending. Skipping update.")
            return

        # Check if actually new
        last_history_date = ""
        if existing_data and "history" in existing_data and len(existing_data["history"]) > 0:
            last_history_date = existing_data["history"][0].get("date")

        if new_item["date"] == last_history_date:
            print(f"Data for {new_item['date']} is already cached. No changes needed.")
            return

        print(f"Found new valid draw: {new_item['date']}")
        
        # Construct updated dataset
        history = existing_data.get("history", [])
        # Insert at top and keep last 100
        updated_history = ([new_item] + history)[:100]
        
        final_data = {
            "latest": new_item,
            "history": updated_history,
            "last_updated": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        
        # Final safety check: don't overwrite with empty history if something went wrong
        if not final_data["history"]:
            print("Error: Generated history is empty. Aborting write.")
            return
            
        with open(FILE_PATH, 'w', encoding='utf-8') as f:
            json.dump(final_data, f, ensure_ascii=False, indent=4)
            
        print(f"Successfully updated {FILE_PATH} with new data for {new_item['date']}.")

    except Exception as e:
        print(f"CRITICAL ERROR in Phase A: {e}")
        # Re-raise to let GitHub Action know it failed
        raise e

if __name__ == "__main__":
    run_scraper()
