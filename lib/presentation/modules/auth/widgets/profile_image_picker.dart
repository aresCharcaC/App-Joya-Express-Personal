import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joya_express/core/constants/app_colors.dart';

// Widget que permite al usuario seleccionar una imagen de perfil
class ProfileImagePicker extends StatefulWidget {
  final Function(File?)? onImageSelected; // Callback que se ejecuta cuando se selecciona o elimina una imagen
  final double size;// Tamaño del avatar

  const ProfileImagePicker({
    super.key,
    this.onImageSelected,
    this.size = 120,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _selectedImage;// Imagen seleccionada
  final ImagePicker _picker = ImagePicker();// Instancia del selector de imágenes
 
 // Muestra el menú de opciones para seleccionar o eliminar imagen
  Future<void> _pickImage() async {
    try {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: [
                // Opción: Cámara
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Cámara'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImage(ImageSource.camera);
                  },
                ),
                // Opción: Galería
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galería'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImage(ImageSource.gallery);
                  },
                ),
                 // Opción: Eliminar imagen (si hay una seleccionada)
                if (_selectedImage != null)
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Eliminar foto'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _removeImage();
                    },
                  ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al seleccionar imagen'),
        ),
      );
    }
  }
  // Obtiene la imagen desde la cámara o galería
  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,// Comprime la imagen para ahorrar espacio
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        widget.onImageSelected?.call(_selectedImage);
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al seleccionar imagen'),
        ),
      );
    }
  }
 // Elimina la imagen seleccionada
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    widget.onImageSelected?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,// Abre menú al tocar el avatar
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.greyLight,
          border: Border.all(
            color: AppColors.border,
            width: 2,
          ),
        ),
        child: _selectedImage != null
            ? Stack(
                children: [
                  // Estado :Imagen seleccionada
                  ClipOval(
                    child: Image.file(
                      _selectedImage!,//Se muestra la imagen seleccionada
                      width: widget.size,
                      height: widget.size,
                      fit: BoxFit.cover,//Imagen ajustada al contenedor
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        border: Border.all(
                          color: AppColors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon( // Icono de edición
                        Icons.edit,
                        color: AppColors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  // Default avatar background
                  Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.greyLight,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.grey,
                    ),
                  ),
                  // Plus icon
                  Positioned(// Estado: No hay imagen seleccionada
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.black,
                        border: Border.all(
                          color: AppColors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}