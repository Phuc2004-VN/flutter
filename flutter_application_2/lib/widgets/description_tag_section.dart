import 'package:flutter/material.dart';
import '../utils/tag_manager.dart';
import 'attachment_section.dart';

class DescriptionTagSection extends StatefulWidget {
  final TextEditingController descriptionController;
  final List<String> selectedTags;
  final List<Map<String, String>> currentAttachments;
  final Function(List<String>) onTagsChanged;
  final Function(List<Map<String, String>>) onAttachmentsChanged;
  final Function(String) onDescriptionChanged;

  const DescriptionTagSection({
    super.key,
    required this.descriptionController,
    required this.selectedTags,
    required this.currentAttachments,
    required this.onTagsChanged,
    required this.onAttachmentsChanged,
    required this.onDescriptionChanged,
  });

  @override
  State<DescriptionTagSection> createState() => _DescriptionTagSectionState();
}

class _DescriptionTagSectionState extends State<DescriptionTagSection> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: widget.descriptionController,
              onChanged: widget.onDescriptionChanged,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Nhập mô tả chi tiết...',
                hintStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                prefixIcon: Icon(Icons.description_rounded, color: Colors.blue.shade400),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gắn tag',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(TagManager.tags.length, (index) {
              final tag = TagManager.tags[index];
              final isSelected = widget.selectedTags.contains(tag);
              return FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      TagManager.tagIcons[index],
                      size: 16,
                      color: isSelected ? Colors.white : TagManager.tagColors[index],
                    ),
                    const SizedBox(width: 4),
                    Text(tag),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  final List<String> newTags = List.from(widget.selectedTags);
                  if (selected) {
                    if (!newTags.contains(tag)) {
                      newTags.add(tag);
                    }
                  } else {
                    newTags.remove(tag);
                  }
                  widget.onTagsChanged(newTags);
                },
                backgroundColor: TagManager.tagColors[index].withOpacity(0.1),
                selectedColor: TagManager.tagColors[index],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : TagManager.tagColors[index],
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? TagManager.tagColors[index] : Colors.transparent,
                    width: 1,
                  ),
                ),
              );
            }),
          ),
          if (widget.selectedTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tag đã chọn',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${widget.selectedTags.length} tag',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.selectedTags.map((tag) {
                      final index = TagManager.tags.indexOf(tag);
                      if (index == -1) return const SizedBox.shrink(); // Skip invalid tags
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: TagManager.tagColors[index].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: TagManager.tagColors[index].withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              TagManager.tagIcons[index],
                              color: TagManager.tagColors[index],
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tag,
                              style: TextStyle(
                                color: TagManager.tagColors[index],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                final List<String> newTags = List.from(widget.selectedTags);
                                newTags.remove(tag);
                                widget.onTagsChanged(newTags);
                              },
                              child: Icon(
                                Icons.close_rounded,
                                color: TagManager.tagColors[index],
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          AttachmentSection(
            currentAttachments: widget.currentAttachments,
            onAttachmentsChanged: widget.onAttachmentsChanged,
          ),
        ],
      ),
    );
  }

} 