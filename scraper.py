import requests
from bs4 import BeautifulSoup
import json
import os
from datetime import datetime

def scrape_lotto():
    url = "https://news.sanook.com/lotto/"
    print(f"Fetching {url}...")
    try:
        response = requests.get(url, timeout=15)
        response.encoding = 'utf-8'
        soup = BeautifulSoup(response.text, 'html.parser')

        # 1. 提取日期
        date_elem = soup.find('h2', class_='lotto-check__title')
        date_str = date_elem.text.strip() if date_elem else "未知日期"
        print(f"Detected Date: {date_str}")

        # 2. 提取各项奖项
        # 尝试通过 ID 查找 (Sanook 常用 ID)
        prize1 = soup.find(id="number1")
        prize2 = soup.find(id="number2")
        
        # 3位前缀/后缀通常在特定的区块中
        def get_by_label(label_text):
            label = soup.find(lambda tag: tag.name == "span" and label_text in tag.text)
            if label:
                # 通常数字在 label 的后续节点或父节点的特定子节点中
                container = label.find_parent('div', class_='lotto-check__number')
                if container:
                    nums = container.find_all('strong')
                    return ", ".join([n.text.strip() for n in nums])
            return "N/A"

        number = prize1.text.strip() if prize1 else "N/A"
        bottom2 = prize2.text.strip() if prize2 else "N/A"
        top3 = get_by_label("เลขหน้า 3 ตัว")
        bottom3 = get_by_label("เลขท้าย 3 ตัว")

        print(f"Data: {number}, {bottom2}, {top3}, {bottom3}")

        if number == "N/A" and bottom2 == "N/A":
            raise Exception("Failed to find main prizes. Structure might have changed.")

        latest = {
            "date": date_str,
            "number": number,
            "top3": top3,
            "bottom3": bottom3,
            "bottom2": bottom2
        }

        # 构建历史记录 (暂时用 Latest 填充，实际应从历史列表爬取)
        history = [latest]
        
        # 尝试从历史链接列表中提取前几个
        history_items = soup.find_all('div', class_='lotto-check__history-item', limit=10)
        for item in history_items:
            try:
                h_date = item.find('a').text.strip()
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
        # 输出部分 HTML 以便在 GitHub Logs 中分析
        if 'response' in locals():
            print("HTML Snippet:")
            print(response.text[:1000])
        raise e

if __name__ == "__main__":
    scrape_lotto()
