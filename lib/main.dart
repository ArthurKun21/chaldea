import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:catcher_2/catcher_2.dart';
import 'package:worker_manager/worker_manager.dart';

import 'package:chaldea/app/tools/app_window.dart';
import 'package:chaldea/packages/home_widget.dart';
import 'app/chaldea.dart';
import 'app/modules/common/blank_page.dart';
import 'app/modules/home/bootstrap/startup_failed_page.dart';
import 'models/db.dart';
import 'packages/analysis/analysis.dart';
import 'packages/network.dart';
import 'packages/packages.dart';
import 'packages/split_route/split_route.dart';
import 'utils/catcher/catcher_util.dart';
import 'utils/catcher/server_feedback_handler.dart';
import 'utils/http_override.dart';
import 'utils/notification.dart';
import 'utils/utils.dart';

void main() async {
  // make sure flutter packages like path_provider is working now
  WidgetsFlutterBinding.ensureInitialized();
  dynamic initError, initStack;
  Catcher2Options? catcherOptions;
  try {
    await _initiateCommon();
    workerManager.init();
    await db.initiate();
    AppAnalysis.instance.initiate();
    catcherOptions = CatcherUtil.getOptions(
      logPath: db.paths.crashLog,
      feedbackHandler: ServerFeedbackHandler(
        screenshotController: db.runtimeData.screenshotController,
        screenshotPath: joinPaths(db.paths.tempDir, 'crash.jpg'),
        attachments: [db.paths.appLog, db.paths.crashLog, db.paths.userDataPath],
        onGenerateAttachments: () => {
          'userdata.memory.json': Uint8List.fromList(utf8.encode(jsonEncode(db.userData))),
          'settings.memory.json': Uint8List.fromList(utf8.encode(jsonEncode(db.settings))),
        },
      ),
    );
  } catch (e, s) {
    initError = e;
    initStack = s;
    try {
      logger.e('initiate app failed at startup', e, s);
    } catch (e, s) {
      print(e);
      print(s);
    }
  }
  final app = initError == null ? Chaldea() : StartupFailedPage(error: initError, stackTrace: initStack, wrapApp: true);
  if (kDebugMode) {
    runApp(app);
  } else {
    Catcher2(
      rootWidget: app,
      debugConfig: catcherOptions,
      profileConfig: catcherOptions,
      releaseConfig: catcherOptions,
      navigatorKey: kAppKey,
      ensureInitialized: true,
      enableLogger: kDebugMode,
    );
  }
}

Future<void> _initiateCommon() async {
  await AppWindowUtil.init();

  LicenseRegistry.addLicense(() async* {
    Map<String, String> licenses = {
      'MOONCELL': 'res/license/CC-BY-NC-SA-4.0.txt',
      'FANDOM': 'res/license/CC-BY-SA-3.0.txt',
      'Atlas Academy': 'res/license/ODC-BY 1.0.txt',
    };
    for (final entry in licenses.entries) {
      String license = await rootBundle.loadString(entry.value).catchError((e, s) async {
        logger.e('load license(${entry.key}, ${entry.value}) failed.', e, s);
        return 'load license failed';
      });
      yield LicenseEntryWithLineBreaks([entry.key], license);
    }
  });
  network.init();
  if (!kIsWeb) {
    HttpOverrides.global = CustomHttpOverrides();
  }
  SplitRoute.defaultMasterFillPageBuilder = (context) => const BlankPage();
  await LocalNotificationUtil.init();

  HomeWidgetX.init();
}
