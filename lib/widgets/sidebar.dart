import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';

class Sidebar extends StatelessWidget {
  final bool dark;
  final String lang;
  const Sidebar({super.key, required this.dark, required this.lang});

  static const _plantTypes = [
    'Solar PV', 'Wind Turbine', 'Hydropower', 'Gas Turbine', 'Nuclear'
  ];

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Container(
      width: 252,
      decoration: BoxDecoration(
        color: AppTheme.bgOf(dark),
        border: Border(right: BorderSide(color: AppTheme.borderOf(dark))),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(Tr.t('plantConfig', lang), dark),

            _FieldLabel(Tr.t('plantType', lang), dark),
            const SizedBox(height: 5),
            _Dropdown(
              value: s.plantType,
              items: _plantTypes,
              dark: dark,
              onChanged: context.read<AppState>().setPlantType,
            ),
            const SizedBox(height: 12),

            _FieldLabel('${Tr.t('capacity', lang)} (${s.unit})', dark),
            const SizedBox(height: 5),
            _NumberInput(
              value: s.capacity, dark: dark,
              onChanged: context.read<AppState>().setCapacity,
            ),
            const SizedBox(height: 12),

            _FieldLabel(Tr.t('numUnits', lang), dark),
            const SizedBox(height: 5),
            _SliderRow(
              value: s.units, min: 1, max: 20,
              label: s.units.round().toString(),
              dark: dark,
              onChanged: context.read<AppState>().setUnits,
            ),
            const SizedBox(height: 12),

            _FieldLabel('${Tr.t('efficiency', lang)} (%)', dark),
            const SizedBox(height: 5),
            _SliderRow(
              value: s.efficiency, min: 20, max: 99,
              label: '${s.efficiency.round()}%',
              dark: dark,
              onChanged: context.read<AppState>().setEfficiency,
            ),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: context.read<AppState>().addPlantGroup,
                icon: Icon(Icons.add, size: 16, color: AppTheme.txOf(dark)),
                label: Text(Tr.t('addPlant', lang),
                    style: AppTheme.label(dark).copyWith(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: BorderSide(color: AppTheme.border2Of(dark)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.r)),
                  backgroundColor: AppTheme.bgOf(dark),
                ),
              ),
            ),

            if (s.plantGroups.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...s.plantGroups.asMap().entries.map((e) =>
                  _PlantRow(plant: e.value, index: e.key, dark: dark)),
            ],

            const SizedBox(height: 24),
            _SectionLabel(Tr.t('computedOutput', lang), dark),
            _StatPill(Tr.t('totalCap', lang),
                '${_fmt(s.totalCapacity)} ${s.unit}', dark),
            _StatPill(Tr.t('expectedOut', lang),
                '${_fmt(s.expectedOutput)} ${s.unit}', dark),
            _StatPill(Tr.t('loadFactor', lang),
                '${s.efficiency.round()}%', dark),
          ],
        ),
      ),
    );
  }

  String _fmt(int v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toString();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text; final bool dark;
  const _SectionLabel(this.text, this.dark);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: Text(text.toUpperCase(), style: AppTheme.sectionLabel(dark)),
  );
}

class _FieldLabel extends StatelessWidget {
  final String text; final bool dark;
  const _FieldLabel(this.text, this.dark);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTheme.label(dark).copyWith(fontSize: 13));
}

class _Dropdown extends StatelessWidget {
  final String value; final List<String> items;
  final bool dark; final ValueChanged<String> onChanged;
  const _Dropdown({required this.value, required this.items,
    required this.dark, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 11),
    decoration: BoxDecoration(
      color: AppTheme.bgOf(dark),
      border: Border.all(color: AppTheme.border2Of(dark)),
      borderRadius: BorderRadius.circular(AppTheme.r),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value, isExpanded: true,
        dropdownColor: AppTheme.bgOf(dark),
        style: AppTheme.label(dark).copyWith(fontSize: 14),
        items: items.map((e) =>
            DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    ),
  );
}

class _NumberInput extends StatelessWidget {
  final double value; final bool dark; final ValueChanged<double> onChanged;
  const _NumberInput({required this.value, required this.dark,
    required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppTheme.bgOf(dark),
      border: Border.all(color: AppTheme.border2Of(dark)),
      borderRadius: BorderRadius.circular(AppTheme.r),
    ),
    child: TextField(
      controller: TextEditingController(text: value.round().toString()),
      keyboardType: TextInputType.number,
      style: AppTheme.label(dark).copyWith(fontSize: 14),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        border: InputBorder.none,
      ),
      onSubmitted: (v) {
        final p = double.tryParse(v);
        if (p != null) onChanged(p);
      },
    ),
  );
}

class _SliderRow extends StatelessWidget {
  final double value, min, max; final String label;
  final bool dark; final ValueChanged<double> onChanged;
  const _SliderRow({required this.value, required this.min,
    required this.max, required this.label, required this.dark,
    required this.onChanged});
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: AppTheme.green,
          thumbColor: AppTheme.green,
          inactiveTrackColor: AppTheme.border2Of(dark),
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        ),
        child: Slider(
          value: value.clamp(min, max), min: min, max: max,
          divisions: (max - min).round(), onChanged: onChanged,
        ),
      ),
    ),
    SizedBox(
      width: 38,
      child: Text(label, textAlign: TextAlign.right,
          style: AppTheme.label(dark).copyWith(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: AppTheme.green)),
    ),
  ]);
}

class _StatPill extends StatelessWidget {
  final String label, value; final bool dark;
  const _StatPill(this.label, this.value, this.dark);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 7),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: AppTheme.pill(dark),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: AppTheme.label(dark)
          .copyWith(fontSize: 13, color: AppTheme.greenDark)),
      Text(value, style: AppTheme.label(dark).copyWith(
          fontSize: 13, fontWeight: FontWeight.w700,
          color: AppTheme.greenDark)),
    ]),
  );
}

class _PlantRow extends StatelessWidget {
  final Map<String, dynamic> plant; final int index; final bool dark;
  const _PlantRow({required this.plant, required this.index,
    required this.dark});
  @override
  Widget build(BuildContext context) {
    final total = ((plant['capacity'] as double) *
        (plant['units'] as double)).round();
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.bg2Of(dark),
        borderRadius: BorderRadius.circular(AppTheme.r),
      ),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plant['type'], style: AppTheme.label(dark)
                .copyWith(fontSize: 12, fontWeight: FontWeight.w500)),
            Text('${(plant['capacity'] as double).round()} MW'
                ' × ${(plant['units'] as double).round()}',
                style: AppTheme.small(dark).copyWith(fontSize: 11)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: AppTheme.greenBgOf(dark),
              borderRadius: BorderRadius.circular(99)),
          child: Text('$total MW', style: AppTheme.label(dark).copyWith(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: AppTheme.greenDark)),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => context.read<AppState>().removePlantGroup(index),
          child: Icon(Icons.close, size: 14,
              color: AppTheme.tx2Of(dark)),
        ),
      ]),
    );
  }
}