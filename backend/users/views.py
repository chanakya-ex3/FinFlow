from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from django.contrib.auth import get_user_model, authenticate
from rest_framework.authtoken.models import Token
from rest_framework import status
from .serializers import UserSerializer
from group_expenses.models import GroupTransaction, SplitRatio
from transactions.models import Transaction
from group_expenses.serializers import GroupTransactionSerializer
from django.db.models import Sum


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
        serializer = UserSerializer(user)
        if user:
            token, create = Token.objects.get_or_create(user = user)
            return Response({"message": "Logged In Successfully",'token':token.key,"user":serializer.data},status = status.HTTP_200_OK)
        print(user)
        return Response({"error":'Invalid Credentials'}, status = status.HTTP_401_UNAUTHORIZED)
    
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
            return Response({"error":"Error Creating account"}, status = status.HTTP_400_BAD_REQUEST)
        user = User.objects.create_user(
            username= username,
            password= password,
            first_name = first_name,
            last_name = last_name, 
            email= email
        )
        serializer = UserSerializer(user)
        token = Token.objects.create(user= user)
        return Response({"message":"Account Created Successfully", "token":token.key,"user":serializer.data}, status = status.HTTP_201_CREATED)



class DashboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user

        # Totals
        total_spent = Transaction.objects.filter(by=user).aggregate(total=Sum('amount'))['total'] or 0
        total_borrowed = SplitRatio.objects.filter(borrower=user).aggregate(total=Sum('borrowed_amount'))['total'] or 0
        total_lent = GroupTransaction.objects.filter(paidBy=user).aggregate(total=Sum('paid_amount'))['total'] or 0

        # Recent Expenses
        recent_group_transactions = GroupTransaction.objects.filter(paidBy=user).order_by('-transactionId__date')[:5]
        serialized_transactions = GroupTransactionSerializer(recent_group_transactions, many=True).data

        # Top Contributors (top 5 users who paid the most in total)
        top_contributor_qs = (
            GroupTransaction.objects
            .values('paidBy')  # Group by user
            .annotate(total_paid=Sum('paid_amount'))  # Sum their paid amount
            .order_by('-total_paid')[:5]  # Take top 5
        )

        # Enrich with user details
        top_contributors = []
        for contributor in top_contributor_qs:
            try:
                user_obj = User.objects.get(id=contributor['paidBy'])
                top_contributors.append({
                    'name': f"{user_obj.first_name} {user_obj.last_name}",
                    'total_paid': contributor['total_paid']
                })
            except User.DoesNotExist:
                continue

        return Response({
            'total_spent': total_spent,
            'total_borrowed': total_borrowed,
            'total_lent': total_lent,
            'recent_expenses': serialized_transactions,
            'top_contributors': top_contributors,
        })