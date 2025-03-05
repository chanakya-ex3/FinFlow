from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, Group
from django.db import models

class CustomUserManager(BaseUserManager):
    def create_user(self,username, password=None, **extrafields):
        if not username:
            raise ValueError("Username cant be empty")
        user = self.model(username = username, **extrafields)
        user.set_password(password)
        user.save(using= self.db)

# Create your models here.
class CustomUser(AbstractBaseUser):
    username = models.CharField(max_length=150, unique=True)
    password = models.CharField(max_length=150)
    first_name = models.CharField(max_length=150)
    last_name = models.CharField(max_length=150)
    group_id = models.ManyToManyField(Group,related_name="custom_users", blank=True)
    
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    
    objects = CustomUserManager()
    
    USERNAME_FIELD =  'username'
    REQUIRED_FIELDS = ['first_name', 'last_name']
    
    def __str__(self):
        return self.username
    