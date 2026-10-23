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
    """Home dashboard view displaying public complaints and user private tickets."""
    from complaints.models import Complaint

    public_complaints = Complaint.objects.filter(
        visibility=Complaint.Visibility.PUBLIC_FORUM
    ).select_related('student', 'department').order_by('-created_at')[:8]

    my_private_complaints = Complaint.objects.none()
    if request.user.is_authenticated:
        if request.user.role == 'STAFF' and request.user.department:
            my_private_complaints = Complaint.objects.filter(
                department=request.user.department
            ).select_related('student', 'department').order_by('-created_at')[:8]
        else:
            my_private_complaints = Complaint.objects.filter(
                student=request.user
            ).select_related('department').order_by('-created_at')[:8]

    return render(request, 'home.html', {
        'public_complaints': public_complaints,
        'my_private_complaints': my_private_complaints,
    })


urlpatterns = [
    path('admin/', admin.site.urls),
    path('accounts/', include('accounts.urls')),
    path('complaints/', include('complaints.urls')),
    path('department/', include('departments.urls')),
    path('', home_view, name='home'),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
