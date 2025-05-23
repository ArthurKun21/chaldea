import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class PlayerSvtDefaultLvEditPage extends StatefulWidget {
  const PlayerSvtDefaultLvEditPage({super.key});

  @override
  State<PlayerSvtDefaultLvEditPage> createState() => _PlayerSvtDefaultLvEditPageState();
}

class _PlayerSvtDefaultLvEditPageState extends State<PlayerSvtDefaultLvEditPage> {
  PlayerSvtDefaultData get defaultLvs => db.settings.battleSim.defaultLvs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.default_lvs)),
      body: ListView(
        children: [
          CheckboxListTile(
            dense: true,
            title: Text('Lv. @${S.current.max_limit_break}'),
            value: defaultLvs.useMaxLv,
            onChanged: (v) {
              setState(() {
                if (v != null) defaultLvs.useMaxLv = v;
              });
            },
          ),
          disable(
            disabled: defaultLvs.useMaxLv,
            child: SliderWithPrefix(
              label: 'Level',
              min: 1,
              max: 120,
              value: defaultLvs.lv,
              onChange: (v) {
                setState(() {
                  defaultLvs.lv = v.round();
                });
              },
            ),
          ),
          SliderWithPrefix(
            label: S.current.ascension_short,
            min: 0,
            max: 4,
            value: defaultLvs.limitCount,
            onChange: (v) {
              setState(() {
                defaultLvs.limitCount = v.round();
              });
            },
          ),
          SliderWithPrefix(
            label: 'ATK ${S.current.foukun}',
            min: 0,
            max: 200,
            value: defaultLvs.atkFou,
            onChange: (v) {
              setState(() {
                defaultLvs.atkFou = v.round();
              });
            },
          ),
          SliderWithPrefix(
            label: 'HP ${S.current.foukun}',
            min: 0,
            max: 200,
            value: defaultLvs.hpFou,
            onChange: (v) {
              setState(() {
                defaultLvs.hpFou = v.round();
              });
            },
          ),
          const Divider(height: 16),
          CheckboxListTile(
            dense: true,
            title: Text('${S.current.np_short} Lv: ${S.current.general_default}'),
            subtitle: Text('0-3$kStarChar+${S.current.event}: Lv.5, 4$kStarChar: Lv.2, 5$kStarChar: Lv.1'),
            value: defaultLvs.useDefaultTdLv,
            onChanged: (v) {
              setState(() {
                if (v != null) defaultLvs.useDefaultTdLv = v;
              });
            },
          ),
          disable(
            disabled: defaultLvs.useDefaultTdLv,
            child: SliderWithPrefix(
              label: '${S.current.np_short} Lv',
              min: 1,
              max: 5,
              value: defaultLvs.tdLv,
              onChange: (v) {
                setState(() {
                  defaultLvs.tdLv = v.round();
                });
              },
            ),
          ),
          const Divider(height: 16),
          SliderWithPrefix(
            label: S.current.active_skill_short,
            min: 1,
            max: 10,
            value: defaultLvs.activeSkillLv,
            onChange: (v) {
              setState(() {
                defaultLvs.activeSkillLv = v.round();
              });
            },
          ),
          const Divider(height: 16),
          for (int index = 0; index < defaultLvs.appendLvs.length; index++)
            SliderWithPrefix(
              label: '${S.current.append_skill_short}${index + 1}',
              min: 0,
              max: 10,
              value: defaultLvs.appendLvs[index],
              onChange: (v) {
                setState(() {
                  defaultLvs.appendLvs[index] = v.round();
                });
              },
            ),
          const Divider(height: 16),
          CheckboxListTile(
            dense: true,
            title: Text('${S.current.craft_essence}: ${S.current.max_limit_break}'),
            value: defaultLvs.ceMaxLimitBreak,
            onChanged: (v) {
              setState(() {
                if (v != null) defaultLvs.ceMaxLimitBreak = v;
              });
            },
          ),
          CheckboxListTile(
            dense: true,
            title: Text('${S.current.craft_essence}: Lv. MAX'),
            value: defaultLvs.ceMaxLv,
            onChanged: (v) {
              setState(() {
                if (v != null) defaultLvs.ceMaxLv = v;
              });
            },
          ),
          const Divider(height: 16),
          SFooter(S.current.default_lvs_hint),
        ],
      ),
    );
  }

  Widget disable({required bool disabled, required Widget child}) {
    if (!disabled) return child;
    return Opacity(opacity: 0.5, child: AbsorbPointer(child: child));
  }
}
