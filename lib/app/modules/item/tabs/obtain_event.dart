import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../event/tabs/exchange_ticket_tab.dart';

class ItemObtainEventTab extends StatefulWidget {
  final int itemId;
  final bool showOutdated;

  const ItemObtainEventTab({super.key, required this.itemId, this.showOutdated = false});

  @override
  _ItemObtainEventTabState createState() => _ItemObtainEventTabState();
}

class _ItemObtainEventTabState extends State<ItemObtainEventTab> {
  @override
  Widget build(BuildContext context) {
    return db.onUserData((context, _) {
      List<Widget> children = [_limitEventAccordion, _ticketAccordion, _limitedMissionAccordion, _mainRecordAccordion];
      return InheritSelectionArea(
        child: ListView.separated(
          itemBuilder: (context, index) => children[index],
          separatorBuilder: (context, index) => kDefaultDivider,
          itemCount: children.length,
        ),
      );
    });
  }

  bool _whetherToShow(bool planned, bool outdated) {
    if (planned) return true;
    if (!widget.showOutdated && outdated) return false;
    return true;
  }

  TextStyle? _textStyle([bool highlight = false, bool outdated = false]) {
    if (!highlight && !outdated) return null;
    return TextStyle(
      color: highlight
          ? Colors.blueAccent
          : outdated
          ? Colors.grey
          : null,
    );
  }

  Widget get _limitEventAccordion {
    List<Widget> children = [];
    final limitEvents = db.gameData.events.values
        .where((event) => _whetherToShow(db.curUser.limitEventPlanOf(event.id).enabled, event.isOutdated()))
        .toList();
    limitEvents.sort2((e) => e.startedAt);
    int count = 0;
    for (final event in limitEvents) {
      final plan = db.curUser.limitEventPlanOf(event.id);
      List<Widget> texts = [];
      int itemFixed = event.statItemFixed[widget.itemId] ?? 0;
      bool hasExtra = event.statItemExtra.contains(widget.itemId);
      bool hasLottery = event.statItemLottery.values.any((e) => (e[widget.itemId] ?? 0) > 0);
      bool hasCustom = plan.enabled && !event.isEmpty && plan.customItems.containsKey(widget.itemId);
      if (itemFixed <= 0 && !hasLottery && !hasExtra && !hasCustom) {
        continue;
      }
      if (!_whetherToShow(plan.enabled, event.isOutdated())) {
        continue;
      }
      int itemGot = db.itemCenter.calcOneEvent(event, plan)[widget.itemId] ?? 0;
      TextStyle style = _textStyle(plan.enabled, event.isOutdated()) ?? const TextStyle();
      int addNum = 0;
      if (widget.itemId == Items.grailId) {
        addNum =
            (event.statItemFixed[Items.grailToCrystalId] ?? 0) + (event.statItemFixed[Items.grailFragId] ?? 0) ~/ 7;
      } else if (widget.itemId == Items.crystalId) {
        addNum = event.statItemFixed[Items.grailToCrystalId] ?? 0;
      }
      String suffix = hasLottery || hasExtra ? '+' : '';
      if (addNum > 0) {
        suffix += '+$addNum';
      }
      texts.add(
        Text('${itemGot.format()}/${itemFixed.format()}$suffix', style: style.copyWith(fontWeight: FontWeight.w500)),
      );
      for (final lotteryId in event.statItemLottery.keys) {
        int itemPerLottery = event.statItemLottery[lotteryId]![widget.itemId] ?? 0;
        if (itemPerLottery > 0) {
          texts.add(
            Text(
              '${S.current.event_lottery_unlimited} ${plan.lotteries[lotteryId] ?? 0} ×${itemPerLottery.format()}',
              style: style.copyWith(fontWeight: FontWeight.w300),
            ),
          );
        }
      }

      count += itemGot;
      children.add(
        ListTile(
          title: AutoSizeText(
            event.shownName,
            maxFontSize: 14,
            maxLines: 2,
            style: _textStyle(false, event.isOutdated()),
          ),
          onTap: () {
            router.push(url: event.route);
          },
          trailing: Opacity(
            opacity: plan.enabled || !event.isOutdated() ? 1 : 0.75,
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: texts),
          ),
        ),
      );
    }
    return _getAccordion(title: Text(S.current.limited_event), trailing: Text(count.format()), children: children);
  }

  Widget get _ticketAccordion {
    List<Widget> children = [];
    final exchangeTickets = db.gameData.exchangeTickets.values.toList();
    exchangeTickets.sort2((a) => a.id);
    int count = 0;
    for (final ticket in exchangeTickets) {
      int itemIndex = ticket.of(db.curUser.region).indexOf(widget.itemId);
      if (itemIndex < 0) {
        continue;
      }

      final plan = db.curUser.ticketOf(ticket.id);
      if (!_whetherToShow(plan.enabled, ticket.isOutdated())) {
        continue;
      }

      int itemNum = plan[itemIndex] * ticket.multiplier;
      count += itemNum;
      children.add(
        SimpleAccordion(
          expanded: false,
          headerBuilder: (context, _) => ListTile(
            title: Text(
              '${S.current.exchange_ticket_short} ${ticket.dateStr}',
              style: _textStyle(false, ticket.isOutdated()),
              textScaler: const TextScaler.linear(0.9),
            ),
            subtitle: AutoSizeText(
              ticket.of(db.curUser.region).map((e) => GameCardMixin.anyCardItemName(e).l).join('/'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text('$itemNum/${ticket.maxCount}', style: _textStyle(plan.enabled, ticket.isOutdated())),
          ),
          contentBuilder: (context) => ExchangeTicketTab(id: ticket.id),
          expandIconBuilder: (_, _) => const SizedBox(),
          disableAnimation: true,
        ),
      );
    }
    return _getAccordion(title: Text(S.current.exchange_ticket), trailing: Text(count.toString()), children: children);
  }

  Widget get _limitedMissionAccordion {
    List<Widget> children = [];
    final masterMissions = db.gameData.masterMissions.values
        .where((e) => const [MissionType.limited, MissionType.extra].contains(e.type))
        .toList();
    masterMissions.sort2((a) => -a.endedAt);
    int count = 0;
    for (final mission in masterMissions) {
      int itemNum = mission.gifts[widget.itemId] ?? 0;
      if (itemNum <= 0) continue;
      if (!_whetherToShow(false, mission.isOutdated())) {
        continue;
      }

      count += itemNum;
      children.add(
        ListTile(
          title: Text(
            mission.getDispName(),
            style: _textStyle(false, mission.isOutdated()),
            textScaler: const TextScaler.linear(0.9),
          ),
          subtitle: AutoSizeText(
            [mission.startedAt, mission.endedAt].map((e) => e.sec2date().toDateString()).join(' ~ '),
            maxLines: 1,
          ),
          trailing: Text(itemNum.format(), style: _textStyle(false, mission.isOutdated())),
          onTap: () {
            mission.routeTo();
          },
        ),
      );
    }
    return _getAccordion(
      title: Text('${S.current.master_mission}(${Transl.enums(MissionType.limited, (enums) => enums.missionType).l})'),
      trailing: Text(count.format()),
      children: children,
    );
  }

  Widget get _mainRecordAccordion {
    List<Widget> children = [];
    final mainRecords = db.gameData.mainStories.values.toList();
    mainRecords.sort2((e) => e.id);
    int count = 0, totalCount = 0;
    for (final record in mainRecords) {
      int dropCount = record.itemDrop[widget.itemId] ?? 0;
      int rewardCount = record.itemReward[widget.itemId] ?? 0;
      totalCount += dropCount + rewardCount;
      if (dropCount <= 0 && rewardCount <= 0) {
        continue;
      }
      final plan = db.curUser.mainStoryOf(record.id);
      if (!_whetherToShow(plan.enabled, record.isOutdated())) {
        continue;
      }
      if (plan.fixedDrop) count += dropCount;
      if (plan.questReward) count += rewardCount;
      children.add(
        ListTile(
          title: AutoSizeText(
            record.lLongName.l,
            maxFontSize: 14,
            maxLines: 2,
            style: _textStyle(false, record.isOutdated()),
          ),
          onTap: () {
            router.push(url: record.route);
          },
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (rewardCount > 0)
                Text(
                  '${S.current.quest_reward_short}'
                  ' ${rewardCount.format()}',
                  style: _textStyle(plan.questReward, record.isOutdated()),
                ),
              if (dropCount > 0)
                Text(
                  '${S.current.quest_fixed_drop_short}'
                  ' ${dropCount.format()}',
                  style: _textStyle(plan.fixedDrop, record.isOutdated()),
                ),
            ],
          ),
        ),
      );
    }
    return _getAccordion(
      title: Text(S.current.main_story),
      trailing: Text('${count.format()}/${totalCount.format()}'),
      children: children,
    );
  }

  Widget _getAccordion({required Widget title, Widget? trailing, required List<Widget> children}) {
    return SimpleAccordion(
      expanded: false,
      headerBuilder: (context, expanded) => ListTile(
        leading: const Icon(Icons.event),
        title: title,
        trailing: trailing,
        contentPadding: const EdgeInsetsDirectional.only(start: 16),
      ),
      contentBuilder: (context) => ListView.separated(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) => children[index],
        itemCount: children.length,
        separatorBuilder: (context, index) => kDefaultDivider,
      ),
    );
  }
}
