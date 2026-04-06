import 'package:fashion_studio/models/client.dart';
import 'package:fashion_studio/services/clients_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key, required this.clientsService});

  final ClientsService clientsService;

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  late Future<List<Client>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.clientsService.list();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = widget.clientsService.list();
    });
    await _future;
  }

  Future<void> _openEditor({Client? editing}) async {
    final result = await showDialog<_ClientFormResult>(
      context: context,
      builder: (context) => _ClientEditorDialog(editing: editing),
    );

    if (result == null) return;

    try {
      if (editing == null) {
        await widget.clientsService.create(
          prenom: result.prenom,
          nom: result.nom,
          telephone: result.telephone,
          email: result.email,
          taille: result.taille,
          poitrine: result.poitrine,
          tourDeTaille: result.tourDeTaille,
          hanches: result.hanches,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Client ajouté avec succès')));
      } else {
        await widget.clientsService.update(
          id: editing.id,
          prenom: result.prenom,
          nom: result.nom,
          telephone: result.telephone,
          email: result.email,
          taille: result.taille,
          poitrine: result.poitrine,
          tourDeTaille: result.tourDeTaille,
          hanches: result.hanches,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Client mis à jour avec succès')));
      }

      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> _delete(Client client) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le client'),
          content: Text(
              'Êtes-vous sûr de vouloir supprimer ${client.prenom} ${client.nom} ?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler')),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626)),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    try {
      await widget.clientsService.delete(client.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Client supprimé')));
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<Client>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Erreur lors du chargement',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(snapshot.error.toString()),
                const SizedBox(height: 12),
                FilledButton(
                    onPressed: _refresh, child: const Text('Réessayer')),
              ],
            );
          }

          final clients = snapshot.data ?? const <Client>[];
          final count = clients.length;

          return LayoutBuilder(
            builder: (context, c) {
              final crossAxisCount = c.maxWidth >= 1100
                  ? 3
                  : c.maxWidth >= 700
                      ? 2
                      : 1;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Clients',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            Text(
                              '$count client${count > 1 ? 's' : ''} enregistré${count > 1 ? 's' : ''}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: () => _openEditor(),
                        icon: const Icon(Icons.add),
                        label: const Text('Nouveau client'),
                        style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (clients.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 44, horizontal: 16),
                        child: Center(
                          child: Text(
                            'Aucun client enregistré. Ajoutez votre premier client !',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey.shade700),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: crossAxisCount == 1 ? 1.8 : 1.55,
                      ),
                      itemCount: clients.length,
                      itemBuilder: (context, i) {
                        final client = clients[i];
                        return _ClientCard(
                          client: client,
                          onEdit: () => _openEditor(editing: client),
                          onDelete: () => _delete(client),
                        );
                      },
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard(
      {required this.client, required this.onEdit, required this.onDelete});

  final Client client;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('yyyy-MM-dd').format(client.createdAt);

    return Card(
      elevation: 10,
      shadowColor: const Color(0xFFDC2626).withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: const Color(0xFFDC2626).withOpacity(0.10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${client.prenom} ${client.nom}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Client depuis $date',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon:
                      const Icon(Icons.edit_outlined, color: Color(0xFFDC2626)),
                  tooltip: 'Modifier',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline,
                      color: Color(0xFFDC2626)),
                  tooltip: 'Supprimer',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.phone_outlined,
                    size: 18, color: Color(0xFFFB7185)),
                const SizedBox(width: 8),
                Expanded(child: Text(client.telephone)),
              ],
            ),
            if (client.email != null && client.email!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.mail_outline,
                      size: 18, color: Color(0xFFFB7185)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      client.email!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Divider(color: const Color(0xFFDC2626).withOpacity(0.10)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.straighten,
                            size: 18, color: Color(0xFFFB7185)),
                        const SizedBox(width: 8),
                        Text(
                          'Mensurations',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        _MeasureChip(label: 'Taille', value: client.taille),
                        _MeasureChip(label: 'Poitrine', value: client.poitrine),
                        _MeasureChip(
                            label: 'Tour taille', value: client.tourDeTaille),
                        _MeasureChip(label: 'Hanches', value: client.hanches),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeasureChip extends StatelessWidget {
  const _MeasureChip({required this.label, required this.value});

  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) {
    final v = value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        v == null ? '$label: -' : '$label: $v cm',
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF9F1239)),
      ),
    );
  }
}

class _ClientEditorDialog extends StatefulWidget {
  const _ClientEditorDialog({this.editing});

  final Client? editing;

  @override
  State<_ClientEditorDialog> createState() => _ClientEditorDialogState();
}

class _ClientEditorDialogState extends State<_ClientEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _prenom;
  late final TextEditingController _nom;
  late final TextEditingController _telephone;
  late final TextEditingController _email;
  late final TextEditingController _taille;
  late final TextEditingController _poitrine;
  late final TextEditingController _tourDeTaille;
  late final TextEditingController _hanches;

  @override
  void initState() {
    super.initState();
    final c = widget.editing;
    _prenom = TextEditingController(text: c?.prenom ?? '');
    _nom = TextEditingController(text: c?.nom ?? '');
    _telephone = TextEditingController(text: c?.telephone ?? '');
    _email = TextEditingController(text: c?.email ?? '');
    _taille = TextEditingController(text: c?.taille?.toString() ?? '');
    _poitrine = TextEditingController(text: c?.poitrine?.toString() ?? '');
    _tourDeTaille =
        TextEditingController(text: c?.tourDeTaille?.toString() ?? '');
    _hanches = TextEditingController(text: c?.hanches?.toString() ?? '');
  }

  @override
  void dispose() {
    _prenom.dispose();
    _nom.dispose();
    _telephone.dispose();
    _email.dispose();
    _taille.dispose();
    _poitrine.dispose();
    _tourDeTaille.dispose();
    _hanches.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing != null;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editing ? 'Modifier le client' : 'Nouveau client',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                _TwoCols(
                  left: _field('Prénom *', _prenom, required: true),
                  right: _field('Nom *', _nom, required: true),
                ),
                const SizedBox(height: 12),
                _TwoCols(
                  left: _field('Téléphone *', _telephone,
                      required: true, keyboardType: TextInputType.phone),
                  right: _field('Email', _email,
                      keyboardType: TextInputType.emailAddress),
                ),
                const SizedBox(height: 18),
                Divider(color: const Color(0xFFDC2626).withOpacity(0.10)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.straighten, size: 18),
                    const SizedBox(width: 8),
                    Text('Mensurations (en cm)',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 12),
                _GridMeasures(
                  children: [
                    _field('Taille *', _taille,
                        required: true, keyboardType: TextInputType.number),
                    _field('Poitrine *', _poitrine,
                        required: true, keyboardType: TextInputType.number),
                    _field('Tour de taille *', _tourDeTaille,
                        required: true, keyboardType: TextInputType.number),
                    _field('Hanches *', _hanches,
                        required: true, keyboardType: TextInputType.number),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Annuler')),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;

                        final result = _ClientFormResult(
                          prenom: _prenom.text.trim(),
                          nom: _nom.text.trim(),
                          telephone: _telephone.text.trim(),
                          email: _email.text.trim().isEmpty
                              ? null
                              : _email.text.trim(),
                          taille: int.parse(_taille.text.trim()),
                          poitrine: int.parse(_poitrine.text.trim()),
                          tourDeTaille: int.parse(_tourDeTaille.text.trim()),
                          hanches: int.parse(_hanches.text.trim()),
                        );

                        Navigator.of(context).pop(result);
                      },
                      style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626)),
                      child: Text(editing ? 'Mettre à jour' : 'Ajouter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          validator: (v) {
            if (!required) return null;
            final value = (v ?? '').trim();
            if (value.isEmpty) return 'Champ obligatoire';
            return null;
          },
        ),
      ],
    );
  }
}

class _GridMeasures extends StatelessWidget {
  const _GridMeasures({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final crossAxisCount = c.maxWidth >= 700 ? 3 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.6,
          children: children,
        );
      },
    );
  }
}

class _TwoCols extends StatelessWidget {
  const _TwoCols({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isTwo = c.maxWidth >= 640;
        if (!isTwo) {
          return Column(
            children: [
              left,
              const SizedBox(height: 12),
              right,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: left),
            const SizedBox(width: 12),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

class _ClientFormResult {
  const _ClientFormResult({
    required this.prenom,
    required this.nom,
    required this.telephone,
    required this.email,
    required this.taille,
    required this.poitrine,
    required this.tourDeTaille,
    required this.hanches,
  });

  final String prenom;
  final String nom;
  final String telephone;
  final String? email;
  final int taille;
  final int poitrine;
  final int tourDeTaille;
  final int hanches;
}
