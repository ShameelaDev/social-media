import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {

  final void Function() onPressed;
  final bool isFollow;
  const FollowButton({super.key,required this.isFollow,required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:const  EdgeInsets.symmetric(horizontal: 25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MaterialButton(
          onPressed: onPressed,
          color: isFollow? Theme.of(context).colorScheme.primary : Colors.blue,
          child: Text(isFollow? "Unfollow" : "Follow",style: TextStyle(color: Theme.of(context).colorScheme.secondary,fontWeight: FontWeight.bold),),
          ),
      ),
    );
  }
}