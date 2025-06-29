"""
Database Service using Firebase Firestore for data persistence
"""

import firebase_admin
from firebase_admin import credentials, firestore
import os
import logging
from datetime import datetime, timedelta
from typing import Dict, Any, List, Optional

logger = logging.getLogger(__name__)

class DatabaseService:
    def __init__(self):
        """Initialize Firebase Firestore connection"""
        try:
            if not firebase_admin._apps:
                service_account_path = os.getenv('FIREBASE_SERVICE_ACCOUNT_PATH')
                if service_account_path and os.path.exists(service_account_path):
                    cred = credentials.Certificate(service_account_path)
                    firebase_admin.initialize_app(cred)
                else:
                    firebase_admin.initialize_app()
            
            self.db = firestore.client()
            logger.info("Firebase Firestore initialized successfully")
            
        except Exception as e:
            logger.error(f"Failed to initialize Firestore: {str(e)}")
            raise
    
    def save_session(self, session_data: Dict[str, Any]) -> str:
        """Save a practice session to Firestore"""
        try:
            if 'timestamp' not in session_data:
                session_data['timestamp'] = datetime.utcnow()
            
            session_data = self._prepare_for_firestore(session_data)
            doc_ref = self.db.collection('practice_sessions').add(session_data)
            session_id = doc_ref[1].id
            
            logger.info(f"Session saved with ID: {session_id}")
            return session_id
            
        except Exception as e:
            logger.error(f"Failed to save session: {str(e)}")
            raise
    
    def get_user_sessions(self, user_id: str, limit: int = 20, 
                         start_date: Optional[str] = None, 
                         end_date: Optional[str] = None) -> Dict[str, Any]:
        """Get user's practice sessions with optional date filtering"""
        try:
            query = self.db.collection('practice_sessions').where('user_id', '==', user_id)
            
            if start_date:
                start_dt = datetime.fromisoformat(start_date.replace('Z', '+00:00'))
                query = query.where('timestamp', '>=', start_dt)
            
            if end_date:
                end_dt = datetime.fromisoformat(end_date.replace('Z', '+00:00'))
                query = query.where('timestamp', '<=', end_dt)
            
            query = query.order_by('timestamp', direction=firestore.Query.DESCENDING).limit(limit + 1)
            docs = query.stream()
            sessions = []
            
            for doc in docs:
                if len(sessions) >= limit:
                    break
                
                session_data = doc.to_dict()
                session_data['id'] = doc.id
                session_data = self._prepare_from_firestore(session_data)
                sessions.append(session_data)
            
            has_more = len(list(query.stream())) > limit
            
            return {
                'data': sessions,
                'total': len(sessions),
                'has_more': has_more
            }
            
        except Exception as e:
            logger.error(f"Failed to get user sessions: {str(e)}")
            raise
    
    def get_user_statistics(self, user_id: str, period: str = 'month') -> Dict[str, Any]:
        """Get user's practice statistics for a given period"""
        try:
            now = datetime.utcnow()
            if period == 'week':
                start_date = now - timedelta(days=7)
            elif period == 'month':
                start_date = now - timedelta(days=30)
            elif period == 'year':
                start_date = now - timedelta(days=365)
            else:
                start_date = now - timedelta(days=30)
            
            query = (self.db.collection('practice_sessions')
                    .where('user_id', '==', user_id)
                    .where('timestamp', '>=', start_date)
                    .order_by('timestamp'))
            
            docs = query.stream()
            sessions = [doc.to_dict() for doc in docs]
            
            if not sessions:
                return self._get_empty_stats()
            
            total_sessions = len(sessions)
            scores = [s.get('analysis', {}).get('overall_score', 0) for s in sessions if s.get('analysis')]
            average_score = sum(scores) / len(scores) if scores else 0
            
            # Calculate improvement trend
            mid_point = len(scores) // 2
            if mid_point > 0:
                first_half_avg = sum(scores[:mid_point]) / mid_point
                second_half_avg = sum(scores[mid_point:]) / (len(scores) - mid_point)
                improvement_trend = ((second_half_avg - first_half_avg) / first_half_avg) * 100
            else:
                improvement_trend = 0
            
            # Category breakdown
            category_breakdown = {}
            for session in sessions:
                category = session.get('category', 'general')
                if category not in category_breakdown:
                    category_breakdown[category] = {'count': 0, 'avg_score': 0, 'scores': []}
                
                category_breakdown[category]['count'] += 1
                score = session.get('analysis', {}).get('overall_score', 0)
                category_breakdown[category]['scores'].append(score)
            
            for category in category_breakdown:
                scores_list = category_breakdown[category]['scores']
                category_breakdown[category]['avg_score'] = sum(scores_list) / len(scores_list) if scores_list else 0
                del category_breakdown[category]['scores']
            
            recent_scores = [
                {
                    'date': s.get('timestamp', now).isoformat() if isinstance(s.get('timestamp'), datetime) else str(s.get('timestamp', now)),
                    'score': s.get('analysis', {}).get('overall_score', 0)
                }
                for s in sessions[-10:]
            ]
            
            return {
                'total_sessions': total_sessions,
                'average_score': round(average_score, 1),
                'improvement_trend': round(improvement_trend, 1),
                'category_breakdown': category_breakdown,
                'recent_scores': recent_scores,
                'period': period
            }
            
        except Exception as e:
            logger.error(f"Failed to get user statistics: {str(e)}")
            return self._get_empty_stats()
    
    def get_practice_questions(self, category: str = 'general', 
                             difficulty: str = 'intermediate', 
                             limit: int = 10) -> List[Dict[str, Any]]:
        """Get practice questions from the database"""
        try:
            query = (self.db.collection('practice_questions')
                    .where('category', '==', category)
                    .where('difficulty', '==', difficulty)
                    .limit(limit))
            
            docs = query.stream()
            questions = []
            
            for doc in docs:
                question_data = doc.to_dict()
                question_data['id'] = doc.id
                questions.append(question_data)
            
            if not questions:
                questions = self._get_default_questions(category, difficulty, limit)
            
            return questions
            
        except Exception as e:
            logger.error(f"Failed to get practice questions: {str(e)}")
            return self._get_default_questions(category, difficulty, limit)
    
    def _prepare_for_firestore(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Prepare data for Firestore by converting datetime objects"""
        if isinstance(data, dict):
            return {k: self._prepare_for_firestore(v) for k, v in data.items()}
        elif isinstance(data, list):
            return [self._prepare_for_firestore(item) for item in data]
        elif isinstance(data, datetime):
            return data
        else:
            return data
    
    def _prepare_from_firestore(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Prepare data from Firestore by converting timestamps to ISO strings"""
        if isinstance(data, dict):
            result = {}
            for k, v in data.items():
                if hasattr(v, 'timestamp'):
                    result[k] = v.isoformat()
                elif isinstance(v, datetime):
                    result[k] = v.isoformat()
                elif isinstance(v, dict):
                    result[k] = self._prepare_from_firestore(v)
                elif isinstance(v, list):
                    result[k] = [self._prepare_from_firestore(item) if isinstance(item, dict) else item for item in v]
                else:
                    result[k] = v
            return result
        else:
            return data
    
    def _get_empty_stats(self) -> Dict[str, Any]:
        """Return empty statistics structure"""
        return {
            'total_sessions': 0,
            'average_score': 0,
            'improvement_trend': 0,
            'category_breakdown': {},
            'recent_scores': [],
            'period': 'month'
        }
    
    def _get_default_questions(self, category: str, difficulty: str, limit: int) -> List[Dict[str, Any]]:
        """Return default questions if none found in database"""
        default_questions = {
            'general': {
                'beginner': [
                    {'id': 'gen_1', 'question': 'Tell me about yourself.', 'category': 'general', 'difficulty': 'beginner'},
                    {'id': 'gen_2', 'question': 'Why are you interested in this position?', 'category': 'general', 'difficulty': 'beginner'},
                    {'id': 'gen_3', 'question': 'What are your greatest strengths?', 'category': 'general', 'difficulty': 'beginner'},
                ],
                'intermediate': [
                    {'id': 'gen_4', 'question': 'Describe a challenging situation you faced and how you handled it.', 'category': 'general', 'difficulty': 'intermediate'},
                    {'id': 'gen_5', 'question': 'Where do you see yourself in 5 years?', 'category': 'general', 'difficulty': 'intermediate'},
                    {'id': 'gen_6', 'question': 'Why should we hire you over other candidates?', 'category': 'general', 'difficulty': 'intermediate'},
                ],
                'advanced': [
                    {'id': 'gen_7', 'question': 'How would you handle a situation where you disagree with your manager?', 'category': 'general', 'difficulty': 'advanced'},
                    {'id': 'gen_8', 'question': 'Describe a time when you had to make a difficult decision with limited information.', 'category': 'general', 'difficulty': 'advanced'},
                ]
            },
            'behavioral': {
                'beginner': [
                    {'id': 'beh_1', 'question': 'Tell me about a time you worked in a team.', 'category': 'behavioral', 'difficulty': 'beginner'},
                    {'id': 'beh_2', 'question': 'Describe a time when you helped a colleague.', 'category': 'behavioral', 'difficulty': 'beginner'},
                ],
                'intermediate': [
                    {'id': 'beh_3', 'question': 'Tell me about a time you had to deal with a difficult customer.', 'category': 'behavioral', 'difficulty': 'intermediate'},
                    {'id': 'beh_4', 'question': 'Describe a situation where you had to adapt to change.', 'category': 'behavioral', 'difficulty': 'intermediate'},
                ],
                'advanced': [
                    {'id': 'beh_5', 'question': 'Tell me about a time you had to influence someone without authority.', 'category': 'behavioral', 'difficulty': 'advanced'},
                    {'id': 'beh_6', 'question': 'Describe a time when you had to make an unpopular decision.', 'category': 'behavioral', 'difficulty': 'advanced'},
                ]
            },
            'technical': {
                'beginner': [
                    {'id': 'tech_1', 'question': 'What programming languages are you familiar with?', 'category': 'technical', 'difficulty': 'beginner'},
                    {'id': 'tech_2', 'question': 'Explain what a database is.', 'category': 'technical', 'difficulty': 'beginner'},
                ],
                'intermediate': [
                    {'id': 'tech_3', 'question': 'How would you optimize a slow-performing application?', 'category': 'technical', 'difficulty': 'intermediate'},
                    {'id': 'tech_4', 'question': 'Explain the difference between SQL and NoSQL databases.', 'category': 'technical', 'difficulty': 'intermediate'},
                ],
                'advanced': [
                    {'id': 'tech_5', 'question': 'Design a system that can handle millions of users.', 'category': 'technical', 'difficulty': 'advanced'},
                    {'id': 'tech_6', 'question': 'How would you implement a caching strategy for a web application?', 'category': 'technical', 'difficulty': 'advanced'},
                ]
            }
        }
        
        questions = default_questions.get(category, {}).get(difficulty, [])
        return questions[:limit]