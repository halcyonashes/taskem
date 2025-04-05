import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskem/models/task.dart';

class TaskProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  TaskProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('tasks').get();
      _tasks = snapshot.docs
          .map((doc) => Task.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error loading tasks: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Task> getTasksByStatus(int status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  Future<void> addTask(String title, String description) async {
    try {
      final docRef = await _firestore.collection('tasks').add({
        'title': title,
        'description': description,
        'status': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      final task = Task.fromFirestore(await docRef.get());
      _tasks.add(task);
      notifyListeners();
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  Future<void> updateTaskStatus(String taskId, int newStatus) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      final doc = await _firestore.collection('tasks').doc(taskId).get();
      final updatedTask = Task.fromFirestore(doc);
      final index = _tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating task status: $e');
    }
  }

  Future<void> updateTask(String taskId, String title, String description) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'title': title,
        'description': description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  Future<void> reorderTasks(List<Task> reorderedTasks) async {
    try {
      // Update the local list first
      _tasks = reorderedTasks;
      notifyListeners();

      // Update Firestore with the new order
      final batch = _firestore.batch();
      for (var i = 0; i < reorderedTasks.length; i++) {
        final task = reorderedTasks[i];
        batch.update(
          _firestore.collection('tasks').doc(task.id),
          {'order': i},
        );
      }
      await batch.commit();
    } catch (e) {
      print('Error reordering tasks: $e');
    }
  }
} 