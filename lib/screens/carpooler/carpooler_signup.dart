import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExtendedCarpoolerSignupScreen extends StatefulWidget {
  const ExtendedCarpoolerSignupScreen({super.key});

  @override
  State<ExtendedCarpoolerSignupScreen> createState() =>
      _ExtendedCarpoolerSignupScreenState();
}

class _ExtendedCarpoolerSignupScreenState
    extends State<ExtendedCarpoolerSignupScreen> {
  int _currentStep = 0;
  final ImagePicker _picker = ImagePicker();
  final _sb = Supabase.instance.client;

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
        const SnackBar(content: Text('✅ Image selected')),
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
    } else {
      Get.offAllNamed('/roles');
    }
  }

  Future<void> _submitForm() async {
    if (_licenseImage == null ||
        _carNumberImage == null ||
        _cnicFrontImage == null ||
        _cnicBackImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please upload all required documents')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = _sb.auth.currentUser;
      if (user == null) throw "Not logged in";

      /// Upload files to Supabase Storage
      Future<String> uploadFile(XFile file, String docType) async {
        final fileExt = file.path.split('.').last;
        final path = "${user.id}/$docType.$fileExt";
        await _sb.storage.from('driver_docs').upload(path, File(file.path),
            fileOptions: const FileOptions(upsert: true));
        return path;
      }

      final licensePath = await uploadFile(_licenseImage!, "license");
      final platePath = await uploadFile(_carNumberImage!, "car_plate");
      final cnicFrontPath = await uploadFile(_cnicFrontImage!, "cnic_front");
      final cnicBackPath = await uploadFile(_cnicBackImage!, "cnic_back");

      /// Insert into driver_documents table
      await _sb.from('driver_documents').upsert({
        'user_id': user.id,
        'license_url': licensePath,
        'car_plate_url': platePath,
        'cnic_front_url': cnicFrontPath,
        'cnic_back_url': cnicBackPath,
        'status': 'pending',
        'submitted_at': DateTime.now().toIso8601String(),
      });

      /// Update users table → role + status
      await _sb.from('users').update({
        'role': 'carpooler',
        'status': 'pending',
      }).eq('id', user.id);

      if (!mounted) return;
      Get.offAllNamed('/verification_pending');
    } catch (e, st) {
      debugPrint("❌ Submit failed: $e\n$st");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

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
        subtitle:
            file != null ? const Text('Uploaded') : const Text('Tap to upload'),
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
        state:
            _licenseImage != null ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Car Number Plate'),
        content: _uploadCard(
          "Upload Car Number Plate",
          _carNumberImage,
          () => _pickImage((file) => setState(() => _carNumberImage = file)),
        ),
        isActive: _currentStep >= 1,
        state:
            _carNumberImage != null ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('CNIC Front'),
        content: _uploadCard(
          "Upload CNIC Front",
          _cnicFrontImage,
          () => _pickImage((file) => setState(() => _cnicFrontImage = file)),
        ),
        isActive: _currentStep >= 2,
        state:
            _cnicFrontImage != null ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('CNIC Back'),
        content: _uploadCard(
          "Upload CNIC Back",
          _cnicBackImage,
          () => _pickImage((file) => setState(() => _cnicBackImage = file)),
        ),
        isActive: _currentStep >= 3,
        state:
            _cnicBackImage != null ? StepState.complete : StepState.indexed,
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
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF255A45)),
        ),
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: _isSubmitting ? null : _onStepContinue,
          onStepCancel: _isSubmitting ? null : _onStepCancel,
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
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_currentStep == _buildSteps().length - 1
                          ? 'Submit'
                          : 'Next'),
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
      ),
    );
  }
}
