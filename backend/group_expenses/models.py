from django.db import models
from django.contrib.auth import get_user_model
import uuid
from transactions.models import Transaction
from groups.models import Group

User = get_user_model()
# Create your models here.
class GroupTransaction(models.Model):
    id = models.UUIDField(primary_key=True,default=uuid.uuid4, editable=False)
    transactionId = models.ForeignKey(Transaction, on_delete=models.CASCADE, related_name='group_transaction')
    paidBy = models.ForeignKey(User, on_delete=models.CASCADE, related_name='paid_by')
    paid_amount = models.DecimalField(max_digits=10, decimal_places=2)
    groupId = models.ForeignKey(Group, on_delete= models.CASCADE)
class SplitRatio(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    transactionId = models.ForeignKey(GroupTransaction, on_delete=models.CASCADE, related_name='transaction_ratio')
    percentage = models.DecimalField(max_digits=5, decimal_places=2)
    borrowed_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    borrower = models.ForeignKey(User, on_delete=models.CASCADE, related_name='split_user')
    