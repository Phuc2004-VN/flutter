import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule_model.dart';
import '../models/workspace.dart';

class WorkspaceSelector extends StatelessWidget {
  const WorkspaceSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use Consumer to rebuild only this widget when ScheduleProvider changes
    return Consumer<ScheduleProvider>(
      builder: (context, scheduleProvider, child) {
        final currentWorkspace = scheduleProvider.workspaces.firstWhere(
          (ws) => ws.id == scheduleProvider.currentWorkspaceId, 
          orElse: () => scheduleProvider.workspaces.isNotEmpty 
              ? scheduleProvider.workspaces.first 
              : Workspace(id: 'loading', name: 'Đang tải...') // Handle loading or no workspace state
        );

        return InkWell( // Use InkWell for tap effect
           onTap: () {
             _showWorkspaceMenu(context, scheduleProvider); // Call method to show custom menu
           },
           borderRadius: BorderRadius.circular(8), // Match container border radius
           child: Container(
             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
             decoration: BoxDecoration(
               color: Theme.of(context).brightness == Brightness.dark 
                   ? Colors.blueGrey.shade900.withValues(alpha: 0.7) 
                   : Colors.blue.shade50.withValues(alpha: 0.7),
               borderRadius: BorderRadius.circular(8),
             ),
             child: Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 // Placeholder for current workspace icon/avatar
                 Container(
                   width: 20, // Adjust size as needed
                   height: 20,
                   decoration: BoxDecoration(
                     color: Colors.pink.shade300, // Placeholder color
                     borderRadius: BorderRadius.circular(4),
                   ),
                   child: Center(
                     child: Text(
                       currentWorkspace.name.isNotEmpty ? currentWorkspace.name[0].toUpperCase() : '', // First letter
                       style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                     ),
                   ),
                 ),
                 const SizedBox(width: 8),
                 Text(
                   currentWorkspace.name, // Current Workspace Name
                   style: TextStyle(
                     fontSize: 16,
                     fontWeight: FontWeight.w600,
                     color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                   ),
                 ),
                 const SizedBox(width: 4),
                 Icon(Icons.arrow_drop_down, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey.shade700, size: 20),
               ],
             ),
           ),
        );
      },
    );
  }

  // Method to show custom workspace menu/dialog using showMenu
  void _showWorkspaceMenu(BuildContext context, ScheduleProvider scheduleProvider) async {
     // Get the render box of the InkWell to position the menu
     final RenderBox renderBox = context.findRenderObject() as RenderBox;
     final Offset offset = renderBox.localToGlobal(Offset.zero);

     // Calculate the position for the menu
     final RelativeRect position = RelativeRect.fromRect(
       Rect.fromPoints(
         offset,
         offset.translate(renderBox.size.width, renderBox.size.height),
       ),
       Offset.zero & MediaQuery.of(context).size, // The size of the overlay
     );

     // Build the list of menu items
     List<PopupMenuEntry<String>> items = [];

     // Add 'Current Workspace' section title (optional)
     items.add(const PopupMenuItem<String>(
       value: '_current_title',
       enabled: false,
       child: Text(
         'Current Workspace',
         style: TextStyle(
           fontSize: 12,
           fontWeight: FontWeight.bold,
           // color adjusted in _buildWorkspaceMenuItem
         ),
       ),
     ));

     // Add Current Workspace item
     items.add(_buildWorkspaceMenuItem(context, scheduleProvider.workspaces.firstWhere((ws) => ws.id == scheduleProvider.currentWorkspaceId), true)); // Pass true for isCurrent

     // Add Separator
     items.add(const PopupMenuDivider());

     // Add 'Your Workspaces' section title (optional)
      if (scheduleProvider.workspaces.where((ws) => ws.id != scheduleProvider.currentWorkspaceId).isNotEmpty) { // Only show if there are other workspaces
          items.add(const PopupMenuItem<String>(
             value: '_your_workspaces_title', // Unique value
             enabled: false, // Disable selection
             child: Text(
               'Your Workspaces',
               style: TextStyle(
                 fontSize: 12,
                 fontWeight: FontWeight.bold,
                 // color adjusted in _buildWorkspaceMenuItem
               ),
             ),
          ));
      }

     // Add other workspaces list
     items.addAll(
       scheduleProvider.workspaces
           .where((ws) => ws.id != scheduleProvider.currentWorkspaceId)
           .map((workspace) => _buildWorkspaceMenuItem(context, workspace, false)) // Pass false for isCurrent
           .toList(),
     );

     // Add a separator before the management option
     items.add(const PopupMenuDivider());

     // Add 'Manage Workspaces' option
     items.add(PopupMenuItem<String>(
       value: '_manage_workspaces', // Unique value
       child: Row(
         children: [
           Icon(Icons.settings, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey.shade700, size: 20), // Icon
           const SizedBox(width: 8),
           const Text('Quản lý Workspaces'), // Text
         ],
       ),
     ));

     // Show the menu
     final String? selectedValue = await showMenu<String>(
       context: context,
       position: position,
       items: items,
       elevation: 8.0,
       // color: Theme.of(context).cardColor, // Optional: customize background color
     );

     if (!context.mounted) return; // Add mounted check

     // Handle selection
     if (selectedValue != null) {
       if (selectedValue == '_manage_workspaces') {
         // Show the manage workspaces dialog
         _showManageWorkspacesDialog(context, scheduleProvider);
       } else if (selectedValue != '_current_title' && selectedValue != '_your_workspaces_title' && selectedValue != '_separator') {
         // Select a workspace
         scheduleProvider.setCurrentWorkspace(selectedValue);
       }
     }
  }

  // Helper method to build individual workspace item as PopupMenuItem
  PopupMenuEntry<String> _buildWorkspaceMenuItem(BuildContext context, Workspace workspace, bool isCurrent) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isDark ? Colors.white : Colors.black87; // Default text color


    return PopupMenuItem<String>(
      value: workspace.id,
      child: Container( // Wrap in Container for padding/margin if needed
         padding: const EdgeInsets.symmetric(vertical: 4.0), // Add padding to item content
         child: Row(
          children: [
            // Placeholder for icon/avatar
            Container(
              width: 24, // Adjust size as needed
              height: 24,
              decoration: BoxDecoration(
                color: isCurrent ? Colors.pink.shade300 : Colors.blue.shade300, // Different colors for current/other
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  workspace.name.isNotEmpty ? workspace.name[0].toUpperCase() : '', // First letter
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded( // Use Expanded to prevent overflow if workspace name is long
              child: Text(
                workspace.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal, // Bold for current
                  color: color,
                ),
                overflow: TextOverflow.ellipsis, // Handle long names
              ),
            ),
            // Add checkmark for current workspace
            if (isCurrent)
               Icon(Icons.check, color: Colors.green.shade700, size: 18), // Checkmark icon
          ],
        ),
      ),
    );
  }

  // Method to show the manage workspaces dialog
  void _showManageWorkspacesDialog(BuildContext context, ScheduleProvider scheduleProvider) {
     showDialog(
       context: context,
       builder: (BuildContext context) {
         return AlertDialog(
           title: const Text('Quản lý Workspaces'),
           content: SizedBox(
             width: double.maxFinite,
             child: ListView.builder(
               shrinkWrap: true,
               itemCount: scheduleProvider.workspaces.length,
               itemBuilder: (context, index) {
                 final workspace = scheduleProvider.workspaces[index];
                 // Ensure the default workspace cannot be deleted
                 final bool isDefault = workspace.id == 'default_workspace';
                 return ListTile(
                   leading: Container(
                       width: 30, // Adjust size as needed
                       height: 30,
                       decoration: BoxDecoration(
                         color: isDefault ? Colors.grey.shade500 : Colors.blue.shade300, // Different color for default
                         borderRadius: BorderRadius.circular(4),
                       ),
                       child: Center(
                         child: Text(
                           workspace.name.isNotEmpty ? workspace.name[0].toUpperCase() : '', // First letter
                           style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                         ),
                       ),
                     ),
                   title: Text(workspace.name),
                   trailing: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       // Edit button
                       IconButton(
                         icon: const Icon(Icons.edit, size: 20),
                         tooltip: 'Chỉnh sửa',
                         onPressed: () {
                           Navigator.pop(context); // Close manage dialog
                           _showEditWorkspaceDialog(context, scheduleProvider, workspace); // Show edit dialog
                         },
                       ),
                       // Delete button (only if not default workspace)
                       if (!isDefault)
                         IconButton(
                           icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                           tooltip: 'Xóa',
                           onPressed: () {
                             // Confirm deletion and then delete
                             _confirmDeleteWorkspace(context, scheduleProvider, workspace);
                           },
                         ),
                     ],
                   ),
                 );
               },
             ),
           ),
           actions: <Widget>[
             TextButton(
               child: const Text('Đóng'),
               onPressed: () {
                 Navigator.of(context).pop(); // Close the dialog
               },
             ),
           ],
         );
       },
     );
  }

  // Method to show dialog for editing workspace name
  void _showEditWorkspaceDialog(BuildContext context, ScheduleProvider scheduleProvider, Workspace workspace) {
      final TextEditingController editWorkspaceNameController = TextEditingController(text: workspace.name);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Chỉnh sửa Workspace'),
            content: TextField(
              controller: editWorkspaceNameController,
              decoration: const InputDecoration(hintText: 'Nhập tên mới'),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Hủy'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Lưu'),
                onPressed: () {
                  final newName = editWorkspaceNameController.text.trim();
                  if (newName.isNotEmpty && newName != workspace.name) {
                    // Update the workspace name in ScheduleProvider
                    // We need to add an updateWorkspaceName method to ScheduleProvider
                    scheduleProvider.updateWorkspaceName(workspace.id, newName);
                    Navigator.of(context).pop(); // Close edit dialog
                    _showManageWorkspacesDialog(context, scheduleProvider); // Re-open manage dialog
                  } else {
                     Navigator.of(context).pop(); // Close edit dialog even if no change
                     _showManageWorkspacesDialog(context, scheduleProvider); // Re-open manage dialog
                  }
                },
              ),
            ],
          );
        },
      );
  }

  // Method to confirm workspace deletion
  void _confirmDeleteWorkspace(BuildContext context, ScheduleProvider scheduleProvider, Workspace workspace) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa workspace "${workspace.name}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // Delete the workspace
                scheduleProvider.removeWorkspace(workspace.id);
                Navigator.of(context).pop(); // Close confirmation dialog
                Navigator.of(context).pop(); // Close manage workspaces dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Keep the helper method to build individual workspace item in the menu for titles (optional)
} 