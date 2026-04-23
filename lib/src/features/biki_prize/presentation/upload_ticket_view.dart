import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../data/prize_repository.dart';

class UploadTicketView extends StatefulWidget {
  const UploadTicketView({super.key});

  @override
  State<UploadTicketView> createState() => _UploadTicketViewState();
}

class _UploadTicketViewState extends State<UploadTicketView> {
  File? _selectedImage;
  int _selectedSem = 5;
  int _seriesCount = 1;
  bool _isUploading = false;
  final _repository = PrizeRepository();
  final _picker = ImagePicker();

  final List<int> _semOptions = [5, 10, 30, 50, 100, 200];

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedImage == null) return;

    // Double Confirmation
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Submission',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text(
                'Are you sure you want to submit this ticket for verification? Please ensure the image is clear.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: kNavyPrimary),
                child: const Text('YES, SUBMIT'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    setState(() => _isUploading = true);

    try {
      await _repository.uploadTicket(
        imageFile: _selectedImage!,
        semCount: _selectedSem,
        seriesCount: _seriesCount,
      );
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Ticket uploaded successfully!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('UPLOAD TICKET',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Preview
              GestureDetector(
                onTap: () => _showImageSourceActionSheet(),
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined,
                                size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text('Tap to capture or select ticket photo',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // SEM Selection
              const Text(
                'SELECT TICKET SEM',
                style: TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _semOptions.map((sem) {
                  final isSelected = _selectedSem == sem;
                  final price = sem * 7;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSem = sem),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? kNavyPrimary : Colors.white,
                        border: Border.all(
                            color: isSelected
                                ? kNavyPrimary
                                : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$sem SEM',
                            style: TextStyle(
                              color: isSelected ? Colors.white : kNavyPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹$price',
                            style: TextStyle(
                              color: isSelected ? Colors.white70 : Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Series Count Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL SERIES COUNT',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => setState(() { if(_seriesCount > 1) _seriesCount--; }),
                          icon: const Icon(Icons.remove_circle_outline),
                          color: kNavyPrimary,
                        ),
                        Text(
                          '$_seriesCount',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        IconButton(
                          onPressed: () => setState(() { if(_seriesCount < 50) _seriesCount++; }),
                          icon: const Icon(Icons.add_circle_outline),
                          color: kNavyPrimary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Text('Example: 12345-49 is 5 series', style: TextStyle(fontSize: 10, color: Colors.grey)),

              const SizedBox(height: 48),

              // Price Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kNavyPrimary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: kNavyPrimary.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Claim Fee:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      '₹${_selectedSem * 7 * _seriesCount}',
                      style: TextStyle(color: kNavyPrimary, fontWeight: FontWeight.black, fontSize: 24),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (_selectedImage == null || _isUploading) ? null : _handleUpload,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: kNavyPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('SUBMIT FOR VERIFICATION',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take Photo'),
              onTap: () {
                context.pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () {
                context.pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
