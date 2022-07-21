import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as syspath;

import 'package:todoapp/models/todo.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  String _orderSelected = "";
  PickerDateRange? _selectedDate;

  _selectedDateDialog(PickerDateRange selectedDate) {
    _selectedDate = selectedDate;
  }

  _saveTodoDialog({QueryDocumentSnapshot? todo}) {
    // todo ??= Todo(time: DateTime.now());

    showDialog(
        context: context,
        builder: (context) => _SaveTodoDialog(
            selectedRangeDate: _selectedDate,
            selectedDate: todo != null
                ? _selectedDate?.startDate
                : todo == null
                    ? _selectedDate?.startDate
                    : todo['time'].toDate(),
            todo: todo));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        toolbarHeight: 90,
        elevation: 5,
        title: Row(
          mainAxisAlignment: MediaQuery.of(context).size.width > 500
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width > 500 ? 130 : 0,
              height: 20,
            ),
            const Text(
              "Todo",
              style: TextStyle(fontSize: 40, color: Colors.grey),
            ),
            const Text(
              "App",
              style: TextStyle(fontSize: 40, color: Colors.white),
            )
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                DropdownButton(
                    items: <String>["By date", "By creation"]
                        .map((i) => DropdownMenuItem<String>(
                              value: i,
                              child: Text(
                                i,
                                style:
                                    const TextStyle(color: Colors.deepPurple),
                              ),
                            ))
                        .toList(),
                    hint: _orderSelected == ""
                        ? const Text(
                            "Seleccionar",
                            style: TextStyle(color: Colors.white),
                          )
                        : Text(
                            _orderSelected,
                            style: const TextStyle(color: Colors.white),
                          ),
                    onChanged: (value) {
                      setState(() {
                        _orderSelected = value.toString();
                      });
                    }),
                const _UserAvatar()
              ],
            ),
          )
        ],
      ),
      body: _Content(
          key: Key(_orderSelected),
          saveTodoDialog: _saveTodoDialog,
          selectedDateDialog: _selectedDateDialog,
          orden: _orderSelected),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () {
          _saveTodoDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundImage: AssetImage("assets/images/user.jpg"),
        ),
      ),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return _ProfileDialog();
            });
      },
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  final Function confirm;
  final String message;

  const _ConfirmDialog(
      {Key? key, required this.confirm, this.message = "Confirm"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Please confirm"),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () {
              // eliminar todo
              confirm();
              Navigator.of(context).pop();
            },
            child: const Text("Yes")),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("No"))
      ],
    );
  }
}

class _ProfileDialog extends StatelessWidget {
  final _key = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _avatarController = TextEditingController();

  _ProfileDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: ConstrainedBox(
        constraints: const BoxConstraints(
            minWidth: 100, maxWidth: 450, minHeight: 100, maxHeight: 280),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * .4,
          height: MediaQuery.of(context).size.height * .4,
          child: Form(
              key: _key,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage("assets/images/user.jpg"),
                        // backgroundImage:
                        //     NetworkImage("https://randomuser.me/api/portraits/men/23.jpg"),
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Name", border: OutlineInputBorder()),
                      controller: _nameController,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Avatar", border: OutlineInputBorder()),
                      controller: _avatarController,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextButton(
                        style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Colors.purple,
                            elevation: 4),
                        onPressed: () {
                          final sizeWidget = _key.currentContext!.size;
                          print(sizeWidget);
                        },
                        child: const Text("Update"))
                  ],
                ),
              )),
        ),
      ),
    );
  }
}

class _SaveTodoDialog extends StatefulWidget {
  _SaveTodoDialog(
      {Key? key, this.selectedRangeDate, this.selectedDate, this.todo})
      : super(key: key);

  DateTime? selectedDate;
  final PickerDateRange? selectedRangeDate;
  final QueryDocumentSnapshot? todo;

  @override
  State<_SaveTodoDialog> createState() => _SaveTodoDialogState();
}

class _SaveTodoDialogState extends State<_SaveTodoDialog> {
  final _key = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _textController = TextEditingController();

  final CollectionReference _todos =
      FirebaseFirestore.instance.collection('todos');

  String _routeImage = "";

  _selectedImage(routeImage) {
    _routeImage = routeImage;
    setState(() {});
  }

  @override
  void initState() {
    _nameController.text = widget.todo?['title'] ?? '';
    _textController.text = widget.todo?['content'] ?? '';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: ConstrainedBox(
        constraints: const BoxConstraints(
            minWidth: 100, maxWidth: 450, minHeight: 100, maxHeight: 700),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Form(
              key: _key,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _ImageField(
                        onSelectedImage: _selectedImage, todo: widget.todo),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Name", border: OutlineInputBorder()),
                      controller: _nameController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "You have to put a name to the place";
                        }

                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      maxLines: 3,
                      minLines: 3,
                      decoration: const InputDecoration(
                          labelText: "Text", border: OutlineInputBorder()),
                      controller: _textController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "You have to put a name to the place";
                        }

                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SfDateRangePicker(
                      selectionColor: Colors.purple,
                      selectionMode: DateRangePickerSelectionMode.single,
                      initialSelectedDate: widget.selectedDate == null
                          ? DateTime.now()
                          : widget.selectedDate!,
                      onSelectionChanged: (dateRangePickerSelection) {
                        print(dateRangePickerSelection.value);
                        widget.selectedDate = dateRangePickerSelection.value;
                        setState(() {});
                      },
                    ),
                    if (widget.selectedDate == null)
                      const Text(
                        "Date not Selected",
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextButton(
                        onPressed: () {
                          if (_key.currentState!.validate() &&
                              widget.selectedDate != null) {
                            // print("Guardar!");
                            // print(widget.selectedDate);

                            if (widget.todo == null) {
                              _todos.add({
                                'time': widget.selectedDate,
                                'title': _nameController.text,
                                'content': _textController.text,
                                'image': '',
                                'image_full': '',
                              });
                            } else {
                              _todos.doc(widget.todo?.id).update({
                                'time': widget.selectedDate,
                                'title': _nameController.text,
                                'content': _textController.text
                              });
                            }
                          }
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Colors.purple,
                            elevation: 4),
                        child: const Text("Save"))
                  ],
                ),
              )),
        ),
      ),
    );
  }
}

class _Content extends StatefulWidget {
  Function saveTodoDialog;
  Function selectedDateDialog;
  String orden;

  _Content(
      {Key? key,
      required this.saveTodoDialog,
      required this.selectedDateDialog,
      required this.orden})
      : super(key: key);

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  bool _showImg = true;

  List<QueryDocumentSnapshot> todos = [];
  List<QueryDocumentSnapshot> todosFiltered = [];

  bool firstFiltered = false;

  final CollectionReference _todos =
      FirebaseFirestore.instance.collection('todos');

  Future getDataTodo() async {
    QuerySnapshot query = await _todos.get();
    print("todo:" + query.docs[0]['title']);
  }

  @override
  void initState() {
    super.initState();

    // getDataTodo();

    // todosFiltered = todos;
    // todosFiltered = [...todos];

    // if (widget.orden == "By date") {
    //   todosFiltered.sort(((a, b) => a['time'].compareTo(b['time'])));
    // } else {
    //   todosFiltered.sort(((a, b) => a.id.compareTo(b.id)));
    // }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Flex(
      direction: size.width > 700 ? Axis.horizontal : Axis.vertical,
      children: [
        Expanded(
            flex: size.width > 700 ? 1 : 2,
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border(
                      right: BorderSide(width: 4, color: Colors.deepPurple))),
              child: SingleChildScrollView(
                controller: ScrollController(),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Show Image"),
                        Checkbox(
                            value: _showImg,
                            onChanged: (value) {
                              _showImg = value!;
                              setState(() {});
                            }),
                      ],
                    ),
                    SfDateRangePicker(
                      selectionColor: Colors.purple,
                      startRangeSelectionColor: Colors.deepPurple,
                      endRangeSelectionColor: Colors.deepPurple,
                      rangeSelectionColor: Colors.purple,
                      selectionMode: DateRangePickerSelectionMode.range,
                      // initialSelectedRange: PickerDateRange(
                      //   DateTime.now().subtract(const Duration(days: 3)),
                      //   DateTime.now().add(const Duration(days: 3)),
                      // ),
                      // confirmText: "Yes!!!!",
                      showActionButtons: true,
                      onCancel: () {
                        todosFiltered = todos;
                        firstFiltered = false;
                        setState(() {});
                      },
                      onSubmit: (dateRange) {
                        todosFiltered = [];
                        firstFiltered = true;
                        if (dateRange is PickerDateRange) {
                          for (var i = 0; i < todos.length; i++) {
                            if (todos[i]['time']
                                        .toDate()
                                        .compareTo(dateRange.startDate!) >=
                                    0 &&
                                todos[i]['time']
                                        .toDate()
                                        .compareTo(dateRange.endDate!) <=
                                    0) {
                              todosFiltered.add(todos[i]);
                            }
                            print(todos[i]['time']);
                          }

                          setState(() {});
                        }

                        print(dateRange);
                      },
                      onSelectionChanged: (dateRange) {
                        print(dateRange.value);
                        widget.selectedDateDialog(dateRange.value);
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      style: ElevatedButton.styleFrom(primary: Colors.purple),
                      label: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Add to do",
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                      onPressed: () {
                        widget.saveTodoDialog();
                      },
                    )
                  ],
                ),
              ),
            )),
        Expanded(
            flex: 3,
            child: StreamBuilder(
                stream: _todos
                    .orderBy('time', descending: (widget.orden == "By date"))
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot?> snanpshot) {
                  if (snanpshot.hasData) {
                    todos = snanpshot.data!.docs;
                    if (!firstFiltered) {
                      todosFiltered = snanpshot.data!.docs;
                    }
                    return ListView.builder(
                        itemCount: todosFiltered.length,
                        itemBuilder: ((context, index) => DelayedDisplay(
                              delay: const Duration(milliseconds: 5),
                              slidingBeginOffset: const Offset(-1, 0),
                              fadeIn: true,
                              child: ListTile(
                                title: Card(
                                  child: Flex(
                                    direction: size.width > 800
                                        ? Axis.horizontal
                                        : Axis.vertical,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AnimatedContainer(
                                        width: _showImg
                                            ? size.width > 800
                                                ? 150
                                                : 800
                                            : 0,
                                        duration: const Duration(
                                            milliseconds:
                                                280), //0 si existe overflow
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Image(
                                            image: todosFiltered[index]
                                                        ['image_full'] ==
                                                    ""
                                                ? const AssetImage(
                                                        "assets/images/img.jpg")
                                                    as ImageProvider
                                                : NetworkImage(
                                                    todosFiltered[index]
                                                        ['image_full']),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: (() => widget.saveTodoDialog(
                                            todo: todosFiltered[index])),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                todosFiltered[index]['title'],
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "${todosFiltered[index]['time'].toDate().day}-${todosFiltered[index]['time'].toDate().month} ",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromARGB(
                                                              255, 99, 99, 99)),
                                                    ),
                                                    const SizedBox(height: 30),
                                                    Text(
                                                      todosFiltered[index]
                                                          ['content'],
                                                      style: const TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 99, 99, 99)),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                leading: const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                ),
                                trailing: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) => _ConfirmDialog(
                                            message:
                                                "Are you sure to remove the to do?",
                                            confirm: () {
                                              var id = todosFiltered[index].id;

                                              // todos
                                              //     .remove(todosFiltered[index]);
                                              todosFiltered
                                                  .remove(todosFiltered[index]);
                                              _todos.doc(id).delete();

                                              setState(() {});
                                            }));
                                  },
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            )));
                  }

                  return const _PageEmpty();
                }))
      ],
    );
  }
}

class _PageEmpty extends StatelessWidget {
  const _PageEmpty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            color: Colors.purple.shade100, shape: BoxShape.circle),
        child: const Center(
            child: Text(
          "No Task To Do",
          style: TextStyle(
              color: Colors.purple,
              fontStyle: FontStyle.italic,
              fontSize: 50,
              fontWeight: FontWeight.w100),
        )),
      ),
    );
  }
}

class _ImageField extends StatefulWidget {
  final Function onSelectedImage;
  final String imageDefault;
  final QueryDocumentSnapshot? todo;

  const _ImageField(
      {Key? key,
      required this.onSelectedImage,
      this.imageDefault = "",
      this.todo})
      : super(key: key);

  @override
  State<_ImageField> createState() => _ImageFieldState();
}

class _ImageFieldState extends State<_ImageField> {
  String? _imagePlace;

  final CollectionReference _todos =
      FirebaseFirestore.instance.collection('todos');

  @override
  void initState() {
    _imagePlace =
        widget.todo?['image_full']; // nulo el to do no existe, "" to do sin img

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            imagePicker();
          },
          child: Container(
              width: 160,
              height: 100,
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.purple)),
              child: _imagePlace != null && _imagePlace != ""
                  ? Image(
                      image: NetworkImage(_imagePlace!),
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image, color: Colors.purple)),
        ),
        // TextButton(
        //   onPressed: imagePicker,
        //   child: const Text("Pick a photo"),
        // ),
        // TextButton(
        //   onPressed: cameraPicker,
        //   child: const Text("Take a photo"),
        // )
      ],
    );
  }

  Future imagePicker() async {
    final imageFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 60);

    if (imageFile == null) {
      return;
    }

    _saveImageFirebase(imageFile);
  }

  _saveImageFirebase(XFile file) async {
    // final appDir = await syspath.getApplicationDocumentsDirectory();
    // final fileName = path.basename(_imagePlace!.path);
    // /*final savedImage = */ await _imagePlace!.copy('${appDir.path}/$fileName');

    final filePath = "images/${DateTime.now()}.jpg";

    final storageRef = FirebaseStorage.instance.ref(filePath);

    // storageRef.putData(await _imagePlace!.readAsBytes());

    storageRef
        .putData(await file.readAsBytes())
        .then((TaskSnapshot value) async {
      if (widget.todo != null) {
        final newUrl = await value.ref.getDownloadURL();
        _todos.doc(widget.todo!.id).update({
          'image': value.ref.fullPath,
          'image_full': newUrl,
        });
        _imagePlace = newUrl;
        setState(() {});
      }
    });
  }
}
