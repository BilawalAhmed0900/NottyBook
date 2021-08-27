import 'package:flutter/material.dart';

class SingleNote {
  String _title, _body;
  SingleNote({required String title, required String body})
    : _title = title, _body = body;

  String getTitle() {
    return _title;
  }

  String getBody() {
    return _body;
  }

  void setTitle(String title) {
    _title = title;
  }

  void setBody(String body) {
    _body = body;
  }

  Map<String, dynamic> toMap() {
    return {
      "title": _title,
      "body": _body
    };
  }

  @override
  String toString() {
    return "SingleNote{title: $_title, body: $_body}";
  }
}

/*
  This will be used to show SingleNote as a widget,

  this takes in two callbacks, one that will run when the SingleNotePage is pop'd
  and one that runs when this widget is long-pressed
 */
class SingleNoteWidget extends StatelessWidget {
  final SingleNote note;
  final VoidCallback onPop;
  final VoidCallback onLongPress;
  SingleNoteWidget(this.note, VoidCallback? onPop, VoidCallback? onLongPress, {Key? key})
      : this.onPop = onPop ?? (() { }),
        this.onLongPress = onLongPress ?? (() { }),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: TextButton(
        onPressed: () async {
          /*
            When we click on a SinglePageWidget, it will
            open a new widget which will return new body
            of the current note when it is pop'd
           */
          String? newBody = await Navigator.of(context).push<String>(MaterialPageRoute(
            builder: (builder) {
              return SingleNotePage(note);
            }
          ));

          if (newBody != null) {
            /*
              note is passed as reference, so we can do this
             */
            note.setBody(newBody);
            onPop();
          }
        },
        onLongPress: onLongPress,
        child: Text(
          note.getTitle(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft
        ),
      ),
    );
  }
}

/*
  A page representing a single note, which when pop'd
  return the new edited body of the note
 */
class SingleNotePage extends StatelessWidget {
  final SingleNote note;
  final TextEditingController textEditingController = TextEditingController();
  SingleNotePage(this.note, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    textEditingController.text = note.getBody();

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(textEditingController.text);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(note.getTitle(), style: TextStyle(color: Colors.white),),
          titleTextStyle: TextStyle(
            color: Colors.white,
          ),
          backgroundColor: Colors.grey.shade800,
        ),

        body: Padding(
          padding: EdgeInsets.only(left: 5, right: 5),
          child: TextFormField(
            controller: textEditingController,
            style: TextStyle(
              color: Colors.white
            ),
            cursorColor: Colors.white,
            keyboardType: TextInputType.multiline,

            /*
              when expands == true,
              minLines and maxLines must be null
             */
            minLines: null,
            maxLines: null,
            expands: true,
          ),
        ),

        backgroundColor: Colors.grey.shade900,
      ),
    );
  }
}


