# Inventario de Apartamentos

Aplicación Flutter para registrar el estado de los elementos de un apartamento sin conexión y exportar los resultados en PDF.

## Requisitos

- Flutter 3.10 o superior.
- Dart 3.0 o superior.

## Configuración inicial

1. Instala las dependencias de Flutter:

   ```bash
   flutter pub get
   ```

2. Ejecuta la aplicación en un dispositivo o emulador:

   ```bash
   flutter run
   ```

## Características principales

- Plantilla de inventario basada en la lista de elementos proporcionada para puertas, baños, habitaciones y áreas comunes.
- Posibilidad de crear múltiples apartamentos, editar su información y eliminar registros.
- Registro del estado de cada ítem (Excelente, Bueno, Requiere mantenimiento, Dañado, No existe) y notas u observaciones adicionales.
- Almacenamiento local en un archivo JSON dentro del dispositivo, sin conexión a APIs externas.
- Generación de reportes en PDF con resumen del apartamento y tabla por sección.

## Exportar a PDF

Dentro del detalle de cada apartamento se encuentra un botón en la barra superior para generar el PDF. El archivo se guarda en el directorio de documentos de la aplicación e incluye la fecha de generación en el nombre.

## Estructura del proyecto

- `lib/data`: Definiciones de ítems y secciones predeterminadas.
- `lib/models`: Modelos de dominio y serialización.
- `lib/providers`: Lógica de estado y persistencia local.
- `lib/services`: Servicios auxiliares como la exportación a PDF.
- `lib/pages` y `lib/widgets`: Interfaces de usuario y componentes reutilizables.
