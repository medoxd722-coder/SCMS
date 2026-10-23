"""
URL configuration for core project.
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.shortcuts import render

# Django Admin Customization for El Sewedy University of Technology (SUT)
admin.site.site_header = 'SUT Complaint Management System'
admin.site.site_title = 'SUT Admin Portal'
admin.site.index_title = 'Smart University Database Administration'


def home_view(request):
    """Temporary home landing view for redirect targets until dashboard is built."""
    return render(request, 'home.html', {'user': request.user})


urlpatterns = [
    path('admin/', admin.site.urls),
    path('accounts/', include('accounts.urls')),
    path('complaints/', include('complaints.urls')),
    path('department/', include('departments.urls')),
    path('', home_view, name='home'),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
