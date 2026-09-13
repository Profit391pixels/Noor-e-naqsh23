
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../utils/safe_calc.dart';

class ThaanScreen extends StatefulWidget {
  const ThaanScreen({super.key});
  @override
  State<ThaanScreen> createState() => _ThaanScreenState();
}

class _ThaanScreenState extends State<ThaanScreen> {
  final _svc = FirestoreService();
  void _openForm({String? id, Map<String,dynamic>? m}){
    final dateCtrl = TextEditingController(text: m?['date']?? DateTime.now().toIso8601String().substring(0,10));
    final partyCtrl = TextEditingController(text: m?['partyName']??'');
    final patiCtrl = TextEditingController(text: m?['totalPati']?.toString()??'');
    final cutCtrl = TextEditingController(text: m?['cuttingExpenses']?.toString()??'');
    final dyeCtrl = TextEditingController(text: m?['dyeingExpenses']?.toString()??'');
    final paperCtrl = TextEditingController(text: m?['paperExpense']?.toString()??'');
    final remarksCtrl = TextEditingController(text: m?['remarks']??'');
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: const Color(0xFFfdfbf7), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_){
      return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(_).viewInsets.bottom, left: 16, right: 16, top: 16), child: SingleChildScrollView(child: Column(children: [
        const Text('Thaan Entry / تھان', style: TextStyle(fontWeight: FontWeight.w900)),
        TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date')),
        TextField(controller: partyCtrl, decoration: const InputDecoration(labelText: 'Party Name')),
        TextField(controller: patiCtrl, decoration: const InputDecoration(labelText: 'Total Pati / کل پٹی')),
        TextField(controller: cutCtrl, decoration: const InputDecoration(labelText: 'Cutting Expenses')),
        TextField(controller: dyeCtrl, decoration: const InputDecoration(labelText: 'Dyeing Expenses')),
        TextField(controller: paperCtrl, decoration: const InputDecoration(labelText: 'Paper Expense')),
        TextField(controller: remarksCtrl, decoration: const InputDecoration(labelText: 'Remarks'), maxLines: 2),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async {
          var data = {
            'date': dateCtrl.text,
            'partyName': partyCtrl.text,
            'totalPati': SafeCalc.calc(patiCtrl.text),
            'cuttingExpenses': SafeCalc.calc(cutCtrl.text),
            'dyeingExpenses': SafeCalc.calc(dyeCtrl.text),
            'paperExpense': SafeCalc.calc(paperCtrl.text),
            'totalExpenses': SafeCalc.calc(cutCtrl.text)+SafeCalc.calc(dyeCtrl.text)+SafeCalc.calc(paperCtrl.text),
            'remarks': remarksCtrl.text,
          };
          if(id==null) await _svc.add('thaanEntries', data);
          else await _svc.update('thaanEntries', id, data);
          if(context.mounted) Navigator.pop(context);
        }, child: const Text('Save Thaan'))),
        const SizedBox(height: 24),
      ])));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thaan Khata / تھان کھاتہ'), backgroundColor: const Color(0xFF0a1931), foregroundColor: Colors.white),
      floatingActionButton: FloatingActionButton(onPressed: ()=> _openForm(), backgroundColor: const Color(0xFF0a1931), child: const Icon(Icons.add, color: Colors.white)),
      body: StreamBuilder<QuerySnapshot>(stream: _svc.streamCol('thaanEntries'), builder: (_, snap){
        if(!snap.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(itemCount: snap.data!.docs.length, padding: const EdgeInsets.all(12), itemBuilder: (_, i){
          var d = snap.data!.docs[i];
          var m = d.data() as Map<String,dynamic>;
          return Card(child: ListTile(
            title: Text('${m['partyName']??'No Party'} • ${m['totalPati']??0} Pati'),
            subtitle: Text('${m['date']??''} • Total Exp Rs ${SafeCalc.formatPK(m['totalExpenses']??0)}\n${m['remarks']??''}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: ()=> _openForm(id: d.id, m: m)),
              IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: ()=> _svc.delete('thaanEntries', d.id)),
            ]),
          ));
        });
      }),
    );
  }
}
