# Practice 10 — The Data Arrives Later

Sagynayev Alimzhan, Thursday 16:00–17:00.

## Level 1: event order

Prediction: A, C, first frame, then B and 6 students after two seconds.
Observed in the event-loop widget test: A, C, first frame, B, 6 students.
The API also prints fetchStudents #1 when the request starts.
await gives control back to the event loop. Blocking sleep would prevent the
first frame during the delay; it is not used in the final app.

fetchStudents waits two seconds and fails on requests 3, 6, 9, etc.
The request number is captured before await so overlapping requests keep their
own failure schedule. save has a separate counter and fails on calls 2, 4, etc.

## Level 2: mounted and the four views

Loading, error with Retry, empty and data are separate widgets.
The home switch selects FakeApi(empty: true) to demonstrate the empty view.
Reload makes it possible to reach the third-request error without restarting.
Both completion paths of _load check mounted.

The deliberately broken countdown experiment produced this exact line:
setState() called after dispose(): _BrokenCountdownState#d066a(lifecycle state: defunct, not mounted)

The same error occurs when a delayed load calls setState after its screen
has been removed without a mounted guard. The State name and hash depend
on the widget and run. The final manual loading screen was tested by disposing
it during its request; completion produced no exception.

## Level 3: a stored Future

Ten compact Switch changes after loading left api.calls equal to 1.
Retry/Reload deliberately replaces the stored Future. It is late, not final.
The FutureBuilder checks hasError, then connectionState, then empty/data.

The assignment's arrow callback for setState returned a Future and caused:
setState() callback argument returned a Future.
The working version uses a block with a semicolon inside setState.

## Level 4: subscriptions

With cancellation: version B was removed at 7. Advancing four more seconds
produced no additional tick messages and no Flutter exception.
Version A behaved the same: StreamBuilder cancelled its own subscription.

Without cancellation: the separate broken test continued:
tick 10, tick 9, tick 8, tick 7, tick 6, tick 5, tick 4, tick 3, tick 2, tick 1, tick 0.
After removal at 7, every attempted setState produced the disposal error.
The experiment catches those expected errors to let the test finish;
this broken widget exists only in test/, never in the working application.

Changing between A and B disposes the previous version and starts a fresh
countdown. No hidden tab is kept ticking.

## Level 5: Save

Unhandled Exception: Bad state: server rejected 6

The unawaited-save experiment uses a guarded zone to capture the otherwise
uncaught error. The simulated pop happens before the error arrives.
The user saw a success although the request failed.

The working Save awaits the API, catches StateError, checks context.mounted,
and pops only on success. It disables the button and shows a spinner while
saving. A double-tap test verifies that only one save happens.

The home owns the API for the session so its save counter survives navigation.
Demo: save successfully, reopen By hand, then Save again to see the error.
Reload and opening either student screen share the fetch counter.

unawaited() is used explicitly for lifecycle/callback work that cannot be
awaited by Flutter. _load and _save handle their errors internally. The stream
cancellation is also marked explicitly. There are no accidentally discarded
Future results in lib/.

## Run and check

flutter pub get
flutter run
flutter analyze
flutter test

## Submission checklist

- Home: By hand, FutureBuilder, Countdown.
- Fake API: delays, deterministic failures, null GPA displayed as —.
- Four reusable state widgets; mounted guards.
- Stored Future; ten Switch changes do not reload.
- Both countdown versions; subscription cancellation.
- Save: await, StateError, mounted, disabled button, success-only pop.
- unawaited_futures enabled; formatted Dart.
- screenshot_error.png: actual third-call error and Retry.
- screenshot_countdown.png: actual version B during the countdown.
