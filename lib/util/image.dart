import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tastybite/services/locator_service.dart';

final FirebaseAuth _auth = locator.get();
final FirebaseFirestore _firestore = locator.get();

class ImagePickerWidget extends StatefulWidget {
  final ValueChanged<String> onValueChanged;
  final String edit;
  const ImagePickerWidget(
      {super.key, required this.onValueChanged, required this.edit});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _image;
  late String _imageUrl =
      'https://thumbs.dreamstime.com/b/image-edit-tool-outline-icon-image-edit-tool-outline-icon-linear-style-sign-mobile-concept-web-design-photo-gallery-135346318.jpg';

  @override
  void initState() {
    super.initState();
    // Check if there is already an image associated with the current user
    _checkUserImage();
  }

  Future<void> _checkUserImage() async {
    try {
      // Get the current user
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Retrieve the user document from Firestore
        final DocumentSnapshot userDoc =
            await _firestore.collection('Users').doc(currentUser.uid).get();
        // Check if the user document contains an image URL
        if (userDoc.exists && userDoc['image'] != null) {
          setState(() {
            _imageUrl = userDoc['image'];
          });
        }
      }
    } catch (e) {
      print('Error checking user image: $e');
    }
  }

  Future getImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imagePermanent = await (saveFilePermanently(image.path));

      setState(() {
        _image = imagePermanent;
      });

      // Upload image to Firebase Storage
      final imageUrl = await uploadImageToFirebase(_image!);

      // Get current user
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Update Firestore document with image URL
        await _firestore.collection('Users').doc(currentUser.uid).set(
          {
            'image': imageUrl,
          },
          SetOptions(merge: true), // Merge with existing document
        );
      }

      widget.onValueChanged(imageUrl);
      _imageUrl = imageUrl;
      setState(() {
        _imageUrl = imageUrl;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  String getPhotoURL() {
    return _imageUrl;
  }

  Future<File> saveFilePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');

    return File(imagePath).copy(image.path);
  }

  Future<String> uploadImageToFirebase(File image) async {
    try {
      final fileName = basename(image.path);
      final destination = 'images/$fileName';

      final ref = firebase_storage.FirebaseStorage.instance.ref(destination);
      final uploadTask = ref.putFile(image);

      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Failed to upload image: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(
                height: 0,
              ),
              Image.network(
                _imageUrl,
                width: 230,
                height: 210,
                fit: BoxFit.cover,
              ),
              const SizedBox(
                height: 20,
              ),
              customButton(
                title: 'Escolher da galeria',
                icon: Icons.image_outlined,
                onClick: () => getImage(ImageSource.gallery),
              ),
              const SizedBox(
                height: 5,
              ),
              customButton(
                title: 'Tirar uma foto',
                icon: Icons.camera_alt,
                onClick: () => getImage(ImageSource.camera),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget customButton(
    {required String title,
    required IconData icon,
    required VoidCallback onClick}) {
  return SizedBox(
    width: 220,
    child: ElevatedButton(
      onPressed: onClick,
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 5),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    ),
  );
}
