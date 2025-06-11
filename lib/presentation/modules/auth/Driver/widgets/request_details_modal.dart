// lib/presentation/modules/auth/Driver/widgets/request_details_modal.dart
import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';

class RequestDetailsModal extends StatefulWidget {
  final dynamic request;
  final Function(String rideId, double tarifa, int tiempo, String? mensaje)?
  onMakeOffer;
  final Function(String rideId)? onReject;

  const RequestDetailsModal({
    super.key,
    required this.request,
    this.onMakeOffer,
    this.onReject,
  });

  @override
  State<RequestDetailsModal> createState() => _RequestDetailsModalState();
}

class _RequestDetailsModalState extends State<RequestDetailsModal> {
  final TextEditingController _tarifaController = TextEditingController();
  final TextEditingController _tiempoController = TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Valores iniciales sugeridos
    _tarifaController.text = widget.request.precio?.toString() ?? '8.0';
    _tiempoController.text =
        widget.request.tiempoEstimadoMinutos?.toString() ?? '10';
  }

  @override
  void dispose() {
    _tarifaController.dispose();
    _tiempoController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfo(),
                  const SizedBox(height: 20),
                  _buildLocationInfo(),
                  const SizedBox(height: 20),
                  _buildTripDetails(),
                  const SizedBox(height: 24),
                  _buildOfferSection(),
                ],
              ),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.close, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Detalles de la solicitud',
              style: AppTextStyles.poppinsHeading2.copyWith(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
            ),
            child:
                widget.request.foto?.isNotEmpty == true
                    ? ClipOval(
                      child: Image.network(
                        widget.request.foto!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildAvatarFallback(),
                      ),
                    )
                    : _buildAvatarFallback(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.request.nombre ?? 'Sin nombre',
                  style: AppTextStyles.poppinsHeading3.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.request.rating?.toStringAsFixed(1) ?? '0.0'} (${widget.request.votos ?? 0} votos)',
                      style: AppTextStyles.interBodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildPaymentMethods(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Center(
      child: Text(
        widget.request.nombre?.isNotEmpty == true
            ? widget.request.nombre![0].toUpperCase()
            : '?',
        style: AppTextStyles.poppinsButton.copyWith(
          fontSize: 20,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final metodos = widget.request.metodos as List<String>? ?? [];

    return Wrap(
      spacing: 6,
      children:
          metodos.map((metodo) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                metodo,
                style: AppTextStyles.interBodySmall.copyWith(
                  color: AppColors.primary,
                  fontSize: 11,
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildLocationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ubicaciones',
          style: AppTextStyles.poppinsHeading3.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),

        // Origen
        _buildLocationItem(
          icon: Icons.radio_button_checked,
          iconColor: AppColors.success,
          title: 'Punto de recogida',
          address: widget.request.direccion ?? 'Dirección no especificada',
          distance:
              widget.request.distanciaKm != null
                  ? '${widget.request.distanciaKm!.toStringAsFixed(1)} km'
                  : null,
        ),

        const SizedBox(height: 12),

        // Destino
        _buildLocationItem(
          icon: Icons.location_on,
          iconColor: AppColors.primary,
          title: 'Destino',
          address: widget.request.destinoDireccion ?? 'Destino no especificado',
        ),
      ],
    );
  }

  Widget _buildLocationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String address,
    String? distance,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.interBodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  address,
                  style: AppTextStyles.interBodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (distance != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                distance,
                style: AppTextStyles.interBodySmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTripDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles del viaje',
            style: AppTextStyles.poppinsHeading3.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.attach_money,
                  label: 'Tarifa máxima',
                  value:
                      'S/ ${widget.request.precio?.toStringAsFixed(1) ?? '0.0'}',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.access_time,
                  label: 'Tiempo estimado',
                  value: '${widget.request.tiempoEstimadoMinutos ?? 0} min',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildDetailItem(
            icon: Icons.schedule,
            label: 'Solicitado hace',
            value: _getTimeAgo(widget.request.fechaSolicitud),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.interBodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.poppinsSubtitle.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOfferSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hacer oferta',
            style: AppTextStyles.poppinsHeading3.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),

          // Tarifa
          Row(
            children: [
              Expanded(
                child: _buildOfferField(
                  controller: _tarifaController,
                  label: 'Tu tarifa (S/)',
                  hint: '8.0',
                  prefix: 'S/ ',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildOfferField(
                  controller: _tiempoController,
                  label: 'Tiempo llegada (min)',
                  hint: '10',
                  suffix: ' min',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Mensaje opcional
          _buildOfferField(
            controller: _mensajeController,
            label: 'Mensaje (opcional)',
            hint: 'Ej: Estoy muy cerca, puedo llegar rápido',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildOfferField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? prefix,
    String? suffix,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.poppinsSubtitle.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            suffixText: suffix,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.greyLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.greyLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Botón Rechazar
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _handleReject,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Rechazar',
                  style: AppTextStyles.poppinsButton.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Botón Hacer Oferta
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleMakeOffer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          'Hacer Oferta',
                          style: AppTextStyles.poppinsButton,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleReject() async {
    setState(() => _isLoading = true);

    try {
      final rideId = widget.request.rideId ?? '';
      final success = await widget.onReject?.call(rideId) ?? true;

      if (success) {
        Navigator.pop(context);
        _showSnackBar('Solicitud rechazada', isError: false);
      } else {
        _showSnackBar('Error al rechazar solicitud', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleMakeOffer() async {
    // Validar campos
    final tarifaText = _tarifaController.text.trim();
    final tiempoText = _tiempoController.text.trim();

    if (tarifaText.isEmpty || tiempoText.isEmpty) {
      _showSnackBar('Por favor completa tarifa y tiempo', isError: true);
      return;
    }

    final tarifa = double.tryParse(tarifaText);
    final tiempo = int.tryParse(tiempoText);

    if (tarifa == null || tiempo == null) {
      _showSnackBar('Por favor ingresa valores válidos', isError: true);
      return;
    }

    if (tarifa <= 0 || tiempo <= 0) {
      _showSnackBar('Los valores deben ser mayores a 0', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final rideId = widget.request.rideId ?? '';
      final mensaje =
          _mensajeController.text.trim().isEmpty
              ? null
              : _mensajeController.text.trim();

      final success =
          await widget.onMakeOffer?.call(rideId, tarifa, tiempo, mensaje) ??
          true;

      if (success) {
        Navigator.pop(context);
        _showSnackBar('Oferta enviada exitosamente', isError: false);
      } else {
        _showSnackBar('Error al enviar oferta', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _getTimeAgo(DateTime? fecha) {
    if (fecha == null) return 'Hace poco';

    final now = DateTime.now();
    final difference = now.difference(fecha);

    if (difference.inMinutes < 1) {
      return 'Ahora mismo';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h';
    } else {
      return '${difference.inDays} días';
    }
  }
}
