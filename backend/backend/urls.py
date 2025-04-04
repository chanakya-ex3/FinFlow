"""
URL configuration for backend project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include

version1 = 'api/v1/'
urlpatterns = [
    path(version1+'admin/', admin.site.urls),
    path(version1+'users/',include('users.urls')),
    path(version1+'transactions/',include('transactions.urls')),
    path(version1+"groups/", include('groups.urls')),
    path(version1+"group-expenses/", include('group_expenses.urls'))
]
