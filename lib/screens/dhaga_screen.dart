
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/entry.dart';
import '../utils/safe_calc.dart';

class DhagaScreen extends StatefulWidget {
  const DhagaScreen({super.key});
  @override
  State<DhagaScreen> createState() => _DhagaScreenState();
}

class _DhagaScreenState extends State<DhagaScreen> {
  final _svc = FirestoreService();
  void _openForm({DhagaEntry? edit}) {
    final dateCtrl = TextEditingController(text: edit?.date ?? DateTime.now().toIso8601String().substring(0,10));
    final partyCtrl = TextEditingController(text: edit?.party ?? '');
    final rateCtrl = TextEditingController(text: edit?.rawRate ?? '');
    final kgCtrl = TextEditingController(text: edit?.rawKg ?? '');
    final totalCtrl = TextEditingController(text: edit?.rawTotal ?? edit?.total.toString() ?? '');
    final paidCtrl = TextEditingController(text: edit?.rawPaid ?? (edit?.paid.toString() ?? ''));
    final remarksCtrl = TextEditingController(text: edit?.remarks ?? '');
    final paidDateCtrl = TextEditingController(text: edit?.paidDate ?? DateTime.now().toIso8601String().substring(0,10));

    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: const Color(0xFFfdfbf7), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_){
      return StatefulBuilder(builder: (ctx, setSt){
        void recalcTotal(){
          double r = SafeCalc.calc(rateCtrl.text);
          double k = SafeCalc.calc(kgCtrl.text);
          totalCtrl.text = (r*k).toStringAsFixed(0);
          setSt((){});
        }
        double remaining = SafeCalc.calc(totalCtrl.text) - SafeCalc.calc(paidCtrl.text);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Dhaga Entry / دھاگہ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date / تاریخ'), readOnly: true, onTap: () async {
                var d = await showDatePicker(context: ctx, firstDate: DateTime(2020), lastDate: DateTime(2030), initialDate: DateTime.now());
                if(d!=null) dateCtrl.text = d.toIso8601String().substring(0,10);
              }),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextField(controller: rateCtrl, decoration: const InputDecoration(labelText: 'Rate / ریٹ (calc: 2+2)'), onChanged: (_)=> recalcTotal())),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: kgCtrl, decoration: const InputDecoration(labelText: 'Kg / کلو'), onChanged: (_)=> recalcTotal())),
              ]),
              const SizedBox(height: 8),
              TextField(controller: partyCtrl, decoration: const InputDecoration(labelText: 'Party Name / پارٹی')),
              const SizedBox(height: 8),
              TextField(controller: totalCtrl, decoration: const InputDecoration(labelText: 'Total (Auto) / کل رقم', filled: true, fillColor: Color(0xFFeef6ff))),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextField(controller: paidCtrl, decoration: const InputDecoration(labelText: 'Paid / ادا شدہ (calc)'), onChanged: (_)=> setSt((){}))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: paidDateCtrl, decoration: const InputDecoration(labelText: 'Paid Date'))),
              ]),
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFfdf6ec), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFf0e6d3))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Remaining / بقایا', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)), Text('Rs ${SafeCalc.formatPK(remaining)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))])),
              const SizedBox(height: 8),
              TextField(controller: remarksCtrl, decoration: const InputDecoration(labelText: 'Remarks / ریمارکس'), maxLines: 3),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async {
                double rate = SafeCalc.calc(rateCtrl.text);
                double kg = SafeCalc.calc(kgCtrl.text);
                double total = SafeCalc.calc(totalCtrl.text);
                double paid = SafeCalc.calc(paidCtrl.text);
                var data = {
                  'date': dateCtrl.text,
                  'party': partyCtrl.text,
                  'rate': rate, 'kg': kg, 'total': total, 'paid': paid,
                  'remaining': total-paid,
                  'rawRate': rateCtrl.text, 'rawKg': kgCtrl.text, 'rawTotal': totalCtrl.text, 'rawPaid': paidCtrl.text,
                  'paidDate': paidDateCtrl.text,
                  'remarks': remarksCtrl.text,
                };
                if(edit==null) await _svc.add('dhagaEntries', data);
                else await _svc.update('dhagaEntries', edit.id, data);
                if(context.mounted) Navigator.pop(context);
              }, child: Text(edit==null? 'Save Dhaga Entry' : 'Update Entry'))),
              const SizedBox(height: 24),
            ]),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dhaga / دھاگہ'), backgroundColor: const Color(0xFF0a1931), foregroundColor: Colors.white),
      floatingActionButton: FloatingActionButton(onPressed: ()=> _openForm(), backgroundColor: const Color(0xFF0a1931), child: const Icon(Icons.add, color: Colors.white)),
      body: StreamBuilder<QuerySnapshot>(
        stream: _svc.streamCol('dhagaEntries'),
        builder: (ctx, snap){
          if(!snap.hasData) return const Center(child: CircularProgressIndicator());
          var docs = snap.data!.docs;
          if(docs.isEmpty) return const Center(child: Text('No entries'));
          return ListView.builder(itemCount: docs.length, padding: const EdgeInsets.all(12), itemBuilder: (_, i){
            var d = docs[i];
            var e = DhagaEntry.fromMap(d.id, d.data() as Map<String,dynamic>);
            return Card(margin: const EdgeInsets.only(bottom: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: ListTile(
              title: Text(e.party, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${e.date} • ${e.kg} Kg @ Rs ${e.rate}'),
                const SizedBox(height: 4),
                Row(children: [
                  Chip(label: Text('Paid: Rs ${SafeCalc.formatPK(e.paid)}', style: const TextStyle(fontSize: 10)), backgroundColor: const Color(0xFFe8f5e9)),
                  const SizedBox(width: 6),
                  Chip(label: Text('Rem: Rs ${SafeCalc.formatPK(e.remaining)}', style: TextStyle(fontSize: 10, color: e.remaining>0? Colors.red : Colors.green)), backgroundColor: const Color(0xFFffebee)),
                ]),
                if(e.remarks.isNotEmpty) Text('📝 ${e.remarks}', style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Color(0xFFb68a3a))),
              ]),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: ()=> _openForm(edit: e)),
                IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: ()=> _svc.delete('dhagaEntries', e.id)),
              ]),
              onTap: ()=> _openForm(edit: e),
            ));
          });
        },
      ),
    );
  }
}
