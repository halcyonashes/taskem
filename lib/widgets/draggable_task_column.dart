import 'package:flutter/material.dart';
import 'package:taskem/models/task.dart';
import 'package:taskem/providers/task_provider.dart';
import 'package:taskem/tasks/task_screen.dart';

class DraggableTaskColumn extends StatelessWidget {
  final TaskStatus status;
  final List<Task> tasks;
  final TaskProvider taskProvider;

  const DraggableTaskColumn({
    super.key,
    required this.status,
    required this.tasks,
    required this.taskProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: EdgeInsets.all(8.0),
      child: DragTarget<Task>(
        onWillAcceptWithDetails: (details) {
          final task = details.data;
          return task.status != status.value;
        },
        onAcceptWithDetails: (details) {
          final task = details.data;
          taskProvider.updateTaskStatus(task.id, status.value);
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: status.color.withValues(alpha: 0.3),
                width: candidateData.isNotEmpty ? 2.0 : 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
              color: candidateData.isNotEmpty
                  ? status.color.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 12, color: status.color),
                      SizedBox(width: 8),
                      Text(
                        status.displayName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: status.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: taskProvider.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : tasks.isEmpty
                          ? Center(
                              child: Text(
                                'No tasks',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: tasks.map((task) {
                                  return Draggable<Task>(
                                    key: ValueKey(task.id),
                                    data: task,
                                    feedback: Material(
                                      elevation: 4.0,
                                      child: Container(
                                        width: 230,
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task.title,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              task.description,
                                              style: TextStyle(color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    child: Card(
                                      margin: EdgeInsets.all(8.0),
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    task.title,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.delete, color: Colors.red),
                                                  onPressed: () => taskProvider.deleteTask(task.id),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              task.description,
                                              style: TextStyle(color: Colors.grey[600]),
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                DropdownButton<TaskStatus>(
                                                  value: TaskStatus.values.firstWhere((e) => e.value == task.status),
                                                  items: TaskStatus.values
                                                      .map((e) => DropdownMenuItem(
                                                            value: e,
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.circle, size: 12, color: e.color),
                                                                SizedBox(width: 8),
                                                                Text(e.displayName),
                                                              ],
                                                            ),
                                                          ))
                                                      .toList(),
                                                  onChanged: (newStatus) {
                                                    if (newStatus != null) {
                                                      taskProvider.updateTaskStatus(task.id, newStatus.value);
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 