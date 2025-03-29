from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from .models import GroupTransaction, SplitRatio
from groups.models import Group,GroupMember
from django.shortcuts import get_object_or_404
from transactions.models import Transaction
from django.db import transaction
from .serializers import GroupTransactionSerializer, SplitRatioSerializer
from decimal import Decimal, ROUND_DOWN

User = get_user_model()
# Create your views here.
class CreateTransaction(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request, *args, **kwargs): 
        groupId = request.data.get('groupId')
        splitRatio = request.data.get('splitRatio')
        amount = request.data.get('amount')
        message = request.data.get('message')
        paidBy = request.user
        groupInstance = Group.objects.get(id = groupId)
        groupMembers = GroupMember.objects.filter(groupId = groupId)
        isPresent = False
        for i in groupMembers:
            if(paidBy == i.user):
                isPresent= True
                break
        if(not isPresent):
            return Response({'error':'invalid user'})
        
        try:
            with transaction.atomic():
                transactionID = Transaction.objects.create(
                    amount=amount,
                    type='group',
                    by=paidBy,
                    message=message
                )

                group_transaction = GroupTransaction.objects.create(
                    transactionId=transactionID,
                    groupId = groupInstance,
                    paidBy=paidBy,
                    paid_amount=amount
                )

                # Fetch users in a single query
                users = User.objects.filter(username__in=splitRatio.keys())
                user_map = {user.username: user for user in users}
                split_ratios = [
                    SplitRatio(
                        transactionId=group_transaction,
                        percentage=splitRatio[username],
                        borrower=user_map[username],
                        borrowed_amount =  (Decimal(amount) * (Decimal(splitRatio[username]) / Decimal("100"))).quantize(Decimal("0.01"), rounding=ROUND_DOWN)
                    )
                    for username in splitRatio if username in user_map
                ]

                SplitRatio.objects.bulk_create(split_ratios)  # Efficient bulk insert

            return Response({'message': 'Added Group Transaction Successfully','tid':transactionID.id,'gtid':group_transaction.id})

        except Exception as e:
            print(e)
            return Response({'message': 'An error occurred'}, status=500)


class ViewTransaction(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request,  *args, **kwargs):
        transactionId = self.kwargs['transactionId']
        user = request.user
        try:
            with transaction.atomic():
                transactionID = Transaction.objects.get(id = transactionId)
                if(transactionID.type != 'group'):
                    return Response({'message':"Invalid Transaction type"})
                groupTransaction = GroupTransaction.objects.get(
                    transactionId = transactionID
                )
                splitRatio = SplitRatio.objects.filter(
                    transactionId = groupTransaction
                )
                print(groupTransaction)
                print(splitRatio)
                return Response({'message':"fetched sucessfully",'groupTransaction':GroupTransactionSerializer(groupTransaction).data, 'splitRatio':SplitRatioSerializer(splitRatio, many =True).data})
        except Exception as e:
          print(e)
          return Response({"erorr":"an error occured"})

class ListTransactions(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        user = request.user
        group_id = kwargs.get("groupId")

        try:
            group_instance = get_object_or_404(Group, id=group_id)
            group_transactions = GroupTransaction.objects.filter(groupId=group_instance)
            
            if not group_transactions.exists():
                return Response({"message": "No transactions found", "transactions": [], "debts": []})

            # Serialize transactions
            group_transactions_serializer = GroupTransactionSerializer(group_transactions, many=True)

            # Calculate debts
            user_balances = {}

            # Step 1: Calculate total amount paid by each user
            for transaction in group_transactions:
                payer = transaction.paidBy
                paid_amount = transaction.paid_amount
                user_balances[payer] = user_balances.get(payer, 0) + paid_amount

                # Step 2: Calculate total borrowed by each user
                split_ratios = SplitRatio.objects.filter(transactionId=transaction)
                for split in split_ratios:
                    borrower = split.borrower
                    borrowed_amount = split.borrowed_amount
                    user_balances[borrower] = user_balances.get(borrower, 0) - borrowed_amount

            # Step 3: Determine who owes whom
            positive_balances = {user: balance for user, balance in user_balances.items() if balance > 0}
            negative_balances = {user: -balance for user, balance in user_balances.items() if balance < 0}

            debt_list = []

            # Settling debts
            while negative_balances and positive_balances:
                debtor, debt = next(iter(negative_balances.items()))
                creditor, credit = next(iter(positive_balances.items()))

                amount_to_settle = min(debt, credit)
                debt_list.append({
                    "from": debtor.username,
                    "to": creditor.username,
                    "amount": float(amount_to_settle)
                })

                # Update balances
                negative_balances[debtor] -= amount_to_settle
                positive_balances[creditor] -= amount_to_settle

                if negative_balances[debtor] == 0:
                    del negative_balances[debtor]
                if positive_balances[creditor] == 0:
                    del positive_balances[creditor]

            return Response({
                "message": "Fetched successfully",
                "transactions": group_transactions_serializer.data,
                "debts": debt_list
            })  

        except Exception as e:
            print(e)
            return Response({"error": "An exception occurred"})

class DeleteTransaction(APIView):
    permission_classes = [IsAuthenticated]
    def post(self,request, *args, **kwargs):
        transactionId = request.data.get('transactionId')
        try:
            transactionID = Transaction.objects.get(id =transactionId)
            transactionID.delete()
            return Response({"messsage":"Deleted Successfully"})
        except Exception as e:
            print(e)
            return Response({"error":"Error occured"})