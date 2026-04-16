import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final Map<String, Map<String, dynamic>> _documents = {
    'license': {
      'title': 'Driving License',
      'status': 'Verified',
      'uploadDate': DateTime.now().subtract(const Duration(days: 30)),
      'expiryDate': DateTime.now().add(const Duration(days: 365)),
    },
    'cnic': {
      'title': 'CNIC',
      'status': 'Verified',
      'uploadDate': DateTime.now().subtract(const Duration(days: 30)),
      'expiryDate': null,
    },
    'vehicleRegistration': {
      'title': 'Vehicle Registration',
      'status': 'Pending',
      'uploadDate': DateTime.now().subtract(const Duration(days: 5)),
      'expiryDate': DateTime.now().add(const Duration(days: 180)),
    },
    'insurance': {
      'title': 'Vehicle Insurance',
      'status': 'Verified',
      'uploadDate': DateTime.now().subtract(const Duration(days: 20)),
      'expiryDate': DateTime.now().add(const Duration(days: 90)),
    },
  };

  void _uploadDocument(String docType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upload ${_documents[docType]!['title']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement camera capture
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera capture coming soon')),
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement file picker
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('File picker coming soon')),
                );
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose from Gallery'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Verified':
        return AppTheme.successColor;
      case 'Pending':
        return AppTheme.warningColor;
      case 'Rejected':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Documents'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info Card
          Card(
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Upload all required documents to start driving. Documents are reviewed within 24-48 hours.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Documents List
          ..._documents.entries.map((entry) {
            final doc = entry.value;
            final status = doc['status'] as String;
            final statusColor = _getStatusColor(status);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.2),
                  child: Icon(
                    Icons.description,
                    color: statusColor,
                  ),
                ),
                title: Text(doc['title'] as String),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (doc['expiryDate'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Expires: ${_formatDate(doc['expiryDate'] as DateTime)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
                trailing: status == 'Verified'
                    ? const Icon(Icons.check_circle, color: AppTheme.successColor)
                    : IconButton(
                  icon: const Icon(Icons.upload),
                  onPressed: () => _uploadDocument(entry.key),
                  tooltip: 'Upload Document',
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}


