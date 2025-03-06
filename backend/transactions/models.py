from django.db import models
from django.db import models
from django.contrib.auth import get_user_model 
import uuid

User = get_user_model()
# Create your models here.
class Transaction(models.Model):
    TRANSACTION_TYPES = [
        ('individual','Individual'),
        ('group','Group')
    ]
    id = models.UUIDField(primary_key=True,default=uuid.uuid4,editable=False)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    date = models.DateTimeField(auto_now_add=True)
    type = models.CharField(max_length=10,choices=TRANSACTION_TYPES)
    by = models.ForeignKey(User, on_delete=models.CASCADE,related_name='transactions')
    message = models.TextField(blank=True,null=True)
    # group = models.ForeignKey('Group',on_delete=models.CASCADE,blank=True,null=True, related_name='transactions')
    
    def __str__(self):
        return f"{self.by.username} - {self.amount} ({self.type})"