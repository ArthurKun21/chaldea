import 'dart:typed_data';

import 'package:flutter/scheduler.dart';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/api/recognizer.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/analysis/analysis.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'screenshot/screenshots.dart';
import 'screenshot/skill_result.dart';
import 'screenshot/viewer.dart';

class ImportSkillScreenshotPage extends StatefulWidget {
  final bool isAppend;

  ImportSkillScreenshotPage({super.key, this.isAppend = false});

  @override
  ImportSkillScreenshotPageState createState() => ImportSkillScreenshotPageState();
}

class ImportSkillScreenshotPageState extends State<ImportSkillScreenshotPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SkillResult? output;
  late Dio _dio;

  Set<Uint8List> get imageFiles => widget.isAppend ? db.runtimeData.recognizerAppend : db.runtimeData.recognizerActive;

  SkillResult? get result =>
      widget.isAppend ? db.runtimeData.recognizerAppendResult : db.runtimeData.recognizerActiveResult;
  set result(SkillResult? v) {
    if (widget.isAppend) {
      db.runtimeData.recognizerAppendResult = v;
    } else {
      db.runtimeData.recognizerActiveResult = v;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: AppInfo.isDebugDevice ? 3 : 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });

    _dio = DioE(
      db.apiServerDio.options.copyWith(
        sendTimeout: const Duration(minutes: 10),
        receiveTimeout: const Duration(minutes: 10),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          widget.isAppend ? S.current.import_append_skill_screenshots : S.current.import_active_skill_screenshots,
        ),
        actions: [ChaldeaUrl.docsHelpBtn('import_data#skill-recognition')],
        bottom: FixedHeight.tabBar(
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: S.current.screenshots),
              Tab(text: S.current.results),
              if (AppInfo.isDebugDevice) const Tab(text: 'Debug'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          KeepAliveBuilder(
            builder: (ctx) => ScreenshotsTab(
              images: imageFiles,
              onUpload: () {
                EasyThrottle.throttle('skill_recognizer_upload', const Duration(seconds: 5), _uploadScreenshots);
              },
              debugServerRoot: _dio.options.baseUrl,
            ),
          ),
          KeepAliveBuilder(
            builder: (ctx) => SkillResultTab(isAppend: widget.isAppend, result: output),
          ),
          if (AppInfo.isDebugDevice)
            KeepAliveBuilder(builder: (ctx) => RecognizerViewerTab(type: RecognizerType.skill)),
        ],
      ),
    );
  }

  void _uploadScreenshots() async {
    if (imageFiles.isEmpty) {
      return;
    }
    try {
      EasyLoading.show(status: 'Uploading', maskType: EasyLoadingMaskType.clear);

      final Map<String, dynamic> map = {};
      List<MultipartFile> files = [];
      for (int index = 0; index < imageFiles.length; index++) {
        var bytes = imageFiles.elementAt(index);
        // compress if size > 1.0M
        if (bytes.length / 1024 > 1.0) {
          bytes = await compressToJpgAsync(src: bytes, maxWidth: 1920, maxHeight: 1080, quality: 90);
        } else {
          bytes = await compressToJpgAsync(src: bytes, quality: 90);
        }
        files.add(MultipartFile.fromBytes(bytes, filename: 'file$index'));
      }
      map['files'] = files;
      var formData = FormData.fromMap(map);
      final resp2 = await _dio.post(
        '/recognizer/skill',
        data: formData,
        onSendProgress: (count, total) {
          if (total <= 0) {
            EasyLoading.show(status: 'Uploaded ${count ~/ 1000}KB...');
          } else {
            final progress = (count / total).format(percent: true);
            EasyLoading.show(status: 'Uploaded $progress...');
          }
        },
        onReceiveProgress: (count, total) {
          if (total <= 0) {
            EasyLoading.show(status: 'Downloaded ${count ~/ 1000}KB...');
          } else {
            final progress = (count / total).format(percent: true);
            EasyLoading.show(status: 'Downloaded $progress...');
          }
        },
      );
      output = SkillResult.fromJson(resp2.data);
      logger.i('received recognized: ${output?.details.length} servants');

      if (mounted) {
        AppAnalysis.instance.logEvent('screenshot_recognizer', {
          "type": widget.isAppend ? "appendSkill" : "activeSkill",
        });
        setState(() {});
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          if (mounted) {
            _tabController.index = 1;
          }
        });
      }
    } catch (e, s) {
      logger.e('upload item screenshots to server error', e, s);
      if (mounted) {
        SimpleConfirmDialog(
          title: const Text('Error'),
          content: Text(escapeDioException(e)),
          showCancel: false,
        ).showDialog(context);
      }
    } finally {
      EasyLoading.dismiss();
    }
  }
}
