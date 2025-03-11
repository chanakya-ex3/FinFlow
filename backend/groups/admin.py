from django.contrib import admin

# Register your models here.
from .models import Group, GroupMember, GroupTransaction, SplitRatio
admin.site.register(Group)
admin.site.register(GroupMember)
admin.site.register(GroupTransaction)
admin.site.register(SplitRatio)