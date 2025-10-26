import '../models/table_model.dart';

class TableRepository {
  static final TableRepository _instance = TableRepository._internal();
  factory TableRepository() => _instance;
  TableRepository._internal();

  final List<TableModel> firstFloorTables = [
    TableModel(id: 1, name: 'Table 01', seats: 4, available: true),
    TableModel(id: 2, name: 'Table 02', seats: 2, available: true),
    TableModel(id: 3, name: 'Table 03', seats: 3, available: true),
    TableModel(id: 4, name: 'Table 04', seats: 4, available: true),
    TableModel(id: 5, name: 'Table 05', seats: 2, available: true),
    TableModel(id: 6, name: 'Table 06', seats: 3, available: true),
  ];

  final List<TableModel> secondFloorTables = [
    TableModel(id: 7, name: 'Table 07', seats: 6, available: true),
    TableModel(id: 8, name: 'Table 08', seats: 4, available: true),
    TableModel(id: 9, name: 'Table 09', seats: 2, available: true),
    TableModel(id: 10, name: 'Table 10', seats: 4, available: true),
    TableModel(id: 11, name: 'Table 11', seats: 3, available: true),
    TableModel(id: 12, name: 'Table 12', seats: 2, available: true),
  ];
}
