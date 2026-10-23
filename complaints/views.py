from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.core.exceptions import PermissionDenied
from .models import Complaint, ComplaintAttachment, ComplaintResponse, ComplaintFeedback
from .forms import (
    ComplaintForm,
    AttachmentForm,
    ComplaintResponseForm,
    StatusUpdateForm,
    FeedbackForm,
)
from ai_module.services import analyze_complaint
from departments.models import Department


@login_required
def submit_complaint(request):
    """Handle new complaint submission with optional attachment and AI heuristic classification."""
    if request.method == 'POST':
        complaint_form = ComplaintForm(request.POST)
        attachment_form = AttachmentForm(request.POST, request.FILES)

        if complaint_form.is_valid() and attachment_form.is_valid():
            complaint = complaint_form.save(commit=False)
            complaint.student = request.user

            # AI classification heuristic fallback
            ai_data = analyze_complaint(complaint.title, complaint.description)
            if not complaint.category:
                complaint.category = ai_data.get('category', '')
            if not complaint.department:
                dept = Department.objects.filter(code=ai_data.get('department_code')).first()
                if dept:
                    complaint.department = dept

            complaint.save()

            # Handle file attachment if uploaded
            if request.FILES.get('file'):
                attachment = attachment_form.save(commit=False)
                attachment.complaint = complaint
                attachment.save()

            return redirect('complaint_detail', id=complaint.id)
    else:
        complaint_form = ComplaintForm()
        attachment_form = AttachmentForm()

    context = {
        'complaint_form': complaint_form,
        'attachment_form': attachment_form,
    }
    return render(request, 'complaints/submit_complaint.html', context)


@login_required
def complaint_detail(request, id):
    """
    Display a specific complaint, its attachments, responses, and feedback.
    Students can only view public complaints or their own private tickets.
    """
    complaint = get_object_or_404(Complaint, id=id)

    # Access control: Private tickets only visible to submitter, staff, or admin
    if complaint.visibility == Complaint.Visibility.PRIVATE_TICKET:
        if request.user.role == 'STUDENT' and complaint.student != request.user:
            raise PermissionDenied("You do not have permission to view this private complaint.")

    attachments = complaint.attachments.all()
    responses = complaint.responses.all().select_related('responder')
    feedback = getattr(complaint, 'feedback', None)

    context = {
        'complaint': complaint,
        'attachments': attachments,
        'responses': responses,
        'feedback': feedback,
    }
    return render(request, 'complaints/complaint_detail.html', context)


@login_required
def staff_update_complaint(request, id):
    """
    Restricted to STAFF/ADMIN. Allows changing status/priority and leaving a response simultaneously.
    """
    if request.user.role not in ['STAFF', 'ADMIN']:
        raise PermissionDenied("Only staff members can update complaints.")

    complaint = get_object_or_404(Complaint, id=id)

    if request.method == 'POST':
        status_form = StatusUpdateForm(request.POST, instance=complaint)
        response_form = ComplaintResponseForm(request.POST)

        if status_form.is_valid():
            status_form.save()

            if response_form.is_valid():
                message = response_form.cleaned_data.get('message', '').strip()
                if message:
                    response_obj = response_form.save(commit=False)
                    response_obj.complaint = complaint
                    response_obj.responder = request.user
                    response_obj.save()

            return redirect('complaint_detail', id=complaint.id)
    else:
        status_form = StatusUpdateForm(instance=complaint)
        response_form = ComplaintResponseForm()

    context = {
        'complaint': complaint,
        'status_form': status_form,
        'response_form': response_form,
    }
    return render(request, 'complaints/staff_update.html', context)


@login_required
def submit_feedback(request, id):
    """Allows student to rate and leave feedback on a resolved complaint."""
    complaint = get_object_or_404(Complaint, id=id)

    if complaint.student != request.user:
        raise PermissionDenied("Only the student who submitted this complaint can leave feedback.")

    if complaint.status != Complaint.Status.RESOLVED:
        return redirect('complaint_detail', id=complaint.id)

    feedback_instance = getattr(complaint, 'feedback', None)

    if request.method == 'POST':
        form = FeedbackForm(request.POST, instance=feedback_instance)
        if form.is_valid():
            feedback_obj = form.save(commit=False)
            feedback_obj.complaint = complaint
            feedback_obj.save()
            return redirect('complaint_detail', id=complaint.id)
    else:
        form = FeedbackForm(instance=feedback_instance)

    context = {
        'complaint': complaint,
        'form': form,
    }
    return render(request, 'complaints/submit_feedback.html', context)
