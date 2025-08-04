import 'dart:io';
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

  setState(() => _isSubmitting = true);

  // Simulate API call (pretend we sent data to server)
  await Future.delayed(const Duration(seconds: 2));
  if (!mounted) return;
  // ✅ Save carpooler status as pending (admin will verify)
  box.write('carpoolerStatus', 'pending');

  setState(() => _isSubmitting = false);

  // ✅ Redirect to "Verification Pending" screen
  Get.offAllNamed('/verification_pending');
}

  /* Future<void> _submitForm() async {
    if (_licenseImage == null || _carNumberImage == null || _cnicFrontImage == null || _cnicBackImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please upload all required documents')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate API call and admin verification (for now: always verified)
    await Future.delayed(const Duration(seconds: 2));

    // Redirect after simulated verification
    final bool isVerified = true; // This will later come from backend

    if (isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Your documents have been verified')),
      );
      Navigator.pushReplacementNamed(context, '/carpooler_home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ Documents not verified. Please try again.'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _submitForm,
          ),
        ),
      );
    }

    setState(() => _isSubmitting = false);
  } */

  Widget _uploadCard(String label, XFile? file, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFE6F2EF),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          file != null ? Icons.check_circle : Icons.upload_file,
          color: file != null ? Colors.green : const Color(0xFF255A45),
        ),
        title: Text(label),
        subtitle: file != null ? const Text('Uploaded') : const Text('Tap to upload'),
        trailing: file != null
            ? Image.file(
                File(file.path),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              )
            : null,
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text("Driver's License"),
        content: _uploadCard(
          "Upload Driver's License",
          _licenseImage,
          () => _pickImage((file) => setState(() => _licenseImage = file)),
        ),
        isActive: _currentStep >= 0,
        state: _licenseImage != null ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Car Number Plate'),
        content: _uploadCard(
          "Upload Car Number Plate",
          _carNumberImage,
          () => _pickImage((file) => setState(() => _carNumberImage = file)),
        ),
        isActive: _currentStep >= 1,
        state: _carNumberImage != null ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('CNIC Front'),
        content: _uploadCard(
          "Upload CNIC Front",
          _cnicFrontImage,
          () => _pickImage((file) => setState(() => _cnicFrontImage = file)),
        ),
        isActive: _currentStep >= 2,
        state: _cnicFrontImage != null ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('CNIC Back'),
        content: _uploadCard(
          "Upload CNIC Back",
          _cnicBackImage,
          () => _pickImage((file) => setState(() => _cnicBackImage = file)),
        ),
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
        backgroundColor: const Color(0xFF255A45),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: const Color(0xFF255A45)),
          ),
          child: Column(
            children: [
              Stepper(
                type: StepperType.vertical,
                currentStep: _currentStep,
                onStepContinue: _isSubmitting ? null : _onStepContinue,
                onStepCancel: _isSubmitting ? null : _onStepCancel,
                onStepTapped: (index) => setState(() => _currentStep = index),
                controlsBuilder: (context, details) {
                  return Row(
                    children: [
                      ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF255A45),
                          foregroundColor: Colors.white,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(_currentStep == _buildSteps().length - 1 ? 'Submit' : 'Next'),
                      ),
                      const SizedBox(width: 10),
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
    );
  }
}
