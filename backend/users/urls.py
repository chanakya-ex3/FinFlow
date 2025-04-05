from django.contrib import admin
from django.urls import path, include
from .views import *

urlpatterns = [
    path('login',LoginView.as_view()),
    path('signup',SignUpView.as_view()),
    path('auth-check',AuthCheck.as_view()),
    path("dashboard",DashboardView.as_view())
]
    