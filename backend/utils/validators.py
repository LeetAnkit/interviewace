"""
Input validation utilities
"""

import os
from werkzeug.datastructures import FileStorage
from typing import Dict, Any, Optional

def validate_audio_file(file: FileStorage) -> bool:
    """Validate uploaded audio file"""
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
    file.seek(0)
    
    max_size = 25 * 1024 * 1024  # 25MB
    if file_size > max_size:
        return False
    
    return True

def validate_text_input(data: Optional[Dict[str, Any]]) -> bool:
    """Validate text input for analysis"""
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
    """Validate user ID format"""
    if not user_id or not isinstance(user_id, str):
        return False
    
    if len(user_id) < 3 or len(user_id) > 128:
        return False
    
    import re
    if not re.match(r'^[a-zA-Z0-9_-]+$', user_id):
        return False
    
    return True