"""
URL configuration for core project.
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.shortcuts import render
from complaints.views import forum_view, archive_view, my_complaints_view

# Django Admin Customization for El Sewedy University of Technology (SUT)
admin.site.site_header = 'SUT Complaint Management System'
admin.site.site_title = 'SUT Admin Portal'
admin.site.index_title = 'Smart University Database Administration'


def home_view(request):
    """Home dashboard view displaying public complaints and user private tickets."""
    import datetime
    from django.db.models import Count, Q
    from django.utils import timezone
    from complaints.models import Complaint

    one_day_ago = timezone.now() - datetime.timedelta(days=1)
    forum_filter = Q(visibility=Complaint.Visibility.PUBLIC_FORUM) & (
        ~Q(status=Complaint.Status.RESOLVED) | Q(resolved_at__gte=one_day_ago)
    )

    public_complaints = Complaint.objects.filter(
        forum_filter
    ).select_related('student', 'department').prefetch_related('upvotes').annotate(
        upvote_count=Count('upvotes')
    ).order_by('-upvote_count', '-created_at')[:8]

    # Annotate user upvotes
    user_upvotes = set()
    if request.user.is_authenticated:
        user_upvotes = set(request.user.upvoted_complaints.values_list('complaint_id', flat=True))

    my_private_complaints = Complaint.objects.none()
    if request.user.is_authenticated:
        if request.user.role == 'STAFF':
            if request.user.department:
                my_private_complaints = Complaint.objects.filter(
                    department=request.user.department
                ).select_related('student', 'department', 'assigned_staff').order_by('-created_at')[:8]
        elif request.user.role == 'ADMIN':
            my_private_complaints = Complaint.objects.all().select_related('student', 'department', 'assigned_staff').order_by('-created_at')[:8]
        else:
            my_private_complaints = Complaint.objects.filter(
                student=request.user
            ).select_related('department', 'assigned_staff').order_by('-created_at')[:8]

    return render(request, 'home.html', {
        'public_complaints': public_complaints,
        'my_private_complaints': my_private_complaints,
        'user_upvotes': user_upvotes,
    })


urlpatterns = [
    path('admin/', admin.site.urls),
    path('accounts/', include('accounts.urls')),
    path('complaints/', include('complaints.urls')),
    path('department/', include('departments.urls')),
    path('forum/', forum_view, name='forum'),
    path('archive/', archive_view, name='archive'),
    path('my-complaints/', my_complaints_view, name='my_complaints'),
    path('', home_view, name='home'),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
