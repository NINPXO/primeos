import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/search_result.dart';

class SearchResultCard extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onTap;

  const SearchResultCard({
    required this.result,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: onTap,
        leading: _buildLeadingIcon(result),
        title: Text(
          result.map(
            goalResult: (r) => r.title,
            progressResult: (r) => r.goalTitle,
            dailyLogResult: (r) => r.title,
            noteResult: (r) => r.title,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: _buildSubtitle(result, context),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildLeadingIcon(SearchResult result) {
    return result.map(
      goalResult: (r) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.flag, color: Colors.blue),
      ),
      progressResult: (r) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.trending_up, color: Colors.green),
      ),
      dailyLogResult: (r) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.calendar_today, color: Colors.orange),
      ),
      noteResult: (r) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.note, color: Colors.purple),
      ),
    );
  }

  Widget _buildSubtitle(SearchResult result, BuildContext context) {
    return result.map(
      goalResult: (r) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Wrap(
          spacing: 8,
          children: [
            _buildBadge(r.categoryName),
            _buildBadge(r.status),
            _buildBadge(DateFormat('MMM d').format(r.createdAt)),
          ],
        ),
      ),
      progressResult: (r) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Wrap(
          spacing: 8,
          children: [
            _buildBadge('${r.value}${r.unit.isEmpty ? '' : ' ${r.unit}'}'),
            _buildBadge(DateFormat('MMM d').format(r.loggedDate)),
          ],
        ),
      ),
      dailyLogResult: (r) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Wrap(
          spacing: 8,
          children: [
            _buildBadge(r.categoryName),
            _buildBadge(DateFormat('MMM d').format(r.logDate)),
          ],
        ),
      ),
      noteResult: (r) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (r.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Wrap(
                  spacing: 6,
                  children: r.tags
                      .take(2)
                      .map((tag) => _buildBadge(tag))
                      .toList(),
                ),
              ),
            Text(
              r.contentPreview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
