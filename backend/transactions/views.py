from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.contrib.auth import get_user_model, authenticate
from rest_framework.authtoken.models import Token
from rest_framework import status
from .models import Transaction
from .serializers import TransactionSerializer

# Create your views here.
class CreateTransactionView(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request, *args, **kwargs):
        amount = request.data.get('amount')
        print(request.user.email)
        message = request.data.get('message')
        if(amount is None or message is None):
            return Response({'error':"Follwing fields are mandatory- amount, message"}, status = status.HTTP_400_BAD_REQUEST)
        try:
            print(1)
            transaction  = Transaction.objects.create(
                amount = amount,
                type = 'individual',
                by = request.user,
                message = message
            )
            print(2)
        except Exception as e:
            print("Unable to create transaction: ",e, status= status.HTTP_500_INTERNAL_SERVER_ERROR)
        return Response({"message":"Success","trxnId":transaction.id},status = status.HTTP_200_OK)
    
class ShowTransactionView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self,request, *args, **kwargs):
        transactionId = self.kwargs['transactionId']
        if(transactionId == 'null' or transactionId == ''):
            return Response({"error":"Transaction ID is not provided"},status= status.HTTP_400_BAD_REQUEST)
        try:
            transaction = Transaction.objects.get(id = transactionId)
            return Response({"Message":"Fetched Successfully","id":transaction.id, "amount":transaction.amount, "bg":f'{transaction.by.first_name} {transaction.by.last_name}',"summary":transaction.message},status=status.HTTP_200_OK)
        except Exception as e:
              return Response({'error':e},status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class ListTransactionView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request, *args, **kwargs):
        try:
            user = request.user
            transactions = Transaction.objects.filter(by = user)
            serializer = TransactionSerializer(transactions,many = True)
            return Response({'message':"fetched Successfully", 'transactions':serializer.data},status=status.HTTP_200_OK)
        except Exception as e:
            return Response({'error':e},status=status.HTTP_500_INTERNAL_SERVER_ERROR)