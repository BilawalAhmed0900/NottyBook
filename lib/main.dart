import 'package:flutter/material.dart';
import 'Notes.dart';
import 'DatabaseFunctions.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  /*
    There is a reason why MaterialApp is here while Scaffold lives
    in its own class. What? you may ask. Because AlertDialog needs
    a localization for showing up, MaterialApp provides it as BuildContext

    If we move MaterialApp too in that class, the context will of naked
    flutter app not Material app and we have to attach Localization delegate
    to the context
   */
  runApp(MaterialApp(
    home: SafeArea(
      child: MainScaffold(),
    ),
  ));
}


class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

/*
  The main scaffold of our app, body is a separate class,
  this only consists of app bar and floating action button
 */
class _MainScaffoldState extends State<MainScaffold> {
  PersistentData? persistentData;
  List<SingleNote> notes = List<SingleNote>.empty();

  @override
  void initState() {
    super.initState();
    PersistentData.create().then((data) {
      persistentData = data;
      persistentData!.readDatabase().then((list) {
        notes = list;
        setState(() {

        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notty Book"),
        titleTextStyle: TextStyle(
          color: Colors.white,
        ),
        backgroundColor: Colors.grey.shade800,
        leading: Icon(Icons.menu_book_sharp, size: 30,),
        titleSpacing: 0,
      ),

      body: MainBody(notes, persistentData),

      floatingActionButton: FloatingActionButton(
        /*
          This is more complex than rest of the GUI
         */
        onPressed: () async {
          /*
            Show a dialog
           */
          String? title = await showInputDialog(context, "Give Title for New Note (long-press title to remove)");

          if (title != null) {
            List<SingleNote> listWithSameTitle = notes.where((element) => element.getTitle() == title).toList();
            if (listWithSameTitle.isNotEmpty) {
              showAlertDialog(context, "Alert!", "No two notes can have same title...");
              return;
            }

            SingleNote newNote = SingleNote(title: title, body: "");
            persistentData!.updateDatabase(newNote);

            setState(() {
              notes.add(newNote);
            });
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.grey.shade700,
      ),

      backgroundColor: Colors.grey.shade900,

      bottomSheet: BottomSheet(
        onClosing: () { },
        builder: (builder) {
          return Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Icon made by Smashicons from Flaticon.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic
                  ),
                ),
              ],
            ),
          );
        },
        backgroundColor: Colors.grey.shade900,
      ),
    );
  }
}

class MainBody extends StatefulWidget {
  final List<SingleNote> notes;
  final PersistentData? persistentData;
  const MainBody(this.notes, this.persistentData, {Key? key}) : super(key: key);

  @override
  _MainBodyState createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
  Widget build(BuildContext context) {
    if (widget.notes.length == 0) {
      return Center(
        child: Text(
          "No notes found",
          style: TextStyle(
            color: Colors.white54,
          ),
        ),
      );
    }

    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return SingleNoteWidget(widget.notes[index],
                () {
                  widget.persistentData!.updateDatabase(widget.notes[index]);
                },
                () {
                  widget.persistentData!.removeFromDatabase(widget.notes[index]).then((value) {
                    widget.notes.removeAt(index);
                    setState(() {

                    });
                  });
                });
      },
      itemCount: widget.notes.length,
    );
  }
}

Future<String?> showInputDialog(BuildContext context, String title) async {
  return await showDialog<String>(
    context: context,

    /*
      The builder will form a AlertDialog
     */
    builder: (builder) {
      /*
        To capture input from TextField, we attach it to that
       */
      final TextEditingController textEditingController = TextEditingController();

      return AlertDialog(
        title: Text(title),
        titleTextStyle: TextStyle(
          color: Colors.white,
        ),
        backgroundColor: Colors.grey.shade800,
        content: TextField(
          controller: textEditingController,
          cursorColor: Colors.white,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          /*
            Cancel button just, pop the context with null value
           */
          TextButton(
              onPressed: () { Navigator.of(context).pop(null); },
              child: Text("Cancel", style: TextStyle(color: Colors.white),)
          ),

          /*
            While the okay button, pops with value form the controller
           */
          TextButton(
              onPressed: () { Navigator.of(context).pop(textEditingController.text); },
              child: Text("OK", style: TextStyle(color: Colors.white),)
          ),
        ],
      );
    },
  );
}

/*
  Show a simple dialog with alert message
 */
void showAlertDialog(BuildContext context, String title, String body) {
  showDialog(
      context: context,
      builder: (builder) {
        return AlertDialog(
          title: Text(title),
          titleTextStyle: TextStyle(
            color: Colors.white,
          ),
          content: Text(body, style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(onPressed: (){ Navigator.of(context).pop(); }, child: Text("OK"))
          ],

          backgroundColor: Colors.grey.shade800,
        );
      }
  );
}
