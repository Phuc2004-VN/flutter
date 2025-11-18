import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class UploadFilesWidget extends StatefulWidget {
  final int scheduleId;

  const UploadFilesWidget({required this.scheduleId, super.key});

  @override
  State<UploadFilesWidget> createState() => _UploadFilesWidgetState();
}

class _UploadFilesWidgetState extends State<UploadFilesWidget> {
  List<Map<String, String>> attachedFiles = [];

  void _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        attachedFiles.addAll(result.files.map((file) => {
          'name': file.name,
          'path': file.path ?? '',
          'extension': file.extension ?? '',
        }));
      });
    }
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _openFile(String filePath) {
    File file = File(filePath);
    if (file.existsSync()) {
      // Xử lý mở file, có thể sử dụng package như open_file
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _pickFiles,
          icon: const Icon(Icons.attach_file),
          label: const Text('Đính kèm tệp'),
        ),
        attachedFiles.isEmpty
            ? const Text('Chưa có tệp đính kèm', style: TextStyle(color: Colors.grey))
            : Column(
                children: attachedFiles.map((file) {
                  return ListTile(
                    leading: Icon(_getFileIcon(file['extension']!)),
                    title: Text(file['name']!),
                    onTap: () => _openFile(file['path']!),
                  );
                }).toList(),
              ),
      ],
    );
  }
}
