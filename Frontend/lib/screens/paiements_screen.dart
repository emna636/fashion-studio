import 'package:fashion_studio/models/client.dart';
import 'package:fashion_studio/models/commande.dart';
import 'package:fashion_studio/models/design.dart';
import 'package:fashion_studio/models/paiement.dart';
import 'package:fashion_studio/services/clients_service.dart';
import 'package:fashion_studio/services/commandes_service.dart';
import 'package:fashion_studio/services/designs_service.dart';
import 'package:fashion_studio/services/paiements_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaiementsScreen extends StatefulWidget {
  const PaiementsScreen({
    super.key,
    required this.paiementsService,
    required this.commandesService,
    required this.clientsService,
    required this.designsService,
  });

  final PaiementsService paiementsService;
  final CommandesService commandesService;
  final ClientsService clientsService;
  final DesignsService designsService;

  @override
  State<PaiementsScreen> createState() => _PaiementsScreenState();
}

class _PaiementsScreenState extends State<PaiementsScreen> {
  late Future<_PaiementsData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_PaiementsData> _load() async {
    final results = await Future.wait([
      widget.paiementsService.list(),
      widget.commandesService.list(),
      widget.clientsService.list(),
      widget.designsService.list(),
    ]);

    return _PaiementsData(
      paiements: results[0] as List<Paiement>,
      commandes: results[1] as List<Commande>,
      clients: results[2] as List<Client>,
      designs: results[3] as List<Design>,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _openNewPaiement(_PaiementsData data) async {
    final result = await showDialog<_NewPaiementResult>(
      context: context,
      builder: (context) => _NewPaiementDialog(data: data),
    );

    if (!mounted) return;

    if (result == null) return;

    final cmd = data.commandeById[result.commandeId];
    if (cmd == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Commande introuvable')));
      return;
    }

    final reste = cmd.resteAPayer;
    if (result.montant > reste) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Le montant ne peut pas dépasser ${NumberFormat.decimalPattern('fr_FR').format(reste)} DH',
          ),
        ),
      );
      return;
    }

    final paiement = Paiement(
      id: 'TEMP',
      commandeId: result.commandeId,
      montant: result.montant,
      methodePaiement: result.methodePaiement,
      notes: result.notes,
      datePaiement: result.datePaiement,
      createdAt: DateTime.now(),
    );

    try {
      await widget.paiementsService.create(paiement);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paiement enregistré avec succès')));
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
      child: FutureBuilder<_PaiementsData>(
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
          final total =
              data.paiements.fold<num>(0, (sum, p) => sum + p.montant);

          final grouped = <String, List<Paiement>>{};
          for (final p in data.paiements) {
            (grouped[p.commandeId] ??= []).add(p);
          }

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
                        Text('Paiements',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(
                          'Total encaissé : ${money.format(total)} DH',
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
                    onPressed: () => _openNewPaiement(data),
                    icon: const Icon(Icons.add),
                    label: const Text('Nouveau paiement'),
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (data.paiements.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 44, horizontal: 16),
                    child: Column(
                      children: [
                        Icon(Icons.credit_card,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 14),
                        Text(
                          'Aucun paiement enregistré. Enregistrez votre premier paiement !',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey.shade700),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...data.commandes.map((cmd) {
                  final list = grouped[cmd.id];
                  if (list == null || list.isEmpty)
                    return const SizedBox.shrink();

                  final client = data.clientById[cmd.clientId];
                  final design = data.designById[cmd.designId];
                  final reste = cmd.resteAPayer;

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
                                    Text(
                                      '${client?.prenom ?? ''} ${client?.nom ?? ''}'
                                          .trim(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w900),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(design?.nom ?? '',
                                        style: TextStyle(
                                            color: Colors.grey.shade700)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Prix total',
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12)),
                                  Text(
                                    '${money.format(cmd.prixTotal)} DH',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 2),
                                  if (reste > 0)
                                    Text(
                                      'Reste: ${money.format(reste)} DH',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFDC2626),
                                          fontWeight: FontWeight.w700),
                                    )
                                  else
                                    const Text(
                                      'Payé intégralement',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF16A34A),
                                          fontWeight: FontWeight.w700),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...list.map(
                              (p) => _PaiementRow(paiement: p, money: money)),
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

class _PaiementRow extends StatelessWidget {
  const _PaiementRow({required this.paiement, required this.money});

  final Paiement paiement;
  final NumberFormat money;

  String _methodeLabel(String m) {
    switch (m.toUpperCase()) {
      case 'ESPECES':
        return 'Espèces';
      case 'CARTE':
        return 'Carte bancaire';
      case 'VIREMENT':
        return 'Virement';
      default:
        return 'Autre';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.credit_card, color: Color(0xFF16A34A)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${money.format(paiement.montant)} DH',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF14532D)),
                      ),
                    ),
                    Text(
                      _methodeLabel(paiement.methodePaiement),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('yyyy-MM-dd').format(paiement.datePaiement),
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ],
                ),
                if (paiement.notes != null &&
                    paiement.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(paiement.notes!,
                      style: TextStyle(color: Colors.grey.shade700)),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewPaiementDialog extends StatefulWidget {
  const _NewPaiementDialog({required this.data});

  final _PaiementsData data;

  @override
  State<_NewPaiementDialog> createState() => _NewPaiementDialogState();
}

class _NewPaiementDialogState extends State<_NewPaiementDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _commandeId;
  String _methode = 'ESPECES';
  final _montant = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _montant.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _onCommandeChanged(String? id) {
    setState(() {
      _commandeId = id;
      if (id == null) return;
      final cmd = widget.data.commandeById[id];
      if (cmd == null) return;
      final reste = cmd.resteAPayer;
      _montant.text = reste.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.decimalPattern('fr_FR');

    final unpaid = widget.data.commandes
        .where((c) => c.montantPaye < c.prixTotal)
        .toList();

    final resteText = () {
      if (_commandeId == null) return null;
      final cmd = widget.data.commandeById[_commandeId!];
      if (cmd == null) return null;
      return 'Reste à payer: ${money.format(cmd.resteAPayer)} DH';
    }();

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enregistrer un paiement',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _commandeId,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Commande *'),
                  items: unpaid.map((cmd) {
                    final client = widget.data.clientById[cmd.clientId];
                    final design = widget.data.designById[cmd.designId];
                    final reste = cmd.resteAPayer;
                    final label =
                        '${client?.prenom ?? ''} ${client?.nom ?? ''} - ${design?.nom ?? ''} (Reste: ${money.format(reste)} DH)';
                    return DropdownMenuItem(
                        value: cmd.id,
                        child: Text(label, overflow: TextOverflow.ellipsis));
                  }).toList(),
                  onChanged: _onCommandeChanged,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Commande obligatoire' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _montant,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Montant (DH) *'),
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'Montant obligatoire';
                    final n = num.tryParse(value);
                    if (n == null) return 'Nombre invalide';
                    if (n < 0) return 'Doit être positif';
                    return null;
                  },
                ),
                if (resteText != null) ...[
                  const SizedBox(height: 6),
                  Text(resteText,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _methode,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Méthode de paiement *'),
                  items: const [
                    DropdownMenuItem(value: 'ESPECES', child: Text('Espèces')),
                    DropdownMenuItem(
                        value: 'CARTE', child: Text('Carte bancaire')),
                    DropdownMenuItem(
                        value: 'VIREMENT', child: Text('Virement')),
                    DropdownMenuItem(value: 'AUTRE', child: Text('Autre')),
                  ],
                  onChanged: (v) => setState(() => _methode = v ?? 'ESPECES'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notes,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Notes',
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
                        final montant = num.parse(_montant.text.trim());
                        Navigator.of(context).pop(
                          _NewPaiementResult(
                            commandeId: _commandeId!,
                            montant: montant,
                            methodePaiement: _methode,
                            notes: _notes.text.trim().isEmpty
                                ? null
                                : _notes.text.trim(),
                            datePaiement: DateTime.now(),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626)),
                      child: const Text('Enregistrer'),
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
}

class _NewPaiementResult {
  const _NewPaiementResult({
    required this.commandeId,
    required this.montant,
    required this.methodePaiement,
    required this.notes,
    required this.datePaiement,
  });

  final String commandeId;
  final num montant;
  final String methodePaiement;
  final String? notes;
  final DateTime datePaiement;
}

class _PaiementsData {
  _PaiementsData(
      {required this.paiements,
      required this.commandes,
      required this.clients,
      required this.designs});

  final List<Paiement> paiements;
  final List<Commande> commandes;
  final List<Client> clients;
  final List<Design> designs;

  late final Map<String, Commande> commandeById = {
    for (final c in commandes) c.id: c
  };
  late final Map<String, Client> clientById = {
    for (final c in clients) c.id: c
  };
  late final Map<String, Design> designById = {
    for (final d in designs) d.id: d
  };
}
