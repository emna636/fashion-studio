import 'dart:typed_data';

import 'package:fashion_studio/models/design.dart';
import 'package:fashion_studio/services/designs_service.dart';
import 'package:fashion_studio/services/supabase_storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DesignsScreen extends StatefulWidget {
  const DesignsScreen({super.key, required this.designsService});

  final DesignsService designsService;

  @override
  State<DesignsScreen> createState() => _DesignsScreenState();
}

class _DesignsScreenState extends State<DesignsScreen> {
  late Future<List<Design>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.designsService.list();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = widget.designsService.list();
    });
    await _future;
  }

  Future<void> _openEditor({Design? editing}) async {
    final result = await showDialog<_DesignFormResult>(
      context: context,
      builder: (context) => _DesignEditorDialog(editing: editing),
    );

    if (result == null) return;

    String imageUrl;
    if (result.imageBytes != null && result.imageFilename != null) {
      final storage = SupabaseStorageService.fromDartDefines();
      imageUrl = await storage.uploadDesignImage(
        bytes: result.imageBytes!,
        filename: result.imageFilename!,
        contentType: result.imageContentType,
      );
    } else if (editing != null && editing.imageUrl.trim().isNotEmpty) {
      imageUrl = editing.imageUrl;
    } else {
      imageUrl =
          'https://images.unsplash.com/photo-1558769132-cb1aea1f0b09?w=800';
    }

    final design = Design(
      id: editing?.id ?? 'TEMP',
      nom: result.nom,
      description: result.description,
      type: result.type,
      prix: result.prix,
      imageUrl: imageUrl,
      createdAt: editing?.createdAt ?? DateTime.now(),
    );

    try {
      if (editing == null) {
        await widget.designsService.create(design);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Design ajouté avec succès')));
      } else {
        await widget.designsService.update(editing.id, design);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Design mis à jour avec succès')));
      }
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> _delete(Design design) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le design'),
          content: Text(
              'Êtes-vous sûr de vouloir supprimer le design "${design.nom}" ?'),
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
      await widget.designsService.delete(design.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Design supprimé')));
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
      child: FutureBuilder<List<Design>>(
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

          final designs = snapshot.data ?? const <Design>[];
          final count = designs.length;

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
                            Text('Designs',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            Text(
                              '$count modèle${count > 1 ? 's' : ''} disponible${count > 1 ? 's' : ''}',
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
                        label: const Text('Nouveau design'),
                        style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (designs.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 44, horizontal: 16),
                        child: Column(
                          children: [
                            Icon(Icons.image_outlined,
                                size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 14),
                            Text(
                              'Aucun design enregistré. Ajoutez votre premier design !',
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
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: crossAxisCount == 1 ? 1.15 : 0.92,
                      ),
                      itemCount: designs.length,
                      itemBuilder: (context, i) {
                        final design = designs[i];
                        return _DesignCard(
                          design: design,
                          money: money,
                          onEdit: () => _openEditor(editing: design),
                          onDelete: () => _delete(design),
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

class _DesignCard extends StatelessWidget {
  const _DesignCard(
      {required this.design,
      required this.money,
      required this.onEdit,
      required this.onDelete});

  final Design design;
  final NumberFormat money;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('yyyy-MM-dd').format(design.createdAt);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 10,
      shadowColor: const Color(0xFFDC2626).withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: const Color(0xFFDC2626).withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  design.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) {
                    return Container(
                      color: const Color(0xFFF3F4F6),
                      child: Icon(Icons.image_not_supported_outlined,
                          color: Colors.grey.shade400),
                    );
                  },
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.90),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      design.type,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFDC2626)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            design.nom,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined,
                              color: Color(0xFFDC2626)),
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
                    const SizedBox(height: 6),
                    ShaderMask(
                      shaderCallback: (rect) => const LinearGradient(
                              colors: [Color(0xFFDC2626), Color(0xFFEF4444)])
                          .createShader(rect),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        '${money.format(design.prix)} DH',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      design.description,
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Créé le $date',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesignEditorDialog extends StatefulWidget {
  const _DesignEditorDialog({this.editing});

  final Design? editing;

  @override
  State<_DesignEditorDialog> createState() => _DesignEditorDialogState();
}

class _DesignEditorDialogState extends State<_DesignEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  static const _types = [
    (value: 'robe', label: 'Robe'),
    (value: 'blouse', label: 'Blouse'),
    (value: 'pantalon', label: 'Pantalon'),
    (value: 'jupe', label: 'Jupe'),
    (value: 'veste', label: 'Veste'),
    (value: 'ensemble', label: 'Ensemble'),
    (value: 'autre', label: 'Autre'),
  ];

  late final TextEditingController _nom;
  late final TextEditingController _prix;
  late final TextEditingController _description;
  String _type = 'robe';

  Uint8List? _pickedBytes;
  String? _pickedFilename;
  String? _pickedContentType;

  @override
  void initState() {
    super.initState();
    final d = widget.editing;
    _nom = TextEditingController(text: d?.nom ?? '');
    _prix = TextEditingController(text: d?.prix.toString() ?? '');
    _description = TextEditingController(text: d?.description ?? '');
    _type = d?.type ?? 'robe';
  }

  @override
  void dispose() {
    _nom.dispose();
    _prix.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: false,
    );
    if (res == null || res.files.isEmpty) return;

    final f = res.files.first;
    if (f.bytes == null) return;

    String? contentType;
    final ext = (f.extension ?? '').toLowerCase();
    if (ext == 'jpg' || ext == 'jpeg') {
      contentType = 'image/jpeg';
    } else if (ext == 'png') {
      contentType = 'image/png';
    } else if (ext == 'webp') {
      contentType = 'image/webp';
    }

    setState(() {
      _pickedBytes = f.bytes;
      _pickedFilename = f.name;
      _pickedContentType = contentType;
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
                  editing ? 'Modifier le design' : 'Nouveau design',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                Text('Nom du design *',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nom,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Ex: Robe de soirée élégante',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nom obligatoire'
                      : null,
                ),
                const SizedBox(height: 12),
                _TwoCols(
                  left: DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Type *'),
                    items: _types
                        .map((t) => DropdownMenuItem(
                            value: t.value, child: Text(t.label)))
                        .toList(),
                    onChanged: (v) => setState(() => _type = v ?? 'robe'),
                  ),
                  right: TextFormField(
                    controller: _prix,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Prix (DH) *'),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'Prix obligatoire';
                      final n = num.tryParse(value);
                      if (n == null) return 'Nombre invalide';
                      if (n < 0) return 'Doit être positif';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text('Description',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _description,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Décrivez le design...'),
                ),
                const SizedBox(height: 12),
                Text("Photo",
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(_pickedFilename == null
                      ? 'Importer une photo'
                      : 'Photo: $_pickedFilename'),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.editing == null
                      ? 'Si tu ne choisis pas de photo, une image par défaut sera utilisée.'
                      : 'Si tu ne choisis pas de nouvelle photo, on garde l\'image actuelle.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey.shade600),
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
                        Navigator.of(context).pop(
                          _DesignFormResult(
                            nom: _nom.text.trim(),
                            type: _type,
                            description: _description.text.trim(),
                            imageBytes: _pickedBytes,
                            imageFilename: _pickedFilename,
                            imageContentType: _pickedContentType,
                            prix: num.parse(_prix.text.trim()),
                          ),
                        );
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

class _DesignFormResult {
  const _DesignFormResult({
    required this.nom,
    required this.type,
    required this.description,
    required this.imageBytes,
    required this.imageFilename,
    required this.imageContentType,
    required this.prix,
  });

  final String nom;
  final String type;
  final String description;
  final Uint8List? imageBytes;
  final String? imageFilename;
  final String? imageContentType;
  final num prix;
}
