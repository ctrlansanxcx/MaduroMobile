import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:maduro/history/history_widget.dart';
import 'package:maduro/widgets/bottom_navbar.dart';

/// Only keep timestamp sort, remove fruit/ripeness ordering
enum SortOption {
  timestamp,
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  String? _selectedRipeness; // ✅ New: filter
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamed(context, '/detectionLandingPage');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/history');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  Future<void> _deleteHistoryItem(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('history')
          .doc(documentId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('History item deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete history item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        bottomNavigationBar: BottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
        body: const Center(
          child: Text("User not logged in."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildModernAppBar(title: 'HISTORY'),
      body: Column(
        children: [
          _buildRipenessFilter(), // ✅ Replaces sort controls
          Expanded(child: _buildHistoryList(userId)),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  /// App bar
  PreferredSize _buildModernAppBar({required String title}) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100.0),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB5DB49),
              Color(0xFFEAD938),
              Color(0xFFF5EE62),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.8,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ Modern white styled dropdown with visual feedback
  Widget _buildRipenessFilter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedRipeness,
        decoration: const InputDecoration(
          labelText: "Filter by Ripeness",
          labelStyle: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 4, // subtle shadow when dropdown is open
        items: const [
          DropdownMenuItem(value: null, child: Text("All")),
          DropdownMenuItem(value: "Ripe", child: Text("Ripe")),
          DropdownMenuItem(value: "Unripe", child: Text("Unripe")),
          DropdownMenuItem(value: "Rotten", child: Text("Rotten")),
        ],
        onChanged: (value) {
          setState(() {
            _selectedRipeness = value;
          });
        },
      ),
    );
  }

  /// Build list with ripeness filter + date/time sort
  Widget _buildHistoryList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('history')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true) // ✅ Always latest → oldest
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        // ✅ Apply ripeness filter
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final ripeness = data['detectedRipeness'] ??
              data['ripenessLabel'] ??
              data['calculatedRipenessLabel'] ??
              'Unknown';

          if (_selectedRipeness == null) return true;
          return ripeness.toString().toLowerCase() ==
              _selectedRipeness!.toLowerCase();
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(
            child: Text("No history found for this filter."),
          );
        }

        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final data = filteredDocs[index].data() as Map<String, dynamic>;
            return HistoryTile(
              data: data,
              onDelete: () => _deleteHistoryItem(filteredDocs[index].id),
            );
          },
        );
      },
    );
  }
}
