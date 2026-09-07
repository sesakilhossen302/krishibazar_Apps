import 'package:flutter/material.dart';

class CustomNavBarItem {
  final IconData icon;
  final String label;

  CustomNavBarItem({required this.icon, required this.label});
}

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<CustomNavBarItem> items;
  final ValueChanged<int> onItemSelected;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = selectedIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => onItemSelected(index),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon with Pill Highlight when selected
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE8F5E9) // Soft light green pill
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Icon(
                            item.icon,
                            color: isSelected
                                ? const Color(0xFF166534) // Active Green
                                : const Color(0xFF1E293B), // Inactive Slate/Navy
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Text Label
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF166534) // Active Green Text
                              : const Color(0xFF1E293B), // Inactive Dark Text
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
