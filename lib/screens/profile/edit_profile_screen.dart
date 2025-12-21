import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shop/services/profile/profile_service.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  late final ProfileService profileService;

  String name = '';
  String bio = '';
  String gender = '';
  String birthday = '';
  String personalInfo = '';
  String phone = '';
  String email = '';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    profileService = ProfileService(storage: storage);
    _loadProfile();
  }

  /// ================= LOAD PROFILE =================
  Future<void> _loadProfile() async {
    try {
      final profile = await profileService.getProfile();
      if (profile != null) {
        setState(() {
          name = profile['name'] ?? '';
          bio = profile['bio'] ?? '';
          gender = profile['gender'] ?? '';
          birthday = profile['birthday'] ?? '';
          personalInfo = profile['personal_info'] ?? '';
          phone = profile['phone'] ?? '';
          email = profile['email'] ?? '';
        });
      }
    } catch (_) {
      // fallback cache
      final cached = await profileService.getCachedProfile();
      if (cached != null) {
        setState(() {
          name = cached['name'] ?? '';
          bio = cached['bio'] ?? '';
          gender = cached['gender'] ?? '';
          birthday = cached['birthday'] ?? '';
          personalInfo = cached['personal_info'] ?? '';
          phone = cached['phone'] ?? '';
          email = cached['email'] ?? '';
        });
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ================= UPDATE PROFILE =================
  Future<void> _updateProfile() async {
    try {
      final result = await profileService.updateProfile(
        name: name,
        bio: bio,
        gender: gender,
        birthday: birthday.isNotEmpty ? DateFormat('dd/MM/yyyy').parse(birthday) : null,
        personalInfo: personalInfo,
        phone: phone,
        email: email,
      );

      if (result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// ================= EDIT BIO DIALOG =================
  void _showEditBioDialog() {
    final controller = TextEditingController(text: bio);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tiểu sử', style: GoogleFonts.roboto()),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Nhập tiểu sử của bạn',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.roboto()),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => bio = controller.text);
              Navigator.pop(context);
              _updateProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            child: Text('Cập nhật', style: GoogleFonts.roboto(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// ================= EDIT GENDER DIALOG =================
  void _showEditGenderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Giới tính', style: GoogleFonts.roboto()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGenderOption('Nam'),
            _buildGenderOption('Nữ'),
            _buildGenderOption('Bê Đê'),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(String value) {
    return ListTile(
      title: Text(value, style: GoogleFonts.roboto()),
      trailing: gender == value ? const Icon(Icons.check, color: Colors.deepPurple) : null,
      onTap: () {
        setState(() => gender = value);
        Navigator.pop(context);
        _updateProfile();
      },
    );
  }

  /// ================= EDIT BIRTHDAY DIALOG =================
  Future<void> _showEditBirthdayDialog() async {
    DateTime initialDate = DateTime.now();
    if (birthday.isNotEmpty) {
      try {
        initialDate = DateFormat('dd/MM/yyyy').parse(birthday);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        birthday = DateFormat('dd/MM/yyyy').format(picked);
      });
      _updateProfile();
    }
  }

  /// ================= EDIT EMAIL DIALOG =================
  void _showEditEmailDialog() {
    final controller = TextEditingController(text: email);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Email', style: GoogleFonts.roboto()),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Nhập email của bạn',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.roboto()),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => email = controller.text);
              Navigator.pop(context);
              _updateProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            child: Text('Cập nhật', style: GoogleFonts.roboto(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// ================= EDIT NAME DIALOG =================
  void _showEditNameDialog() {
    final controller = TextEditingController(text: name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tên', style: GoogleFonts.roboto()),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Nhập tên của bạn',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.roboto()),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => name = controller.text);
              Navigator.pop(context);
              _updateProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            child: Text('Cập nhật', style: GoogleFonts.roboto(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// ================= EDIT PERSONAL INFO DIALOG =================
  void _showEditPersonalInfoDialog() {
    final controller = TextEditingController(text: personalInfo);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thông tin cá nhân', style: GoogleFonts.roboto()),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Nhập thông tin cá nhân',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.roboto()),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => personalInfo = controller.text);
              Navigator.pop(context);
              _updateProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            child: Text('Cập nhật', style: GoogleFonts.roboto(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// ================= EDIT PHONE DIALOG =================
  void _showEditPhoneDialog() {
    final controller = TextEditingController(text: phone);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Số điện thoại', style: GoogleFonts.roboto()),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Nhập số điện thoại',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.roboto()),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => phone = controller.text);
              Navigator.pop(context);
              _updateProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            child: Text('Cập nhật', style: GoogleFonts.roboto(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// ================= AVATAR =================
  Widget _buildAvatar({required String name, double size = 80}) {
    String initials = 'U';
    if (name.isNotEmpty) {
      final parts = name.trim().split(' ');
      initials = parts.length >= 2
          ? parts.first[0].toUpperCase() + parts.last[0].toUpperCase()
          : parts.first[0].toUpperCase();
    }

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.deepPurple,
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.poppins(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
            color: Colors.orange,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Sửa hồ sơ',
          style: GoogleFonts.roboto(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: ListView(
        children: [
          /// ================= AVATAR =================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Stack(
                  children: [
                    _buildAvatar(name: name, size: 80),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          _buildProfileItem(
            label: 'Tên',
            value: name,
            onTap: _showEditNameDialog,
          ),
          _buildProfileItem(
            label: 'Tiểu sử',
            value: bio.isEmpty ? 'Thiết lập ngay' : bio,
            valueColor: bio.isEmpty ? const Color(0xFFE85D4D) : null,
            onTap: _showEditBioDialog,
          ),
          _buildProfileItem(
            label: 'Giới tính',
            value: gender.isEmpty ? 'Thiết lập ngay' : gender,
            valueColor: gender.isEmpty ? const Color(0xFFE85D4D) : null,
            hasInfo: true,
            onTap: _showEditGenderDialog,
          ),
          _buildProfileItem(
            label: 'Ngày sinh',
            value: birthday.isEmpty ? 'Thiết lập ngay' : birthday,
            hasInfo: true,
            onTap: _showEditBirthdayDialog,
          ),
          _buildProfileItem(
            label: 'Thông tin cá nhân',
            value: personalInfo.isEmpty ? 'Thiết lập ngay' : personalInfo,
            valueColor: personalInfo.isEmpty ? const Color(0xFFE85D4D) : null,
            hasInfo: true,
            onTap: _showEditPersonalInfoDialog,
          ),

          const SizedBox(height: 8),

          _buildProfileItem(
            label: 'Số điện thoại',
            value: phone,
            onTap: _showEditPhoneDialog,
          ),
          _buildProfileItem(
            label: 'Email',
            value: email.isEmpty ? 'Thiết lập ngay' : email,
            valueColor: email.isEmpty ? const Color(0xFFE85D4D) : null,
            onTap: _showEditEmailDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem({
    required String label,
    required String value,
    Color? valueColor,
    bool hasInfo = false,
    required VoidCallback onTap,
  }) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Row(
              children: [
                Text(label, style: GoogleFonts.roboto(fontSize: 15)),
                if (hasInfo) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.info_outline, size: 16, color: Colors.grey.shade500),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: valueColor ?? Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
        ],
      ),
    );
  }
}
