
import 'package:flutter/material.dart';
import '../data/table_repository.dart';
import '../models/table_model.dart';
import '../widgets/custom_appBar.dart';
import 'order_confirmation.dart';

class TableSelection extends StatefulWidget {
  const TableSelection({Key? key}) : super(key: key);

  @override
  State<TableSelection> createState() => _TableBookingScreenState();
}

class _TableBookingScreenState extends State<TableSelection> {
  final List<TableModel> firstFloorTables = TableRepository().firstFloorTables;
  final List<TableModel> secondFloorTables = TableRepository().secondFloorTables;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate responsive padding based on screen size
    final horizontalPadding = screenWidth * 0.03; // 3% of screen width
    final verticalPadding = screenHeight * 0.02; // 2% of screen height

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          custom_appBar(),
          
          // Main Content - Scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Legend
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xffD9D9D9),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildLegendItem('Available', Colors.green),
                        const SizedBox(width: 400),
                        _buildLegendItem('Occupied', Colors.red),
                      ],
                    ),
                  ),
                  SizedBox(height: verticalPadding),

                  // First Floor Section
                  _buildFloorSection(
                    'First Floor',
                    firstFloorTables,
                    horizontalPadding,
                    verticalPadding,
                  ),

                  SizedBox(height: verticalPadding),

                  // Second Floor Section
                  _buildFloorSection(
                    'Second Floor',
                    secondFloorTables,
                    horizontalPadding,
                    verticalPadding,
                  ),
                ],
              ),
            ),
          ),

  
        ],
      ),
      // Floating Takeaway Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderConfirmationScreen(
                userName: '', // Pass actual userName if available
                category: '', // Pass actual category if available
                diningOption: 'Take Away',
              ),
            ),
          );
        },
        backgroundColor: Color(0xff9D9D9D),
        icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
        label: const Text(
          'Takeaway',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFloorSection(
    String floorName,
    List<TableModel> tables,
    double horizontalPadding,
    double verticalPadding,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.black),
      ),
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            floorName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: verticalPadding),

          // Tables Grid with dynamic spacing
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;

              // Fixed card width (adjust this value as needed)
              const cardWidth = 350.0;
              const crossAxisCount = 3;

              // Calculate spacing based on remaining space
              final totalCardWidth = cardWidth * crossAxisCount;
              final remainingSpace = availableWidth - totalCardWidth;
              final spacing = remainingSpace > 0 
                  ? (remainingSpace / (crossAxisCount + 1)).clamp(16.0, 80.0) 
                  : 16.0;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: 2.5,
                ),
                itemCount: tables.length,
                itemBuilder: (context, index) {
                  return _buildTableCard(tables, index);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTableCard(List<TableModel> tables, int index) {
    final table = tables[index];
    Color pointColor;
    // You can expand this logic for more statuses in the future
    if (table.available) {
      pointColor = Colors.green;
    } else {
      pointColor = Colors.red;
    }
    return InkWell(
      onTap: table.available
          ? () {
              setState(() {
                table.available = false;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderConfirmationScreen(
                    userName: '', // Pass actual userName if available
                    category: '', // Pass actual category if available
                    diningOption: 'Service (Table ${table.name})',
                  ),
                ),
              );
            }
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: table.available ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: table.available ? Colors.grey[300]! : Colors.grey[400]!,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  table.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${table.seats}-Seats',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: pointColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}