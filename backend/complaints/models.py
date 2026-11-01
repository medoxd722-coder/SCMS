from django.conf import settings
from django.core.validators import MinValueValidator, MaxValueValidator
from django.db import models


class Complaint(models.Model):
    class Visibility(models.TextChoices):
        PUBLIC_FORUM = 'PUBLIC_FORUM', 'Public Forum'
        PRIVATE_TICKET = 'PRIVATE_TICKET', 'Private Ticket'

    class Status(models.TextChoices):
        PENDING = 'PENDING', 'Pending'
        IN_PROGRESS = 'IN_PROGRESS', 'In Progress'
        RESOLVED = 'RESOLVED', 'Resolved'
        REJECTED = 'REJECTED', 'Rejected'

    class Priority(models.TextChoices):
        LOW = 'LOW', 'Low'
        MEDIUM = 'MEDIUM', 'Medium'
        HIGH = 'HIGH', 'High'
        URGENT = 'URGENT', 'Urgent'

    student = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='submitted_complaints',
    )
    department = models.ForeignKey(
        'departments.Department',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='complaints',
    )
    assigned_staff = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='assigned_complaints',
    )
    title = models.CharField(max_length=255)
    description = models.TextField()
    visibility = models.CharField(
        max_length=20,
        choices=Visibility.choices,
        default=Visibility.PRIVATE_TICKET,
    )
    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.PENDING,
    )
    priority = models.CharField(
        max_length=20,
        choices=Priority.choices,
        default=Priority.MEDIUM,
    )
    category = models.CharField(max_length=100, blank=True)
    is_solved_archive = models.BooleanField(
        default=False,
        help_text="True if saved to the searchable Solved Database",
    )
    resolved_at = models.DateTimeField(
        null=True,
        blank=True,
        help_text="Timestamp when complaint was marked resolved",
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Complaint'
        verbose_name_plural = 'Complaints'
        ordering = ['-created_at']

    def __str__(self):
        return f"#{self.pk or 'New'} - {self.title} [{self.get_status_display()}]"

    def save(self, *args, **kwargs):
        from django.utils import timezone
        if self.status == self.Status.RESOLVED and not self.resolved_at:
            self.resolved_at = timezone.now()
        elif self.status != self.Status.RESOLVED:
            self.resolved_at = None
        super().save(*args, **kwargs)


class ComplaintAttachment(models.Model):
    complaint = models.ForeignKey(
        Complaint,
        on_delete=models.CASCADE,
        related_name='attachments',
    )
    file = models.FileField(upload_to='complaint_attachments/%Y/%m/')
    uploaded_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Complaint Attachment'
        verbose_name_plural = 'Complaint Attachments'
        ordering = ['-uploaded_at']

    def __str__(self):
        return f"Attachment #{self.pk} for Complaint #{self.complaint_id}"


class ComplaintResponse(models.Model):
    complaint = models.ForeignKey(
        Complaint,
        on_delete=models.CASCADE,
        related_name='responses',
    )
    responder = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='complaint_responses',
    )
    message = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Complaint Response'
        verbose_name_plural = 'Complaint Responses'
        ordering = ['created_at']

    def __str__(self):
        return f"Response by {self.responder} on Complaint #{self.complaint_id}"


class ComplaintUpvote(models.Model):
    complaint = models.ForeignKey(
        Complaint,
        on_delete=models.CASCADE,
        related_name='upvotes',
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='upvoted_complaints',
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Complaint Upvote'
        verbose_name_plural = 'Complaint Upvotes'
        unique_together = ('complaint', 'user')

    def __str__(self):
        return f"{self.user} upvoted Complaint #{self.complaint_id}"


class ComplaintFeedback(models.Model):
    RATING_CHOICES = (
        (1, '1 - Very Poor'),
        (2, '2 - Poor'),
        (3, '3 - Average'),
        (4, '4 - Good'),
        (5, '5 - Excellent'),
    )

    complaint = models.OneToOneField(
        Complaint,
        on_delete=models.CASCADE,
        related_name='feedback',
    )
    rating = models.PositiveSmallIntegerField(
        choices=RATING_CHOICES,
        validators=[MinValueValidator(1), MaxValueValidator(5)],
    )
    comment = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Complaint Feedback'
        verbose_name_plural = 'Complaint Feedbacks'

    def __str__(self):
        return f"Feedback ({self.rating}/5) for Complaint #{self.complaint_id}"
