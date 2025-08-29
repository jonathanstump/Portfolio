import requests

SERVER_URL = "http://YOUR_VPS_IP:5000/api/upload"  # change port if needed
PHOTO_PATH = "/home/pi/cam/latest.jpg"  # local photo path

data = {
    "schoolId": "GHV",   # or whatever identifier you’re using
    "week": "2"
}

files = {
    "photo": open(PHOTO_PATH, "rb")
}

resp = requests.post(SERVER_URL, data=data, files=files)
print(resp.status_code, resp.json())
