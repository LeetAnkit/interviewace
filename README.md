# AI Interview Coach

A complete AI-powered interview coaching application with Flutter frontend and Python Flask backend.

## 📁 Project Structure

```
ai-interview-coach/
├── 📱 frontend/                    ← Flutter Mobile App
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/
│   │   ├── services/
│   │   ├── models/
│   │   └── widgets/
│   ├── pubspec.yaml
│   └── ...
│
└── 🔧 backend/                     ← Python Flask API
    ├── app.py
    ├── requirements.txt
    ├── .env.example
    ├── services/
    │   ├── transcription_service.py
    │   ├── analysis_service.py
    │   ├── database_service.py
    │   └── auth_service.py
    ├── utils/
    │   ├── validators.py
    │   └── error_handlers.py
    └── scripts/
        ├── setup_firebase.py
        └── test_endpoints.py
```

## 🚀 Quick Start

### Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your API keys
python app.py
```

### Frontend Setup
```bash
cd frontend
flutter pub get
flutter run
```

## 🔑 Required API Keys

- OpenAI API Key (for GPT-4 and Whisper)
- Firebase Project (for Firestore and Auth)

## 📚 Features

- 🎙️ Audio transcription with OpenAI Whisper
- 🤖 AI interview analysis with GPT-4
- 📊 Progress tracking with Firebase
- 🔐 User authentication
- 📱 Beautiful Flutter UI

---

Built with ❤️ for interview success!