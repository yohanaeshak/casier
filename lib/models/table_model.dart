class TableModel {
  final int id;
  final String name;
  final int seats;
  bool available;

  TableModel({
    required this.id,
    required this.name,
    required this.seats,
    required this.available,
  });
}