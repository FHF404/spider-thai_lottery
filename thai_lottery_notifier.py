import json
import os
import requests
from google.oauth2 import service_account
from google.auth.transport.requests import Request
from datetime import datetime

# ==========================================
# Configuration
# ==========================================
FILE_PATH = 'lotto_results.json'

def send_push_notifications():
    # 1. Load latest data from JSON
    if not os.path.exists(FILE_PATH):
        print(f"Error: {FILE_PATH} not found. Cannot send notifications.")
        return

    try:
        with open(FILE_PATH, 'r', encoding='utf-8') as f:
            data = json.load(f)
            latest = data.get("latest", {})
            if not latest:
                print("Error: No 'latest' data found in JSON.")
                return
    except Exception as e:
        print(f"Error reading {FILE_PATH}: {e}")
        return

    # 2. Get Service Account from environment
    service_account_info = os.environ.get('FIREBASE_SERVICE_ACCOUNT_KEY')
    if not service_account_info:
        print("Error: FIREBASE_SERVICE_ACCOUNT_KEY environment variable is not set.")
        return

    try:
        info = json.loads(service_account_info)
    except Exception as e:
        print(f"Error parsing service account JSON: {e}")
        return

    # 3. Authenticate with Firebase
    try:
        scopes = ['https://www.googleapis.com/auth/firebase.messaging']
        creds = service_account.Credentials.from_service_account_info(info, scopes=scopes)
        creds.refresh(Request())
        token = creds.token
        project_id = info.get('project_id')
    except Exception as e:
        print(f"Authentication failed: {e}")
        return

    # 4. Define multi-language notification payloads
    # Using the date from latest data to make it dynamic if needed
    draw_date = latest.get("date", "")
    
    notifications = [
        {
            "topic": "lottery_updates_zh",
            "title": "🎉 泰国彩票开奖结果已更新！",
            "body": f"最新内容 ({draw_date}) 已上线，快来核对您的好运吧！🔔"
        },
        {
            "topic": "lottery_updates_th",
            "title": "🎉 ผลสลากกินแบ่งรัฐบาลออกแล้ว!",
            "body": f"อัปเดตงวดวันที่ {draw_date} แล้ว ตรวจหวยของคุณได้เลยที่นี่! 🔔"
        },
        {
            "topic": "lottery_updates_en",
            "title": "🎉 Thai Lottery Results Updated!",
            "body": f"New draw results for {draw_date} are live. Check yours now! 🔔"
        },
        {
            "topic": "lottery_updates",
            "title": "🎉 Lotto Results Updated!",
            "body": f"New draw data for {draw_date} is available now! 🔔"
        }
    ]

    # 5. Send messages via FCM V1 API
    url = f'https://fcm.googleapis.com/v1/projects/{project_id}/messages:send'
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }

    # --- [DEBUG] 精准推送测试 ---
    debug_token = "fSUT1Ji6RFqujjEaj5FnOy:APA91bEowKyDrNxS7SjLpzEuluhq_rDBuVuB-fAIlZF1E38ElSMdJ3PLQVnPmEfk9_PkPLinEIGC4mGJw9mCWMwRFBFEoDea4MtzQ3LsJZzhL9h6WgpKwMY"
    debug_body = {
        "message": {
            "token": debug_token,
            "notification": {
                "title": "🚀 精准打击测试 (Token)",
                "body": f"如果你看到这条，说明 Firebase 密钥和项目 ID 是对的！时间: {datetime.now().strftime('%H:%M:%S')}"
            },
            "android": {
                "priority": "HIGH",
                "notification": {
                    "channel_id": "fcm_channel",
                    "click_action": "FLUTTER_NOTIFICATION_CLICK"
                }
            }
        }
    }
    
    try:
        resp = requests.post(url, headers=headers, data=json.dumps(debug_body))
        print(f"🎯 [DEBUG] Token Test Result: {resp.status_code}")
    except Exception as e:
        print(f"❌ [DEBUG] Token Test Failed: {e}")
    # --- [DEBUG END] ---

    print(f"[{datetime.now()}] Starting topic distribution...")
    for item in notifications:
        body = {
            "message": {
                "topic": item["topic"],
                "notification": {
                    "title": item["title"],
                    "body": item["body"]
                },
                "data": {
                    "title": item["title"],
                    "body": item["body"],
                    "type": "lottery_update",
                    "click_action": "FLUTTER_NOTIFICATION_CLICK"
                },
                "android": {
                    "priority": "HIGH",
                    "notification": {
                        "channel_id": "fcm_channel",
                        "click_action": "FLUTTER_NOTIFICATION_CLICK",
                        "sound": "default",
                        "notification_priority": "PRIORITY_MAX"
                    }
                }
            }
        }

        try:
            response = requests.post(url, headers=headers, json=body, timeout=20)
            if response.status_code == 200:
                print(f"✅ Sent to {item['topic']}: {response.status_code}")
            else:
                print(f"❌ Failed for {item['topic']}: {response.status_code} - {response.text}")
        except Exception as e:
            print(f"⚠️ Exception sending to {item['topic']}: {e}")

    print("Notification process completed.")

if __name__ == "__main__":
    send_push_notifications()
