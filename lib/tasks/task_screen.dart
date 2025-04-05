import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/draggable_task_column.dart';

enum TaskStatus {
  pending(0),
  running(1),
  testing(2),
  completed(3);

  final int value;
  const TaskStatus(this.value);

  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.running:
        return 'Running';
      case TaskStatus.testing:
        return 'Testing';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.running:
        return Colors.blue;
      case TaskStatus.testing:
        return Colors.purple;
      case TaskStatus.completed:
        return Colors.green;
    }
  }
}

class TaskScreen extends StatelessWidget {
  TaskScreen({super.key});

  void _showAddTaskDialog(BuildContext context, TaskProvider taskProvider) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                taskProvider.addTask(titleController.text, descController.text);
                Navigator.pop(context);
              }
            },
            child: Text('Add Task'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DraggableTaskColumn(
                    status: TaskStatus.pending,
                    tasks: taskProvider.getTasksByStatus(TaskStatus.pending.value),
                    taskProvider: taskProvider,
                  ),
                  DraggableTaskColumn(
                    status: TaskStatus.running,
                    tasks: taskProvider.getTasksByStatus(TaskStatus.running.value),
                    taskProvider: taskProvider,
                  ),
                  DraggableTaskColumn(
                    status: TaskStatus.testing,
                    tasks: taskProvider.getTasksByStatus(TaskStatus.testing.value),
                    taskProvider: taskProvider,
                  ),
                  DraggableTaskColumn(
                    status: TaskStatus.completed,
                    tasks: taskProvider.getTasksByStatus(TaskStatus.completed.value),
                    taskProvider: taskProvider,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return FloatingActionButton(
            onPressed: () => _showAddTaskDialog(context, taskProvider),
            backgroundColor: Colors.blue,
            child: Icon(Icons.add),
          );
        },
      ),
    );
  }
}