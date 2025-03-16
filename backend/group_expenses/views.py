from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from .models import GroupTransaction, SplitRatio
from groups.models import GroupMember
from transactions.models import Transaction
from django.db import transaction
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

            return Response({'message': 'Added Group Transaction Successfully'})

        except Exception as e:
            print(e)
            return Response({'message': 'An error occurred'}, status=500)
