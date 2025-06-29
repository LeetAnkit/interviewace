"""
AI Interview Coach Backend
A Flask application providing audio transcription, AI analysis, and progress tracking
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from dotenv import load_dotenv
import logging
from datetime import datetime

# Import our custom modules
from services.transcription_service import TranscriptionService
from services.analysis_service import AnalysisService
from services.database_service import DatabaseService
from services.auth_service import AuthService
from services.notification_service import NotificationService
from utils.validators import validate_audio_file, validate_text_input
from utils.error_handlers import register_error_handlers

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize services
transcription_service = TranscriptionService()
analysis_service = AnalysisService()
database_service = DatabaseService()
auth_service = AuthService()
notification_service = NotificationService()

# Register error handlers
register_error_handlers(app)

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'version': '1.0.0'
    }), 200

@app.route('/transcribe', methods=['POST'])
def transcribe_audio():
    """
    Transcribe audio file to text using OpenAI Whisper
    
    Expected form data:
    - audio: audio file (mp3, wav, m4a, etc.)
    - user_id: string (optional, for authenticated requests)
    
    Returns:
    - transcription: string
    - duration: float (seconds)
    - confidence: float (0-1)
    """
    try:
        # Validate request
        if 'audio' not in request.files:
            return jsonify({'error': 'No audio file provided'}), 400
        
        audio_file = request.files['audio']
        user_id = request.form.get('user_id')
        
        # Validate audio file
        if not validate_audio_file(audio_file):
            return jsonify({'error': 'Invalid audio file format'}), 400
        
        # Optional: Validate user authentication
        if user_id:
            auth_header = request.headers.get('Authorization')
            if not auth_service.verify_token(auth_header, user_id):
                return jsonify({'error': 'Invalid authentication'}), 401
        
        # Transcribe audio
        result = transcription_service.transcribe(audio_file)
        
        logger.info(f"Audio transcribed successfully for user: {user_id}")
        
        return jsonify({
            'success': True,
            'transcription': result['text'],
            'duration': result['duration'],
            'confidence': result.get('confidence', 0.95),
            'timestamp': datetime.utcnow().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"Transcription error: {str(e)}")
        return jsonify({'error': 'Transcription failed', 'details': str(e)}), 500

@app.route('/analyze', methods=['POST'])
def analyze_response():
    """
    Analyze interview response using GPT-4
    
    Expected JSON:
    {
        "text": "user's interview response",
        "question": "original interview question",
        "user_id": "user123",
        "category": "behavioral|technical|general"
    }
    
    Returns:
    - overall_score: float (0-10)
    - detailed_feedback: object with scores and comments
    - follow_up_question: string
    - improvement_suggestions: array of strings
    """
    try:
        data = request.get_json()
        
        # Validate input
        if not validate_text_input(data):
            return jsonify({'error': 'Invalid input data'}), 400
        
        text = data['text']
        question = data.get('question', '')
        user_id = data.get('user_id')
        category = data.get('category', 'general')
        
        # Optional: Validate user authentication
        if user_id:
            auth_header = request.headers.get('Authorization')
            if not auth_service.verify_token(auth_header, user_id):
                return jsonify({'error': 'Invalid authentication'}), 401
        
        # Analyze response
        analysis_result = analysis_service.analyze_interview_response(
            text=text,
            question=question,
            category=category
        )
        
        # Generate follow-up question
        follow_up = analysis_service.generate_follow_up_question(
            original_question=question,
            user_response=text,
            category=category
        )
        
        result = {
            'success': True,
            'overall_score': analysis_result['overall_score'],
            'detailed_feedback': analysis_result['detailed_feedback'],
            'follow_up_question': follow_up,
            'improvement_suggestions': analysis_result['suggestions'],
            'timestamp': datetime.utcnow().isoformat()
        }
        
        # Save to database if user_id provided
        if user_id:
            session_data = {
                'user_id': user_id,
                'question': question,
                'response': text,
                'category': category,
                'analysis': result,
                'timestamp': datetime.utcnow()
            }
            database_service.save_session(session_data)
        
        logger.info(f"Analysis completed for user: {user_id}")
        
        return jsonify(result), 200
        
    except Exception as e:
        logger.error(f"Analysis error: {str(e)}")
        return jsonify({'error': 'Analysis failed', 'details': str(e)}), 500

@app.route('/sessions', methods=['GET'])
def get_user_sessions():
    """
    Get user's practice sessions
    
    Query parameters:
    - user_id: string (required)
    - limit: int (optional, default 20)
    - start_date: string (optional, ISO format)
    - end_date: string (optional, ISO format)
    
    Returns:
    - sessions: array of session objects
    - total_count: int
    - has_more: boolean
    """
    try:
        user_id = request.args.get('user_id')
        if not user_id:
            return jsonify({'error': 'user_id is required'}), 400
        
        # Validate authentication
        auth_header = request.headers.get('Authorization')
        if not auth_service.verify_token(auth_header, user_id):
            return jsonify({'error': 'Invalid authentication'}), 401
        
        # Parse query parameters
        limit = int(request.args.get('limit', 20))
        start_date = request.args.get('start_date')
        end_date = request.args.get('end_date')
        
        # Get sessions from database
        sessions = database_service.get_user_sessions(
            user_id=user_id,
            limit=limit,
            start_date=start_date,
            end_date=end_date
        )
        
        return jsonify({
            'success': True,
            'sessions': sessions['data'],
            'total_count': sessions['total'],
            'has_more': sessions['has_more']
        }), 200
        
    except Exception as e:
        logger.error(f"Get sessions error: {str(e)}")
        return jsonify({'error': 'Failed to fetch sessions', 'details': str(e)}), 500

@app.route('/sessions/<session_id>', methods=['GET'])
def get_session_detail(session_id):
    """
    Get detailed information about a specific session
    
    Returns:
    - session: complete session object with analysis
    """
    try:
        user_id = request.args.get('user_id')
        if not user_id:
            return jsonify({'error': 'user_id is required'}), 400
        
        # Validate authentication
        auth_header = request.headers.get('Authorization')
        if not auth_service.verify_token(auth_header, user_id):
            return jsonify({'error': 'Invalid authentication'}), 401
        
        # Get session from database
        session = database_service.get_session_by_id(session_id, user_id)
        
        if not session:
            return jsonify({'error': 'Session not found'}), 404
        
        return jsonify({
            'success': True,
            'session': session
        }), 200
        
    except Exception as e:
        logger.error(f"Get session detail error: {str(e)}")
        return jsonify({'error': 'Failed to fetch session', 'details': str(e)}), 500

@app.route('/stats', methods=['GET'])
def get_user_stats():
    """
    Get user's practice statistics
    
    Query parameters:
    - user_id: string (required)
    - period: string (optional: 'week', 'month', 'year', default 'month')
    
    Returns:
    - total_sessions: int
    - average_score: float
    - improvement_trend: float
    - category_breakdown: object
    - recent_scores: array
    """
    try:
        user_id = request.args.get('user_id')
        if not user_id:
            return jsonify({'error': 'user_id is required'}), 400
        
        # Validate authentication
        auth_header = request.headers.get('Authorization')
        if not auth_service.verify_token(auth_header, user_id):
            return jsonify({'error': 'Invalid authentication'}), 401
        
        period = request.args.get('period', 'month')
        
        # Get statistics from database
        stats = database_service.get_user_statistics(user_id, period)
        
        return jsonify({
            'success': True,
            'stats': stats
        }), 200
        
    except Exception as e:
        logger.error(f"Get stats error: {str(e)}")
        return jsonify({'error': 'Failed to fetch statistics', 'details': str(e)}), 500

@app.route('/questions', methods=['GET'])
def get_practice_questions():
    """
    Get practice questions by category and difficulty
    
    Query parameters:
    - category: string (optional: 'behavioral', 'technical', 'general')
    - difficulty: string (optional: 'beginner', 'intermediate', 'advanced')
    - limit: int (optional, default 10)
    
    Returns:
    - questions: array of question objects
    """
    try:
        category = request.args.get('category', 'general')
        difficulty = request.args.get('difficulty', 'intermediate')
        limit = int(request.args.get('limit', 10))
        
        # Get questions from database
        questions = database_service.get_practice_questions(
            category=category,
            difficulty=difficulty,
            limit=limit
        )
        
        return jsonify({
            'success': True,
            'questions': questions
        }), 200
        
    except Exception as e:
        logger.error(f"Get questions error: {str(e)}")
        return jsonify({'error': 'Failed to fetch questions', 'details': str(e)}), 500

@app.route('/notifications/send-reminder', methods=['POST'])
def send_practice_reminder():
    """
    Send practice reminder notification
    
    Expected JSON:
    {
        "user_id": "user123",
        "fcm_token": "device_token",
        "message": "custom message (optional)"
    }
    
    Returns:
    - success: boolean
    - message_id: string
    """
    try:
        data = request.get_json()
        user_id = data.get('user_id')
        fcm_token = data.get('fcm_token')
        custom_message = data.get('message')
        
        if not user_id or not fcm_token:
            return jsonify({'error': 'user_id and fcm_token are required'}), 400
        
        # Validate authentication
        auth_header = request.headers.get('Authorization')
        if not auth_service.verify_token(auth_header, user_id):
            return jsonify({'error': 'Invalid authentication'}), 401
        
        # Send notification
        result = notification_service.send_practice_reminder(
            fcm_token=fcm_token,
            user_id=user_id,
            custom_message=custom_message
        )
        
        return jsonify({
            'success': True,
            'message_id': result['message_id']
        }), 200
        
    except Exception as e:
        logger.error(f"Send notification error: {str(e)}")
        return jsonify({'error': 'Failed to send notification', 'details': str(e)}), 500

@app.route('/feedback', methods=['POST'])
def submit_feedback():
    """
    Submit user feedback about the app
    
    Expected JSON:
    {
        "user_id": "user123",
        "rating": 5,
        "comment": "Great app!",
        "category": "general|bug|feature_request"
    }
    
    Returns:
    - success: boolean
    - feedback_id: string
    """
    try:
        data = request.get_json()
        user_id = data.get('user_id')
        rating = data.get('rating')
        comment = data.get('comment', '')
        category = data.get('category', 'general')
        
        if not user_id or rating is None:
            return jsonify({'error': 'user_id and rating are required'}), 400
        
        # Validate authentication
        auth_header = request.headers.get('Authorization')
        if not auth_service.verify_token(auth_header, user_id):
            return jsonify({'error': 'Invalid authentication'}), 401
        
        # Save feedback
        feedback_id = database_service.save_feedback({
            'user_id': user_id,
            'rating': rating,
            'comment': comment,
            'category': category,
            'timestamp': datetime.utcnow()
        })
        
        return jsonify({
            'success': True,
            'feedback_id': feedback_id
        }), 200
        
    except Exception as e:
        logger.error(f"Submit feedback error: {str(e)}")
        return jsonify({'error': 'Failed to submit feedback', 'details': str(e)}), 500

if __name__ == '__main__':
    # Ensure required environment variables are set
    required_env_vars = [
        'OPENAI_API_KEY',
        'FIREBASE_PROJECT_ID'
    ]
    
    missing_vars = [var for var in required_env_vars if not os.getenv(var)]
    if missing_vars:
        logger.error(f"Missing required environment variables: {missing_vars}")
        exit(1)
    
    # Run the application
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_ENV') == 'development'
    
    logger.info(f"Starting AI Interview Coach Backend on port {port}")
    app.run(host='0.0.0.0', port=port, debug=debug)