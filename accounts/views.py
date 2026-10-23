from django.shortcuts import render, redirect
from django.contrib.auth import login as auth_login
from django.contrib.auth.decorators import login_required
from .forms import CustomUserCreationForm


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
    if user.role == user.Role.STAFF:
        recent_complaints = user.assigned_complaints.all().order_by('-created_at')[:10]
    else:
        recent_complaints = user.submitted_complaints.all().order_by('-created_at')[:10]

    context = {
        'user': user,
        'recent_complaints': recent_complaints,
    }
    return render(request, 'accounts/profile.html', context)
