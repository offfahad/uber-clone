import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  Future<XFile?> pickCropImage({
    required CropAspectRatio cropAspectRatio,
    required ImageSource imageSource,
  }) async {
    XFile? pickImage = await ImagePicker().pickImage(source: imageSource);
    if (pickImage == null) return null;
    CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickImage.path,
        aspectRatio: cropAspectRatio,
        compressQuality: 90,
        compressFormat: ImageCompressFormat.jpg);
    if (croppedFile == null) return null;
    return XFile(croppedFile.path);
  }
}
