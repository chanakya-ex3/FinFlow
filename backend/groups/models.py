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

class GroupMembers(models.Model):
    id = models.UUIDField(primary_key=True, default= uuid.uuid4, editable=False)
    groupId = models.ForeignKey(Group, on_delete=models.CASCADE, related_name='group_members')
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='group_user',unique=True)

class GroupTransaction(models.Model):
    id = models.UUIDField(primary_key=True,default=uuid.uuid4, editable=False)
    transactionId = models.ForeignKey(Transaction, on_delete=models.CASCADE, related_name='group_transaction')
    paidBy = models.ForeignKey(User, on_delete=models.CASCADE, related_name='paid_by')
    paid_amount = models.DecimalField(max_digits=10, decimal_places=2)
class SplitRatio(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    transactionId = models.ForeignKey(GroupTransaction, on_delete=models.CASCADE, related_name='transaction_ratio')
    percentage = models.DecimalField(max_digits=2, decimal_places=2)
    borrower = models.ForeignKey(User, on_delete=models.CASCADE, related_name='split_user')
    