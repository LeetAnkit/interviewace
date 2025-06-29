"""
Input validation utilities
"""

import os
from werkzeug.datastructures import FileStorage
from typing import Dict, Any, Optional

def validate_audio_file(file: FileStorage) -> bool:
    """
    Validate uploaded audio file
    
    Args:
        file: Flask file upload object
        
    Returns:
        True if valid, False otherwise
    """
    if not file or not file.filename:
        return False
    
    # Check file extension
    allowed_extensions = {'.mp3', '.wav', '.m4a', '.aac', '.ogg', '.flac', '.webm'}
    file_ext = os.path.splitext(file.filename.lower())[1]
    
    if file_ext not in allowed_extensions:
        return False
    
    # Check file size (max 25MB)
    file.seek(0, os.SEEK_END)
    file_size = file.tell()
    file.seek(0)  # Reset file pointer
    
    max_size = 25 * 1024 * 1024  # 25MB
    if file_size > max_size:
        return False
    
    return True

def validate_text_input(data: Optional[Dict[str, Any]]) -> bool:
    """
    Validate text input for analysis
    
    Args:
        data: Request JSON data
        
    Returns:
        True if valid, False otherwise
    """
    if not data or not isinstance(data, dict):
        return False
    
    # Check required fields
    text = data.get('text', '').strip()
    if not text or len(text) < 10:
        return False
    
    # Check text length (max 5000 characters)
    if len(text) > 5000:
        return False
    
    # Validate optional fields
    category = data.get('category', 'general')
    valid_categories = {'general', 'behavioral', 'technical', 'leadership', 'situational'}
    if category not in valid_categories:
        return False
    
    return True

def validate_user_id(user_id: Optional[str]) -> bool:
    """
    Validate user ID format
    
    Args:
        user_id: User identifier string
        
    Returns:
        True if valid, False otherwise
    """
    if not user_id or not isinstance(user_id, str):
        return False
    
    # Basic validation - adjust based on your user ID format
    if len(user_id) < 3 or len(user_id) > 128:
        return False
    
    # Check for valid characters (alphanumeric, hyphens, underscores)
    import re
    if not re.match(r'^[a-zA-Z0-9_-]+$', user_id):
        return False
    
    return True

def validate_fcm_token(token: Optional[str]) -> bool:
    """
    Validate Firebase Cloud Messaging token
    
    Args:
        token: FCM token string
        
    Returns:
        True if valid, False otherwise
    """
    if not token or not isinstance(token, str):
        return False
    
    # FCM tokens are typically 152+ characters long
    if len(token) < 100:
        return False
    
    return True

def validate_date_range(start_date: Optional[str], end_date: Optional[str]) -> bool:
    """
    Validate date range parameters
    
    Args:
        start_date: Start date in ISO format
        end_date: End date in ISO format
        
    Returns:
        True if valid, False otherwise
    """
    if not start_date and not end_date:
        return True  # Both optional
    
    try:
        from datetime import datetime
        
        if start_date:
            start_dt = datetime.fromisoformat(start_date.replace('Z', '+00:00'))
        
        if end_date:
            end_dt = datetime.fromisoformat(end_date.replace('Z', '+00:00'))
        
        # If both provided, start should be before end
        if start_date and end_date:
            if start_dt >= end_dt:
                return False
        
        return True
        
    except (ValueError, AttributeError):
        return False