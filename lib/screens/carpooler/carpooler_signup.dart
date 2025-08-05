
import 'dart:io';
import 'package:carpool_connect/screens/auth/choose_role_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

final box = GetStorage();

class ExtendedCarpoolerSignupScreen extends StatefulWidget {
  const ExtendedCarpoolerSignupScreen({super.key});

  @override
  State<ExtendedCarpoolerSignupScreen> createState() => _ExtendedCarpoolerSignupScreenState();
}

class _ExtendedCarpoolerSignupScreenState extends State<ExtendedCarpoolerSignupScreen> {
  int _currentStep = 0;
  final ImagePicker _picker = ImagePicker();

  XFile? _licenseImage;
  XFile? _carNumberImage;
  XFile? _cnicFrontImage;
  XFile? _cnicBackImage;

  bool _isSubmitting = false;

  Future<void> _pickImage(Function(XFile) onImagePicked) async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      onImagePicked(image);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Image uploaded successfully')),
      );
    }
  }

  void _onStepContinue() {
    if (_currentStep < _buildSteps().length - 1) {
      setState(() => _currentStep += 1);
    } else {
      _submitForm();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  Future<void> _submitForm() async {
    if (_licenseImage == null || _carNumberImage == null || _cnicFrontImage == null || _cnicBackImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please upload all required documents')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF255A45)),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    box.write('carpoolerStatus', 'pending');

    Navigator.of(context).pop(); // Close dialog
    Get.offAllNamed('/verification_pending');
  }

  Widget _uploadCard(String label, XFile? file, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: file != null ? const Color(0xFFDFF0E9) : const Color(0xFFE6F2EF),
          borderRadius: BorderRadius.circular(12),
          //border: Border.all(color: const Color(0xFF255A45), width: 1),
        ),
        child: Row(
          children: [
            Icon(
              file != null ? Icons.check_circle : Icons.upload_file,
              color: file != null ? Colors.green : const Color(0xFF255A45),
              size: 44,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    file != null ? 'Uploaded' : 'Tap to upload',
                    style: TextStyle(
                      color: file != null ? Colors.green : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (file != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(file.path),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text("Driver's License"),
        content: _uploadCard("Upload Driver's License", _licenseImage, () => _pickImage((f) => setState(() => _licenseImage = f))),
        isActive: _currentStep >= 0,
        state: _licenseImage != null ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Car Number Plate'),
        content: _uploadCard("Upload Car Number Plate", _carNumberImage, () => _pickImage((f) => setState(() => _carNumberImage = f))),
        isActive: _currentStep >= 1,
        state: _carNumberImage != null ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('CNIC Front'),
        content: _uploadCard("Upload CNIC Front", _cnicFrontImage, () => _pickImage((f) => setState(() => _cnicFrontImage = f))),
        isActive: _currentStep >= 2,
        state: _cnicFrontImage != null ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('CNIC Back'),
        content: _uploadCard("Upload CNIC Back", _cnicBackImage, () => _pickImage((f) => setState(() => _cnicBackImage = f))),
        isActive: _currentStep >= 3,
        state: _cnicBackImage != null ? StepState.complete : StepState.indexed,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Carpooler Signup'),
        backgroundColor: const Color(0xFFFAF9F6),
        foregroundColor: const Color(0xFF255A45),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF255A45)),
          onPressed: () =>  Get.offAll(() => const ChooseRoleScreen()),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFF255A45)),
            ),
            child: Column(
              children: [
                Stepper(
                  key: ValueKey<int>(_currentStep),
                  type: StepperType.vertical,
                  currentStep: _currentStep,
                  onStepContinue: _isSubmitting ? null : _onStepContinue,
                  onStepCancel: _isSubmitting ? null : _onStepCancel,
                  onStepTapped: (i) => setState(() => _currentStep = i),
                  controlsBuilder: (context, details) {
                    return Row(
                      children: [
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF255A45),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(_currentStep == _buildSteps().length - 1 ? 'Submit' : 'Next'),
                        ),
                        const SizedBox(width: 10,),
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text('Back'),
                          ),
                      ],
                    );
                  },
                  steps: _buildSteps(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
