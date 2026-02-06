String formatQuantity(double q) {
  if (q == q.toInt()) {
    return q.toInt().toString();
  }
  // Show up to 2 decimal places, remove trailing zeros
  String s = q.toStringAsFixed(2);
  if (s.endsWith('.00')) return q.toInt().toString();
  if (s.contains('.')) {
    while (s.endsWith('0')) {
      s = s.substring(0, s.length - 1);
    }
    if (s.endsWith('.')) {
      s = s.substring(0, s.length - 1);
    }
  }
  return s;
}
