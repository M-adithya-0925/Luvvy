import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'StoryPage.dart';
import 'services/FirebaseService.dart';

class DistancePreferenceScreen extends StatefulWidget {
  @override
  _DistancePreferenceScreenState createState() => _DistancePreferenceScreenState();
}

class _DistancePreferenceScreenState extends State<DistancePreferenceScreen>
    with TickerProviderStateMixin {
  double _currentDistance = 80.0;
  bool _isLoading = false;

  // ✅ FIXED: Make nullable initially
  AnimationController? _pulseController;
  AnimationController? _connectionController;
  Animation<double>? _pulseAnimation;
  Animation<double>? _connectionAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAnimations();
    });
  }

  void _initializeAnimations() {
    if (!mounted) return;

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _connectionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController!,
      curve: Curves.easeInOut,
    ));

    _connectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _connectionController!,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _pulseController?.repeat(reverse: true);
    _connectionController?.forward();

    setState(() {}); // Trigger rebuild after initialization
  }

  void _onDistanceChanged(double value) {
    setState(() {
      _currentDistance = value;
    });

    // Restart connection animation when distance changes
    if (_connectionController != null) {
      _connectionController!.reset();
      _connectionController!.forward();
    }
  }

  Widget _buildPersonAvatar({
    required bool isLeft,
    required String emoji,
    required Color color,
  }) {
    // ✅ FIXED: Add null safety check
    if (_pulseAnimation == null) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _pulseAnimation!,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation!.value * 0.9 + 0.1,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: color.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDistanceVisualization() {
    // ✅ FIXED: Add null safety check
    if (_connectionAnimation == null) {
      return Container(
        height: 200,
        child: Stack(
          children: [
            // Simple static version while animations load
            Positioned(
              left: 80,
              right: 80,
              top: 90,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Static people
            Positioned(
              left: 0,
              top: 50,
              child: _buildPersonAvatar(
                isLeft: true,
                emoji: "🧑",
                color: Colors.blue,
              ),
            ),
            Positioned(
              right: 0,
              top: 50,
              child: _buildPersonAvatar(
                isLeft: false,
                emoji: "👩",
                color: Colors.pink,
              ),
            ),
            // Static distance text
            Positioned(
              left: 0,
              right: 0,
              top: 110,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF8B5CF6), width: 1),
                  ),
                  child: Text(
                    '${_currentDistance.round()} km',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _connectionAnimation!,
      builder: (context, child) {
        return Container(
          height: 200,
          child: Stack(
            children: [
              // Background connection line
              Positioned(
                left: 80,
                right: 80,
                top: 90,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),

              // Animated connection line based on distance
              Positioned(
                left: 80,
                right: 80,
                top: 90,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF8B5CF6),
                        _currentDistance < 50
                            ? Colors.green
                            : _currentDistance < 100
                            ? Colors.orange
                            : Colors.red,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),

              // Animated dots showing connection strength
              ...List.generate(5, (index) {
                final progress = _connectionAnimation!.value;
                final delay = index * 0.2;
                final dotProgress = math.max(0.0, progress - delay);

                return Positioned(
                  left: 80 + (MediaQuery.of(context).size.width - 240) * (index / 4),
                  top: 85,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: dotProgress,
                    child: Transform.scale(
                      scale: dotProgress,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withOpacity(0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // Distance text in the middle
              Positioned(
                left: 0,
                right: 0,
                top: 110,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _currentDistance < 50
                          ? Colors.green.withOpacity(0.1)
                          : _currentDistance < 100
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _currentDistance < 50
                            ? Colors.green
                            : _currentDistance < 100
                            ? Colors.orange
                            : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${_currentDistance.round()} km',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _currentDistance < 50
                            ? Colors.green.shade700
                            : _currentDistance < 100
                            ? Colors.orange.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                ),
              ),

              // Left person
              Positioned(
                left: 0,
                top: 50,
                child: _buildPersonAvatar(
                  isLeft: true,
                  emoji: "🧑",
                  color: Colors.blue,
                ),
              ),

              // Right person
              Positioned(
                right: 0,
                top: 50,
                child: _buildPersonAvatar(
                  isLeft: false,
                  emoji: "👩",
                  color: Colors.pink,
                ),
              ),

              // Proximity indicators
              if (_currentDistance < 30 && _pulseController != null) ...[
                Positioned(
                  left: 100,
                  top: 40,
                  child: AnimatedBuilder(
                    animation: _pulseController!,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation!.value,
                        child: Container(
                          child: Text(
                            "💕",
                            style: TextStyle(
                              fontSize: 20 * _pulseAnimation!.value,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  right: 100,
                  top: 40,
                  child: AnimatedBuilder(
                    animation: _pulseController!,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation!.value,
                        child: Container(
                          child: Text(
                            "💖",
                            style: TextStyle(
                              fontSize: 20 * _pulseAnimation!.value,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              // Distance range indicator
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _currentDistance < 30
                          ? Icons.favorite
                          : _currentDistance < 70
                          ? Icons.location_on
                          : Icons.explore,
                      color: _currentDistance < 30
                          ? Colors.red
                          : _currentDistance < 70
                          ? Colors.orange
                          : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _currentDistance < 30
                          ? "Very Close"
                          : _currentDistance < 70
                          ? "Nearby"
                          : "Extended Range",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
              const SizedBox(height: 20),

              // Header with back button and progress
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey[200],
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: const LinearGradient(
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

              const SizedBox(height: 40),

              // Title
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Find matches nearby',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ✅ FIXED: Add null safety check for animated icon
                  if (_pulseController != null && _pulseAnimation != null)
                    AnimatedBuilder(
                      animation: _pulseController!,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulseAnimation!.value - 1.0) * 0.3,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 28,
                          ),
                        );
                      },
                    )
                  else
                    const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 28,
                    ),
                ],
              ),

              const SizedBox(height: 16),
              const Text(
                'Set your distance preference to discover perfect matches nearby. The closer, the stronger the connection!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 40),

              // Animated distance visualization
              _buildDistanceVisualization(),

              const SizedBox(height: 40),

              // Distance preference label
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Distance Range',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
                    ),
                    child: Text(
                      '${_currentDistance.round()} km',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8B5CF6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF8B5CF6),
                  inactiveTrackColor: Colors.grey[300],
                  thumbColor: const Color(0xFF8B5CF6),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
                  trackHeight: 6,
                  tickMarkShape: SliderTickMarkShape.noTickMark,
                ),
                child: Slider(
                  value: _currentDistance,
                  min: 1,
                  max: 150,
                  divisions: 149,
                  onChanged: _onDistanceChanged,
                ),
              ),

              // Distance markers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1 km',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '150 km',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Continue button
              Container(
                width: double.infinity,
                height: 56,
                margin: const EdgeInsets.only(bottom: 30),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      print('Distance preference set to: ${_currentDistance.round()} km');
                      await FirebaseService().updateDistanceRange(_currentDistance.round());

                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfileStoryScreen()),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    disabledBackgroundColor: Colors.grey.shade400,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
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

  @override
  void dispose() {
    _pulseController?.dispose();
    _connectionController?.dispose();
    super.dispose();
  }
}
