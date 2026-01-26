import requests
from bs4 import BeautifulSoup
import json
import os
from datetime import datetime

import time

def scrape_lotto():
    base_url = "https://lotto.api.rayriffy.com"
    print("Fetching historical draw list...")
    
    try:
        # 1. 获取最近的开奖列表 (第1页通常包含最近的 15-20 条)
        # 我们需要约 48 条 (24个月)，所以抓取前 3 页
        all_draw_ids = []
        for page in range(1, 4):
            list_url = f"{base_url}/list/{page}"
            resp = requests.get(list_url, timeout=10)
            if resp.status_code == 200:
                page_data = resp.json()
                if page_data.get("status") == "success":
                    all_draw_ids.extend([item["id"] for item in page_data["response"]])
            time.sleep(0.5) # 稍微延迟避免频率限制

        print(f"Total historical IDs found: {len(all_draw_ids)}")
        
        # 限制为最近的 50 条 (约 25 个月)
        target_ids = all_draw_ids[:50]
        history = []

        # 2. 循环获取每条开奖的详细信息
        for i, draw_id in enumerate(target_ids):
            print(f"[{i+1}/{len(target_ids)}] Fetching detail for ID: {draw_id}")
            detail_url = f"{base_url}/lotto/{draw_id}"
            
            try:
                resp = requests.get(detail_url, timeout=10)
                if resp.status_code == 200:
                    res = resp.json()["response"]
                    
                    def find_prize(prizes, pid, idx=0):
                        for p in prizes:
                            if p["id"] == pid: return p["number"][idx]
                        return "N/A"

                    def find_run(runs, rid):
                        for r in runs:
                            if r["id"] == rid: return ", ".join(r["number"])
                        return "N/A"

                    prizes = res.get("prizes", [])
                    runs = res.get("runningNumbers", [])
                    
                    item = {
                        "date": res["date"],
                        "number": find_prize(prizes, "prizeFirst"),
                        "top3": find_run(runs, "runningNumberFrontThree"),
                        "bottom3": find_run(runs, "runningNumberBackThree"),
                        "bottom2": find_run(runs, "runningNumberBackTwo")
                    }
                    history.append(item)
                
                time.sleep(0.3) # 减缓采集频率
            except Exception as inner_e:
                print(f"Error fetching {draw_id}: {inner_e}")

        if not history:
            raise Exception("No history could be fetched.")

        # 3. 组织最终数据
        latest = history[0]
        data = {
            "latest": latest,
            "history": history,
            "last_updated": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }

        # 4. 保存
        with open('lotto_results.json', 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=4)
        print(f"Successfully updated lotto_results.json with {len(history)} entries.")
        
    except Exception as e:
        print(f"CRITICAL ERROR: {e}")
        raise e

if __name__ == "__main__":
    scrape_lotto()
