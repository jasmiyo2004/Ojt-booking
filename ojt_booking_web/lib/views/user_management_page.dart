import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';
import '../models/user_model.dart';
import '../widgets/success_dialog.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final ApiService _apiService = ApiService();
  List<User> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All'; // All, Active, Inactive

  // Pagination
  int _currentPage = 1;
  static const int _itemsPerPage = 5;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final usersData = await _apiService.getUsers();
      setState(() {
        _users = usersData.map((json) => User.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  List<User> get _filteredUsers {
    var filtered = _users;

    // Apply status filter
    if (_statusFilter == 'Active') {
      filtered = filtered.where((user) => user.statusDesc == 'Active').toList();
    } else if (_statusFilter == 'Inactive') {
      filtered = filtered.where((user) => user.statusDesc != 'Active').toList();
    }

    // Apply search filter
    if (_searchQuery.isEmpty) return filtered;
    return filtered.where((user) {
      final fullName = user.fullName.toLowerCase();
      final email = user.email?.toLowerCase() ?? '';
      final userCode = user.userCode?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return fullName.contains(query) ||
          email.contains(query) ||
          userCode.contains(query);
    }).toList();
  }

  List<User> get _paginatedUsers {
    final filtered = _filteredUsers;
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= filtered.length) return [];
    return filtered.sublist(
      start,
      end > filtered.length ? filtered.length : end,
    );
  }

  int get _totalPages {
    return (_filteredUsers.length / _itemsPerPage).ceil();
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages) {
      setState(() => _currentPage++);
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── Yellow Header ──────────────────────────────
          Container(
            decoration: const BoxDecoration(color: Color(0xFFFFEB3B)),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.people_rounded,
                        color: Color(0xFFD4AF37),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'User Management',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            '${_users.length} users registered',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF424242),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── White content area ─────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'All Users',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'View, create and manage system users',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Create New User button and Status Filter
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: () => _showAddUserDialog(),
                                icon: const Icon(
                                  Icons.person_add_rounded,
                                  size: 20,
                                ),
                                label: const Text(
                                  'Create New User',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4AF37),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _statusFilter,
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons.filter_list_rounded,
                                      size: 20,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF212121),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'All',
                                        child: Text('All Users'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Active',
                                        child: Text('Active'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Inactive',
                                        child: Text('Inactive'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _statusFilter = value ?? 'All';
                                        _currentPage = 1;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Search bar with clear button
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) => setState(() {
                                    _searchQuery = value;
                                    _currentPage = 1;
                                  }),
                                  decoration: InputDecoration(
                                    hintText: 'Search by name, code, or email…',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Clear button
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _searchQuery.isNotEmpty
                                    ? const Color(0xFFEF5350)
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: _searchQuery.isNotEmpty
                                    ? [
                                        BoxShadow(
                                          color: const Color(
                                            0xFFEF5350,
                                          ).withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: IconButton(
                                onPressed: _searchQuery.isNotEmpty
                                    ? () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchQuery = '';
                                          _currentPage = 1;
                                        });
                                      }
                                    : null,
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: _searchQuery.isNotEmpty
                                      ? Colors.white
                                      : Colors.grey[500],
                                  size: 22,
                                ),
                                tooltip: 'Clear search',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // User list
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFD4AF37),
                            ),
                          )
                        : _filteredUsers.isEmpty
                        ? _buildEmptyState()
                        : Column(
                            children: [
                              Expanded(
                                child: ListView.separated(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    0,
                                    24,
                                    12,
                                  ),
                                  itemCount: _paginatedUsers.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) =>
                                      _buildUserCard(_paginatedUsers[index]),
                                ),
                              ),
                              if (_totalPages > 1) _buildPagination(),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 100,
            height: 40,
            child: ElevatedButton(
              onPressed: _currentPage > 1 ? _goToPreviousPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentPage > 1
                    ? const Color(0xFFD4AF37)
                    : Colors.grey[300],
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: const Text(
                'Previous',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Text(
              '$_currentPage of $_totalPages',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
          ),
          SizedBox(
            width: 100,
            height: 40,
            child: ElevatedButton(
              onPressed: _currentPage < _totalPages ? _goToNextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentPage < _totalPages
                    ? const Color(0xFFD4AF37)
                    : Colors.grey[300],
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(User user) {
    final isAdmin = (user.userTypeDesc ?? '').toLowerCase().contains('admin');
    final isActive = user.statusDesc == 'Active';

    // Role badge colors
    final roleColor = isAdmin
        ? const Color(0xFFD4AF37)
        : const Color(0xFF2E7D32);
    final roleBg = isAdmin ? const Color(0xFFFFF8E1) : const Color(0xFFE8F5E9);
    final roleLabel = isAdmin ? 'Admin' : 'Local';

    // Avatar background color based on role
    final avatarBg = isAdmin
        ? const Color(0xFFD4AF37)
        : const Color(0xFF2E7D32);

    // Decode profile picture if available
    Uint8List? imgBytes;
    if (user.profilePicture != null && user.profilePicture!.isNotEmpty) {
      try {
        imgBytes = base64Decode(user.profilePicture!);
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: imgBytes != null ? Colors.transparent : avatarBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!, width: 1.5),
                  image: imgBytes != null
                      ? DecorationImage(
                          image: MemoryImage(imgBytes),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imgBytes == null
                    ? Center(
                        child: Text(
                          user.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + role badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: roleBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            roleLabel,
                            style: TextStyle(
                              color: roleColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    // Email
                    Text(
                      user.email ?? 'No email',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    // UserCode chip
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            user.userCode ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF424242),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Active/Inactive dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green : Colors.red[400],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 11,
                            color: isActive
                                ? Colors.green[700]
                                : Colors.red[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Divider
          Container(height: 1, color: Colors.grey[200]),
          const SizedBox(height: 8),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionBtn(
                icon: Icons.visibility_rounded,
                label: 'View',
                color: const Color(0xFF2196F3),
                onTap: () => _showViewUserDialog(user),
              ),
              const SizedBox(width: 8),
              _buildActionBtn(
                icon: Icons.edit_rounded,
                label: 'Edit',
                color: const Color(0xFFFF9800),
                onTap: () => _showEditUserDialog(user),
              ),
              const SizedBox(width: 8),
              _buildActionBtn(
                icon: isActive
                    ? Icons.block_rounded
                    : Icons.check_circle_rounded,
                label: isActive ? 'Deactivate' : 'Activate',
                color: isActive ? const Color(0xFFEF5350) : Colors.green,
                onTap: () => _toggleUserStatus(user),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── View Dialog ──────────────────────────────────────────────────────────────

  void _showViewUserDialog(User user) {
    final isAdmin = (user.userTypeDesc ?? '').toLowerCase().contains('admin');
    final isActive = user.statusDesc == 'Active';
    final avatarBg = isAdmin
        ? const Color(0xFFD4AF37)
        : const Color(0xFF2E7D32);

    Uint8List? imgBytes;
    if (user.profilePicture != null && user.profilePicture!.isNotEmpty) {
      try {
        imgBytes = base64Decode(user.profilePicture!);
      } catch (_) {}
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 620),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header band
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: avatarBg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    // Profile photo
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6),
                          width: 2,
                        ),
                        image: imgBytes != null
                            ? DecorationImage(
                                image: MemoryImage(imgBytes),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: imgBytes == null
                          ? Center(
                              child: Text(
                                user.initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _viewBadge(
                                isAdmin ? 'Admin' : 'Local',
                                Colors.white,
                              ),
                              const SizedBox(width: 8),
                              _viewBadge(
                                isActive ? 'Active' : 'Inactive',
                                isActive
                                    ? Colors.green[200]!
                                    : Colors.red[200]!,
                                textColor: const Color(0xFF212121),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _infoSection('Personal Information', [
                        _infoRow(
                          'First Name',
                          user.firstName ?? 'N/A',
                          Icons.person_outline,
                        ),
                        _infoRow(
                          'Middle Name',
                          user.middleName ?? 'N/A',
                          Icons.person_outline,
                        ),
                        _infoRow(
                          'Last Name',
                          user.lastName ?? 'N/A',
                          Icons.person_outline,
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _infoSection('Contact Information', [
                        _infoRow('Email', user.email ?? 'N/A', Icons.email),
                        _infoRow('Phone', user.number ?? 'N/A', Icons.phone),
                      ]),
                      const SizedBox(height: 16),
                      _infoSection('Account Information', [
                        _infoRow(
                          'User Code',
                          user.userCode ?? 'N/A',
                          Icons.qr_code,
                        ),
                        _infoRow(
                          'User Type',
                          user.userTypeDesc ?? 'N/A',
                          Icons.admin_panel_settings,
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _viewBadge(String label, Color bg, {Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _infoSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        ...rows,
      ],
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Add / Edit Dialogs ───────────────────────────────────────────────────────

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        existingUsers: _users,
        onSave: (userData) async {
          final parentContext = this.context;
          try {
            await _apiService.createUser(userData);
            await _loadData();
            if (mounted && parentContext.mounted) {
              SuccessDialog.show(
                parentContext,
                title: 'USER CREATED',
                message: 'New user is successfully created!',
              );
            }
          } catch (e) {
            if (mounted && parentContext.mounted) {
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(
                  content: Text('Error creating user: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditUserDialog(User user) {
    final parentContext = context; // capture page context before dialog opens
    showDialog(
      context: parentContext,
      builder: (_) => UserFormDialog(
        user: user,
        existingUsers: _users,
        onSave: (userData) async {
          final sm = ScaffoldMessenger.of(parentContext);
          try {
            await _apiService.updateUser(user.userId, userData);
            await _loadData();

            // Update session if the edited user is the currently logged-in user
            final currentUserId = UserSession().userId;
            if (currentUserId == user.userId) {
              final updatedUserData = Map<String, dynamic>.from(
                UserSession().currentUser ?? {},
              );
              updatedUserData['firstName'] = userData['firstName'];
              updatedUserData['middleName'] = userData['middleName'];
              updatedUserData['lastName'] = userData['lastName'];
              updatedUserData['email'] = userData['email'];
              updatedUserData['number'] = userData['number'];
              updatedUserData['profilePicture'] = userData['profilePicture'];
              updatedUserData['fullName'] =
                  '${userData['firstName']} ${userData['middleName'] ?? ''} ${userData['lastName']}'
                      .trim();
              UserSession().setUser(updatedUserData);
            }

            if (mounted) {
              SuccessDialog.show(
                parentContext,
                title: 'USER UPDATED',
                message: '${user.fullName} has been updated successfully!',
              );
            }
          } catch (e) {
            sm.showSnackBar(
              SnackBar(
                content: Text('Error updating user: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _toggleUserStatus(User user) {
    final isActive = user.statusDesc == 'Active';

    // For deactivation, show remarks dialog first
    if (isActive) {
      _showDeactivateRemarksDialog(user);
    } else {
      // For activation, show confirmation directly
      _showActivateConfirmation(user);
    }
  }

  void _showDeactivateRemarksDialog(User user) {
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Deactivate User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to deactivate ${user.fullName}?'),
            const SizedBox(height: 20),
            const Text(
              'Remarks:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: remarksController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter reason for deactivation...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final remarks = remarksController.text.trim();
              if (remarks.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter remarks'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              await _deactivateUser(user, remarks);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _showActivateConfirmation(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Activate User'),
        content: Text('Are you sure you want to activate ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _activateUser(user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Activate'),
          ),
        ],
      ),
    );
  }

  Future<void> _deactivateUser(User user, String remarks) async {
    try {
      await _apiService.updateUser(user.userId, {
        'statusId': 2,
        'remarks': remarks,
        'updateUserId': UserSession().userId?.toString() ?? 'SYSTEM',
      });
      await _loadData();

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'USER STATUS UPDATED',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'User: ${user.userCode} has successfully INACTIVE.',
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deactivating user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _activateUser(User user) async {
    try {
      await _apiService.updateUser(user.userId, {
        'statusId': 1,
        'updateUserId': UserSession().userId?.toString() ?? 'SYSTEM',
      });
      await _loadData();

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'USER STATUS UPDATED',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'User: ${user.userCode} has successfully ACTIVE.',
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error activating user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// User Form Dialog — Add / Edit with profile photo picker
// ════════════════════════════════════════════════════════════════════════════════

class UserFormDialog extends StatefulWidget {
  final User? user;
  final List<User> existingUsers;
  final Function(Map<String, dynamic>) onSave;

  const UserFormDialog({
    super.key,
    this.user,
    required this.existingUsers,
    required this.onSave,
  });

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _numberController;
  late TextEditingController _userCodeController;
  late TextEditingController _passwordController;
  int? _selectedUserTypeId;
  int _selectedStatusId = 1;
  bool _obscurePassword = true;

  // Profile picture
  Uint8List? _imageBytes;
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user?.firstName);
    _middleNameController = TextEditingController(
      text: widget.user?.middleName,
    );
    _lastNameController = TextEditingController(text: widget.user?.lastName);
    _emailController = TextEditingController(text: widget.user?.email);
    _numberController = TextEditingController(text: widget.user?.number);
    _userCodeController = TextEditingController(text: widget.user?.userCode);
    _passwordController = TextEditingController();
    _selectedUserTypeId = widget.user?.userIdType;
    _selectedStatusId = widget.user?.statusId ?? 1;

    // Load existing picture
    if (widget.user?.profilePicture != null &&
        widget.user!.profilePicture!.isNotEmpty) {
      try {
        _imageBytes = base64Decode(widget.user!.profilePicture!);
        _base64Image = widget.user!.profilePicture;
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _numberController.dispose();
    _userCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 512,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _base64Image = base64Encode(bytes);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
    if (mounted) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context); // close bottom sheet
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose how to add a photo',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 20),
              _sheetOption(
                icon: Icons.camera_alt_rounded,
                label: 'Take Photo',
                color: const Color(0xFF2196F3),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(height: 12),
              _sheetOption(
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                color: const Color(0xFFD4AF37),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              if (_imageBytes != null) ...[
                const SizedBox(height: 12),
                _sheetOption(
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove Photo',
                  color: const Color(0xFFEF5350),
                  onTap: () {
                    setState(() {
                      _imageBytes = null;
                      _base64Image = null;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;
    final avatarBg = (_selectedUserTypeId == 1)
        ? const Color(0xFFD4AF37)
        : const Color(0xFF2E7D32);

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 20 : 40,
      ),
      child: Container(
        width: isMobile ? double.infinity : 500,
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height * (isMobile ? 0.9 : 0.85),
          maxWidth: isMobile ? screenWidth - 32 : 500,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 24,
                  isMobile ? 16 : 24,
                  isMobile ? 8 : 16,
                  isMobile ? 16 : 24,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isEdit ? Icons.edit_rounded : Icons.person_add_rounded,
                      color: const Color(0xFFD4AF37),
                      size: isMobile ? 20 : 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isEdit ? 'Edit User' : 'Add New User',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF212121),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // ── Body ────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 16 : 24,
                    isMobile ? 16 : 20,
                    isMobile ? 16 : 24,
                    isMobile ? 12 : 16,
                  ),
                  child: Column(
                    children: [
                      // Profile photo picker
                      Center(
                        child: GestureDetector(
                          onTap: _showImagePickerSheet,
                          child: Stack(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: _imageBytes != null
                                      ? Colors.transparent
                                      : avatarBg,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.12,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  image: _imageBytes != null
                                      ? DecorationImage(
                                          image: MemoryImage(_imageBytes!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _imageBytes == null
                                    ? Center(
                                        child: Text(
                                          isEdit
                                              ? widget.user?.initials ?? '?'
                                              : '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD4AF37),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to change photo',
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 20),

                      // ── Personal Info ────
                      _sectionLabel(
                        'Personal Information',
                        Icons.badge_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        'First Name',
                        _firstNameController,
                        Icons.person_outline,
                        required: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter First Name';
                          }
                          if (!RegExp(
                            r'^[a-zA-Z\s]+$',
                          ).hasMatch(value.trim())) {
                            return 'First name must contain letters only';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        'Middle Name',
                        _middleNameController,
                        Icons.person_outline,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (!RegExp(
                              r'^[a-zA-Z\s]+$',
                            ).hasMatch(value.trim())) {
                              return 'Middle name must contain letters only';
                            }
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        'Last Name',
                        _lastNameController,
                        Icons.person_outline,
                        required: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter Last Name';
                          }
                          if (!RegExp(
                            r'^[a-zA-Z\s]+$',
                          ).hasMatch(value.trim())) {
                            return 'Last name must contain letters only';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 8),
                      _sectionLabel(
                        'Contact Information',
                        Icons.contact_mail_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        'Email',
                        _emailController,
                        Icons.email_outlined,
                        required: true,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter Email';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value.trim())) {
                            return 'The email must be a valid email address';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        'Phone Number',
                        _numberController,
                        Icons.phone,
                        required: true,
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Phone Number';
                          }
                          if (value.length != 11) {
                            return 'Phone number must be exactly 11 digits';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Phone number must contain only digits';
                          }
                          return null;
                        },
                      ),

                      // Status (edit mode only)
                      if (isEdit) ...[
                        _buildDropdownField<int>(
                          label: 'Status',
                          icon: Icons.toggle_on_outlined,
                          value: _selectedStatusId,
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('Active')),
                            DropdownMenuItem(value: 2, child: Text('Inactive')),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedStatusId = v ?? 1),
                        ),
                      ],

                      const SizedBox(height: 8),
                      _sectionLabel(
                        'Account Information',
                        Icons.shield_outlined,
                      ),
                      const SizedBox(height: 12),

                      // User Type
                      _buildDropdownField<int>(
                        label: 'User Type',
                        icon: Icons.admin_panel_settings_outlined,
                        value: _selectedUserTypeId,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Admin')),
                          DropdownMenuItem(value: 2, child: Text('Local')),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedUserTypeId = v),
                        validator: (v) =>
                            v == null ? 'Please select user type' : null,
                      ),

                      _buildTextField(
                        'User Code',
                        _userCodeController,
                        Icons.qr_code,
                        required: true,
                      ),

                      // Password
                      _buildPasswordField(isEdit),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // ── Footer buttons ───────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _saveUser,
                        icon: const Icon(Icons.save_rounded, size: 18),
                        label: Text(isEdit ? 'SAVE CHANGES' : 'CREATE USER'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFFD4AF37)),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 1.5, color: Colors.grey[200])),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool required = false,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF424242),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLength: maxLength,
            style: const TextStyle(fontSize: 13, color: Color(0xFF212121)),
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
              prefixIcon: Container(
                width: 44,
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: Colors.grey[500]),
              ),
              filled: true,
              fillColor: const Color(0xFFF8F8F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFD4AF37),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.only(
                left: 0,
                right: 12,
                top: 12,
                bottom: 12,
              ),
              counterText: maxLength != null ? '' : null,
              isDense: true,
            ),
            validator:
                validator ??
                (required
                    ? (value) => (value == null || value.isEmpty)
                          ? 'Please enter $label'
                          : null
                    : null),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF424242),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownButtonFormField<T>(
            initialValue: value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF212121)),
            decoration: InputDecoration(
              hintText: 'Select $label',
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
              prefixIcon: Container(
                width: 44,
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: Colors.grey[500]),
              ),
              filled: true,
              fillColor: const Color(0xFFF8F8F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFD4AF37),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.only(
                left: 0,
                right: 12,
                top: 12,
                bottom: 12,
              ),
              isDense: true,
            ),
            items: items,
            onChanged: onChanged,
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(bool isEdit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              isEdit ? 'Password (leave blank to keep)' : 'Password',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF424242),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(fontSize: 13, color: Color(0xFF212121)),
            decoration: InputDecoration(
              hintText: 'Enter password',
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
              prefixIcon: Container(
                width: 44,
                alignment: Alignment.center,
                child: Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: Colors.grey[500],
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: Colors.grey[500],
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              filled: true,
              fillColor: const Color(0xFFF8F8F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFD4AF37),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.only(
                left: 0,
                right: 12,
                top: 12,
                bottom: 12,
              ),
              isDense: true,
            ),
            validator: (value) {
              if (!isEdit && (value == null || value.isEmpty)) {
                return 'Please enter password';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  void _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.user != null;
    final enteredUserCode = _userCodeController.text.trim();

    // Check for duplicate user code
    final isDuplicate = widget.existingUsers.any((user) {
      // If editing, exclude the current user from the check
      if (isEdit && user.userId == widget.user!.userId) {
        return false;
      }
      return user.userCode?.toLowerCase() == enteredUserCode.toLowerCase();
    });

    if (isDuplicate) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.red[700], size: 28),
              const SizedBox(width: 12),
              const Text(
                'Duplicate User Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: const Text(
            'User code already exists, please try another',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
      return;
    }

    if (isEdit) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Confirm Update',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Update user: ${_userCodeController.text}?',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'CONFIRM',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final userData = <String, dynamic>{
      'firstName': _firstNameController.text,
      'middleName': _middleNameController.text.isEmpty
          ? null
          : _middleNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'number': _numberController.text,
      'userCode': _userCodeController.text,
      'statusId': _selectedStatusId,
      'userTypeId': _selectedUserTypeId,
      'createUserId': UserSession().userId?.toString() ?? 'SYSTEM',
      'profilePicture':
          _base64Image ?? '', // Send empty string if null (photo removed)
    };

    if (isEdit) {
      userData['updateUserId'] = UserSession().userId?.toString() ?? 'SYSTEM';
    }

    if (!isEdit || _passwordController.text.isNotEmpty) {
      userData['password'] = _passwordController.text;
    }

    debugPrint('UserFormDialog: Saving user');
    widget.onSave(userData);
    if (mounted) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }
}
