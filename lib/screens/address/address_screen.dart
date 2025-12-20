import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shop/models/user_model.dart';
import 'package:shop/routes/route_constants.dart';
import 'package:shop/services/users/address_service.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  late Future<List<UserAddress>> _addressesFuture;
  List<UserAddress> _addresses = [];

  int? _selectedIndex;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _addressesFuture = _loadAddressesFuture();
  }

  Future<List<UserAddress>> _loadAddressesFuture() async {
    final userIdStr = await _storage.read(key: 'user_id');
    if (userIdStr == null) {
      throw Exception("User not logged in");
    }

    final userId = int.parse(userIdStr);
    final addresses = await AddressService.getAddressesByUserId(userId: userId);

    _addresses = addresses;

    final defaultIndex = addresses.indexWhere((a) => a.isDefault);
    if (defaultIndex != -1) {
      _selectedIndex = defaultIndex;
    }

    return addresses;
  }

  Future<void> _onSelectAddress(int index, UserAddress address) async {
    if (_isUpdating) return;
    _isUpdating = true;

    final previousIndex = _selectedIndex;
    final previousAddresses = List<UserAddress>.from(_addresses);

    // Update UI trước (optimistic update)
    setState(() {
      _selectedIndex = index;
      _addresses = _addresses.map((a) {
        return a.id == address.id ? a.copyWith(isDefault: true) : a.copyWith(isDefault: false);
      }).toList();
    });

    try {
      await AddressService.updateAddress(
        address: address.copyWith(isDefault: true),
      );
    } catch (e) {
      // Rollback nếu API lỗi
      setState(() {
        _selectedIndex = previousIndex;
        _addresses = previousAddresses;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể chọn địa chỉ này")),
      );
    } finally {
      _isUpdating = false;
    }
  }

  void _onAddAddress() {
    Navigator.pushNamed(context, addAddressScreenRoute).then((_) {
      setState(() {
        _addressesFuture = _loadAddressesFuture();
      });
    });
  }

  void _onEditAddress(UserAddress address) {
    Navigator.pushNamed(
      context,
      editAddressScreenRoute,
      arguments: address,
    ).then((_) {
      setState(() {
        _addressesFuture = _loadAddressesFuture();
      });
    });
  }

  Widget _buildAddressCard(UserAddress address, int index) {
    final bool isSelected = _selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.blue.shade400 : Colors.grey.shade200,
          width: isSelected ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onSelectAddress(index, address),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Radio
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey.shade400,
                          width: 2,
                        ),
                        color: isSelected ? Colors.blue : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),

                    // Name + default badge
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              address.fullName,
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (address.isDefault) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade400,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "Mặc định",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Edit
                    InkWell(
                      onTap: () => _onEditAddress(address),
                      child: const Icon(Icons.edit_outlined, color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(address.phone),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${address.addressLine}\n'
                        '${address.ward}, ${address.district}, ${address.city}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Address"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<UserAddress>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final addresses = snapshot.data ?? [];

          return Column(
            children: [
              GestureDetector(
                onTap: _onAddAddress,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.location_on_outlined),
                      SizedBox(width: 8),
                      Text("Add new address"),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: addresses.isEmpty
                    ? const Center(child: Text("Chưa có địa chỉ nào"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: addresses.length,
                        itemBuilder: (_, index) => _buildAddressCard(addresses[index], index),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
