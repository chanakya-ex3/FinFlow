from django.urls import path
from .views import *

urlpatterns = [
    path('create',CreateGroup.as_view()),
    path('get/<str:groupId>',ViewGroup.as_view()),
    path('join',JoinGroup.as_view())
]
    