"""
AI Module Services for SCMS (Smart University Complaint Management System)

This module provides NLP analysis, categorization, priority prediction,
and duplicate/similarity detection. It includes keyword-based fallback heuristics
designed to be seamlessly replaced or enhanced by ML/NLP pipelines (e.g., Hugging Face,
FastText, OpenAI, or local PyTorch/TensorFlow embeddings).
"""

from typing import Dict, Any, List
import re
from django.db.models import Q


def analyze_complaint(title: str, description: str) -> Dict[str, Any]:
    """
    Analyze a complaint's title and description to predict:
    - category
    - priority ('LOW', 'MEDIUM', 'HIGH', 'URGENT')
    - recommended department_code (e.g., 'IT', 'REG', 'ADV', 'FAC', 'FIN')

    Returns:
        dict: {
            'category': str,
            'priority': str,
            'department_code': str,
            'confidence': float,
            'is_ai_generated': bool,
        }
    """
    combined_text = f"{title} {description}".lower()

    # Default baseline predictions
    predicted_category = "General Inquiry"
    predicted_priority = "MEDIUM"
    recommended_dept = "IT"
    confidence = 0.65

    # 1. Department & Category keyword mapping
    keyword_dept_map = [
        (
            r'\b(wifi|internet|network|portal|login|password|canvas|blackboard|email|server|account locked|software|laptop|pc)\b',
            'IT',
            'IT & Technical Support',
        ),
        (
            r'\b(register|registration|enroll|enrollment|transcript|graduation|degree|prerequisite|add/drop|admission|diploma)\b',
            'REG',
            'Admissions & Registration',
        ),
        (
            r'\b(advisor|advising|academic|curriculum|major|minor|gpa|probation|warning|course plan)\b',
            'ADV',
            'Academic Advising',
        ),
        (
            r'\b(tuition|fees|payment|invoice|scholarship|refund|finance|billing|bursar)\b',
            'FIN',
            'Finance & Student Accounts',
        ),
        (
            r'\b(ac|air condition|elevator|restroom|bathroom|leak|parking|chair|desk|projector|classroom|cafeteria|maintenance|clean)\b',
            'FAC',
            'Campus Facilities & Maintenance',
        ),
    ]

    for pattern, dept_code, category in keyword_dept_map:
        if re.search(pattern, combined_text):
            recommended_dept = dept_code
            predicted_category = category
            confidence = 0.85
            break

    # 2. Priority heuristic mapping
    urgent_keywords = r'\b(urgent|emergency|flood|fire|hazard|danger|immediate|exam today|lockout|harassment)\b'
    high_keywords = r'\b(deadline|cannot access|blocked|exam|midterm|final|payment failed|unable to submit|error 500)\b'
    low_keywords = r'\b(suggestion|idea|minor|typo|feature request|feedback|optional|inquiry)\b'

    if re.search(urgent_keywords, combined_text):
        predicted_priority = 'URGENT'
        confidence = max(confidence, 0.90)
    elif re.search(high_keywords, combined_text):
        predicted_priority = 'HIGH'
        confidence = max(confidence, 0.80)
    elif re.search(low_keywords, combined_text):
        predicted_priority = 'LOW'
        confidence = max(confidence, 0.75)

    return {
        'category': predicted_category,
        'priority': predicted_priority,
        'department_code': recommended_dept,
        'confidence': confidence,
        'is_ai_generated': False,  # Switch to True when ML inference pipeline is connected
    }


def find_similar_complaints(text: str, limit: int = 5):
    """
    Find existing public or solved complaints similar to the input text.
    Uses database keyword matching as a fallback until vector embeddings / semantic search
    are integrated by the Data Science team.

    Args:
        text (str): Title or description snippet to match against.
        limit (int): Maximum number of similar records to return.

    Returns:
        QuerySet: Filtered Complaint objects matching resolved/archive criteria.
    """
    from complaints.models import Complaint

    if not text or not text.strip():
        return Complaint.objects.none()

    # Filter only resolved or public forum / archive solved tickets
    base_qs = Complaint.objects.filter(
        Q(is_solved_archive=True) |
        Q(status=Complaint.Status.RESOLVED, visibility=Complaint.Visibility.PUBLIC_FORUM)
    )

    # Extract meaningful words (min length 4) for basic search fallback
    words = [re.escape(w) for w in re.findall(r'\b\w{4,}\b', text.lower())]
    if not words:
        return base_qs[:limit]

    query_filter = Q()
    for word in words[:6]:  # Limit to top 6 keywords to keep query performant
        query_filter |= Q(title__icontains=word) | Q(description__icontains=word)

    return base_qs.filter(query_filter).distinct()[:limit]
