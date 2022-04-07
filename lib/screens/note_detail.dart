import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_sqflite_project/models/note.dart';
import 'package:flutter_sqflite_project/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBartitle;
  final Note note;
  NoteDetail(this.note, this.appBartitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBartitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.subtitle1;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                moveToLastScreen();
              }),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: ListView(
            children: [
              //Second Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),

                child: TextButton(
                  onPressed: () => ReadCode(),
                  child: Text("Scan Barcode"),
                ),

               
              ),

              //Third Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint("Something changed in Description Text Field");
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      labelText: "Açıklama",
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),

              //Fourth Element
              Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColorDark,
                          textStyle: TextStyle(
                              color: Theme.of(context).primaryColorLight),
                        ),
                        child: Text(
                          "Kaydet",
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            debugPrint("Save button clicked");
                            _save();
                          });
                        },
                      )),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                          child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColorDark,
                          textStyle: TextStyle(
                              color: Theme.of(context).primaryColorLight),
                        ),
                        child: Text(
                          "Sil",
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            debugPrint("Delete button clicked");
                            _delete();
                          });
                        },
                      )),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  moveToLastScreen() {
    Navigator.pop(context, true);
  }

  //Update the title of Note object
  void updateTitle() {
    note.title = ReadCode().toString();
  }

  //Update the description of Note object
  void updateDescription() {
    note.description = descriptionController.text;
  }

  //Save data to database
  void _save() async {
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      //Case 1: Update operation
      result = await helper.updateNote(note);
    } else {
      //Case 2:Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      //Success
      _showAlertDialog("Durum", "Not Başarıyla Kaydedildi");
    } else {
      // Failure
      _showAlertDialog("Durum", "Not Kaydedilemedi");
    }
  }

  void _delete() async {
    moveToLastScreen();
    if (note.id == null) {
      _showAlertDialog("Durum", "Hiçbir Not Silinmedi");
      return;
    }

    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog("Durum", "Not Başarıyla Silindi");
    } else {
      _showAlertDialog("Durum", "Not Silinirken Hata Oluştu");
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  Future<String> ReadCode() async {
    String barCode = await FlutterBarcodeScanner.scanBarcode(
        "#000000", "Cancel", true, ScanMode.BARCODE);
    note.title = barCode;
  }
}