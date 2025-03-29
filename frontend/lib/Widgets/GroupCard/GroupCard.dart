import 'package:flutter/material.dart';
import 'package:frontend/Screens/GroupDetails/GroupDetails.dart';

class GroupCard extends StatelessWidget {
  final Map groupData;

  const GroupCard({super.key, required this.groupData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.group, color: Colors.white),
        ),
        title: Text(
          groupData['groupName'] ?? "Group Name",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "${groupData['members_count'] ?? 0} members",
          style: TextStyle(fontSize: 14,color: Theme.of(context).primaryColorLight),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // Navigate to GroupDetailsPage when tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupDetailsPage(groupData: groupData),
            ),
          );
        },
      ),
    );
  }
}
