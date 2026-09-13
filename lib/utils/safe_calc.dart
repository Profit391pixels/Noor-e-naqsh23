
class SafeCalc {
  static double calc(dynamic input) {
    try {
      var s = (input ?? '0').toString().trim();
      if (s.isEmpty) return 0;
      // allow only numbers and +-*/(). and spaces
      if (!RegExp(r'^[0-9+\-*/().\s]+$').hasMatch(s)) {
        return double.tryParse(s) ?? 0;
      }
      return _eval(s);
    } catch (_) {
      return 0;
    }
  }

  static double _eval(String expr) {
    // Shunting-yard simple evaluator for +-*/()
    try {
      expr = expr.replaceAll(' ', '');
      // handle double operators
      List<double> values = [];
      List<String> ops = [];
      int i = 0;
      int prec(String op) => (op == '+' || op == '-') ? 1 : (op == '*' || op == '/') ? 2 : 0;
      double applyOp(String op, double b, double a) {
        switch (op) {
          case '+': return a + b;
          case '-': return a - b;
          case '*': return a * b;
          case '/': return b == 0 ? 0 : a / b;
        }
        return 0;
      }
      while (i < expr.length) {
        var c = expr[i];
        if (c == '(') {
          ops.add(c);
          i++;
        } else if (c == ')') {
          while (ops.isNotEmpty && ops.last != '(') {
            var op = ops.removeLast();
            var b = values.removeLast();
            var a = values.removeLast();
            values.add(applyOp(op, b, a));
          }
          if (ops.isNotEmpty) ops.removeLast();
          i++;
        } else if ('+-*/'.contains(c)) {
          // handle negative number
          if (c == '-' && (i == 0 || '+-*/('.contains(expr[i-1]))) {
            // parse negative number
            int j = i+1;
            while (j < expr.length && (RegExp(r'[0-9.]').hasMatch(expr[j]))) j++;
            var num = double.tryParse(expr.substring(i, j)) ?? 0;
            values.add(num);
            i = j;
            continue;
          }
          while (ops.isNotEmpty && prec(ops.last) >= prec(c)) {
            var op = ops.removeLast();
            var b = values.removeLast();
            var a = values.removeLast();
            values.add(applyOp(op, b, a));
          }
          ops.add(c);
          i++;
        } else if (RegExp(r'[0-9.]').hasMatch(c)) {
          int j = i;
          while (j < expr.length && RegExp(r'[0-9.]').hasMatch(expr[j])) j++;
          values.add(double.tryParse(expr.substring(i, j)) ?? 0);
          i = j;
        } else {
          i++;
        }
      }
      while (ops.isNotEmpty) {
        var op = ops.removeLast();
        var b = values.removeLast();
        var a = values.removeLast();
        values.add(applyOp(op, b, a));
      }
      return values.isEmpty ? 0 : values.last;
    } catch (_) {
      return 0;
    }
  }

  static String formatPK(num v) {
    // en-PK formatting
    return v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
