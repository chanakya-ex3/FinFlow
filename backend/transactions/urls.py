from django.contrib import admin
from django.urls import path, include
from .views import *

urlpatterns = [
    path('create',CreateTransactionView.as_view()),
    path("get/<str:transactionId>", ShowTransactionView.as_view()),
    path("list", ListTransactionView.as_view())
]
    