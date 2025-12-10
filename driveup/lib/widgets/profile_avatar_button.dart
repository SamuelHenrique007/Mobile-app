import 'package:flutter/material.dart';

class ProfileAvatarButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ProfileAvatarButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onPressed,
      child: const CircleAvatar(
        radius: 16,
        backgroundColor: Colors.orange,
        child: Icon(Icons.person, color: Colors.white, size: 18),
      ),
    );
  }
}
