// lib/features/calculator/presentation/calculator_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../models/apartment.dart';
import '../../../models/expense.dart';
import '../../../models/building.dart';
import '../../../services/calculation_service.dart';
import 'package:koinoxrista/services/hive_save_service.dart';
import 'package:koinoxrista/features/calculator/presentation/result_page.dart';





// ─────────────────── Riverpod ­state ───────────────────

class ExpenseState {
  final double fixed, extra, elevator, heating;
  const ExpenseState({this.fixed = 0, this.extra = 0, this.elevator = 0, this.heating = 0});

  Expense toExpense() => Expense(fixed: fixed, extra: extra, elevator: elevator, heating: heating);

  ExpenseState copyWith({double? fixed, double? extra, double? elevator, double? heating}) =>
      ExpenseState(
        fixed: fixed ?? this.fixed,
        extra: extra ?? this.extra,
        elevator: elevator ?? this.elevator,
        heating: heating ?? this.heating,
      );
}

class ExpenseNotifier extends StateNotifier<ExpenseState> {
  ExpenseNotifier() : super(const ExpenseState());
  double _d(String v) => double.tryParse(v.replaceAll(',', '.')) ?? 0;
  void _set(ExpenseState s) => state = s;

  void updateFixed(String v)    => _set(state.copyWith(fixed:    _d(v)));
  void updateExtra(String v)    => _set(state.copyWith(extra:    _d(v)));
  void updateElevator(String v) => _set(state.copyWith(elevator: _d(v)));
  void updateHeating(String v)  => _set(state.copyWith(heating:  _d(v)));

  void setFromExpense(Expense e) =>
      _set(ExpenseState(fixed: e.fixed, extra: e.extra, elevator: e.elevator, heating: e.heating));
}
final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>((ref) => ExpenseNotifier());

class ApartmentsNotifier extends StateNotifier<List<Apartment>> {
  ApartmentsNotifier() : super([const Apartment(id: 1, area: 0, floor: 0)]);

  void setCount(int count) {
    if (count < 1) return;
    state = List.generate(count, (i) => i < state.length ? state[i] : Apartment(id: i + 1, area: 0, floor: 0));
  }
  void updateArea(int id, String v)    => _r(id, area: double.tryParse(v.replaceAll(',', '.')) ?? 0);
  void updateFloor(int id, String v)   => _r(id, floor: int.tryParse(v) ?? 0);
  void toggleElevator(int id)          => _r(id, elevatorExcluded: !state.firstWhere((a) => a.id == id).elevatorExcluded);

  void _r(int id,{double? area,int? floor,bool? elevatorExcluded}) =>
    state = [for (final a in state) if (a.id == id) Apartment(id:a.id,area: area??a.area,floor: floor??a.floor,elevatorExcluded: elevatorExcluded??a.elevatorExcluded) else a];

  void setFromList(List<Apartment> apartments)=> state = apartments;
}
final apartmentsProvider = StateNotifierProvider<ApartmentsNotifier, List<Apartment>>((ref)=>ApartmentsNotifier());

// ─────────────────── UI ───────────────────

class CalculatorPage extends ConsumerWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Υπολογισμός Κοινοχρήστων')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: wide
              ? Row(children: const [
                  Expanded(child: _FormBlock()),
                  VerticalDivider(width: 1),
                  Expanded(child: _PreviewBlock()),
                ])
              : const _FormBlock(),
        ),
      ),
    );
  }
}

// ─────────────────── Form block ───────────────────

class _FormBlock extends ConsumerStatefulWidget {
  const _FormBlock({super.key});
  @override ConsumerState<_FormBlock> createState() => _FormBlockState();
}

class _FormBlockState extends ConsumerState<_FormBlock> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _countCtrl;

  @override
  void initState() {
    super.initState();
    _countCtrl = TextEditingController(text: ref.read(apartmentsProvider).length.toString());
  }

  @override
  Widget build(BuildContext context) {
    final apartments = ref.watch(apartmentsProvider);
    final expense     = ref.watch(expenseProvider);
    final box         = Hive.box('koinoxrista');
    final saver       = HiveSaveService(box);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _countCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Πλήθος διαμερισμάτων', border: OutlineInputBorder()),
            onChanged: (v)=>ref.read(apartmentsProvider.notifier).setCount(int.tryParse(v)??1),
            validator: (v)=> (int.tryParse(v??'')??0) < 1 ? 'Δώσε ≥1' : null,
          ),
          const SizedBox(height: 16),
          _apartmentsList(context, apartments),
          const Divider(height: 32),
          _expensesSection(expense),
          const SizedBox(height: 24),
          Center(
            child: FilledButton.icon(
              icon: const Icon(Icons.calculate_outlined), label: const Text('ΥΠΟΛΟΓΙΣΜΟΣ'),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Συμπληρώστε σωστά όλα τα πεδία.')));
                  return;
                }
                final building = Building(apartments: apartments, expense: expense.toExpense());
                final results  = CalculationService().calculateShares(building);

                await saver.save(building, results);          // ➕ save last
                if (!mounted) return;
                Navigator.push(context, MaterialPageRoute(builder: (_) => ResultPage(results: results)));
              },
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.history), label: const Text('Επαναφόρτωση τελευταίου'),
              onPressed: () {
                final b = saver.loadBuilding();
                final r = saver.loadResults();
                if (b == null || r == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Δεν βρέθηκε προηγούμενος υπολογισμός.')));
                  return;
                }
                ref.read(apartmentsProvider.notifier).setFromList(b.apartments);
                ref.read(expenseProvider.notifier).setFromExpense(b.expense);
                _countCtrl.text = b.apartments.length.toString();
                Navigator.push(context, MaterialPageRoute(builder: (_) => ResultPage(results: r)));
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------- helpers ----------

  Widget _apartmentsList(BuildContext context, List<Apartment> apartments) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: apartments.length,
      separatorBuilder: (_, __)=>const SizedBox(height:8),
      itemBuilder:(context,i){
        final a=apartments[i];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children:[
              Text('Δ${a.id}', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(width:8),
              Expanded(child:_fld(initial:a.area==0?'':a.area.toStringAsFixed(0), label:'m²',
                onChanged:(v)=>ref.read(apartmentsProvider.notifier).updateArea(a.id,v),
                validator:(v){final d=double.tryParse(v!.replaceAll(',','.'));return (d==null||d<=0)?'>':null;},)),
              const SizedBox(width:8),
              SizedBox(width:70,child:_fld(initial:a.floor==0?'':a.floor.toString(), label:'Όροφος',
                onChanged:(v)=>ref.read(apartmentsProvider.notifier).updateFloor(a.id,v))),
              const SizedBox(width:8),
              Column(children:[const Text('Εξ. Ανελκ.'),Checkbox(
                value:a.elevatorExcluded,
                onChanged:(_)=>ref.read(apartmentsProvider.notifier).toggleElevator(a.id))]),
            ]),
          ),
        );
      },
    );
  }

  Widget _expensesSection(ExpenseState e) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children:[
      Text('Έξοδα', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.bold)),
      const SizedBox(height:8),
      Row(children:[
        _numField('Πάγια €',  e.fixed,    ref.read(expenseProvider.notifier).updateFixed),
        const SizedBox(width:8),
        _numField('Έκτακτα €',e.extra,    ref.read(expenseProvider.notifier).updateExtra),
      ]),
      const SizedBox(height:8),
      Row(children:[
        _numField('Ανελκ. €', e.elevator, ref.read(expenseProvider.notifier).updateElevator),
        const SizedBox(width:8),
        _numField('Θέρμανση €',e.heating, ref.read(expenseProvider.notifier).updateHeating),
      ]),
    ],
  );

  Widget _numField(String label,double val,Function(String) onCh) => Expanded(child:_fld(
        initial: val==0?'':val.toStringAsFixed(0),
        label:label,onChanged:onCh,
        validator:(v)=> v!.isNotEmpty && double.tryParse(v.replaceAll(',','.'))==null ? 'Ν' : null));

  Widget _fld({required String initial,required String label,required ValueChanged<String> onChanged,String? Function(String?)? validator}) =>
      TextFormField(
        initialValue:initial,
        decoration: InputDecoration(labelText:label,border: const OutlineInputBorder()),
        keyboardType: const TextInputType.numberWithOptions(decimal:true),
        onChanged:onChanged,
        validator:validator,
      );
}

// ─────────────────── Preview block ───────────────────

class _PreviewBlock extends ConsumerWidget {
  const _PreviewBlock({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref){
    final apts=ref.watch(apartmentsProvider);
    final e=ref.watch(expenseProvider);
    final total= e.fixed+e.extra+e.elevator+e.heating;

    return ListView(
      padding:const EdgeInsets.all(16),
      children:[
        Text('Σύνοψη',style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.bold)),
        const SizedBox(height:12),
        ListTile(leading:const Icon(Icons.home_work_outlined),title:const Text('Διαμερίσματα'),trailing:Text('${apts.length}')),
        ListTile(leading:const Icon(Icons.euro_outlined),title:const Text('Σύνολο εξόδων'),trailing:Text(total.toStringAsFixed(2))),
        const SizedBox(height:24),
        const Text('Συμπληρώστε/διορθώστε τα στοιχεία αριστερά και πατήστε \"ΥΠΟΛΟΓΙΣΜΟΣ\" 👈',
            style:TextStyle(fontStyle:FontStyle.italic)),
      ],
    );
  }
}
