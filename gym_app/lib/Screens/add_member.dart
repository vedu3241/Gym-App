import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gym_app/API_services/api_service.dart';
import 'package:gym_app/components/my_app_bar.dart';
import 'package:gym_app/models/member_model.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  //Form key
  final _formKey = GlobalKey<FormState>();
  File? imageFile;
  // Variable to hold the radio selected value
  String selectedRadio = "Male";

  int? _selectedPackage = 1;
  //Available Packages
  final List<int> packages = [1, 2, 4, 6, 8];

  int amount = 100;
  // Text Controllers
  final TextEditingController _medicalIssueController =
      TextEditingController(text: 'None');
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _amountPaidController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _phoneNumController = TextEditingController();
  int calculateAmount(int months) {
    // Example pricing logic, replace with your own
    switch (months) {
      case 1:
        return 100;
      case 2:
        return 180;
      case 4:
        return 250;
      case 6:
        return 300;
      case 8:
        return 350;
      default:
        return 200; // Default
    }
  }

  //Methods
  Future addMember() async {
    try {
      //If image is not selected then show error
      if (imageFile == null) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: const Text("Can not proceed without image!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Okay"),
              )
            ],
          ),
        );
      } else {
        MemberModel member = MemberModel(
          firstName: _fnameController.text,
          lastName: _lnameController.text,
          phoneNum: int.parse(_phoneNumController.text),
          gender: selectedRadio,
          medicalIssue: _medicalIssueController.text,
          membershipPeriod: _selectedPackage!,
          actualAmount: amount,
          paidAmount: int.parse(_amountPaidController.text),
        );

        final Response res = await ApiService().addMember(member, imageFile!);
        // final responseData = jsonDecode(res.body);
        if (res.statusCode == 200) {
          Navigator.pop(context);
        }
      }
    } catch (err) {
      print(err);
    }
  }

  // Method to handle radio button selection
  void handleRadioValueChanged(String value) {
    setState(() {
      selectedRadio = value;
      // print(selectedRadio);
    });
  }

  final picker = ImagePicker();

  _cropImage(File imgFile) async {
    final croppedFile = await ImageCropper().cropImage(
        sourcePath: imgFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: "Image Cropper",
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: "Image Cropper",
          )
        ]);
    if (croppedFile != null) {
      imageCache.clear();
      setState(() {
        imageFile = File(croppedFile.path);
      });
      // reload();
    }
  }

  _imgFromGallery() async {
    await picker
        .pickImage(source: ImageSource.gallery, imageQuality: 50)
        .then((value) {
      if (value != null) {
        _cropImage(File(value.path));
      }
    });
  }

  _imgFromCamera() async {
    await picker
        .pickImage(source: ImageSource.camera, imageQuality: 50)
        .then((value) {
      if (value != null) {
        _cropImage(File(value.path));
      }
    });
  }

  void showImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Card(
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 5.2,
                margin: const EdgeInsets.only(top: 8.0),
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: InkWell(
                      child: const Column(
                        children: [
                          Icon(
                            Icons.image,
                            size: 60.0,
                          ),
                          SizedBox(height: 12.0),
                          Text(
                            "Gallery",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          )
                        ],
                      ),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.pop(context);
                      },
                    )),
                    Expanded(
                        child: InkWell(
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 60.0,
                            ),
                            SizedBox(height: 12.0),
                            Text(
                              "Camera",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        _imgFromCamera();
                        Navigator.pop(context);
                      },
                    ))
                  ],
                )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    amount.toString();

    return Scaffold(
      appBar: const MyAppBar(text: "New Member"),
      // backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  //For displaying image
                  imageFile == null
                      ? Image.asset(
                          'assets/icons/no_profile_image.png',
                          height: 100.0,
                          width: 100.0,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(150.0),
                          child: Image.file(
                            imageFile!,
                            height: 200.0,
                            width: 200.0,
                            fit: BoxFit.fill,
                          )),
                  const SizedBox(
                    height: 10.0,
                  ),
                  // Select Image button
                  ElevatedButton(
                    onPressed: () async {
                      Map<Permission, PermissionStatus> statuses = await [
                        Permission.storage,
                        Permission.camera,
                      ].request();
                      print(statuses);
                      // if (statuses[Permission.storage]!.isGranted &&
                      //     statuses[Permission.camera]!.isGranted) {
                      showImagePicker(context);
                      // } else {
                      //   print('no permission provided');
                      // }
                    },
                    child: const Text(
                      'Select Image',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  // First and last name
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _fnameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Field can't be empty";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            label: Text("First name"),
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                            contentPadding: EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2.0),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            // hintText: "First Name",
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _lnameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Field can't be empty";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              label: Text("Last name"),
                              labelStyle: TextStyle(
                                color: Colors.black,
                              ),
                              contentPadding: EdgeInsets.all(15),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 2.0),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              )),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  //Phone number
                  TextFormField(
                    controller: _phoneNumController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Field can't be empty";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: const InputDecoration(
                      label: Text("Phone number"),
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                      contentPadding: EdgeInsets.all(15),
                      prefixIcon: Icon(Icons.phone_android),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  //Radio Button Male / Female
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          value: "Male",
                          activeColor: Colors.black,
                          groupValue: selectedRadio,
                          contentPadding: EdgeInsets.all(0),
                          title: const Text('Male'),
                          onChanged: (value) {
                            handleRadioValueChanged(value!);
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          value: "Female",
                          groupValue: selectedRadio,
                          contentPadding: EdgeInsets.all(0),
                          title: const Text('Female'),
                          activeColor: Colors.black,
                          onChanged: (value) {
                            handleRadioValueChanged(value!);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  //Medical Issues
                  TextFormField(
                    controller: _medicalIssueController,
                    decoration: const InputDecoration(
                      label: Text(
                        "Medical Issues",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 18),
                      ),
                      prefixIcon: Icon(Icons.medical_services_outlined),
                      contentPadding: EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  //Drop Down - Package
                  DropdownButtonFormField<int>(
                    value: _selectedPackage,
                    decoration: const InputDecoration(
                      labelText: "Membership Duration",
                      labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    iconEnabledColor: Colors.white,
                    items: packages.map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(
                          '${value.toString()} Month${value > 1 ? 's' : ''}',
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (int? value) {
                      setState(() {
                        _selectedPackage = value!;
                        amount = calculateAmount(value);
                      });
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Displaying amount
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Text(
                          "Actual Amount: ",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        const Icon(
                          Icons.currency_rupee,
                          size: 20,
                        ),
                        Text(
                          amount.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Paid amount
                  TextFormField(
                    controller: _amountPaidController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Field can't be empty";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      label: Text("Paid Amount"),
                      contentPadding: EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  // Save button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Processing data"),
                          ),
                        );
                        addMember();
                      }
                      print(_amountPaidController);
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
