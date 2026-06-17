# Arreglar fotos que no se ven en el Admin Panel (CORS)

**Síntoma:** subes una foto a un lugar y en el panel web sale el ícono de "imagen rota".
La foto SÍ se sube bien a Firebase Storage (la URL queda guardada en Firestore), pero el
navegador bloquea mostrarla porque el bucket de Storage no permite peticiones desde otro
dominio (CORS). En la app móvil (nativa) se ve bien porque ahí no aplica CORS; solo falla
en la web del admin (Flutter Web usa CanvasKit y descarga la imagen con fetch → necesita CORS).

## Solución (una sola vez) — Google Cloud Shell, sin instalar nada

1. Abre **https://console.cloud.google.com/** y selecciona el proyecto **cabin-de0c9**.
2. Click en el ícono de **Cloud Shell** (`>_`) arriba a la derecha.
3. Pega este bloque y Enter:

```bash
cat > cors.json <<'EOF'
[
  { "origin": ["*"], "method": ["GET", "HEAD"], "responseHeader": ["Content-Type"], "maxAgeSeconds": 3600 }
]
EOF
gsutil cors set cors.json gs://cabin-de0c9.firebasestorage.app
gsutil cors get gs://cabin-de0c9.firebasestorage.app
```

> Si el primer `gsutil cors set` da error de bucket inexistente, prueba con el bucket clásico:
> `gsutil cors set cors.json gs://cabin-de0c9.appspot.com`
> (algunos proyectos tienen uno u otro; aplica al que exista).

4. Recarga el admin (Ctrl+Shift+R para limpiar caché). Las fotos ya se verán.

El archivo `cors.json` de este repo es el mismo contenido, por si prefieres subirlo y correr
`gsutil cors set cors.json gs://cabin-de0c9.firebasestorage.app` directamente.
