// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:today_mate_clean/core/errors/exceptions.dart';
import 'package:today_mate_clean/core/errors/failures.dart';
import 'package:today_mate_clean/data/datasources/local/schedule_database.dart';
import 'package:today_mate_clean/data/mappers/schedule_mapper.dart';
import 'package:today_mate_clean/domain/entities/schedule/schedule.dart';
import 'package:today_mate_clean/domain/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleDataBase scheduleDataBase;
  ScheduleRepositoryImpl({
    required this.scheduleDataBase,
  });

  @override
  Future<List<Schedule>> getSchedules() async {
    try {
      final todoModelList = await scheduleDataBase.getSchedules();
      return ScheduleMapper.toEntities(todoModelList);
    } on CacheException catch (e) {
      throw CacheFailure(message: e.toString());
    }
  }

  @override
  Future<Schedule> createSchedule(Schedule schedule) async {
    try {
      final todoModel =
          await scheduleDataBase.insertSchedule(ScheduleMapper.toMap(schedule));
      return ScheduleMapper.toEntity(todoModel);
    } on CacheException catch (e) {
      throw CacheFailure(message: e.toString());
    }
  }

  @override
  Future<void> deleteSchedule(int id) async {
    try {
      await scheduleDataBase.deleteSchedule(id);
    } on CacheException catch (e) {
      throw CacheFailure(message: e.toString());
    }
  }

  @override
  Future<void> updateSchedule(Schedule schedule) async {
    try {
      await scheduleDataBase.updateSchedule(ScheduleMapper.toMap(schedule));
    } on CacheException catch (e) {
      throw CacheFailure(message: e.toString());
    }
  }
}
