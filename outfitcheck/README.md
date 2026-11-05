# OutfitCheck

แอปแนะนำการแต่งตัว สร้างด้วย Flutter และรองรับการ build เป็นเว็บไซต์

## รันเว็บในเครื่อง

```powershell
flutter run -d chrome
```

## Deploy เว็บไป Firebase Hosting

ติดตั้ง Node.js และ Flutter ก่อน จากนั้นเปิด PowerShell ที่โฟลเดอร์โปรเจกต์ `outfitcheck` แล้วล็อกอิน Firebase (ทำครั้งแรกครั้งเดียว):

```powershell
npx firebase-tools login
```

Build และ deploy เว็บ:

```powershell
flutter build web --release
npx firebase-tools deploy --only hosting
```

ไฟล์ `firebase.json` ตั้งค่าให้ deploy จาก `build/web` และ `.firebaserc` เลือก Firebase project `project-outfitcheck` ไว้แล้ว ไม่ต้องใส่ Firebase token หรือข้อมูลล็อกอินลงใน Git
