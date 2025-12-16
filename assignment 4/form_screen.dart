import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:iconsax/iconsax.dart';
import '../models/form_data.dart';
import '../repositories/form_repository.dart';
import '../widgets/phone_input_field.dart';
import 'records_screen.dart';

class FormScreen extends StatefulWidget {
  final FormData? formData;
  final bool isEditing;

  const FormScreen({
    super.key,
    this.formData,
    this.isEditing = false,
  });

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _repository = FormRepository();
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.formData != null) {
      _phoneController.text = widget.formData!.phoneNumber;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    
    if (digitsOnly.length > 15) {
      return 'Phone number is too long';
    }
    
    return null;
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();
    
    final phoneError = _validatePhoneNumber(_phoneController.text);
    if (phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(phoneError),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fix all errors before submitting'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final data = _formKey.currentState!.value;
      
      final formData = FormData(
        id: widget.formData?.id,
        fullName: data['full_name'] as String,
        email: data['email'] as String,
        phoneNumber: _phoneController.text,
        address: data['address'] as String,
        gender: data['gender'] as String,
        createdAt: widget.formData?.createdAt ?? DateTime.now(),
      );

      if (widget.isEditing && formData.id != null) {
        await _repository.update(formData);
        _showSuccessMessage('Form updated successfully!');
        
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        await _repository.create(formData);
        _showSuccessMessage('Form submitted successfully!');
        
        _formKey.currentState?.reset();
        _phoneController.clear();
        
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const RecordsScreen(),
            ),
            (route) => false,
          );
        }
      }
      
    } catch (e) {
      _showErrorMessage('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Form' : 'Submit New Form',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
          onPressed: () => Navigator.pop(context),
          color: Colors.black87,
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.isEditing ? Icons.edit_rounded : Icons.add_circle_rounded,
                      color: Colors.blue,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isEditing ? 'Update Form Data' : 'Create New Form',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.isEditing 
                                ? 'Modify the form details below' 
                                : 'Fill in all required fields to submit a new form',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              FormBuilder(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                initialValue: widget.formData != null
                    ? {
                        'full_name': widget.formData!.fullName,
                        'email': widget.formData!.email,
                        'address': widget.formData!.address,
                        'gender': widget.formData!.gender,
                      }
                    : {},
                child: Column(
                  children: [
                    // Full Name Field
                    _buildFieldHeader('Full Name'),
                    FormBuilderTextField(
                      name: 'full_name',
                      decoration: _buildInputDecoration(
                        hintText: 'Enter your full name',
                        icon: Iconsax.user,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Full name is required'),
                        FormBuilderValidators.minLength(3, errorText: 'Minimum 3 characters'),
                      ]),
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    _buildFieldHeader('Email Address'),
                    FormBuilderTextField(
                      name: 'email',
                      decoration: _buildInputDecoration(
                        hintText: 'example@email.com',
                        icon: Iconsax.sms,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Email is required'),
                        FormBuilderValidators.email(errorText: 'Enter a valid email'),
                      ]),
                    ),
                    const SizedBox(height: 20),

                    // Phone Number Field
                    _buildFieldHeader('Phone Number'),
                    PhoneInputField(
                      controller: _phoneController,
                      labelText: 'Phone Number *',
                    ),
                    const SizedBox(height: 20),

                    // Address Field
                    _buildFieldHeader('Address'),
                    FormBuilderTextField(
                      name: 'address',
                      maxLines: 3,
                      decoration: _buildInputDecoration(
                        hintText: 'Enter your complete address',
                        icon: Iconsax.location,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Address is required'),
                        FormBuilderValidators.minLength(10, errorText: 'Enter complete address'),
                      ]),
                    ),
                    const SizedBox(height: 20),

                    // Gender Field
                    _buildFieldHeader('Gender'),
                    FormBuilderDropdown<String>(
                      name: 'gender',
                      decoration: _buildInputDecoration(
                        hintText: 'Select your gender',
                        icon: Iconsax.profile_2user,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Male',
                          child: Row(
                            children: [
                              Icon(Iconsax.man, size: 20, color: Colors.blue),
                              SizedBox(width: 12),
                              Text('Male'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Female',
                          child: Row(
                            children: [
                              Icon(Iconsax.woman, size: 20, color: Colors.pink),
                              SizedBox(width: 12),
                              Text('Female'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Other',
                          child: Row(
                            children: [
                              Icon(Iconsax.user, size: 20, color: Colors.purple),
                              SizedBox(width: 12),
                              Text('Other'),
                            ],
                          ),
                        ),
                      ],
                      dropdownColor: Colors.white,
                      validator: FormBuilderValidators.required(errorText: 'Please select gender'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // Submit Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade600,
                      Colors.blue.shade400,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.isEditing ? Iconsax.edit_2 : Iconsax.send_2,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              widget.isEditing ? 'UPDATE FORM' : 'SUBMIT FORM',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // Required Field Note
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Colors.grey[600], size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All fields marked with * are required',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[500]),
      prefixIcon: Container(
        margin: const EdgeInsets.all(12),
        child: Icon(icon, size: 22, color: Colors.grey[600]),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }
}