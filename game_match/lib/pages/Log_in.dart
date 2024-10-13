import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basic Login',

      // This is the theme of your application.
      //
      // TRY THIS: Try running your application with "flutter run". You'll see
      // the application has a purple toolbar. Then, without quitting the app,
      // try changing the seedColor in the colorScheme below to Colors.green
      // and then invoke "hot reload" (save your changes or press the "hot
      // reload" button in a Flutter-supported IDE, or press "r" if you used
      // the command line to start the app).
      //
      theme: ThemeData(

          primarySwatch: Colors.grey
      ),
      // Notice that the counter didn't reset back to zero; the application
      // state is not lost during the reload. To reset the state, use hot
      // restart instead.
      //
      // This works for code too, not just values: Most code changes can be
      // tested with just a hot reload.

      home: const MyLoginPage(title: 'My Main Login Page'),
    );
  }
}

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {

  //learn how to create controllers for text fields here

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // int _counter = 0;

  // void _incrementCounter() {
  //   setState(() {
  //     // This call to setState tells the Flutter framework that something has
  //     // changed in this State, which causes it to rerun the build method below
  //     // so that the display can reflect the updated values. If we changed
  //     // _counter without calling setState(), then the build method would not be
  //     // called again, and so nothing would appear to happen.
  //     _counter++;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(

          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[

            Padding(
              padding: const EdgeInsets.only(top:40.0),
              child: Image.asset(
                'images/gamematchlogoresize.png',
                height: 260,  // change height to match figma
                width: 260,   // same as height for good ratio
              ),
            ),

            // const SizedBox(height: 16),

            // login text below logo
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 40, // match the logo? or not idk
                fontWeight: FontWeight.bold, //need to figure out how to make the text match
              ),
            ),


            const SizedBox(height: 32),

            //resize border with wrap with sized box
            SizedBox(
              height: 40,
              width: 325,
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Enter your Username',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
              ),
            ),

            const SizedBox(height: 2),


            const Padding(
              padding: EdgeInsets.only(left: 30),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Forgot your Username?',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.blue, //straight blue?
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            //resize border with wrap with sized box
            SizedBox(
              height: 40,
              width: 325,
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Enter your Password',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
              ),
            ),



            const SizedBox(height: 2),

            const Padding(
              padding: EdgeInsets.only(left: 30),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Forgot your Password?',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),

            //put sized box again for spacing
            const SizedBox(height: 20),




            // continue button stuff
            const SizedBox(height: 20), // space it from the password section

            //wrap with container
            Container(
              width: 140, // try to match dimensions with figma
              height: 30,
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent, // make it lighter somehow
                borderRadius: BorderRadius.all(Radius.circular(2.5)), // rounded slightly
              ),
              child: const Center( // center text within blue box
                child: Text(
                  'continue',
                  style: TextStyle(
                    color: Colors.black, // straight black?
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),



            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center, // center the row
              children: [
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(
                    color: Colors.black, // make text straight black or lighter idk
                    fontSize: 16, // resize this
                  ),
                ),


                //add gesture within row
                GestureDetector(
                  onTap: () {
                    // add sign up stuff here
                  },

                  
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      color: Colors.blue, // Blue color for the "Sign up" text
                      fontSize: 16, // Font size for the text
                      fontWeight: FontWeight.bold, // Make the text bold
                    ),
                  ),
                ),
              ],
            ),




            //put back end login interaction here
            // const Text(
            //   'You have pushed the button this many times:',
            // ),
            // Text(
            //   '$_counter',
            //   style: Theme.of(context).textTheme.headlineMedium,
            // )
          ],
        ),
      ),
    );
  }
}




// Column is also a layout widget. It takes a list of children and
// arranges them vertically. By default, it sizes itself to fit its
// children horizontally, and tries to be as tall as its parent.
//
// Column has various properties to control how it sizes itself and
// how it positions its children. Here we use mainAxisAlignment to
// center the children vertically; the main axis here is the vertical
// axis because Columns are vertical (the cross axis would be
// horizontal).
//
// TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
// action in the IDE, or press "p" in the console), to see the
// wireframe for each widget.
