import requests
from bs4 import BeautifulSoup
import json
import os
from datetime import datetime

def scrape_lotto():
    url = "https://lotto.api.rayriffy.com/latest"
    print(f"Fetching data from API: {url}...")
    try:
        response = requests.get(url, timeout=15)
        response.raise_for_status()
        api_data = response.json()

        if api_data.get("status") != "success":
            raise Exception(f"API returned error: {api_data.get('status')}")

        res = api_data["response"]
        
        # 1. 提取核心奖项
        def find_prize(prize_id):
            for p in res.get("prizes", []):
                if p["id"] == prize_id:
                    return p["number"][0]
            return "N/A"

        def find_running(running_id):
            for r in res.get("runningNumbers", []):
                if r["id"] == running_id:
                    return ", ".join(r["number"])
            return "N/A"

        latest = {
            "date": res["date"],
            "number": res["prizes"][0]["number"][0], # 1st Prize
            "top3": find_running("runningNumberFrontThree"),
            "bottom3": find_running("runningNumberBackThree"),
            "bottom2": find_running("runningNumberBackTwo")
        }

        print(f"Mapped Data -> Date: {latest['date']}, 1st: {latest['number']}, 2-digit: {latest['bottom2']}")

        # 2. 构建历史记录
        # 由于 API `/latest` 只返回单条，这里暂时将最新一条放入历史
        # 如果需要完整历史，建议后续通过爬取 archive 页面来实现
        history = [latest]
        
        # 模拟一些历史数据以防列表为空 (实际运行中这里会逐渐累积)
        data = {
            "latest": latest,
            "history": history,
            "last_updated": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }

        with open('lotto_results.json', 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=4)
        print("Successfully updated lotto_results.json via API")
        
    except Exception as e:
        print(f"CRITICAL ERROR: {e}")
        raise e

if __name__ == "__main__":
    scrape_lotto()
