from django.urls import path
from .views import (
    submit_complaint,
    complaint_detail,
    staff_update_complaint,
    submit_feedback,
    forum_view,
    archive_view,
    my_complaints_view,
    upvote_complaint,
)

urlpatterns = [
    path('', my_complaints_view, name='my_complaints'),
    path('submit/', submit_complaint, name='submit_complaint'),
    path('forum/', forum_view, name='forum'),
    path('archive/', archive_view, name='archive'),
    path('<int:id>/', complaint_detail, name='complaint_detail'),
    path('<int:id>/update/', staff_update_complaint, name='staff_update_complaint'),
    path('<int:id>/feedback/', submit_feedback, name='submit_feedback'),
    path('<int:id>/upvote/', upvote_complaint, name='upvote_complaint'),
]
