import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/api_service.dart';
import 'denuncia_detail_screen.dart';
import 'denuncia_form_screen.dart';

class DenunciasListScreen extends StatefulWidget {
  const DenunciasListScreen({super.key});

  @override
  State<DenunciasListScreen> createState() => _DenunciasListScreenState();
}

class _DenunciasListScreenState extends State<DenunciasListScreen> {
  final List<Denuncia> _denuncias = [];
  final TextEditingController _dniSearchController = TextEditingController();

  int _offset = 0;
  final int _limit = 5;

  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isSearchingByDni = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarDenunciasIniciales();
  }

  @override
  void dispose() {
    _dniSearchController.dispose();
    super.dispose();
  }

  /// Carga inicial de las primeras 5 denuncias (offset=0, limit=5)
  Future<void> _cargarDenunciasIniciales() async {
    setState(() {
      _isLoadingInitial = true;
      _errorMessage = null;
      _isSearchingByDni = false;
      _offset = 0;
      _hasMore = true;
    });

    try {
      final lista = await ApiService.getDenunciasPaginadas(
        offset: 0,
        limit: _limit,
      );

      setState(() {
        _denuncias.clear();
        _denuncias.addAll(lista);
        _offset = lista.length;
        _hasMore = lista.length == _limit;
        _isLoadingInitial = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingInitial = false;
      });
    }
  }

  /// Cargar los siguientes 5 registros
  Future<void> _cargarSiguientesCinco() async {
    if (_isLoadingMore || !_hasMore || _isSearchingByDni) return;

    setState(() => _isLoadingMore = true);

    try {
      final siguientes = await ApiService.getDenunciasPaginadas(
        offset: _offset,
        limit: _limit,
      );

      setState(() {
        _denuncias.addAll(siguientes);
        _offset += siguientes.length;
        if (siguientes.length < _limit) {
          _hasMore = false;
        }
        _isLoadingMore = false;
      });

      if (siguientes.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay más denuncias por cargar.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoadingMore = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar siguientes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Buscar denuncias de un ciudadano por DNI
  Future<void> _buscarPorDni() async {
    final dni = _dniSearchController.text.trim();
    if (dni.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un DNI para buscar')),
      );
      return;
    }

    if (!RegExp(r'^\d{8}$').hasMatch(dni)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El DNI debe tener 8 dígitos numéricos')),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoadingInitial = true;
      _errorMessage = null;
      _isSearchingByDni = true;
    });

    try {
      final resultados = await ApiService.getDenunciasByDni(dni);

      setState(() {
        _denuncias.clear();
        _denuncias.addAll(resultados);
        _hasMore = false;
        _isLoadingInitial = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingInitial = false;
      });
    }
  }

  void _limpiarBusqueda() {
    _dniSearchController.clear();
    FocusScope.of(context).unfocus();
    _cargarDenunciasIniciales();
  }

  /// Diálogo para cambiar la URL base de la API
  void _mostrarConfiguracionUrl() {
    final controller = TextEditingController(text: ApiService.baseUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Configurar Servidor API'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dirección de la API REST:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'http://10.0.2.2:8081/denuncias',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '• Emulador Android: http://10.0.2.2:8081/denuncias\n'
              '• Celular físico: http://[TU_IP_PC]:8081/denuncias\n'
              '• Render.com: https://[app].onrender.com/denuncias',
              style: TextStyle(fontSize: 11, color: Colors.blueGrey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                ApiService.baseUrl = controller.text.trim();
              });
              Navigator.pop(ctx);
              _cargarDenunciasIniciales();
            },
            child: const Text('Guardar y Recargar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serenazgo - Denuncias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configurar URL de la API',
            onPressed: _mostrarConfiguracionUrl,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar lista',
            onPressed: _cargarDenunciasIniciales,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda por DNI
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.blueGrey.shade50,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dniSearchController,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    decoration: InputDecoration(
                      hintText: 'Buscar por DNI del ciudadano...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _dniSearchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _limpiarBusqueda,
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (_) => _buscarPorDni(),
                    onChanged: (text) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _buscarPorDni,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),

          // Banner de aviso si está en modo búsqueda
          if (_isSearchingByDni)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: Colors.blue.shade100,
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filtrado por DNI: ${_dniSearchController.text.trim()} (${_denuncias.length} encontrados)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _limpiarBusqueda,
                    child: const Text('Quitar filtro'),
                  ),
                ],
              ),
            ),

          // Contenido principal: Lista de denuncias
          Expanded(
            child: _buildContenido(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => const DenunciaFormScreen(),
            ),
          );
          if (res == true) {
            _cargarDenunciasIniciales();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Denuncia'),
      ),
    );
  }

  Widget _buildContenido() {
    if (_isLoadingInitial) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando denuncias...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 50, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                'Error al consultar la API',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _cargarDenunciasIniciales,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_denuncias.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              _isSearchingByDni
                  ? 'No se encontraron denuncias para este DNI'
                  : 'No hay denuncias registradas',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            if (_isSearchingByDni) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _limpiarBusqueda,
                child: const Text('Ver todas las denuncias'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarDenunciasIniciales,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 80),
        itemCount: _denuncias.length + (_isSearchingByDni ? 0 : 1),
        itemBuilder: (context, index) {
          // Último elemento: botón para cargar los siguientes 5
          if (!_isSearchingByDni && index == _denuncias.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: _isLoadingMore
                    ? const CircularProgressIndicator()
                    : _hasMore
                        ? ElevatedButton.icon(
                            onPressed: _cargarSiguientesCinco,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: const Icon(Icons.expand_more),
                            label: const Text(
                              'Cargar los 5 siguientes',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )
                        : const Text(
                            'Fin del listado de denuncias',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
              ),
            );
          }

          final denuncia = _denuncias[index];
          return _buildDenunciaCard(denuncia);
        },
      ),
    );
  }

  Widget _buildDenunciaCard(Denuncia denuncia) {
    final bool atendida = denuncia.isAtendida;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: atendida ? Colors.green.shade300 : Colors.orange.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => DenunciaDetailScreen(denuncia: denuncia),
            ),
          );
          if (res is Denuncia) {
            // Actualizar el elemento en la lista si fue atendido
            final idx = _denuncias.indexWhere((d) => d.id == res.id);
            if (idx != -1) {
              setState(() {
                _denuncias[idx] = res;
              });
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado: ID, Tipo y Badge de Estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${denuncia.id ?? "-"}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        denuncia.tipo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: atendida
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          atendida ? Icons.check_circle : Icons.schedule,
                          size: 14,
                          color: atendida
                              ? Colors.green.shade800
                              : Colors.orange.shade900,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          atendida ? 'ATENDIDA (0)' : 'PENDIENTE (1)',
                          style: TextStyle(
                            color: atendida
                                ? Colors.green.shade800
                                : Colors.orange.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Dirección
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.blueGrey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      denuncia.direccion,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Descripción
              Text(
                denuncia.descripcion,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Pie: DNI y Fecha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'DNI: ${denuncia.dni}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    denuncia.fecha,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

