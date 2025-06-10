import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';

/**
 * DriverRequestList
 * -----------------
 * Widget que muestra la lista de solicitudes de pasajeros.
 * Incluye estado vacío, manejo de errores y pull-to-refresh.
 */
class DriverRequestList extends StatelessWidget {
  final List<dynamic>? solicitudes;
  final Future<void> Function()? onRefresh;
  final Function(dynamic)? onRequestTap;

  const DriverRequestList({
    super.key,
    this.solicitudes,
    this.onRefresh,
    this.onRequestTap,
  });

  @override
  Widget build(BuildContext context) {
    // Estado vacío
    if (solicitudes == null || solicitudes!.isEmpty) {
      return _buildEmptyState();
    }

    // Lista con RefreshIndicator
    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: solicitudes!.length,
        itemBuilder: (context, index) {
          final request = solicitudes![index];
          return _RequestCard(
            request: request,
            onTap: () => onRequestTap?.call(request),
          );
        },
      ),
    );
  }

  /// Construye el estado vacío cuando no hay solicitudes
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay solicitudes disponibles',
            style: AppTextStyles.poppinsHeading3.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las nuevas solicitudes aparecerán aquí.',
            style: AppTextStyles.interBodySmall.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta individual para cada solicitud de pasajero
class _RequestCard extends StatelessWidget {
  final dynamic request;
  final VoidCallback? onTap;

  const _RequestCard({
    required this.request,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foto = request.foto ?? '';
    final nombre = request.nombre ?? 'Sin nombre';
    final direccion = request.direccion ?? 'Dirección no especificada';
    final metodos = request.metodos ?? <String>[];
    final rating = request.rating ?? 0.0;
    final votos = request.votos ?? 0;
    final precio = request.precio ?? 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: foto.isNotEmpty
            ? CircleAvatar(
                backgroundImage: NetworkImage(foto),
                onBackgroundImageError: (_, __) {},
              )
            : CircleAvatar(
                child: Icon(Icons.person),
                backgroundColor: Colors.grey.shade300,
              ),
        title: Text(
          nombre,
          style: AppTextStyles.poppinsHeading3,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'S/ ${precio.toStringAsFixed(2)}',
              style: AppTextStyles.poppinsHeading2.copyWith(
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              direccion,
              style: AppTextStyles.interBodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            if (metodos.isNotEmpty)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: metodos.map<Widget>((m) => Chip(
                  label: Text(
                    m,
                    style: AppTextStyles.interCaption.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                  backgroundColor: m == 'Efectivo'
                      ? Colors.green
                      : m == 'Yape'
                          ? Colors.purple
                          : m == 'Plin'
                              ? Colors.blue
                              : Colors.orange,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 18),
            Text(
              '${rating.toStringAsFixed(1)} ($votos)',
              style: AppTextStyles.interCaption,
            ),
          ],
        ),
      ),
    );
  }
}