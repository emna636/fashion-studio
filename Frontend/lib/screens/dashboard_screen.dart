import 'package:fashion_studio/models/client.dart';
import 'package:fashion_studio/models/commande.dart';
import 'package:fashion_studio/models/design.dart';
import 'package:fashion_studio/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.dataService});

  final DataService dataService;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.dataService.fetchDashboard();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = widget.dataService.fetchDashboard();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.decimalPattern('fr_FR');

    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<DashboardData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Erreur lors du chargement du tableau de bord',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(snapshot.error.toString()),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _refresh,
                  child: const Text('Réessayer'),
                )
              ],
            );
          }

          final data = snapshot.data!;

          final totalRevenu =
              data.commandes.fold<num>(0, (sum, c) => sum + c.prixTotal);
          final totalPaye =
              data.commandes.fold<num>(0, (sum, c) => sum + c.montantPaye);
          final totalEnAttente = totalRevenu - totalPaye;

          final commandesEnCours = data.commandes.where((c) {
            return c.statut == StatutCommande.enCours ||
                c.statut == StatutCommande.enCouture ||
                c.statut == StatutCommande.enAttente;
          }).toList();

          final commandesTerminees = data.commandes.where((c) {
            return c.statut == StatutCommande.termine ||
                c.statut == StatutCommande.livre;
          }).toList();

          final now = DateTime.now();
          final commandesUrgentes = data.commandes.where((c) {
            final diffDays = c.dateLivraison.difference(now).inDays;
            return diffDays <= 7 &&
                diffDays >= 0 &&
                c.statut != StatutCommande.livre;
          }).toList();

          final commandesRecentes = data.commandes.take(4).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Tableau de bord',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                "Vue d'ensemble de votre activité",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              _StatsGrid(
                totalClients: data.clients.length,
                totalDesigns: data.designs.length,
                commandesActives: commandesEnCours.length,
                commandesTerminees: commandesTerminees.length,
                totalPaye: totalPaye,
                totalEnAttente: totalEnAttente,
                money: money,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, c) {
                  final isWide = c.maxWidth >= 900;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _UrgentCard(
                            commandesUrgentes: commandesUrgentes,
                            clients: data.clients,
                            designs: data.designs,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _RecentCard(
                            commandesRecentes: commandesRecentes,
                            clients: data.clients,
                            designs: data.designs,
                            money: money,
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _UrgentCard(
                        commandesUrgentes: commandesUrgentes,
                        clients: data.clients,
                        designs: data.designs,
                      ),
                      const SizedBox(height: 16),
                      _RecentCard(
                        commandesRecentes: commandesRecentes,
                        clients: data.clients,
                        designs: data.designs,
                        money: money,
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.totalClients,
    required this.totalDesigns,
    required this.commandesActives,
    required this.commandesTerminees,
    required this.totalPaye,
    required this.totalEnAttente,
    required this.money,
  });

  final int totalClients;
  final int totalDesigns;
  final int commandesActives;
  final int commandesTerminees;
  final num totalPaye;
  final num totalEnAttente;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final crossAxisCount = c.maxWidth >= 900
            ? 4
            : c.maxWidth >= 600
                ? 2
                : 1;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: crossAxisCount == 1 ? 3.4 : 2.4,
          children: [
            _StatCard(
              title: 'Total Clients',
              value: '$totalClients',
              subtitle: 'Clients enregistrés',
              icon: Icons.group_outlined,
              iconBg: const [Color(0x1ADC2626), Color(0x1AF87171)],
              iconColor: const Color(0xFFDC2626),
            ),
            _StatCard(
              title: 'Designs',
              value: '$totalDesigns',
              subtitle: 'Modèles disponibles',
              icon: Icons.palette_outlined,
              iconBg: const [Color(0x1AFBCFE8), Color(0x1AFEE2E2)],
              iconColor: const Color(0xFFDB2777),
            ),
            _StatCard(
              title: 'Commandes actives',
              value: '$commandesActives',
              subtitle: '$commandesTerminees terminées',
              icon: Icons.shopping_bag_outlined,
              iconBg: const [Color(0x1ADBEAFE), Color(0x1AC7D2FE)],
              iconColor: const Color(0xFF2563EB),
            ),
            _StatCard(
              title: 'Revenus',
              value: '${money.format(totalPaye)} DH',
              subtitle: '${money.format(totalEnAttente)} DH en attente',
              icon: Icons.payments_outlined,
              iconBg: const [Color(0x1AD1FAE5), Color(0x1AA7F3D0)],
              iconColor: const Color(0xFF16A34A),
              gradientText: true,
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.gradientText = false,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final List<Color> iconBg;
  final Color iconColor;
  final bool gradientText;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shadowColor: const Color(0xFFDC2626).withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: const Color(0xFFDC2626).withOpacity(0.10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(colors: iconBg),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  if (gradientText)
                    ShaderMask(
                      shaderCallback: (rect) => const LinearGradient(
                              colors: [Color(0xFFDC2626), Color(0xFFEF4444)])
                          .createShader(rect),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        value,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else
                    Text(
                      value,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UrgentCard extends StatelessWidget {
  const _UrgentCard({
    required this.commandesUrgentes,
    required this.clients,
    required this.designs,
  });

  final List<Commande> commandesUrgentes;
  final List<Client> clients;
  final List<Design> designs;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: Color(0xFFEA580C)),
                const SizedBox(width: 8),
                Text('Livraisons à venir',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 12),
            if (commandesUrgentes.isEmpty)
              Text('Aucune livraison urgente',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey.shade600))
            else
              ...commandesUrgentes.map((commande) {
                final client = clients
                    .where((c) => c.id == commande.clientId)
                    .cast<Client?>()
                    .firstWhere((e) => true, orElse: () => null);
                final design = designs
                    .where((d) => d.id == commande.designId)
                    .cast<Design?>()
                    .firstWhere((e) => true, orElse: () => null);
                final diffDays =
                    commande.dateLivraison.difference(DateTime.now()).inDays;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFEA580C)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${client?.prenom ?? ''} ${client?.nom ?? ''}'
                                  .trim(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(design?.nom ?? '',
                                style: TextStyle(color: Colors.grey.shade700)),
                            const SizedBox(height: 4),
                            Text(
                              'Livraison dans $diffDays jour${diffDays > 1 ? 's' : ''}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFEA580C),
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatutBadge(statut: commande.statut),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({
    required this.commandesRecentes,
    required this.clients,
    required this.designs,
    required this.money,
  });

  final List<Commande> commandesRecentes;
  final List<Client> clients;
  final List<Design> designs;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_bag_outlined,
                    color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Text('Commandes récentes',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 12),
            ...commandesRecentes.map((commande) {
              final client = clients
                  .where((c) => c.id == commande.clientId)
                  .cast<Client?>()
                  .firstWhere((e) => true, orElse: () => null);
              final design = designs
                  .where((d) => d.id == commande.designId)
                  .cast<Design?>()
                  .firstWhere((e) => true, orElse: () => null);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${client?.prenom ?? ''} ${client?.nom ?? ''}'
                                .trim(),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(design?.nom ?? '',
                              style: TextStyle(color: Colors.grey.shade700)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              StatutBadge(statut: commande.statut),
                              if (commande.resteAPayer > 0)
                                Text(
                                  'Reste: ${money.format(commande.resteAPayer)} DH',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFDC2626),
                                      fontWeight: FontWeight.w600),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${money.format(commande.prixTotal)} DH',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('yyyy-MM-dd')
                              .format(commande.dateLivraison),
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
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
        color: info.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        info.label,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: info.fg),
      ),
    );
  }
}
