"""
AI Analysis Service using OpenAI GPT-4 for interview response analysis
"""

import openai
import os
import json
import logging
import re
from typing import Dict, Any, List

logger = logging.getLogger(__name__)

class AnalysisService:
    def __init__(self):
        """Initialize the analysis service with OpenAI API key"""
        self.client = openai.OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
        
    def analyze_interview_response(self, text: str, question: str = "", category: str = "general") -> Dict[str, Any]:
        """
        Analyze interview response using GPT-4
        
        Args:
            text: User's interview response
            question: Original interview question
            category: Question category (behavioral, technical, general)
            
        Returns:
            Dict containing analysis results and scores
        """
        try:
            prompt = self._create_analysis_prompt(text, question, category)
            
            response = self.client.chat.completions.create(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": self._get_system_prompt()},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.3,
                max_tokens=1500
            )
            
            analysis_text = response.choices[0].message.content
            analysis_result = self._parse_analysis_response(analysis_text)
            
            # Add filler word analysis
            filler_analysis = self._analyze_filler_words(text)
            analysis_result['detailed_feedback']['filler_words'] = filler_analysis
            
            # Calculate overall score
            analysis_result['overall_score'] = self._calculate_overall_score(analysis_result['detailed_feedback'])
            
            return analysis_result
            
        except Exception as e:
            logger.error(f"Analysis failed: {str(e)}")
            raise Exception(f"Failed to analyze response: {str(e)}")
    
    def generate_follow_up_question(self, original_question: str, user_response: str, category: str = "general") -> str:
        """Generate a follow-up interview question based on the user's response"""
        try:
            prompt = f"""
            Based on the following interview exchange, generate ONE thoughtful follow-up question that:
            1. Digs deeper into the candidate's experience
            2. Tests their problem-solving or critical thinking
            3. Is relevant to the {category} category
            4. Encourages specific examples or details
            
            Original Question: {original_question}
            Candidate's Response: {user_response}
            
            Generate a single, well-crafted follow-up question:
            """
            
            response = self.client.chat.completions.create(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": "You are an expert interviewer who asks insightful follow-up questions."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=200
            )
            
            follow_up = response.choices[0].message.content.strip()
            follow_up = re.sub(r'^["\']*|["\']*$', '', follow_up)
            
            return follow_up
            
        except Exception as e:
            logger.error(f"Follow-up generation failed: {str(e)}")
            return "Can you provide a specific example from your experience that demonstrates this skill?"
    
    def _get_system_prompt(self) -> str:
        """Get the system prompt for GPT-4 analysis"""
        return """
        You are an expert interview coach and HR professional. Analyze interview responses across these dimensions:
        1. Content Quality (0-10): Relevance, depth, and substance
        2. Communication Clarity (0-10): How clearly the message is conveyed
        3. Confidence Level (0-10): Apparent confidence and conviction
        4. Structure & Organization (0-10): Logical flow and organization
        5. Professionalism (0-10): Professional tone and language
        
        Provide analysis in this JSON format:
        {
            "content_quality": {"score": X, "feedback": "detailed feedback"},
            "communication_clarity": {"score": X, "feedback": "detailed feedback"},
            "confidence_level": {"score": X, "feedback": "detailed feedback"},
            "structure_organization": {"score": X, "feedback": "detailed feedback"},
            "professionalism": {"score": X, "feedback": "detailed feedback"},
            "strengths": ["strength 1", "strength 2"],
            "areas_for_improvement": ["improvement 1", "improvement 2"],
            "suggestions": ["suggestion 1", "suggestion 2", "suggestion 3"]
        }
        
        Be constructive, specific, and encouraging.
        """
    
    def _create_analysis_prompt(self, text: str, question: str, category: str) -> str:
        """Create the analysis prompt for GPT-4"""
        return f"""
        Please analyze this interview response:
        
        Question Category: {category}
        Original Question: {question if question else "Not provided"}
        
        Candidate's Response:
        "{text}"
        
        Provide a comprehensive analysis following the JSON format specified.
        """
    
    def _parse_analysis_response(self, analysis_text: str) -> Dict[str, Any]:
        """Parse GPT-4 analysis response into structured data"""
        try:
            json_match = re.search(r'\{.*\}', analysis_text, re.DOTALL)
            if json_match:
                json_str = json_match.group()
                analysis_data = json.loads(json_str)
            else:
                analysis_data = self._fallback_parse(analysis_text)
            
            return {
                'detailed_feedback': analysis_data,
                'suggestions': analysis_data.get('suggestions', [])
            }
            
        except Exception as e:
            logger.warning(f"Failed to parse analysis response: {str(e)}")
            return self._get_default_analysis()
    
    def _fallback_parse(self, text: str) -> Dict[str, Any]:
        """Fallback parsing method if JSON parsing fails"""
        return {
            'content_quality': {'score': 7, 'feedback': 'Analysis parsing failed, using default scores'},
            'communication_clarity': {'score': 7, 'feedback': 'Please try again'},
            'confidence_level': {'score': 7, 'feedback': 'Analysis temporarily unavailable'},
            'structure_organization': {'score': 7, 'feedback': 'Default feedback'},
            'professionalism': {'score': 7, 'feedback': 'Default feedback'},
            'strengths': ['Response provided'],
            'areas_for_improvement': ['Try speaking more clearly'],
            'suggestions': ['Practice your response structure', 'Provide specific examples']
        }
    
    def _analyze_filler_words(self, text: str) -> Dict[str, Any]:
        """Analyze filler words in the response"""
        filler_words = ['um', 'uh', 'like', 'you know', 'so', 'well', 'actually', 'basically', 'literally']
        
        text_lower = text.lower()
        filler_count = {}
        total_fillers = 0
        
        for filler in filler_words:
            count = len(re.findall(r'\b' + re.escape(filler) + r'\b', text_lower))
            if count > 0:
                filler_count[filler] = count
                total_fillers += count
        
        word_count = len(text.split())
        filler_percentage = (total_fillers / word_count * 100) if word_count > 0 else 0
        
        if filler_percentage == 0:
            score = 10
        elif filler_percentage < 2:
            score = 9
        elif filler_percentage < 5:
            score = 7
        elif filler_percentage < 10:
            score = 5
        else:
            score = max(1, 10 - int(filler_percentage))
        
        return {
            'score': score,
            'total_count': total_fillers,
            'percentage': round(filler_percentage, 1),
            'breakdown': filler_count,
            'feedback': self._get_filler_feedback(total_fillers, filler_percentage)
        }
    
    def _get_filler_feedback(self, count: int, percentage: float) -> str:
        """Generate feedback for filler word usage"""
        if percentage == 0:
            return "Excellent! No filler words detected. Your speech is clear and confident."
        elif percentage < 2:
            return "Very good! Minimal use of filler words. Your communication is quite polished."
        elif percentage < 5:
            return "Good control of filler words, but there's room for improvement."
        elif percentage < 10:
            return "Moderate use of filler words detected. Focus on slowing down and thinking before speaking."
        else:
            return "High usage of filler words may distract from your message. Practice speaking more deliberately."
    
    def _calculate_overall_score(self, detailed_feedback: Dict[str, Any]) -> float:
        """Calculate overall score from detailed feedback"""
        try:
            scores = []
            for key, value in detailed_feedback.items():
                if isinstance(value, dict) and 'score' in value:
                    scores.append(value['score'])
            
            if not scores:
                return 7.0
            
            return round(sum(scores) / len(scores), 1)
            
        except Exception as e:
            logger.warning(f"Failed to calculate overall score: {str(e)}")
            return 7.0
    
    def _get_default_analysis(self) -> Dict[str, Any]:
        """Get default analysis structure if parsing fails"""
        return {
            'detailed_feedback': {
                'content_quality': {'score': 7, 'feedback': 'Analysis temporarily unavailable'},
                'communication_clarity': {'score': 7, 'feedback': 'Please try again'},
                'confidence_level': {'score': 7, 'feedback': 'Default feedback'},
                'structure_organization': {'score': 7, 'feedback': 'Default feedback'},
                'professionalism': {'score': 7, 'feedback': 'Default feedback'},
                'strengths': ['Response provided'],
                'areas_for_improvement': ['Analysis pending'],
                'suggestions': ['Please try submitting your response again']
            },
            'suggestions': ['Please try submitting your response again'],
            'overall_score': 7.0
        }