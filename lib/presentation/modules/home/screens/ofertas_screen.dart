import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../viewmodels/ofertas_viewmodel.dart';
import '../widgets/oferta_card.dart';
import '../../../../domain/entities/oferta_viaje_entity.dart';

class OfertasScreen extends StatefulWidget {
  final String rideId;

  const OfertasScreen({
    super.key,
    required this.rideId,
  });

  @override
  State<OfertasScreen> createState() => _OfertasScreenState();
}

class _OfertasScreenState extends State<OfertasScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfertasViewModel>().cargarOfertas(widget.rideId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<OfertasViewModel>().cargarMasOfertas(widget.rideId);
    }
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FiltrosBottomSheet(
        onFiltrosAplicados: (filtros) {
          context.read<OfertasViewModel>().aplicarFiltros(filtros);
          context.read<OfertasViewModel>().cargarOfertas(widget.rideId, refresh: true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofertas Recibidas'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
          ),
        ],
      ),
      body: Consumer<OfertasViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.ofertas.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${viewModel.error}',
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.cargarOfertas(widget.rideId, refresh: true),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (!viewModel.hasOfertas) {
            return const Center(
              child: Text(
                'No hay ofertas disponibles',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.cargarOfertas(widget.rideId, refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.ofertas.length + (viewModel.hasNextPage ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == viewModel.ofertas.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final oferta = viewModel.ofertas[index];
                return OfertaCard(
                  oferta: oferta,
                  isSelected: oferta.ofertaId == viewModel.selectedOfertaId,
                  onTap: () => viewModel.seleccionarOferta(oferta.ofertaId),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _FiltrosBottomSheet extends StatefulWidget {
  final Function(OfertaFilters) onFiltrosAplicados;

  const _FiltrosBottomSheet({
    required this.onFiltrosAplicados,
  });

  @override
  State<_FiltrosBottomSheet> createState() => _FiltrosBottomSheetState();
}

class _FiltrosBottomSheetState extends State<_FiltrosBottomSheet> {
  double? _precioMin;
  double? _precioMax;
  double? _distanciaMax;
  String? _ordenarPor;
  bool _ordenAscendente = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Filtro de precio mínimo
          TextField(
            decoration: const InputDecoration(
              labelText: 'Precio mínimo',
              prefixText: 'S/ ',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _precioMin = double.tryParse(value);
            },
          ),
          const SizedBox(height: 8),
          // Filtro de precio máximo
          TextField(
            decoration: const InputDecoration(
              labelText: 'Precio máximo',
              prefixText: 'S/ ',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _precioMax = double.tryParse(value);
            },
          ),
          const SizedBox(height: 8),
          // Filtro de distancia máxima
          TextField(
            decoration: const InputDecoration(
              labelText: 'Distancia máxima (km)',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _distanciaMax = double.tryParse(value);
            },
          ),
          const SizedBox(height: 16),
          // Ordenamiento
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Ordenar por',
            ),
            value: _ordenarPor,
            items: const [
              DropdownMenuItem(
                value: 'precio',
                child: Text('Precio'),
              ),
              DropdownMenuItem(
                value: 'distancia',
                child: Text('Distancia'),
              ),
              DropdownMenuItem(
                value: 'tiempo',
                child: Text('Tiempo'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _ordenarPor = value;
              });
            },
          ),
          const SizedBox(height: 8),
          // Dirección del ordenamiento
          SwitchListTile(
            title: const Text('Orden ascendente'),
            value: _ordenAscendente,
            onChanged: (value) {
              setState(() {
                _ordenAscendente = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // Botón de aplicar filtros
          ElevatedButton(
            onPressed: () {
              final filtros = OfertaFilters(
                precioMin: _precioMin,
                precioMax: _precioMax,
                distanciaMax: _distanciaMax,
                ordenarPor: _ordenarPor,
                ordenAscendente: _ordenAscendente,
              );
              widget.onFiltrosAplicados(filtros);
              Navigator.pop(context);
            },
            child: const Text('Aplicar filtros'),
          ),
        ],
      ),
    );
  }
} 