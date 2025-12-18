import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shop/models/user_model.dart';
import 'package:shop/services/users/address_service.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _wardController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();

  bool _isDefault = false;
  bool _isLoading = false;

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

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userIdStr = await _storage.read(key: 'user_id');
      if (userIdStr == null) throw Exception("User not logged in");

      final newAddress = UserAddress(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        addressLine: _addressLineController.text.trim(),
        ward: _wardController.text.trim(),
        district: _districtController.text.trim(),
        city: _cityController.text.trim(),
        isDefault: _isDefault,
      );

      await AddressService.addAddress(newAddress);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Địa chỉ đã được thêm thành công!',
              style: GoogleFonts.roboto(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi: ${e.toString()}',
              style: GoogleFonts.roboto(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.roboto(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
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
          'Thêm Địa Chỉ Mới',
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
                    // Info box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Vui lòng điền đầy đủ thông tin để giao hàng chính xác',
                              style: GoogleFonts.roboto(
                                color: Colors.blue.shade700,
                                fontSize: 13,
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Vui lòng nhập họ và tên';
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'Vui lòng nhập địa chỉ cụ thể';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _wardController,
                      label: 'Phường/Xã',
                      hint: 'Nhập phường/xã',
                      icon: Icons.location_city_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Vui lòng nhập phường/xã';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _districtController,
                      label: 'Quận/Huyện',
                      hint: 'Nhập quận/huyện',
                      icon: Icons.location_on_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'Vui lòng nhập quận/huyện';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _cityController,
                      label: 'Tỉnh/Thành phố',
                      hint: 'Nhập tỉnh/thành phố',
                      icon: Icons.map_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'Vui lòng nhập tỉnh/thành phố';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Default checkbox
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CheckboxListTile(
                        title: Text(
                          'Đặt làm địa chỉ mặc định',
                          style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Địa chỉ này sẽ được sử dụng mặc định khi đặt hàng',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        value: _isDefault,
                        onChanged: (value) {
                          setState(() => _isDefault = value ?? false);
                        },
                        activeColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            // Save Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Lưu Địa Chỉ',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
