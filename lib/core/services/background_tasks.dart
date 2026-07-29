import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void backgroundCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Step 10/12 placeholder for periodic summaries/bill checks.
    return Future.value(true);
  });
}
