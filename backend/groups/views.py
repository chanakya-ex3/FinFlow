from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.contrib.auth import get_user_model, authenticate
from .models import Group, GroupMember
from .serializers import GroupSerializer, GroupMemberSerializer
from transactions.models import Transaction
from django.db import transaction
from decimal import Decimal, ROUND_DOWN
from rest_framework import status

# Create your views here.
User = get_user_model()
class CreateGroup(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request, *args, **kwargs):
        group_name = request.data.get('groupName')
        group_admin = request.user
        
        try:
            with transaction.atomic():
                group = Group.objects.create(
                    groupName=group_name,
                    groupAdmin=group_admin
                )
                groupmembers = GroupMember.objects.create(
                    groupId=group,
                    user=request.user
                )
            return Response({'message': 'group created successfully', 'id': group.id},status = status.HTTP_200_OK)
        
        except Exception as e:
            print(e)
            return Response({'error': 'error occurred'}, status = status.HTTP_500_INTERNAL_SERVER_ERROR)

class ViewGroup(APIView):
    permission_classes = [IsAuthenticated]
    def get(self,request, *args, **kwargs):
        groupId = self.kwargs['groupId']
        if(groupId == 'null' or groupId == ''):
            return Response({'error':"Group ID not provided"},status= status.HTTP_400_BAD_REQUEST)
        try:
            group = Group.objects.get(id = groupId)
            serializer = GroupSerializer(group)
            admin = group.groupAdmin
            members = GroupMember.objects.filter(groupId = group.id)
            member_serializer = GroupMemberSerializer(members, many =True)
            
            return Response({'group':serializer.data,'admin':admin.first_name+' '+admin.last_name,'members':member_serializer.data}, status =status.HTTP_200_OK) 
        except Exception as e:
            print(e)
            return Response({'error':'error occured'},status = status.HTTP_500_INTERNAL_SERVER_ERROR)
        
class JoinGroup(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request, *args, **kwargs):
        groupId = request.data.get('groupId')
        member = request.user
        if(groupId == 'null' or groupId == ''):
            return Response({'error':"Group ID not provided"})
        try:
            
            group = Group.objects.get(id=groupId)
            group_member, created = GroupMember.objects.get_or_create(
                groupId = group,
                user = member
            )
            if(created):
                return Response({'message':'group joined successfully'},status = status.HTTP_200_OK)
            else:
                return Response({'message':'user aready exists in group'}, status = status.HTTP_409_CONFLICT)
        except Exception as e:
            print(e)
            return Response({'error':'an error occured'},status = status.HTTP_500_INTERNAL_SERVER_ERROR)
            

class ListGroups(APIView):
    def get(self, request, *args, **kwargs):
        user_id = request.user
        # Get groups where the user is a member
        user_groups = Group.objects.filter(group_members__user_id=user_id)
        # Serialize the data
        serializer = GroupSerializer(user_groups, many=True)
        groups_data = serializer.data
        for i, group in enumerate(user_groups):
                members = GroupMember.objects.filter(groupId=group)
                groups_data[i]["members"] = GroupMemberSerializer(members, many=True).data
                groups_data[i]['members_count'] = len(groups_data[i]['members'])

        return Response(serializer.data, status=status.HTTP_200_OK)