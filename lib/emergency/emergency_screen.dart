import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../community/providers.dart';
import '../community/sync_service.dart';
import '../database/models/emergency_contact_model.dart';

class EmergencyScreen extends ConsumerWidget {
  final String userId;
  const EmergencyScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(emergencyContactsProvider(userId));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red[600],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Emergency',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmergencyButton(context),
            const SizedBox(height: 28),
            _buildContactsHeader(context, ref),
            const SizedBox(height: 10),
            Expanded(
              child: contactsAsync.when(
                data:
                    (contacts) =>
                        contacts.isEmpty
                            ? _buildEmptyState(context)
                            : _buildContactsList(contacts, context, ref),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _buildErrorState(context, e.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _callEmergencyNumber(context),
        icon: const Icon(Icons.local_hospital, color: Colors.white, size: 28),
        label: const Text(
          'Call Ambulance',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildContactsHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'My Emergency Contacts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF222222),
          ),
        ),
        TextButton.icon(
          onPressed: () => _showAddContactDialog(context, ref, userId),
          icon: const Icon(Icons.add, color: Color(0xFFD32F2F)),
          label: const Text(
            'Add',
            style: TextStyle(
              color: Color(0xFFD32F2F),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFD32F2F)),
        ),
      ],
    );
  }

  Widget _buildContactsList(
    List<EmergencyContact> contacts,
    BuildContext context,
    WidgetRef ref,
  ) {
    return ListView.separated(
      itemCount: contacts.length,
      separatorBuilder: (context, i) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFD32F2F).withOpacity(0.12),
              child: const Icon(Icons.person, color: Color(0xFFD32F2F)),
            ),
            title: Text(
              contact.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Text(
              '${contact.relationship} • ${contact.phone}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  tooltip: 'Edit',
                  onPressed: () => _showEditDialog(context, ref, contact),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete',
                  onPressed:
                      () => _showDeleteConfirmation(context, ref, contact),
                ),
                IconButton(
                  icon: const Icon(Icons.call, color: Color(0xFF2E7D32)),
                  tooltip: 'Call',
                  onPressed: () => _callContact(context, contact.phone),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 64, color: Colors.red[200]),
            const SizedBox(height: 16),
            const Text(
              'No emergency contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add trusted contacts for quick access in emergencies.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to load contacts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Refresh the provider
                // ref.refresh(emergencyContactsProvider(userId));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Industry standard dialogs with proper validation and UX

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: const Icon(Icons.info_outline, color: Color(0xFFD32F2F)),
            title: const Text('About Emergency Contacts'),
            content: const Text(
              'Add trusted contacts you want to reach out to in case of emergency. They will be available for quick call access.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }

  void _showAddContactDialog(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationshipController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  backgroundColor: Colors.white,
                  icon: const Icon(Icons.person_add, color: Color(0xFFD32F2F)),
                  title: const Text('Add Emergency Contact'),
                  content: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a name';
                            }
                            if (value.trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                            hintText: '+1 234 567 8900',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a phone number';
                            }
                            // Basic phone validation (you might want more sophisticated validation)
                            final phoneRegex = RegExp(
                              r'^\+?[0-9\s\-\(\)]{10,}$',
                            );
                            if (!phoneRegex.hasMatch(value.trim())) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: relationshipController,
                          decoration: const InputDecoration(
                            labelText: 'Relationship',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.family_restroom),
                            hintText: 'e.g., Parent, Sibling, Friend',
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the relationship';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                if (formKey.currentState!.validate()) {
                                  setState(() => isLoading = true);

                                  try {
                                    final contact = EmergencyContact(
                                      id: const Uuid().v4(),
                                      userId: userId,
                                      name: nameController.text.trim(),
                                      phone: phoneController.text.trim(),
                                      relationship:
                                          relationshipController.text.trim(),
                                      isSynced: 0,
                                    );

                                    await ref
                                        .read(emergencyContactDaoProvider)
                                        .insertContact(contact);
                                    await EmergencySyncService.syncAllPendingToFirestore(
                                      contact.userId,
                                    );
                                    ref.refresh(
                                      emergencyContactsProvider(contact.userId),
                                    );

                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                      _showSuccessSnackBar(
                                        context,
                                        'Contact added successfully',
                                      );
                                    }
                                  } catch (e) {
                                    setState(() => isLoading = false);
                                    if (context.mounted) {
                                      _showErrorSnackBar(
                                        context,
                                        'Failed to add contact: $e',
                                      );
                                    }
                                  }
                                }
                              },
                      child:
                          isLoading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Add Contact'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    EmergencyContact contact,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: contact.name);
    final phoneController = TextEditingController(text: contact.phone);
    final relationshipController = TextEditingController(
      text: contact.relationship,
    );
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  backgroundColor: Colors.white,
                  icon: const Icon(Icons.edit, color: Color(0xFFD32F2F)),
                  title: const Text('Edit Emergency Contact'),
                  content: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a name';
                            }
                            if (value.trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a phone number';
                            }
                            final phoneRegex = RegExp(
                              r'^\+?[0-9\s\-\(\)]{10,}$',
                            );
                            if (!phoneRegex.hasMatch(value.trim())) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: relationshipController,
                          decoration: const InputDecoration(
                            labelText: 'Relationship',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.family_restroom),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the relationship';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                if (formKey.currentState!.validate()) {
                                  setState(() => isLoading = true);

                                  try {
                                    final updated = EmergencyContact(
                                      id: contact.id,
                                      userId: contact.userId,
                                      name: nameController.text.trim(),
                                      phone: phoneController.text.trim(),
                                      relationship:
                                          relationshipController.text.trim(),
                                      isSynced: 0,
                                    );

                                    await ref
                                        .read(emergencyContactDaoProvider)
                                        .updateContact(updated);
                                    await EmergencySyncService.syncAllPendingToFirestore(
                                      contact.userId,
                                    );
                                    ref.refresh(
                                      emergencyContactsProvider(contact.userId),
                                    );

                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                      _showSuccessSnackBar(
                                        context,
                                        'Contact updated successfully',
                                      );
                                    }
                                  } catch (e) {
                                    setState(() => isLoading = false);
                                    if (context.mounted) {
                                      _showErrorSnackBar(
                                        context,
                                        'Failed to update contact: $e',
                                      );
                                    }
                                  }
                                }
                              },
                      child:
                          isLoading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Save Changes'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    EmergencyContact contact,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            icon: const Icon(Icons.warning, color: Colors.red),
            title: const Text('Delete Contact'),
            content: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  const TextSpan(text: 'Are you sure you want to delete '),
                  TextSpan(
                    text: contact.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' from your emergency contacts?'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _deleteContact(context, ref, contact);
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  // Helper methods

  Future<void> _callEmergencyNumber(BuildContext context) async {
    const ambulanceNumber = '112';
    final uri = Uri(scheme: 'tel', path: ambulanceNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Could not launch dialer');
      }
    }
  }

  Future<void> _callContact(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Could not launch dialer');
      }
    }
  }

  Future<void> _deleteContact(
    BuildContext context,
    WidgetRef ref,
    EmergencyContact contact,
  ) async {
    try {
      await ref.read(emergencyContactDaoProvider).deleteContact(contact.id);
      await EmergencySyncService.syncAllPendingToFirestore(contact.userId);
      ref.refresh(emergencyContactsProvider(contact.userId));

      if (context.mounted) {
        _showSuccessSnackBar(context, 'Contact deleted successfully');
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to delete contact: $e');
      }
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
