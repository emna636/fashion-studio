import 'package:fashion_studio/models/client.dart';
import 'package:fashion_studio/models/commande.dart';
import 'package:fashion_studio/models/design.dart';
import 'package:fashion_studio/services/clients_service.dart';
import 'package:fashion_studio/services/commandes_service.dart';
import 'package:fashion_studio/services/designs_service.dart';
import 'package:fashion_studio/utils/download_bytes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommandesScreen extends StatefulWidget {
  const CommandesScreen({
    super.key,
    required this.commandesService,
    required this.clientsService,
    required this.designsService,
  });

  final CommandesService commandesService;
  final ClientsService clientsService;
  final DesignsService designsService;

  @override
  State<CommandesScreen> createState() => _CommandesScreenState();
}

class _CommandesScreenState extends State<CommandesScreen> {
  late Future<_CommandesData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<void> _exportPdf(Commande commande) async {
    try {
      final res = await widget.commandesService.downloadFacturePdf(commande.id);
      if (!mounted) return;

      final filename = res.filename ?? 'facture-${commande.id}.pdf';
      downloadBytes(res.bytes, filename: filename, mimeType: 'application/pdf');

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('PDF téléchargé')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<_CommandesData> _load() async {
    final results = await Future.wait([
      widget.commandesService.list(),
      widget.clientsService.list(),
      widget.designsService.list(),
    ]);

    return _CommandesData(
      commandes: results[0] as List<Commande>,
      clients: results[1] as List<Client>,
      designs: results[2] as List<Design>,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _openEditor(
      {required List<Client> clients,
      required List<Design> designs,
      Commande? editing}) async {
    final result = await showDialog<_CommandeFormResult>(
      context: context,
      builder: (context) => _CommandeEditorDialog(
        clients: clients,
        designs: designs,
        editing: editing,
      ),
    );

    if (result == null) return;

    final commande = Commande(
      id: editing?.id ?? 'TEMP',
      clientId: result.clientId,
      designId: result.designId,
      statut: result.statut,
      prixTotal: result.prixTotal,
      montantPaye: result.montantPaye,
      dateCommande: result.dateCommande,
      dateLivraison: result.dateLivraison,
      notes: result.notes,
    );

    try {
      if (editing == null) {
        await widget.commandesService.create(commande);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Commande créée avec succès')));
      } else {
        await widget.commandesService.update(editing.id, commande);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Commande mise à jour avec succès')));
      }

      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> _delete(Commande commande) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer la commande'),
          content:
              const Text('Êtes-vous sûr de vouloir supprimer cette commande ?'),
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
      await widget.commandesService.delete(commande.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Commande supprimée')));
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.decimalPattern('fr_FR');

    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<_CommandesData>(
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

          final data = snapshot.data!;
          final commandes = data.commandes;

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
                        Text('Commandes',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(
                          '${commandes.length} commande${commandes.length > 1 ? 's' : ''}',
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
                    onPressed: () => _openEditor(
                        clients: data.clients, designs: data.designs),
                    icon: const Icon(Icons.add),
                    label: const Text('Nouvelle commande'),
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (commandes.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 44, horizontal: 16),
                    child: Center(
                      child: Text(
                        'Aucune commande enregistrée. Créez votre première commande !',
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
                ...commandes.map((commande) {
                  final client = data.clientById[commande.clientId];
                  final design = data.designById[commande.designId];
                  final reste = commande.resteAPayer;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
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
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 8,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          '${client?.prenom ?? ''} ${client?.nom ?? ''}'
                                              .trim(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w900),
                                        ),
                                        StatutBadge(statut: commande.statut),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(design?.nom ?? '',
                                        style: TextStyle(
                                            color: Colors.grey.shade700)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton.icon(
                                onPressed: () => _exportPdf(commande),
                                icon: const Icon(Icons.picture_as_pdf_outlined,
                                    size: 18),
                                label: const Text('PDF'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () => _openEditor(
                                    clients: data.clients,
                                    designs: data.designs,
                                    editing: commande),
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('Modifier'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () => _delete(commande),
                                child: const Icon(Icons.delete_outline,
                                    color: Color(0xFFDC2626)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          LayoutBuilder(
                            builder: (context, c) {
                              final isWide = c.maxWidth >= 900;
                              final tiles = [
                                _InfoTile(
                                  icon: Icons.calendar_month_outlined,
                                  title: 'Date de livraison',
                                  value: DateFormat('yyyy-MM-dd')
                                      .format(commande.dateLivraison),
                                ),
                                _InfoTile(
                                  icon: Icons.payments_outlined,
                                  title: 'Prix total',
                                  value:
                                      '${money.format(commande.prixTotal)} DH',
                                ),
                                _InfoTile(
                                  icon: Icons.payments_outlined,
                                  title: 'Montant payé',
                                  value:
                                      '${money.format(commande.montantPaye)} DH',
                                  footer: reste > 0
                                      ? Text('Reste: ${money.format(reste)} DH',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFDC2626),
                                              fontWeight: FontWeight.w700))
                                      : const Text('Payé intégralement',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF16A34A),
                                              fontWeight: FontWeight.w700)),
                                ),
                              ];

                              if (isWide) {
                                return Row(
                                  children: tiles
                                      .map((t) => Expanded(
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 12),
                                              child: t)))
                                      .toList(),
                                );
                              }
                              return Column(
                                children: tiles
                                    .map((t) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: t))
                                    .toList(),
                              );
                            },
                          ),
                          if (commande.notes != null &&
                              commande.notes!.trim().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                commande.notes!,
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(
      {required this.icon,
      required this.title,
      required this.value,
      this.footer});

  final IconData icon;
  final String title;
  final String value;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
              if (footer != null) ...[
                const SizedBox(height: 4),
                footer!,
              ]
            ],
          ),
        ),
      ],
    );
  }
}

class StatutBadge extends StatelessWidget {
  const StatutBadge({super.key, required this.statut});

  final StatutCommande statut;

  @override
  Widget build(BuildContext context) {
    final info = switch (statut) {
      StatutCommande.enAttente => (
          label: 'En attente',
          bg: const Color(0xFFFEF9C3),
          fg: const Color(0xFF854D0E)
        ),
      StatutCommande.enCours => (
          label: 'En cours',
          bg: const Color(0xFFDBEAFE),
          fg: const Color(0xFF1E40AF)
        ),
      StatutCommande.enCouture => (
          label: 'En couture',
          bg: const Color(0xFFE9D5FF),
          fg: const Color(0xFF6B21A8)
        ),
      StatutCommande.paye => (
          label: 'Payé',
          bg: const Color(0xFFD1FAE5),
          fg: const Color(0xFF065F46)
        ),
      StatutCommande.termine => (
          label: 'Terminé',
          bg: const Color(0xFFDCFCE7),
          fg: const Color(0xFF166534)
        ),
      StatutCommande.livre => (
          label: 'Livré',
          bg: const Color(0xFFF3F4F6),
          fg: const Color(0xFF374151)
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: info.bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        info.label,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w800, color: info.fg),
      ),
    );
  }
}

class _CommandeEditorDialog extends StatefulWidget {
  const _CommandeEditorDialog(
      {required this.clients, required this.designs, this.editing});

  final List<Client> clients;
  final List<Design> designs;
  final Commande? editing;

  @override
  State<_CommandeEditorDialog> createState() => _CommandeEditorDialogState();
}

class _CommandeEditorDialogState extends State<_CommandeEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _clientId;
  String? _designId;
  StatutCommande _statut = StatutCommande.enAttente;
  DateTime? _dateLivraison;

  final _prixTotal = TextEditingController();
  final _montantPaye = TextEditingController();
  final _notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    final c = widget.editing;
    if (c != null) {
      _clientId = c.clientId;
      _designId = c.designId;
      _statut = c.statut;
      _dateLivraison = c.dateLivraison;
      _prixTotal.text = c.prixTotal.toString();
      _montantPaye.text = c.montantPaye.toString();
      _notes.text = c.notes ?? '';
    }
  }

  @override
  void dispose() {
    _prixTotal.dispose();
    _montantPaye.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _dateLivraison ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() {
      _dateLivraison = picked;
    });
  }

  void _onDesignChanged(String? id) {
    setState(() {
      _designId = id;
      final design = widget.designs
          .where((d) => d.id == id)
          .cast<Design?>()
          .firstWhere((e) => true, orElse: () => null);
      if (design != null && _prixTotal.text.trim().isEmpty) {
        _prixTotal.text = design.prix.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing != null;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editing ? 'Modifier la commande' : 'Nouvelle commande',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                _TwoCols(
                  left: _dropdownClient(),
                  right: _dropdownDesign(),
                ),
                const SizedBox(height: 12),
                _TwoCols(
                  left: _dropdownStatut(),
                  right: _dateField(),
                ),
                const SizedBox(height: 12),
                _TwoCols(
                  left: _numberField('Prix total (DH) *', _prixTotal),
                  right: _numberField('Montant payé (DH) *', _montantPaye),
                ),
                const SizedBox(height: 12),
                Text('Notes',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notes,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Notes supplémentaires...'),
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
                        if (_dateLivraison == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Date de livraison obligatoire')));
                          return;
                        }

                        final result = _CommandeFormResult(
                          clientId: _clientId!,
                          designId: _designId!,
                          statut: _statut,
                          dateCommande:
                              widget.editing?.dateCommande ?? DateTime.now(),
                          dateLivraison: _dateLivraison!,
                          prixTotal: num.parse(_prixTotal.text.trim()),
                          montantPaye: num.parse(_montantPaye.text.trim()),
                          notes: _notes.text.trim().isEmpty
                              ? null
                              : _notes.text.trim(),
                        );

                        Navigator.of(context).pop(result);
                      },
                      style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626)),
                      child: Text(editing ? 'Mettre à jour' : 'Créer'),
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

  Widget _dropdownClient() {
    return DropdownButtonFormField<String>(
      value: _clientId,
      decoration: const InputDecoration(
          border: OutlineInputBorder(), labelText: 'Client *'),
      items: widget.clients
          .map((c) => DropdownMenuItem(
              value: c.id, child: Text('${c.prenom} ${c.nom}')))
          .toList(),
      onChanged: (v) => setState(() => _clientId = v),
      validator: (v) => (v == null || v.isEmpty) ? 'Client obligatoire' : null,
    );
  }

  Widget _dropdownDesign() {
    return DropdownButtonFormField<String>(
      value: _designId,
      decoration: const InputDecoration(
          border: OutlineInputBorder(), labelText: 'Design *'),
      items: widget.designs
          .map((d) => DropdownMenuItem(
              value: d.id, child: Text('${d.nom} (${d.prix} DH)')))
          .toList(),
      onChanged: _onDesignChanged,
      validator: (v) => (v == null || v.isEmpty) ? 'Design obligatoire' : null,
    );
  }

  Widget _dropdownStatut() {
    return DropdownButtonFormField<StatutCommande>(
      value: _statut,
      decoration: const InputDecoration(
          border: OutlineInputBorder(), labelText: 'Statut *'),
      items: const [
        DropdownMenuItem(
            value: StatutCommande.enAttente, child: Text('En attente')),
        DropdownMenuItem(
            value: StatutCommande.enCours, child: Text('En cours')),
        DropdownMenuItem(value: StatutCommande.paye, child: Text('Payé')),
        DropdownMenuItem(
            value: StatutCommande.enCouture, child: Text('En couture')),
        DropdownMenuItem(value: StatutCommande.termine, child: Text('Terminé')),
        DropdownMenuItem(value: StatutCommande.livre, child: Text('Livré')),
      ],
      onChanged: (v) => setState(() => _statut = v ?? StatutCommande.enAttente),
    );
  }

  Widget _dateField() {
    final text = _dateLivraison == null
        ? 'Choisir une date'
        : DateFormat('yyyy-MM-dd').format(_dateLivraison!);

    return InkWell(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Date de livraison *',
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, size: 18),
            const SizedBox(width: 8),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget _numberField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration:
          InputDecoration(border: const OutlineInputBorder(), labelText: label),
      validator: (v) {
        final value = (v ?? '').trim();
        if (value.isEmpty) return 'Champ obligatoire';
        final n = num.tryParse(value);
        if (n == null) return 'Nombre invalide';
        if (n < 0) return 'Doit être positif';
        return null;
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

class _CommandeFormResult {
  const _CommandeFormResult({
    required this.clientId,
    required this.designId,
    required this.statut,
    required this.dateCommande,
    required this.dateLivraison,
    required this.prixTotal,
    required this.montantPaye,
    required this.notes,
  });

  final String clientId;
  final String designId;
  final StatutCommande statut;
  final DateTime dateCommande;
  final DateTime dateLivraison;
  final num prixTotal;
  final num montantPaye;
  final String? notes;
}

class _CommandesData {
  _CommandesData(
      {required this.commandes, required this.clients, required this.designs});

  final List<Commande> commandes;
  final List<Client> clients;
  final List<Design> designs;

  late final Map<String, Client> clientById = {
    for (final c in clients) c.id: c
  };
  late final Map<String, Design> designById = {
    for (final d in designs) d.id: d
  };
}
