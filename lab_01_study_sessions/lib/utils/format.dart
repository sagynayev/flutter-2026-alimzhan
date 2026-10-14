const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatDateTime(DateTime value) {
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.day} ${_months[value.month - 1]}, '
      '${value.hour}:$minute';
}

String formatDate(DateTime value) =>
    '${value.day} ${_months[value.month - 1]} ${value.year}';

String formatTime(DateTime value) =>
    '${value.hour}:${value.minute.toString().padLeft(2, '0')}';
