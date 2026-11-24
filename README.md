# Rumu

Rumu es un reproductor IPTV de escritorio para Windows, hecho con Flutter.
Reproduce las listas que tú añadas (Xtream Codes o M3U). **No incluye canales ni contenido de ningún tipo.**

## Funciones

- Cuentas Xtream (varios servidores por cuenta con test de velocidad) y listas M3U por URL
- Canales en directo: buscador, favoritos, recientes y guía de programación (EPG)
- Películas y series, con "continuar viendo", audio y subtítulos
- Ocultar y ordenar categorías, tema claro/oscuro y color de acento
- Credenciales guardadas cifradas con el almacén seguro de Windows
- Cambio de canal desde el reproductor y atajos de teclado

## Requisitos

- [Flutter](https://docs.flutter.dev/get-started/install/windows/desktop)
- Visual Studio con la carga de trabajo "Desarrollo para el escritorio con C++"
  (y el componente "ATL de C++" si la compilación lo pide)

## Ejecutar

```
flutter pub get
flutter run -d windows
```

## Atajos del reproductor

| Tecla         | Acción                     |
| ------------- | -------------------------- |
| Espacio       | Pausa / play               |
| ← / →         | Retroceder / avanzar 10 s  |
| ↑ / ↓         | Volumen                    |
| M             | Silenciar                  |
| AvPág / RePág | Canal siguiente / anterior |
| F / F11 / Esc | Pantalla completa / salir  |
| I             | Guía del canal             |
| S             | Audio y subtítulos         |

## Privacidad

Todo se guarda en tu equipo. La app no envía datos a terceros salvo las peticiones a los servidores que tú configures y, opcionalmente, al servidor de pruebas de velocidad.

Opcionalmente, si pones un token de [TMDB](https://www.themoviedb.org) en Ajustes, la app envía a TMDB el título de lo que abres para completar la ficha (sinopsis, reparto, tráiler). Sin token no se envía nada.

## Aviso legal

Este proyecto es solo un reproductor. El usuario es responsable de usar únicamente listas y contenidos a los que tenga derecho legítimo de acceso.

Este producto usa la API de TMDB pero no está avalado ni certificado por TMDB.

## Estado

Proyecto personal en desarrollo.

## Licencia

MIT. Ver el archivo [LICENSE](LICENSE).
