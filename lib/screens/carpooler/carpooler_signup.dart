import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ExtendedCarpoolerSignupScreen extends StatefulWidget {
  const ExtendedCarpoolerSignupScreen({super.key});

  @override
  State<ExtendedCarpoolerSignupScreen> createState() => _ExtendedCarpoolerSignupScreenState();
}

class _ExtendedCarpoolerSignupScreenState extends State<ExtendedCarpoolerSignupScreen> {
  int _currentStep = 0;
  final ImagePicker _picker = ImagePicker();
  final GetStorage _box = GetStorage();

  XFile? _licenseImage;
  XFile? _carNumberImage;
  XFile? _cnicFrontImage;
  XFile? _cnicBackImage;

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  void _loadSavedImages() {
    setState(() {
      _licenseImage = _getImageFromPath('licenseImage');
      _carNumberImage = _getImageFromPath('carNumberImage');
      _cnicFrontImage = _getImageFromPath('cnicFrontImage');
      _cnicBackImage = _getImageFromPath('cnicBackImage');
    });
  }

  XFile? _getImageFromPath(String key) {
    final path = _box.read(key);
    return path != null ? XFile(path) : null;
  }

  Future<void> _pickImage(String key, Function(XFile) onImagePicked) async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      _box.write(key, image.path); // Save progress
      onImagePicked(image);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Uploaded successfully"),
        backgroundColor: Colors.green,
      ));
    }
  }

  void _submitForm() {
    if (_licenseImage == null ||
        _carNumberImage == null ||
        _cnicFrontImage == null ||
        _cnicBackImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please upload all required documents'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Clear stored images after success
    _box.remove('licenseImage');
    _box.remove('carNumberImage');
    _box.remove('cnicFrontImage');
    _box.remove('cnicBackImage');

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('All documents uploaded! Redirecting...'),
      backgroundColor: Colors.green,
    ));

    // Simulate route
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/carpooler_home');
    });
  }

  Widget _buildStepTile(String label, XFile? file, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFE6F2EF),
      child: ListTile(
        onTap: onTap,
        leading: file != null
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.upload_file, color: Color(0xFF255A45)),
        title: Text(label),
        subtitle: file != null
            ? const Text('Uploaded')
            : const Text('Tap to upload'),
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

  @override
  Widget build(BuildContext context) {
    final stepStyle = Theme.of(context).copyWith(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF255A45), // Active step
        secondary: Colors.green,     // Completed check
      ),
    );

    return Theme(
      data: stepStyle,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        appBar: AppBar(
          title: const Text('Carpooler Signup'),
          backgroundColor: const Color(0xFF255A45),
          foregroundColor: Colors.white,
        ),
        body: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 3) {
              setState(() => _currentStep++);
            } else {
              _submitForm();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          controlsBuilder: (context, details) {
            return Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF255A45),
                  ),
                  child: Text(_currentStep < 3 ? 'Next' : 'Submit',style:TextStyle(color: const Color(0xFFE6F2EF)),),
                ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
              ],
            );
          },
          steps: [
            Step(
              title: const Text("Driver's License"),
              content: _buildStepTile("Upload your Driver's License", _licenseImage, () {
                _pickImage('licenseImage', (file) => setState(() => _licenseImage = file));
              }),
              isActive: _currentStep >= 0,
              state: _licenseImage != null ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text("Car Number Plate"),
              content: _buildStepTile("Upload your Car's Number Plate", _carNumberImage, () {
                _pickImage('carNumberImage', (file) => setState(() => _carNumberImage = file));
              }),
              isActive: _currentStep >= 1,
              state: _carNumberImage != null ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text("CNIC Front"),
              content: _buildStepTile("Upload CNIC Front", _cnicFrontImage, () {
                _pickImage('cnicFrontImage', (file) => setState(() => _cnicFrontImage = file));
              }),
              isActive: _currentStep >= 2,
              state: _cnicFrontImage != null ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text("CNIC Back"),
              content: _buildStepTile("Upload CNIC Back", _cnicBackImage, () {
                _pickImage('cnicBackImage', (file) => setState(() => _cnicBackImage = file));
              }),
              isActive: _currentStep >= 3,
              state: _cnicBackImage != null ? StepState.complete : StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }
}
