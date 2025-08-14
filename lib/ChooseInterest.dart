import 'package:flutter/material.dart';
import 'package:luvvy/ImageUpload.dart';
import 'services/FirebaseService.dart';

class InterestsSelectionScreen extends StatefulWidget {
  final Map<String, dynamic>? preferences;

  InterestsSelectionScreen({this.preferences});

  @override
  _InterestsSelectionScreenState createState() =>
      _InterestsSelectionScreenState();
}

class _InterestsSelectionScreenState extends State<InterestsSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> selectedInterests = [];

  final List<Interest> interests = [
    // Interests
    Interest('Yoga', '🧘'),
    Interest('Cooking', '🍳'),
    Interest('Hiking', '🥾'),
    Interest('Photography', '📷'),
    Interest('Astrology', '🔮'),
    Interest('Spirituality', '🕉️'),
    Interest('Dancing', '💃'),
    Interest('Reading', '📚'),
    Interest('Surfing', '🏄‍♂️'),
    Interest('Minimalism', '🌱'),
    Interest('Fashion', '👗'),
    Interest('Nature', '🌿'),
    Interest('Writing', '✍️'),
    Interest('Volunteering', '🤝'),
    Interest('Gardening', '🌼'),
    Interest('Camping', '🏕️'),
    Interest('Skating', '🛼'),
    Interest('Binge-Watching', '📺'),
    Interest('Travel', '✈️'),
    Interest('Meditation', '🧘‍♂️'),
    Interest('Fitness', '💪'),
    Interest('Blogging', '📝'),
    Interest('Workout', '🏋️'),
    Interest('Board Games', '🎲'),
    Interest('Entrepreneurship', '🚀'),
    Interest('Journaling', '📓'),

    // Languages
    Interest('English', '🇬🇧'),
    Interest('Hindi', '🇮🇳'),
    Interest('Tamil', '🇮🇳'),
    Interest('Telugu', '🇮🇳'),
    Interest('Malayalam', '🇮🇳'),
    Interest('Kannada', '🇮🇳'),
    Interest('Marathi', '🇮🇳'),
    Interest('French', '🇫🇷'),
    Interest('German', '🇩🇪'),
    Interest('Spanish', '🇪🇸'),
    Interest('Korean', '🇰🇷'),
    Interest('Japanese', '🇯🇵'),

    // Relationship Goals
    Interest('Dating', '💑'),
    Interest('Friendship', '👫'),
    Interest('Casual', '😎'),
    Interest('Serious Relationship', '❤️'),
    Interest('Exploration', '🌍'),

    // Religion
    Interest('Hinduism', '🛕'),
    Interest('Islam', '🕌'),
    Interest('Christianity', '⛪'),
    Interest('Buddhism', '☸️'),
    Interest('Atheist', '❌'),
    Interest('Spiritual', '✨'),

    // Music
    Interest('Rock', '🎸'),
    Interest('Indie', '🎶'),
    Interest('Pop', '🎤'),
    Interest('Jazz', '🎷'),
    Interest('Classical', '🎻'),
    Interest('Hip-Hop', '🎧'),
    Interest('K-pop', '🎵'),

    // Movies
    Interest('Action', '🔫'),
    Interest('Romantic', '💕'),
    Interest('Thriller', '😱'),
    Interest('Comedy', '😂'),
    Interest('Historical', '🏛️'),
    Interest('Sci-fi', '🛸'),
    Interest('Fantasy', '🧙'),

    // Books
    Interest('Romance', '💌'),
    Interest('Mystery', '🕵️'),
    Interest('Fantasy', '🐉'),
    Interest('Biography', '📖'),
    Interest('Science Fiction', '🚀'),
    Interest('Spirituality', '📿'),
    Interest('Motivational', '📈'),

    // Travel
    Interest('Solo Travel', '🚶‍♀️'),
    Interest('Road Trips', '🚗'),
    Interest('Beach Travel', '🏖️'),
    Interest('Cultural Exploration', '🎭'),
    Interest('Trekking', '⛰️'),

    // Diet
    Interest('Vegan', '🥗'),
    Interest('Vegetarian', '🌱'),
    Interest('Keto', '🥩'),
    Interest('Organic', '🌾'),
    Interest('Ayurvedic', '🌿'),

    // Lifestyle
    Interest('Pets', '🐶'),
    Interest('Drinking Habits', '🍷'),
    Interest('Smoking Habits', '🚭'),
    Interest('Social Media Presence', '📱'),
  ];



  List<Interest> get filteredInterests {
    if (_searchController.text.isEmpty) return interests;
    return interests
        .where((interest) => interest.name
        .toLowerCase()
        .contains(_searchController.text.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.preferences != null) {
      autoSelectPreferences(widget.preferences!);
    }
  }

  void autoSelectPreferences(Map<String, dynamic> preferences) {
    final allValues = preferences.values.expand((e) => e).toList();
    final names = interests.map((i) => i.name.toLowerCase()).toSet();

    for (var item in allValues) {
      if (item is String && names.contains(item.toLowerCase())) {
        final match = interests.firstWhere(
              (i) => i.name.toLowerCase() == item.toLowerCase(),
          orElse: () => Interest('', ''),
        );
        if (match.name.isNotEmpty && !selectedInterests.contains(match.name)) {
          selectedInterests.add(match.name);
        }
      }
    }

    setState(() {});
  }

  void toggleInterest(String interestName) {
    setState(() {
      if (selectedInterests.contains(interestName)) {
        selectedInterests.remove(interestName);
      } else if (selectedInterests.length < 5) {
        selectedInterests.add(interestName);
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
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.arrow_back_ios,
                                color: Colors.black, size: 20),
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
                                      Color(0xFFA855F7)
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Discover like-minded people',
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                        Text('🤗', style: TextStyle(fontSize: 28)),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Share your interests, passions, and hobbies. We\'ll connect you with people who share your enthusiasm.',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5),
                    ),
                    SizedBox(height: 30),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: filteredInterests.map((interest) {
                        bool isSelected =
                        selectedInterests.contains(interest.name);
                        return GestureDetector(
                          onTap: () => toggleInterest(interest.name),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xFF8B5CF6)
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? Color(0xFF8B5CF6)
                                    : Colors.grey[300]!,
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
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(interest.emoji,
                                    style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      height: 56,
                      margin: EdgeInsets.only(bottom: 40),
                      child: ElevatedButton(
                        onPressed: selectedInterests.isNotEmpty
                            ? () async {
                          print('Selected interests: $selectedInterests');
                          await FirebaseService()
                              .updateUserInterests(selectedInterests);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PhotoUploadScreen()),
                          );
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8B5CF6),
                          disabledBackgroundColor: Colors.grey[300],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28)),
                        ),
                        child: Text(
                          'Continue (${selectedInterests.length}/5)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: selectedInterests.isNotEmpty
                                ? Colors.white
                                : Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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