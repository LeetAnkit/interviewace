# AI Interview Coach Backend

A comprehensive Flask-based backend API for the AI Interview Coach mobile application, providing audio transcription, AI-powered interview analysis, and progress tracking.

## 🚀 Features

- **🎙️ Audio Transcription**: Convert speech to text using OpenAI Whisper API
- **🤖 AI Analysis**: Analyze interview responses using GPT-4 for detailed feedback
- **📊 Progress Tracking**: Store and retrieve user practice sessions with Firebase Firestore
- **🔐 Authentication**: Firebase Auth token validation for secure endpoints
- **📱 Push Notifications**: Firebase Cloud Messaging for practice reminders
- **📈 Analytics**: User statistics and progress insights

## 🛠️ Tech Stack

- **Framework**: Flask (Python)
- **AI Services**: OpenAI GPT-4 & Whisper APIs
- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth
- **Notifications**: Firebase Cloud Messaging
- **Audio Processing**: pydub
- **Deployment**: Docker, Gunicorn

## 📋 Prerequisites

- Python 3.11+
- OpenAI API key
- Firebase project with Firestore and Auth enabled
- Firebase service account key

## 🔧 Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd ai-interview-coach-backend
```

2. **Create virtual environment**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies**
```bash
pip install -r requirements.txt
```

4. **Set up environment variables**
```bash
cp .env.example .env
# Edit .env with your API keys and configuration
```

5. **Configure Firebase**
   - Download your Firebase service account key JSON file
   - Update `FIREBASE_SERVICE_ACCOUNT_PATH` in `.env`

## 🚀 Running the Application

### Development
```bash
python app.py
```

### Production with Gunicorn
```bash
gunicorn --bind 0.0.0.0:5000 --workers 4 app:app
```

### Docker
```bash
docker build -t ai-interview-coach-backend .
docker run -p 5000:5000 --env-file .env ai-interview-coach-backend
```

## 📚 API Documentation

### Base URL
```
http://localhost:5000
```

### Authentication
Most endpoints require Firebase Auth token in the Authorization header:
```
Authorization: Bearer <firebase_id_token>
```

### Endpoints

#### 🎙️ Audio Transcription
```http
POST /transcribe
Content-Type: multipart/form-data

Form Data:
- audio: audio file (mp3, wav, m4a, etc.)
- user_id: string (optional)
```

**Response:**
```json
{
  "success": true,
  "transcription": "Hello, my name is John...",
  "duration": 45.2,
  "confidence": 0.95,
  "timestamp": "2024-01-15T10:30:00Z"
}
```

#### 🤖 Interview Analysis
```http
POST /analyze
Content-Type: application/json

{
  "text": "I am a software engineer with 5 years of experience...",
  "question": "Tell me about yourself",
  "user_id": "user123",
  "category": "general"
}
```

**Response:**
```json
{
  "success": true,
  "overall_score": 8.5,
  "detailed_feedback": {
    "content_quality": {
      "score": 9,
      "feedback": "Excellent technical background..."
    },
    "communication_clarity": {
      "score": 8,
      "feedback": "Clear and well-structured response..."
    },
    "filler_words": {
      "score": 7,
      "total_count": 3,
      "percentage": 2.1
    }
  },
  "follow_up_question": "Can you tell me about a specific project you worked on?",
  "improvement_suggestions": [
    "Add more specific examples",
    "Reduce use of filler words"
  ]
}
```

#### 📊 Get User Sessions
```http
GET /sessions?user_id=user123&limit=20&start_date=2024-01-01T00:00:00Z
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "sessions": [
    {
      "id": "session_001",
      "question": "Tell me about yourself",
      "response": "I am a software engineer...",
      "analysis": { ... },
      "timestamp": "2024-01-15T10:30:00Z"
    }
  ],
  "total_count": 15,
  "has_more": false
}
```

#### 📈 Get User Statistics
```http
GET /stats?user_id=user123&period=month
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "stats": {
    "total_sessions": 25,
    "average_score": 8.2,
    "improvement_trend": 15.5,
    "category_breakdown": {
      "general": {"count": 10, "avg_score": 8.5},
      "technical": {"count": 8, "avg_score": 7.8}
    },
    "recent_scores": [
      {"date": "2024-01-15", "score": 8.5},
      {"date": "2024-01-14", "score": 7.9}
    ]
  }
}
```

#### 🔔 Send Practice Reminder
```http
POST /notifications/send-reminder
Content-Type: application/json
Authorization: Bearer <token>

{
  "user_id": "user123",
  "fcm_token": "device_fcm_token",
  "message": "Time to practice your interview skills!"
}
```

#### ❓ Get Practice Questions
```http
GET /questions?category=behavioral&difficulty=intermediate&limit=5
```

**Response:**
```json
{
  "success": true,
  "questions": [
    {
      "id": "q_001",
      "question": "Tell me about a time you faced a challenge",
      "category": "behavioral",
      "difficulty": "intermediate"
    }
  ]
}
```

## 🏗️ Project Structure

```
ai-interview-coach-backend/
├── app.py                 # Main Flask application
├── requirements.txt       # Python dependencies
├── Dockerfile            # Docker configuration
├── config.py             # Application configuration
├── services/             # Business logic services
│   ├── transcription_service.py
│   ├── analysis_service.py
│   ├── database_service.py
│   ├── auth_service.py
│   └── notification_service.py
├── utils/                # Utility functions
│   ├── validators.py
│   └── error_handlers.py
└── README.md
```

## 🔒 Security Features

- Firebase Auth token validation
- Input validation and sanitization
- File upload restrictions
- Rate limiting (configurable)
- Error handling without information leakage

## 📊 Monitoring & Logging

- Comprehensive logging with different levels
- Health check endpoint (`/health`)
- Error tracking and reporting
- Performance monitoring ready

## 🚀 Deployment

### Google Cloud Platform
1. Set up Google Cloud project
2. Enable required APIs (Firestore, Cloud Functions)
3. Deploy using Cloud Run or App Engine

### AWS
1. Use Elastic Beanstalk or ECS
2. Configure environment variables
3. Set up RDS for additional database needs

### Heroku
1. Create Heroku app
2. Set environment variables
3. Deploy using Git or Docker

## 🧪 Testing

```bash
# Run tests (when test files are added)
python -m pytest tests/

# Test specific endpoint
curl -X POST http://localhost:5000/health
```

## 🔧 Configuration

Key environment variables:

- `OPENAI_API_KEY`: Your OpenAI API key
- `FIREBASE_PROJECT_ID`: Firebase project ID
- `FIREBASE_SERVICE_ACCOUNT_PATH`: Path to service account JSON
- `FLASK_ENV`: Environment (development/production)
- `PORT`: Server port (default: 5000)

## 📝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For issues and questions:
1. Check the documentation
2. Search existing issues
3. Create a new issue with detailed information

## 🔄 API Versioning

Current API version: v1
Base URL: `/api/v1` (can be added for versioning)

---

Built with ❤️ for helping people ace their interviews!