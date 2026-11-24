import 'package:material_ui/material_ui.dart';
import 'account.dart';
import 'server_picker_page.dart';
import 'speed_test_page.dart';
import 'account_home_page.dart';
import 'settings_page.dart';
import 'progress_store.dart';
import 'about_page.dart';

String _normalize(String s) {
  s = s.trim();
  if (s.isEmpty) return '';
  if (!s.startsWith('http')) s = 'http://$s';
  if (s.endsWith('/')) s = s.substring(0, s.length - 1);
  return s;
}

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  List<Account> _accounts = [];
  bool _loaded = false;
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final list = await AccountStore.load();
    for (final a in list) {
      ProgressStore.list(a.id); // limpia entradas antiguas con credenciales
    }
    if (!mounted) return;
    setState(() {
      _accounts = list;
      _loaded = true;
    });
  }

  void _snack(String msg, {String? actionLabel, VoidCallback? onAction}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        action: actionLabel == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
      ),
    );
  }

    Future<void> _connect(Account acc) async {
    final server = acc.currentServer;
    setState(() => _connecting = true);
    try {
      final source = acc.createSource(server);
      final ok = await source.login().timeout(
            Duration(seconds: acc.type == AccountType.m3u ? 60 : 12),
          );
      if (!ok) {
        _snack(
          'Usuario o contraseña incorrectos',
          actionLabel: 'Editar cuenta',
          onAction: () => _editAccount(acc),
        );
        return;
      }
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AccountHomePage(
            source: source,
            accountId: acc.id,
            epgUrl: acc.effectiveEpgUrl(server),
          ),
      ),
      );
    } catch (e) {
      _snack(
        'No se pudo conectar a ${acc.label(server)}',
        actionLabel: 'Cambiar servidor',
        onAction: () => _pickServer(acc),
      );
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _pickServer(Account acc) async {
    final server = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => ServerPickerPage(account: acc)),
    );
    if (server == null) return;
    final i = _accounts.indexWhere((a) => a.id == acc.id);
    if (i < 0) return;
    _accounts[i] = acc.copyWith(lastServer: server);
    await AccountStore.save(_accounts);
    if (!mounted) return;
    setState(() {});
    _snack('Servidor fijado: $server');
  }

    Future<Account?> _showAccountDialog({Account? existing}) async {
    final name = TextEditingController(text: existing?.name ?? '');
    final servers =
        TextEditingController(text: existing?.servers.join('\n') ?? '');
    final user = TextEditingController(text: existing?.user ?? '');
    final pass = TextEditingController(text: existing?.pass ?? '');
    final epg = TextEditingController(text: existing?.epgUrl ?? '');
    var type = existing?.type ?? AccountType.xtream;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(existing == null ? 'Nueva cuenta' : 'Editar cuenta'),
          content: SizedBox(
            width: 380,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (existing == null) ...[
                    SegmentedButton<AccountType>(
                      segments: const [
                        ButtonSegment(
                          value: AccountType.xtream,
                          label: Text('Xtream'),
                        ),
                        ButtonSegment(
                          value: AccountType.m3u,
                          label: Text('Lista M3U'),
                        ),
                      ],
                      selected: {type},
                      onSelectionChanged: (s) =>
                          setLocal(() => type = s.first),
                    ),
                    const SizedBox(height: 8),
                  ],
                  TextField(
                    controller: name,
                    decoration:
                        const InputDecoration(labelText: 'Nombre (ej: Casa)'),
                  ),
                  if (type == AccountType.xtream) ...[
                    TextField(
                      controller: servers,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Servidores (uno por línea)',
                        hintText: 'servidor1.com:8080\nservidor2.com:8080',
                      ),
                    ),
                    TextField(
                      controller: user,
                      decoration: const InputDecoration(labelText: 'Usuario'),
                    ),
                    TextField(
                      controller: pass,
                      obscureText: true,
                      decoration:
                          const InputDecoration(labelText: 'Contraseña'),
                    ),
                  ] else
                    TextField(
                      controller: servers,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'URL de la lista M3U',
                      ),
                    ),
                  TextField(
                    controller: epg,
                    decoration: const InputDecoration(
                      labelText: 'URL de la guía EPG (opcional)',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return null;

    final list = type == AccountType.m3u
        ? [_normalize(servers.text)].where((s) => s.isNotEmpty).toList()
        : servers.text
            .split('\n')
            .map(_normalize)
            .where((s) => s.isNotEmpty)
            .toList();
    if (list.isEmpty) {
      _snack('Añade al menos un servidor o una URL');
      return null;
    }

    final isM3u = type == AccountType.m3u;
    final epgText = epg.text.trim();
    return Account(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.text.trim().isNotEmpty
          ? name.text.trim()
          : (isM3u ? 'Lista M3U' : list.first),
      type: type,
      servers: list,
      user: isM3u ? '' : user.text.trim(),
      pass: isM3u ? '' : pass.text.trim(),
      lastServer: existing?.lastServer,
      epgUrl: epgText.isEmpty ? null : epgText,
    );
  }

  Future<void> _addAccount() async {
    final acc = await _showAccountDialog();
    if (acc == null) return;
    _accounts.add(acc);
    await AccountStore.save(_accounts);
    if (mounted) setState(() {});
  }

  Future<void> _editAccount(Account old) async {
    final acc = await _showAccountDialog(existing: old);
    if (acc == null) return;
    final i = _accounts.indexWhere((a) => a.id == old.id);
    if (i < 0) return;
    _accounts[i] = acc;
    await AccountStore.save(_accounts);
    if (mounted) setState(() {});
  }

  Future<void> _delete(Account acc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar cuenta'),
        content: Text('¿Seguro que quieres borrar "${acc.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    _accounts.removeWhere((a) => a.id == acc.id);
    await AccountStore.save(_accounts);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis cuentas'),
        actions: [
          IconButton(
            tooltip: 'Ajustes',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
          IconButton(
            tooltip: 'Test de mi conexión',
            icon: const Icon(Icons.speed),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SpeedTestPage()),
            ),
          ),
          IconButton(
            tooltip: 'Acerca de',
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutPage()),
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAccount,
        icon: const Icon(Icons.add),
        label: const Text('Añadir cuenta'),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : _accounts.isEmpty
              ? const Center(
                  child: Text('Aún no tienes cuentas. Pulsa "Añadir cuenta".'),
                )
              : Stack(
                  children: [
                    ListView.builder(
                      itemCount: _accounts.length,
                      itemBuilder: (context, i) {
                        final acc = _accounts[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: Icon(acc.type == AccountType.m3u ? Icons.link : Icons.dns),
                            title: Text(acc.name),
                            subtitle: Text(
                              acc.servers.length > 1
                                  ? '${acc.label(acc.currentServer)}  ·  ${acc.servers.length} servidores'
                                  : acc.label(acc.currentServer),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (acc.servers.length > 1)
                                  IconButton(
                                    tooltip: 'Cambiar servidor',
                                    icon: const Icon(Icons.swap_horiz),
                                    onPressed: () => _pickServer(acc),
                                  ),
                                IconButton(
                                  tooltip: 'Editar cuenta',
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _editAccount(acc),
                                ),
                                IconButton(
                                  tooltip: 'Borrar cuenta',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _delete(acc),
                                ),
                              ],
                            ),
                            onTap: _connecting ? null : () => _connect(acc),
                          ),
                        );
                      },
                    ),
                    if (_connecting)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
    );
  }
}