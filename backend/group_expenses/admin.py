from django.contrib import admin

# Register your models here.
from .models import GroupTransaction, SplitRatio
admin.site.register(GroupTransaction)
admin.site.register(SplitRatio)