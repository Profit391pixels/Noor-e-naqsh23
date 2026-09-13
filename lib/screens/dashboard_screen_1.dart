
import 'package:flutter/material.dart';
import 'dhaga_screen.dart';
import 'labour_screen.dart';
import 'party_bill_screen.dart';
import 'thaan_screen.dart';
import 'generic_expense_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _index = 0;
  final _screens = [
    const HomeGrid(),
    const DhagaScreen(),
    const LabourScreen(),
    const PartyBillScreen(),
    const ThaanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i)=> setState(()=> _index=i),
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.inventory), label: 'Dhaga'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Labour'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Party Bill'),
          NavigationDestination(icon: Icon(Icons.view_module), label: 'Thaan'),
        ],
      ),
    );
  }
}

class HomeGrid extends StatelessWidget {
  const HomeGrid({super.key});
  @override
  Widget build(BuildContext context) {
    final items = [
      {'k':'dhaga','l':'Dhaga','u':'دھاگہ','c':Colors.orange},
      {'k':'paper','l':'Paper','u':'پیپر','c':Colors.blue},
      {'k':'thaan','l':'Total Thaan','u':'کل تھان','c':Colors.green},
      {'k':'labour','l':'Labour','u':'لیبر','c':Colors.purple},
      {'k':'hall','l':'Hall Rent','u':'ہال','c':Colors.teal},
      {'k':'electric','l':'Electric','u':'بجلی','c':Colors.amber},
      {'k':'firqi','l':'Firqi','u':'فرقی','c':Colors.pink},
      {'k':'party','l':'Party Bills','u':'پارٹی بل','c':const Color(0xFF0a1931)},
    ];
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF0a1931), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFC5A880), width: 2)),
              child: Row(children: [
                Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFC5A880))), child: const Center(child: Text('N', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)))),
                const SizedBox(width: 12),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('NOOR-E-NAQSH', style: TextStyle(color: Color(0xFFd4a76a), fontWeight: FontWeight.w900, fontSize: 18)),
                  Text('EMBROIDERY LACE FACTORY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                  Text('Small Estate FSD', style: TextStyle(color: Colors.white70, fontSize: 10)),
                ]),
              ]),
            ),
            const SizedBox(height: 16),
            const Text('Factory Management / فیکٹری مینجمنٹ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.3),
              itemCount: items.length,
              itemBuilder: (_, i){
                final it = items[i];
                return InkWell(
                  onTap: (){
                    if(it['k']=='dhaga') Navigator.push(context, MaterialPageRoute(builder: (_)=> const DhagaScreen()));
                    if(it['k']=='labour') Navigator.push(context, MaterialPageRoute(builder: (_)=> const LabourScreen()));
                    if(it['k']=='party') Navigator.push(context, MaterialPageRoute(builder: (_)=> const PartyBillScreen()));
                    if(it['k']=='hall') Navigator.push(context, MaterialPageRoute(builder: (_)=> GenericExpenseScreen(col: 'hallEntries', title: 'Hall Rent / ہال کرایہ')));
                    if(it['k']=='electric') Navigator.push(context, MaterialPageRoute(builder: (_)=> GenericExpenseScreen(col: 'electricityEntries', title: 'Electricity / بجلی')));
                    if(it['k']=='thaan') Navigator.push(context, MaterialPageRoute(builder: (_)=> const ThaanScreen()));
                  },
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFf0e6d3))),
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      CircleAvatar(backgroundColor: (it['c'] as Color).withOpacity(0.15), child: Icon(Icons.category, color: it['c'] as Color)),
                      const Spacer(),
                      Text(it['l'] as String, style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text(it['u'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFFb68a3a))),
                    ]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
