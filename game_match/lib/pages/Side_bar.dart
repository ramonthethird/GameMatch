import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              color: const Color(0xFF74ACD5),
              width: 200,
          child: Row(
            children: [
                  ElevatedButton(
                    onPressed: () {
                      // navigate to the profile page
                      Navigator.pushNamed(context, '/Profile');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      backgroundColor: const Color(0xFF74ACD5),
                      fixedSize: const Size(80, 80),
                      alignment: Alignment.centerLeft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/profile.png'),
                          //fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("User Name"),
                          Text(
                            "Diamond Tier",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.favorite),
              label: const Text("Swipe page"),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                backgroundColor: Colors.white,
                fixedSize: const Size(200, 50),
                textStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                foregroundColor: Colors.black, // make the text color black
                alignment: Alignment.centerLeft, // align the text to the left
                side: const BorderSide(
                    color: Colors.black, width: 0), // add a border
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        0)), // make the button rectangular
                //alignment: Alignment.center, // align the text to the center
              ), //will be used to navigate to the next page
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.room_preferences),
              label: const Text("Preference"),
              onPressed: () {
                Navigator.pushNamed(context, '/Preference_&_Interest');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                backgroundColor: Colors.white,
                fixedSize: const Size(200, 50),
                textStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                foregroundColor: Colors.black, // make the text color black
                alignment: Alignment.centerLeft, // align the text to the left
                side: const BorderSide(color: Colors.black, width: 0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        0)), // make the button rectangular
                //alignment: Alignment.center, // align the text to the center
              ), //will be used to navigate to the next page
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.subscriptions),
              label: const Text("Subscription"),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                backgroundColor: Colors.white,
                fixedSize: const Size(200, 50),
                textStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                foregroundColor: Colors.black, // make the text color black
                alignment: Alignment.centerLeft, // align the text to the left
                side: const BorderSide(
                    color: Colors.black, width: 0), // add a border
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        0)), // make the button rectangular
                //alignment: Alignment.center, // align the text to the center
              ), //will be used to navigate to the next page
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.newspaper_rounded),
              label: const Text("News"),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                backgroundColor: Colors.white,
                fixedSize: const Size(200, 50),
                textStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                foregroundColor: Colors.black, // make the text color black
                alignment: Alignment.centerLeft, // align the text to the left
                side: const BorderSide(
                    color: Colors.black, width: 0), // add a border
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        0)), // make the button rectangular
                //alignment: Alignment.center, // align the text to the center
              ), //will be used to navigate to the next page
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.interests),
              label: const Text("Wishlist"),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                backgroundColor: Colors.white,
                fixedSize: const Size(200, 50),
                textStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                foregroundColor: Colors.black, // make the text color black
                alignment: Alignment.centerLeft, // align the text to the left
                side: const BorderSide(
                    color: Colors.black, width: 0), // add a border
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        0)), // make the button rectangular
                //alignment: Alignment.center, // align the text to the center
              ), //will be used to navigate to the next page
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text("Settings"),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                backgroundColor: Colors.white,
                fixedSize: const Size(200, 50),
                textStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                foregroundColor: Colors.black, // make the text color black
                alignment: Alignment.centerLeft, // align the text to the left
                side: const BorderSide(
                    color: Colors.black, width: 0), // add a border
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        0)), // make the button rectangular
                //alignment: Alignment.center, // align the text to the center
              ), //will be used to navigate to the next page
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Log out"),
              onPressed: () {
                // show a dialog to confirm log out
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: const Text("Are you sure you want to log out?"),
                      actions: [
                        TextButton(
                          child: const Text("No"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text("Yes"),
                          onPressed: () {},
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                backgroundColor: Colors.white,
                fixedSize: const Size(200, 50),
                textStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                foregroundColor: Colors.black, // make the text color black
                alignment: Alignment.centerLeft, // align the text to the left
                side: const BorderSide(
                    color: Colors.black, width: 0), // add a border
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        0)), // make the button rectangular
                //alignment: Alignment.center, // align the text to the center
              ), //will be used to navigate to the next page
            ),
          ],
        ),
      ),
    );
  }
}
