"""
AI Interview Coach Backend API
A Flask application providing audio transcription, AI analysis, and progress tracking
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from dotenv import load_dotenv
import logging
from datetime import datetime

# Import services
from services.transcription_service import TranscriptionService
from services.analysis_service import AnalysisService
from services.database_service import DatabaseService
from services.auth_service import AuthService
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
    """
    try:
        if 'audio' not in request.files:
            return jsonify({'error': 'No audio file provided'}), 400
        
        audio_file = request.files['audio']
        user_id = request.form.get('user_id')
        
        if not validate_audio_file(audio_file):
            return jsonify({'error': 'Invalid audio file format'}), 400
        
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
        return jsonify({'error': 'Transcription failed'}), 500

@app.route('/analyze', methods=['POST'])
def analyze_response():
    """
    Analyze interview response using GPT-4
    """
    try:
        data = request.get_json()
        
        if not validate_text_input(data):
            return jsonify({'error': 'Invalid input data'}), 400
        
        text = data['text']
        question = data.get('question', '')
        user_id = data.get('user_id')
        category = data.get('category', 'general')
        
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
        return jsonify({'error': 'Analysis failed'}), 500

@app.route('/sessions', methods=['GET'])
def get_user_sessions():
    """Get user's practice sessions"""
    try:
        user_id = request.args.get('user_id')
        if not user_id:
            return jsonify({'error': 'user_id is required'}), 400
        
        limit = int(request.args.get('limit', 20))
        start_date = request.args.get('start_date')
        end_date = request.args.get('end_date')
        
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
        return jsonify({'error': 'Failed to fetch sessions'}), 500

@app.route('/stats', methods=['GET'])
def get_user_stats():
    """Get user's practice statistics"""
    try:
        user_id = request.args.get('user_id')
        if not user_id:
            return jsonify({'error': 'user_id is required'}), 400
        
        period = request.args.get('period', 'month')
        stats = database_service.get_user_statistics(user_id, period)
        
        return jsonify({
            'success': True,
            'stats': stats
        }), 200
        
    except Exception as e:
        logger.error(f"Get stats error: {str(e)}")
        return jsonify({'error': 'Failed to fetch statistics'}), 500

@app.route('/questions', methods=['GET'])
def get_practice_questions():
    """Get practice questions by category and difficulty"""
    try:
        category = request.args.get('category', 'general')
        difficulty = request.args.get('difficulty', 'intermediate')
        limit = int(request.args.get('limit', 10))
        
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
        return jsonify({'error': 'Failed to fetch questions'}), 500

if __name__ == '__main__':
    # Ensure required environment variables are set
    required_env_vars = ['OPENAI_API_KEY', 'FIREBASE_PROJECT_ID']
    missing_vars = [var for var in required_env_vars if not os.getenv(var)]
    
    if missing_vars:
        logger.error(f"Missing required environment variables: {missing_vars}")
        exit(1)
    
    # Run the application
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_ENV') == 'development'
    
    logger.info(f"Starting AI Interview Coach Backend on port {port}")
    app.run(host='0.0.0.0', port=port, debug=debug)