import 'package:dodoc/colors.dart';
import 'package:dodoc/models/file_model.dart';

import 'package:flutter/material.dart';

class FilesTab extends StatelessWidget {
  final List<FileModel> files;
  final ValueChanged<FileModel> onOpenedFile;
  final ValueChanged<FileModel>? onDeleteFile;
  final ValueChanged<FileModel> onDownloadFile;

  const FilesTab({
    super.key,
    required this.files,
    required this.onOpenedFile,
    this.onDeleteFile,
    required this.onDownloadFile,
  });

  Color getColor(String extension) {
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.orange;
      case 'txt':
        return Colors.grey;
      default:
        return Colors.red; // Default color for unknown extensions
    }
  }

  @override
  Widget build(BuildContext context) {
    return files.isEmpty
        ? const Center(
            child: Text(
              'No Files To Show',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          )
        : GridView.builder(
            itemCount: files.length,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 8, crossAxisSpacing: 8, crossAxisCount: 3),
            itemBuilder: (context, index) {
              final file = files[index];
              return buildFile(file, context);
            });
  }

  void onItemSelected(int item, BuildContext context, FileModel file) {
    switch (item) {
      case 0:
        // Implement your download logic here
        onDownloadFile(file);
        break;
      case 1:
        // Implement your delete logic here
        onDeleteFile!(file);
        break;
    }
  }

  Widget buildFile(
    FileModel file,
    BuildContext context,
  ) {
    final kb = file.size / 1024;
    final mb = kb / 1024;
    final fileSize =
        mb >= 1 ? '${mb.toStringAsFixed(2)}MB' : '${kb.toStringAsFixed(2)}Kb';
    final fileNameParts =
        file.filename.split('.'); // Split the file name by '.'
    final extension = fileNameParts.length > 1 ? fileNameParts.last : 'none';
    final color = getColor(extension);
    return InkWell(
      onTap: () {
        onOpenedFile(file);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '.$extension',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kWhiteColor),
              ),
            )),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.originalname,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      fileSize,
                      style: const TextStyle(fontSize: 16),
                    )
                  ],
                ),
                PopupMenuButton<int>(
                  onSelected: (item) => onItemSelected(item, context, file),
                  itemBuilder: (context) => [
                    const PopupMenuItem<int>(
                      value: 0,
                      child: Row(
                        children: [
                          Icon(Icons.download),
                          Text('Download'),
                        ],
                      ),
                    ),
                    if (onDeleteFile != null)
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            Text('Delete'),
                          ],
                        ),
                      ),
                  ],
                  icon: const Icon(Icons.more_vert),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
