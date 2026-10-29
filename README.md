# Denuncias Ciudadanas

Sistema integral de denuncias de inseguridad ciudadana ante el serenazgo municipal, compuesto por:
1. **Backend (API REST):** Desarrollado con Spring Boot 4 / Java 21, Spring Data JPA y MySQL.
2. **Mobile App:** Desarrollada con Flutter (Material 3), compatible con Android 15 (API 35).

---

## 🚀 Arquitectura del Proyecto

```text
DenunciasCiudadanas/
├── backend/                  # Proyecto Spring Boot (API REST)
│   ├── src/main/java/com/pacherres/denunciaservice/
│   │   ├── controller/      # Endpoints REST (DenunciaController)
│   │   ├── service/         # Lógica de negocio (DenunciaService)
│   │   ├── repository/      # Acceso a datos JPA (DenunciaRepository)
│   │   ├── entity/          # Entidad Denuncia
│   │   └── exception/       # Manejo global de excepciones
│   ├── src/test/            # 12 pruebas automatizadas (Integration & Unit)
│   └── pom.xml
└── mobile_app/               # Aplicación móvil Flutter
    ├── lib/
    │   ├── models/          # Modelo de datos (Denuncia)
    │   ├── services/        # Cliente HTTP (ApiService)
    │   ├── screens/         # Pantallas (Lista paginada, Registro, Detalle)
    │   └── main.dart        # Punto de entrada y tema institucional
    └── pubspec.yaml
```

---

## 📡 Endpoints de la API REST

Base URL: `http://localhost:8081/denuncias/` (Local) o `http://10.0.2.2:8081/denuncias/` (Emulador Android).

| Método | Endpoint | Descripción |
| :--- | :--- | :--- |
| **POST** | `/denuncias/` | Registra una denuncia (el estado inicia en 1 = pendiente). |
| **GET** | `/denuncias/?offset=0&limit=5` | Obtiene el listado de denuncias con paginación por offset. |
| **GET** | `/denuncias/{id}` | Obtiene el detalle de una denuncia por su ID. |
| **GET** | `/denuncias/ciudadano/{dni}` | Obtiene todas las denuncias realizadas por un ciudadano (DNI). |
| **PUT** | `/denuncias/{id}` | Marca la denuncia como atendida por serenazgo (cambia estado de 1 a 0). |

---

## 📱 Funcionalidades de la App Móvil

- **Lista de denuncias paginada:** Muestra las denuncias en tarjetas con indicador de estado (Pendiente / Atendida) y botón para cargar las siguientes 5.
- **Búsqueda por DNI:** Permite filtrar rápidamente todas las denuncias de un ciudadano específico.
- **Formulario de Registro:** Validación completa de campos (DNI de 8 dígitos, tipo de denuncia, dirección y descripción).
- **Pantalla de Detalle y Atención:** Información completa del reporte y botón para marcar como atendida.
- **Configuración de IP/URL:** Diálogo para cambiar la URL del backend según el entorno (Emulador `10.0.2.2`, Celular físico en red local o Render en la nube).

---

## 🛠️ Cómo Ejecutar el Proyecto

### 1. Base de datos
- Iniciar MySQL en XAMPP (puerto `3306`).
- Base de datos: `denuncias_db`.

### 2. Backend (Spring Boot)
```bash
cd backend
./mvnw spring-boot:run
```
El servidor arrancará en el puerto `8081`.

### 3. Aplicación Móvil (Flutter)
```bash
cd mobile_app
flutter run
```
Para ejecutar en un emulador específico:
```bash
flutter run -d emulator-5554
```

