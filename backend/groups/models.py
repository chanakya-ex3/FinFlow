from django.db import models
from django.contrib.auth import get_user_model
import uuid
from transactions.models import Transaction

# Create your models here.
User = get_user_model()

class Group(models.Model):
    id = models.UUIDField(primary_key=True,default=uuid.uuid4,editable=False)
    groupName = models.CharField(blank=False,null=False, max_length=15, unique=True)
    groupAdmin = models.ForeignKey(User, on_delete=models.CASCADE, related_name='group_admin')
    def __str__(self):
        return f"{self.groupAdmin.username} - {self.groupName} "

class GroupMember(models.Model):
    id = models.UUIDField(primary_key=True, default= uuid.uuid4, editable=False)
    groupId = models.ForeignKey(Group, on_delete=models.CASCADE, related_name='group_members')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='group_user')
