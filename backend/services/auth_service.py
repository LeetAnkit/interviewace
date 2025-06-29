"""
Authentication Service using Firebase Auth for token validation
"""

import firebase_admin
from firebase_admin import auth
import logging
from typing import Optional

logger = logging.getLogger(__name__)

class AuthService:
    def __init__(self):
        """Initialize the authentication service"""
        pass
    
    def verify_token(self, auth_header: Optional[str], expected_user_id: str) -> bool:
        """
        Verify Firebase Auth token and validate user ID
        
        Args:
            auth_header: Authorization header containing Bearer token
            expected_user_id: Expected user ID to validate against
            
        Returns:
            True if token is valid and user ID matches, False otherwise
        """
        try:
            if not auth_header:
                logger.warning("No authorization header provided")
                return False
            
            if not auth_header.startswith('Bearer '):
                logger.warning("Invalid authorization header format")
                return False
            
            token = auth_header.split('Bearer ')[1]
            
            # Verify the token with Firebase Auth
            decoded_token = auth.verify_id_token(token)
            token_user_id = decoded_token.get('uid')
            
            # Validate user ID matches
            if token_user_id != expected_user_id:
                logger.warning(f"User ID mismatch: token={token_user_id}, expected={expected_user_id}")
                return False
            
            logger.info(f"Token verified successfully for user: {expected_user_id}")
            return True
            
        except auth.InvalidIdTokenError:
            logger.warning("Invalid Firebase ID token")
            return False
        except auth.ExpiredIdTokenError:
            logger.warning("Expired Firebase ID token")
            return False
        except Exception as e:
            logger.error(f"Token verification failed: {str(e)}")
            return False
    
    def get_user_info(self, auth_header: str) -> Optional[dict]:
        """
        Get user information from Firebase Auth token
        
        Args:
            auth_header: Authorization header containing Bearer token
            
        Returns:
            User information dictionary or None if invalid
        """
        try:
            if not auth_header or not auth_header.startswith('Bearer '):
                return None
            
            token = auth_header.split('Bearer ')[1]
            decoded_token = auth.verify_id_token(token)
            
            return {
                'user_id': decoded_token.get('uid'),
                'email': decoded_token.get('email'),
                'email_verified': decoded_token.get('email_verified', False),
                'name': decoded_token.get('name'),
                'picture': decoded_token.get('picture')
            }
            
        except Exception as e:
            logger.error(f"Failed to get user info: {str(e)}")
            return None