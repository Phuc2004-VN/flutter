import 'package:flutter/material.dart';
// Might need this for date formatting, though we pass strings

class GreetingAndFiltersSection extends StatelessWidget {
  final bool isDark;
  final String greeting;
  final String currentDate;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onFocusModePressed;

  const GreetingAndFiltersSection({
    Key? key,
    required this.isDark,
    required this.greeting,
    required this.currentDate,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onFocusModePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? Colors.blueGrey.shade900 : Colors.blue.shade800,
            isDark ? Colors.blueGrey.shade700 : Colors.blue.shade500,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.blue.shade200).withValues(alpha:0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentDate,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.85),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // The Row with user name and icon is removed from here
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Placeholder for Quick Filters (Dropdown/Buttons)
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedFilter,
                    icon: Container(),
                    underline: Container(),
                    style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                    dropdownColor: isDark ? Colors.blueGrey.shade800 : Colors.white,
                    items: <String>['Tất cả', 'Hôm nay', 'Hoàn thành', 'Chưa hoàn thành'].map((String value) {
                      IconData icon;
                      switch (value) {
                        case 'Tất cả':
                          icon = Icons.list;
                          break;
                        case 'Hôm nay':
                          icon = Icons.calendar_today;
                          break;
                        case 'Hoàn thành':
                          icon = Icons.check_circle_outline;
                          break;
                        case 'Chưa hoàn thành':
                          icon = Icons.radio_button_unchecked;
                          break;
                        default:
                          icon = Icons.filter_list;
                      }

                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(icon, size: 20, color: isDark ? Colors.white70 : Colors.grey.shade600),
                            const SizedBox(width: 8),
                            Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        onFilterChanged(newValue);
                      }
                    },
                    selectedItemBuilder: (BuildContext context) {
                      return <String>['Tất cả', 'Hôm nay', 'Hoàn thành', 'Chưa hoàn thành'].map((String value) {
                        IconData icon;
                        switch (value) {
                          case 'Tất cả':
                            icon = Icons.list;
                            break;
                          case 'Hôm nay':
                            icon = Icons.calendar_today;
                            break;
                          case 'Hoàn thành':
                            icon = Icons.check_circle_outline;
                            break;
                          case 'Chưa hoàn thành':
                            icon = Icons.radio_button_unchecked;
                            break;
                          default:
                            icon = Icons.filter_list;
                        }

                        return Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 20, color: isDark ? Colors.white70 : Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Text(
                                value,
                                style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                const SizedBox(width: 12), // Spacing between filters and button
                // "Chế độ tập trung" Button
                Tooltip(
                  message: 'Chế độ tập trung', // Tooltip
                  child: ElevatedButton.icon(
                  onPressed: onFocusModePressed,
                    icon: const Icon(Icons.timer_outlined, size: 20), // Use timer icon
                    label: const Text('Chế độ tập trung'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: (isDark ? Colors.blue.shade300 : Colors.blue.shade700).withValues(alpha:0.5)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 