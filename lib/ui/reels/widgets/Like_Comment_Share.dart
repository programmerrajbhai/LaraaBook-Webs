import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class Like_Comment_Share extends StatelessWidget {
  const Like_Comment_Share({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 50,right: 7),
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end, // নিচে নামাতে
          crossAxisAlignment: CrossAxisAlignment.end, // বাম পাশে আনতে
          children: [
            SizedBox(height: 100),
            Column(
              children: [


                Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: 50,
                ),
                // লাইক বা লাভ আইকন
                SizedBox(height: 10),


                Icon(
                  Icons.heart_broken,
                  color: Colors.white,
                  size: 34,
                ),


                // লাইক বা লাভ আইকন
                SizedBox(height: 5),
                Text(
                  '44K',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                SizedBox(height: 15),
                FaIcon(FontAwesomeIcons.comment, color: Colors.white
                  ,size: 30,),
                SizedBox(height: 5),
                Text(
                  '12K',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                SizedBox(height: 15),
                FaIcon(
                  FontAwesomeIcons.bookmark,
                  color: Colors.white,size: 30,
                ),
                SizedBox(height: 5),
                Text(
                  '682',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                SizedBox(height: 15),
                FaIcon(FontAwesomeIcons.share, color: Colors.white,
                  size: 30,),
                SizedBox(height: 5),
                Text(
                  '120',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                SizedBox(height: 10),

              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: (){},
                    child: Text("The Village Coder",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20
                      ),),
                  ),
                  SizedBox(height: 10,),
                  Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit "
                      "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua"
                      "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris."
                      "Nisi ut aliquip ex ea commodo consequat duis aute irure dolor.",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.justify,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}