sealed class Countdown {
  const Countdown();
}

final class Upcoming extends Countdown {
  const Upcoming(this.remaining);

  final Duration remaining;
}

final class Started extends Countdown {
  const Started(this.elapsed);

  final Duration elapsed;
}

final class Ended extends Countdown {
  const Ended();
}

Countdown countdownFor(DateTime start, {DateTime? now}) {
  final current = now ?? DateTime.now();
  if (current.isBefore(start)) {
    return Upcoming(start.difference(current));
  }
  final elapsed = current.difference(start);
  if (elapsed < const Duration(hours: 2)) {
    return Started(elapsed);
  }
  return const Ended();
}

String describeCountdown(Countdown countdown) => switch (countdown) {
  Upcoming(remaining: final duration) when duration.inDays > 0 =>
    'In ${duration.inDays} d',
  Upcoming(remaining: final duration) when duration.inHours > 0 =>
    'In ${duration.inHours} h',
  Upcoming(remaining: final duration) => 'In ${duration.inMinutes + 1} min',
  Started(elapsed: final duration) => 'Started ${duration.inMinutes} min ago',
  Ended() => 'Ended',
};
