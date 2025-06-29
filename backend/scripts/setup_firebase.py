"""
Script to help set up Firebase collections and initial data
"""

import firebase_admin
from firebase_admin import credentials, firestore
import os
from datetime import datetime

def setup_firebase_collections():
    """Set up initial Firebase collections and sample data"""
    
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
            'question': 'Tell me about a time you faced a significant challenge at work.',
            'category': 'behavioral',
            'difficulty': 'intermediate',
            'estimated_time': 180,
            'tips': 'Use the STAR method: Situation, Task, Action, Result'
        },
        {
            'question': 'What programming languages are you most comfortable with?',
            'category': 'technical',
            'difficulty': 'beginner',
            'estimated_time': 120,
            'tips': 'Mention specific projects and your level of expertise'
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
    
    print("\nFirebase setup completed successfully!")
    print("Your backend is now ready to use.")

if __name__ == '__main__':
    setup_firebase_collections()