import 'package:flutter/material.dart';
import 'package:luvvy/ImageUpload.dart';

class InterestsSelectionScreen extends StatefulWidget {
  @override
  _InterestsSelectionScreenState createState() => _InterestsSelectionScreenState();
}

class _InterestsSelectionScreenState extends State<InterestsSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> selectedInterests = [];
  
  final List<Interest> interests = [
    Interest('Travel', '✈️'),
    Interest('Cooking', '🍳'),
    Interest('Hiking', '🏔️'),
    Interest('Yoga', '🧘'),
    Interest('Gaming', '🎮'),
    Interest('Movies', '🎬'),
    Interest('Photography', '📷'),
    Interest('Music', '🎵'),
    Interest('Pets', '🐱'),
    Interest('Painting', '🎨'),
    Interest('Art', '🎭'),
    Interest('Fitness', '💪'),
    Interest('Reading', '📚'),
    Interest('Dancing', '💃'),
    Interest('Sports', '🏀'),
    Interest('Board Games', '🎲'),
    Interest('Technology', '💻'),
    Interest('Fashion', '👗'),
    Interest('Motorcycling', '🏍️'),
  ];

  List<Interest> get filteredInterests {
    if (_searchController.text.isEmpty) {
      return interests;
    }
    return interests.where((interest) =>
      interest.name.toLowerCase().contains(_searchController.text.toLowerCase())
    ).toList();
  }

  void toggleInterest(String interestName) {
    setState(() {
      if (selectedInterests.contains(interestName)) {
        selectedInterests.remove(interestName);
      } else {
        if (selectedInterests.length < 5) {
          selectedInterests.add(interestName);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button and progress bar
              SizedBox(height: 20),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey[200],
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.9,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF8B5CF6),
                                Color(0xFFA855F7),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 40),
              
              // Title with emoji
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Discover like-minded people',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    '🤗',
                    style: TextStyle(fontSize: 28),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              // Description text
              Text(
                'Share your interests, passions, and hobbies. We\'ll connect you with people who share your enthusiasm.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 30),
              
              // Search bar
              // Container(
              //   decoration: BoxDecoration(
              //     color: Colors.grey[100],
              //     borderRadius: BorderRadius.circular(25),
              //   ),
              //   child: TextField(
              //     controller: _searchController,
              //     onChanged: (value) => setState(() {}),
              //     decoration: InputDecoration(
              //       hintText: 'Search interest',
              //       hintStyle: TextStyle(
              //         color: Colors.grey[500],
              //         fontSize: 16,
              //       ),
              //       prefixIcon: Icon(
              //         Icons.search,
              //         color: Colors.grey[500],
              //         size: 20,
              //       ),
              //       border: InputBorder.none,
              //       contentPadding: EdgeInsets.symmetric(
              //         horizontal: 20,
              //         vertical: 15,
              //       ),
              //     ),
              //   ),
              // ),
              
              SizedBox(height: 30),
              
              // Interests grid
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: filteredInterests.map((interest) {
                      bool isSelected = selectedInterests.contains(interest.name);
                      return GestureDetector(
                        onTap: () => toggleInterest(interest.name),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Color(0xFF8B5CF6) : Colors.white,
                            border: Border.all(
                              color: isSelected ? Color(0xFF8B5CF6) : Colors.grey[300]!,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                interest.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                interest.emoji,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Continue button
              Container(
                width: double.infinity,
                height: 56,
                margin: EdgeInsets.only(bottom: 40),
                child: ElevatedButton(
                  onPressed: selectedInterests.isNotEmpty ? () {
                    print('Selected interests: $selectedInterests');
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>PhotoUploadScreen(),));
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B5CF6),
                    disabledBackgroundColor: Colors.grey[300],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Continue (${selectedInterests.length}/5)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: selectedInterests.isNotEmpty ? Colors.white : Colors.grey[500],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Interest {
  final String name;
  final String emoji;

  Interest(this.name, this.emoji);
}

// Usage example - add this to your main app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dating App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'SF Pro Display',
      ),
      home: InterestsSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() {
  runApp(MyApp());
}