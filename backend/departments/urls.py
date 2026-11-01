from django.urls import path
from .views import department_dashboard

urlpatterns = [
    path('', department_dashboard, name='department_dashboard'),
    path('dashboard/', department_dashboard, name='department_dashboard_alias'),
]
