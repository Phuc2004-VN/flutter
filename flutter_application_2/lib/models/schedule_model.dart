import 'package:flutter/material.dart';
import 'schedule.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'workspace.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';

class ScheduleProvider with ChangeNotifier {
  static const String _defaultWorkspaceId = 'default_workspace';

  final _uuid = const Uuid();
  final DatabaseService _databaseService = DatabaseService.instance;

  List<Schedule> _allSchedules = [];
  List<Workspace> _workspaces = [];
  String? _currentWorkspaceId;
  bool _isSyncing = false;

  ScheduleProvider() {
    _loadData();
    _syncFromBackend();
  }

  List<Schedule> get schedules {
    _ensureWorkspaceSetup();
    return _allSchedules
        .where((schedule) => schedule.workspaceId == _currentWorkspaceId)
        .toList();
  }

  List<Schedule> get allSchedules => _allSchedules;

  List<Workspace> get workspaces => _workspaces;

  String? get currentWorkspaceId => _currentWorkspaceId;

  void setCurrentWorkspace(String workspaceId) {
    if (_workspaces.any((ws) => ws.id == workspaceId)) {
      _currentWorkspaceId = workspaceId;
      notifyListeners();
      _saveSchedules();
    }
  }

  void addWorkspace(Workspace workspace) {
    if (!_workspaces.any((ws) => ws.id == workspace.id)) {
      final newWorkspace = Workspace(id: _uuid.v4(), name: workspace.name);
      _workspaces.add(newWorkspace);
      if (_workspaces.length == 1) {
        _currentWorkspaceId = newWorkspace.id;
      }
      notifyListeners();
      _saveSchedules();
    }
  }

  void removeWorkspace(String workspaceId) {
    _workspaces.removeWhere((ws) => ws.id == workspaceId);
    _allSchedules.removeWhere((schedule) => schedule.workspaceId == workspaceId);
    if (_currentWorkspaceId == workspaceId) {
      _currentWorkspaceId = _workspaces.isNotEmpty ? _workspaces.first.id : null;
    }
    notifyListeners();
    _saveSchedules();
  }

  Future<void> addSchedule(Schedule schedule) async {
    _ensureWorkspaceSetup();
    final scheduleWithWorkspace = schedule.copyWith(
      workspaceId: schedule.workspaceId ?? _currentWorkspaceId,
    );
    _allSchedules.add(scheduleWithWorkspace);
    notifyListeners();
    await _saveSchedules();
    await _uploadSchedule(scheduleWithWorkspace);
  }

  Future<void> updateSchedule(int indexInCurrentWorkspace, Schedule updatedSchedule) async {
    final currentWorkspaceSchedules = schedules;
    if (indexInCurrentWorkspace < 0 || indexInCurrentWorkspace >= currentWorkspaceSchedules.length) {
      debugPrint("Error: Index out of bounds for current workspace schedules.");
      return;
    }

    final scheduleToUpdate = currentWorkspaceSchedules[indexInCurrentWorkspace];
    final actualIndex = _allSchedules.indexOf(scheduleToUpdate);
    if (actualIndex == -1) {
      debugPrint("Error: Schedule to update not found in all schedules.");
      return;
    }

    final finalUpdatedSchedule = updatedSchedule.copyWith(
      workspaceId: updatedSchedule.workspaceId ?? scheduleToUpdate.workspaceId,
      id: scheduleToUpdate.id,
    );
    _allSchedules[actualIndex] = finalUpdatedSchedule;
    notifyListeners();
    await _saveSchedules();

    final remoteId = int.tryParse(scheduleToUpdate.id);
    if (remoteId != null) {
      final success = await _databaseService.updateSchedule(remoteId, finalUpdatedSchedule.toJson());
      if (success) {
        await _syncFromBackend();
      }
    } else {
      await _syncFromBackend();
    }
  }

  Future<void> deleteSchedule(int indexInCurrentWorkspace) async {
    final currentWorkspaceSchedules = schedules;
    if (indexInCurrentWorkspace < 0 || indexInCurrentWorkspace >= currentWorkspaceSchedules.length) {
      debugPrint("Error: Index out of bounds for current workspace schedules.");
      return;
    }

    final scheduleToDelete = currentWorkspaceSchedules[indexInCurrentWorkspace];
    _allSchedules.remove(scheduleToDelete);
    notifyListeners();
    await _saveSchedules();

    final remoteId = int.tryParse(scheduleToDelete.id);
    if (remoteId != null) {
      final success = await _databaseService.deleteSchedule(remoteId);
      if (success) {
        await _syncFromBackend();
      }
    }
  }

  Future<void> toggleCompletionStatus(int indexInCurrentWorkspace) async {
    final currentWorkspaceSchedules = schedules;
    if (indexInCurrentWorkspace < 0 || indexInCurrentWorkspace >= currentWorkspaceSchedules.length) {
      debugPrint("Error: Index out of bounds for current workspace schedules.");
      return;
    }

    final scheduleToToggle = currentWorkspaceSchedules[indexInCurrentWorkspace];
    final updatedSchedule = scheduleToToggle.copyWith(
      isCompleted: !scheduleToToggle.isCompleted,
    );
    await updateSchedule(indexInCurrentWorkspace, updatedSchedule);
  }

  void clear() {
    _allSchedules.clear();
    _workspaces.clear();
    _currentWorkspaceId = null;
    notifyListeners();
    _saveSchedules();
  }

  Future<void> refreshFromBackend() async {
    await _syncFromBackend();
  }

  Future<void> _uploadSchedule(Schedule schedule) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('logged_in_user_id');
    if (userId == null) return;
    final success = await _databaseService.saveSchedule(userId, schedule.toJson());
    if (success) {
      await _syncFromBackend();
    }
  }

  Future<void> _saveSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final String allSchedulesJson = jsonEncode(_allSchedules.map((schedule) => schedule.toJson()).toList());
    await prefs.setString('all_schedules', allSchedulesJson);
    final String workspacesJson = jsonEncode(
      _workspaces.map((workspace) => {'id': workspace.id, 'name': workspace.name}).toList(),
    );
    await prefs.setString('workspaces', workspacesJson);
    await prefs.setString('current_workspace_id', _currentWorkspaceId ?? '');
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? allSchedulesJson = prefs.getString('all_schedules');
    if (allSchedulesJson != null) {
      final List<dynamic> jsonList = jsonDecode(allSchedulesJson);
      _allSchedules = jsonList.map((json) => Schedule.fromJson(json)).toList();
    }
    final String? workspacesJson = prefs.getString('workspaces');
    if (workspacesJson != null) {
      final List<dynamic> jsonList = jsonDecode(workspacesJson);
      _workspaces = jsonList.map((json) => Workspace(id: json['id'], name: json['name'])).toList();
    }
    _currentWorkspaceId = prefs.getString('current_workspace_id');

    _ensureWorkspaceSetup();
    notifyListeners();
  }

  Future<void> _syncFromBackend() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('logged_in_user_id');
      if (userId == null) return;
      final remoteData = await _databaseService.getSchedules(userId);
      _ensureWorkspaceSetup();
      _allSchedules = remoteData.map((item) => _mapRemoteSchedule(item)).toList();
      notifyListeners();
      await _saveSchedules();
    } catch (e) {
      debugPrint('Sync schedules error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Schedule _mapRemoteSchedule(Map<String, dynamic> remote) {
    final createdAtString = remote['created_at']?.toString();
    final createdAt = createdAtString != null ? DateTime.parse(createdAtString) : DateTime.now();
    final tagsString = remote['tags']?.toString() ?? '';
    final tags = tagsString.isEmpty
        ? <String>[]
        : tagsString
            .split(',')
            .map((e) => e.trim())
            .where((element) => element.isNotEmpty)
            .toList();
    final deadlineString = remote['deadline']?.toString();
    final deadline = deadlineString != null && deadlineString.isNotEmpty ? DateTime.parse(deadlineString) : null;
    final isCompletedValue = remote['is_completed'];
    final isCompleted = (isCompletedValue is bool && isCompletedValue) ||
        (isCompletedValue is num && isCompletedValue != 0) ||
        (isCompletedValue is String && (isCompletedValue == '1' || isCompletedValue.toLowerCase() == 'true'));

    return Schedule(
      id: remote['id'].toString(),
      title: remote['title'] ?? '',
      description: remote['description'],
      date: createdAt,
      time: TimeOfDay(hour: createdAt.hour, minute: createdAt.minute),
      tags: tags,
      attachments: const [],
      isCompleted: isCompleted,
      priority: remote['priority'],
      deadline: deadline,
      workspaceId: _currentWorkspaceId ?? _defaultWorkspaceId,
    );
  }

  void _ensureWorkspaceSetup() {
    if (_workspaces.isEmpty) {
      final defaultWorkspace = Workspace(id: _defaultWorkspaceId, name: 'Mặc định');
      _workspaces.add(defaultWorkspace);
      _currentWorkspaceId = defaultWorkspace.id;
    }
    if (_currentWorkspaceId == null && _workspaces.isNotEmpty) {
      _currentWorkspaceId = _workspaces.first.id;
    }
  }

  void updateWorkspaceName(String workspaceId, String newName) {
    final index = _workspaces.indexWhere((ws) => ws.id == workspaceId);
    if (index != -1) {
      _workspaces[index] = Workspace(id: workspaceId, name: newName);
      notifyListeners();
      _saveSchedules();
    }
  }
}
