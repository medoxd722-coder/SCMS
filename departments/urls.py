from django.urls import path
from .views import department_dashboard

urlpatterns = [
    path('dashboard/', department_dashboard, name='department_dashboard'),
]
