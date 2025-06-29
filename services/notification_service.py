"""
Notification Service using Firebase Cloud Messaging for push notifications
"""

import firebase_admin
from firebase_admin import messaging
import logging
import random
from typing import Dict, Any, Optional

logger = logging.getLogger(__name__)

class NotificationService:
    def __init__(self):
        """Initialize the notification service"""
        # Firebase Admin SDK should already be initialized
        self.motivational_quotes = [
            "Practice makes perfect! Keep improving your interview skills.",
            "Every expert was once a beginner. Keep practicing!",
            "Confidence comes from preparation. Practice today!",
            "Your next opportunity is just one practice session away.",
            "Great interviews start with great preparation.",
            "Success is where preparation and opportunity meet.",
            "The more you practice, the luckier you get in interviews.",
            "Believe in yourself and your interview skills will shine.",
            "Practice today, succeed tomorrow!",
            "Every practice session brings you closer to your dream job."
        ]
    
    def send_practice_reminder(self, fcm_token: str, user_id: str, 
                             custom_message: Optional[str] = None) -> Dict[str, Any]:
        """
        Send practice reminder notification to user's device
        
        Args:
            fcm_token: Firebase Cloud Messaging token for the device
            user_id: User identifier
            custom_message: Custom message to send (optional)
            
        Returns:
            Dictionary containing message ID and status
        """
        try:
            # Use custom message or random motivational quote
            if custom_message:
                message_body = custom_message
            else:
                message_body = random.choice(self.motivational_quotes)
            
            # Create the message
            message = messaging.Message(
                notification=messaging.Notification(
                    title="Time to Practice! 🎯",
                    body=message_body,
                    image=None  # You can add an image URL here
                ),
                data={
                    'type': 'practice_reminder',
                    'user_id': user_id,
                    'timestamp': str(int(firebase_admin._utils.datetime.datetime.utcnow().timestamp()))
                },
                token=fcm_token,
                android=messaging.AndroidConfig(
                    notification=messaging.AndroidNotification(
                        icon='ic_notification',
                        color='#2C3E50',
                        sound='default',
                        click_action='FLUTTER_NOTIFICATION_CLICK'
                    ),
                    priority='high'
                ),
                apns=messaging.APNSConfig(
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(
                            sound='default',
                            badge=1,
                            category='PRACTICE_REMINDER'
                        )
                    )
                )
            )
            
            # Send the message
            response = messaging.send(message)
            
            logger.info(f"Practice reminder sent successfully to user {user_id}: {response}")
            
            return {
                'success': True,
                'message_id': response,
                'user_id': user_id
            }
            
        except messaging.UnregisteredError:
            logger.warning(f"FCM token is unregistered for user {user_id}")
            return {
                'success': False,
                'error': 'Device token is no longer valid',
                'user_id': user_id
            }
        except messaging.SenderIdMismatchError:
            logger.error(f"Sender ID mismatch for user {user_id}")
            return {
                'success': False,
                'error': 'Invalid sender configuration',
                'user_id': user_id
            }
        except Exception as e:
            logger.error(f"Failed to send notification to user {user_id}: {str(e)}")
            return {
                'success': False,
                'error': str(e),
                'user_id': user_id
            }
    
    def send_achievement_notification(self, fcm_token: str, user_id: str, 
                                    achievement_type: str, achievement_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Send achievement notification to user
        
        Args:
            fcm_token: Firebase Cloud Messaging token
            user_id: User identifier
            achievement_type: Type of achievement (score_improvement, streak, etc.)
            achievement_data: Achievement details
            
        Returns:
            Dictionary containing message ID and status
        """
        try:
            # Create achievement message based on type
            title, body = self._get_achievement_message(achievement_type, achievement_data)
            
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body
                ),
                data={
                    'type': 'achievement',
                    'achievement_type': achievement_type,
                    'user_id': user_id,
                    'achievement_data': str(achievement_data)
                },
                token=fcm_token,
                android=messaging.AndroidConfig(
                    notification=messaging.AndroidNotification(
                        icon='ic_achievement',
                        color='#27AE60',
                        sound='achievement_sound'
                    )
                ),
                apns=messaging.APNSConfig(
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(
                            sound='achievement_sound.wav',
                            badge=1
                        )
                    )
                )
            )
            
            response = messaging.send(message)
            
            logger.info(f"Achievement notification sent to user {user_id}: {response}")
            
            return {
                'success': True,
                'message_id': response,
                'user_id': user_id
            }
            
        except Exception as e:
            logger.error(f"Failed to send achievement notification: {str(e)}")
            return {
                'success': False,
                'error': str(e),
                'user_id': user_id
            }
    
    def send_weekly_progress_summary(self, fcm_token: str, user_id: str, 
                                   progress_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Send weekly progress summary notification
        
        Args:
            fcm_token: Firebase Cloud Messaging token
            user_id: User identifier
            progress_data: Weekly progress statistics
            
        Returns:
            Dictionary containing message ID and status
        """
        try:
            sessions_count = progress_data.get('sessions_count', 0)
            avg_score = progress_data.get('average_score', 0)
            improvement = progress_data.get('improvement_percentage', 0)
            
            if sessions_count == 0:
                title = "Weekly Summary 📊"
                body = "No practice sessions this week. Start practicing to improve your skills!"
            else:
                title = f"Weekly Summary 📊 - {sessions_count} sessions completed!"
                if improvement > 0:
                    body = f"Great progress! Average score: {avg_score:.1f} (+{improvement:.1f}% improvement)"
                else:
                    body = f"Keep it up! Average score: {avg_score:.1f}. Practice more to improve!"
            
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body
                ),
                data={
                    'type': 'weekly_summary',
                    'user_id': user_id,
                    'sessions_count': str(sessions_count),
                    'average_score': str(avg_score)
                },
                token=fcm_token
            )
            
            response = messaging.send(message)
            
            logger.info(f"Weekly summary sent to user {user_id}: {response}")
            
            return {
                'success': True,
                'message_id': response,
                'user_id': user_id
            }
            
        except Exception as e:
            logger.error(f"Failed to send weekly summary: {str(e)}")
            return {
                'success': False,
                'error': str(e),
                'user_id': user_id
            }
    
    def _get_achievement_message(self, achievement_type: str, data: Dict[str, Any]) -> tuple:
        """Get achievement notification title and body"""
        if achievement_type == 'score_improvement':
            score = data.get('new_score', 0)
            return "🎉 New Personal Best!", f"Congratulations! You scored {score:.1f} - your highest yet!"
        
        elif achievement_type == 'practice_streak':
            days = data.get('streak_days', 0)
            return "🔥 Practice Streak!", f"Amazing! You've practiced {days} days in a row!"
        
        elif achievement_type == 'sessions_milestone':
            count = data.get('session_count', 0)
            return "🏆 Milestone Reached!", f"You've completed {count} practice sessions!"
        
        elif achievement_type == 'category_mastery':
            category = data.get('category', 'interview')
            return "⭐ Category Mastery!", f"You're excelling in {category} questions!"
        
        else:
            return "🎯 Achievement Unlocked!", "Great job on your interview practice!"