from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from django.core.exceptions import PermissionDenied
from complaints.models import Complaint


@login_required
def department_dashboard(request):
    """
    Restricted to STAFF and ADMIN.
    Queries pending and in-progress complaints assigned to the staff user's department.
    """
    if request.user.role not in ['STAFF', 'ADMIN']:
        raise PermissionDenied("Only department staff and administrators can access this dashboard.")

    department = request.user.department

    if department:
        complaints = Complaint.objects.filter(
            department=department,
            status__in=[Complaint.Status.PENDING, Complaint.Status.IN_PROGRESS],
        ).select_related('student', 'assigned_staff').order_by('-created_at')
    else:
        if request.user.role == 'ADMIN':
            complaints = Complaint.objects.filter(
                status__in=[Complaint.Status.PENDING, Complaint.Status.IN_PROGRESS],
            ).select_related('student', 'department', 'assigned_staff').order_by('-created_at')
        else:
            complaints = Complaint.objects.none()

    context = {
        'department': department,
        'complaints': complaints,
    }
    return render(request, 'departments/dashboard.html', context)
