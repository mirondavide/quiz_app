import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

// App File model
class AppFile {
  final String name;
  final String? path;
  final Uint8List? bytes;
  final int size;
  final String extension;
  final AppFileType type;
  
  AppFile({
    required this.name,
    this.path,
    this.bytes,
    required this.size,
    required this.extension,
    required this.type,
  });
  
  String get sizeDisplay => FileService()._formatFileSize(size);
  
  bool get isValid => FileService().isValidFile(this);
}

// File types
enum AppFileType {
  pdf,
  document,
  text,
  image,
  unknown,
}

class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();
  
  final ImagePicker _imagePicker = ImagePicker();
  
  // Supported file types
  static const List<String> supportedExtensions = [
    'pdf', 'docx', 'doc', 'txt',
    'jpg', 'jpeg', 'png', 'gif', 'bmp'
  ];
  
  // Pick document files (PDF, DOCX)
  Future<AppFile?> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        return AppFile(
          name: file.name,
          path: file.path,
          bytes: file.bytes,
          size: file.size,
          extension: file.extension ?? '',
          type: _getFileType(file.extension ?? ''),
        );
      }
    } catch (e) {
      debugPrint('Error picking document: $e');
      throw FileServiceException('Failed to pick document: $e');
    }
    return null;
  }
  
  // Pick image from gallery
  Future<AppFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        final file = File(image.path);
        final fileSize = await file.length();
        
        return AppFile(
          name: image.name,
          path: image.path,
          bytes: bytes,
          size: fileSize,
          extension: image.path.split('.').last.toLowerCase(),
          type: AppFileType.image,
        );
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      throw FileServiceException('Failed to pick image from gallery: $e');
    }
    return null;
  }
  
  // Pick image from camera
  Future<AppFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        final file = File(image.path);
        final fileSize = await file.length();
        
        return AppFile(
          name: image.name,
          path: image.path,
          bytes: bytes,
          size: fileSize,
          extension: image.path.split('.').last.toLowerCase(),
          type: AppFileType.image,
        );
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
      throw FileServiceException('Failed to take photo: $e');
    }
    return null;
  }
  
  // Extract text content from file
  Future<String> extractTextContent(AppFile file) async {
    try {
      switch (file.type) {
        case AppFileType.text:
          return await _extractTextFromTextFile(file);
        case AppFileType.pdf:
          return await _extractTextFromPDF(file);
        case AppFileType.document:
          return await _extractTextFromDocument(file);
        case AppFileType.image:
          return await _extractTextFromImage(file);
        default:
          throw FileServiceException('Unsupported file type: ${file.extension}');
      }
    } catch (e) {
      debugPrint('Error extracting text content: $e');
      throw FileServiceException('Failed to extract text content: $e');
    }
  }
  
  // Extract text from text file
  Future<String> _extractTextFromTextFile(AppFile file) async {
    if (file.bytes != null) {
      return String.fromCharCodes(file.bytes!);
    } else if (file.path != null) {
      final textFile = File(file.path!);
      return await textFile.readAsString();
    } else {
      throw FileServiceException('No file data available');
    }
  }
  
  // Extract text from PDF (basic implementation)
  Future<String> _extractTextFromPDF(AppFile file) async {
    // Note: For a production app, you would use a proper PDF text extraction library
    // like pdf_text or similar. For MVP, we'll provide a placeholder.
    return "PDF content extraction requires additional implementation. "
           "File: ${file.name} (${_formatFileSize(file.size)}).\n\n"
           "Please implement PDF text extraction using a library like 'pdf_text' "
           "or send the file to your backend for processing.";
  }
  
  // Extract text from document (DOCX/DOC)
  Future<String> _extractTextFromDocument(AppFile file) async {
    // Note: For a production app, you would use a proper document processing library
    // or send to backend for processing. For MVP, we'll provide a placeholder.
    return "Document content extraction requires additional implementation. "
           "File: ${file.name} (${_formatFileSize(file.size)}).\n\n"
           "Please implement document text extraction using a library "
           "or send the file to your backend for processing.";
  }
  
  // Extract text from image using OCR
  Future<String> _extractTextFromImage(AppFile file) async {
    // Note: For a production app, you would use an OCR service like Google ML Kit
    // or similar. For MVP, we'll provide a placeholder.
    return "Image text extraction (OCR) requires additional implementation. "
           "Image: ${file.name} (${_formatFileSize(file.size)}).\n\n"
           "Please implement OCR using Google ML Kit or send the image "
           "to your backend for text extraction.";
  }
  
  // Validate file
  bool isValidFile(AppFile file) {
    // Check file size (max 10MB for MVP)
    const maxSizeBytes = 10 * 1024 * 1024;
    if (file.size > maxSizeBytes) {
      return false;
    }
    
    // Check extension
    return supportedExtensions.contains(file.extension.toLowerCase());
  }
  
  // Get file type from extension
  AppFileType _getFileType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return AppFileType.pdf;
      case 'docx':
      case 'doc':
        return AppFileType.document;
      case 'txt':
        return AppFileType.text;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        return AppFileType.image;
      default:
        return AppFileType.unknown;
    }
  }
  
  // Format file size for display
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class FileServiceException implements Exception {
  final String message;

  FileServiceException(this.message);

  @override
  String toString() {
    return 'FileServiceException: $message';
  }
}
