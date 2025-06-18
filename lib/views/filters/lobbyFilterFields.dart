import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/designs/widgets/text_field.dart';
import 'package:aroundu/views/location/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

// Custom Filter Widget that handles all filter types

class DynamicFilterField extends ConsumerWidget {
  final String type;
  final String title;
  final List<String>? options;
  final dynamic value;
  final Function(String, dynamic) onChanged;
  final Map<String, dynamic> filterData;

  const DynamicFilterField({
    super.key,
    required this.type,
    required this.title,
    this.options,
    required this.value,
    required this.onChanged,
    required this.filterData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: DesignText(
            text: title,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        _buildFilterWidget(context),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFilterWidget(BuildContext context) {
    switch (type) {
      case 'INPUT':
        return _buildInputField();
      case 'RADIO_BUTTON':
        return _buildRadioButtons(); //
      case 'DROP_DOWN_MENU':
        return _buildDropdown(context);
      case 'CHECK_BOX':
        return _buildCheckboxes(); //
      case 'DATE':
        return _buildDatePicker(context); //
      case 'SLIDER':
        return _buildSlider(); //
      case 'LOCATION':
        return _buildLocationField(context); //
      case 'DATE_RANGE':
        return _buildDateRangePicker(context); //
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInputField() {
    return TextFormField(
      initialValue: value?.toString() ?? '',
      onChanged: (val) => onChanged(title, val),
      decoration: InputDecoration(
        hintText: 'Enter ${title}',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildRadioButtons() {
    double screenWidth = Get.width;
     double sw(double size) => screenWidth * size;
    return Card(
      elevation: 1,
      color: const Color(0xFFFAF9F9),
      child: SizedBox(
        width:sw(0.6),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            children: options?.map((option) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: option,
                        groupValue: value?.toString(),
                        onChanged: (val) => onChanged(title, val),
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return const Color(0xFFEC4B5D);
                          }
                          return const Color(0xFFBBBCBD).withOpacity(0.5);
                        }),
                        splashRadius: 0.5,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      DesignText(
                        text: option,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  );
                }).toList() ??
                [],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFEC4B5D),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF444444),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            elevation: 1,
            value: value?.toString(),
            isExpanded: true,
            menuMaxHeight: 300,
            hint: DesignText(
              text: 'Select ${title}',
              fontSize: 12,
              color: const Color(0xFF444444),
            ),
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Color(0xFF444444),
            ),
            // style: const TextStyle(
            //   color: Color(0xFF444444),
            //   fontSize: 14,
            // ),
            dropdownColor: Colors.white,

            // Add border radius to the dropdown menu
            borderRadius: BorderRadius.circular(16),
            items: options?.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (val) => onChanged(title, val),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxes() {
    double screenWidth = Get.width;
     double sw(double size) => screenWidth * size;
    return Card(
      elevation: 1,
      color: const Color(0xFFFAF9F9),
      child: SizedBox(
        width: sw(0.6),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            children: options?.map((option) {
                  bool isSelected =
                      (value as List<String>?)?.contains(option) ?? false;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (bool? checked) {
                          List<String> currentSelected =
                              List<String>.from(value ?? []);
                          if (checked ?? false) {
                            currentSelected.add(option);
                          } else {
                            currentSelected.remove(option);
                          }
                          onChanged(title, currentSelected);
                        },
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return const Color(0xFFEC4B5D);
                          }
                          return const Color(0xFFFAF9F9);
                        }),
                        side: WidgetStateBorderSide.resolveWith(
                          (states) {
                            if (states.contains(WidgetState.selected)) {
                              return null;
                            }
                            return const BorderSide(
                              width: 1.5,
                              color: Color(0xFFBBBCBD),
                            );
                          },
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      DesignText(
                        text: option,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  );
                }).toList() ??
                [],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: value is String
              ? DateTime.fromMillisecondsSinceEpoch(value)
              : (value ?? DateTime.now()),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFFEC4B5D),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Color(0xFF444444),
                  secondary: Color(0xFFEC4B5D),
                  onSecondary: Colors.white,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFEC4B5D),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                dialogBackgroundColor: Colors.white,
                datePickerTheme: DatePickerThemeData(
                  backgroundColor: Colors.white,
                  headerBackgroundColor: const Color(0xFFEC4B5D),
                  headerForegroundColor: Colors.white,
                  dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const Color(0xFFEC4B5D);
                    }
                    return Colors.transparent;
                  }),
                  todayBackgroundColor: WidgetStateProperty.resolveWith(
                    (states) => const Color(0xFFEC4B5D).withOpacity(0.1),
                  ),
                  yearBackgroundColor:
                      WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const Color(0xFFEC4B5D);
                    }
                    return Colors.transparent;
                  }),
                  dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return const Color(0xFF444444);
                  }),
                  yearForegroundColor:
                      WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return const Color(0xFF444444);
                  }),
                  surfaceTintColor: Colors.transparent,
                ),
                textTheme: const TextTheme(
                  bodyMedium: TextStyle(color: Color(0xFF444444)),
                  bodyLarge: TextStyle(color: Color(0xFF444444)),
                  titleMedium: TextStyle(color: Color(0xFF444444)),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
         onChanged(title, picked.millisecondsSinceEpoch.toString());
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFBBBCBD).withOpacity(0.5)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DesignText(
              text: value != null
                  ? DateFormat('MMM dd, yyyy')
                      .format(value is String ? DateTime.fromMillisecondsSinceEpoch(int.parse(value)) : value)
                  : 'Select Date',
              fontSize: 14,
              color: const Color(0xFFBBBCBD),
            ),
            Icon(
              Icons.calendar_today,
              size: 20,
              color: const Color(0xFFBBBCBD),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider() {
    final double min = filterData['min']?.toDouble() ?? 0.0;
    final double max = filterData['max']?.toDouble() ?? 100.0;
    RangeValues currentRangeValues = RangeValues(
      value?['start']?.toDouble() ?? min,
      value?['end']?.toDouble() ?? max,
    );
    return Column(
      children: [
        RangeSlider(
          values: RangeValues(
            value?['start']?.toDouble() ?? min,
            value?['end']?.toDouble() ?? max,
          ),
          min: min,
          max: max,
          divisions: (max - min)
              .toInt(), // Ensure the range is divided into integer steps
          activeColor: const Color(0xFFEC4B5D),
          inactiveColor: const Color(0xFFEC4B5D).withOpacity(0.2),
          // labels: RangeLabels(
          //   value?['start']?.toString() ?? min.toString(),
          //   value?['end']?.toString() ?? max.toString(),
          // ),
          onChanged: (RangeValues values) {
            onChanged(title, {
              'start': values.start.round(), // Round the values to integers
              'end': values.end.round(),
            });
          },
          overlayColor: WidgetStateProperty.resolveWith(
            (states) => const Color(0xFFEC4B5D).withOpacity(0.1),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${value?['start']?.toInt() ?? min.toInt()}',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF444444),
                ),
              ),
              Text(
                '${value?['end']?.toInt() ?? max.toInt()}',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF444444),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField(BuildContext context) {
    return WrapperTextField(
      text: value?['structured_formatting']['main_text'] ?? '',
      hintText: 'Add location',
      suffixOnPressed: () async {
        // Proceed with location selection
        final location = await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) {
          return const Location();
        }));

        if (location != null) {
          final locationJson = location.toJson();
          print('New location added: $locationJson');
          onChanged(title, locationJson);
        }
      },
    );
  }

  Widget _buildDateRangePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          initialDateRange: value != null
              ? DateTimeRange(
                  start: value['start'] is String
                      ? DateTime.fromMillisecondsSinceEpoch(int.parse(value['start']))
                      : value['start'],
                  end: value['end'] is String
                      ? DateTime.fromMillisecondsSinceEpoch(int.parse(value['end']))
                      : value['end'],
                )
              : null,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFFEC4B5D),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Color(0xFF444444),
                  secondary: Color(0xFFEC4B5D),
                  onSecondary: Colors.white,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFEC4B5D),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                dialogBackgroundColor: Colors.white,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFFEC4B5D),
                  foregroundColor: Colors.white,
                ),
                datePickerTheme: DatePickerThemeData(
                  backgroundColor: Colors.white,
                  rangeSelectionBackgroundColor:
                      const Color(0xFFEC4B5D).withOpacity(0.1),
                  rangePickerHeaderBackgroundColor: const Color(0xFFEC4B5D),
                  rangePickerHeaderForegroundColor: Colors.white,
                  rangeSelectionOverlayColor: WidgetStateProperty.resolveWith(
                    (states) => const Color(0xFFEC4B5D).withOpacity(0.2),
                  ),
                  dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return const Color(0xFFEC4B5D);
                    }
                    return Colors.transparent;
                  }),
                  todayBackgroundColor: WidgetStateProperty.resolveWith(
                    (states) => const Color(0xFFEC4B5D).withOpacity(0.1),
                  ),
                  headerForegroundColor: const Color(0xFFEC4B5D),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onChanged(title, {
            'start': picked.start.millisecondsSinceEpoch.toString(),
            'end': picked.end.millisecondsSinceEpoch.toString(),
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DesignText(
              text: value != null
                  ? '${DateFormat('MMM dd').format(value['start'] is String ? DateTime.fromMillisecondsSinceEpoch(int.parse(value['start'])) : value['start'])} - ${DateFormat('MMM dd').format(value['end'] is String ? DateTime.fromMillisecondsSinceEpoch(int.parse(value['end'])) : value['end'])}'
                  : 'Select Date Range',
              fontSize: 14,
              color: const Color(0xFFBBBCBD),
            ),
            Icon(
              Icons.date_range,
              size: 20,
              color: const Color(0xFFBBBCBD),
            ),
          ],
        ),
      ),
    );
  }
}
