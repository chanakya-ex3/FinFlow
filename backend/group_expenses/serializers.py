from rest_framework import serializers
from .models import GroupTransaction, SplitRatio
from users.serializers import *
from transactions.serializers import *

class GroupTransactionSerializer(serializers.ModelSerializer):
    paidBy = UserSerializer()
    transactionId = TransactionSerializer()
    class Meta:
        model = GroupTransaction
        fields = '__all__'
        

class SplitRatioSerializer(serializers.ModelSerializer):
    borrower = UserSerializer()
    class Meta:
        model = SplitRatio
        fields = '__all__'