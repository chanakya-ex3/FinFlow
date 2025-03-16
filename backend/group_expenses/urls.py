from django.urls import path
from .views import *

urlpatterns = [
    path('create',CreateTransaction.as_view())
]
    