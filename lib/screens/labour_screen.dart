
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/entry.dart';
import '../utils/safe_calc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';

class LabourScreen extends StatefulWidget {
  const LabourScreen({super.key});
  @override
  State<LabourScreen> createState() => _LabourScreenState();
}

class _LabourScreenState extends State<LabourScreen> {
  final _svc = FirestoreService();
  final _screenshotController = ScreenshotController();

  void _openForm({LabourEntry? edit}){
    final dateCtrl = TextEditingController(text: edit?.date ?? DateTime.now().toIso8601String().substring(0,10));
    final nameCtrl = TextEditingController(text: edit?.name ?? '');
    final totalCtrl = TextEditingController(text: edit?.rawTotalSalary ?? '');
    final paidCtrl = TextEditingController(text: edit?.rawPaid ?? '');
    final remarksCtrl = TextEditingController(text: edit?.remarks ?? '');
    final labourCtrl = TextEditingController(text: edit?.labourPayout.toString() ?? '');
    final electCtrl = TextEditingController(text: edit?.electricianPayout.toString() ?? '');
    final mechCtrl = TextEditingController(text: edit?.mechanicPayout.toString() ?? '');

    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: const Color(0xFFfdfbf7), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_){
      return StatefulBuilder(builder: (ctx, setSt){
        double total = SafeCalc.calc(totalCtrl.text);
        double paid = SafeCalc.calc(paidCtrl.text);
        double rem = total-paid;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: SingleChildScrollView(child: Column(children: [
            const Text('Labour Salary / مزدور تنخواہ', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date')),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name / نام')),
            TextField(controller: totalCtrl, decoration: const InputDecoration(labelText: 'Total Salary / کل تنخواہ (calc: 2+2)'), onChanged: (_)=> setSt((){})),
            TextField(controller: paidCtrl, decoration: const InputDecoration(labelText: 'Paid / ادا شدہ'), onChanged: (_)=> setSt((){})),
            Container(margin: const EdgeInsets.symmetric(vertical: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFfdf6ec), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Remaining'), Text('Rs ${SafeCalc.formatPK(rem)}', style: const TextStyle(fontWeight: FontWeight.w900))])),
            TextField(controller: labourCtrl, decoration: const InputDecoration(labelText: 'Labour Payout')),
            TextField(controller: electCtrl, decoration: const InputDecoration(labelText: 'Electrician Payout')),
            TextField(controller: mechCtrl, decoration: const InputDecoration(labelText: 'Mechanic Payout')),
            TextField(controller: remarksCtrl, decoration: const InputDecoration(labelText: 'Remarks / ریمارکس'), maxLines: 3),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async {
              var data = {
                'date': dateCtrl.text,
                'name': nameCtrl.text,
                'totalSalary': SafeCalc.calc(totalCtrl.text),
                'paid': SafeCalc.calc(paidCtrl.text),
                'remaining': SafeCalc.calc(totalCtrl.text)-SafeCalc.calc(paidCtrl.text),
                'rawTotalSalary': totalCtrl.text,
                'rawPaid': paidCtrl.text,
                'labourPayout': SafeCalc.calc(labourCtrl.text),
                'electricianPayout': SafeCalc.calc(electCtrl.text),
                'mechanicPayout': SafeCalc.calc(mechCtrl.text),
                'remarks': remarksCtrl.text,
              };
              if(edit==null) await _svc.add('labourEntries', data);
              else await _svc.update('labourEntries', edit.id, data);
              if(context.mounted) Navigator.pop(context);
            }, child: const Text('Save Labour Salary'))),
            const SizedBox(height: 20),
          ])),
        );
      });
    });
  }

  Future<void> _shareReceipt(LabourEntry e) async {
    // Simple receipt using screenshot of a widget
    var bytes = await _screenshotController.captureFromWidget(
      Container(
        width: 1080,
        color: const Color(0xFFfdfbf7),
        padding: const EdgeInsets.all(40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('NOOR-E-NAQSH', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Color(0xFF0a1931))),
          const Text('EMBROIDERY LACE FACTORY', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFb68a3a))),
          const SizedBox(height: 20),
          Text('Labour Salary Slip / مزدور تنخواہ رسید', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          const Divider(),
          Text('Name: ${e.name}'),
          Text('Date: ${e.date}'),
          const SizedBox(height: 12),
          Text('Total: Rs ${SafeCalc.formatPK(e.totalSalary)}'),
          Text('Paid: Rs ${SafeCalc.formatPK(e.paid)}'),
          Text('Remaining: Rs ${SafeCalc.formatPK(e.remaining)}', style: TextStyle(color: e.remaining>0? Colors.red: Colors.green, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Remarks: ${e.remarks.isEmpty? '-' : e.remarks}'),
        ]),
      ),
      pixelRatio: 2,
    );
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/Labour_${e.name}_${e.date}.png');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: 'Labour Salary Receipt - ${e.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Labour Salary / مزدور تنخواہ'), backgroundColor: const Color(0xFF0a1931), foregroundColor: Colors.white),
      floatingActionButton: FloatingActionButton(onPressed: ()=> _openForm(), backgroundColor: const Color(0xFF0a1931), child: const Icon(Icons.add, color: Colors.white)),
      body: StreamBuilder<QuerySnapshot>(
        stream: _svc.streamCol('labourEntries'),
        builder: (_, snap){
          if(!snap.hasData) return const Center(child: CircularProgressIndicator());
          var docs = snap.data!.docs;
          return ListView.builder(itemCount: docs.length, padding: const EdgeInsets.all(12), itemBuilder: (_, i){
            var e = LabourEntry.fromMap(docs[i].id, docs[i].data() as Map<String,dynamic>);
            return Card(child: ListTile(
              title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${e.date} | Total: Rs ${SafeCalc.formatPK(e.totalSalary)} | Paid: Rs ${SafeCalc.formatPK(e.paid)}'),
                Text('Remaining: Rs ${SafeCalc.formatPK(e.remaining)}', style: TextStyle(fontWeight: FontWeight.bold, color: e.remaining>0? Colors.red: Colors.green)),
                if(e.remarks.isNotEmpty) Text('📝 ${e.remarks}', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFFb68a3a))),
              ]),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.receipt, size: 18), onPressed: ()=> _shareReceipt(e)),
                IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: ()=> _openForm(edit: e)),
                IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: ()=> _svc.delete('labourEntries', e.id)),
              ]),
            ));
          });
        },
      ),
    );
  }
}
