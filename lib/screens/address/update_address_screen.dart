import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shop/models/user_model.dart';
import 'package:shop/services/users/address_service.dart';

class EditAddressScreen extends StatefulWidget {
  const EditAddressScreen({super.key});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _wardController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();

  bool _isDefault = false;
  bool _isLoading = false;
  bool _isDeleting = false;

  UserAddress? _currentAddress;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_currentAddress == null) {
      _currentAddress = ModalRoute.of(context)!.settings.arguments as UserAddress;
      _loadAddressData();
    }
  }

  void _loadAddressData() {
    if (_currentAddress != null) {
      _fullNameController.text = _currentAddress!.fullName;
      _phoneController.text = _currentAddress!.phone;
      _addressLineController.text = _currentAddress!.addressLine;
      _wardController.text = _currentAddress!.ward;
      _districtController.text = _currentAddress!.district;
      _cityController.text = _currentAddress!.city;
      _isDefault = _currentAddress!.isDefault;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLineController.dispose();
    _wardController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _updateAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userIdStr = await _storage.read(key: 'user_id');
      if (userIdStr == null) throw Exception("User not logged in");
      final userId = int.parse(userIdStr);

      final updatedAddress = UserAddress(
        id: _currentAddress!.id,
        userId: userId,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        addressLine: _addressLineController.text.trim(),
        ward: _wardController.text.trim(),
        district: _districtController.text.trim(),
        city: _cityController.text.trim(),
        isDefault: _isDefault,
      );

      await AddressService.updateAddress(address: updatedAddress);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Địa chỉ đã được cập nhật thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAddress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Xóa địa chỉ',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa địa chỉ này không?',
          style: GoogleFonts.roboto(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy', style: GoogleFonts.roboto(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Xóa', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      final addressId = _currentAddress?.id;
      if (addressId == null) throw Exception("Address ID not found");

      await AddressService.deleteAddress(addressId: addressId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Địa chỉ đã được xóa thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3142),
            )),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.roboto(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.roboto(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 22),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chỉnh Sửa Địa Chỉ',
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                  )
                : const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _isDeleting ? null : _deleteAddress,
            tooltip: 'Xóa địa chỉ',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Information Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, color: Colors.amber.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Cập nhật thông tin địa chỉ của bạn',
                              style: GoogleFonts.roboto(
                                color: Colors.amber.shade900,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Họ và tên',
                      hint: 'Nhập họ và tên người nhận',
                      icon: Icons.person_outline,
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Vui lòng nhập họ và tên'
                          : null,
                    ),

                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _phoneController,
                      label: 'Số điện thoại',
                      hint: 'Nhập số điện thoại',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'Vui lòng nhập số điện thoại';
                        if (value.trim().length < 10) return 'Số điện thoại không hợp lệ';
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _addressLineController,
                      label: 'Địa chỉ cụ thể',
                      hint: 'Số nhà, tên đường...',
                      icon: Icons.home_outlined,
                      maxLines: 2,
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Vui lòng nhập địa chỉ cụ thể'
                          : null,
                    ),

                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _wardController,
                      label: 'Phường/Xã',
                      hint: 'Nhập phường/xã',
                      icon: Icons.location_city_outlined,
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Vui lòng nhập phường/xã'
                          : null,
                    ),

                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _districtController,
                      label: 'Quận/Huyện',
                      hint: 'Nhập quận/huyện',
                      icon: Icons.location_on_outlined,
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Vui lòng nhập quận/huyện'
                          : null,
                    ),

                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _cityController,
                      label: 'Tỉnh/Thành phố',
                      hint: 'Nhập tỉnh/thành phố',
                      icon: Icons.map_outlined,
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Vui lòng nhập tỉnh/thành phố'
                          : null,
                    ),

                    const SizedBox(height: 24),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CheckboxListTile(
                        title: Text(
                          'Đặt làm địa chỉ mặc định',
                          style: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'Địa chỉ này sẽ được sử dụng mặc định khi đặt hàng',
                          style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        value: _isDefault,
                        onChanged: (value) => setState(() => _isDefault = value ?? false),
                        activeColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, -2)),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            'Cập Nhật Địa Chỉ',
                            style: GoogleFonts.roboto(
                                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
