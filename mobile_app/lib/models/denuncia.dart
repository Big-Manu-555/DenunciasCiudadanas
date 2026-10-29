class Denuncia {
  final int? id;
  final String dni;
  final String fecha;
  final String tipo;
  final String direccion;
  final String descripcion;
  final int estado;

  Denuncia({
    this.id,
    required this.dni,
    required this.fecha,
    required this.tipo,
    required this.direccion,
    required this.descripcion,
    this.estado = 1,
  });

  bool get isPendiente => estado == 1;
  bool get isAtendida => estado == 0;

  factory Denuncia.fromJson(Map<String, dynamic> json) {
    return Denuncia(
      id: json['id'] as int?,
      dni: json['dni']?.toString() ?? '',
      fecha: json['fecha']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      estado: json['estado'] is int ? json['estado'] as int : int.tryParse(json['estado']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'dni': dni,
      'fecha': fecha,
      'tipo': tipo,
      'direccion': direccion,
      'descripcion': descripcion,
    };
    if (id != null) data['id'] = id;
    data['estado'] = estado;
    return data;
  }

  Denuncia copyWith({
    int? id,
    String? dni,
    String? fecha,
    String? tipo,
    String? direccion,
    String? descripcion,
    int? estado,
  }) {
    return Denuncia(
      id: id ?? this.id,
      dni: dni ?? this.dni,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      direccion: direccion ?? this.direccion,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
    );
  }
}

