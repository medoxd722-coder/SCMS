from django.urls import path
from .views import (
    submit_complaint,
    complaint_detail,
    staff_update_complaint,
    submit_feedback,
)

urlpatterns = [
    path('submit/', submit_complaint, name='submit_complaint'),
    path('<int:id>/', complaint_detail, name='complaint_detail'),
    path('<int:id>/update/', staff_update_complaint, name='staff_update_complaint'),
    path('<int:id>/feedback/', submit_feedback, name='submit_feedback'),
]
