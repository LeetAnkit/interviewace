"""
Audio Transcription Service using OpenAI Whisper API
"""

import openai
import os
import tempfile
import logging
from pydub import AudioSegment
from typing import Dict, Any

logger = logging.getLogger(__name__)

class TranscriptionService:
    def __init__(self):
        """Initialize the transcription service with OpenAI API key"""
        self.client = openai.OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
        
    def transcribe(self, audio_file) -> Dict[str, Any]:
        """
        Transcribe audio file using OpenAI Whisper API
        
        Args:
            audio_file: Flask file object containing audio data
            
        Returns:
            Dict containing transcription text, duration, and confidence
        """
        try:
            # Save uploaded file temporarily
            with tempfile.NamedTemporaryFile(delete=False, suffix='.wav') as temp_file:
                audio_file.save(temp_file.name)
                
                # Convert to supported format if needed
                audio_path = self._convert_audio_format(temp_file.name)
                
                # Get audio duration
                duration = self._get_audio_duration(audio_path)
                
                # Transcribe using OpenAI Whisper
                with open(audio_path, 'rb') as audio:
                    transcript = self.client.audio.transcriptions.create(
                        model="whisper-1",
                        file=audio,
                        response_format="verbose_json",
                        language="en"
                    )
                
                # Clean up temporary files
                os.unlink(temp_file.name)
                if audio_path != temp_file.name:
                    os.unlink(audio_path)
                
                return {
                    'text': transcript.text.strip(),
                    'duration': duration,
                    'confidence': self._calculate_confidence(transcript),
                    'language': getattr(transcript, 'language', 'en')
                }
                
        except Exception as e:
            logger.error(f"Transcription failed: {str(e)}")
            raise Exception(f"Failed to transcribe audio: {str(e)}")
    
    def _convert_audio_format(self, input_path: str) -> str:
        """Convert audio to a format supported by Whisper API"""
        try:
            audio = AudioSegment.from_file(input_path)
            output_path = input_path.replace('.wav', '_converted.wav')
            audio = audio.set_frame_rate(16000)
            audio = audio.set_channels(1)
            audio.export(output_path, format="wav")
            return output_path
        except Exception as e:
            logger.warning(f"Audio conversion failed, using original: {str(e)}")
            return input_path
    
    def _get_audio_duration(self, audio_path: str) -> float:
        """Get duration of audio file in seconds"""
        try:
            audio = AudioSegment.from_file(audio_path)
            return len(audio) / 1000.0
        except Exception as e:
            logger.warning(f"Could not determine audio duration: {str(e)}")
            return 0.0
    
    def _calculate_confidence(self, transcript) -> float:
        """Calculate confidence score based on transcript metadata"""
        try:
            text = transcript.text.strip()
            if not text:
                return 0.0
            
            confidence = 0.95
            
            if len(text) < 10:
                confidence -= 0.1
            
            unclear_markers = ['[inaudible]', '[unclear]', '...', 'um', 'uh']
            unclear_count = sum(text.lower().count(marker) for marker in unclear_markers)
            confidence -= min(unclear_count * 0.05, 0.3)
            
            return max(confidence, 0.1)
            
        except Exception as e:
            logger.warning(f"Could not calculate confidence: {str(e)}")
            return 0.8