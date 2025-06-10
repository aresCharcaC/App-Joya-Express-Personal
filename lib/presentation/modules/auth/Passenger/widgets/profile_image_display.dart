import 'dart:io';

import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';

class ProfileImageDisplay extends StatelessWidget {
  final String? localImagePath;
  final String? remoteImageUrl;
  final double size;
  final String? fallbackText;

  const ProfileImageDisplay({
    super.key,
    this.localImagePath,
    this.remoteImageUrl,
    this.size = 100,
    this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    // Priorizar imagen local si existe
    if (localImagePath != null && File(localImagePath!).existsSync()) {
      return Image.file(
        File(localImagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }
    
    // Si no hay imagen local, usar imagen remota
    if (remoteImageUrl != null && remoteImageUrl!.isNotEmpty) {
      return Image.network(
        remoteImageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }
    
    return _buildFallback();
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.grey.withOpacity(0.2),
      child: Center(
        child: Text(
          fallbackText?.substring(0, 1).toUpperCase() ?? '?',
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}