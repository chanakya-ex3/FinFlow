from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from django.contrib.auth import get_user_model, authenticate
from rest_framework.authtoken.models import Token
from rest_framework import status

User = get_user_model()

class AuthCheck(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request, *args, **kwargs):
        return Response({"message":"User is authenticated"})

# Create your views here.
class LoginView(APIView):
    permission_classes = [AllowAny]
    def post(self, request,*args, **kwargs):
        print(request.data)
        username = request.data.get('username')
        password = request.data.get('password')
        user = authenticate(username=username, password=password)
        if user:
            token, create = Token.objects.get_or_create(user = user)
            return Response({'token':token.key},status = status.HTTP_200_OK)
        return Response({"error":'Invalid Credentials'})
    
    def create_superuser(self, username, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        return self.create_user(username, password, **extra_fields)
    
class SignUpView(APIView):
    permission_classes = [AllowAny]
    def post(self, request, *args, **kwargs):
        username = request.data.get('username')
        password = request.data.get('password')
        first_name = request.data.get('first_name')
        last_name = request.data.get('last_name')
        email = request.data.get('email')
        
        if User.objects.filter(username = username).exists():
            return Response({"error":"Error Creating account"})
        User.objects.create_user(
            username= username,
            password= password,
            first_name = first_name,
            last_name = last_name, 
            email= email
        )
        user = User.objects.get(username= username)
        token = Token.objects.create(user= user)
        return Response({"message":"Account Created Successfully", "token":token.key}, status = status.HTTP_201_CREATED)