import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/denuncia.dart';
import '../services/api_service.dart';

class DenunciaFormScreen extends StatefulWidget {
  const DenunciaFormScreen({super.key});

  @override
  State<DenunciaFormScreen> createState() => _DenunciaFormScreenState();
}

class _DenunciaFormScreenState extends State<DenunciaFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _dniController = TextEditingController();
  final _direccionController = TextEditingController();
  final _descripcionController = TextEditingController();

  final List<String> _tipos = [
    'ROBO',
    'ASALTO',
    'VANDALISMO',
    'HURTO',
    'EXTORSION',
    'ACCIDENTE',
    'OTRO',
  ];

  String _tipoSeleccionado = 'ROBO';
  DateTime _fechaSeleccionada = DateTime.now();
  bool _isSaving = false;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  void dispose() {
    _dniController.dispose();
    _direccionController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFechaHora() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fechaSeleccionada),
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      _fechaSeleccionada = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
        DateTime.now().second,
      );
    });
  }

  Future<void> _guardarDenuncia() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final nuevaDenuncia = Denuncia(
      dni: _dniController.text.trim(),
      fecha: _dateFormat.format(_fechaSeleccionada),
      tipo: _tipoSeleccionado,
      direccion: _direccionController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      estado: 1, // El estado inicial siempre es 1
    );

    try {
      final registrada = await ApiService.registrarDenuncia(nuevaDenuncia);

      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Denuncia #${registrada.id} registrada con éxito.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Denuncia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Datos de la Inseguridad Ciudadana',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // DNI
              TextFormField(
                controller: _dniController,
                keyboardType: TextInputType.number,
                maxLength: 8,
                decoration: const InputDecoration(
                  labelText: 'DNI del Ciudadano *',
                  hintText: 'Ej. 71829304',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                  counterText: "",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El DNI es obligatorio';
                  }
                  if (!RegExp(r'^\d{8}$').hasMatch(value.trim())) {
                    return 'El DNI debe tener exactamente 8 dígitos numéricos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tipo
              DropdownButtonFormField<String>(
                initialValue: _tipoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Hecho *',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _tipos.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _tipoSeleccionado = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Fecha y Hora
              InkWell(
                onTap: _seleccionarFechaHora,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha y Hora del Incidente *',
                    prefixIcon: Icon(Icons.calendar_today),
                    suffixIcon: Icon(Icons.edit_calendar),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _dateFormat.format(_fechaSeleccionada),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dirección
              TextFormField(
                controller: _direccionController,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Dirección del Incidente *',
                  hintText: 'Ej. Av. Bolognesi 450, Chiclayo',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La dirección es obligatoria';
                  }
                  if (value.trim().length > 200) {
                    return 'La dirección no debe exceder los 200 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descripcionController,
                maxLength: 255,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción de los Hechos *',
                  hintText: 'Detalle lo sucedido para el personal de Serenazgo...',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La descripción es obligatoria';
                  }
                  if (value.trim().length > 255) {
                    return 'La descripción no debe exceder los 255 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botón Guardar
              FilledButton.icon(
                onPressed: _isSaving ? null : _guardarDenuncia,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isSaving ? 'Registrando...' : 'Registrar Denuncia',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
