import 'package:flutter/material.dart';

class CreatePostSheet extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onPost;

  const CreatePostSheet({
    super.key,
    required this.controller,
    required this.onPost,
  });

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  bool _isPosting = false;
  int _characterCount = 0;
  static const int _maxCharacters = 280;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateCharacterCount);
    _characterCount = widget.controller.text.length;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateCharacterCount);
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = widget.controller.text.length;
    });
  }

  bool get _canPost =>
      widget.controller.text.trim().isNotEmpty &&
      _characterCount <= _maxCharacters &&
      !_isPosting;

  Color get _progressColor {
    if (_characterCount > _maxCharacters) return Colors.red;
    if (_characterCount > _maxCharacters * 0.9) return Colors.orange;
    return Colors.green[600]!;
  }

  void _handlePost() async {
    if (!_canPost) return;

    setState(() => _isPosting = true);

    try {
      widget.onPost();
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 20,
          right: 20,
          top: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Row(
              children: [
                // Cancel button
                TextButton(
                  onPressed: _isPosting ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Spacer(),

                // Post button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: ElevatedButton(
                    onPressed: _canPost ? _handlePost : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _canPost ? Colors.green[600] : Colors.grey[300],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: const Size(80, 36),
                    ),
                    child:
                        _isPosting
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Post',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Main content area
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: Colors.green[600], size: 24),
                ),

                const SizedBox(width: 12),

                // Text input area
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text field
                      TextField(
                        controller: widget.controller,
                        maxLines: null,
                        minLines: 3,
                        enabled: !_isPosting,
                        style: const TextStyle(fontSize: 18, height: 1.4),
                        decoration: InputDecoration(
                          hintText: "What's happening?",
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        autofocus: true,
                      ),

                      const SizedBox(height: 16),

                      // Character counter and actions
                      Row(
                        children: [
                          // Action buttons
                          Row(
                            children: [
                              _ActionButton(
                                icon: Icons.image_outlined,
                                onTap:
                                    _isPosting
                                        ? null
                                        : () {
                                          // TODO: Implement image picker
                                        },
                              ),
                              const SizedBox(width: 8),
                              _ActionButton(
                                icon: Icons.gif_box_outlined,
                                onTap:
                                    _isPosting
                                        ? null
                                        : () {
                                          // TODO: Implement GIF picker
                                        },
                              ),
                              const SizedBox(width: 8),
                              _ActionButton(
                                icon: Icons.poll_outlined,
                                onTap:
                                    _isPosting
                                        ? null
                                        : () {
                                          // TODO: Implement poll creation
                                        },
                              ),
                              const SizedBox(width: 8),
                              _ActionButton(
                                icon: Icons.location_on_outlined,
                                onTap:
                                    _isPosting
                                        ? null
                                        : () {
                                          // TODO: Implement location picker
                                        },
                              ),
                            ],
                          ),

                          const Spacer(),

                          // Character counter
                          if (_characterCount > _maxCharacters * 0.8)
                            Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    value: _characterCount / _maxCharacters,
                                    strokeWidth: 2,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _progressColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_maxCharacters - _characterCount}',
                                  style: TextStyle(
                                    color: _progressColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null ? Colors.green[600] : Colors.grey[400],
        ),
      ),
    );
  }
}
