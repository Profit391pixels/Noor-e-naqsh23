
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../utils/safe_calc.dart';

class GenericExpenseScreen extends StatefulWidget {
  final String col;
  final String title;
  const GenericExpenseScreen({super.key, required this.col, required this.title});
  @override
  State<GenericExpenseScreen> createState() => _GenericExpenseScreenState();
}

class _GenericExpenseScreenState extends State<GenericExpenseScreen> {
  final _svc = FirestoreService();
  void _openForm({String? editId, Map<String,dynamic>? data}){
    final dateCtrl = TextEditingController(text: data?['date'] ?? DateTime.now().toIso8601String().substring(0,10));
    final amountCtrl = TextEditingController(text: data?['amount']?.toString() ?? data?['rawAmount']?.toString() ?? '');
    final remarksCtrl = TextEditingController(text: data?['remarks'] ?? '');
    final unitsCtrl = TextEditingController(text: data?['units']?.toString() ?? '');

    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: const Color(0xFFfdfbf7), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_){
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(_).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date / تاریخ')),
          if(widget.col=='electricityEntries') TextField(controller: unitsCtrl, decoration: const InputDecoration(labelText: 'Units / یونٹ')),
          TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'Amount / رقم (calc: 2+2)')),
          TextField(controller: remarksCtrl, decoration: const InputDecoration(labelText: 'Remarks / ریمارکس'), maxLines: 3),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async {
            var map = {
              'date': dateCtrl.text,
              'amount': SafeCalc.calc(amountCtrl.text),
              'rawAmount': amountCtrl.text,
              'remarks': remarksCtrl.text,
              if(widget.col=='electricityEntries') 'units': unitsCtrl.text,
            };
            if(editId==null) await _svc.add(widget.col, map);
            else await _svc.update(widget.col, editId, map);
            if(context.mounted) Navigator.pop(context);
          }, child: Text(editId==null? 'Save' : 'Update'))),
          const SizedBox(height: 24),
        ]),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: const Color(0xFF0a1931), foregroundColor: Colors.white),
      floatingActionButton: FloatingActionButton(onPressed: ()=> _openForm(), backgroundColor: const Color(0xFF0a1931), child: const Icon(Icons.add, color: Colors.white)),
      body: StreamBuilder<QuerySnapshot>(
        stream: _svc.streamCol(widget.col),
        builder: (_, snap){
          if(!snap.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(itemCount: snap.data!.docs.length, padding: const EdgeInsets.all(12), itemBuilder: (_, i){
            var d = snap.data!.docs[i];
            var m = d.data() as Map<String,dynamic>;
            return Card(child: ListTile(
              title: Text('Rs ${SafeCalc.formatPK(m['amount']??0)} - ${m['date']??''}'),
              subtitle: Text(m['remarks']?.toString() ?? (m['units']?.toString() ?? '')),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: ()=> _openForm(editId: d.id, data: m)),
                IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: ()=> _svc.delete(widget.col, d.id)),
              ]),
            ));
          });
        },
      ),
    );
  }
}
