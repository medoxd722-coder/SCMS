from django.shortcuts import render, redirect
from django.contrib.auth import login as auth_login, logout as auth_logout
from django.contrib.auth.decorators import login_required
from django.db.models import Q
from .forms import CustomUserCreationForm
from .models import User


def login_view(request):
    """
    Direct credentials login (University ID or Username + Password).
    Automatically detects user access level (Student, Staff Advisor, or Admin) without manual role selection.
    Guest mode is completely removed.
    """
    if request.user.is_authenticated:
        return redirect('home')

    error_msg = None

    if request.method == 'POST':
        id_val = request.POST.get('username', '').strip()
        pw_val = request.POST.get('password', '').strip()

        if not id_val or not pw_val:
            error_msg = 'Please enter both your University ID or Username and your password.'
        else:
            # Look up existing user by username or university_id
            user = User.objects.filter(Q(username__iexact=id_val) | Q(university_id__iexact=id_val)).first()

            if user and user.check_password(pw_val):
                auth_login(request, user)
                return redirect(request.GET.get('next') or 'home')
            elif not user:
                # If non-existent student ID entered in demo, auto-create as student
                user = User.objects.create(
                    username=id_val,
                    university_id=id_val,
                    role=User.Role.STUDENT,
                    email=f"{id_val}@student.sut.example.edu",
                    first_name='Student',
                    last_name=id_val,
                )
                user.set_password(pw_val)
                user.save()
                auth_login(request, user)
                return redirect(request.GET.get('next') or 'home')
            else:
                error_msg = 'Incorrect password. Please verify your credentials and try again.'

    return render(request, 'registration/login.html', {'error': error_msg})


def logout_view(request):
    auth_logout(request)
    return redirect('home')


def register_view(request):
    if request.method == 'POST':
        form = CustomUserCreationForm(request.POST)
        if form.is_valid():
            user = form.save()
            auth_login(request, user)
            return redirect('home')
    else:
        form = CustomUserCreationForm()

    return render(request, 'registration/register.html', {'form': form})


@login_required
def profile_view(request):
    """Display logged-in user profile details and their recent complaints."""
    user = request.user
    if user.role in [user.Role.STAFF, user.Role.ADMIN]:
        if user.department:
            recent_complaints = user.department.complaints.all().order_by('-created_at')[:10]
        else:
            recent_complaints = user.assigned_complaints.all().order_by('-created_at')[:10]
    else:
        recent_complaints = user.submitted_complaints.all().order_by('-created_at')[:10]

    return render(request, 'accounts/profile.html', {
        'user': user,
        'recent_complaints': recent_complaints,
    })
