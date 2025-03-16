from rest_framework import serializers
from .models import GroupTransaction, SplitRatio

class GroupTransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = GroupTransaction
        fields = '__all__'
        

class SplitRatioSerializer(serializers.ModelSerializer):
    class Meta:
        model = SplitRatio
        fields = '__all__'