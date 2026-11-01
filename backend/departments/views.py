from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from django.core.exceptions import PermissionDenied
from complaints.models import Complaint
from departments.models import Department


@login_required
def department_dashboard(request):
    """
    Restricted to STAFF and ADMIN.
    - Staff Advisors (e.g. Cybersecurity/IT, Registrar, etc.) CAN ONLY see complaints
      belonging strictly to their assigned department.
    - Administrators have higher access: they can review university-wide complaints
      and filter/sort by any department.
    """
    if request.user.role not in ['STAFF', 'ADMIN']:
        raise PermissionDenied("Only department staff and administrators can access this dashboard.")

    departments = Department.objects.all().order_by('name')
    selected_dept_code = request.GET.get('dept', '').strip()
    status_filter = request.GET.get('status', '').strip()

    if request.user.role == 'ADMIN':
        department = None
        if selected_dept_code:
            department = Department.objects.filter(code__iexact=selected_dept_code).first()
            complaints_qs = Complaint.objects.filter(department=department)
        else:
            complaints_qs = Complaint.objects.all()
    else:
        # STAFF: Strictly isolated to their own department
        department = request.user.department
        if department:
            complaints_qs = Complaint.objects.filter(department=department)
        else:
            complaints_qs = Complaint.objects.none()

    if status_filter:
        complaints_qs = complaints_qs.filter(status=status_filter)

    complaints = complaints_qs.select_related(
        'student', 'department', 'assigned_staff'
    ).prefetch_related(
        'responses', 'responses__responder'
    ).order_by('-created_at')

    context = {
        'department': department,
        'departments': departments,
        'selected_dept': selected_dept_code,
        'complaints': complaints,
        'status_filter': status_filter,
    }
    return render(request, 'departments/dashboard.html', context)
