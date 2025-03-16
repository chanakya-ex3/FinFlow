from django.urls import path
from .views import *

urlpatterns = [
    path('create',CreateTransaction.as_view()),
    path('view/<str:transactionId>',ViewTransaction.as_view()),
    path('list/<str:groupId>',ListTransactions.as_view()),
    path('delete',DeleteTransaction.as_view())
]
    