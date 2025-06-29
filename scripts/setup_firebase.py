"""
Script to help set up Firebase collections and initial data
"""

import firebase_admin
from firebase_admin import credentials, firestore
import os
from datetime import datetime

def setup_firebase_collections():
    """Set up initial Firebase collections and sample data"""
    
    # Initialize Firebase (make sure to set FIREBASE_SERVICE_ACCOUNT_PATH)
    service_account_path = os.getenv('FIREBASE_SERVICE_ACCOUNT_PATH')
    if not service_account_path:
        print("Please set FIREBASE_SERVICE_ACCOUNT_PATH environment variable")
        return
    
    cred = credentials.Certificate(service_account_path)
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    
    print("Setting up Firebase collections...")
    
    # Sample practice questions
    questions = [
        # General Questions
        {
            'question': 'Tell me about yourself.',
            'category': 'general',
            'difficulty': 'beginner',
            'estimated_time': 120,
            'tips': 'Focus on professional background and relevant experiences'
        },
        {
            'question': 'Why are you interested in this position?',
            'category': 'general',
            'difficulty': 'beginner',
            'estimated_time': 90,
            'tips': 'Research the company and connect your skills to their needs'
        },
        {
            'question': 'Where do you see yourself in 5 years?',
            'category': 'general',
            'difficulty': 'intermediate',
            'estimated_time': 120,
            'tips': 'Show ambition while staying realistic and relevant'
        },
        
        # Behavioral Questions
        {
            'question': 'Tell me about a time you faced a significant challenge at work.',
            'category': 'behavioral',
            'difficulty': 'intermediate',
            'estimated_time': 180,
            'tips': 'Use the STAR method: Situation, Task, Action, Result'
        },
        {
            'question': 'Describe a situation where you had to work with a difficult team member.',
            'category': 'behavioral',
            'difficulty': 'intermediate',
            'estimated_time': 180,
            'tips': 'Focus on your communication and problem-solving skills'
        },
        {
            'question': 'Tell me about a time you had to make a decision with incomplete information.',
            'category': 'behavioral',
            'difficulty': 'advanced',
            'estimated_time': 200,
            'tips': 'Highlight your analytical thinking and risk assessment'
        },
        
        # Technical Questions
        {
            'question': 'What programming languages are you most comfortable with?',
            'category': 'technical',
            'difficulty': 'beginner',
            'estimated_time': 120,
            'tips': 'Mention specific projects and your level of expertise'
        },
        {
            'question': 'How would you approach debugging a performance issue in an application?',
            'category': 'technical',
            'difficulty': 'intermediate',
            'estimated_time': 240,
            'tips': 'Walk through your systematic debugging process'
        },
        {
            'question': 'Design a system that can handle millions of concurrent users.',
            'category': 'technical',
            'difficulty': 'advanced',
            'estimated_time': 300,
            'tips': 'Consider scalability, load balancing, and database design'
        }
    ]
    
    # Add questions to Firestore
    questions_ref = db.collection('practice_questions')
    for question in questions:
        question['created_at'] = datetime.utcnow()
        questions_ref.add(question)
    
    print(f"Added {len(questions)} practice questions")
    
    # Create indexes (these should be created in Firebase Console)
    print("\nPlease create the following indexes in Firebase Console:")
    print("1. practice_questions: category (Ascending), difficulty (Ascending)")
    print("2. practice_sessions: user_id (Ascending), timestamp (Descending)")
    print("3. user_feedback: user_id (Ascending), timestamp (Descending)")
    
    # Sample user feedback categories
    feedback_categories = [
        {'name': 'general', 'description': 'General feedback about the app'},
        {'name': 'bug', 'description': 'Bug reports and technical issues'},
        {'name': 'feature_request', 'description': 'Requests for new features'},
        {'name': 'ui_ux', 'description': 'User interface and experience feedback'}
    ]
    
    categories_ref = db.collection('feedback_categories')
    for category in feedback_categories:
        categories_ref.add(category)
    
    print(f"Added {len(feedback_categories)} feedback categories")
    
    print("\nFirebase setup completed successfully!")
    print("Your backend is now ready to use.")

if __name__ == '__main__':
    setup_firebase_collections()