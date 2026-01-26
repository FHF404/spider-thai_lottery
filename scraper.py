import requests
from bs4 import BeautifulSoup
import json
import os
from datetime import datetime

import time

def scrape_lotto():
    base_url = "https://lotto.api.rayriffy.com"
    file_path = 'lotto_results.json'
    
    def is_valid(item):
        # 检查所有核心字段是否包含 'x'
        content = f"{item.get('number', '')}{item.get('top3', '')}{item.get('bottom3', '')}{item.get('bottom2', '')}".lower()
        return 'x' not in content and 'n/a' not in content

    # 1. 尝试加载现有数据
    existing_data = None
    if os.path.exists(file_path):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                existing_data = json.load(f)
        except: pass

    # 2. 尝试执行增量更新 (仅当已有 48 条以上有效数据时)
    if existing_data and "history" in existing_data and len(existing_data["history"]) >= 48:
        print("Existing valid history found. Checking for new draw...")
        try:
            resp = requests.get(f"{base_url}/latest", timeout=15)
            api_data = resp.json()["response"]
            
            def find_run(runs, rid):
                return next((", ".join(n["number"]) for n in runs if n["id"] == rid), "N/A")

            prizes = api_data.get("prizes", [])
            runs = api_data.get("runningNumbers", [])
            new_item = {
                "date": api_data["date"],
                "number": prizes[0]["number"][0] if prizes else "N/A",
                "top3": find_run(runs, "runningNumberFrontThree"),
                "bottom3": find_run(runs, "runningNumberBackThree"),
                "bottom2": find_run(runs, "runningNumberBackTwo")
            }
            
            if is_valid(new_item):
                if existing_data["history"][0]["date"] != new_item["date"]:
                    print(f"New valid draw found: {new_item['date']}")
                    updated_data = {
                        "latest": new_item,
                        "history": ([new_item] + existing_data["history"])[:100],
                        "last_updated": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                    }
                    with open(file_path, 'w', encoding='utf-8') as f:
                        json.dump(updated_data, f, ensure_ascii=False, indent=4)
                else:
                    print("Already up to date.")
                return
            else:
                print("Latest result from API is still pending (contains X). Skipping update.")
                return
        except Exception as e:
            print(f"Incremental update error: {e}")

    # 3. 全量抓取逻辑 (初始化或数据不足时)
    print("Performing full historical fetch and filtering...")
    try:
        all_draw_ids = []
        for page in range(1, 5):
            resp = requests.get(f"{base_url}/list/{page}", timeout=10)
            if resp.status_code == 200:
                all_draw_ids.extend([item["id"] for item in resp.json()["response"]])
            time.sleep(0.5)

        history = []
        for draw_id in all_draw_ids[:55]:
            try:
                resp = requests.get(f"{base_url}/lotto/{draw_id}", timeout=10)
                res = resp.json()["response"]
                def f_p(p, i): return next((n["number"][0] for n in p if n["id"] == i), "N/A")
                def f_r(r, i): return next((", ".join(n["number"]) for n in r if n["id"] == i), "N/A")

                item = {
                    "date": res["date"],
                    "number": f_p(res.get("prizes", []), "prizeFirst"),
                    "top3": f_r(res.get("runningNumbers", []), "runningNumberFrontThree"),
                    "bottom3": f_r(res.get("runningNumbers", []), "runningNumberBackThree"),
                    "bottom2": f_r(res.get("runningNumbers", []), "runningNumberBackTwo")
                }
                if is_valid(item):
                    history.append(item)
                time.sleep(0.2)
            except: pass

        if history:
            # 确保 latest 是历史中最新的一条有效数据
            data = {
                "latest": history[0],
                "history": history,
                "last_updated": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            }
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=4)
            print(f"Successfully saved {len(history)} valid entries.")
            
    except Exception as e:
        print(f"CRITICAL ERROR: {e}")
        raise e

if __name__ == "__main__":
    scrape_lotto()
