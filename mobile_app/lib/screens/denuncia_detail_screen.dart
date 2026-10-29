import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/api_service.dart';

class DenunciaDetailScreen extends StatefulWidget {
  final Denuncia denuncia;

  const DenunciaDetailScreen({super.key, required this.denuncia});

  @override
  State<DenunciaDetailScreen> createState() => _DenunciaDetailScreenState();
}

class _DenunciaDetailScreenState extends State<DenunciaDetailScreen> {
  late Denuncia _denuncia;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _denuncia = widget.denuncia;
  }

  Future<void> _atenderDenuncia() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Atención'),
        content: Text(
          '¿Desea marcar como atendida la denuncia #${_denuncia.id} por serenazgo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.check),
            label: const Text('Atender'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final updated = await ApiService.atenderDenuncia(_denuncia.id!);
      setState(() {
        _denuncia = updated;
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Denuncia marcada como atendida exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Denuncia #${_denuncia.id ?? "-"}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _denuncia),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta de Estado
            Card(
              color: _denuncia.isAtendida
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _denuncia.isAtendida ? Colors.green : Colors.orange,
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      _denuncia.isAtendida
                          ? Icons.check_circle
                          : Icons.pending_actions,
                      size: 36,
                      color: _denuncia.isAtendida
                          ? Colors.green.shade700
                          : Colors.orange.shade800,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ESTADO DE LA DENUNCIA',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _denuncia.isAtendida ? 'ATENDIDA (0)' : 'PENDIENTE (1)',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _denuncia.isAtendida
                                ? Colors.green.shade800
                                : Colors.orange.shade900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tarjeta con información detallada
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.badge_outlined,
                      label: 'DNI del Ciudadano',
                      value: _denuncia.dni,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.category_outlined,
                      label: 'Tipo de Hecho',
                      value: _denuncia.tipo,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Fecha y Hora',
                      value: _denuncia.fecha,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Dirección del Incidente',
                      value: _denuncia.direccion,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.description_outlined,
                      label: 'Descripción de los Hechos',
                      value: _denuncia.descripcion,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botón de acción: Atender denuncia por serenazgo
            if (_denuncia.isPendiente)
              FilledButton.icon(
                onPressed: _isLoading ? null : _atenderDenuncia,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.shield_outlined),
                label: Text(
                  _isLoading ? 'Procesando...' : 'Atender Denuncia (Serenazgo)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Esta denuncia ya fue atendida por el Serenazgo.',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueGrey, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

