import requests
from bs4 import BeautifulSoup
import json
import os
from datetime import datetime

import time

def scrape_lotto():
    base_url = "https://lotto.api.rayriffy.com"
    file_path = 'lotto_results.json'
    
    # 1. 尝试加载现有数据
    existing_data = None
    if os.path.exists(file_path):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                existing_data = json.load(f)
        except:
            print("Could not read existing lotto_results.json")

    # 2. 只有当现有数据已经包含足够多的历史（比如 48 期，约 24 个月）时，才执行增量更新
    # 否则，强制执行一次全量抓取来补齐历史数据
    if existing_data and "history" in existing_data and len(existing_data["history"]) >= 48:
        print(f"History has {len(existing_data['history'])} entries. Performing incremental update...")
        try:
            latest_url = f"{base_url}/latest"
            resp = requests.get(latest_url, timeout=15)
            resp.raise_for_status()
            api_data = resp.json()["response"]
            
            latest_date = api_data["date"]
            if existing_data["history"][0]["date"] == latest_date:
                print(f"Latest draw ({latest_date}) already exists. No update.")
                return

            def find_run(runs, rid):
                return next((", ".join(n["number"]) for n in runs if n["id"] == rid), "N/A")

            prizes = api_data.get("prizes", [])
            runs = api_data.get("runningNumbers", [])
            
            new_item = {
                "date": latest_date,
                "number": prizes[0]["number"][0] if prizes else "N/A",
                "top3": find_run(runs, "runningNumberFrontThree"),
                "bottom3": find_run(runs, "runningNumberBackThree"),
                "bottom2": find_run(runs, "runningNumberBackTwo")
            }
            
            new_history = [new_item] + existing_data["history"]
            final_history = new_history[:100] # 最多保留 100 期
            
            updated_data = {
                "latest": new_item,
                "history": final_history,
                "last_updated": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            }
            
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(updated_data, f, ensure_ascii=False, indent=4)
            print(f"Added new draw: {latest_date}")
            return
            
        except Exception as e:
            print(f"Incremental update failed: {e}. Falling back to full fetch.")

    # 3. 全量抓取逻辑 (初次运行或历史不全时触发)
    print("Performing full historical fetch (Target: 24 months/50 draws)...")
    try:
        all_draw_ids = []
        # 抓取前 4 页列表以获取足够的 ID
        for page in range(1, 5):
            list_url = f"{base_url}/list/{page}"
            resp = requests.get(list_url, timeout=10)
            if resp.status_code == 200:
                page_data = resp.json()
                if page_data.get("status") == "success":
                    all_draw_ids.extend([item["id"] for item in page_data["response"]])
            time.sleep(0.5)

        target_ids = all_draw_ids[:55] # 抓取 55 条确保至少有 50 条成功
        history = []
        for i, draw_id in enumerate(target_ids):
            print(f"[{i+1}/{len(target_ids)}] Fetching detail: {draw_id}")
            detail_url = f"{base_url}/lotto/{draw_id}"
            try:
                resp = requests.get(detail_url, timeout=10)
                if resp.status_code == 200:
                    res = resp.json()["response"]
                    def find_prize(p, pid):
                        return next((n["number"][0] for n in p if n["id"] == pid), "N/A")
                    def find_run(r, rid):
                        return next((", ".join(n["number"]) for n in r if n["id"] == rid), "N/A")

                    history.append({
                        "date": res["date"],
                        "number": find_prize(res.get("prizes", []), "prizeFirst"),
                        "top3": find_run(res.get("runningNumbers", []), "runningNumberFrontThree"),
                        "bottom3": find_run(res.get("runningNumbers", []), "runningNumberBackThree"),
                        "bottom2": find_run(res.get("runningNumbers", []), "runningNumberBackTwo")
                    })
                time.sleep(0.2)
            except Exception: pass

        if history:
            data = {
                "latest": history[0],
                "history": history,
                "last_updated": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            }
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=4)
            print(f"Full fetch complete: {len(history)} entries saved.")
            
    except Exception as e:
        print(f"CRITICAL ERROR: {e}")
        raise e

if __name__ == "__main__":
    scrape_lotto()
