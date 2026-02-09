"""
Thai Lottery 推送通知脚本
用于 GitHub Actions 自动推送开奖结果通知
"""
import os
import json
import datetime
import firebase_admin
from firebase_admin import credentials, messaging

# ==========================================
# Configuration
# ==========================================
FILE_PATH = 'lotto_results.json'

def send_push_notification(test_mode=False):
    """
    发送开奖结果通知 (支持中、泰、英三语)
    
    Args:
        test_mode: 如果为 True，跳过日期检查直接发送
    """
    # 严格从环境变量读取 (GitHub Actions 安全规范)
    service_account_info = os.environ.get('FIREBASE_SERVICE_ACCOUNT_KEY')

    if not service_account_info:
        print("Error: FIREBASE_SERVICE_ACCOUNT_KEY environment variable not set.")
        return False

    try:
        # 初始化 Firebase
        cert_dict = json.loads(service_account_info)
        cred = credentials.Certificate(cert_dict)
        if not firebase_admin._apps:
            firebase_admin.initialize_app(cred)

        # 读取最新开奖数据
        if not os.path.exists(FILE_PATH):
            print(f"Error: {FILE_PATH} not found.")
            return False
        
        with open(FILE_PATH, 'r', encoding='utf-8') as f:
            data = json.load(f)
            latest = data.get('latest', {})
            
            if not latest:
                print("Error: No 'latest' data found in JSON.")
                return False
            
            draw_date = latest.get('date', '')
            print(f"Found update for {draw_date}. Proceeding to send notifications...")

        # 彻底重构日期解析：从泰文佛历转换到公历/佛历
        # 原始格式示例: "1 กุมภาพันธ์ 2569"
        try:
            parts = draw_date.split()
            day = parts[0]
            month_th = parts[1]
            year_be = int(parts[2]) # 佛历年
            year_ad = year_be - 543  # 公历年
            
            thai_months_map = {
                "มกราคม": {"en": "Jan", "en_full": "January", "zh": "01月", "num": 1},
                "กุมภาพันธ์": {"en": "Feb", "en_full": "February", "zh": "02月", "num": 2},
                "มีนาคม": {"en": "Mar", "en_full": "March", "zh": "03月", "num": 3},
                "เมษายน": {"en": "Apr", "en_full": "April", "zh": "04月", "num": 4},
                "พฤษภาคม": {"en": "May", "en_full": "May", "zh": "05月", "num": 5},
                "มิถุนายน": {"en": "Jun", "en_full": "June", "zh": "06月", "num": 6},
                "กรกฎาคม": {"en": "Jul", "en_full": "July", "zh": "07月", "num": 7},
                "สิงหาคม": {"en": "Aug", "en_full": "August", "zh": "08月", "num": 8},
                "กันยายน": {"en": "Sep", "en_full": "September", "zh": "09月", "num": 9},
                "ตุลาคม": {"en": "Oct", "en_full": "October", "zh": "10月", "num": 10},
                "พฤศจิกายน": {"en": "Nov", "en_full": "November", "zh": "11月", "num": 11},
                "ธันวาคม": {"en": "Dec", "en_full": "December", "zh": "12月", "num": 12}
            }
            
            m_info = thai_months_map.get(month_th, {"en": "Jan", "zh": "01月", "num": 1})
            
            # 格式化日期 (Master Rules)
            # 中文: yyyy年MM月dd日
            date_zh = f"{year_ad}年{m_info['zh']}{int(day):02d}日"
            # 英文: MMM dd, yyyy
            date_en = f"{m_info['en']} {int(day):02d}, {year_ad}"
            # 泰语: 佛历
            date_th = draw_date
            
        except Exception as e:
            print(f"Date parsing failed, using fallback: {e}")
            date_zh, date_en, date_th = draw_date, draw_date, draw_date

        # 定义多语言推送任务
        tasks = [
            {
                "topic": "lottery_updates_zh",
                "title": "【Lotto Go】开奖结果更新 🎉",
                "body": f"泰国彩票 ({date_zh}) 已开奖，快来核对您的好运吧！"
            },
            {
                "topic": "lottery_updates_th",
                "title": "【Lotto Go】ผลสลากออกแล้ว 🎉",
                "body": f"สลากกินแบ่งรัฐบาล งวดวันที่ {date_th} ตรวจผลได้แล้ววันนี้!"
            },
            {
                "topic": "lottery_updates_en",
                "title": "【Lotto Go】Results Updated 🎉",
                "body": f"Thai Lottery ({date_en}) results are available now. Check yours!"
            }
        ]

        # 循环发送
        success_count = 0
        for task in tasks:
            try:
                message = messaging.Message(
                    notification=messaging.Notification(
                        title=task["title"],
                        body=task["body"],
                    ),
                    topic=task["topic"],
                    android=messaging.AndroidConfig(
                        priority='high',
                        notification=messaging.AndroidNotification(
                            channel_id='fcm_channel',
                            icon='launcher_icon',
                            sound='default'
                        )
                    )
                )
                response = messaging.send(message)
                print(f'Successfully sent to {task["topic"]}: {response}')
                success_count += 1
            except Exception as e:
                print(f'Failed to send to {task["topic"]}: {e}')

        print(f"\nTask Completed. Success: {success_count}/{len(tasks)}")
        return success_count > 0

    except Exception as e:
        print(f"Failed to send push notification: {e}")
        return False

if __name__ == "__main__":
    import sys
    is_test = "--test" in sys.argv
    success = send_push_notification(test_mode=is_test)
    exit(0 if success else 1)
