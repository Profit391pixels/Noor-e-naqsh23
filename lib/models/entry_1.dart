
import '../utils/safe_calc.dart';

class DhagaEntry {
  String id;
  String date;
  String party;
  String rawRate, rawKg, rawTotal, rawPaid;
  double rate, kg, total, paid, remaining;
  String paidDate;
  String remarks;
  DhagaEntry({required this.id, required this.date, required this.party, required this.rawRate, required this.rawKg, required this.rawTotal, required this.rawPaid, required this.rate, required this.kg, required this.total, required this.paid, required this.remaining, required this.paidDate, required this.remarks});
  factory DhagaEntry.fromMap(String id, Map<String,dynamic> m){
    var rr = (m['rawRate']??m['rate']??'').toString();
    var rk = (m['rawKg']??m['kg']??'').toString();
    var rt = (m['rawTotal']??m['total']??'').toString();
    var rp = (m['rawPaid']??m['paid']??'').toString();
    double r = SafeCalc.calc(rr);
    double k = SafeCalc.calc(rk);
    double t = m['total']!=null ? (m['total'] as num).toDouble() : SafeCalc.calc(rt);
    double p = m['paid']!=null ? (m['paid'] as num).toDouble() : SafeCalc.calc(rp);
    return DhagaEntry(
      id: id,
      date: m['date']??'',
      party: m['party']??'',
      rawRate: rr, rawKg: rk, rawTotal: rt, rawPaid: rp,
      rate: r, kg: k, total: t, paid: p,
      remaining: (m['remaining']??(t-p)).toDouble(),
      paidDate: m['paidDate']??'',
      remarks: m['remarks']??'',
    );
  }
  Map<String,dynamic> toMap() => {
    'date': date, 'party': party,
    'rate': rate, 'kg': kg, 'total': total, 'paid': paid, 'remaining': remaining,
    'rawRate': rawRate, 'rawKg': rawKg, 'rawTotal': rawTotal, 'rawPaid': rawPaid,
    'paidDate': paidDate, 'remarks': remarks,
  };
}

class LabourEntry {
  String id, date, name;
  String rawTotalSalary, rawPaid;
  double totalSalary, paid, remaining;
  double labourPayout, electricianPayout, mechanicPayout, waterPayout, chainLockPayout, rafuGar, hotelPayout, chaiWalaPayout;
  double totalPayout;
  String remarks;
  LabourEntry({required this.id, required this.date, required this.name, required this.rawTotalSalary, required this.rawPaid, required this.totalSalary, required this.paid, required this.remaining, this.labourPayout=0,this.electricianPayout=0,this.mechanicPayout=0,this.waterPayout=0,this.chainLockPayout=0,this.rafuGar=0,this.hotelPayout=0,this.chaiWalaPayout=0,this.totalPayout=0, required this.remarks});
  factory LabourEntry.fromMap(String id, Map<String,dynamic> m){
    String rt = (m['rawTotalSalary']??m['totalSalary']??'').toString();
    String rp = (m['rawPaid']??m['paid']??'').toString();
    return LabourEntry(
      id: id,
      date: m['date']??'',
      name: m['name']??'',
      rawTotalSalary: rt,
      rawPaid: rp,
      totalSalary: SafeCalc.calc(rt),
      paid: SafeCalc.calc(rp),
      remaining: SafeCalc.calc(m['remaining']??0),
      labourPayout: (m['labourPayout']??0).toDouble(),
      electricianPayout: (m['electricianPayout']??0).toDouble(),
      mechanicPayout: (m['mechanicPayout']??0).toDouble(),
      waterPayout: (m['waterPayout']??0).toDouble(),
      chainLockPayout: (m['chainLockPayout']??0).toDouble(),
      rafuGar: (m['rafuGar']??0).toDouble(),
      hotelPayout: (m['hotelPayout']??0).toDouble(),
      chaiWalaPayout: (m['chaiWalaPayout']??0).toDouble(),
      totalPayout: (m['totalPayout']??0).toDouble(),
      remarks: m['remarks']??'',
    );
  }
  Map<String,dynamic> toMap() => {
    'date': date, 'name': name,
    'totalSalary': totalSalary, 'paid': paid, 'remaining': totalSalary-paid,
    'rawTotalSalary': rawTotalSalary, 'rawPaid': rawPaid,
    'labourPayout': labourPayout, 'electricianPayout': electricianPayout,
    'mechanicPayout': mechanicPayout, 'waterPayout': waterPayout,
    'chainLockPayout': chainLockPayout, 'rafuGar': rafuGar,
    'hotelPayout': hotelPayout, 'chaiWalaPayout': chaiWalaPayout,
    'totalPayout': labourPayout+electricianPayout+mechanicPayout+waterPayout+chainLockPayout+rafuGar+hotelPayout+chaiWalaPayout,
    'remarks': remarks,
  };
}

class PartyBillEntry {
  String id, date, partyName, designNo, invoiceNo, reference;
  double totalThaan, totalYards, patiRate, totalPati, patiAmount;
  double paperRollReceived, paperRollUsed;
  double dyingExpenses, cuttingCost, transportFare, previousBalance, ourPreviousBalance, totalAmount, receivedAmount, remainingAmount;
  String designImg, remarks;
  PartyBillEntry({required this.id, required this.date, required this.partyName, this.designNo='', this.invoiceNo='', this.reference='', this.totalThaan=0,this.totalYards=0,this.patiRate=0,this.totalPati=0,this.patiAmount=0,this.paperRollReceived=0,this.paperRollUsed=0,this.dyingExpenses=0,this.cuttingCost=0,this.transportFare=0,this.previousBalance=0,this.ourPreviousBalance=0,this.totalAmount=0,this.receivedAmount=0,this.remainingAmount=0,this.designImg='',this.remarks=''});
  factory PartyBillEntry.fromMap(String id, Map<String,dynamic> m) => PartyBillEntry(
    id: id,
    date: m['date']??'',
    partyName: m['partyName']??'',
    designNo: m['designNo']??'',
    invoiceNo: m['invoiceNo']?.toString()??'',
    reference: m['reference']??'',
    totalThaan: (m['totalThaan']??0).toDouble(),
    totalYards: (m['totalYards']??0).toDouble(),
    patiRate: (m['patiRate']??0).toDouble(),
    totalPati: (m['totalPati']??0).toDouble(),
    patiAmount: (m['patiAmount']??0).toDouble(),
    paperRollReceived: (m['paperRollReceived']??0).toDouble(),
    paperRollUsed: (m['paperRollUsed']??0).toDouble(),
    dyingExpenses: (m['dyingExpenses']??0).toDouble(),
    cuttingCost: (m['cuttingCost']??0).toDouble(),
    transportFare: (m['transportFare']??0).toDouble(),
    previousBalance: (m['previousBalance']??m['partyPreviousBalance']??0).toDouble(),
    ourPreviousBalance: (m['ourPreviousBalance']??0).toDouble(),
    totalAmount: (m['totalAmount']??0).toDouble(),
    receivedAmount: (m['receivedAmount']??0).toDouble(),
    remainingAmount: (m['remainingAmount']??0).toDouble(),
    designImg: m['designImg']??'',
    remarks: m['remarks']??'',
  );
  Map<String,dynamic> toMap() => {
    'date': date, 'partyName': partyName, 'designNo': designNo,
    'invoiceNo': invoiceNo, 'reference': reference,
    'totalThaan': totalThaan, 'totalYards': totalYards,
    'patiRate': patiRate, 'totalPati': totalPati, 'patiAmount': patiRate*totalPati,
    'paperRollReceived': paperRollReceived, 'paperRollUsed': paperRollUsed,
    'dyingExpenses': dyingExpenses, 'cuttingCost': cuttingCost,
    'transportFare': transportFare, 'previousBalance': previousBalance,
    'ourPreviousBalance': ourPreviousBalance,
    'totalAmount': totalAmount, 'receivedAmount': receivedAmount,
    'remainingAmount': totalAmount-receivedAmount,
    'designImg': designImg, 'remarks': remarks,
  };
}
