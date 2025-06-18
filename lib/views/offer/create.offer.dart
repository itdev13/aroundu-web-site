import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/views/offer/manage_offer.dart';
import 'package:aroundu/views/profile/services/apis.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditOfferScreen extends StatefulWidget {
  final String lobbyId;
  final String editPage;

  const EditOfferScreen({super.key, required this.lobbyId, this.editPage = ""});
  @override
  State<EditOfferScreen> createState() => _EditOfferScreenState();
}

class _EditOfferScreenState extends State<EditOfferScreen> {
  final TextEditingController discountValueController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedDiscountType;
  List<String> selectedEligibility = [];
  bool isActive = true;
  bool isLoading = false;

  // @override
  // void initState() {
  //   super.initState();
  //   if (widget.editPage == "edit") {
  //     _fetchOfferDetails();
  //   }
  // }

  @override
  void dispose() {
    discountValueController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  // Future<void> _fetchOfferDetails() async {
  //   setState(() {
  //     isLoading = true;
  //   });

  //   try {
  //     var offerDetails = await Api.getOffers(entityId:  widget.lobbyId);

  //     if (mounted) {
  //       setState(() {
  //         // Check if offerDetails is not null and has the expected structure
  //         if (offerDetails != null) {
  //           selectedDiscountType = offerDetails['discountType'] as String?;
  //           discountValueController.text = offerDetails['discountValue']?.toString() ?? '';
  //           startDateController.text = offerDetails['startDate']?.toString() ?? '';
  //           endDateController.text = offerDetails['endDate']?.toString() ?? '';

  //           // Safely convert eligibility to List<String>
  //           if (offerDetails['eligibility'] is List) {
  //             selectedEligibility = List<String>.from(
  //                 offerDetails['eligibility'].map((e) => e.toString()));
  //           } else {
  //             selectedEligibility = [];
  //           }

  //           isActive = offerDetails['isActive'] == true;
  //         }
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text("Failed to load offer details: ${e.toString()}"),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Already prevents past dates
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFEC4B5D),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

        // Validate dates after selection
        if (controller == startDateController &&
            endDateController.text.isNotEmpty) {
          // Check if end date is before start date
          DateTime endDate = DateTime.parse(endDateController.text);
          if (endDate.isBefore(picked)) {
            // Show error message
            CustomSnackBar.show(
              context: context,
              message: "End date must be after start date",
              type: SnackBarType.error,
            );
            // Reset end date
            endDateController.clear();
          }
        } else if (controller == endDateController &&
            startDateController.text.isNotEmpty) {
          // Check if start date is after end date
          DateTime startDate = DateTime.parse(startDateController.text);
          if (picked.isBefore(startDate)) {
            // Show error message
            CustomSnackBar.show(
              context: context,
              message: "End date must be after start date",
              type: SnackBarType.error,
            );
            // Reset the end date
            endDateController.clear();
          }
        }
      });
    }
  }

  void _clearForm() {
    setState(() {
      discountValueController.clear();
      startDateController.clear();
      endDateController.clear();
      selectedDiscountType = null;
      selectedEligibility = [];
      isActive = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: DesignText(
            text: widget.editPage == "edit" ? "Edit Offer" : "Create Offer",
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black,
              size: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  widget.editPage == "edit" ? () => Get.back() : _clearForm,
              child: DesignText(
                text: widget.editPage == "edit" ? "Cancel" : "Clear",
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF3E79A1),
              ),
            )
          ],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFEC4B5D)))
            : Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with icon
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.local_offer_rounded,
                                  color: const Color(0xFFEC4B5D),
                                  size: 32,
                                ),
                                SizedBox(height: 8),
                                DesignText(
                                  text: "Apply discount offer for your lobby",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                SizedBox(height: 4),
                                DesignText(
                                  text:
                                      "Attract more participants with special offers",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey.shade700,
                                ),
                              ],
                            ),
                          ),
                        ),
      
                        SizedBox(height: 24),
      
                        // Discount Type Section
                        _buildSectionTitle("Discount Details"),
                        SizedBox(height: 16),
      
                        _buildDropdownField(
                            "Discount Type *",
                            ["Percentage", "Flat"],
                            selectedDiscountType, (value) {
                          setState(() {
                            selectedDiscountType = value;
                            discountValueController.text = "0";
                          });
                        }),
      
                        SizedBox(height: 16),
      
                        _buildTextField(
                          "Set Discount Value *",
                          selectedDiscountType == "Percentage"
                              ? "e.g., 10 (without % symbol)"
                              : "e.g., 100 (without ₹ symbol)",
                          discountValueController,
                          onChanged: (value) {
                            if (value.isEmpty) return;
      
                            // Check if value contains negative sign or invalid characters
                            if (value.contains('-') ||
                                value.contains(RegExp(r'[^\d]'))) {
                              // Reset to 0 for negative or invalid input
                              discountValueController.text = "0";
                              discountValueController.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset:
                                          discountValueController.text.length));
                              return;
                            }
      
                            // Parse value as integer
                            int? parsedValue = int.tryParse(value);
                            if (parsedValue == null) return;
      
                            // Check percentage limits
                            if (selectedDiscountType == "Percentage" &&
                                parsedValue > 100) {
                              discountValueController.text = "100";
                              discountValueController.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset:
                                          discountValueController.text.length));
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a discount value";
                            }
      
                            // Check if value contains negative sign or invalid characters
                            if (value.contains('-') ||
                                value.contains(RegExp(r'[^\d]'))) {
                              // Reset to 0 for negative or invalid input
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                discountValueController.text = "0";
                              });
                              return "Value must be positive. Reset to 0.";
                            }
      
                            // Parse value as integer
                            int? parsedValue = int.tryParse(value);
                            if (parsedValue == null) {
                              return "Please enter a valid number";
                            }
      
                            // Check percentage limits
                            if (selectedDiscountType == "Percentage" &&
                                parsedValue > 100) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                discountValueController.text = "100";
                              });
                              return "Percentage cannot exceed 100%. Reset to 100.";
                            }
      
                            return null;
                          },
                        ),
      
                        SizedBox(height: 24),
      
                        // Date Section
                        _buildSectionTitle("Offer Duration"),
                        SizedBox(height: 16),
      
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateField(
                                "Start Date *",
                                startDateController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Required";
                                  }
      
                                  // Validate date format
                                  DateTime? startDate = DateTime.tryParse(value);
                                  if (startDate == null) {
                                    return "Invalid date format";
                                  }
      
                                  // Check if start date is in the past
                                  if (startDate.isBefore(DateTime.now()
                                      .subtract(const Duration(days: 1)))) {
                                    return "Cannot select past dates";
                                  }
      
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildDateField(
                                "End Date *",
                                endDateController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Required";
                                  }
      
                                  // Validate date format
                                  DateTime? endDate = DateTime.tryParse(value);
                                  if (endDate == null) {
                                    return "Invalid date format";
                                  }
      
                                  // Check if end date is in the past
                                  if (endDate.isBefore(DateTime.now()
                                      .subtract(const Duration(days: 1)))) {
                                    return "Cannot select past dates";
                                  }
      
                                  // Check if start date is selected and valid
                                  if (startDateController.text.isNotEmpty) {
                                    DateTime? startDate = DateTime.tryParse(
                                        startDateController.text);
                                    if (startDate != null &&
                                        endDate.isBefore(startDate)) {
                                      return "End date must be after start date";
                                    }
                                  }
      
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
      
                        SizedBox(height: 24),
      
                        // Eligibility Section
                        _buildSectionTitle("Eligibility"),
                        SizedBox(height: 16),
      
                        _buildMultiSelectField(
                          "Define Who Can Use The Offer *",
                          [
                            "All",
                            "First-time joiner – Welcome new attendees.",
                            "Frequent joiner – Joined 50%+ lobbies.",
                            "Early bird – Joined within 12 hours.",
                            "Birthday – Special offer.",
                            "Couple",
                            "Female only",
                            "Small group (<3)",
                            "Medium group (3-5)",
                            "Large group (≥6)",
                            "Friends",
                            "House members"
                          ],
                          selectedEligibility,
                          (value) {
                            setState(() {
                              selectedEligibility = value;
                            });
                          },
                        ),
      
                        SizedBox(height: 8),
      
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 12, color: const Color(0xFF3E79A1)),
                            SizedBox(width: 4),
                            DesignText(
                              text: "You can choose max 3 options",
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade700,
                            ),
                          ],
                        ),
      
                        // Status Section
                        if (widget.editPage == "edit") ...[
                          SizedBox(height: 24),
                          _buildSectionTitle("Offer Status"),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildRadioButton("Active", true),
                                ),
                                Expanded(
                                  child: _buildRadioButton("Inactive", false),
                                ),
                              ],
                            ),
                          ),
                        ],
      
                        SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    if (selectedDiscountType == null ||
                        discountValueController.text.isEmpty ||
                        // startDateController.text.isEmpty ||
                        // endDateController.text.isEmpty ||
                        selectedEligibility.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Please complete all the offer details"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (selectedDiscountType == "Percentage") {
                      final discountValue =
                          int.tryParse(discountValueController.text) ?? 0;
                      if (discountValue <= 0 || discountValue > 100) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Percentage must be between 0 and 100"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                    }
                    if (DateTime.tryParse(startDateController.text) != null &&
                        DateTime.tryParse(endDateController.text) != null) {
                      final startDate = DateTime.parse(startDateController.text);
                      final endDate = DateTime.parse(endDateController.text);
                      if (startDate.isAfter(endDate) ||
                          startDate.isAtSameMomentAs(endDate)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text("End date must be greater than start date"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                    }
      
                    if (widget.editPage != "edit") {
                      // Call addOffers API
                      await Api.addOffers(
                        widget.lobbyId,
                        "LOBBY",
                        selectedDiscountType ?? '',
                        startDateController.text,
                        endDateController.text,
                        discountValueController.text,
                        selectedEligibility ?? [],
                      );
                      Get.off(() => ManageOfferScreen(lobbyId: widget.lobbyId));
                    } else {
                      // Call editOffers API
                      await Api.editOffers(
                        widget.lobbyId,
                        "LOBBY",
                        selectedDiscountType ?? '',
                        startDateController.text,
                        endDateController.text,
                        discountValueController.text,
                        selectedEligibility ?? [],
                      );
                      Get.to(ManageOfferScreen(lobbyId: widget.lobbyId));
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC4B5D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              padding: EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : DesignText(
                    text: widget.editPage == "edit"
                        ? "Save Changes"
                        : "Create Offer",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFEC4B5D),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 8),
        DesignText(
          text: title,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DesignText(
          text: label,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          validator: validator,
          onTap: () => _selectDate(context, controller),
          decoration: InputDecoration(
            hintText: "YYYY-MM-DD",
            hintStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: Colors.grey,
            ),
            suffixIcon:
                Icon(Icons.calendar_today, color: Colors.grey, size: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEC4B5D)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> options,
      String? selectedValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DesignText(
          text: label,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: selectedValue,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: InputBorder.none,
              ),
              hint: DesignText(
                text: "Select $label",
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: Colors.grey,
              ),
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
              onChanged: onChanged,
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: DesignText(
                    text: option,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DesignText(
          text: label,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w300,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEC4B5D)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            prefixIcon: selectedDiscountType == "Percentage"
                ? Icon(Icons.percent, size: 16, color: Colors.grey.shade600)
                : Icon(Icons.currency_rupee,
                    size: 16, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectField(
    String label,
    List<String> options,
    List<String> selectedValues,
    ValueChanged<List<String>> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DesignText(
          text: label,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showMultiSelectDialog(
              context, label, options, selectedValues, onChanged),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DesignText(
                    text: selectedValues.isEmpty
                        ? "Select options"
                        : selectedValues.join(', '),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: selectedValues.isEmpty ? Colors.grey : Colors.black,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey.shade700,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMultiSelectDialog(
    BuildContext context,
    String label,
    List<String> options,
    List<String> selectedValues,
    ValueChanged<List<String>> onChanged,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<String> tempSelectedValues = List.from(selectedValues);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text("Select $label"),
              content: Container(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((option) {
                      bool isSelected = tempSelectedValues.contains(option);
                      return CheckboxListTile(
                        title: Text(
                          option,
                          style: TextStyle(fontSize: 14),
                        ),
                        value: isSelected,
                        activeColor: const Color(0xFFEC4B5D),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              if (tempSelectedValues.length < 3) {
                                tempSelectedValues.add(option);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "You can select maximum 3 options"),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            } else {
                              tempSelectedValues.remove(option);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    onChanged(tempSelectedValues);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Done",
                    style: TextStyle(color: Color(0xFFEC4B5D)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRadioButton(String label, bool value) {
    return InkWell(
      onTap: () {
        setState(() {
          isActive = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Radio(
              value: value,
              groupValue: isActive,
              activeColor: const Color(0xFFEC4B5D),
              onChanged: (newValue) {
                setState(() {
                  isActive = newValue as bool;
                });
              },
            ),
            DesignText(
              text: label,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}
