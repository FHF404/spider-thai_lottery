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

        # 日期本地化逻辑：尝试将泰文月份转换为中/英
        thai_months = {
            "มกราคม": ("January", "1月"), "กุมภาพันธ์": ("February", "2月"), "มีนาคม": ("March", "3月"),
            "เมษายน": ("April", "4月"), "พฤษภาคม": ("May", "5月"), "มิถุนายน": ("June", "6月"),
            "กรกฎาคม": ("July", "7月"), "สิงหาคม": ("August", "8月"), "กันยายน": ("September", "9月"),
            "ตุลาคม": ("October", "10月"), "พฤศจิกายน": ("November", "11月"), "ธันวาคม": ("December", "12月")
        }
        
        # 默认使用原始日期
        date_zh, date_en, date_th = draw_date, draw_date, draw_date
        
        for th_m, (en_m, zh_m) in thai_months.items():
            if th_m in draw_date:
                date_en = draw_date.replace(th_m, en_m)
                date_zh = draw_date.replace(th_m, zh_m)
                break

        # 定义多语言推送任务 (移除通用的 lottery_updates，防止重复)
        tasks = [
            {
                "topic": "lottery_updates_zh",
                "title": "【Lotto Go】开奖结果更新 🎉",
                "body": f"泰国彩票 ({date_zh}) 已开奖，快来查看您的好运吧！"
            },
            {
                "topic": "lottery_updates_th",
                "title": "【Lotto Go】ผลสลากออกแล้ว 🎉",
                "body": f"สลากกินแบ่งรัฐบาล งวดวันที่ {date_th} ตรวจผลได้แล้ววันนี้!"
            },
            {
                "topic": "lottery_updates_en",
                "title": "【Lotto Go】Results Updated 🎉",
                "body": f"Thai Lottery ({date_en}) results are now available. Check your luck!"
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
