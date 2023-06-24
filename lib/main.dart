import 'dart:io';
import 'package:cataloguer/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final tempData = await FirebaseFirestore.instance
      .collection("Departments")
      .doc("Departments")
      .get();

  Map<String, dynamic>? departments_ = (tempData.exists)
      ? tempData.data()
      : {
          "Cleaning": [
            "Soap",
            "Toothpaste",
            "Cleaners",
            "Hygenie",
            "Laundry",
            "Brooms/Brushes/Mops"
          ],
          "Flower": [
            "Filler",
            "Vase",
            "Accessories",
            "Single",
            "Bunch",
            "Vine"
          ],
          "Gardeneing": ["Seeds", "Pots", "Tools"],
          "Hardware": [
            "Tools",
            "Paint",
            "Fasteners",
            "Electricals",
            "Kitchen",
            "Bathroom",
            "Flooring",
            "Ropes/Chains",
            "Mesh",
            "PPE",
            "Rainware",
            "Plumbing",
          ],
          "Kitchenware": [
            "Utensils",
            "Organizers",
            "Glass",
            "Cookware",
            "Plates",
            "Containers",
            "Bottles",
            "Organizers",
            "Cleaning",
            "Jars",
            "Baskets",
            "Plastic",
            "Cups",
            "Ceramics",
            "Baking",
            "Basins/Sieves",
          ],
          "Party": [
            "Birthday",
            "Gender Reveal",
            "New Year",
            "Anniversary",
            "Sweet Sixteen",
            "Baby Shower",
            "Valentines",
            "Mothers Day",
            "Fathers Day",
            "Celebration",
            "Old Years",
            "Christmas",
            "Independence",
            "Mashrimani",
          ],
          "Wedding": [
            "Bouquet",
            "Invitations",
            "Broach",
            "Decorations",
            "Jewellery",
          ],
          "Stationary": [
            "Writing/Drawing",
            "Books",
            "Arts&Crafts",
            "Math",
            "Office",
            "Charts",
            "School",
          ]
        };

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  var email = sharedPreferences.get("email");

  runApp((email == null)
      ? SignInPage(
          departments_: departments_,
          pref: sharedPreferences,
        )
      : UploadScreen(
          departments_: departments_,
          pref: sharedPreferences,
        ));
}

class UploadScreen extends StatelessWidget {
  const UploadScreen({
    super.key,
    required this.departments_,
    required this.pref,
  });

  final Map<String, dynamic>? departments_;
  final SharedPreferences pref;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Upload Products',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Upload Products'),
          backgroundColor: Colors.blue.shade700,
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          children: [
            MyCustomForm(
              departments_: departments_,
              pref: pref,
            ),
          ],
        ),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({
    super.key,
    required this.departments_,
    required this.pref,
  });

  final SharedPreferences pref;
  final Map<String, dynamic>? departments_;

  @override
  @override
  State<MyCustomForm> createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm> {
  FocusNode focusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();
  var db = FirebaseFirestore.instance;
  var storageRef = FirebaseStorage.instance.ref();
  String dropdownValue = "Cleaning";

  var barcodeController = TextEditingController();
  Set<String> sections = <String>{};
  List<File?> images = [];

  bool isRepeatBarcode = false;
  bool isUploading = false;
  bool isDisabled = false;

  void clearForm() {
    setState(() {
      images = [];
      sections = <String>{};
      dropdownValue = widget.departments_!.keys.first;
      barcodeController.clear();
    });
  }

  Future<void> uploadImagesFirebase(
      List<File?> images, List<String> imagePaths, String department) async {
    for (var i = 0; i < images.length; i++) {
      final file = images[i];
      if (file != null) {
        await storageRef
            .child("products/$department/${imagePaths[i]}")
            .putFile(file);
      }
    }
  }

  Future<void> saveImagesLocal(List<File?> images) async {
    for (var i = 0; i < images.length; i++) {
      final currentImage = images[i];
      if (currentImage != null) {
        await GallerySaver.saveImage(currentImage.path, albumName: 'Products');
      }
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _formKey.currentState?.validate();
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            //Barcode
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              focusNode: focusNode,
              decoration: const InputDecoration(
                  icon: Icon(Icons.barcode_reader), labelText: "Barcode"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter Barcode";
                }
                if (num.tryParse(value) == null) {
                  return "Invalid Barcode";
                }
                if (value.trim() != value) {
                  return "Remove spaces from barcode";
                }
                if (isRepeatBarcode) {
                  isRepeatBarcode = false;
                  return "Repeat Barcode";
                }
                return null;
              },
              controller: barcodeController,
              onTap: () => focusNode.requestFocus(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.storage),
                labelText: "Department",
              ),
              validator: (value) {
                return null;
              },
              value: dropdownValue,
              onChanged: (String? value) {
                setState(() {
                  dropdownValue = value!;
                  sections = {};
                });
              },
              items: widget.departments_?.keys
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SectionsFilterChips(
              inputSection: widget.departments_?[dropdownValue] ?? [""],
              sections: sections,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ProductPhoto(
              images: images,
            ),
          ),
          Padding(
            //Submit
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
                onPressed: isDisabled
                    ? null
                    : () async {
                        setState(() {
                          isUploading = true;
                          isDisabled = true;
                        });

                        if (!_formKey.currentState!.validate()) {
                          setState(() {
                            isUploading = false;
                            isDisabled = false;
                          });
                          return;
                        }
                        final product = <String, dynamic>{
                          "barcode": barcodeController.text,
                          "department": dropdownValue,
                          "sections": sections.toList(),
                          "images": images.map((file) {
                            return "${barcodeController.text}-${images.indexOf(file)}.jpg";
                          }).toList(),
                          "user": widget.pref.get("email"),
                        };

                        (db
                                .collection("products")
                                .doc(product["barcode"])
                                .get())
                            .then((doc) async {
                          final exists = doc.exists;
                          setState(
                            () async {
                              if (exists) {
                                isRepeatBarcode = true;
                              } else {
                                await db
                                    .collection("products")
                                    .doc(product["barcode"])
                                    .set(product);
                                await uploadImagesFirebase(images,
                                    product["images"], product["department"]);
                                await saveImagesLocal(images);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Uploaded Product"),
                                    duration: Duration(milliseconds: 1500),
                                  ),
                                );
                                clearForm();
                              }

                              setState(() {
                                isUploading = false;
                                isDisabled = false;
                              });
                            },
                          );
                        });
                      },
                icon: isUploading
                    ? Container(
                        width: 20,
                        height: 20,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.feed),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(10.0)),
                label: const Text('Submit')),
          ),
        ],
      ),
    );
  }

  Future<bool> checkBarcode(barcode) async {
    var doc = await db.collection("product").doc(barcode).get();
    return doc.exists;
  }
}

class SectionsFilterChips extends StatefulWidget {
  const SectionsFilterChips({
    super.key,
    required this.inputSection,
    required this.sections,
  });

  final List<dynamic> inputSection;
  final Set<String> sections;

  @override
  State<SectionsFilterChips> createState() => _SectionsFilterChipsState();
}

class _SectionsFilterChipsState extends State<SectionsFilterChips> {
  @override
  Widget build(BuildContext context) {
    return FormField(
      builder: (state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              "Sections",
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              state.errorText ?? "",
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
            if (state.errorText != null)
              const SizedBox(
                height: 10.0,
              ),
            Wrap(
              spacing: 5.0,
              children: widget.inputSection.map((chip) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FilterChip(
                    label: Text(chip),
                    selected: widget.sections.contains(chip),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          widget.sections.add(chip);
                          state.didChange(widget.sections);
                        } else {
                          widget.sections.remove(chip);
                          state.didChange(widget.sections);
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            )
          ],
        );
      },
      validator: (value) {
        if (widget.sections.isEmpty) return 'Select sections';
        return null;
      },
    );
  }
}

class ProductPhoto extends StatefulWidget {
  const ProductPhoto({
    super.key,
    required this.images,
  });
  final List<File?> images;

  @override
  State<ProductPhoto> createState() => _ProductPhotoState();
}

class _ProductPhotoState extends State<ProductPhoto> {
  @override
  Widget build(BuildContext context) {
    return FormField(
      builder: (state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text("Photos"),
            const SizedBox(
              height: 5,
            ),
            Text(
              state.errorText ?? "",
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
            if (state.errorText != null)
              const SizedBox(
                height: 10.0,
              ),
            Wrap(
              spacing: 5.0,
              children: <Widget>[
                Row(
                  children: [
                    Wrap(
                      spacing: 10.0,
                      children: [
                        IconButton(
                          onPressed: () async {
                            try {
                              ImagePicker imagePicker = ImagePicker();
                              XFile? imageCamera = await imagePicker.pickImage(
                                  source: ImageSource.camera);
                              if (imageCamera == null) return;
                              final imageTemp = File(imageCamera.path);

                              setState(() {
                                if (widget.images.length < 5) {
                                  if (!widget.images.contains(imageTemp)) {
                                    widget.images.add(imageTemp);
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Only upload 5 photos')));
                                }
                              });
                              return;
                            } on PlatformException catch (e) {
                              print("failed to pick image $e");
                            }
                          },
                          icon: const Icon(Icons.camera_alt),
                        ),
                        IconButton(
                          // gallery button
                          onPressed: () async {
                            try {
                              ImagePicker imagePicker = ImagePicker();
                              List<XFile?> imagelst =
                                  await imagePicker.pickMultiImage();
                              if (imagelst.isEmpty) return;
                              final imageTemps = imagelst.map((image) {
                                if (image != null) return File(image.path);
                              }).toList();
                              setState(() {
                                bool listOverflowBool = false;
                                for (final imageTemp in imageTemps) {
                                  if (widget.images.length < 5) {
                                    if (!widget.images.contains(imageTemp)) {
                                      widget.images.add(imageTemp);
                                    }
                                  } else {
                                    listOverflowBool = true;
                                  }
                                }
                                if (listOverflowBool) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Only upload 5 photos')));
                                }
                              });
                            } on PlatformException catch (e) {
                              print("failed  to pick image $e");
                            }
                          },
                          icon: const Icon(Icons.photo_library_sharp),
                        ),
                      ],
                    ),
                  ],
                ),
                if (widget.images.isNotEmpty)
                  for (final image in widget.images)
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Stack(
                        children: <Widget>[
                          Image.file(
                            image!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.fill,
                          ),
                          Positioned(
                            right: -15,
                            top: -15,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  widget.images.remove(image);
                                });
                              },
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.red.withOpacity(0.75),
                                size: 18,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
              ],
            )
          ],
        );
      },
      validator: (value) {
        if (widget.images.isEmpty) return "Upload Images";
        return null;
      },
    );
  }
}

class SignInPage extends StatelessWidget {
  const SignInPage({super.key, required this.departments_, required this.pref});

  final Map<String, dynamic>? departments_;
  final SharedPreferences pref;

  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> authUser(LoginData data) {
    return FirebaseFirestore.instance
        .collection("Users")
        .doc(data.name)
        .get()
        .then((doc) async {
      if (!doc.exists) return "Incorrect username";
      var docData = doc.data();
      if (docData?["password"] != data.password) return "Incorrect password";
      pref.setString("email", data.name);
      return null;
    });
  }

  Future<String?> recoverPassword(String name) {
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Builder(
      builder: (context) => FlutterLogin(
        title: "Muneshwers",
        theme: LoginTheme(
          primaryColor: Colors.blue.shade700,
          accentColor: Colors.blue.shade100,
        ),
        hideForgotPasswordButton: true,
        onLogin: authUser,
        onRecoverPassword: recoverPassword,
        onSubmitAnimationCompleted: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => UploadScreen(
                departments_: departments_,
                pref: pref,
              ),
            ),
          );
        },
      ),
    ));
  }
}


//TODO
// put in production mode
// upload to app and play store


//COMPLETED 1 
//make the section chips validate
//make the photos upload validate

//COMPLETE 2
//submit the information to firebase
//ensure there are no repeats with barcode
//progess bar
//disabled button while loading
//upload the image
//clear the form on submission
// warn of whitespaces in barcode
//get departments from a get request

//COMPLETE 3
//make sign in page 
// show that the products have been uploaded
// test on android

//COMPLETE 4
// save the photo to local
// allow user to remain signed in after closing
