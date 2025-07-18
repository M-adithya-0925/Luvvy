import 'package:flutter/material.dart';
import 'StoryPage.dart';

class DistancePreferenceScreen extends StatefulWidget {
  @override
  _DistancePreferenceScreenState createState() => _DistancePreferenceScreenState();
}

class _DistancePreferenceScreenState extends State<DistancePreferenceScreen> {
  double _currentDistance = 80.0;

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
                        widthFactor: 1.0, // final step
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

              SizedBox(height: 60),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Find matches nearby',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 22,
                  ),
                ],
              ),

              SizedBox(height: 24),
              Text(
                'Select your preferred distance range to discover matches conveniently. We\'ll help you find love close by.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Distance Preference',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '${_currentDistance.round()} km',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Color(0xFF8B5CF6),
                  inactiveTrackColor: Colors.grey[300],
                  thumbColor: Color(0xFF8B5CF6),
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _currentDistance,
                  min: 1,
                  max: 150,
                  onChanged: (value) {
                    setState(() {
                      _currentDistance = value;
                    });
                  },
                ),
              ),

              Spacer(),

              Container(
                width: double.infinity,
                height: 56,
                margin: EdgeInsets.only(bottom: 30),
                child: ElevatedButton(
                  onPressed: () {
                    print('Distance preference set to: ${_currentDistance.round()} km');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileStoryScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B5CF6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
