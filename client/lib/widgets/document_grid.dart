import 'package:dodoc/colors.dart';
import 'package:dodoc/models/document_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DocumentGrid extends ConsumerWidget {
  final List<DocumentModel> documents;
  final Function? onDeleteFile;
  final Function? onRemoveDocument;
  final Function navigateToDocument;
  const DocumentGrid(
      {super.key,
      required this.onRemoveDocument,
      required this.navigateToDocument,
      required this.documents,
      required this.onDeleteFile});
  void onItemSelected(
      int item, BuildContext context, DocumentModel doc, WidgetRef ref) {
    switch (item) {
      case 0:
        // Implement your download logic here
        copyLinkToClipboard(
            'http://localhost:3000/#/document/${doc.id}', context);
        break;
      case 1:
        // Implement your delete logic here
        if (onDeleteFile != null) {
          onDeleteFile!(ref, doc.id, context);
        } else {
          onRemoveDocument!(doc.id, ref);
        }
        break;
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return GridView.builder(
        itemCount: documents.length,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 8, crossAxisSpacing: 8, crossAxisCount: 3),
        itemBuilder: (context, index) {
          final file = documents[index];
          return buildFile(file, context, ref, onDeleteFile == null);
        });
  }

  void copyLinkToClipboard(String link, BuildContext context) {
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard'),
      ),
    );
  }

  Widget buildFile(
    DocumentModel doc,
    BuildContext context,
    WidgetRef ref,
    bool isShared,
  ) {
    return InkWell(
      onTap: () {
        navigateToDocument(context, doc.id);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Container(
              alignment: Alignment.topLeft,
              width: double.infinity,
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  doc.title.isEmpty ? 'Untitled Document' : doc.title,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: kBlackColor),
                ),
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
                      DateFormat('dd/MM/yy').format(doc.createdAt),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormat('h:mm a').format(doc.createdAt),
                      style: const TextStyle(fontSize: 16),
                    )
                  ],
                ),
                PopupMenuButton<int>(
                  onSelected: (item) => onItemSelected(item, context, doc, ref),
                  itemBuilder: (context) => [
                    const PopupMenuItem<int>(
                      value: 0,
                      child: Row(
                        children: [
                          Icon(Icons.share),
                          Text('Share'),
                        ],
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(isShared ? Icons.close : Icons.delete),
                          Text(isShared ? 'Remove' : 'Delete'),
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
