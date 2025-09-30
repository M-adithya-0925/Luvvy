import 'package:flutter/material.dart';
import 'package:luvvy/ImageUpload.dart';
import 'services/FirebaseService.dart';

class InterestsSelectionScreen extends StatefulWidget {
  final Map<String, dynamic>? preferences;

  const InterestsSelectionScreen({super.key, this.preferences});

  @override
  _InterestsSelectionScreenState createState() => _InterestsSelectionScreenState();
}

class _InterestsSelectionScreenState extends State<InterestsSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> selectedInterests = [];
  String selectedCategory = 'All';
  bool _isLoading = false;

  final int maxSelections = 8;

  // Simplified interests
  final Map<String, List<Interest>> categorizedInterests = {
    'Lifestyle': [
      Interest('Yoga', '🧘‍♀️'), Interest('Fitness', '💪'), Interest('Running', '🏃‍♀️'),
      Interest('Cycling', '🚴‍♂️'), Interest('Swimming', '🏊‍♀️'), Interest('Gym', '🏋️‍♂️'),
    ],

    'Food': [
      Interest('Cooking', '👩‍🍳'), Interest('Coffee', '☕'), Interest('Wine', '🍷'),
      Interest('Vegan', '🌱'), Interest('Foodie', '🍽️'), Interest('Baking', '🍰'),
    ],

    'Adventure': [
      Interest('Hiking', '🥾'), Interest('Surfing', '🏄‍♂️'), Interest('Skiing', '⛷️'),
      Interest('Camping', '🏕️'), Interest('Rock Climbing', '🧗‍♂️'), Interest('Backpacking', '🎒'),
    ],

    'Arts': [
      Interest('Photography', '📸'), Interest('Art', '🎨'), Interest('Music', '🎵'),
      Interest('Dancing', '💃'), Interest('Theater', '🎭'), Interest('Writing', '✍️'),
    ],

    'Entertainment': [
      Interest('Movies', '🎬'), Interest('Gaming', '🎮'), Interest('Reading', '📚'),
      Interest('Netflix', '📺'), Interest('Podcasts', '🎙️'), Interest('Comedy', '😂'),
    ],

    'Travel': [
      Interest('Travel', '✈️'), Interest('Beach', '🏖️'), Interest('Mountains', '🏔️'),
      Interest('Road Trips', '🚗'), Interest('Solo Travel', '🚶‍♀️'), Interest('City Breaks', '🏙️'),
    ],

    'Social': [
      Interest('Volunteering', '🤝'), Interest('Parties', '🥳'), Interest('Meetups', '👫'),
      Interest('Networking', '👥'), Interest('Dancing', '💃'), Interest('Social Events', '🎉'),
    ],
  };

  List<String> get categories => ['All'] + categorizedInterests.keys.toList();

  List<Interest> get filteredInterests {
    List<Interest> interests = [];

    if (selectedCategory == 'All') {
      interests = categorizedInterests.values.expand((list) => list).toList();
    } else {
      interests = categorizedInterests[selectedCategory] ?? [];
    }

    if (_searchController.text.isEmpty) return interests;

    return interests.where((interest) =>
        interest.name.toLowerCase().contains(_searchController.text.toLowerCase())
    ).toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.preferences != null) {
      _autoSelectPreferences(widget.preferences!);
    }
  }

  void _autoSelectPreferences(Map<String, dynamic> preferences) {
    print("🤖 AI suggested preferences: $preferences");

    for (final category in preferences.keys) {
      final items = preferences[category];
      if (items is List) {
        for (final item in items) {
          if (item is String) {
            final itemLower = item.toLowerCase().trim();

            // Direct and partial matches
            for (final interest in categorizedInterests.values.expand((list) => list)) {
              if ((interest.name.toLowerCase() == itemLower ||
                  interest.name.toLowerCase().contains(itemLower)) &&
                  !selectedInterests.contains(interest.name) &&
                  selectedInterests.length < maxSelections) {
                selectedInterests.add(interest.name);
                break;
              }
            }
          }
        }
      }
    }

    print("✅ Auto-selected ${selectedInterests.length} interests: $selectedInterests");
    setState(() {});
  }

  void _toggleInterest(String interestName) {
    setState(() {
      if (selectedInterests.contains(interestName)) {
        selectedInterests.remove(interestName);
      } else if (selectedInterests.length < maxSelections) {
        selectedInterests.add(interestName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Maximum $maxSelections interests allowed"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  Future<void> _continueToNext() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseService().updateUserInterests(selectedInterests);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PhotoUploadScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Back button and progress
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                      ),
                      Expanded(
                        child: Container(
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey[200],
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.98,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Your interests',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (selectedInterests.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            '${selectedInterests.length}/$maxSelections',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Select up to $maxSelections interests. We\'ve pre-selected some based on your story!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search interests...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ],
              ),
            ),

            // Category tabs
            Container(
              color: Colors.white,
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == selectedCategory;

                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF8B5CF6),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Interests list
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredInterests.length,
                  itemBuilder: (context, index) {
                    final interest = filteredInterests[index];
                    final isSelected = selectedInterests.contains(interest.name);

                    return InkWell(
                      onTap: () => _toggleInterest(interest.name),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey.shade300,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Text(interest.emoji, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                interest.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Continue button
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: selectedInterests.length >= 3 && !_isLoading
                        ? _continueToNext
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : Text(
                      selectedInterests.length >= 3
                          ? "Continue (${selectedInterests.length} selected)"
                          : "Select at least 3 interests",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class Interest {
  final String name;
  final String emoji;

  Interest(this.name, this.emoji);
}
