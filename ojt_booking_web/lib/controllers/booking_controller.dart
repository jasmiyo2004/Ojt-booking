import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../models/commodity_model.dart';
import '../models/customer_model.dart';
import '../models/container_model.dart';
import '../models/vessel_schedule_model.dart';
import '../services/api_service.dart';
import '../widgets/error_dialog.dart';

class BookingController {
  final ApiService _apiService = ApiService();
  List<Location>? _cachedLocations;

  Future<void> showLocationPicker({
    required BuildContext context,
    required String title,
    required Function(
      String locationDesc,
      int locationId,
      String? locationTypeDesc,
    )
    onSelect,
    int? currentLocationId, // Add parameter to check against
    String? errorType, // "origin" or "destination"
  }) async {
    if (_cachedLocations == null) {
      _cachedLocations = await _apiService.getLocations();
    }
    if (!context.mounted) return;

    String searchQuery = '';
    String searchCategory = 'Location Name'; // Default category
    final TextEditingController searchController = TextEditingController();
    int currentPage = 0;
    const int itemsPerPage = 5;
    Location? selectedLocation;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Filter based on selected category
            final filteredLocations = _cachedLocations!.where((loc) {
              if (searchQuery.isEmpty) return true;

              if (searchCategory == 'Location Name') {
                return loc.locationDesc.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
              } else {
                // Location Code
                return loc.locationCD.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
              }
            }).toList();

            final totalPages = (filteredLocations.length / itemsPerPage).ceil();
            final startIndex = currentPage * itemsPerPage;
            final endIndex =
                (startIndex + itemsPerPage < filteredLocations.length)
                ? startIndex + itemsPerPage
                : filteredLocations.length;
            final paginatedLocations = filteredLocations.isNotEmpty
                ? filteredLocations.sublist(startIndex, endIndex)
                : <Location>[];

            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final isSmall = screenWidth < 600;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: EdgeInsets.symmetric(
                horizontal: isSmall ? 16 : 40,
                vertical: isSmall ? 20 : 40,
              ),
              child: Container(
                width: isSmall ? screenWidth * 0.92 : screenWidth * 0.6,
                height: isSmall ? screenHeight * 0.88 : screenHeight * 0.7,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, const Color(0xFFFFFBF0)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with gradient background
                    Container(
                      padding: EdgeInsets.all(isSmall ? 16 : 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1B5E20),
                            const Color(0xFF2E7D32),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmall ? 8 : 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: isSmall ? 20 : 28,
                            ),
                          ),
                          SizedBox(width: isSmall ? 10 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: isSmall ? 18 : 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Select a location from the list',
                                  style: TextStyle(
                                    fontSize: isSmall ? 11 : 14,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                            color: Colors.white,
                            iconSize: isSmall ? 22 : 28,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content area
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(isSmall ? 12 : 24),
                        child: Column(
                          children: [
                            // Search controls row
                            Row(
                              children: [
                                // Category dropdown
                                Expanded(
                                  flex: isSmall ? 3 : 2,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmall ? 10 : 16,
                                      vertical: isSmall ? 0 : 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: searchCategory,
                                        isExpanded: true,
                                        isDense: isSmall,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: const Color(0xFF1B5E20),
                                          size: isSmall ? 20 : 24,
                                        ),
                                        style: TextStyle(
                                          fontSize: isSmall ? 12 : 15,
                                          color: const Color(0xFF212121),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        items:
                                            [
                                              'Location Name',
                                              'Location Code',
                                            ].map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: TextStyle(
                                                    fontSize: isSmall ? 12 : 15,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              searchCategory = newValue;
                                              currentPage = 0;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: isSmall ? 8 : 12),
                                // Search input field
                                Expanded(
                                  flex: isSmall ? 4 : 3,
                                  child: TextField(
                                    controller: searchController,
                                    style: TextStyle(
                                      fontSize: isSmall ? 13 : 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          searchCategory == 'Location Name'
                                          ? "Enter name..."
                                          : "Enter code...",
                                      hintStyle: TextStyle(
                                        fontSize: isSmall ? 13 : 16,
                                        color: Colors.grey[400],
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: isSmall ? 12 : 16,
                                        vertical: isSmall ? 12 : 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFD4AF37),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onSubmitted: (value) {
                                      setState(() {
                                        searchQuery = value;
                                        currentPage = 0;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: isSmall ? 8 : 12),
                                // Search button
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      searchQuery = searchController.text;
                                      currentPage = 0;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4AF37),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.all(isSmall ? 12 : 18),
                                    minimumSize: Size.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Icon(
                                    Icons.search,
                                    size: isSmall ? 20 : 24,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmall ? 12 : 20),
                            // Column headers with better styling
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmall ? 16 : 16,
                                vertical: isSmall ? 14 : 14,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFF5F5F5),
                                    const Color(0xFFEEEEEE),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: isSmall ? 50 : 50,
                                    child: Icon(
                                      Icons.check_box_outline_blank,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Location Code',
                                      style: TextStyle(
                                        fontSize: isSmall ? 13 : 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B5E20),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Location Name',
                                      style: TextStyle(
                                        fontSize: isSmall ? 13 : 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B5E20),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isSmall ? 16 : 12),
                            Expanded(
                              child: filteredLocations.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search_off,
                                            size: isSmall ? 56 : 64,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: isSmall ? 16 : 16),
                                          Text(
                                            'No locations found',
                                            style: TextStyle(
                                              fontSize: isSmall ? 16 : 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: paginatedLocations.length,
                                      itemBuilder: (context, index) {
                                        final location =
                                            paginatedLocations[index];
                                        final isSelected =
                                            selectedLocation?.locationId ==
                                            location.locationId;
                                        return Container(
                                          margin: EdgeInsets.only(
                                            bottom: isSmall ? 10 : 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(
                                                    0xFFD4AF37,
                                                  ).withValues(alpha: 0.08)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFFD4AF37)
                                                  : Colors.grey[200]!,
                                              width: isSelected ? 2 : 1.5,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFFD4AF37,
                                                      ).withValues(alpha: 0.2),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ]
                                                : [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.03,
                                                          ),
                                                      blurRadius: 4,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                          ),
                                          child: InkWell(
                                            onTap: () => setState(
                                              () => selectedLocation = location,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isSmall ? 16 : 16,
                                                vertical: isSmall ? 12 : 16,
                                              ),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: isSmall ? 50 : 50,
                                                    child: Transform.scale(
                                                      scale: isSmall
                                                          ? 1.3
                                                          : 1.1,
                                                      child: Checkbox(
                                                        value: isSelected,
                                                        onChanged:
                                                            (
                                                              bool? value,
                                                            ) => setState(
                                                              () =>
                                                                  selectedLocation =
                                                                      value ==
                                                                          true
                                                                      ? location
                                                                      : null,
                                                            ),
                                                        activeColor:
                                                            const Color(
                                                              0xFFD4AF37,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF1B5E20,
                                                              ).withValues(
                                                                alpha: 0.1,
                                                              )
                                                            : Colors.grey[50],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        location
                                                                .locationCD
                                                                .isEmpty
                                                            ? '(No Code)'
                                                            : location
                                                                  .locationCD,
                                                        style: TextStyle(
                                                          fontSize: isSmall
                                                              ? 14
                                                              : 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isSelected
                                                              ? const Color(
                                                                  0xFF1B5E20,
                                                                )
                                                              : const Color(
                                                                  0xFF424242,
                                                                ),
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: isSmall ? 12 : 12,
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      location.locationDesc,
                                                      style: TextStyle(
                                                        fontSize: isSmall
                                                            ? 15
                                                            : 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF212121,
                                                              )
                                                            : const Color(
                                                                0xFF616161,
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            SizedBox(height: isSmall ? 20 : 16),
                            if (filteredLocations.length > itemsPerPage)
                              Container(
                                margin: EdgeInsets.only(
                                  bottom: isSmall ? 20 : 16,
                                ),
                                padding: EdgeInsets.all(isSmall ? 12 : 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.03,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: ElevatedButton.icon(
                                        onPressed: currentPage > 0
                                            ? () =>
                                                  setState(() => currentPage--)
                                            : null,
                                        icon: Icon(
                                          Icons.chevron_left,
                                          size: isSmall ? 18 : 18,
                                        ),
                                        label: Text(
                                          'Previous',
                                          style: TextStyle(
                                            fontSize: isSmall ? 13 : 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF1B5E20,
                                          ),
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor:
                                              Colors.grey[200],
                                          disabledForegroundColor:
                                              Colors.grey[400],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmall ? 12 : 16,
                                            vertical: 12,
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFD4AF37,
                                          ).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${currentPage + 1} of $totalPages',
                                          style: TextStyle(
                                            fontSize: isSmall ? 13 : 14,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1B5E20),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: ElevatedButton.icon(
                                        onPressed: currentPage < totalPages - 1
                                            ? () =>
                                                  setState(() => currentPage++)
                                            : null,
                                        label: Text(
                                          'Next',
                                          style: TextStyle(
                                            fontSize: isSmall ? 13 : 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.chevron_right,
                                          size: isSmall ? 18 : 18,
                                        ),
                                        iconAlignment: IconAlignment.end,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF1B5E20,
                                          ),
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor:
                                              Colors.grey[200],
                                          disabledForegroundColor:
                                              Colors.grey[400],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmall ? 12 : 16,
                                            vertical: 12,
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(
                              width: double.infinity,
                              height: isSmall ? 56 : 54,
                              child: ElevatedButton.icon(
                                onPressed: selectedLocation != null
                                    ? () async {
                                        // Check if selected location matches the other location
                                        if (currentLocationId != null &&
                                            selectedLocation!.locationId ==
                                                currentLocationId) {
                                          // Show error dialog
                                          if (errorType == 'origin') {
                                            ErrorDialog.showOriginError(
                                              context,
                                            );
                                          } else if (errorType ==
                                              'destination') {
                                            ErrorDialog.showDestinationError(
                                              context,
                                            );
                                          }
                                          // Don't proceed with selection, keep picker open
                                          return;
                                        }

                                        // If validation passes, proceed with selection
                                        onSelect(
                                          selectedLocation!.displayName,
                                          selectedLocation!.locationId,
                                          selectedLocation!.locationTypeDesc,
                                        );
                                        Navigator.pop(context);
                                      }
                                    : null,
                                icon: Icon(
                                  Icons.check_circle,
                                  size: isSmall ? 22 : 20,
                                ),
                                label: Text(
                                  'CONFIRM SELECTION',
                                  style: TextStyle(
                                    fontSize: isSmall ? 16 : 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4AF37),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey[200],
                                  disabledForegroundColor: Colors.grey[400],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: selectedLocation != null ? 4 : 0,
                                  shadowColor: selectedLocation != null
                                      ? const Color(
                                          0xFFD4AF37,
                                        ).withValues(alpha: 0.4)
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showEquipmentPicker({
    required BuildContext context,
    required Function(String, int) onSelect,
  }) async {
    final equipment = await _apiService.getEquipment();
    if (!context.mounted) return;

    String searchQuery = '';
    String searchCategory = 'Equipment Name'; // Default category
    final TextEditingController searchController = TextEditingController();
    int currentPage = 0;
    const int itemsPerPage = 5;
    int? selectedEquipmentId;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Filter based on selected category
            final filteredEquipment = equipment.where((equip) {
              if (searchQuery.isEmpty) return true;

              if (searchCategory == 'Equipment Name') {
                return equip.equipmentDesc.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
              } else {
                // Equipment Code
                return equip.equipmentCd.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
              }
            }).toList();

            final totalPages = (filteredEquipment.length / itemsPerPage).ceil();
            final startIndex = currentPage * itemsPerPage;
            final endIndex =
                (startIndex + itemsPerPage < filteredEquipment.length)
                ? startIndex + itemsPerPage
                : filteredEquipment.length;
            final paginatedEquipment = filteredEquipment.isNotEmpty
                ? filteredEquipment.sublist(startIndex, endIndex)
                : [];

            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final isSmall = screenWidth < 600;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: EdgeInsets.symmetric(
                horizontal: isSmall ? 16 : 40,
                vertical: isSmall ? 20 : 40,
              ),
              child: Container(
                width: isSmall ? screenWidth * 0.92 : screenWidth * 0.6,
                height: isSmall ? screenHeight * 0.88 : screenHeight * 0.7,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, const Color(0xFFFFFBF0)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with gradient background
                    Container(
                      padding: EdgeInsets.all(isSmall ? 16 : 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1B5E20),
                            const Color(0xFF2E7D32),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmall ? 8 : 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.build_rounded,
                              color: Colors.white,
                              size: isSmall ? 20 : 28,
                            ),
                          ),
                          SizedBox(width: isSmall ? 10 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Equipment Type',
                                  style: TextStyle(
                                    fontSize: isSmall ? 18 : 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Select equipment from the list',
                                  style: TextStyle(
                                    fontSize: isSmall ? 11 : 14,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                            color: Colors.white,
                            iconSize: isSmall ? 22 : 28,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content area
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(isSmall ? 12 : 24),
                        child: Column(
                          children: [
                            // Search controls row
                            Row(
                              children: [
                                // Category dropdown
                                Expanded(
                                  flex: isSmall ? 3 : 2,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmall ? 10 : 16,
                                      vertical: isSmall ? 0 : 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: searchCategory,
                                        isExpanded: true,
                                        isDense: isSmall,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: const Color(0xFF1B5E20),
                                          size: isSmall ? 20 : 24,
                                        ),
                                        style: TextStyle(
                                          fontSize: isSmall ? 12 : 15,
                                          color: const Color(0xFF212121),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        items:
                                            [
                                              'Equipment Name',
                                              'Equipment Code',
                                            ].map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: TextStyle(
                                                    fontSize: isSmall ? 12 : 15,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              searchCategory = newValue;
                                              currentPage = 0;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: isSmall ? 8 : 12),
                                // Search input field
                                Expanded(
                                  flex: isSmall ? 4 : 3,
                                  child: TextField(
                                    controller: searchController,
                                    style: TextStyle(
                                      fontSize: isSmall ? 13 : 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          searchCategory == 'Equipment Name'
                                          ? "Enter name..."
                                          : "Enter code...",
                                      hintStyle: TextStyle(
                                        fontSize: isSmall ? 13 : 16,
                                        color: Colors.grey[400],
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: isSmall ? 12 : 16,
                                        vertical: isSmall ? 12 : 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFD4AF37),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onSubmitted: (value) {
                                      setState(() {
                                        searchQuery = value;
                                        currentPage = 0;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: isSmall ? 8 : 12),
                                // Search button
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      searchQuery = searchController.text;
                                      currentPage = 0;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4AF37),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.all(isSmall ? 12 : 18),
                                    minimumSize: Size.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Icon(
                                    Icons.search,
                                    size: isSmall ? 20 : 24,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmall ? 12 : 20),
                            // Column headers
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmall ? 16 : 16,
                                vertical: isSmall ? 14 : 14,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFF5F5F5),
                                    const Color(0xFFEEEEEE),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: isSmall ? 50 : 50,
                                    child: Icon(
                                      Icons.check_box_outline_blank,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Equipment Code',
                                      style: TextStyle(
                                        fontSize: isSmall ? 13 : 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B5E20),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Equipment Name',
                                      style: TextStyle(
                                        fontSize: isSmall ? 13 : 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B5E20),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isSmall ? 12 : 12),
                            Expanded(
                              child: filteredEquipment.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search_off,
                                            size: isSmall ? 56 : 64,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: isSmall ? 16 : 16),
                                          Text(
                                            'No equipment found',
                                            style: TextStyle(
                                              fontSize: isSmall ? 16 : 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: paginatedEquipment.length,
                                      itemBuilder: (context, index) {
                                        final equip = paginatedEquipment[index];
                                        final isSelected =
                                            selectedEquipmentId ==
                                            equip.equipmentId;
                                        return Container(
                                          margin: EdgeInsets.only(
                                            bottom: isSmall ? 10 : 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(
                                                    0xFFD4AF37,
                                                  ).withValues(alpha: 0.08)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFFD4AF37)
                                                  : Colors.grey[200]!,
                                              width: isSelected ? 2 : 1.5,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFFD4AF37,
                                                      ).withValues(alpha: 0.2),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ]
                                                : [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.03,
                                                          ),
                                                      blurRadius: 4,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                          ),
                                          child: InkWell(
                                            onTap: () => setState(
                                              () => selectedEquipmentId =
                                                  equip.equipmentId,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isSmall ? 16 : 16,
                                                vertical: isSmall ? 12 : 16,
                                              ),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: isSmall ? 50 : 50,
                                                    child: Transform.scale(
                                                      scale: isSmall
                                                          ? 1.3
                                                          : 1.1,
                                                      child: Checkbox(
                                                        value: isSelected,
                                                        onChanged:
                                                            (
                                                              bool? value,
                                                            ) => setState(
                                                              () => selectedEquipmentId =
                                                                  value == true
                                                                  ? equip
                                                                        .equipmentId
                                                                  : null,
                                                            ),
                                                        activeColor:
                                                            const Color(
                                                              0xFFD4AF37,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF1B5E20,
                                                              ).withValues(
                                                                alpha: 0.1,
                                                              )
                                                            : Colors.grey[50],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        equip
                                                                .equipmentCd
                                                                .isEmpty
                                                            ? '(No Code)'
                                                            : equip.equipmentCd,
                                                        style: TextStyle(
                                                          fontSize: isSmall
                                                              ? 14
                                                              : 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isSelected
                                                              ? const Color(
                                                                  0xFF1B5E20,
                                                                )
                                                              : const Color(
                                                                  0xFF424242,
                                                                ),
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: isSmall ? 12 : 12,
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      equip.equipmentDesc,
                                                      style: TextStyle(
                                                        fontSize: isSmall
                                                            ? 15
                                                            : 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF212121,
                                                              )
                                                            : const Color(
                                                                0xFF616161,
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            SizedBox(height: isSmall ? 12 : 16),
                            if (filteredEquipment.length > itemsPerPage)
                              Container(
                                margin: EdgeInsets.only(
                                  bottom: isSmall ? 12 : 16,
                                ),
                                padding: EdgeInsets.all(isSmall ? 12 : 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.03,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: ElevatedButton.icon(
                                        onPressed: currentPage > 0
                                            ? () =>
                                                  setState(() => currentPage--)
                                            : null,
                                        icon: Icon(
                                          Icons.chevron_left,
                                          size: isSmall ? 18 : 18,
                                        ),
                                        label: Text(
                                          'Previous',
                                          style: TextStyle(
                                            fontSize: isSmall ? 13 : 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF1B5E20,
                                          ),
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor:
                                              Colors.grey[200],
                                          disabledForegroundColor:
                                              Colors.grey[400],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmall ? 12 : 16,
                                            vertical: 12,
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFD4AF37,
                                          ).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${currentPage + 1} of $totalPages',
                                          style: TextStyle(
                                            fontSize: isSmall ? 13 : 14,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1B5E20),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: ElevatedButton.icon(
                                        onPressed: currentPage < totalPages - 1
                                            ? () =>
                                                  setState(() => currentPage++)
                                            : null,
                                        label: Text(
                                          'Next',
                                          style: TextStyle(
                                            fontSize: isSmall ? 13 : 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.chevron_right,
                                          size: isSmall ? 18 : 18,
                                        ),
                                        iconAlignment: IconAlignment.end,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF1B5E20,
                                          ),
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor:
                                              Colors.grey[200],
                                          disabledForegroundColor:
                                              Colors.grey[400],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmall ? 12 : 16,
                                            vertical: 12,
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(
                              width: double.infinity,
                              height: isSmall ? 50 : 54,
                              child: ElevatedButton.icon(
                                onPressed: selectedEquipmentId != null
                                    ? () {
                                        final selectedEquip = equipment
                                            .firstWhere(
                                              (e) =>
                                                  e.equipmentId ==
                                                  selectedEquipmentId,
                                            );
                                        onSelect(
                                          selectedEquip.equipmentDesc,
                                          selectedEquip.equipmentId,
                                        );
                                        Navigator.pop(context);
                                      }
                                    : null,
                                icon: Icon(
                                  Icons.check_circle,
                                  size: isSmall ? 20 : 20,
                                ),
                                label: Text(
                                  'CONFIRM SELECTION',
                                  style: TextStyle(
                                    fontSize: isSmall ? 15 : 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4AF37),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey[200],
                                  disabledForegroundColor: Colors.grey[400],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: selectedEquipmentId != null
                                      ? 4
                                      : 0,
                                  shadowColor: selectedEquipmentId != null
                                      ? const Color(
                                          0xFFD4AF37,
                                        ).withValues(alpha: 0.4)
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showVesselPicker({
    required BuildContext context,
    required Function(String, int) onSelect,
  }) async {
    final vessels = await _apiService.getVessels();
    if (!context.mounted) return;

    String searchQuery = '';
    String searchCategory = 'Vessel Name'; // Default category
    final TextEditingController searchController = TextEditingController();
    int currentPage = 0;
    const int itemsPerPage = 5;
    int? selectedVesselId;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Filter based on selected category
            final filteredVessels = vessels.where((vessel) {
              if (searchQuery.isEmpty) return true;

              if (searchCategory == 'Vessel Name') {
                return vessel.vesselDesc.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
              } else {
                // Vessel Code
                return vessel.vesselCd.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
              }
            }).toList();

            final totalPages = (filteredVessels.length / itemsPerPage).ceil();
            final startIndex = currentPage * itemsPerPage;
            final endIndex =
                (startIndex + itemsPerPage < filteredVessels.length)
                ? startIndex + itemsPerPage
                : filteredVessels.length;
            final paginatedVessels = filteredVessels.isNotEmpty
                ? filteredVessels.sublist(startIndex, endIndex)
                : [];

            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final isSmall = screenWidth < 600;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: EdgeInsets.symmetric(
                horizontal: isSmall ? 16 : 40,
                vertical: isSmall ? 20 : 40,
              ),
              child: Container(
                width: isSmall ? screenWidth * 0.92 : screenWidth * 0.6,
                height: isSmall ? screenHeight * 0.88 : screenHeight * 0.7,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, const Color(0xFFFFFBF0)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with gradient background
                    Container(
                      padding: EdgeInsets.all(isSmall ? 16 : 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1B5E20),
                            const Color(0xFF2E7D32),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmall ? 8 : 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.directions_boat_rounded,
                              color: Colors.white,
                              size: isSmall ? 20 : 28,
                            ),
                          ),
                          SizedBox(width: isSmall ? 10 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vessel Name',
                                  style: TextStyle(
                                    fontSize: isSmall ? 18 : 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Select a vessel from the list',
                                  style: TextStyle(
                                    fontSize: isSmall ? 11 : 14,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                            color: Colors.white,
                            iconSize: isSmall ? 22 : 28,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content area
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(isSmall ? 12 : 24),
                        child: Column(
                          children: [
                            // Search controls row
                            Row(
                              children: [
                                // Category dropdown
                                Expanded(
                                  flex: isSmall ? 3 : 2,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmall ? 10 : 16,
                                      vertical: isSmall ? 0 : 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: searchCategory,
                                        isExpanded: true,
                                        isDense: isSmall,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: const Color(0xFF1B5E20),
                                          size: isSmall ? 20 : 24,
                                        ),
                                        style: TextStyle(
                                          fontSize: isSmall ? 12 : 15,
                                          color: const Color(0xFF212121),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        items: ['Vessel Name', 'Vessel Code']
                                            .map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: TextStyle(
                                                    fontSize: isSmall ? 12 : 15,
                                                  ),
                                                ),
                                              );
                                            })
                                            .toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              searchCategory = newValue;
                                              currentPage = 0;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: isSmall ? 8 : 12),
                                // Search input field
                                Expanded(
                                  flex: isSmall ? 4 : 3,
                                  child: TextField(
                                    controller: searchController,
                                    style: TextStyle(
                                      fontSize: isSmall ? 13 : 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: searchCategory == 'Vessel Name'
                                          ? "Enter name..."
                                          : "Enter code...",
                                      hintStyle: TextStyle(
                                        fontSize: isSmall ? 13 : 16,
                                        color: Colors.grey[400],
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: isSmall ? 12 : 16,
                                        vertical: isSmall ? 12 : 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFD4AF37),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onSubmitted: (value) {
                                      setState(() {
                                        searchQuery = value;
                                        currentPage = 0;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: isSmall ? 8 : 12),
                                // Search button
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      searchQuery = searchController.text;
                                      currentPage = 0;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4AF37),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.all(isSmall ? 12 : 18),
                                    minimumSize: Size.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Icon(
                                    Icons.search,
                                    size: isSmall ? 20 : 24,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmall ? 12 : 20),
                            // Column headers
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmall ? 16 : 16,
                                vertical: isSmall ? 14 : 14,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFF5F5F5),
                                    const Color(0xFFEEEEEE),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: isSmall ? 50 : 50,
                                    child: Icon(
                                      Icons.check_box_outline_blank,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Vessel Code',
                                      style: TextStyle(
                                        fontSize: isSmall ? 13 : 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B5E20),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Vessel Name',
                                      style: TextStyle(
                                        fontSize: isSmall ? 13 : 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B5E20),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isSmall ? 12 : 12),
                            Expanded(
                              child: filteredVessels.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search_off,
                                            size: isSmall ? 56 : 64,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: isSmall ? 16 : 16),
                                          Text(
                                            'No vessels found',
                                            style: TextStyle(
                                              fontSize: isSmall ? 16 : 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: paginatedVessels.length,
                                      itemBuilder: (context, index) {
                                        final vessel = paginatedVessels[index];
                                        final isSelected =
                                            selectedVesselId == vessel.vesselId;
                                        return Container(
                                          margin: EdgeInsets.only(
                                            bottom: isSmall ? 10 : 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(
                                                    0xFFD4AF37,
                                                  ).withValues(alpha: 0.08)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFFD4AF37)
                                                  : Colors.grey[200]!,
                                              width: isSelected ? 2 : 1.5,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFFD4AF37,
                                                      ).withValues(alpha: 0.2),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ]
                                                : [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.03,
                                                          ),
                                                      blurRadius: 4,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                          ),
                                          child: InkWell(
                                            onTap: () => setState(
                                              () => selectedVesselId =
                                                  vessel.vesselId,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isSmall ? 16 : 16,
                                                vertical: isSmall ? 12 : 16,
                                              ),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: isSmall ? 50 : 50,
                                                    child: Transform.scale(
                                                      scale: isSmall
                                                          ? 1.3
                                                          : 1.1,
                                                      child: Checkbox(
                                                        value: isSelected,
                                                        onChanged:
                                                            (
                                                              bool? value,
                                                            ) => setState(
                                                              () => selectedVesselId =
                                                                  value == true
                                                                  ? vessel
                                                                        .vesselId
                                                                  : null,
                                                            ),
                                                        activeColor:
                                                            const Color(
                                                              0xFFD4AF37,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF1B5E20,
                                                              ).withValues(
                                                                alpha: 0.1,
                                                              )
                                                            : Colors.grey[50],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        vessel.vesselCd.isEmpty
                                                            ? '(No Code)'
                                                            : vessel.vesselCd,
                                                        style: TextStyle(
                                                          fontSize: isSmall
                                                              ? 14
                                                              : 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isSelected
                                                              ? const Color(
                                                                  0xFF1B5E20,
                                                                )
                                                              : const Color(
                                                                  0xFF424242,
                                                                ),
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: isSmall ? 12 : 12,
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      vessel.vesselDesc,
                                                      style: TextStyle(
                                                        fontSize: isSmall
                                                            ? 15
                                                            : 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF212121,
                                                              )
                                                            : const Color(
                                                                0xFF616161,
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            SizedBox(height: isSmall ? 12 : 16),
                            if (filteredVessels.length > itemsPerPage)
                              Container(
                                margin: EdgeInsets.only(
                                  bottom: isSmall ? 12 : 16,
                                ),
                                padding: EdgeInsets.all(isSmall ? 12 : 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.03,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: ElevatedButton.icon(
                                        onPressed: currentPage > 0
                                            ? () =>
                                                  setState(() => currentPage--)
                                            : null,
                                        icon: Icon(
                                          Icons.chevron_left,
                                          size: isSmall ? 18 : 18,
                                        ),
                                        label: Text(
                                          'Previous',
                                          style: TextStyle(
                                            fontSize: isSmall ? 13 : 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF1B5E20,
                                          ),
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor:
                                              Colors.grey[200],
                                          disabledForegroundColor:
                                              Colors.grey[400],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmall ? 12 : 16,
                                            vertical: 12,
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFD4AF37,
                                          ).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${currentPage + 1} of $totalPages',
                                          style: TextStyle(
                                            fontSize: isSmall ? 13 : 14,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1B5E20),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: ElevatedButton.icon(
                                        onPressed: currentPage < totalPages - 1
                                            ? () =>
                                                  setState(() => currentPage++)
                                            : null,
                                        label: Text(
                                          'Next',
                                          style: TextStyle(
                                            fontSize: isSmall ? 13 : 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.chevron_right,
                                          size: isSmall ? 18 : 18,
                                        ),
                                        iconAlignment: IconAlignment.end,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF1B5E20,
                                          ),
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor:
                                              Colors.grey[200],
                                          disabledForegroundColor:
                                              Colors.grey[400],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmall ? 12 : 16,
                                            vertical: 12,
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(
                              width: double.infinity,
                              height: isSmall ? 50 : 54,
                              child: ElevatedButton.icon(
                                onPressed: selectedVesselId != null
                                    ? () {
                                        final selectedVessel = vessels
                                            .firstWhere(
                                              (v) =>
                                                  v.vesselId ==
                                                  selectedVesselId,
                                            );
                                        onSelect(
                                          selectedVessel.vesselDesc,
                                          selectedVessel.vesselId,
                                        );
                                        Navigator.pop(context);
                                      }
                                    : null,
                                icon: Icon(
                                  Icons.check_circle,
                                  size: isSmall ? 20 : 20,
                                ),
                                label: Text(
                                  'CONFIRM SELECTION',
                                  style: TextStyle(
                                    fontSize: isSmall ? 15 : 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4AF37),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey[200],
                                  disabledForegroundColor: Colors.grey[400],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: selectedVesselId != null ? 4 : 0,
                                  shadowColor: selectedVesselId != null
                                      ? const Color(
                                          0xFFD4AF37,
                                        ).withValues(alpha: 0.4)
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> showCommodityPicker({
    required BuildContext context,
    required Function(String, int) onSelect,
  }) async {
    final commodities = await _apiService.getCommodities();
    if (!context.mounted) return;

    String searchQuery = '';
    String searchCategory = 'Commodity Name'; // Default category
    final TextEditingController searchController = TextEditingController();
    int currentPage = 0;
    const int itemsPerPage = 5;
    Commodity? selectedCommodity;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Filter based on selected category
            final filteredCommodities = commodities.where((commodity) {
              if (searchQuery.isEmpty) return true;

              if (searchCategory == 'Commodity Name') {
                return commodity.commodityDesc.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
              } else {
                // Commodity Code
                return commodity.commodityCd.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
              }
            }).toList();

            final totalPages = (filteredCommodities.length / itemsPerPage)
                .ceil();
            final startIndex = currentPage * itemsPerPage;
            final endIndex =
                (startIndex + itemsPerPage < filteredCommodities.length)
                ? startIndex + itemsPerPage
                : filteredCommodities.length;
            final paginatedCommodities = filteredCommodities.isNotEmpty
                ? filteredCommodities.sublist(startIndex, endIndex)
                : <Commodity>[];

            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final isSmall = screenWidth < 600;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: EdgeInsets.symmetric(
                horizontal: isSmall ? 16 : 40,
                vertical: isSmall ? 20 : 40,
              ),
              child: Container(
                width: isSmall ? screenWidth * 0.92 : screenWidth * 0.6,
                height: isSmall ? screenHeight * 0.88 : screenHeight * 0.7,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, const Color(0xFFFFFBF0)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with gradient background
                    Container(
                      padding: EdgeInsets.all(isSmall ? 16 : 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1B5E20),
                            const Color(0xFF2E7D32),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmall ? 8 : 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.category,
                              color: Colors.white,
                              size: isSmall ? 20 : 28,
                            ),
                          ),
                          SizedBox(width: isSmall ? 10 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Commodity',
                                  style: TextStyle(
                                    fontSize: isSmall ? 18 : 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Select a commodity from the list',
                                  style: TextStyle(
                                    fontSize: isSmall ? 11 : 14,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                            color: Colors.white,
                            iconSize: isSmall ? 22 : 28,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content area
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(isSmall ? 12 : 24),
                        child: Column(
                          children: [
                            // Search controls row
                            Row(
                              children: [
                                // Category dropdown
                                Expanded(
                                  flex: isSmall ? 3 : 2,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmall ? 10 : 16,
                                      vertical: isSmall ? 0 : 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: searchCategory,
                                        isExpanded: true,
                                        isDense: isSmall,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: const Color(0xFF1B5E20),
                                          size: isSmall ? 20 : 24,
                                        ),
                                        style: TextStyle(
                                          fontSize: isSmall ? 12 : 15,
                                          color: const Color(0xFF212121),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        items:
                                            [
                                              'Commodity Name',
                                              'Commodity Code',
                                            ].map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: TextStyle(
                                                    fontSize: isSmall ? 12 : 15,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              searchCategory = newValue;
                                              currentPage = 0;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: isSmall ? 8 : 12),
                                // Search input field
                                Expanded(
                                  flex: isSmall ? 4 : 3,
                                  child: TextField(
                                    controller: searchController,
                                    style: TextStyle(
                                      fontSize: isSmall ? 13 : 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          searchCategory == 'Commodity Name'
                                          ? "Enter name..."
                                          : "Enter code...",
                                      hintStyle: TextStyle(
                                        fontSize: isSmall ? 13 : 16,
                                        color: Colors.grey[400],
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: isSmall ? 12 : 16,
                                        vertical: isSmall ? 12 : 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFD4AF37),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onSubmitted: (value) {
                                      setState(() {
                                        searchQuery = value;
                                        currentPage = 0;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: isSmall ? 8 : 12),
                                // Search button
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      searchQuery = searchController.text;
                                      currentPage = 0;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4AF37),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.all(isSmall ? 12 : 18),
                                    minimumSize: Size.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Icon(
                                    Icons.search,
                                    size: isSmall ? 20 : 24,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmall ? 12 : 20),
                            // Column headers with better styling
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmall ? 16 : 16,
                                vertical: isSmall ? 14 : 14,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFF5F5F5),
                                    const Color(0xFFEEEEEE),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: isSmall ? 50 : 50,
                                    child: Icon(
                                      Icons.check_box_outline_blank,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Commodity Code',
                                      style: TextStyle(
                                        fontSize: isSmall ? 13 : 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B5E20),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Commodity Name',
                                      style: TextStyle(
                                        fontSize: isSmall ? 13 : 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B5E20),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isSmall ? 16 : 12),
                            Expanded(
                              child: filteredCommodities.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search_off,
                                            size: isSmall ? 56 : 64,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: isSmall ? 16 : 16),
                                          Text(
                                            'No commodities found',
                                            style: TextStyle(
                                              fontSize: isSmall ? 16 : 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: paginatedCommodities.length,
                                      itemBuilder: (context, index) {
                                        final commodity =
                                            paginatedCommodities[index];
                                        final isSelected =
                                            selectedCommodity?.commodityId ==
                                            commodity.commodityId;
                                        return Container(
                                          margin: EdgeInsets.only(
                                            bottom: isSmall ? 10 : 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(
                                                    0xFFD4AF37,
                                                  ).withValues(alpha: 0.08)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFFD4AF37)
                                                  : Colors.grey[200]!,
                                              width: isSelected ? 2 : 1.5,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFFD4AF37,
                                                      ).withValues(alpha: 0.2),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ]
                                                : [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.03,
                                                          ),
                                                      blurRadius: 4,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                          ),
                                          child: InkWell(
                                            onTap: () => setState(
                                              () =>
                                                  selectedCommodity = commodity,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isSmall ? 16 : 16,
                                                vertical: isSmall ? 12 : 16,
                                              ),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: isSmall ? 50 : 50,
                                                    child: Transform.scale(
                                                      scale: isSmall
                                                          ? 1.3
                                                          : 1.1,
                                                      child: Checkbox(
                                                        value: isSelected,
                                                        onChanged:
                                                            (
                                                              bool? value,
                                                            ) => setState(
                                                              () =>
                                                                  selectedCommodity =
                                                                      value ==
                                                                          true
                                                                      ? commodity
                                                                      : null,
                                                            ),
                                                        activeColor:
                                                            const Color(
                                                              0xFFD4AF37,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF1B5E20,
                                                              ).withValues(
                                                                alpha: 0.1,
                                                              )
                                                            : Colors.grey[50],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        commodity
                                                                .commodityCd
                                                                .isEmpty
                                                            ? '(No Code)'
                                                            : commodity
                                                                  .commodityCd,
                                                        style: TextStyle(
                                                          fontSize: isSmall
                                                              ? 14
                                                              : 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isSelected
                                                              ? const Color(
                                                                  0xFF1B5E20,
                                                                )
                                                              : const Color(
                                                                  0xFF424242,
                                                                ),
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: isSmall ? 12 : 12,
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      commodity.commodityDesc,
                                                      style: TextStyle(
                                                        fontSize: isSmall
                                                            ? 14
                                                            : 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF1B5E20,
                                                              )
                                                            : const Color(
                                                                0xFF212121,
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            SizedBox(height: isSmall ? 16 : 16),
                            // Pagination controls
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmall ? 12 : 16,
                                vertical: isSmall ? 12 : 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: ElevatedButton.icon(
                                      onPressed: currentPage > 0
                                          ? () => setState(() => currentPage--)
                                          : null,
                                      icon: Icon(
                                        Icons.chevron_left,
                                        size: isSmall ? 18 : 20,
                                      ),
                                      label: Text(
                                        'Previous',
                                        style: TextStyle(
                                          fontSize: isSmall ? 12 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: currentPage > 0
                                            ? const Color(0xFF1B5E20)
                                            : Colors.grey[300],
                                        foregroundColor: currentPage > 0
                                            ? Colors.white
                                            : Colors.grey[500],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isSmall ? 12 : 16,
                                          vertical: isSmall ? 10 : 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmall ? 8 : 16,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${currentPage + 1} / ${totalPages > 0 ? totalPages : 1}',
                                        style: TextStyle(
                                          fontSize: isSmall ? 12 : 14,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1B5E20),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: ElevatedButton.icon(
                                      onPressed: currentPage < totalPages - 1
                                          ? () => setState(() => currentPage++)
                                          : null,
                                      label: Text(
                                        'Next',
                                        style: TextStyle(
                                          fontSize: isSmall ? 12 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons.chevron_right,
                                        size: isSmall ? 18 : 20,
                                      ),
                                      iconAlignment: IconAlignment.end,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            currentPage < totalPages - 1
                                            ? const Color(0xFF1B5E20)
                                            : Colors.grey[300],
                                        foregroundColor:
                                            currentPage < totalPages - 1
                                            ? Colors.white
                                            : Colors.grey[500],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isSmall ? 12 : 16,
                                          vertical: isSmall ? 10 : 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isSmall ? 16 : 16),
                            // Confirm button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: selectedCommodity != null
                                    ? () {
                                        onSelect(
                                          selectedCommodity!.commodityDesc,
                                          selectedCommodity!.commodityId,
                                        );
                                        Navigator.pop(context);
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedCommodity != null
                                      ? const Color(0xFF1B5E20)
                                      : Colors.grey[300],
                                  foregroundColor: selectedCommodity != null
                                      ? Colors.white
                                      : Colors.grey[500],
                                  padding: EdgeInsets.symmetric(
                                    vertical: isSmall ? 14 : 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: selectedCommodity != null ? 2 : 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: isSmall ? 20 : 24,
                                    ),
                                    SizedBox(width: isSmall ? 8 : 12),
                                    Text(
                                      'Confirm Selection',
                                      style: TextStyle(
                                        fontSize: isSmall ? 15 : 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showSearchPicker({
    required BuildContext context,
    required String title,
    required List<String> options,
    required Function(String) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "Select $title",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(options[index]),
                      onTap: () {
                        onSelect(options[index]);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showCancelProcess(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Cancel?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("NO"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showRemarksModal(context);
            },
            child: const Text("YES"),
          ),
        ],
      ),
    );
  }

  void _showRemarksModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Remarks"),
        content: const TextField(
          decoration: InputDecoration(hintText: "Reason for cancellation..."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("SUBMIT"),
          ),
        ],
      ),
    );
  }

  Future<void> showAgreementPartyPicker({
    required BuildContext context,
    required Function(String, int, Customer) onSelect,
  }) async {
    final customers = await _apiService.getAgreementParties();
    if (!context.mounted) return;

    String searchQuery = '';
    String searchCategory = 'Customer Name'; // Default category
    final TextEditingController searchController = TextEditingController();
    int currentPage = 0;
    const int itemsPerPage = 5;
    Customer? selectedCustomer;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Filter based on selected category
            final filteredCustomers = customers.where((customer) {
              if (searchQuery.isEmpty) return true;

              if (searchCategory == 'Customer Name') {
                return customer.fullName.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
              } else {
                // Customer Code
                return customer.customerCd.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
              }
            }).toList();

            final totalPages = (filteredCustomers.length / itemsPerPage).ceil();
            final startIndex = currentPage * itemsPerPage;
            final endIndex =
                (startIndex + itemsPerPage < filteredCustomers.length)
                ? startIndex + itemsPerPage
                : filteredCustomers.length;
            final paginatedCustomers = filteredCustomers.isNotEmpty
                ? filteredCustomers.sublist(startIndex, endIndex)
                : <Customer>[];

            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final isSmall = screenWidth < 600;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: EdgeInsets.symmetric(
                horizontal: isSmall ? 16 : 40,
                vertical: isSmall ? 20 : 40,
              ),
              child: Container(
                width: isSmall ? screenWidth * 0.92 : screenWidth * 0.6,
                height: isSmall ? screenHeight * 0.88 : screenHeight * 0.7,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, const Color(0xFFFFFBF0)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with gradient background
                    Container(
                      padding: EdgeInsets.all(isSmall ? 16 : 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1B5E20),
                            const Color(0xFF2E7D32),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmall ? 8 : 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: isSmall ? 20 : 28,
                            ),
                          ),
                          SizedBox(width: isSmall ? 10 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Agreement Party',
                                  style: TextStyle(
                                    fontSize: isSmall ? 18 : 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Select an agreement party from the list',
                                  style: TextStyle(
                                    fontSize: isSmall ? 11 : 14,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                            color: Colors.white,
                            iconSize: isSmall ? 22 : 28,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content area
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(isSmall ? 12 : 24),
                        child: Column(
                          children: [
                            // Search controls row
                            Row(
                              children: [
                                // Category dropdown
                                Expanded(
                                  flex: isSmall ? 3 : 2,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmall ? 10 : 16,
                                      vertical: isSmall ? 0 : 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: searchCategory,
                                        isExpanded: true,
                                        isDense: isSmall,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: const Color(0xFF1B5E20),
                                          size: isSmall ? 20 : 24,
                                        ),
                                        style: TextStyle(
                                          fontSize: isSmall ? 12 : 15,
                                          color: const Color(0xFF212121),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        items:
                                            [
                                              'Customer Name',
                                              'Customer Code',
                                            ].map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: TextStyle(
                                                    fontSize: isSmall ? 12 : 15,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              searchCategory = newValue;
                                              currentPage = 0;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: isSmall ? 8 : 12),
                                // Search input field
                                Expanded(
                                  flex: isSmall ? 4 : 3,
                                  child: TextField(
                                    controller: searchController,
                                    style: TextStyle(
                                      fontSize: isSmall ? 13 : 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          searchCategory == 'Customer Name'
                                          ? "Enter name..."
                                          : "Enter code...",
                                      hintStyle: TextStyle(
                                        fontSize: isSmall ? 13 : 16,
                                        color: Colors.grey[400],
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: isSmall ? 12 : 16,
                                        vertical: isSmall ? 12 : 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFD4AF37),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onSubmitted: (value) {
                                      setState(() {
                                        searchQuery = value;
                                        currentPage = 0;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: isSmall ? 8 : 12),
                                // Search button
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      searchQuery = searchController.text;
                                      currentPage = 0;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4AF37),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.all(isSmall ? 12 : 18),
                                    minimumSize: Size.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Icon(
                                    Icons.search,
                                    size: isSmall ? 20 : 24,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmall ? 12 : 20),
                            // Column headers with better styling
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmall ? 16 : 16,
                                vertical: isSmall ? 14 : 14,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFF5F5F5),
                                    const Color(0xFFEEEEEE),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: isSmall ? 50 : 50,
                                    child: Icon(
                                      Icons.check_box_outline_blank,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Customer Code',
                                      style: TextStyle(
                                        fontSize: isSmall ? 13 : 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B5E20),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Customer Name',
                                      style: TextStyle(
                                        fontSize: isSmall ? 13 : 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B5E20),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isSmall ? 16 : 12),
                            Expanded(
                              child: filteredCustomers.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search_off,
                                            size: isSmall ? 56 : 64,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: isSmall ? 16 : 16),
                                          Text(
                                            'No customers found',
                                            style: TextStyle(
                                              fontSize: isSmall ? 16 : 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: paginatedCustomers.length,
                                      itemBuilder: (context, index) {
                                        final customer =
                                            paginatedCustomers[index];
                                        final isSelected =
                                            selectedCustomer?.customerId ==
                                            customer.customerId;
                                        return Container(
                                          margin: EdgeInsets.only(
                                            bottom: isSmall ? 10 : 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(
                                                    0xFFD4AF37,
                                                  ).withValues(alpha: 0.08)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFFD4AF37)
                                                  : Colors.grey[200]!,
                                              width: isSelected ? 2 : 1.5,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFFD4AF37,
                                                      ).withValues(alpha: 0.2),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ]
                                                : [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.03,
                                                          ),
                                                      blurRadius: 4,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                          ),
                                          child: InkWell(
                                            onTap: () => setState(
                                              () => selectedCustomer = customer,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isSmall ? 16 : 16,
                                                vertical: isSmall ? 12 : 16,
                                              ),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: isSmall ? 50 : 50,
                                                    child: Transform.scale(
                                                      scale: isSmall
                                                          ? 1.3
                                                          : 1.1,
                                                      child: Checkbox(
                                                        value: isSelected,
                                                        onChanged:
                                                            (
                                                              bool? value,
                                                            ) => setState(
                                                              () =>
                                                                  selectedCustomer =
                                                                      value ==
                                                                          true
                                                                      ? customer
                                                                      : null,
                                                            ),
                                                        activeColor:
                                                            const Color(
                                                              0xFFD4AF37,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF1B5E20,
                                                              ).withValues(
                                                                alpha: 0.1,
                                                              )
                                                            : Colors.grey[50],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        customer
                                                                .customerCd
                                                                .isEmpty
                                                            ? '(No Code)'
                                                            : customer
                                                                  .customerCd,
                                                        style: TextStyle(
                                                          fontSize: isSmall
                                                              ? 14
                                                              : 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isSelected
                                                              ? const Color(
                                                                  0xFF1B5E20,
                                                                )
                                                              : const Color(
                                                                  0xFF424242,
                                                                ),
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: isSmall ? 12 : 12,
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      customer.fullName,
                                                      style: TextStyle(
                                                        fontSize: isSmall
                                                            ? 14
                                                            : 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF1B5E20,
                                                              )
                                                            : const Color(
                                                                0xFF212121,
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            SizedBox(height: isSmall ? 16 : 16),
                            // Pagination controls
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmall ? 12 : 16,
                                vertical: isSmall ? 12 : 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: ElevatedButton.icon(
                                      onPressed: currentPage > 0
                                          ? () => setState(() => currentPage--)
                                          : null,
                                      icon: Icon(
                                        Icons.chevron_left,
                                        size: isSmall ? 18 : 20,
                                      ),
                                      label: Text(
                                        'Previous',
                                        style: TextStyle(
                                          fontSize: isSmall ? 12 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: currentPage > 0
                                            ? const Color(0xFF1B5E20)
                                            : Colors.grey[300],
                                        foregroundColor: currentPage > 0
                                            ? Colors.white
                                            : Colors.grey[500],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isSmall ? 12 : 16,
                                          vertical: isSmall ? 10 : 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmall ? 8 : 16,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${currentPage + 1} / ${totalPages > 0 ? totalPages : 1}',
                                        style: TextStyle(
                                          fontSize: isSmall ? 12 : 14,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1B5E20),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: ElevatedButton.icon(
                                      onPressed: currentPage < totalPages - 1
                                          ? () => setState(() => currentPage++)
                                          : null,
                                      label: Text(
                                        'Next',
                                        style: TextStyle(
                                          fontSize: isSmall ? 12 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons.chevron_right,
                                        size: isSmall ? 18 : 20,
                                      ),
                                      iconAlignment: IconAlignment.end,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            currentPage < totalPages - 1
                                            ? const Color(0xFF1B5E20)
                                            : Colors.grey[300],
                                        foregroundColor:
                                            currentPage < totalPages - 1
                                            ? Colors.white
                                            : Colors.grey[500],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isSmall ? 12 : 16,
                                          vertical: isSmall ? 10 : 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isSmall ? 16 : 16),
                            // Confirm button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: selectedCustomer != null
                                    ? () {
                                        onSelect(
                                          selectedCustomer!.fullName,
                                          selectedCustomer!.customerId,
                                          selectedCustomer!,
                                        );
                                        Navigator.pop(context);
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedCustomer != null
                                      ? const Color(0xFF1B5E20)
                                      : Colors.grey[300],
                                  foregroundColor: selectedCustomer != null
                                      ? Colors.white
                                      : Colors.grey[500],
                                  padding: EdgeInsets.symmetric(
                                    vertical: isSmall ? 14 : 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: selectedCustomer != null ? 2 : 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: isSmall ? 20 : 24,
                                    ),
                                    SizedBox(width: isSmall ? 8 : 12),
                                    Text(
                                      'Confirm Selection',
                                      style: TextStyle(
                                        fontSize: isSmall ? 15 : 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> showShipperPartyPicker({
    required BuildContext context,
    required Function(String, int, Customer) onSelect,
  }) async {
    final customers = await _apiService.getShipperParties();
    if (!context.mounted) return;

    String searchQuery = '';
    String searchCategory = 'Customer Name';
    final TextEditingController searchController = TextEditingController();
    int currentPage = 0;
    const int itemsPerPage = 5;
    Customer? selectedCustomer;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Filter based on selected category
            final filteredCustomers = customers.where((customer) {
              if (searchQuery.isEmpty) return true;

              if (searchCategory == 'Customer Name') {
                return customer.fullName.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
              } else {
                // Customer Code
                return customer.customerCd.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
              }
            }).toList();

            final totalPages = (filteredCustomers.length / itemsPerPage).ceil();
            final startIndex = currentPage * itemsPerPage;
            final endIndex =
                (startIndex + itemsPerPage < filteredCustomers.length)
                ? startIndex + itemsPerPage
                : filteredCustomers.length;
            final paginatedCustomers = filteredCustomers.isNotEmpty
                ? filteredCustomers.sublist(startIndex, endIndex)
                : <Customer>[];

            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final isSmall = screenWidth < 600;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: EdgeInsets.symmetric(
                horizontal: isSmall ? 16 : 40,
                vertical: isSmall ? 20 : 40,
              ),
              child: Container(
                width: isSmall ? screenWidth * 0.92 : screenWidth * 0.6,
                height: isSmall ? screenHeight * 0.88 : screenHeight * 0.7,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, const Color(0xFFFFFBF0)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmall ? 16 : 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1B5E20),
                            const Color(0xFF2E7D32),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmall ? 8 : 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.local_shipping_rounded,
                              color: Colors.white,
                              size: isSmall ? 20 : 28,
                            ),
                          ),
                          SizedBox(width: isSmall ? 10 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Shipper Party',
                                  style: TextStyle(
                                    fontSize: isSmall ? 18 : 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Select a shipper party from the list',
                                  style: TextStyle(
                                    fontSize: isSmall ? 11 : 14,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                            color: Colors.white,
                            iconSize: isSmall ? 22 : 28,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(isSmall ? 12 : 24),
                        child: Column(
                          children: [
                            // Search controls row
                            Row(
                              children: [
                                // Category dropdown
                                Expanded(
                                  flex: isSmall ? 3 : 2,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmall ? 10 : 16,
                                      vertical: isSmall ? 0 : 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: searchCategory,
                                        isExpanded: true,
                                        isDense: isSmall,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: const Color(0xFF1B5E20),
                                          size: isSmall ? 20 : 24,
                                        ),
                                        style: TextStyle(
                                          fontSize: isSmall ? 12 : 15,
                                          color: const Color(0xFF212121),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        items:
                                            [
                                              'Customer Name',
                                              'Customer Code',
                                            ].map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: TextStyle(
                                                    fontSize: isSmall ? 12 : 15,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              searchCategory = newValue;
                                              currentPage = 0;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: isSmall ? 8 : 12),
                                // Search input field
                                Expanded(
                                  flex: isSmall ? 4 : 3,
                                  child: TextField(
                                    controller: searchController,
                                    style: TextStyle(
                                      fontSize: isSmall ? 13 : 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          searchCategory == 'Customer Name'
                                          ? "Enter name..."
                                          : "Enter code...",
                                      hintStyle: TextStyle(
                                        fontSize: isSmall ? 13 : 16,
                                        color: Colors.grey[400],
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: isSmall ? 12 : 16,
                                        vertical: isSmall ? 12 : 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFD4AF37),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onSubmitted: (value) {
                                      setState(() {
                                        searchQuery = value;
                                        currentPage = 0;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: isSmall ? 8 : 12),
                                // Search button
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      searchQuery = searchController.text;
                                      currentPage = 0;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4AF37),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.all(isSmall ? 12 : 18),
                                    minimumSize: Size.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Icon(
                                    Icons.search,
                                    size: isSmall ? 20 : 24,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmall ? 12 : 20),
                            // Column headers with better styling
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmall ? 16 : 16,
                                vertical: isSmall ? 14 : 14,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFF5F5F5),
                                    const Color(0xFFEEEEEE),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: isSmall ? 50 : 50,
                                    child: Icon(
                                      Icons.check_box_outline_blank,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Customer Code',
                                      style: TextStyle(
                                        fontSize: isSmall ? 13 : 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B5E20),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Customer Name',
                                      style: TextStyle(
                                        fontSize: isSmall ? 13 : 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B5E20),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isSmall ? 16 : 12),
                            Expanded(
                              child: filteredCustomers.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search_off,
                                            size: isSmall ? 56 : 64,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: isSmall ? 16 : 16),
                                          Text(
                                            'No customers found',
                                            style: TextStyle(
                                              fontSize: isSmall ? 16 : 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: paginatedCustomers.length,
                                      itemBuilder: (context, index) {
                                        final customer =
                                            paginatedCustomers[index];
                                        final isSelected =
                                            selectedCustomer?.customerId ==
                                            customer.customerId;
                                        return Container(
                                          margin: EdgeInsets.only(
                                            bottom: isSmall ? 10 : 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(
                                                    0xFFD4AF37,
                                                  ).withValues(alpha: 0.08)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFFD4AF37)
                                                  : Colors.grey[200]!,
                                              width: isSelected ? 2 : 1.5,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFFD4AF37,
                                                      ).withValues(alpha: 0.2),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ]
                                                : [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.03,
                                                          ),
                                                      blurRadius: 4,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                          ),
                                          child: InkWell(
                                            onTap: () => setState(
                                              () => selectedCustomer = customer,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isSmall ? 16 : 16,
                                                vertical: isSmall ? 12 : 16,
                                              ),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: isSmall ? 50 : 50,
                                                    child: Transform.scale(
                                                      scale: isSmall
                                                          ? 1.3
                                                          : 1.1,
                                                      child: Checkbox(
                                                        value: isSelected,
                                                        onChanged:
                                                            (
                                                              bool? value,
                                                            ) => setState(
                                                              () =>
                                                                  selectedCustomer =
                                                                      value ==
                                                                          true
                                                                      ? customer
                                                                      : null,
                                                            ),
                                                        activeColor:
                                                            const Color(
                                                              0xFFD4AF37,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF1B5E20,
                                                              ).withValues(
                                                                alpha: 0.1,
                                                              )
                                                            : Colors.grey[50],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        customer
                                                                .customerCd
                                                                .isEmpty
                                                            ? '(No Code)'
                                                            : customer
                                                                  .customerCd,
                                                        style: TextStyle(
                                                          fontSize: isSmall
                                                              ? 14
                                                              : 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isSelected
                                                              ? const Color(
                                                                  0xFF1B5E20,
                                                                )
                                                              : const Color(
                                                                  0xFF424242,
                                                                ),
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: isSmall ? 12 : 12,
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      customer.fullName,
                                                      style: TextStyle(
                                                        fontSize: isSmall
                                                            ? 14
                                                            : 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF1B5E20,
                                                              )
                                                            : const Color(
                                                                0xFF212121,
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            SizedBox(height: isSmall ? 16 : 16),
                            // Pagination controls
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmall ? 12 : 16,
                                vertical: isSmall ? 12 : 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: ElevatedButton.icon(
                                      onPressed: currentPage > 0
                                          ? () => setState(() => currentPage--)
                                          : null,
                                      icon: Icon(
                                        Icons.chevron_left,
                                        size: isSmall ? 18 : 20,
                                      ),
                                      label: Text(
                                        'Previous',
                                        style: TextStyle(
                                          fontSize: isSmall ? 12 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: currentPage > 0
                                            ? const Color(0xFF1B5E20)
                                            : Colors.grey[300],
                                        foregroundColor: currentPage > 0
                                            ? Colors.white
                                            : Colors.grey[500],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isSmall ? 12 : 16,
                                          vertical: isSmall ? 10 : 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmall ? 8 : 16,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${currentPage + 1} / ${totalPages > 0 ? totalPages : 1}',
                                        style: TextStyle(
                                          fontSize: isSmall ? 12 : 14,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1B5E20),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: ElevatedButton.icon(
                                      onPressed: currentPage < totalPages - 1
                                          ? () => setState(() => currentPage++)
                                          : null,
                                      label: Text(
                                        'Next',
                                        style: TextStyle(
                                          fontSize: isSmall ? 12 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons.chevron_right,
                                        size: isSmall ? 18 : 20,
                                      ),
                                      iconAlignment: IconAlignment.end,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            currentPage < totalPages - 1
                                            ? const Color(0xFF1B5E20)
                                            : Colors.grey[300],
                                        foregroundColor:
                                            currentPage < totalPages - 1
                                            ? Colors.white
                                            : Colors.grey[500],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isSmall ? 12 : 16,
                                          vertical: isSmall ? 10 : 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isSmall ? 16 : 16),
                            // Confirm button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: selectedCustomer != null
                                    ? () {
                                        onSelect(
                                          selectedCustomer!.fullName,
                                          selectedCustomer!.customerId,
                                          selectedCustomer!,
                                        );
                                        Navigator.pop(context);
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedCustomer != null
                                      ? const Color(0xFF1B5E20)
                                      : Colors.grey[300],
                                  foregroundColor: selectedCustomer != null
                                      ? Colors.white
                                      : Colors.grey[500],
                                  padding: EdgeInsets.symmetric(
                                    vertical: isSmall ? 14 : 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: selectedCustomer != null ? 2 : 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: isSmall ? 20 : 24,
                                    ),
                                    SizedBox(width: isSmall ? 8 : 12),
                                    Text(
                                      'Confirm Selection',
                                      style: TextStyle(
                                        fontSize: isSmall ? 15 : 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> showConsigneePartyPicker({
    required BuildContext context,
    required Function(String, int, Customer) onSelect,
  }) async {
    final customers = await _apiService.getConsigneeParties();
    if (!context.mounted) return;

    String searchQuery = '';
    String searchCategory = 'Customer Name';
    final TextEditingController searchController = TextEditingController();
    int currentPage = 0;
    const int itemsPerPage = 5;
    Customer? selectedCustomer;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Filter based on selected category
            final filteredCustomers = customers.where((customer) {
              if (searchQuery.isEmpty) return true;

              if (searchCategory == 'Customer Name') {
                return customer.fullName.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
              } else {
                // Customer Code
                return customer.customerCd.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
              }
            }).toList();

            final totalPages = (filteredCustomers.length / itemsPerPage).ceil();
            final startIndex = currentPage * itemsPerPage;
            final endIndex =
                (startIndex + itemsPerPage < filteredCustomers.length)
                ? startIndex + itemsPerPage
                : filteredCustomers.length;
            final paginatedCustomers = filteredCustomers.isNotEmpty
                ? filteredCustomers.sublist(startIndex, endIndex)
                : <Customer>[];

            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final isSmall = screenWidth < 600;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: EdgeInsets.symmetric(
                horizontal: isSmall ? 16 : 40,
                vertical: isSmall ? 20 : 40,
              ),
              child: Container(
                width: isSmall ? screenWidth * 0.92 : screenWidth * 0.6,
                height: isSmall ? screenHeight * 0.88 : screenHeight * 0.7,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, const Color(0xFFFFFBF0)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmall ? 16 : 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1B5E20),
                            const Color(0xFF2E7D32),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmall ? 8 : 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.person_pin_rounded,
                              color: Colors.white,
                              size: isSmall ? 20 : 28,
                            ),
                          ),
                          SizedBox(width: isSmall ? 10 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Consignee Party',
                                  style: TextStyle(
                                    fontSize: isSmall ? 18 : 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Select a consignee party from the list',
                                  style: TextStyle(
                                    fontSize: isSmall ? 11 : 14,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                            color: Colors.white,
                            iconSize: isSmall ? 22 : 28,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(isSmall ? 12 : 24),
                        child: Column(
                          children: [
                            // Search controls row - same as Agreement/Shipper
                            Row(
                              children: [
                                Expanded(
                                  flex: isSmall ? 3 : 2,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmall ? 10 : 16,
                                      vertical: isSmall ? 0 : 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: searchCategory,
                                        isExpanded: true,
                                        isDense: isSmall,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: const Color(0xFF1B5E20),
                                          size: isSmall ? 20 : 24,
                                        ),
                                        style: TextStyle(
                                          fontSize: isSmall ? 12 : 15,
                                          color: const Color(0xFF212121),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        items:
                                            [
                                              'Customer Name',
                                              'Customer Code',
                                            ].map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: TextStyle(
                                                    fontSize: isSmall ? 12 : 15,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              searchCategory = newValue;
                                              currentPage = 0;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: isSmall ? 8 : 12),
                                Expanded(
                                  flex: isSmall ? 4 : 3,
                                  child: TextField(
                                    controller: searchController,
                                    style: TextStyle(
                                      fontSize: isSmall ? 13 : 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          searchCategory == 'Customer Name'
                                          ? "Enter name..."
                                          : "Enter code...",
                                      hintStyle: TextStyle(
                                        fontSize: isSmall ? 13 : 16,
                                        color: Colors.grey[400],
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: isSmall ? 12 : 16,
                                        vertical: isSmall ? 12 : 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFD4AF37),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onSubmitted: (value) {
                                      setState(() {
                                        searchQuery = value;
                                        currentPage = 0;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: isSmall ? 8 : 12),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      searchQuery = searchController.text;
                                      currentPage = 0;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4AF37),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.all(isSmall ? 12 : 18),
                                    minimumSize: Size.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Icon(
                                    Icons.search,
                                    size: isSmall ? 20 : 24,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmall ? 12 : 20),
                            // Table header and content - same structure as Agreement/Shipper
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmall ? 16 : 16,
                                vertical: isSmall ? 14 : 14,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFF5F5F5),
                                    const Color(0xFFEEEEEE),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: isSmall ? 50 : 50,
                                    child: Icon(
                                      Icons.check_box_outline_blank,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Customer Code',
                                      style: TextStyle(
                                        fontSize: isSmall ? 13 : 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B5E20),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Customer Name',
                                      style: TextStyle(
                                        fontSize: isSmall ? 13 : 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B5E20),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isSmall ? 16 : 12),
                            Expanded(
                              child: filteredCustomers.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search_off,
                                            size: isSmall ? 56 : 64,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: isSmall ? 16 : 16),
                                          Text(
                                            'No customers found',
                                            style: TextStyle(
                                              fontSize: isSmall ? 16 : 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: paginatedCustomers.length,
                                      itemBuilder: (context, index) {
                                        final customer =
                                            paginatedCustomers[index];
                                        final isSelected =
                                            selectedCustomer?.customerId ==
                                            customer.customerId;
                                        return Container(
                                          margin: EdgeInsets.only(
                                            bottom: isSmall ? 10 : 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(
                                                    0xFFD4AF37,
                                                  ).withValues(alpha: 0.08)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFFD4AF37)
                                                  : Colors.grey[200]!,
                                              width: isSelected ? 2 : 1.5,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFFD4AF37,
                                                      ).withValues(alpha: 0.2),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ]
                                                : [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.03,
                                                          ),
                                                      blurRadius: 4,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                          ),
                                          child: InkWell(
                                            onTap: () => setState(
                                              () => selectedCustomer = customer,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isSmall ? 16 : 16,
                                                vertical: isSmall ? 12 : 16,
                                              ),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: isSmall ? 50 : 50,
                                                    child: Transform.scale(
                                                      scale: isSmall
                                                          ? 1.3
                                                          : 1.1,
                                                      child: Checkbox(
                                                        value: isSelected,
                                                        onChanged:
                                                            (
                                                              bool? value,
                                                            ) => setState(
                                                              () =>
                                                                  selectedCustomer =
                                                                      value ==
                                                                          true
                                                                      ? customer
                                                                      : null,
                                                            ),
                                                        activeColor:
                                                            const Color(
                                                              0xFFD4AF37,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF1B5E20,
                                                              ).withValues(
                                                                alpha: 0.1,
                                                              )
                                                            : Colors.grey[50],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        customer
                                                                .customerCd
                                                                .isEmpty
                                                            ? '(No Code)'
                                                            : customer
                                                                  .customerCd,
                                                        style: TextStyle(
                                                          fontSize: isSmall
                                                              ? 14
                                                              : 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isSelected
                                                              ? const Color(
                                                                  0xFF1B5E20,
                                                                )
                                                              : const Color(
                                                                  0xFF424242,
                                                                ),
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: isSmall ? 12 : 12,
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      customer.fullName,
                                                      style: TextStyle(
                                                        fontSize: isSmall
                                                            ? 14
                                                            : 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF1B5E20,
                                                              )
                                                            : const Color(
                                                                0xFF212121,
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            SizedBox(height: isSmall ? 16 : 16),
                            // Pagination and Confirm button - same as Agreement/Shipper
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmall ? 12 : 16,
                                vertical: isSmall ? 12 : 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: ElevatedButton.icon(
                                      onPressed: currentPage > 0
                                          ? () => setState(() => currentPage--)
                                          : null,
                                      icon: Icon(
                                        Icons.chevron_left,
                                        size: isSmall ? 18 : 20,
                                      ),
                                      label: Text(
                                        'Previous',
                                        style: TextStyle(
                                          fontSize: isSmall ? 12 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: currentPage > 0
                                            ? const Color(0xFF1B5E20)
                                            : Colors.grey[300],
                                        foregroundColor: currentPage > 0
                                            ? Colors.white
                                            : Colors.grey[500],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isSmall ? 12 : 16,
                                          vertical: isSmall ? 10 : 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmall ? 8 : 16,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${currentPage + 1} / ${totalPages > 0 ? totalPages : 1}',
                                        style: TextStyle(
                                          fontSize: isSmall ? 12 : 14,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1B5E20),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: ElevatedButton.icon(
                                      onPressed: currentPage < totalPages - 1
                                          ? () => setState(() => currentPage++)
                                          : null,
                                      label: Text(
                                        'Next',
                                        style: TextStyle(
                                          fontSize: isSmall ? 12 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons.chevron_right,
                                        size: isSmall ? 18 : 20,
                                      ),
                                      iconAlignment: IconAlignment.end,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            currentPage < totalPages - 1
                                            ? const Color(0xFF1B5E20)
                                            : Colors.grey[300],
                                        foregroundColor:
                                            currentPage < totalPages - 1
                                            ? Colors.white
                                            : Colors.grey[500],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isSmall ? 12 : 16,
                                          vertical: isSmall ? 10 : 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isSmall ? 16 : 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: selectedCustomer != null
                                    ? () {
                                        onSelect(
                                          selectedCustomer!.fullName,
                                          selectedCustomer!.customerId,
                                          selectedCustomer!,
                                        );
                                        Navigator.pop(context);
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedCustomer != null
                                      ? const Color(0xFF1B5E20)
                                      : Colors.grey[300],
                                  foregroundColor: selectedCustomer != null
                                      ? Colors.white
                                      : Colors.grey[500],
                                  padding: EdgeInsets.symmetric(
                                    vertical: isSmall ? 14 : 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: selectedCustomer != null ? 2 : 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: isSmall ? 20 : 24,
                                    ),
                                    SizedBox(width: isSmall ? 8 : 12),
                                    Text(
                                      'Confirm Selection',
                                      style: TextStyle(
                                        fontSize: isSmall ? 15 : 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> showContainerPicker({
    required BuildContext context,
    required Function(String, int) onSelect,
  }) async {
    final containers = await _apiService.getContainers();
    if (!context.mounted) return;

    String searchQuery = '';
    final TextEditingController searchController = TextEditingController();
    int currentPage = 0;
    const int itemsPerPage = 5;
    ContainerData? selectedContainer;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Filter based on search query
            final filteredContainers = containers.where((container) {
              if (searchQuery.isEmpty) return true;
              return container.containerNo.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );
            }).toList();

            final totalPages = (filteredContainers.length / itemsPerPage)
                .ceil();
            final startIndex = currentPage * itemsPerPage;
            final endIndex =
                (startIndex + itemsPerPage < filteredContainers.length)
                ? startIndex + itemsPerPage
                : filteredContainers.length;
            final paginatedContainers = filteredContainers.isNotEmpty
                ? filteredContainers.sublist(startIndex, endIndex)
                : <ContainerData>[];

            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final isSmall = screenWidth < 600;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: EdgeInsets.symmetric(
                horizontal: isSmall ? 16 : 40,
                vertical: isSmall ? 20 : 40,
              ),
              child: Container(
                width: isSmall ? screenWidth * 0.92 : screenWidth * 0.6,
                height: isSmall ? screenHeight * 0.88 : screenHeight * 0.7,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, const Color(0xFFFFFBF0)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with gradient background
                    Container(
                      padding: EdgeInsets.all(isSmall ? 16 : 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1B5E20),
                            const Color(0xFF2E7D32),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmall ? 8 : 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.inventory_2_rounded,
                              color: Colors.white,
                              size: isSmall ? 20 : 28,
                            ),
                          ),
                          SizedBox(width: isSmall ? 10 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Container',
                                  style: TextStyle(
                                    fontSize: isSmall ? 18 : 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Choose a container number from the list',
                                  style: TextStyle(
                                    fontSize: isSmall ? 11 : 14,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                            color: Colors.white,
                            iconSize: isSmall ? 22 : 28,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content area
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(isSmall ? 12 : 24),
                        child: Column(
                          children: [
                            // Search controls row
                            Row(
                              children: [
                                // Search input field
                                Expanded(
                                  child: TextField(
                                    controller: searchController,
                                    style: TextStyle(
                                      fontSize: isSmall ? 13 : 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Enter container number...",
                                      hintStyle: TextStyle(
                                        fontSize: isSmall ? 13 : 16,
                                        color: Colors.grey[400],
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: isSmall ? 12 : 16,
                                        vertical: isSmall ? 10 : 14,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF1B5E20),
                                          width: 2,
                                        ),
                                      ),
                                      suffixIcon: searchQuery.isNotEmpty
                                          ? IconButton(
                                              icon: Icon(
                                                Icons.clear,
                                                size: isSmall ? 18 : 20,
                                              ),
                                              onPressed: () {
                                                searchController.clear();
                                                setState(() {
                                                  searchQuery = '';
                                                  currentPage = 0;
                                                });
                                              },
                                            )
                                          : null,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        searchQuery = value;
                                        currentPage = 0;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: isSmall ? 8 : 12),
                                // Search button
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      searchQuery = searchController.text;
                                      currentPage = 0;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFA000),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmall ? 16 : 24,
                                      vertical: isSmall ? 12 : 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.search,
                                        size: isSmall ? 18 : 20,
                                      ),
                                      if (!isSmall) ...[
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Search',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmall ? 16 : 20),

                            // Table header - 2 columns
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmall ? 12 : 16,
                                vertical: isSmall ? 10 : 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: isSmall ? 40 : 50,
                                    child: Text(
                                      '',
                                      style: TextStyle(
                                        fontSize: isSmall ? 12 : 14,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF424242),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Container Number',
                                      style: TextStyle(
                                        fontSize: isSmall ? 12 : 14,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF424242),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Table rows
                            Expanded(
                              child: paginatedContainers.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search_off,
                                            size: isSmall ? 48 : 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No containers found',
                                            style: TextStyle(
                                              fontSize: isSmall ? 14 : 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: paginatedContainers.length,
                                      itemBuilder: (context, index) {
                                        final container =
                                            paginatedContainers[index];
                                        final isSelected =
                                            selectedContainer?.containerId ==
                                            container.containerId;

                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFFE8F5E9)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFF1B5E20)
                                                  : Colors.grey[200]!,
                                              width: isSelected ? 2 : 1,
                                            ),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedContainer = container;
                                              });
                                            },
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isSmall ? 12 : 16,
                                                vertical: isSmall ? 10 : 12,
                                              ),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: isSmall ? 40 : 50,
                                                    child: Checkbox(
                                                      value: isSelected,
                                                      onChanged: (bool? value) {
                                                        setState(() {
                                                          selectedContainer =
                                                              value == true
                                                              ? container
                                                              : null;
                                                        });
                                                      },
                                                      activeColor: const Color(
                                                        0xFF1B5E20,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      container.containerNo,
                                                      style: TextStyle(
                                                        fontSize: isSmall
                                                            ? 13
                                                            : 15,
                                                        color: const Color(
                                                          0xFF212121,
                                                        ),
                                                        fontWeight: isSelected
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),

                            // Pagination controls
                            if (filteredContainers.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: currentPage > 0
                                        ? () {
                                            setState(() {
                                              currentPage--;
                                            });
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1B5E20),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.grey[300],
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmall ? 12 : 20,
                                        vertical: isSmall ? 8 : 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.chevron_left,
                                          size: isSmall ? 18 : 20,
                                        ),
                                        if (!isSmall) ...[
                                          const SizedBox(width: 4),
                                          const Text('Previous'),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${currentPage + 1} of $totalPages',
                                    style: TextStyle(
                                      fontSize: isSmall ? 13 : 15,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF424242),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: currentPage < totalPages - 1
                                        ? () {
                                            setState(() {
                                              currentPage++;
                                            });
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1B5E20),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.grey[300],
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmall ? 12 : 20,
                                        vertical: isSmall ? 8 : 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (!isSmall) ...[
                                          const Text('Next'),
                                          const SizedBox(width: 4),
                                        ],
                                        Icon(
                                          Icons.chevron_right,
                                          size: isSmall ? 18 : 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // Confirm button
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: selectedContainer != null
                                    ? () {
                                        onSelect(
                                          selectedContainer!.containerNo,
                                          selectedContainer!.containerId,
                                        );
                                        Navigator.pop(context);
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1B5E20),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey[300],
                                  padding: EdgeInsets.symmetric(
                                    vertical: isSmall ? 12 : 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_outline),
                                    const SizedBox(width: 8),
                                    Text(
                                      'CONFIRM SELECTION',
                                      style: TextStyle(
                                        fontSize: isSmall ? 14 : 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> showVesselSchedulePicker({
    required BuildContext context,
    required int originLocationId,
    required int destinationLocationId,
    required int vesselId,
    required Function(String, int, VesselSchedule) onSelect,
  }) async {
    final schedules = await _apiService.getVesselSchedules(
      originLocationId: originLocationId,
      destinationLocationId: destinationLocationId,
      vesselId: vesselId,
    );
    if (!context.mounted) return;

    int currentPage = 0;
    const int itemsPerPage = 5;
    int? selectedScheduleId;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final totalPages = (schedules.length / itemsPerPage).ceil();
            final startIndex = currentPage * itemsPerPage;
            final endIndex = (startIndex + itemsPerPage < schedules.length)
                ? startIndex + itemsPerPage
                : schedules.length;
            final paginatedSchedules = schedules.isNotEmpty
                ? schedules.sublist(startIndex, endIndex)
                : [];

            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final isSmall = screenWidth < 600;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: EdgeInsets.symmetric(
                horizontal: isSmall ? 16 : 40,
                vertical: isSmall ? 20 : 40,
              ),
              child: Container(
                width: isSmall ? screenWidth * 0.92 : screenWidth * 0.7,
                height: isSmall ? screenHeight * 0.88 : screenHeight * 0.7,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, const Color(0xFFFFFBF0)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with gradient background
                    Container(
                      padding: EdgeInsets.all(isSmall ? 16 : 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1B5E20),
                            const Color(0xFF2E7D32),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmall ? 8 : 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.schedule_rounded,
                              color: Colors.white,
                              size: isSmall ? 20 : 28,
                            ),
                          ),
                          SizedBox(width: isSmall ? 10 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Vessel Schedule',
                                  style: TextStyle(
                                    fontSize: isSmall ? 18 : 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Choose a schedule from the list',
                                  style: TextStyle(
                                    fontSize: isSmall ? 11 : 14,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                            color: Colors.white,
                            iconSize: isSmall ? 22 : 28,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content area
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(isSmall ? 12 : 24),
                        child: Column(
                          children: [
                            // Column headers with 5 columns
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmall ? 12 : 16,
                                vertical: isSmall ? 12 : 14,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFF5F5F5),
                                    const Color(0xFFEEEEEE),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: isSmall ? 40 : 50,
                                    child: Icon(
                                      Icons.check_box_outline_blank,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'POL',
                                      style: TextStyle(
                                        fontSize: isSmall ? 12 : 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B5E20),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'POD',
                                      style: TextStyle(
                                        fontSize: isSmall ? 12 : 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B5E20),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'ETD',
                                      style: TextStyle(
                                        fontSize: isSmall ? 12 : 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B5E20),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'ETA',
                                      style: TextStyle(
                                        fontSize: isSmall ? 12 : 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B5E20),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isSmall ? 12 : 16),
                            Expanded(
                              child: schedules.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search_off,
                                            size: isSmall ? 56 : 64,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: isSmall ? 16 : 16),
                                          Text(
                                            'No schedules found',
                                            style: TextStyle(
                                              fontSize: isSmall ? 16 : 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Try selecting different filters',
                                            style: TextStyle(
                                              fontSize: isSmall ? 13 : 14,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: paginatedSchedules.length,
                                      itemBuilder: (context, index) {
                                        final schedule =
                                            paginatedSchedules[index];
                                        final isSelected =
                                            selectedScheduleId ==
                                            schedule.vesselScheduleId;

                                        // Format dates with time (add 8 hours for timezone)
                                        final etdStr = schedule.etd != null
                                            ? () {
                                                final adjustedEtd = schedule
                                                    .etd!
                                                    .add(
                                                      const Duration(hours: 8),
                                                    );
                                                return '${adjustedEtd.month.toString().padLeft(2, '0')}/${adjustedEtd.day.toString().padLeft(2, '0')}/${adjustedEtd.year} ${adjustedEtd.hour.toString().padLeft(2, '0')}:${adjustedEtd.minute.toString().padLeft(2, '0')}';
                                              }()
                                            : 'N/A';
                                        final etaStr = schedule.eta != null
                                            ? () {
                                                final adjustedEta = schedule
                                                    .eta!
                                                    .add(
                                                      const Duration(hours: 8),
                                                    );
                                                return '${adjustedEta.month.toString().padLeft(2, '0')}/${adjustedEta.day.toString().padLeft(2, '0')}/${adjustedEta.year} ${adjustedEta.hour.toString().padLeft(2, '0')}:${adjustedEta.minute.toString().padLeft(2, '0')}';
                                              }()
                                            : 'N/A';

                                        return Container(
                                          margin: EdgeInsets.only(
                                            bottom: isSmall ? 8 : 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(
                                                    0xFFD4AF37,
                                                  ).withValues(alpha: 0.08)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFFD4AF37)
                                                  : Colors.grey[200]!,
                                              width: isSelected ? 2 : 1.5,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFFD4AF37,
                                                      ).withValues(alpha: 0.2),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ]
                                                : [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.03,
                                                          ),
                                                      blurRadius: 4,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                          ),
                                          child: InkWell(
                                            onTap: () => setState(
                                              () => selectedScheduleId =
                                                  schedule.vesselScheduleId,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isSmall ? 12 : 16,
                                                vertical: isSmall ? 10 : 12,
                                              ),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: isSmall ? 40 : 50,
                                                    child: Transform.scale(
                                                      scale: isSmall
                                                          ? 1.2
                                                          : 1.1,
                                                      child: Checkbox(
                                                        value: isSelected,
                                                        onChanged:
                                                            (
                                                              bool? value,
                                                            ) => setState(
                                                              () => selectedScheduleId =
                                                                  value == true
                                                                  ? schedule
                                                                        .vesselScheduleId
                                                                  : null,
                                                            ),
                                                        activeColor:
                                                            const Color(
                                                              0xFFD4AF37,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      schedule.originPortDesc,
                                                      style: TextStyle(
                                                        fontSize: isSmall
                                                            ? 12
                                                            : 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF1B5E20,
                                                              )
                                                            : const Color(
                                                                0xFF212121,
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      schedule
                                                          .destinationPortDesc,
                                                      style: TextStyle(
                                                        fontSize: isSmall
                                                            ? 12
                                                            : 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF1B5E20,
                                                              )
                                                            : const Color(
                                                                0xFF212121,
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      etdStr,
                                                      style: TextStyle(
                                                        fontSize: isSmall
                                                            ? 11
                                                            : 12,
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF1B5E20,
                                                              )
                                                            : const Color(
                                                                0xFF424242,
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      etaStr,
                                                      style: TextStyle(
                                                        fontSize: isSmall
                                                            ? 11
                                                            : 12,
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF1B5E20,
                                                              )
                                                            : const Color(
                                                                0xFF424242,
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            SizedBox(height: isSmall ? 16 : 16),
                            // Pagination controls
                            if (schedules.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmall ? 12 : 16,
                                  vertical: isSmall ? 12 : 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.03,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: ElevatedButton.icon(
                                        onPressed: currentPage > 0
                                            ? () =>
                                                  setState(() => currentPage--)
                                            : null,
                                        icon: Icon(
                                          Icons.chevron_left,
                                          size: isSmall ? 18 : 20,
                                        ),
                                        label: Text(
                                          'Previous',
                                          style: TextStyle(
                                            fontSize: isSmall ? 12 : 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: currentPage > 0
                                              ? const Color(0xFF1B5E20)
                                              : Colors.grey[300],
                                          foregroundColor: currentPage > 0
                                              ? Colors.white
                                              : Colors.grey[500],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmall ? 12 : 16,
                                            vertical: isSmall ? 10 : 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmall ? 8 : 16,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5F5F5),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          '${currentPage + 1} / ${totalPages > 0 ? totalPages : 1}',
                                          style: TextStyle(
                                            fontSize: isSmall ? 12 : 14,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1B5E20),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: ElevatedButton.icon(
                                        onPressed: currentPage < totalPages - 1
                                            ? () =>
                                                  setState(() => currentPage++)
                                            : null,
                                        label: Text(
                                          'Next',
                                          style: TextStyle(
                                            fontSize: isSmall ? 12 : 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.chevron_right,
                                          size: isSmall ? 18 : 20,
                                        ),
                                        iconAlignment: IconAlignment.end,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              currentPage < totalPages - 1
                                              ? const Color(0xFF1B5E20)
                                              : Colors.grey[300],
                                          foregroundColor:
                                              currentPage < totalPages - 1
                                              ? Colors.white
                                              : Colors.grey[500],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmall ? 12 : 16,
                                            vertical: isSmall ? 10 : 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(height: isSmall ? 16 : 16),
                            // Confirm button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: selectedScheduleId != null
                                    ? () {
                                        final selectedSchedule = schedules
                                            .firstWhere(
                                              (s) =>
                                                  s.vesselScheduleId ==
                                                  selectedScheduleId,
                                            );
                                        final displayText =
                                            '${selectedSchedule.originPortDesc} → ${selectedSchedule.destinationPortDesc}';
                                        onSelect(
                                          displayText,
                                          selectedSchedule.vesselScheduleId,
                                          selectedSchedule,
                                        );
                                        Navigator.pop(context);
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedScheduleId != null
                                      ? const Color(0xFF1B5E20)
                                      : Colors.grey[300],
                                  foregroundColor: selectedScheduleId != null
                                      ? Colors.white
                                      : Colors.grey[500],
                                  padding: EdgeInsets.symmetric(
                                    vertical: isSmall ? 14 : 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: selectedScheduleId != null ? 2 : 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: isSmall ? 20 : 24,
                                    ),
                                    SizedBox(width: isSmall ? 8 : 12),
                                    Text(
                                      'Confirm Selection',
                                      style: TextStyle(
                                        fontSize: isSmall ? 15 : 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
