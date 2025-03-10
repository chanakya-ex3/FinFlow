from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.contrib.auth import get_user_model, authenticate
from .models import Group, GroupMembers
from .serializers import GroupSerializer, GroupMembersSerializer
# Create your views here.
User = get_user_model()
class CreateGroup(APIView):
    permission_classes = [IsAuthenticated]
    def post(self,request, *args, **kwargs):
        group_name = request.data.get('groupName')
        group_admin = request.user
        try:
            group = Group.objects.create(
                groupName = group_name,
                groupAdmin = group_admin
            )
            groupmembers = GroupMembers.objects.create(
                groupId = group,
                user = request.user
            )
            return Response({'message':'group created successfully','id':group.id})
        except Exception as e:
            print(e)
            return Response({'error':'error occured'})

class ViewGroup(APIView):
    permission_classes = [IsAuthenticated]
    def get(self,request, *args, **kwargs):
        groupId = self.kwargs['groupId']
        if(groupId == 'null' or groupId == ''):
            return Response({'error':"Group ID not provided"})
        try:
            group = Group.objects.get(id = groupId)
            serializer = GroupSerializer(group)
            admin = group.groupAdmin
            members = GroupMembers.objects.filter(groupId = group.id)
            member_serializer = GroupMembersSerializer(members, many =True)
            
            return Response({'group':serializer.data,'admin':admin.first_name+' '+admin.last_name,'members':member_serializer.data}) 
        except Exception as e:
            print(e)
            return Response({'error':'error occured'})
        
class JoinGroup(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request, *args, **kwargs):
        groupId = request.data.get('groupId')
        member = request.user
        if(groupId == 'null' or groupId == ''):
            return Response({'error':"Group ID not provided"})
        try:
            group = Group.objects.get(id=groupId)
            group_member = GroupMembers.objects.create(
                groupId = group,
                user = member
            )
            return Response({'message':'group joined successfully'})
        except Exception as e:
            print(e)
            return Response({'error':'an error occured'})
            
            