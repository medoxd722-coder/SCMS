import datetime
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.views.decorators.csrf import csrf_exempt
from django.core.exceptions import PermissionDenied
from django.http import JsonResponse
from django.contrib import messages
from django.db.models import Count, Q
from django.utils import timezone

from .models import (
    Complaint,
    ComplaintAttachment,
    ComplaintResponse,
    ComplaintFeedback,
    ComplaintUpvote,
)
from .forms import (
    ComplaintForm,
    AttachmentForm,
    ComplaintResponseForm,
    StatusUpdateForm,
    FeedbackForm,
)
from departments.models import Department
from accounts.models import User


@login_required
def submit_complaint(request):
    """
    Handle new complaint submission.
    Requires student login. Dynamically routes to correct department and assigns active staff.
    """
    if request.method == 'POST':
        title = request.POST.get('title', '').strip()
        description = request.POST.get('description', '').strip()
        category = request.POST.get('category', 'Registration & grades').strip()
        priority = request.POST.get('priority', Complaint.Priority.MEDIUM)
        visibility = request.POST.get('visibility', Complaint.Visibility.PRIVATE_TICKET)

        if not title or not description:
            return render(request, 'complaints/submit_complaint.html', {
                'error': 'Please provide both a subject and details for your complaint.'
            })

        # Department routing by category
        dept_code_map = {
            'Registration & grades': 'REG',
            'Study plan & courses': 'ADV',
            'Portal, Wi-Fi & accounts': 'IT',
            'Fees & payments': 'FIN',
            'Transport, housing & clubs': 'SA',
            'Labs, library & facilities': 'FAC',
        }
        target_code = dept_code_map.get(category, 'REG')
        department = Department.objects.filter(code=target_code).first()

        # If not found by code, try name or fallback to first department
        if not department:
            department = Department.objects.filter(name__icontains=category.split()[0]).first() or Department.objects.first()

        # Automatically route to an assigned staff member in this department
        assigned_staff = None
        if department:
            assigned_staff = department.staff_members.first()

        complaint = Complaint.objects.create(
            student=request.user,
            title=title,
            description=description,
            category=category,
            priority=priority,
            visibility=visibility,
            department=department,
            assigned_staff=assigned_staff,
            status=Complaint.Status.PENDING,
        )

        # Handle file attachment if uploaded
        if request.FILES.get('file'):
            ComplaintAttachment.objects.create(
                complaint=complaint,
                file=request.FILES['file'],
            )

        messages.success(request, f"Complaint #CD-{complaint.id} submitted successfully to {department.name if department else 'University Office'}.")
        return redirect('complaint_detail', id=complaint.id)

    return render(request, 'complaints/submit_complaint.html')


def complaint_detail(request, id):
    """
    Display a specific complaint, its attachments, responses, and feedback.
    Public forum complaints are viewable by anyone.
    Private tickets are restricted to the student submitter, staff of THAT department, or admin.
    Advisors from other departments cannot view or manage other departments' private tickets.
    """
    complaint = get_object_or_404(Complaint, id=id)

    # Access control: Private tickets
    if complaint.visibility == Complaint.Visibility.PRIVATE_TICKET:
        if not request.user.is_authenticated:
            return redirect('login')
        
        is_owner = (complaint.student == request.user)
        is_dept_staff = (request.user.role == 'STAFF' and request.user.department_id == complaint.department_id)
        is_admin = (request.user.role == 'ADMIN')

        if not (is_owner or is_dept_staff or is_admin):
            raise PermissionDenied("You do not have permission to view this private complaint. It belongs to another department or student.")

    # Determine if the current user has permission to manage/reply as staff to this complaint
    can_manage_as_staff = False
    if request.user.is_authenticated:
        if request.user.role == 'ADMIN':
            can_manage_as_staff = True
        elif request.user.role == 'STAFF' and request.user.department_id == complaint.department_id:
            can_manage_as_staff = True

    # Handle reply directly from detail page
    if request.method == 'POST':
        if not request.user.is_authenticated:
            return redirect('login')

        message = request.POST.get('message', '').strip()
        if message:
            # Enforce department isolation on staff replies
            if request.user.role == 'STAFF' and not can_manage_as_staff:
                raise PermissionDenied(f"You cannot post official responses to complaints outside your department ({complaint.department.name if complaint.department else 'General'}).")
            elif request.user.role == 'STUDENT' and complaint.student != request.user:
                raise PermissionDenied("You can only reply to your own complaints.")

            ComplaintResponse.objects.create(
                complaint=complaint,
                responder=request.user,
                message=message,
            )
            return redirect('complaint_detail', id=complaint.id)

    attachments = complaint.attachments.all()
    responses = complaint.responses.all().select_related('responder', 'responder__department')
    feedback = getattr(complaint, 'feedback', None)

    context = {
        'complaint': complaint,
        'attachments': attachments,
        'responses': responses,
        'feedback': feedback,
        'can_manage_as_staff': can_manage_as_staff,
    }
    return render(request, 'complaints/complaint_detail.html', context)


@login_required
def staff_update_complaint(request, id):
    """
    Restricted to STAFF of THIS complaint's department, or ADMIN.
    Advisors from other departments (e.g. IT/Cybersecurity vs Registrar) cannot manage other departments' complaints.
    """
    if request.user.role not in ['STAFF', 'ADMIN']:
        raise PermissionDenied("Only staff members can update complaints.")

    complaint = get_object_or_404(Complaint, id=id)

    # Department Isolation: Staff can ONLY manage complaints for their assigned department
    if request.user.role == 'STAFF':
        if not request.user.department or complaint.department_id != request.user.department_id:
            raise PermissionDenied(
                f"Access Denied: As a {request.user.department.name if request.user.department else 'Staff'} advisor, "
                f"you cannot manage tickets for {complaint.department.name if complaint.department else 'another department'}."
            )

    if request.method == 'POST':
        old_status = complaint.status
        status_form = StatusUpdateForm(request.POST, instance=complaint)
        response_form = ComplaintResponseForm(request.POST)

        if status_form.is_valid():
            updated_complaint = status_form.save(commit=False)
            # If changed to RESOLVED, save timestamp
            if updated_complaint.status == Complaint.Status.RESOLVED and not updated_complaint.resolved_at:
                updated_complaint.resolved_at = timezone.now()
            elif updated_complaint.status != Complaint.Status.RESOLVED:
                updated_complaint.resolved_at = None
            updated_complaint.save()

            if response_form.is_valid():
                message = response_form.cleaned_data.get('message', '').strip()
                if message:
                    response_obj = response_form.save(commit=False)
                    response_obj.complaint = updated_complaint
                    response_obj.responder = request.user
                    response_obj.save()

            messages.success(request, f"Complaint #CD-{complaint.id} updated successfully.")
            return redirect('complaint_detail', id=complaint.id)
    else:
        status_form = StatusUpdateForm(instance=complaint)
        response_form = ComplaintResponseForm()

    return render(request, 'complaints/staff_update.html', {
        'complaint': complaint,
        'status_form': status_form,
        'response_form': response_form,
    })


@login_required
def submit_feedback(request, id):
    """
    Allows a student to rate a resolved complaint.
    """
    complaint = get_object_or_404(Complaint, id=id)

    if request.user.role == 'STUDENT' and complaint.student != request.user:
        raise PermissionDenied("You can only submit feedback for your own complaints.")

    if complaint.status != Complaint.Status.RESOLVED:
        return redirect('complaint_detail', id=complaint.id)

    if hasattr(complaint, 'feedback'):
        return redirect('complaint_detail', id=complaint.id)

    if request.method == 'POST':
        form = FeedbackForm(request.POST)
        if form.is_valid():
            feedback = form.save(commit=False)
            feedback.complaint = complaint
            feedback.save()
            return redirect('complaint_detail', id=complaint.id)
    else:
        form = FeedbackForm()

    return render(request, 'complaints/submit_feedback.html', {
        'complaint': complaint,
        'form': form,
    })


def forum_view(request):
    """
    Public Forum stream:
    1. Higher upvotes raise the complaint to the top (ordered by -upvote_count, -created_at).
    2. Whenever an issue is RESOLVED, it stays on the forum wherever it ranks for exactly 1 day (24 hours).
       After 24 hours from resolution, it leaves the forum and goes to the Solved Archive.
    3. Supports department filtering.
    """
    if request.method == 'POST':
        if not request.user.is_authenticated:
            return redirect('login')

        title = request.POST.get('title', '').strip()
        description = request.POST.get('description', '').strip()
        category = request.POST.get('category', 'Registration & grades').strip()

        if title and description:
            dept_code_map = {
                'Registration & grades': 'REG',
                'Study plan & courses': 'ADV',
                'Portal, Wi-Fi & accounts': 'IT',
                'Fees & payments': 'FIN',
                'Transport, housing & clubs': 'SA',
                'Labs, library & facilities': 'FAC',
            }
            dept = Department.objects.filter(code=dept_code_map.get(category, 'REG')).first()

            Complaint.objects.create(
                student=request.user,
                title=title,
                description=description,
                category=category,
                visibility=Complaint.Visibility.PUBLIC_FORUM,
                department=dept,
                status=Complaint.Status.PENDING,
            )
            messages.success(request, "Your issue has been posted to the public forum.")
            return redirect('forum')

    one_day_ago = timezone.now() - datetime.timedelta(days=1)

    # 24-Hour Rule for Resolved Forum Issues:
    # Visible if NOT resolved, OR if resolved, resolved_at was within the last 24 hours.
    forum_filter = Q(visibility=Complaint.Visibility.PUBLIC_FORUM) & (
        ~Q(status=Complaint.Status.RESOLVED) | Q(resolved_at__gte=one_day_ago)
    )

    # Department filter from GET
    dept_code = request.GET.get('dept', '').strip()
    if dept_code:
        forum_filter &= Q(department__code__iexact=dept_code)

    # Search filter from GET
    q = request.GET.get('q', '').strip()
    if q:
        forum_filter &= (Q(title__icontains=q) | Q(description__icontains=q))

    # Query with upvotes annotation and rank by higher upvotes first!
    posts = Complaint.objects.filter(
        forum_filter
    ).select_related('student', 'department').prefetch_related(
        'responses', 'upvotes', 'responses__responder'
    ).annotate(
        upvote_count=Count('upvotes')
    ).order_by('-upvote_count', '-created_at')

    # User upvotes: strictly per authenticated user
    user_upvotes = set()
    if request.user.is_authenticated:
        user_upvotes = set(request.user.upvoted_complaints.values_list('complaint_id', flat=True))

    for p in posts:
        p.user_has_upvoted = p.id in user_upvotes

    departments = Department.objects.all().order_by('name')

    return render(request, 'complaints/forum.html', {
        'forum_posts': posts,
        'user_upvotes': user_upvotes,
        'departments': departments,
        'selected_dept': dept_code,
        'search_query': q,
    })


def archive_view(request):
    """
    Solved complaints answers archive:
    Houses all complaints with status = RESOLVED (including older forum tickets after their 1-day mark).
    Supports search and department filtering.
    """
    dept_code = request.GET.get('dept', '').strip()
    q = request.GET.get('q', '').strip()

    archive_filter = Q(status=Complaint.Status.RESOLVED)
    if dept_code:
        archive_filter &= Q(department__code__iexact=dept_code)
    if q:
        archive_filter &= (Q(title__icontains=q) | Q(description__icontains=q))

    archive_items = Complaint.objects.filter(
        archive_filter
    ).select_related('student', 'department', 'assigned_staff').prefetch_related('responses').order_by('-resolved_at', '-updated_at')

    departments = Department.objects.all().order_by('name')

    return render(request, 'complaints/archive.html', {
        'archive_items': archive_items,
        'departments': departments,
        'selected_dept': dept_code,
        'search_query': q,
    })


@login_required
def my_complaints_view(request):
    """
    Displays complaints relevant to the logged-in user:
    - Students: their own complaints
    - Staff: complaints within THEIR department
    - Admin: complaints across all departments
    """
    if request.user.role == 'STUDENT':
        complaints = Complaint.objects.filter(student=request.user).select_related('department', 'assigned_staff').prefetch_related('responses', 'responses__responder').order_by('-created_at')
    elif request.user.role == 'STAFF':
        if request.user.department:
            complaints = Complaint.objects.filter(department=request.user.department).select_related('student', 'department', 'assigned_staff').prefetch_related('responses', 'responses__responder').order_by('-created_at')
        else:
            complaints = Complaint.objects.none()
    else:  # ADMIN
        dept_code = request.GET.get('dept', '').strip()
        qs = Complaint.objects.all().select_related('student', 'department', 'assigned_staff').prefetch_related('responses', 'responses__responder')
        if dept_code:
            qs = qs.filter(department__code__iexact=dept_code)
        complaints = qs.order_by('-created_at')

    departments = Department.objects.all().order_by('name')

    return render(request, 'complaints/my_complaints.html', {
        'complaints': complaints,
        'departments': departments,
        'selected_dept': request.GET.get('dept', ''),
    })


@csrf_exempt
def upvote_complaint(request, id):
    """
    Toggle upvote for a public complaint.
    Strictly authenticated: each user has their own independent vote.
    """
    if not request.user.is_authenticated:
        is_ajax = (
            request.headers.get('x-requested-with') == 'XMLHttpRequest' or
            request.GET.get('format') == 'json' or
            request.POST.get('format') == 'json' or
            'application/json' in request.headers.get('Accept', '')
        )
        if is_ajax:
            return JsonResponse({'status': 'login_required', 'redirect': '/accounts/login/'}, status=401)
        return redirect('login')

    complaint = get_object_or_404(Complaint, id=id)

    # Vote belongs to request.user
    existing = ComplaintUpvote.objects.filter(complaint=complaint, user=request.user).first()
    if existing:
        existing.delete()
        upvoted = False
    else:
        ComplaintUpvote.objects.create(complaint=complaint, user=request.user)
        upvoted = True

    count = complaint.upvotes.count()

    is_ajax = (
        request.headers.get('x-requested-with') == 'XMLHttpRequest' or
        request.GET.get('format') == 'json' or
        request.POST.get('format') == 'json' or
        'application/json' in request.headers.get('Accept', '')
    )
    if is_ajax:
        return JsonResponse({'status': 'ok', 'upvoted': upvoted, 'count': count})

    referer = request.META.get('HTTP_REFERER')
    if referer:
        return redirect(referer)
    return redirect('forum')
