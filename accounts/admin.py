from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.utils.translation import gettext_lazy as _
from .models import User


@admin.register(User)
class CustomUserAdmin(UserAdmin):
    model = User
    list_display = (
        'username',
        'university_id',
        'email',
        'first_name',
        'last_name',
        'role',
        'department',
        'is_staff',
    )
    list_filter = ('role', 'department', 'is_staff', 'is_superuser', 'is_active')
    search_fields = ('username', 'university_id', 'email', 'first_name', 'last_name')
    ordering = ('username',)

    fieldsets = UserAdmin.fieldsets + (
        (
            _('University Profile'),
            {
                'fields': ('university_id', 'role', 'department'),
            },
        ),
    )

    add_fieldsets = UserAdmin.add_fieldsets + (
        (
            _('University Profile'),
            {
                'classes': ('wide',),
                'fields': ('university_id', 'role', 'department'),
            },
        ),
    )
