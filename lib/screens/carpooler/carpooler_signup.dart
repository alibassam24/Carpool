import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ExtendedCarpoolerSignupScreen extends StatefulWidget {
  const ExtendedCarpoolerSignupScreen({super.key});

  @override
  State<ExtendedCarpoolerSignupScreen> createState() => _ExtendedCarpoolerSignupScreenState();
}

class _ExtendedCarpoolerSignupScreenState extends State<ExtendedCarpoolerSignupScreen> {
  XFile? _licenseImage;
  XFile? _carNumberImage;
  XFile? _cnicFrontImage;
  XFile? _cnicBackImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(Function(XFile) onImagePicked) async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (image != null) {
      onImagePicked(image);
    }
  }

  void _submitForm() {
    if (_licenseImage == null || _carNumberImage == null || _cnicFrontImage == null || _cnicBackImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required documents')),
      );
      return;
    }

    // TODO: Upload images, update user role in backend, then navigate
    Navigator.pushReplacementNamed(context, '/carpooler_home');
  }

  Widget _buildUploadTile(String label, XFile? file, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFE6F2EF),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          file != null ? Icons.check_circle : Icons.upload_file,
          color: file != null ? Colors.green : const Color(0xFF255A45),
        ),
        title: Row(
          children: [
            Text(label),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Text(file != null ? 'Uploaded' : 'Tap to upload'),
      ),
    );
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Upload Required Documents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF255A45)),
            ),
            const SizedBox(height: 20),

            // Upload Tiles
            _buildUploadTile("Driver's License", _licenseImage, () {
              _pickImage((file) => setState(() => _licenseImage = file));
            }),
            _buildUploadTile('Car Number Plate', _carNumberImage, () {
              _pickImage((file) => setState(() => _carNumberImage = file));
            }),
            _buildUploadTile('CNIC Front', _cnicFrontImage, () {
              _pickImage((file) => setState(() => _cnicFrontImage = file));
            }),
            _buildUploadTile('CNIC Back', _cnicBackImage, () {
              _pickImage((file) => setState(() => _cnicBackImage = file));
            }),

            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _submitForm,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF255A45),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
