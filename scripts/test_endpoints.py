"""
Script to test API endpoints
"""

import requests
import json
import os
from dotenv import load_dotenv

load_dotenv()

BASE_URL = "http://localhost:5000"

def test_health_endpoint():
    """Test the health check endpoint"""
    print("Testing health endpoint...")
    response = requests.get(f"{BASE_URL}/health")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    print("-" * 50)

def test_analyze_endpoint():
    """Test the analyze endpoint"""
    print("Testing analyze endpoint...")
    
    data = {
        "text": "I am a software engineer with 5 years of experience in web development. I have worked on various projects using React, Node.js, and Python. I am passionate about creating user-friendly applications and solving complex problems.",
        "question": "Tell me about yourself",
        "category": "general"
    }
    
    response = requests.post(
        f"{BASE_URL}/analyze",
        json=data,
        headers={"Content-Type": "application/json"}
    )
    
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        result = response.json()
        print(f"Overall Score: {result.get('overall_score')}")
        print(f"Follow-up Question: {result.get('follow_up_question')}")
        print("Detailed Feedback:")
        for key, value in result.get('detailed_feedback', {}).items():
            if isinstance(value, dict) and 'score' in value:
                print(f"  {key}: {value['score']}/10")
    else:
        print(f"Error: {response.text}")
    
    print("-" * 50)

def test_questions_endpoint():
    """Test the questions endpoint"""
    print("Testing questions endpoint...")
    
    response = requests.get(f"{BASE_URL}/questions?category=general&difficulty=beginner&limit=3")
    
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        result = response.json()
        questions = result.get('questions', [])
        print(f"Found {len(questions)} questions:")
        for q in questions:
            print(f"  - {q.get('question')}")
    else:
        print(f"Error: {response.text}")
    
    print("-" * 50)

def test_transcribe_endpoint():
    """Test the transcribe endpoint (requires audio file)"""
    print("Testing transcribe endpoint...")
    
    # This would require an actual audio file
    # For now, just test the endpoint availability
    response = requests.post(f"{BASE_URL}/transcribe")
    
    print(f"Status: {response.status_code}")
    print(f"Response: {response.text}")
    print("Note: This endpoint requires an audio file to work properly")
    print("-" * 50)

if __name__ == '__main__':
    print("Testing AI Interview Coach Backend API")
    print("=" * 50)
    
    try:
        test_health_endpoint()
        test_analyze_endpoint()
        test_questions_endpoint()
        test_transcribe_endpoint()
        
        print("API testing completed!")
        
    except requests.exceptions.ConnectionError:
        print("Error: Could not connect to the server.")
        print("Make sure the Flask app is running on http://localhost:5000")
    except Exception as e:
        print(f"Error during testing: {str(e)}")