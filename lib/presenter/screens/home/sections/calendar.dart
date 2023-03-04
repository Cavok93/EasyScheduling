import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jiffy/jiffy.dart';
import 'package:today_mate_clean/domain/entities/calendar/day_props.dart';

import '../../../../core/enums/week_day.dart';
import '../../../../states/calendar/calendar_bloc.dart';
import '../../../../states/schedule/schedule_bloc.dart';
import '../../../../states/schedule/schedule_selector.dart';
import '../widgets/calendar_header.dart';
import '../widgets/calender_body.dart';

class Calendar extends StatefulWidget {
  final PageController pageController;

  final int initialPage;
  final int pageCount;
  const Calendar(
      {super.key,
      required this.pageController,
      required this.initialPage,
      required this.pageCount});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarBloc get calendarBloc => context.read<CalendarBloc>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScheduleStateStatusSelector((status) {
      switch (status) {
        case ScheduleStateStatus.loading:
          return _buildLoading();
        case ScheduleStateStatus.loadSuccess:
          return _buildCalendar();
        case ScheduleStateStatus.loadFailure:
          return _buildError();
        default:
          return const SizedBox();
      }
    });
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        const CalendarHeader(),
        Expanded(
          child: PageView.builder(
              onPageChanged: (currentPage) {
                calendarBloc.add(SelectAppBarDateEvent(
                    initialDate: DateItemStore().dateItemProperties.initialDate,
                    initialPage: widget.initialPage,
                    currentPage: currentPage));
              },
              pageSnapping: true,
              controller: widget.pageController,
              itemCount: widget.pageCount,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, pageIndex) {
                final int offset = pageIndex - widget.initialPage;
                final displayMonth =
                    Jiffy(DateItemStore().dateItemProperties.initialDate)
                        .add(months: offset)
                        .dateTime;
                final display =
                    Jiffy(DateTime.utc(displayMonth.year, displayMonth.month));
                final beginOffset = (DateItemStore()
                            .dateItemProperties
                            .startWeekDay
                            .index >
                        display.day - 1)
                    ? display.day -
                        1 +
                        (WeekDay.values.length -
                            DateItemStore()
                                .dateItemProperties
                                .startWeekDay
                                .index)
                    : display.day -
                        1 -
                        DateItemStore().dateItemProperties.startWeekDay.index;
                int daysInMonth = display.daysInMonth;
                Jiffy beginRange =
                    Jiffy(Jiffy(display).subtract(days: beginOffset));
                Jiffy endRange =
                    Jiffy(Jiffy(display).add(days: daysInMonth - 1));
                if (endRange.day != WeekDay.sunday.index + 1) {
                  endRange.add(
                      days: WeekDay.values.length -
                          endRange.day +
                          DateItemStore()
                              .dateItemProperties
                              .startWeekDay
                              .index);
                }
                return CalendarBody(
                    end: endRange,
                    begin: beginRange,
                    displayMonth: displayMonth,
                    beginOffset: beginOffset,
                    daysInMonth: daysInMonth);
              }),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError() {
    return const SizedBox();
  }
}