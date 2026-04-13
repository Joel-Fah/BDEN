import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/enums/verification_status.dart';

class HospitalRegistrationScreen extends StatefulWidget {
  const HospitalRegistrationScreen({super.key});

  @override
  State<HospitalRegistrationScreen> createState() => _HospitalRegistrationScreenState();
}

class _HospitalRegistrationScreenState extends State<HospitalRegistrationScreen> {
  int _currentStep = 0;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();

  // Forms
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  bool _isObscure = true;
  bool _isLoading = false;

  void _submitRegistration() async {
    if (!_step3FormKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual registration logic and upload document
      // e.g., create auth user, then create HospitalModel in Firestore
      // status will default to VerificationStatus.pending
      
      await Future.delayed(const Duration(seconds: 2)); // Simulated delay

      Get.snackbar(
        'Registration Submitted',
        'Your registration is pending admin verification.',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Navigate to a "Waiting for Verification" screen or Back to Login
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Registration failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    bool isStepValid = false;

    if (_currentStep == 0) {
      isStepValid = _step1FormKey.currentState?.validate() ?? false;
    } else if (_currentStep == 1) {
      isStepValid = _step2FormKey.currentState?.validate() ?? false;
    } else if (_currentStep == 2) {
      isStepValid = _step3FormKey.currentState?.validate() ?? false;
    }

    if (isStepValid) {
      if (_currentStep < 2) {
        setState(() => _currentStep++);
      } else {
        _submitRegistration();
      }
    }
  }

  void _cancelStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Registration'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: _nextStep,
            onStepCancel: _cancelStep,
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: details.onStepContinue,
                        child: Text(_currentStep == 2 ? 'Submit' : 'Next'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        child: Text(_currentStep == 0 ? 'Cancel' : 'Back'),
                      ),
                    ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Basic Information'),
                content: Form(
                  key: _step1FormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Hospital/Organization Name'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Official Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Location Details'),
                content: Form(
                  key: _step2FormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Street Address'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(labelText: 'City'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _regionController,
                        decoration: const InputDecoration(labelText: 'Region/State'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Verification & Documents'),
                content: Form(
                  key: _step3FormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _licenseController,
                        decoration: const InputDecoration(labelText: 'Medical License Number / Registration ID'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Contact Phone Number'),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement file picker
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload Supporting Document'),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This document will be reviewed by administrators to approve your account. Your account remains pending until then.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 2,
              ),
            ],
          ),
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    super.dispose();
  }
}
