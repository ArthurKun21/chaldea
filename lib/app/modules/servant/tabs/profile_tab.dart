import 'package:flutter/services.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SvtLoreTab extends StatefulWidget {
  final Servant svt;

  const SvtLoreTab({super.key, required this.svt});

  @override
  State<SvtLoreTab> createState() => _SvtLoreTabState();
}

enum _WikiSource { mc, fandom, aprilFool }

class _SvtLoreTabState extends State<SvtLoreTab> {
  _WikiSource? _wikiSource;
  Region? _region;
  Set<Region> releasedRegions = {};

  Servant? svt;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    for (final r in Region.values) {
      if (r == Region.jp || isReleased(r)) {
        releasedRegions.add(r);
      }
    }

    final curRegion = Transl.current;
    if (releasedRegions.contains(curRegion)) {
      _region = curRegion;
    } else if ((curRegion == Region.cn || curRegion == Region.tw) && widget.svt.extra.mcProfiles.isNotEmpty) {
      _wikiSource = _WikiSource.mc;
    } else if ((curRegion == Region.na || curRegion == Region.kr) && widget.svt.extra.fandomProfiles.isNotEmpty) {
      _wikiSource = _WikiSource.fandom;
    } else {
      _region = Region.jp;
    }
    if (_region != null) {
      fetchSvt(_region!);
    }
  }

  bool isReleased(Region r) {
    final released = db.gameData.mappingData.entityRelease.ofRegion(r);
    return released?.contains(widget.svt.id) == true;
  }

  void fetchSvt(Region r) async {
    _loading = true;
    svt = null;
    if (mounted) setState(() {});
    final result = await AtlasApi.svt(widget.svt.id, region: r);
    if (r == _region) {
      svt = result;
    }
    _loading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (_region != null) {
      children.addAll(_addRegionProfile());
    } else if (_wikiSource == _WikiSource.mc) {
      children.addAll(_addWikiProfile(widget.svt.extra.mcProfiles));
    } else if (_wikiSource == _WikiSource.fandom) {
      children.addAll(_addWikiProfile(widget.svt.extra.fandomProfiles));
    } else if (_wikiSource == _WikiSource.aprilFool) {
      children.addAll(_addAprilFool());
    }

    return Column(
      children: [
        Expanded(
          child: InheritSelectionArea(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: children.length,
              itemBuilder: (context, index) => children[index],
            ),
          ),
        ),
        SafeArea(child: buttonBar),
      ],
    );
  }

  Widget get buttonBar {
    final hasMC = widget.svt.extra.mcProfiles.isNotEmpty,
        hasFandom = widget.svt.extra.fandomProfiles.isNotEmpty,
        hasApril = widget.svt.extra.aprilFoolProfile.values.any((e) => e != null);
    return OverflowBar(
      alignment: MainAxisAlignment.center,
      children: [
        FilterGroup<Region>(
          combined: true,
          padding: EdgeInsets.zero,
          options: releasedRegions.toList(),
          optionBuilder: (v) => Text(v.upper),
          values: FilterRadioData(_region),
          onFilterChanged: (v, _) {
            if (v.radioValue != null) {
              _region = v.radioValue!;
              _wikiSource = null;
              fetchSvt(_region!);
            }
            setState(() {});
          },
        ),
        if (hasMC || hasFandom || hasApril)
          FilterGroup<_WikiSource>(
            combined: true,
            padding: EdgeInsets.zero,
            options: [
              if (hasMC) _WikiSource.mc,
              if (hasFandom) _WikiSource.fandom,
              if (hasApril) _WikiSource.aprilFool,
            ],
            optionBuilder: (v) {
              switch (v) {
                case _WikiSource.mc:
                  return const Text('MC');
                case _WikiSource.fandom:
                  return const Text('Fandom');
                case _WikiSource.aprilFool:
                  return Text(S.current.april_fool);
              }
            },
            values: FilterRadioData(_wikiSource),
            onFilterChanged: (v, _) {
              if (v.radioValue != null) {
                _wikiSource = v.radioValue!;
                _region = null;
              }
              setState(() {});
            },
          ),
      ],
    );
  }

  Widget? _condDescribe(CondType condType, List<int>? condValues, int condValue2, bool showUnknown) {
    int? condValue = condValues?.getOrNull(0);
    if (condValue != null) {
      switch (condType) {
        case CondType.none:
          return null;
        case CondType.questClear:
          return CondTargetValueDescriptor(condType: condType, target: condValue, value: 0, textScaleFactor: 0.9);
        case CondType.svtFriendship:
          return Text('${S.current.bond} Lv.$condValue', textScaler: const TextScaler.linear(0.9));
        case CondType.svtLimit:
          return Text('${S.current.ascension_short} Lv.$condValue', textScaler: const TextScaler.linear(0.9));
        case CondType.svtGet:
          return CondTargetValueDescriptor(condType: condType, target: condValue, value: 0, textScaleFactor: 0.9);
        default:
          break;
      }
    }
    if (showUnknown) {
      return Text('Unknown condType $condType, condValues $condValues');
    } else {
      return null;
    }
  }

  List<Widget> _addRegionProfile() {
    List<Widget> children = [];
    List<LoreComment> comments = List.of(svt?.profile.comments ?? []);
    Map<int, List<LoreComment>> grouped = {};
    for (final lore in comments) {
      grouped.putIfAbsent(lore.priority, () => []).add(lore);
    }
    comments.clear();
    for (final priority in grouped.keys.toList()..sort()) {
      comments.addAll(grouped[priority]!..sort2((e) => e.id));
    }
    for (final lore in comments) {
      String title;
      if ([168, 240].contains(svt?.collectionNo)) {
        title = S.current.svt_profile_n(lore.id);
      } else {
        title = lore.id == 1 ? S.current.svt_profile_info : S.current.svt_profile_n(lore.id - 1);
      }
      List<Widget?> conds = [];
      conds.add(_condDescribe(lore.condType, lore.condValues, lore.condValue2, false));
      if (lore.additionalConds.isNotEmpty) {
        for (final condAdd in lore.additionalConds) {
          final cond = _condDescribe(condAdd.condType, condAdd.condValues, condAdd.condValue2, true);
          conds.add(cond);
        }
      }
      if (lore.condMessage.isNotEmpty) {
        conds.add(Text('(${lore.condMessage})', textScaler: const TextScaler.linear(0.85)));
      }

      children.add(
        ProfileCommentCard(
          title: Text(title),
          subtitle: conds.any((e) => e != null)
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: conds.whereType<Widget>().toList())
              : null,
          comment: lore.comment,
        ),
      );
    }
    if (comments.isEmpty) {
      children.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: _loading
                ? const CircularProgressIndicator()
                : RefreshButton(
                    text: '???',
                    onPressed: () {
                      if (_region != null) {
                        fetchSvt(_region!);
                      }
                    },
                  ),
          ),
        ),
      );
    }
    return children;
  }

  List<Widget> _addWikiProfile(Map<int, List<String>> profiles) {
    List<Widget> children = [];
    final keys = profiles.keys.toList()..sort();
    int maxLength = Maths.max(profiles.values.map((e) => e.length), 0);
    for (int priority = 0; priority < maxLength; priority++) {
      for (final index in keys) {
        final profile = profiles[index]?.getOrNull(priority);
        if (profile == null) continue;
        String title;
        if ([168, 240].contains(svt?.collectionNo)) {
          title = S.current.svt_profile_n(index + 1);
        } else {
          title = index == 0 ? S.current.svt_profile_info : S.current.svt_profile_n(index);
        }
        children.add(ProfileCommentCard(title: Text(title), comment: profile));
      }
    }
    return children;
  }

  List<Widget> _addAprilFool() {
    List<Widget> children = [];
    for (final region in Region.values) {
      final text = widget.svt.extra.aprilFoolProfile.ofRegion(region);
      if (text == null) continue;
      children.add(ProfileCommentCard(title: Text(S.current.april_fool), subtitle: Text(region.upper), comment: text));
    }
    return children;
  }
}

class ProfileCommentCard extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final String comment;
  final EdgeInsetsGeometry? margin;

  const ProfileCommentCard({super.key, required this.title, this.subtitle, required this.comment, this.margin});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      color: Theme.of(context).cardColor.withAlpha(249),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomTile(
            title: title,
            subtitle: subtitle,
            trailing: IconButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: comment));
                EasyLoading.showInfo(S.current.copied);
              },
              icon: const Icon(Icons.copy_rounded),
              tooltip: S.current.copy,
              padding: const EdgeInsets.all(0),
              constraints: const BoxConstraints(),
              iconSize: 18,
            ),
          ),
          kIndentDivider,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(comment, textScaler: const TextScaler.linear(0.9)),
          ),
        ],
      ),
    );
  }
}
