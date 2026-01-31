import 'package:flutter/material.dart';

class VersePreviewButton extends StatelessWidget {
  final List<String> verses;
  final Function(String) onPreview;

  const VersePreviewButton({
    super.key,
    required this.verses,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    if (verses.isEmpty) return const SizedBox.shrink();

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: verses.length == 1
            ? _buildSingleVerseButton(context, verses.first)
            : _buildMultipleVersesButton(context),
      ),
    );
  }

  Widget _buildSingleVerseButton(BuildContext context, String verse) {
    return InkWell(
      onTap: () => onPreview(verse),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.visibility,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Preview Verse',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  verse,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleVersesButton(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onPreview,
      itemBuilder: (context) => verses
          .map(
            (verse) => PopupMenuItem(
              value: verse,
              child: Row(
                children: [
                  const Icon(Icons.book, size: 16),
                  const SizedBox(width: 8),
                  Text(verse),
                ],
              ),
            ),
          )
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.visibility,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Preview Verses',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${verses.length} verses detected',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
