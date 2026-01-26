import requests
from bs4 import BeautifulSoup
import json
import os
from datetime import datetime

import re

def scrape_lotto():
    url = "https://news.sanook.com/lotto/"
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    }
    print(f"Fetching {url} with headers...")
    try:
        response = requests.get(url, headers=headers, timeout=15)
        response.encoding = 'utf-8'
        soup = BeautifulSoup(response.text, 'html.parser')

        # 1. 提取日期
        date_elem = soup.find('h2', class_='lotto-check__title')
        date_str = date_elem.text.strip() if date_elem else "未知日期"
        print(f"Detected Date: {date_str}")

        # 2. 提取各项奖项
        # Sanook 常用 ID: number1 (1st Prize), number2 (2-digit)
        prize1 = soup.find(id="number1") or soup.select_one('strong[data-prize="1"]')
        prize2 = soup.find(id="number2") or soup.select_one('strong[data-prize="2"]')
        
        def get_by_label(label_regex):
            # 使用正则匹配泰文标签，解决精确匹配失效问题
            label = soup.find(lambda tag: tag.name == "span" and re.search(label_regex, tag.text))
            if label:
                container = label.find_parent('div', class_='lotto-check__number')
                if not container:
                    # 尝试寻找兄弟节点中的 strong
                    container = label.find_next('div')
                
                if container:
                    nums = container.find_all('strong')
                    return ", ".join([n.text.strip() for n in nums if n.text.strip()])
                
                # 直接找后续的 strong
                next_strongs = label.find_all_next('strong', limit=2)
                return ", ".join([n.text.strip() for n in next_strongs])
            return "N/A"

        number = prize1.text.strip() if prize1 else "N/A"
        bottom2 = prize2.text.strip() if prize2 else "N/A"
        
        # 泰文匹配：เลขหน้า 3 ตัว (前3位), เลขท้าย 3 ตัว (后3位)
        top3 = get_by_label(r"เลขหน้า\s*3\s*ตัว")
        bottom3 = get_by_label(r"เลขท้าย\s*3\s*ตัว")

        print(f"Extracted -> 1st: {number}, 2-digit: {bottom2}, Top3: {top3}, Bottom3: {bottom3}")

        if number == "N/A" and bottom2 == "N/A":
            # 最后的尝试：按类名找 strong
            strongs = soup.find_all('strong', class_='lotto-check__number')
            if len(strongs) >= 6:
                number = strongs[0].text.strip()
                top3 = f"{strongs[1].text.strip()}, {strongs[2].text.strip()}"
                bottom3 = f"{strongs[3].text.strip()}, {strongs[4].text.strip()}"
                bottom2 = strongs[5].text.strip()
                print("Fallback to class-based selection worked.")
            else:
                raise Exception("Failed to find main prizes. HTML likely changed or blocks scraping.")

        latest = {
            "date": date_str,
            "number": number,
            "top3": top3,
            "bottom3": bottom3,
            "bottom2": bottom2
        }

        # 历史记录逻辑保持不变
        history = [latest]
        history_items = soup.find_all('div', class_='lotto-check__history-item', limit=10)
        for item in history_items:
            try:
                link = item.find('a')
                if not link: continue
                h_date = link.text.strip()
                h_nums = item.find_all('strong')
                if len(h_nums) >= 2:
                    history.append({
                        "date": h_date,
                        "number": h_nums[0].text.strip(),
                        "top3": "N/A",
                        "bottom3": "N/A",
                        "bottom2": h_nums[1].text.strip()
                    })
            except:
                continue

        data = {
            "latest": latest,
            "history": history,
            "last_updated": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }

        with open('lotto_results.json', 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=4)
        print("Successfully updated lotto_results.json")
        
    except Exception as e:
        print(f"CRITICAL ERROR: {e}")
        raise e

if __name__ == "__main__":
    scrape_lotto()
