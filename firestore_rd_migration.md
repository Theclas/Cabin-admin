# Migración Firestore → República Dominicana

Copia y pega cada bloque JSON en Firebase Console > Firestore > el documento correspondiente.

---

## 1. Documento: `legal/terms`

**Ruta:** `legal` → documento `terms`

```json
{
  "version": "2.0",
  "updatedAt": "2026-05-21",
  "content": "# Términos y Condiciones de Uso\n\n**Versión 2.0 — Vigente desde el 21 de mayo de 2026**\n\n## 1. Aceptación de los términos\n\nAl descargar, instalar o utilizar la aplicación **Cabin** (en adelante, \"la App\"), usted acepta quedar vinculado por los presentes Términos y Condiciones. Si no está de acuerdo con alguno de estos términos, le rogamos que no utilice la App.\n\n## 2. Descripción del servicio\n\nCabin es una plataforma digital que permite a los usuarios localizar, visualizar y contactar establecimientos de hospedaje temporal (moteles, cabañas, villas, hoteles y similares) ubicados en la **República Dominicana**. La App no actúa como intermediario de reservas ni procesa pagos.\n\n## 3. Uso permitido\n\nUsted se compromete a:\n\n- Utilizar la App únicamente para fines legales y personales.\n- No publicar, transmitir ni distribuir contenido falso, difamatorio, obsceno o ilegal.\n- No intentar acceder sin autorización a sistemas, cuentas o datos de terceros.\n- No usar la App para actividades que violen las leyes de la República Dominicana.\n\n## 4. Registro de cuenta\n\nPara acceder a ciertas funciones deberá crear una cuenta proporcionando información verídica. Usted es responsable de mantener la confidencialidad de sus credenciales y de todas las actividades realizadas bajo su cuenta.\n\n## 5. Contenido de terceros\n\nLa información de los establecimientos (nombre, ubicación, fotos, precios) es proporcionada por los propietarios o administradores de dichos negocios. Cabin no garantiza la exactitud, veracidad o actualización de dicha información y no se hace responsable de las condiciones reales de los establecimientos.\n\n## 6. Propiedad intelectual\n\nTodos los derechos sobre la App, su diseño, logotipos, código fuente y contenido propio pertenecen a Cabin. Queda prohibida su reproducción total o parcial sin autorización expresa por escrito.\n\n## 7. Limitación de responsabilidad\n\nCabin no será responsable por daños directos, indirectos, incidentales o consecuentes derivados del uso o imposibilidad de uso de la App, incluyendo pero no limitado a pérdidas económicas, daños a la reputación o pérdida de datos.\n\n## 8. Modificaciones\n\nNos reservamos el derecho de modificar estos Términos en cualquier momento. Las modificaciones entrarán en vigor al publicarse en la App. El uso continuado de la App tras la publicación de cambios constituirá su aceptación de los nuevos términos.\n\n## 9. Ley aplicable y jurisdicción\n\nEstos Términos se rigen por las leyes de la **República Dominicana**. Cualquier controversia derivada de su interpretación o cumplimiento será sometida a los tribunales competentes de **Santo Domingo, República Dominicana**, renunciando expresamente a cualquier otro fuero que pudiera corresponder.\n\n## 10. Contacto\n\nPara cualquier consulta relacionada con estos Términos, puede contactarnos en:\n**soporte@cabin.do**\n\n---\n*Cabin © 2026 — República Dominicana. Todos los derechos reservados.*"
}
```

---

## 2. Documento: `legal/privacy`

**Ruta:** `legal` → documento `privacy`

```json
{
  "version": "2.0",
  "updatedAt": "2026-05-21",
  "content": "# Política de Privacidad\n\n**Versión 2.0 — Vigente desde el 21 de mayo de 2026**\n\n## 1. Responsable del tratamiento\n\n**Cabin** (en adelante, \"nosotros\") es responsable del tratamiento de los datos personales recabados a través de la aplicación móvil Cabin, operada en la **República Dominicana**.\n\n## 2. Marco legal aplicable\n\nEl tratamiento de sus datos personales se rige por la **Ley No. 172-13 sobre Protección de Datos Personales de la República Dominicana** y sus reglamentos de aplicación. La autoridad competente en materia de protección de datos en RD es el **INDOTEL** (Instituto Dominicano de las Telecomunicaciones) y el Instituto Nacional de Protección de Datos Personales (INPDP).\n\n## 3. Datos que recopilamos\n\nRecopilamos los siguientes datos cuando usted utiliza la App:\n\n- **Datos de registro:** nombre completo, correo electrónico, número de teléfono (opcional).\n- **Datos de uso:** lugares visitados, favoritos guardados, historial de búsqueda dentro de la App.\n- **Datos de ubicación:** coordenadas GPS para mostrar establecimientos cercanos (solo cuando usted lo autoriza expresamente).\n- **Datos técnicos:** tipo de dispositivo, sistema operativo, identificadores de dispositivo anónimos.\n\n## 4. Finalidad del tratamiento\n\nSus datos son utilizados para:\n\n- Gestionar su cuenta y autenticar su acceso.\n- Mostrar establecimientos de hospedaje cercanos a su ubicación.\n- Mejorar la experiencia de uso de la App.\n- Enviar notificaciones relacionadas con el servicio (si usted lo autoriza).\n- Cumplir con obligaciones legales aplicables en la República Dominicana.\n\n## 5. Base legal del tratamiento\n\nEl tratamiento de sus datos se fundamenta en:\n\n- Su **consentimiento expreso** otorgado al registrarse y aceptar esta Política.\n- La **ejecución del contrato** de servicios de la App.\n- El **interés legítimo** de mejorar la seguridad y funcionamiento del servicio.\n- El **cumplimiento de obligaciones legales** conforme a la Ley 172-13.\n\n## 6. Compartición de datos\n\nNo vendemos ni cedemos sus datos personales a terceros con fines comerciales. Podemos compartir datos con:\n\n- **Proveedores de servicios técnicos** (Firebase/Google) bajo acuerdos de confidencialidad que cumplen con estándares internacionales de protección de datos.\n- **Autoridades dominicanas** cuando sea requerido por ley.\n\n## 7. Transferencia internacional de datos\n\nAlgunos de nuestros proveedores técnicos (Firebase) almacenan datos en servidores fuera de la República Dominicana. En tales casos, garantizamos que dichas transferencias se realizan con las salvaguardas adecuadas conforme al artículo 24 de la Ley 172-13.\n\n## 8. Derechos del titular de los datos\n\nConforme a la Ley No. 172-13, usted tiene derecho a:\n\n- **Acceder** a sus datos personales que tratamos.\n- **Rectificar** datos inexactos o incompletos.\n- **Cancelar** o eliminar sus datos cuando no sean necesarios.\n- **Oponerse** al tratamiento de sus datos para determinadas finalidades.\n- **Revocar** su consentimiento en cualquier momento.\n\nPara ejercer estos derechos, contáctenos en: **soporte@cabin.do**\n\n## 9. Conservación de datos\n\nConservamos sus datos mientras mantenga una cuenta activa. Tras la eliminación de su cuenta, los datos se borran en un plazo máximo de 30 días, salvo obligación legal de conservación.\n\n## 10. Seguridad\n\nAplicamos medidas técnicas y organizativas para proteger sus datos: cifrado en tránsito (HTTPS/TLS), autenticación segura (Firebase Auth), y acceso restringido a los datos.\n\n## 11. Datos de menores\n\nLa App no está dirigida a menores de 18 años. No recopilamos intencionalmente datos de menores. Si detectamos que hemos recabado datos de un menor, los eliminaremos de forma inmediata.\n\n## 12. Cambios a esta Política\n\nPodremos actualizar esta Política en cualquier momento. Le notificaremos los cambios relevantes a través de la App. El uso continuado de la App tras la publicación de cambios implica su aceptación.\n\n## 13. Contacto y reclamaciones\n\nPara cualquier consulta sobre el tratamiento de sus datos:\n\n**Email:** soporte@cabin.do\n\nSi considera que sus derechos no han sido atendidos adecuadamente, puede presentar una reclamación ante el **INDOTEL** o la autoridad de protección de datos competente en la República Dominicana.\n\n---\n*Cabin © 2026 — República Dominicana. Todos los derechos reservados.*"
}
```

---

## 3. Documento: `config/app`

**Ruta:** `config` → documento `app`

```json
{
  "country": "DO",
  "currency": "DOP",
  "currencySymbol": "RD$",
  "language": "es",
  "timezone": "America/Santo_Domingo",
  "supportEmail": "soporte@cabin.do",
  "supportPhone": "+1 809 000 0000",
  "defaultCity": "Santo Domingo",
  "supportedCities": [
    "Santo Domingo",
    "Santiago de los Caballeros",
    "Punta Cana",
    "Bávaro",
    "La Romana",
    "Puerto Plata",
    "San Pedro de Macorís",
    "Boca Chica",
    "Jarabacoa",
    "Samaná",
    "Las Terrenas",
    "Bayahíbe",
    "Constanza",
    "Higüey"
  ],
  "mapDefaultLat": 18.7357,
  "mapDefaultLng": -70.1627,
  "mapDefaultZoom": 8,
  "appVersion": "2.0.0",
  "maintenanceMode": false,
  "allowNewRegistrations": true
}
```

---

## 4. Lugares de prueba (colección `places`)

Eliminar los lugares con ciudades mexicanas y crear nuevos desde el Admin Panel.
Alternativamente, actualizar los documentos existentes con estos datos de referencia:

### Ejemplo: Lugar Santo Domingo
```json
{
  "name": "Motel Las Palmas",
  "description": "Cómodo motel en el corazón de Santo Domingo con habitaciones climatizadas, estacionamiento y servicio 24 horas.",
  "type": "motel",
  "address": "Calle Principal 45, Sector Gazcue",
  "city": "Santo Domingo",
  "state": "Distrito Nacional",
  "geopoint": { "__type": "GeoPoint", "latitude": 18.4774, "longitude": -69.9312 },
  "location": { "city": "Santo Domingo", "state": "Distrito Nacional" },
  "pricePerNight": 2500,
  "isActive": true,
  "isFeatured": true,
  "is24h": true,
  "amenities": ["WiFi", "Aire Acondicionado", "Estacionamiento", "TV"],
  "photos": [],
  "rating": 0,
  "reviewCount": 0,
  "extras": {}
}
```

### Ejemplo: Lugar Santiago
```json
{
  "name": "Cabaña El Cibao",
  "description": "Hermosa cabaña en las afueras de Santiago con vista a la Cordillera Central, perfecta para escapadas de fin de semana.",
  "type": "cabaña",
  "address": "Km 12 Autopista Duarte, El Mamey",
  "city": "Santiago de los Caballeros",
  "state": "Santiago",
  "geopoint": { "__type": "GeoPoint", "latitude": 19.4517, "longitude": -70.6970 },
  "location": { "city": "Santiago de los Caballeros", "state": "Santiago" },
  "pricePerNight": 4500,
  "isActive": true,
  "isFeatured": false,
  "is24h": false,
  "amenities": ["WiFi", "Piscina", "BBQ", "Estacionamiento", "Aire Acondicionado"],
  "photos": [],
  "rating": 0,
  "reviewCount": 0,
  "extras": {}
}
```

### Ejemplo: Lugar Punta Cana
```json
{
  "name": "Villa Coral Bávaro",
  "description": "Exclusiva villa privada a 5 minutos de Playa Bávaro. Ideal para parejas y grupos pequeños buscando privacidad total.",
  "type": "villa",
  "address": "Carretera Bávaro, Sector Los Corales",
  "city": "Punta Cana",
  "state": "La Altagracia",
  "geopoint": { "__type": "GeoPoint", "latitude": 18.5601, "longitude": -68.3725 },
  "location": { "city": "Punta Cana", "state": "La Altagracia" },
  "pricePerNight": 8500,
  "isActive": true,
  "isFeatured": true,
  "is24h": false,
  "amenities": ["WiFi", "Piscina", "Jacuzzi", "Aire Acondicionado", "Cocina", "Estacionamiento"],
  "photos": [],
  "rating": 0,
  "reviewCount": 0,
  "extras": {}
}
```

---

## Cómo aplicar estos cambios en Firebase Console

1. Abre https://console.firebase.google.com → tu proyecto → **Firestore Database**
2. Para `legal/terms`:
   - Navega a colección `legal` → documento `terms`
   - Haz clic en cada campo y actualiza su valor
   - El campo `content` es el texto Markdown completo
3. Para `config/app`:
   - Navega a colección `config` → documento `app` (créalo si no existe)
   - Agrega cada campo con su tipo (string, number, boolean, array)
4. Para los `places/`:
   - Elimina los documentos con ciudades mexicanas
   - Crea nuevos documentos con los datos de referencia de RD
   - O créalos directamente desde el Admin Panel ya actualizado

---

*Generado automáticamente el 2026-05-21 para la migración Cabin MX → RD*
