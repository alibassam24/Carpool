import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final box = GetStorage();

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
  final supabase = Supabase.instance.client;

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
      _goToChooseRole();
    }
  }

  void _goToChooseRole() {
    Get.offAllNamed('/roles');
  }

  Future<String?> _uploadFile(XFile file, String docType) async {
  try {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) throw "Not logged in";

    final bytes = await File(file.path).readAsBytes();
    final fileExt = file.path.split('.').last;

    // 👇 Save inside folder named by user.id
    final filePath =
        "${user.id}/${docType}_${DateTime.now().millisecondsSinceEpoch}.$fileExt";

    await client.storage
        .from("driver_docs")
        .uploadBinary(filePath, bytes,
            fileOptions: const FileOptions(upsert: true));

    // Generate a public URL (or signed URL if bucket is private)
    final publicUrl =
        client.storage.from("driver_docs").getPublicUrl(filePath);

    return publicUrl;
  } catch (e) {
    debugPrint("❌ Upload failed: $e");
    return null;
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
      final user = supabase.auth.currentUser;
      if (user == null) throw "User not logged in";

      // 1. Upload docs
   final licenseUrl = await _uploadFile(_licenseImage!, "license");
final carPlateUrl = await _uploadFile(_carNumberImage!, "plate");
final cnicFrontUrl = await _uploadFile(_cnicFrontImage!, "cnic_front");
final cnicBackUrl = await _uploadFile(_cnicBackImage!, "cnic_back");


      if ([licenseUrl, carPlateUrl, cnicFrontUrl, cnicBackUrl]
          .any((url) => url == null)) {
        throw "One or more uploads failed. Please retry.";
      }

      // 2. Insert into driver_documents
      await supabase.from("driver_documents").insert({
        "user_id": user.id,
        "license_url": licenseUrl,
        "car_plate_url": carPlateUrl,
        "cnic_front_url": cnicFrontUrl,
        "cnic_back_url": cnicBackUrl,
        "status": "pending",
      });

      // 3. Update user role + status
      await supabase.from("users").update({
        "role": "carpooler",
        "status": "pending",
      }).eq("id", user.id);

      // 4. Save local status
      box.write("carpoolerStatus", "pending");

      // 5. Navigate
      Get.offAllNamed('/verification_pending');
    } catch (e, st) {
      debugPrint("❌ Signup error: $e\n$st");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: $e")),
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
    return WillPopScope(
      onWillPop: () async {
        if (_currentStep > 0) {
          setState(() => _currentStep -= 1);
        } else {
          _goToChooseRole();
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        appBar: AppBar(
          title: const Text('Carpooler Signup'),
          backgroundColor: const Color(0xFF255A45),
          foregroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: _goToChooseRole,
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme:
                  ColorScheme.light(primary: const Color(0xFF255A45)),
            ),
            child: Column(
              children: [
                Stepper(
                  type: StepperType.vertical,
                  currentStep: _currentStep,
                  onStepContinue: _isSubmitting ? null : _onStepContinue,
                  onStepCancel: _isSubmitting ? null : _onStepCancel,
                  onStepTapped: (index) =>
                      setState(() => _currentStep = index),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
