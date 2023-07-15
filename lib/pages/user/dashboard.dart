import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:todolistapp/firebase_service.dart';
import 'package:todolistapp/task.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late FirebaseFirestore _firestore;
  late CollectionReference _todosCollection;
  List<Task> _tasks = [];

  // Text editing controllers for the user input
  TextEditingController _textFieldController = TextEditingController();
  TextEditingController _otherInfoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize Firebase Firestore
    _firestore = FirebaseService.getFirestore();
    _todosCollection = _firestore.collection('todos');
    // Listen to changes in the todos collection
    _todosCollection.snapshots().listen(_onTodoListChanged);
  }

  // Callback function to handle changes in the todos collection
  void _onTodoListChanged(QuerySnapshot snapshot) {
    setState(() {
      // Convert each document snapshot to a Task object and update the task list
      _tasks = snapshot.docs.map((doc) => Task.fromSnapshot(doc)).toList();
    });
  }

  // Toggle the completion status of a task
  void _toggleComplete(Task task) {
    _todosCollection.doc(task.id).update({'isCompleted': !task.isCompleted}).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update completion status for "${task.title}"'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  // Delete a task
  void _deleteItem(Task task) {
    _todosCollection.doc(task.id).delete().catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete "${task.title}"'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  // Update the title of a task
  void _updateItem(Task task) {
    _textFieldController.text = task.title;
    _otherInfoController.text = task.otherInfo;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update To-Do Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textFieldController,
                decoration: InputDecoration(
                  hintText: 'Enter updated item title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _otherInfoController,
                decoration: InputDecoration(
                  hintText: 'Enter updated description',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Update'),
              onPressed: () {
                String updatedTitle = _textFieldController.text;
                String updatedOtherInfo = _otherInfoController.text;
                if (updatedTitle.isNotEmpty) {
                  _todosCollection.doc(task.id).update({
                    'title': updatedTitle,
                    'otherInfo': updatedOtherInfo,
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update "${task.title}"'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Updated "${task.title}" to "$updatedTitle"'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Set the due date for a task
  void _setDueDate(Task task) async {
    final DateTime initialDate = task.dueDate ?? DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2025),
    );

    if (pickedDate != null) {
      _todosCollection.doc(task.id).update({
        'dueDate': pickedDate,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Due date updated for "${task.title}"'),
            duration: Duration(seconds: 2),
          ),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update due date for "${task.title}"'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  String _getStatusMessage(Task task) {
    return task.isCompleted ? 'Completed' : 'Pending';
  }

  Widget _buildTaskItem(Task task) {
    IconData statusIcon;
    Color statusColor;

    if (task.isCompleted) {
      statusIcon = Icons.check_circle;
      statusColor = Colors.green;
    } else {
      statusIcon = Icons.radio_button_unchecked;
      statusColor = Colors.red;
    }

    String statusMessage = _getStatusMessage(task);

    return ListTile(
        title: Text(
        task.title,
        style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
    ),
    ),
    subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Due Date: ${task.dueDate}',
    ),
    Text(
    'Status: $statusMessage',
    style: TextStyle(
    fontWeight: FontWeight.bold,
    color : statusColor,
    ),
    ),
    ],
    ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _updateItem(task),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _setDueDate(task),
          ),
          IconButton(
            icon: Icon(statusIcon, color: statusColor),
            onPressed: () => _toggleComplete(task),
          ),
        ],
      ),
      onTap: () => _updateItem(task),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = '${now.year}-${now.month}-${now.day}';
    String formattedTime = '${now.hour}:${now.minute}';
    return Scaffold(
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _deleteItem(_tasks[index]),
            background: Container(
              alignment: Alignment.centerRight,
              color: Colors.red,
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: _buildTaskItem(_tasks[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addTodoItem(context),
      ),
    );
  }

  void _addTodoItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add a To-Do Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textFieldController,
                decoration: InputDecoration(
                  hintText: 'Enter item title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _otherInfoController,
                decoration: InputDecoration(
                  hintText: 'Enter description',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                String title = _textFieldController.text;
                String otherInfo = _otherInfoController.text;
                if (title.isNotEmpty) {
                  _textFieldController.clear();
                  _otherInfoController.clear();
                  _todosCollection.add({
                    'title': title,
                    'otherInfo': otherInfo,
                    'isCompleted': false,
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add "$title"'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added "$title"'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
