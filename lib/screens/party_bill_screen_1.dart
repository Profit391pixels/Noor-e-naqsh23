
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/entry.dart';
import '../utils/safe_calc.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PartyBillScreen extends StatefulWidget {
  const PartyBillScreen({super.key});
  @override
  State<PartyBillScreen> createState() => _PartyBillScreenState();
}

class _PartyBillScreenState extends State<PartyBillScreen> {
  final _svc = FirestoreService();
  final _screenshotCtrl = ScreenshotController();

  void _openForm({PartyBillEntry? edit}){
    final dateCtrl = TextEditingController(text: edit?.date ?? DateTime.now().toIso8601String().substring(0,10));
    final partyCtrl = TextEditingController(text: edit?.partyName ?? '');
    final designCtrl = TextEditingController(text: edit?.designNo ?? '');
    final thaanCtrl = TextEditingController(text: edit?.totalThaan.toString() ?? '');
    final yardsCtrl = TextEditingController(text: edit?.totalYards.toString() ?? '');
    final patiRateCtrl = TextEditingController(text: edit?.patiRate.toString() ?? '');
    final totalPatiCtrl = TextEditingController(text: edit?.totalPati.toString() ?? '');
    final receivedCtrl = TextEditingController(text: edit?.receivedAmount.toString() ?? '');
    final remarksCtrl = TextEditingController(text: edit?.remarks ?? '');

    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: const Color(0xFFfdfbf7), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_){
      return StatefulBuilder(builder: (ctx, setSt){
        double patiAmount = SafeCalc.calc(patiRateCtrl.text) * SafeCalc.calc(totalPatiCtrl.text);
        double totalAmount = patiAmount;
        double remaining = totalAmount - SafeCalc.calc(receivedCtrl.text);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: SingleChildScrollView(child: Column(children: [
            const Text('Party Bill / پارٹی بل', style: TextStyle(fontWeight: FontWeight.w900)),
            TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date')),
            TextField(controller: partyCtrl, decoration: const InputDecoration(labelText: 'Party Name')),
            TextField(controller: designCtrl, decoration: const InputDecoration(labelText: 'Design No')),
            Row(children: [
              Expanded(child: TextField(controller: thaanCtrl, decoration: const InputDecoration(labelText: 'Total Thaan'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: yardsCtrl, decoration: const InputDecoration(labelText: 'Total Yards'))),
            ]),
            Row(children: [
              Expanded(child: TextField(controller: patiRateCtrl, decoration: const InputDecoration(labelText: 'Pati Rate'), onChanged: (_)=> setSt((){}))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: totalPatiCtrl, decoration: const InputDecoration(labelText: 'Total Pati'), onChanged: (_)=> setSt((){}))),
            ]),
            Container(margin: const EdgeInsets.symmetric(vertical: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFfff8e6), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFf0e6d3))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Pati Amount'), Text('Rs ${SafeCalc.formatPK(patiAmount)}', style: const TextStyle(fontWeight: FontWeight.w900))])),
            TextField(controller: receivedCtrl, decoration: const InputDecoration(labelText: 'Received Amount'), onChanged: (_)=> setSt((){})),
            Container(margin: const EdgeInsets.symmetric(vertical: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFfdf6ec), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Remaining'), Text('Rs ${SafeCalc.formatPK(remaining)}', style: const TextStyle(fontWeight: FontWeight.w900))])),
            TextField(controller: remarksCtrl, decoration: const InputDecoration(labelText: 'Remarks'), maxLines: 2),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async {
              var data = {
                'date': dateCtrl.text,
                'partyName': partyCtrl.text,
                'designNo': designCtrl.text,
                'totalThaan': SafeCalc.calc(thaanCtrl.text),
                'totalYards': SafeCalc.calc(yardsCtrl.text),
                'patiRate': SafeCalc.calc(patiRateCtrl.text),
                'totalPati': SafeCalc.calc(totalPatiCtrl.text),
                'patiAmount': patiAmount,
                'totalAmount': totalAmount,
                'receivedAmount': SafeCalc.calc(receivedCtrl.text),
                'remainingAmount': remaining,
                'remarks': remarksCtrl.text,
              };
              if(edit==null) await _svc.add('partyBills', data);
              else await _svc.update('partyBills', edit.id, data);
              if(context.mounted) Navigator.pop(context);
            }, child: const Text('Save Party Bill'))),
            const SizedBox(height: 24),
          ])),
        );
      });
    });
  }

  Future<void> _shareInvoice(PartyBillEntry e) async {
    var widget = Container(
      width: 720,
      color: Colors.white,
      child: Column(children: [
        Container(height: 85, color: const Color(0xFF0a1931), padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
          Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFC5A880), width: 2)), child: const Center(child: Text('NOOR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)))),
          const SizedBox(width: 12),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('NOOR-E-NAQSH', style: TextStyle(color: Color(0xFFd4a76a), fontWeight: FontWeight.w900, fontSize: 20)),
            Text('EMBROIDERY LACE FACTORY', style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          const Spacer(),
          const Text('PARTY BILL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        ])),
        Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Party: ${e.partyName}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          Text('Date: ${e.date} | Design: ${e.designNo}'),
          const Divider(),
          Text('Thaan: ${e.totalThaan} | Yards: ${e.totalYards} | Pati: ${e.totalPati} @ Rs ${e.patiRate}'),
          const SizedBox(height: 8),
          Text('Pati Amount: Rs ${SafeCalc.formatPK(e.patiRate*e.totalPati)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Received: Rs ${SafeCalc.formatPK(e.receivedAmount)}'),
          Text('Remaining: Rs ${SafeCalc.formatPK(e.remainingAmount)}', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.red)),
          if(e.remarks.isNotEmpty) Text('Remarks: ${e.remarks}'),
        ])),
      ]),
    );
    var bytes = await _screenshotCtrl.captureFromWidget(widget, pixelRatio: 2, delay: const Duration(milliseconds: 100));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/Party_${e.partyName}_${e.date}.png');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: 'Party Bill Invoice - ${e.partyName}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Party Bills / پارٹی بل'), backgroundColor: const Color(0xFF0a1931), foregroundColor: Colors.white),
      floatingActionButton: FloatingActionButton(onPressed: ()=> _openForm(), backgroundColor: const Color(0xFF0a1931), child: const Icon(Icons.add, color: Colors.white)),
      body: StreamBuilder<QuerySnapshot>(
        stream: _svc.streamCol('partyBills'),
        builder: (_, snap){
          if(!snap.hasData) return const Center(child: CircularProgressIndicator());
          var docs = snap.data!.docs;
          return ListView.builder(itemCount: docs.length, padding: const EdgeInsets.all(12), itemBuilder: (_, i){
            var e = PartyBillEntry.fromMap(docs[i].id, docs[i].data() as Map<String,dynamic>);
            return Card(child: ListTile(
              title: Text(e.partyName, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('${e.date} • Thaan ${e.totalThaan} • Rs ${SafeCalc.formatPK(e.totalAmount)} | Rem Rs ${SafeCalc.formatPK(e.remainingAmount)}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.share), onPressed: ()=> _shareInvoice(e)),
                IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: ()=> _openForm(edit: e)),
                IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: ()=> _svc.delete('partyBills', e.id)),
              ]),
            ));
          });
        },
      ),
    );
  }
}
