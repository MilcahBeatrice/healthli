import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:healthli/widgets/bottom_navbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Controllers for form fields
  final TextEditingController nameController = TextEditingController(
    text: 'Name',
  );
  final TextEditingController dobController = TextEditingController(
    text: 'dd/mm/yyyy',
  );
  final TextEditingController emailController = TextEditingController(
    text: 'email@gmail.com',
  );
  final TextEditingController phoneController = TextEditingController(
    text: '1234567890',
  );
  final TextEditingController genderController = TextEditingController(
    text: 'Female',
  );
  final TextEditingController heightController = TextEditingController(
    text: '166',
  );
  final TextEditingController weightController = TextEditingController(
    text: '60',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Profile' : 'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading:
            isEditing
                ? IconButton(
                  onPressed: () {
                    setState(() {
                      isEditing = false;
                    });
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.teal,
                    size: 24,
                  ),
                )
                : null,
        actions: [
          if (isEditing)
            TextButton(
              onPressed: () {
                // Save functionality
                setState(() {
                  isEditing = false;
                });
              },
              child: Text(
                'Save',
                style: TextStyle(color: Colors.teal, fontSize: 16),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Avatar Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade200, Colors.teal.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.18),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: ClipOval(
                        child:
                            _profileImage != null
                                ? Image.file(
                                  _profileImage!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                                : Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Colors.white,
                                ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child:
                          isEditing
                              ? GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.teal,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.add_a_photo,
                                    color: Colors.teal,
                                    size: 22,
                                  ),
                                ),
                              )
                              : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isEditing = true;
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.teal,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.teal,
                                    size: 20,
                                  ),
                                ),
                              ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Form Fields
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormField('Name:', nameController),
                  SizedBox(height: 12),
                  _buildFormField('Date of Birth:', dobController),
                  SizedBox(height: 12),
                  _buildFormField('Email:', emailController),
                  SizedBox(height: 12),
                  _buildFormField('Phone:', phoneController),
                  SizedBox(height: 12),
                  _buildFormField('Gender:', genderController),
                  SizedBox(height: 12),
                  _buildFormField('Height/cm:', heightController),
                  SizedBox(height: 12),
                  _buildFormField('Weight/Kg:', weightController),
                ],
              ),

              SizedBox(height: 36),

              // Bottom Action Buttons (only show when not editing)
              if (!isEditing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Log out functionality
                      },
                      icon: Icon(Icons.logout, color: Colors.teal),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.teal,
                        elevation: 1,
                        side: BorderSide(color: Colors.teal, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        textStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      label: Text('Log Out'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Delete account functionality
                      },
                      icon: Icon(Icons.delete_forever, color: Colors.redAccent),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.redAccent,
                        elevation: 1,
                        side: BorderSide(color: Colors.redAccent, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        textStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      label: Text('Delete Account'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HealthBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          // Handle navigation here
          log('Tapped on tab $index');
        },
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.teal.shade700,
            ),
          ),
          SizedBox(height: 2),
          isEditing
              ? TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.teal.shade200,
                      width: 1.2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.teal.shade50,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  isDense: true,
                ),
                style: TextStyle(fontSize: 15, color: Colors.black87),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 2.0,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),

                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.teal.shade200, width: 1.2),
                  ),
                  child: Text(
                    controller.text,
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    emailController.dispose();
    phoneController.dispose();
    genderController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }
}
