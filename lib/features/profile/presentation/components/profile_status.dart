import 'package:flutter/material.dart';

class ProfileStatus extends StatelessWidget {
    final int postCount;
    final int followersCount;
    final int followingCount;
    final void Function() onTap;

  const ProfileStatus({super.key,required this.postCount,required this.followersCount,required this.followingCount,required this.onTap});

  @override
  Widget build(BuildContext context) {

    var textStyleforCount =TextStyle(color: Theme.of(context).colorScheme.inversePrimary,fontSize: 20);
    var textStyleforText =TextStyle(color: Theme.of(context).colorScheme.primary,);


    return GestureDetector(
        onTap: onTap,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              SizedBox(
                  width: 100,
                child: Column(
                    children: [
                        Text(postCount.toString(),style: textStyleforCount,),
                         Text("Post",style: textStyleforText,)
                    ],
                ),
              ),
               SizedBox(
                  width: 100,
                 child: Column(
                    children: [
                        Text(followersCount.toString(),style: textStyleforCount,),
                         Text("Followers",style: textStyleforText,)
                    ],
                             ),
               ),
               SizedBox(
                  width: 100,
                 child: Column(
                    children: [
                        Text(followingCount.toString(),style: textStyleforCount,),
                        Text("Following",style: textStyleforText,)
                    ],
                             ),
               )
          ],
      ),
    );
  }
}