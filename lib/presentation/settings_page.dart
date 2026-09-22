import 'package:flutter/material.dart';

import '../data/settings_repository.dart';
import '../domain/models/cost_defaults.dart';
import 'formatters.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, this.repository});

  final SettingsRepository? repository;

  @override
  Widget build(BuildContext context) {
    final settingsRepository = repository ?? SettingsRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: FutureBuilder<CostDefaults>(
        future: settingsRepository.getCostDefaults(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Não foi possível carregar as configurações.'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _CostDefaultsForm(
            defaults: snapshot.data!,
            repository: settingsRepository,
          );
        },
      ),
    );
  }
}

class _CostDefaultsForm extends StatefulWidget {
  const _CostDefaultsForm({required this.defaults, required this.repository});

  final CostDefaults defaults;
  final SettingsRepository repository;

  @override
  State<_CostDefaultsForm> createState() => _CostDefaultsFormState();
}

class _CostDefaultsFormState extends State<_CostDefaultsForm> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  bool _isSaving = false;

  static const _labels = {
    'packaging': 'Embalagem por bala',
    'label': 'Etiqueta por bala',
    'labor': 'Mão de obra por bala',
    'fixed': 'Custo fixo por bala',
  };

  @override
  void initState() {
    super.initState();
    final defaults = widget.defaults.toMap();
    _controllers = {
      for (final entry in _labels.entries)
        entry.key: TextEditingController(
          text: defaults[entry.key] == 0
              ? ''
              : formatCurrency(defaults[entry.key]!),
        ),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    try {
      await widget.repository.saveCostDefaults(
        CostDefaults(
          packagingCents:
              parseCurrencyToCents(_controllers['packaging']!.text) ?? 0,
          labelCents: parseCurrencyToCents(_controllers['label']!.text) ?? 0,
          laborCents: parseCurrencyToCents(_controllers['labor']!.text) ?? 0,
          fixedCents: parseCurrencyToCents(_controllers['fixed']!.text) ?? 0,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Custos padrão salvos.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Não foi possível salvar as configurações.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Custos padrão por bala',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            const Text(
              'Eles serão sugeridos ao finalizar uma produção e poderão ser alterados naquele momento.',
            ),
            const SizedBox(height: 24),
            ..._labels.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: TextFormField(
                  controller: _controllers[entry.key],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: entry.value,
                    prefixText: 'R\$ ',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value == null ||
                          value.trim().isEmpty ||
                          parseCurrencyToCents(value) != null
                      ? null
                      : 'Informe um valor válido.',
                ),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar custos padrão'),
            ),
          ],
        ),
      ),
    );
  }
}
