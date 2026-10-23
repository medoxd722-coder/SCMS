from django.contrib import admin
from .models import (
    Complaint,
    ComplaintAttachment,
    ComplaintResponse,
    ComplaintUpvote,
    ComplaintFeedback,
)


class ComplaintAttachmentInline(admin.TabularInline):
    model = ComplaintAttachment
    extra = 0
    readonly_fields = ('uploaded_at',)


class ComplaintResponseInline(admin.TabularInline):
    model = ComplaintResponse
    extra = 0
    readonly_fields = ('created_at',)


@admin.register(Complaint)
class ComplaintAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'title',
        'student',
        'department',
        'assigned_staff',
        'visibility',
        'status',
        'priority',
        'is_solved_archive',
        'created_at',
    )
    list_filter = (
        'visibility',
        'status',
        'priority',
        'department',
        'is_solved_archive',
    )
    search_fields = (
        'title',
        'description',
        'category',
        'student__username',
        'student__university_id',
    )
    inlines = [ComplaintAttachmentInline, ComplaintResponseInline]
    date_hierarchy = 'created_at'
    readonly_fields = ('created_at', 'updated_at')


@admin.register(ComplaintUpvote)
class ComplaintUpvoteAdmin(admin.ModelAdmin):
    list_display = ('id', 'complaint', 'user', 'created_at')
    list_filter = ('created_at',)
    search_fields = ('complaint__title', 'user__username', 'user__university_id')
    readonly_fields = ('created_at',)


@admin.register(ComplaintFeedback)
class ComplaintFeedbackAdmin(admin.ModelAdmin):
    list_display = ('id', 'complaint', 'rating', 'created_at')
    list_filter = ('rating', 'created_at')
    search_fields = ('complaint__title', 'comment')
    readonly_fields = ('created_at',)
