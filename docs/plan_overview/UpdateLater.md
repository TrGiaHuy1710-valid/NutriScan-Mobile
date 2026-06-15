Hiện tại nếu nói theo **plan HealTrack** thì dự án **chưa có API key thật**, vì mới ở mức:

```text
One-page plan
→ MVP scope
→ UI-first
→ Mock data
→ Vertical slice
→ Sau đó mới backend/API thật
```

Còn nếu dựa theo logic repo Mental Health trước đó, file phân tích có ghi: README có nhắc **Gemini, Firebase, Node.js, PostgreSQL**, nhưng trong workspace chưa thấy backend thật, chưa thấy implementation Gemini rõ ràng; Flutter hiện đang gọi API local `http://localhost:6000`.

## 1. Các API/key có thể cần trong dự án HealTrack

Dự án của bạn có thể cần các key/token sau:

```text
Google Sign-In / Google Calendar
Firebase nếu dùng Auth/Firestore/Storage
Gemini hoặc OpenAI nếu dùng AI scan món ăn
Nutrition API nếu dùng database calo bên ngoài
Open Food Facts nếu dùng barcode/product data
```

Nhưng lưu ý:

```text
Open Food Facts thường không cần API key cho read public product data.
Google Calendar dùng OAuth client/config, không đơn giản chỉ là API key.
Gemini/OpenAI key là secret, không được để trong Flutter app.
Firebase config không hoàn toàn là secret, nhưng vẫn cần bảo vệ bằng Security Rules.
```

---

## 2. Có nên để trong `.env` không?

Có, nhưng phải chia rõ:

## Frontend Flutter `.env`

Chỉ nên để config **không quá nhạy cảm**:

```env
API_BASE_URL=http://localhost:8000
APP_ENV=dev
GOOGLE_WEB_CLIENT_ID=xxx.apps.googleusercontent.com
FIREBASE_PROJECT_ID=your-project-id
```

Không nên để:

```env
GEMINI_API_KEY=...
OPENAI_API_KEY=...
DATABASE_URL=...
SERVICE_ACCOUNT_KEY=...
JWT_SECRET=...
```

Vì app mobile/web có thể bị unpack/decompile, nên key nhạy cảm trong Flutter **không an toàn**.

---

## Backend `.env`

Các key nhạy cảm phải để ở backend:

```env
DATABASE_URL=postgresql://user:password@localhost:5432/healtrack
JWT_SECRET=your_jwt_secret
GEMINI_API_KEY=your_gemini_key
OPENAI_API_KEY=your_openai_key
GOOGLE_CLIENT_SECRET=your_google_client_secret
FIREBASE_SERVICE_ACCOUNT_PATH=./service-account.json
```

Backend sẽ đứng giữa:

```text
Flutter App
→ Backend API
→ Gemini/OpenAI/Database/Google API
```

Không để app gọi trực tiếp AI provider bằng secret key.

---

## 3. Cấu trúc env nên dùng

```text
project/
  apps/
    mobile/
      .env.example
      .env              # không commit
    api/
      .env.example
      .env              # không commit

  .gitignore
```

`.gitignore` nên có:

```gitignore
.env
.env.*
!.env.example

*.pem
*.key
service-account.json
firebase-adminsdk*.json
```

---

## 4. File `.env.example` nên commit

Frontend:

```env
API_BASE_URL=http://localhost:8000
APP_ENV=dev
GOOGLE_WEB_CLIENT_ID=replace_me
FIREBASE_PROJECT_ID=replace_me
```

Backend:

```env
PORT=8000
DATABASE_URL=replace_me
JWT_SECRET=replace_me
GEMINI_API_KEY=replace_me
GOOGLE_CLIENT_ID=replace_me
GOOGLE_CLIENT_SECRET=replace_me
```

`.env.example` được commit để người khác biết cần biến gì, còn `.env` thật thì không commit.

---

## 5. Kết luận cho dự án của bạn

Với HealTrack, hướng đúng là:

```text
MVP v0/v1:
Không cần API key thật
Dùng fake data/mock repository

MVP v1.3:
Backend có .env
Database URL để backend giữ

MVP v2:
Google Calendar OAuth
Gemini/OpenAI key chỉ để backend
Open Food Facts gọi từ backend hoặc frontend đều được, vì thường không cần secret
```

Câu trả lời ngắn gọn:

```text
Hiện plan chưa cần API key thật.
Sau này có key thì phải để trong .env.
Key nhạy cảm chỉ đặt ở backend.
Flutter chỉ giữ public config, không giữ Gemini/OpenAI/DB secret.
```
