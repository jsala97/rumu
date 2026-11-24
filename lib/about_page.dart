import 'package:material_ui/material_ui.dart';
import 'app_info.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(appName, style: TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              const Text('Versión $appVersion'),
              const SizedBox(height: 16),
              const Text(
                'Reproductor de listas IPTV (Xtream y M3U) para Windows. '
                'No incluye canales ni contenido: solo reproduce las listas que tú añadas, '
                'y eres responsable de usar únicamente contenido al que tengas derecho de acceso.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Privacidad: todo se guarda en tu equipo. La app solo se conecta a los '
                'servidores que configures y, opcionalmente, a TMDB si pones un token.',
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Licencias de código abierto'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: appName,
                  applicationVersion: appVersion,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Este producto usa la API de TMDB pero no está avalado ni certificado por TMDB.',
                style: TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}