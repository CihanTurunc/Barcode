import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_sqflite_project/models/note.dart';
import 'package:flutter_sqflite_project/screens/note_detail.dart';
import 'package:flutter_sqflite_project/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) noteList = <Note>[];
    updateListView();

    return Scaffold(
      appBar: AppBar(
        title: Text("Notlar"),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("FAB clicked");
          navigateToDetail(Note("", "", 2), "Not Ekle");
        },
        tooltip: "Not Ekle",
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subtitle1;

    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
              color: Colors.white,
              elevation: 2.0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      getPriorityColor(this.noteList[position].priority),
                  child: getPriorityIcon(this.noteList[position].priority),
                ),
                title: Text(
                  this.noteList[position].title,
                  style: titleStyle,
                ),
                subtitle: Text(this.noteList[position].date),
                trailing: GestureDetector(
                  child: Icon(
                    Icons.delete,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    debugPrint("ListTile Tapped");
                    navigateToDetail(this.noteList[position], "Notu Düzenle");
                  },
                ),
              ));
        });
  }

  //Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      default:
        return Colors.yellow;
    }
  }

  //Returns the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, "Not Başarıyla Silindi");
      updateListView();
    }
  }

  Future<void> navigateToDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String s) {
    final snackbar = SnackBar(content: Text(s));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
