from rest_framework import serializers
from .models import Group, GroupMember
from users.serializers import UserSerializer

class GroupSerializer(serializers.ModelSerializer):
    class Meta:
        model = Group
        fields = '__all__'
        

class GroupMemberSerializer(serializers.ModelSerializer):
    user = UserSerializer()
    class Meta:
        model = GroupMember
        fields = '__all__'