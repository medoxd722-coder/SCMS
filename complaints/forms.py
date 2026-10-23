from django import forms
from .models import (
    Complaint,
    ComplaintAttachment,
    ComplaintResponse,
    ComplaintFeedback,
)


class ComplaintForm(forms.ModelForm):
    class Meta:
        model = Complaint
        fields = ['title', 'description', 'visibility']
        widgets = {
            'title': forms.TextInput(attrs={'placeholder': 'Brief summary of the issue'}),
            'description': forms.Textarea(attrs={'rows': 5, 'placeholder': 'Detailed explanation of your complaint'}),
            'visibility': forms.Select(),
        }


class AttachmentForm(forms.ModelForm):
    file = forms.FileField(required=False)

    class Meta:
        model = ComplaintAttachment
        fields = ['file']


class ComplaintResponseForm(forms.ModelForm):
    class Meta:
        model = ComplaintResponse
        fields = ['message']
        widgets = {
            'message': forms.Textarea(attrs={'rows': 4, 'placeholder': 'Write your response or update here...'}),
        }


class StatusUpdateForm(forms.ModelForm):
    class Meta:
        model = Complaint
        fields = ['status', 'priority']


class FeedbackForm(forms.ModelForm):
    class Meta:
        model = ComplaintFeedback
        fields = ['rating', 'comment']
        widgets = {
            'rating': forms.Select(),
            'comment': forms.Textarea(attrs={'rows': 3, 'placeholder': 'Share your feedback on the resolution...'}),
        }
