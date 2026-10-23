from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    class Role(models.TextChoices):
        STUDENT = 'STUDENT', 'Student'
        STAFF = 'STAFF', 'Staff'
        ADMIN = 'ADMIN', 'Admin'

    university_id = models.CharField(
        max_length=50,
        unique=True,
        help_text="Student or Staff University ID",
    )
    role = models.CharField(
        max_length=20,
        choices=Role.choices,
        default=Role.STUDENT,
    )
    department = models.ForeignKey(
        'departments.Department',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='staff_members',
        help_text="Assigned department for staff members",
    )

    REQUIRED_FIELDS = ['email', 'university_id']

    class Meta:
        verbose_name = 'User'
        verbose_name_plural = 'Users'
        ordering = ['username']

    def __str__(self):
        return f"{self.username} ({self.university_id}) - {self.get_role_display()}"

    def save(self, *args, **kwargs):
        """Automatically sync is_staff and is_superuser based on assigned role."""
        if self.role == self.Role.ADMIN:
            self.is_staff = True
            self.is_superuser = True
        elif self.role == self.Role.STAFF:
            self.is_staff = True
            self.is_superuser = False
        elif self.role == self.Role.STUDENT:
            self.is_staff = False
            self.is_superuser = False

        super().save(*args, **kwargs)
