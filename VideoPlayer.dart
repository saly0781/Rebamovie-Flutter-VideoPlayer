// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Manages the play/pause state of the audio wave animation.
class AudioWaveData extends ChangeNotifier {
  bool _isPlaying;

  AudioWaveData() : _isPlaying = false;

  bool get isPlaying => _isPlaying;

  void play() {
    if (!_isPlaying) {
      _isPlaying = true;
      notifyListeners();
    }
  }

  void pause() {
    if (_isPlaying) {
      _isPlaying = false;
      notifyListeners();
    }
  }

  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }
}

/// The main widget that visualizes the audio wave using animated bars.
class AudioWaveVisualizer extends StatefulWidget {
  const AudioWaveVisualizer({super.key});

  @override
  State<AudioWaveVisualizer> createState() => _AudioWaveVisualizerState();
}

class _AudioWaveVisualizerState extends State<AudioWaveVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _waveAnimation;

  final double _baseHeight = 10.0;
  final double _maxAmplitude = 5.0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _waveAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAnimationState(
        Provider.of<AudioWaveData>(context, listen: false).isPlaying,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final audioWaveData = Provider.of<AudioWaveData>(context);
    _updateAnimationState(audioWaveData.isPlaying);
  }

  void _updateAnimationState(bool isPlaying) {
    if (isPlaying) {
      if (!_animationController.isAnimating) {
        _animationController.repeat();
      }
    } else {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Calculates the height for a bar based on animation value and index.
  double _calculateBarHeight(double animationValue, int barIndex) {
    // Continuous wave motion
    final double waveSpeed = 4 * pi;
    const double phaseSpacing = pi / 3;

    final double angle =
        (animationValue * waveSpeed) - (barIndex * phaseSpacing);

    // Map sine (-1..1) to (0..1)
    final scaledAmplitude = _maxAmplitude * (sin(angle) * 1 + 1);

    return _baseHeight + scaledAmplitude;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(3, (index) {
            final height = _calculateBarHeight(_waveAnimation.value, index);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: AudioWaveBar(height: height),
            );
          }),
        );
      },
    );
  }
}

/// Represents a single bar in the audio wave visualization.
class AudioWaveBar extends StatelessWidget {
  final double height;

  const AudioWaveBar({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Transform.translate(
        offset: const Offset(0, 0),
        child: Container(
          width: 5.0,
          height: height,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primary,
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }
}

/// Custom widget for animated buttons with bounce effect and haptic feedback
class AnimatedControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? color;

  const AnimatedControlButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.size,
    this.color = Colors.white,
  });

  @override
  State<AnimatedControlButton> createState() => _AnimatedControlButtonState();
}

class _AnimatedControlButtonState extends State<AnimatedControlButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  bool _isLongPressing = false;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _bounceAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0), weight: 50),
    ]).animate(_bounceController)
      ..addListener(() {
        setState(() {
          _scale = _bounceAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!_isLongPressing) {
      _bounceController.forward(from: 0);
      HapticFeedback.lightImpact();
      widget.onTap();
    }
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isLongPressing = true;
      _scale = 0.85;
    });
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (_isLongPressing) {
      HapticFeedback.lightImpact();
      widget.onTap();
    }

    setState(() {
      _isLongPressing = false;
      _scale = 1.0;
    });
  }

  void _onLongPressCancel() {
    setState(() {
      _isLongPressing = false;
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      onLongPressCancel: _onLongPressCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: Color(0x32818181),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0x40E0E3E7), width: 1),
              ),
              alignment: AlignmentDirectional(0, 0),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: widget.size * 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated episode card with bounce effect
class AnimatedEpisodeCard extends StatefulWidget {
  final ApiEpisodeData episode;
  final bool isActive;
  final Function(int) onEpisodeSelected;
  final int index;
  final VoidCallback onCloseBottomSheet;
  final int seasonIndex;

  const AnimatedEpisodeCard({
    super.key,
    required this.episode,
    required this.isActive,
    required this.onEpisodeSelected,
    required this.index,
    required this.onCloseBottomSheet,
    required this.seasonIndex,
  });

  @override
  State<AnimatedEpisodeCard> createState() => _AnimatedEpisodeCardState();
}

class _AnimatedEpisodeCardState extends State<AnimatedEpisodeCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  bool _isLongPressing = false;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _bounceAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0), weight: 50),
    ]).animate(_bounceController)
      ..addListener(() {
        setState(() {
          _scale = _bounceAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  Widget _buildPlaceholderCover() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.movie, color: Colors.grey[600], size: 40),
    );
  }

  void _onTap() {
    if (!_isLongPressing) {
      _bounceController.forward(from: 0);
      HapticFeedback.lightImpact();

      // For locked episodes, the video will still play but with locked controls
      // The server will handle serving the appropriate content based on user status
      widget.onEpisodeSelected(widget.index);

      // Close bottom sheet after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        widget.onCloseBottomSheet();
      });
    }
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isLongPressing = true;
      _scale = 0.85; // shrink card
    });
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (_isLongPressing) {
      HapticFeedback.lightImpact();
      widget.onEpisodeSelected(widget.index);

      // Close bottom sheet after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        widget.onCloseBottomSheet();
      });
    }

    setState(() {
      _isLongPressing = false;
      _scale = 1.0; // revert card
    });
  }

  void _onLongPressCancel() {
    // User dragged finger off → cancel action
    setState(() {
      _isLongPressing = false;
      _scale = 1.0; // revert card
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      onLongPressCancel: _onLongPressCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          width: 250,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: widget.isActive
                ? Border.all(
                    color: FlutterFlowTheme.of(context).primary,
                    width: 3,
                  )
                : Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
            boxShadow: _isLongPressing
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              // Episode cover image
              if (widget.episode.longCover != null &&
                  widget.episode.longCover!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.episode.longCover!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderCover();
                    },
                  ),
                )
              else
                _buildPlaceholderCover(),

              // Gradient overlay for better text visibility
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                    stops: [0.0, 0.9],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              // Lock icon overlay for locked episodes
              if (widget.episode.locked)
                Align(
                  alignment: AlignmentDirectional(1, -1),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 5, 5, 0),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.lock, color: Colors.white, size: 25),
                    ),
                  ),
                ),

              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Season text above episode number
                    Text(
                      'Season ${widget.seasonIndex + 1}',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: FlutterFlowTheme.of(
                              context,
                            ).bodySmallFamily,
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            useGoogleFonts: !FlutterFlowTheme.of(
                              context,
                            ).bodySmallIsCustom,
                          ),
                    ),

                    // Episode number
                    Text(
                      '${widget.episode.episode}',
                      style:
                          FlutterFlowTheme.of(context).displayMedium.override(
                                fontFamily: FlutterFlowTheme.of(
                                  context,
                                ).displayMediumFamily,
                                color: Colors.white,
                                fontSize: 30,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                                useGoogleFonts: !FlutterFlowTheme.of(
                                  context,
                                ).displayMediumIsCustom,
                              ),
                    ),

                    // Episode title
                    Text(
                      widget.episode.title ??
                          'Episode ${widget.episode.episode}',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: FlutterFlowTheme.of(
                              context,
                            ).bodyMediumFamily,
                            color: Colors.white,
                            letterSpacing: 0.0,
                            useGoogleFonts: !FlutterFlowTheme.of(
                              context,
                            ).bodyMediumIsCustom,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              if (widget.isActive && !widget.episode.locked)
                Align(
                  alignment: AlignmentDirectional(1, -1),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 10, 10, 0),
                    child: Consumer<AudioWaveData>(
                      builder: (context, audioWaveData, child) {
                        return AudioWaveVisualizer();
                      },
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

/// Animated More Videos Card with bounce effect
class AnimatedMoreVideosCard extends StatefulWidget {
  final VoidCallback onTap;
  final String moreText;
  final String videoText;
  final Widget coverImage;

  const AnimatedMoreVideosCard({
    super.key,
    required this.onTap,
    required this.moreText,
    required this.videoText,
    required this.coverImage,
  });

  @override
  State<AnimatedMoreVideosCard> createState() => _AnimatedMoreVideosCardState();
}

class _AnimatedMoreVideosCardState extends State<AnimatedMoreVideosCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  bool _isLongPressing = false;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _bounceAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 50),
    ]).animate(_bounceController)
      ..addListener(() {
        setState(() {
          _scale = _bounceAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!_isLongPressing) {
      _bounceController.forward(from: 0);
      HapticFeedback.lightImpact();
      widget.onTap();
    }
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isLongPressing = true;
      _scale = 0.8; // shrink card
    });
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (_isLongPressing) {
      // Finger is still on the card when released → trigger action
      HapticFeedback.lightImpact();
      widget.onTap();
    }

    setState(() {
      _isLongPressing = false;
      _scale = 1.0; // revert card
    });
  }

  void _onLongPressCancel() {
    // User dragged finger off → cancel action
    setState(() {
      _isLongPressing = false;
      _scale = 1.0; // revert card
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      onLongPressCancel: _onLongPressCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          width: 200,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(_isLongPressing ? 0.7 : 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(_isLongPressing ? 0.4 : 0.3),
              width: _isLongPressing ? 1.5 : 1.0,
            ),
            boxShadow: _isLongPressing
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(10, 0, 30, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.moreText,
                        style:
                            FlutterFlowTheme.of(context).displaySmall.override(
                                  fontFamily: FlutterFlowTheme.of(
                                    context,
                                  ).displaySmallFamily,
                                  color: Colors.white,
                                  fontSize: 15,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  lineHeight: 1,
                                  useGoogleFonts: !FlutterFlowTheme.of(
                                    context,
                                  ).displaySmallIsCustom,
                                ),
                      ),
                      Text(
                        widget.videoText,
                        style:
                            FlutterFlowTheme.of(context).displaySmall.override(
                                  fontFamily: FlutterFlowTheme.of(
                                    context,
                                  ).displaySmallFamily,
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontSize: 15,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  useGoogleFonts: !FlutterFlowTheme.of(
                                    context,
                                  ).displaySmallIsCustom,
                                ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Stack(
                        children: [
                          widget.coverImage,
                          Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0, 0),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Data structure to hold API response
class CinemaDataResponse {
  final bool isSeason;
  final List<String> ads;
  final CinemaData data;

  CinemaDataResponse({
    required this.isSeason,
    required this.ads,
    required this.data,
  });

  factory CinemaDataResponse.fromJson(Map<String, dynamic> json) {
    return CinemaDataResponse(
      isSeason: json['isSeason'] ?? false,
      ads: List<String>.from(json['ads'] ?? []),
      data: CinemaData.fromJson(json['data'] ?? {}),
    );
  }
}

class CinemaData {
  final List<String> seasons;
  final List<List<ApiEpisodeData>> episodes;

  CinemaData({required this.seasons, required this.episodes});

  factory CinemaData.fromJson(Map<String, dynamic> json) {
    List<String> seasonsList = List<String>.from(json['seasons'] ?? []);
    List<List<ApiEpisodeData>> episodesList = [];

    if (json['episodes'] != null) {
      for (var episodeArray in json['episodes']) {
        List<ApiEpisodeData> seasonEpisodes = [];
        for (var episodeData in episodeArray) {
          seasonEpisodes.add(ApiEpisodeData.fromJson(episodeData));
        }
        episodesList.add(seasonEpisodes);
      }
    }

    return CinemaData(seasons: seasonsList, episodes: episodesList);
  }
}

class ApiEpisodeData {
  final String movieId;
  final MovieDataId? movieDataId;
  final String server;
  final String episodeId;
  final String title;
  final String seoTitle;
  final Interpreter? interpreter;
  final int episode;
  final String partName;
  final String longCover;
  final String noLongCover;
  final String image;
  final String hdimage;
  final String noImage;
  final String hdnoImage;
  final String type;
  final String logo;
  final PositionStruct? position;
  final ContinueWatchingStruct? continueWatching;
  final VideoStruct? video;
  final SizeStruct? size;
  final TimeStruct? time;
  final bool liked;
  final String addedToList;
  final bool viewed;
  final bool locked;
  final bool adstatus;
  final bool xr;

  ApiEpisodeData({
    required this.movieId,
    this.movieDataId,
    required this.server,
    required this.episodeId,
    required this.title,
    required this.seoTitle,
    this.interpreter,
    required this.episode,
    required this.partName,
    required this.longCover,
    required this.noLongCover,
    required this.image,
    required this.hdimage,
    required this.noImage,
    required this.hdnoImage,
    required this.type,
    required this.logo,
    this.position,
    this.continueWatching,
    this.video,
    this.size,
    this.time,
    required this.liked,
    required this.addedToList,
    required this.viewed,
    required this.locked,
    required this.adstatus,
    required this.xr,
  });

  factory ApiEpisodeData.fromJson(Map<String, dynamic> json) {
    return ApiEpisodeData(
      movieId: json['movieId'] ?? '',
      movieDataId: json['movieDataId'] != null
          ? MovieDataId.fromJson(json['movieDataId'])
          : null,
      server: json['server'] ?? '',
      episodeId: json['episodeId'] ?? '',
      title: json['title'] ?? '',
      seoTitle: json['seoTitle'] ?? '',
      interpreter: json['interpreter'] != null
          ? Interpreter.fromJson(json['interpreter'])
          : null,
      episode: json['episode'] ?? 0,
      partName: json['partName'] ?? '',
      longCover: json['longCover'] ?? '',
      noLongCover: json['noLongCover'] ?? '',
      image: json['image'] ?? '',
      hdimage: json['hdimage'] ?? '',
      noImage: json['noImage'] ?? '',
      hdnoImage: json['hdnoImage'] ?? '',
      type: json['type'] ?? '',
      logo: json['logo'] ?? '',
      position: json['position'] != null
          ? PositionStruct(
              seasonIndex: json['position']['seasonIndex'] ?? 0,
              episodeIndex: json['position']['episodeIndex'] ?? 0,
            )
          : null,
      continueWatching: json['continueWatching'] != null
          ? ContinueWatchingStruct(
              inMinutes: json['continueWatching']['inMinutes'] ?? 0,
              inPercentage:
                  (json['continueWatching']['inPercentage'] ?? 0.0).toDouble(),
            )
          : null,
      video: json['video'] != null
          ? VideoStruct(
              hdVideo: json['video']['hdVideo'] ?? '',
              midVideo: json['video']['midVideo'] ?? '',
              lowVideo: json['video']['lowVideo'] ?? '',
            )
          : null,
      size: json['size'] != null
          ? SizeStruct(
              hdSize: json['size']['hdSize'] ?? '',
              midSize: json['size']['midSize'] ?? '',
              lowSize: json['size']['lowSize'] ?? '',
            )
          : null,
      time: json['time'] != null
          ? TimeStruct(
              startTime: json['time']['startTime'] ?? '0',
              endTime: json['time']['endTime'] ?? '0',
            )
          : null,
      liked: json['liked'] ?? false,
      addedToList: json['addedToList'] ?? 'notAdded',
      viewed: json['viewed'] ?? false,
      locked: json['locked'] ?? false,
      adstatus: json['adstatus'] ?? false,
      xr: json['xr'] ?? false,
    );
  }

  EpisodesStruct toEpisodesStruct() {
    return EpisodesStruct(
      movieId: movieId,
      episodeId: episodeId,
      title: title,
      episode: episode,
      partName: partName,
      longCover: longCover,
      image: image,
      type: type,
      position: position ?? PositionStruct(seasonIndex: 0, episodeIndex: 0),
      continueWatching: continueWatching ??
          ContinueWatchingStruct(inMinutes: 0, inPercentage: 0.0),
      video: video ?? VideoStruct(hdVideo: '', midVideo: '', lowVideo: ''),
      size: size ?? SizeStruct(hdSize: '', midSize: '', lowSize: ''),
      time: time ?? TimeStruct(startTime: '0', endTime: '0'),
      liked: liked,
      addedToList: addedToList,
      viewed: viewed,
      locked: locked,
      adstatus: adstatus,
      isSeason: false,
      server: server,
      xr: xr,
      description: movieDataId?.description ?? '',
    );
  }
}

class MovieDataId {
  final List<String> genre;
  final String description;
  final List<String> country;
  final String rereaseDate;
  final String title;
  final String fullReleaseDate;

  MovieDataId({
    required this.genre,
    required this.description,
    required this.country,
    required this.rereaseDate,
    required this.title,
    required this.fullReleaseDate,
  });

  factory MovieDataId.fromJson(Map<String, dynamic> json) {
    return MovieDataId(
      genre: List<String>.from(json['genre'] ?? []),
      description: json['description'] ?? '',
      country: List<String>.from(json['country'] ?? []),
      rereaseDate: json['rereaseDate'] ?? '',
      title: json['title'] ?? '',
      fullReleaseDate: json['fullReleaseDate'] ?? '',
    );
  }
}

class Interpreter {
  final String title;

  Interpreter({required this.title});

  factory Interpreter.fromJson(Map<String, dynamic> json) {
    return Interpreter(title: json['title'] ?? '');
  }
}

// ContinueWatchingEpisode struct for continue watching functionality
class ContinueWatchingEpisode {
  final String movieId;
  final String episodeId;
  final String title;
  final int episode;
  final String partName;
  final String longCover;
  final String image;
  final String type;
  final PositionStruct position;
  final ContinueWatchingStruct continueWatching;
  final VideoStruct video;
  final SizeStruct size;
  final TimeStruct time;
  final bool liked;
  final String addedToList;
  final bool viewed;
  final bool locked;
  final bool adstatus;
  final bool isSeason;
  final String server;
  final bool xr;
  final String description;

  ContinueWatchingEpisode({
    required this.movieId,
    required this.episodeId,
    required this.title,
    required this.episode,
    required this.partName,
    required this.longCover,
    required this.image,
    required this.type,
    required this.position,
    required this.continueWatching,
    required this.video,
    required this.size,
    required this.time,
    required this.liked,
    required this.addedToList,
    required this.viewed,
    required this.locked,
    required this.adstatus,
    required this.isSeason,
    required this.server,
    required this.xr,
    required this.description,
  });
}

/// QualitySelector widget
class QualitySelector extends StatefulWidget {
  final ApiEpisodeData currentEpisode;
  final String currentQuality;
  final Function(String) onQualityChanged;

  const QualitySelector({
    super.key,
    required this.currentEpisode,
    required this.currentQuality,
    required this.onQualityChanged,
  });

  @override
  State<QualitySelector> createState() => _QualitySelectorState();
}

class _QualitySelectorState extends State<QualitySelector> {
  String _getQualitySize(String quality) {
    switch (quality) {
      case "HD":
        return widget.currentEpisode.size?.hdSize ?? '';
      case "MID":
        return widget.currentEpisode.size?.midSize ?? '';
      case "LOW":
        return widget.currentEpisode.size?.lowSize ?? '';
      default:
        return '';
    }
  }

  String _getQualityUrl(String quality) {
    switch (quality) {
      case "HD":
        return widget.currentEpisode.video?.hdVideo ?? '';
      case "MID":
        return widget.currentEpisode.video?.midVideo ?? '';
      case "LOW":
        return widget.currentEpisode.video?.lowVideo ?? '';
      default:
        return '';
    }
  }

  bool _isQualityAvailable(String quality) {
    final url = _getQualityUrl(quality);
    return url.isNotEmpty &&
        (url.startsWith('https://') || url.startsWith('http://'));
  }

  bool _hasSize(String quality) {
    final size = _getQualitySize(quality);
    return size.isNotEmpty && size != "0 MB" && size != "0 GB";
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          width: 230,
          height: 55,
          constraints: BoxConstraints(minWidth: 200, maxWidth: 270),
          decoration: BoxDecoration(
            color: Color(0x32818181),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Color(0x40E0E3E7), width: 1),
          ),
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // HD Quality
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: _isQualityAvailable("HD")
                        ? () {
                            HapticFeedback.lightImpact();
                            widget.onQualityChanged("HD");
                          }
                        : null,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: widget.currentQuality == "HD" &&
                                _isQualityAvailable("HD")
                            ? Color(0xB31FDF67)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: _hasSize("HD")
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.center,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: Text(
                              'HD',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(
                                      context,
                                    ).bodyMediumFamily,
                                    color: _isQualityAvailable("HD")
                                        ? (widget.currentQuality == "HD"
                                            ? FlutterFlowTheme.of(
                                                context,
                                              ).primaryBackground
                                            : FlutterFlowTheme.of(
                                                context,
                                              ).alternate)
                                        : Color(0x41B4B8B4),
                                    fontSize: 15,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    useGoogleFonts: !FlutterFlowTheme.of(
                                      context,
                                    ).bodyMediumIsCustom,
                                  ),
                            ),
                          ),
                          if (_hasSize("HD")) ...[
                            SizedBox(height: 2),
                            Text(
                              _getQualitySize("HD"),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(
                                      context,
                                    ).bodyMediumFamily,
                                    color: _isQualityAvailable("HD")
                                        ? (widget.currentQuality == "HD"
                                            ? FlutterFlowTheme.of(
                                                context,
                                              ).primaryBackground
                                            : FlutterFlowTheme.of(
                                                context,
                                              ).alternate)
                                        : Color(0x41B4B8B4),
                                    fontSize: 12,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w300,
                                    useGoogleFonts: !FlutterFlowTheme.of(
                                      context,
                                    ).bodyMediumIsCustom,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4),
                // MID Quality
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: _isQualityAvailable("MID")
                        ? () {
                            HapticFeedback.lightImpact();
                            widget.onQualityChanged("MID");
                          }
                        : null,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: widget.currentQuality == "MID" &&
                                _isQualityAvailable("MID")
                            ? Color(0xB31FDF67)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: _hasSize("MID")
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.center,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: Text(
                              'MID',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(
                                      context,
                                    ).bodyMediumFamily,
                                    color: _isQualityAvailable("MID")
                                        ? (widget.currentQuality == "MID"
                                            ? FlutterFlowTheme.of(
                                                context,
                                              ).primaryBackground
                                            : FlutterFlowTheme.of(
                                                context,
                                              ).alternate)
                                        : Color(0x41B4B8B4),
                                    fontSize: 15,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    useGoogleFonts: !FlutterFlowTheme.of(
                                      context,
                                    ).bodyMediumIsCustom,
                                  ),
                            ),
                          ),
                          if (_hasSize("MID")) ...[
                            SizedBox(height: 2),
                            Text(
                              _getQualitySize("MID"),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(
                                      context,
                                    ).bodyMediumFamily,
                                    color: _isQualityAvailable("MID")
                                        ? (widget.currentQuality == "MID"
                                            ? FlutterFlowTheme.of(
                                                context,
                                              ).primaryBackground
                                            : FlutterFlowTheme.of(
                                                context,
                                              ).alternate)
                                        : Color(0x41B4B8B4),
                                    fontSize: 12,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w300,
                                    useGoogleFonts: !FlutterFlowTheme.of(
                                      context,
                                    ).bodyMediumIsCustom,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4),
                // LOW Quality
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: _isQualityAvailable("LOW")
                        ? () {
                            HapticFeedback.lightImpact();
                            widget.onQualityChanged("LOW");
                          }
                        : null,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: widget.currentQuality == "LOW" &&
                                _isQualityAvailable("LOW")
                            ? Color(0xB31FDF67)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: _hasSize("LOW")
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.center,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: Text(
                              'LOW',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(
                                      context,
                                    ).bodyMediumFamily,
                                    color: _isQualityAvailable("LOW")
                                        ? (widget.currentQuality == "LOW"
                                            ? FlutterFlowTheme.of(
                                                context,
                                              ).primaryBackground
                                            : FlutterFlowTheme.of(
                                                context,
                                              ).alternate)
                                        : Color(0x41B4B8B4),
                                    fontSize: 15,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    useGoogleFonts: !FlutterFlowTheme.of(
                                      context,
                                    ).bodyMediumIsCustom,
                                  ),
                            ),
                          ),
                          if (_hasSize("LOW")) ...[
                            SizedBox(height: 2),
                            Text(
                              _getQualitySize("LOW"),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(
                                      context,
                                    ).bodyMediumFamily,
                                    color: _isQualityAvailable("LOW")
                                        ? (widget.currentQuality == "LOW"
                                            ? FlutterFlowTheme.of(
                                                context,
                                              ).primaryBackground
                                            : FlutterFlowTheme.of(
                                                context,
                                              ).alternate)
                                        : Color(0x41B4B8B4),
                                    fontSize: 12,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w300,
                                    useGoogleFonts: !FlutterFlowTheme.of(
                                      context,
                                    ).bodyMediumIsCustom,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// AdPlayer widget
class AdPlayer extends StatefulWidget {
  final List<String> adUrls;
  final Function(String action) onAction; // Changed to accept action type
  final String movieId;
  final Future Function(dynamic action)? customCallBack;

  const AdPlayer({
    super.key,
    required this.adUrls,
    required this.onAction, // Updated parameter
    required this.movieId,
    required this.customCallBack,
  });

  @override
  State<AdPlayer> createState() => _AdPlayerState();
}

class _AdPlayerState extends State<AdPlayer> {
  VideoPlayerController? _adVideoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _isFullScreen = false;
  bool _adCompleted = false;

  // Skip button variables
  double _skipProgress = 0.0;
  bool _skipActive = false;
  Timer? _skipTimer;
  final int _skipDuration = 35; // 35 seconds

  @override
  void initState() {
    super.initState();
    _initializeAd();
    _startSkipCountdown();
  }

  @override
  void dispose() {
    _adVideoController?.removeListener(_adVideoListener);
    _adVideoController?.dispose();
    _chewieController?.dispose();
    _skipTimer?.cancel();
    super.dispose();
  }

  void _startSkipCountdown() {
    const tick = Duration(milliseconds: 100);
    int elapsed = 0;
    final totalDuration = _skipDuration * 1000;

    _skipTimer = Timer.periodic(tick, (t) {
      if (_adCompleted) {
        _skipTimer?.cancel();
        return;
      }

      setState(() {
        elapsed += tick.inMilliseconds;
        _skipProgress = elapsed / totalDuration;

        if (_skipProgress >= 1.0) {
          _skipProgress = 1.0;
          _skipActive = true;
          _skipTimer?.cancel();
        }
      });
    });
  }

  Future<void> _initializeAd() async {
    if (widget.adUrls.isEmpty) {
      _completeAd();
      return;
    }

    setState(() {
      _isLoading = true;
      _adCompleted = false;
    });

    // Only use the FIRST ad URL (we now pass only one ad)
    final adUrl = widget.adUrls.first;

    try {
      // Clean up previous controllers
      _adVideoController?.removeListener(_adVideoListener);
      await _adVideoController?.dispose();
      _chewieController?.dispose();

      _adVideoController = VideoPlayerController.network(adUrl);
      await _adVideoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _adVideoController!,
        autoPlay: true,
        looping: false,
        autoInitialize: true,
        allowedScreenSleep: false,
        showControls: false,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Ad failed to load: $errorMessage',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      _adVideoController!.addListener(_adVideoListener);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading ad: $e');
      // If ad fails to load, just complete
      _completeAd();
    }
  }

  void _adVideoListener() {
    if (_adVideoController == null || _adCompleted) return;

    // Check if ad has finished
    if (_adVideoController!.value.isInitialized &&
        _adVideoController!.value.position >=
            _adVideoController!.value.duration &&
        !_adVideoController!.value.isBuffering) {
      // Single ad finished
      _completeAd();
    }
  }

  void _completeAd() {
    if (_adCompleted) return;

    setState(() {
      _adCompleted = true;
    });

    _skipTimer?.cancel();

    // Close the ad and call completion callback with "skipAd" action
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        widget.onAction("skipAd");
      }
    });
  }

  void _skipAd() {
    if (_skipActive && !_adCompleted) {
      _skipTimer?.cancel();
      widget.onAction("skipAd");
    }
  }

  void _handleSubscribe() {
    widget.onAction("subscribe");
  }

  void _handleBackButton() {
    widget.onAction("back");
  }

  Future<void> _toggleFullscreen() async {
    if (_isFullScreen) {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      setState(() {
        _isFullScreen = false;
      });
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      setState(() {
        _isFullScreen = true;
      });
    }
  }

  Widget _buildSkipButton() {
    return GestureDetector(
      onTap: _skipActive ? _skipAd : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 150,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x67FFFFFF), width: 2),
          ),
          child: Stack(
            children: [
              // Background
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xB3090909),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              // Progress bar overlay
              Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 150 * _skipProgress,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0x34E0E3E7),
                    borderRadius: BorderRadius.only(
                      bottomLeft: const Radius.circular(12),
                      bottomRight: _skipProgress >= 1.0
                          ? const Radius.circular(12)
                          : const Radius.circular(0),
                      topLeft: const Radius.circular(12),
                      topRight: _skipProgress >= 1.0
                          ? const Radius.circular(12)
                          : const Radius.circular(0),
                    ),
                  ),
                ),
              ),

              // Text overlay
              Center(
                child: Text(
                  _skipActive
                      ? Localizations.localeOf(context).languageCode == 'en'
                          ? 'Skip'
                          : 'Hagarika'
                      : "${Localizations.localeOf(context).languageCode == 'en' ? 'wait' : 'Tegereza'} ${_skipDuration - (_skipProgress * _skipDuration).floor()}s",
                  style: TextStyle(
                    color: _skipActive
                        ? Colors.white
                        : Colors.white.withOpacity(0.6),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          // Video Player
          if (_chewieController != null && !_isLoading)
            Container(
              width: double.infinity,
              height: double.infinity,
              child: Chewie(controller: _chewieController!),
            )
          else
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      Localizations.localeOf(context).languageCode == 'en'
                          ? 'Loading Advertisement...'
                          : 'Kwamamaza...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          // Controls Overlay
          Align(
            alignment: AlignmentDirectional(0, 0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(30, 20, 30, 30),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Controls
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        GestureDetector(
                          onTap: _handleBackButton,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chevron_left_rounded,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ),

                        // Fullscreen Button
                        GestureDetector(
                          onTap: _toggleFullscreen,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isFullScreen
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen_rounded,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Buttons
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Pay Button
                        GestureDetector(
                          onTap: _handleSubscribe,
                          child: Container(
                            width: 150,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xCC1FDF67),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(0x67FFFFFF),
                                width: 1,
                              ),
                            ),
                            child: Align(
                              alignment: AlignmentDirectional(0, 0),
                              child: Text(
                                Localizations.localeOf(context).languageCode ==
                                        'en'
                                    ? 'Click To Pay'
                                    : 'Kwishyura',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(
                                        context,
                                      ).bodyMediumFamily,
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).primaryBackground,
                                      fontSize: 15,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      useGoogleFonts: !FlutterFlowTheme.of(
                                        context,
                                      ).bodyMediumIsCustom,
                                    ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 4),

                        // Skip Button with countdown
                        _buildSkipButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedSeasonCard extends StatefulWidget {
  final int seasonIndex;
  final String seasonName;
  final String? seasonCover;
  final bool isActive;
  final Function(int) onSeasonSelected;

  const AnimatedSeasonCard({
    super.key,
    required this.seasonIndex,
    required this.seasonName,
    required this.seasonCover,
    required this.isActive,
    required this.onSeasonSelected,
  });

  @override
  State<AnimatedSeasonCard> createState() => _AnimatedSeasonCardState();
}

class _AnimatedSeasonCardState extends State<AnimatedSeasonCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  bool _isAnimating = false;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _bounceAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0), weight: 50),
    ]).animate(_bounceController)
      ..addListener(() {
        setState(() {
          _scale = _bounceAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_isAnimating) return;

    _bounceController.forward(from: 0);
    HapticFeedback.lightImpact();
    widget.onSeasonSelected(widget.seasonIndex);

    setState(() {
      _isAnimating = true;
    });

    Future.delayed(Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          width: 250,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: widget.isActive
                ? Border.all(color: Color(0xCC1FDF67), width: 4)
                : null,
          ),
          child: Stack(
            children: [
              // Season cover image
              if (widget.seasonCover != null && widget.seasonCover!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.seasonCover!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderSeasonCover();
                    },
                  ),
                )
              else
                _buildPlaceholderSeasonCover(),

              // Gradient overlay for better text visibility
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xB3090909), Color(0xB3090909)],
                    stops: [0, 1],
                    begin: AlignmentDirectional(1, 0),
                    end: AlignmentDirectional(-1, 0),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              // Season name
              Center(
                child: Text(
                  widget.seasonName,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        color:
                            widget.isActive ? Color(0xCB1FDF67) : Colors.white,
                        fontSize: 30,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        useGoogleFonts: !FlutterFlowTheme.of(
                          context,
                        ).bodyMediumIsCustom,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderSeasonCover() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.movie, color: Colors.grey[600], size: 40),
    );
  }
}

class _VideoLoadingScreen extends StatefulWidget {
  final ApiEpisodeData episode;
  final bool isLandscape;

  const _VideoLoadingScreen({required this.episode, required this.isLandscape});

  @override
  State<_VideoLoadingScreen> createState() => _VideoLoadingScreenState();
}

class _VideoLoadingScreenState extends State<_VideoLoadingScreen> {
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    animationsMap.addAll({
      'textOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 220.0.ms,
            duration: 820.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 780.0.ms,
            begin: Offset(0.0, 0.0),
            end: Offset(0.0, -12.0),
          ),
        ],
      ),
      'imageOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 220.0.ms,
            duration: 820.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 780.0.ms,
            begin: Offset(0.0, 0.0),
            end: Offset(0.0, -12.0),
          ),
        ],
      ),
      'dividerOnPageLoadAnimation1': AnimationInfo(
        loop: true,
        reverse: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.linear,
            delay: 0.0.ms,
            duration: 220.0.ms,
            begin: Offset(1.0, 1.0),
            end: Offset(-1.0, 1.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 220.0.ms,
            duration: 820.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 780.0.ms,
            begin: Offset(0.0, 0.0),
            end: Offset(0.0, -12.0),
          ),
        ],
      ),
      'imageOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 220.0.ms,
            duration: 820.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 780.0.ms,
            begin: Offset(0.0, 0.0),
            end: Offset(0.0, -12.0),
          ),
        ],
      ),
      'dividerOnPageLoadAnimation2': AnimationInfo(
        loop: true,
        reverse: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.linear,
            delay: 0.0.ms,
            duration: 220.0.ms,
            begin: Offset(1.0, 1.0),
            end: Offset(-1.0, 1.0),
          ),
        ],
      ),
    });
  }

  String _getGenre() {
    if (widget.episode.movieDataId?.genre?.isNotEmpty ?? false) {
      return widget.episode.movieDataId!.genre.first;
    }
    return 'Movie';
  }

  String _getCountry() {
    if (widget.episode.movieDataId?.country?.isNotEmpty ?? false) {
      return widget.episode.movieDataId!.country.first;
    }
    return 'International';
  }

  String _getReleaseDate() {
    return widget.episode.movieDataId?.rereaseDate ?? '2024';
  }

  String _getDescription() {
    return widget.episode.movieDataId?.description ??
        'Enjoy your favorite content on rebaMovie';
  }

  String _getTitle() {
    return widget.episode.movieDataId?.title ?? widget.episode.title;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLandscape) {
      return _buildLandscapeLoadingScreen();
    } else {
      return _buildPortraitLoadingScreen();
    }
  }

  Widget _buildLandscapeLoadingScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Background image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              fadeInDuration: Duration(milliseconds: 500),
              fadeOutDuration: Duration(milliseconds: 500),
              imageUrl: widget.episode.longCover.isNotEmpty
                  ? widget.episode.noLongCover == null
                      ? widget.episode.noLongCover
                      : widget.episode.longCover
                  : 'https://static.wixstatic.com/media/b7e546_3f1f253483fe41d287faf9de00228c2b~mv2.webp/v1/fill/w_1280,h_720,al_c,q_80,usm_0.66_1.00_0.01,enc_avif,quality_auto/loading_edited.jpg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment(1, 0),
            ),
          ),
          // Gradient overlay
          Container(
            width: 738.7,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xF2090909),
                  Color(0xDD090909),
                  Color(0x00090909),
                ],
                stops: [0.2, 0.4, 1],
                begin: AlignmentDirectional(-1, 0),
                end: AlignmentDirectional(1, 0),
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(50, 0, 0, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/REB-removebg-preview.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        alignment: Alignment(1, -1),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 7),
                    child: Container(
                      width: 300,
                      height: 60,
                      decoration: BoxDecoration(),
                      child: Align(
                        alignment: AlignmentDirectional(0, 1),
                        child: _buildTitleSection(true),
                      ),
                    ),
                  ),
                  Container(
                    width: 300,
                    decoration: BoxDecoration(),
                    child: Align(
                      alignment: AlignmentDirectional(-1, 0),
                      child: Text(
                        _getDescription(),
                        textAlign: TextAlign.start,
                        maxLines: 3,
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              font: GoogleFonts.ptSans(
                                fontWeight: FontWeight.w200,
                                fontStyle: FlutterFlowTheme.of(
                                  context,
                                ).bodyLarge.fontStyle,
                              ),
                              color: Color(0x99C3C1C1),
                              fontSize: 15,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w200,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 5),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildInfoChip(
                            icon: Icons.live_tv_rounded,
                            text: _getGenre(),
                          ),
                          SizedBox(width: 5),
                          _buildInfoChip(
                            icon: FontAwesomeIcons.globeAfrica,
                            text: _getCountry(),
                          ),
                          SizedBox(width: 5),
                          _buildInfoChip(
                            icon: Icons.calendar_month,
                            text: _getReleaseDate(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildLoadingIndicator(true),
        ],
      ),
    );
  }

  Widget _buildPortraitLoadingScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Background image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              fadeInDuration: Duration(milliseconds: 500),
              fadeOutDuration: Duration(milliseconds: 500),
              imageUrl: widget.episode.longCover.isNotEmpty
                  ? widget.episode.noLongCover == null
                      ? widget.episode.noImage
                      : widget.episode.image
                  : 'https://image.tmdb.org/t/p/original/dLK5snN0BFxPzdbrAqO7B3ilsMh.jpg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment(1, 0),
            ),
          ),
          // Gradient overlay
          Align(
            alignment: AlignmentDirectional(0, 1),
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xF2090909),
                    Color(0xDD090909),
                    Color(0x00090909),
                  ],
                  stops: [0.2, 0.4, 1],
                  begin: AlignmentDirectional(0, 1),
                  end: AlignmentDirectional(0, -1),
                ),
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(30, 0, 30, 60),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/REB-removebg-preview.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          alignment: Alignment(1, -1),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 7),
                      child: Container(
                        width: 300,
                        height: 60,
                        decoration: BoxDecoration(),
                        child: Align(
                          alignment: AlignmentDirectional(0, 1),
                          child: _buildTitleSection(false),
                        ),
                      ),
                    ),
                    Container(
                      width: 300,
                      decoration: BoxDecoration(),
                      child: Align(
                        alignment: AlignmentDirectional(-1, 0),
                        child: Text(
                          _getDescription(),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style:
                              FlutterFlowTheme.of(context).bodyLarge.override(
                                    font: GoogleFonts.ptSans(
                                      fontWeight: FontWeight.w200,
                                      fontStyle: FlutterFlowTheme.of(
                                        context,
                                      ).bodyLarge.fontStyle,
                                    ),
                                    color: Color(0x99C3C1C1),
                                    fontSize: 15,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w200,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 5),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildInfoChip(
                              icon: Icons.live_tv_rounded,
                              text: _getGenre(),
                            ),
                            SizedBox(width: 5),
                            _buildInfoChip(
                              icon: FontAwesomeIcons.globeAfrica,
                              text: _getCountry(),
                            ),
                            SizedBox(width: 5),
                            _buildInfoChip(
                              icon: Icons.calendar_month,
                              text: _getReleaseDate(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildLoadingIndicator(false),
        ],
      ),
    );
  }

  Widget _buildTitleSection(bool isLandscape) {
    final bool showLogo = widget.episode.logo.isNotEmpty;

    if (showLogo) {
      return Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            widget.episode.logo,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
            alignment: isLandscape ? Alignment(-1, 1) : Alignment(0, 1),
          ),
        ).animateOnPageLoad(
          animationsMap[isLandscape
              ? 'imageOnPageLoadAnimation1'
              : 'imageOnPageLoadAnimation2']!,
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 5),
        child: Text(
          _getTitle(),
          textAlign: isLandscape ? TextAlign.start : TextAlign.center,
          maxLines: 2,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.readexPro(
                  fontWeight: FontWeight.bold,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).lineColor,
                fontSize: 30,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
                lineHeight: 0.9,
              ),
          overflow: TextOverflow.ellipsis,
        ).animateOnPageLoad(
          animationsMap[isLandscape
              ? 'textOnPageLoadAnimation1'
              : 'textOnPageLoadAnimation2']!,
        ),
      );
    }
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Align(
      alignment: AlignmentDirectional(0, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            height: 25,
            decoration: BoxDecoration(
              color: Color(0x34333131),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0x1BE0E3E7), width: 1),
            ),
            alignment: AlignmentDirectional(0, 0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16, 0, 20, 1),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                    child: Icon(
                      icon,
                      color: FlutterFlowTheme.of(context).accent4,
                      size: 13,
                    ),
                  ),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyMediumFamily,
                          color: Color(0xB2ECEBEB),
                          fontSize: 13,
                          letterSpacing: 0.0,
                          useGoogleFonts: !FlutterFlowTheme.of(
                            context,
                          ).bodyMediumIsCustom,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(bool isLandscape) {
    return Align(
      alignment: AlignmentDirectional(0, 1),
      child: Container(
        width: 100,
        height: 50,
        decoration: BoxDecoration(),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Divider(
                height: 10,
                thickness: 3,
                color: FlutterFlowTheme.of(context).primary,
              ).animateOnPageLoad(
                animationsMap[isLandscape
                    ? 'dividerOnPageLoadAnimation1'
                    : 'dividerOnPageLoadAnimation2']!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomDownloadControls extends StatefulWidget {
  final VideoPlayerController videoController;
  final String title;
  final String category;
  final bool isMuted;
  final bool isFullScreen;
  final VoidCallback onBack;
  final VoidCallback onSkipIntro;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onShowMoreVideos;
  final bool hasMultipleEpisodes;
  final List<ApiEpisodeData> episodes;
  final int currentEpisodeIndex;
  final ApiEpisodeData? currentEpisode;
  final String currentQuality;
  final Function(String) onQualityChanged;
  final bool showAdCountdown;
  final int adCountdownSeconds;
  final VoidCallback onSkipAd;
  final bool showNextEpisodeCountdown;
  final int nextEpisodeCountdownSeconds;
  final VoidCallback onSkipNextEpisodeCountdown;
  final VoidCallback onPlayNextEpisodeNow;
  final bool isEpisodeLocked;
  final VoidCallback? onSubscribe;
  final bool isSeason;

  const CustomDownloadControls({
    Key? key,
    required this.videoController,
    required this.title,
    required this.category,
    required this.isMuted,
    required this.isFullScreen,
    required this.onBack,
    required this.onSkipIntro,
    required this.onToggleMute,
    required this.onToggleFullscreen,
    required this.onShowMoreVideos,
    required this.hasMultipleEpisodes,
    required this.episodes,
    required this.currentEpisodeIndex,
    required this.currentQuality,
    required this.onQualityChanged,
    required this.showAdCountdown,
    required this.adCountdownSeconds,
    required this.onSkipAd,
    this.currentEpisode,
    required this.showNextEpisodeCountdown,
    required this.nextEpisodeCountdownSeconds,
    required this.onSkipNextEpisodeCountdown,
    required this.onPlayNextEpisodeNow,
    required this.isEpisodeLocked,
    this.onSubscribe,
    required this.isSeason, // Add this parameter
  }) : super(key: key);

  @override
  State<CustomDownloadControls> createState() => _CustomDownloadControlsState();
}

class _CustomDownloadControlsState extends State<CustomDownloadControls>
    with SingleTickerProviderStateMixin {
  bool _isVisible = true;
  Timer? _hideTimer;
  Timer? _progressTimer;
  double _currentProgress = 0.0;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isDragging = false;
  double _dragProgress = 0.0;
  bool _showSkipIntro = true;

  // Slider animation
  late AnimationController _sliderAnimationController;
  late Animation<double> _sliderHeightAnimation;
  double _originalSliderHeight = 5.0;
  double _expandedSliderHeight = 15.0;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
    _startProgressTimer();
    _updateProgress();

    _sliderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _sliderHeightAnimation = Tween<double>(
      begin: _originalSliderHeight,
      end: _expandedSliderHeight,
    ).animate(
      CurvedAnimation(
        parent: _sliderAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _progressTimer?.cancel();
    _sliderAnimationController.dispose();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && widget.videoController.value.isPlaying && !_isDragging) {
        setState(() => _isVisible = false);
      }
    });
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (mounted && _isVisible && !_isDragging) {
        _updateProgress();
        _checkSkipIntroVisibility();
      }
    });
  }

  void _updateProgress() {
    if (!widget.videoController.value.isInitialized) return;

    final position = widget.videoController.value.position;
    final duration = widget.videoController.value.duration;

    if (mounted) {
      setState(() {
        _currentPosition = position;
        _totalDuration = duration;
        if (!_isDragging) {
          _currentProgress = duration.inMilliseconds > 0
              ? position.inMilliseconds / duration.inMilliseconds
              : 0.0;
        }
      });
    }
  }

  bool _shouldShowLockedControls() {
    // For episodes: show locked controls if episode is locked
    if (widget.isSeason) {
      return widget.isEpisodeLocked;
    }
    // For movies: show locked controls if episode is locked AND progress > 50%
    else {
      if (!widget.isEpisodeLocked) return false;

      // Check if progress is above 50%
      if (widget.videoController.value.isInitialized) {
        final totalDuration = widget.videoController.value.duration;
        final currentPosition = widget.videoController.value.position;

        if (totalDuration.inSeconds > 0) {
          final progressPercentage =
              currentPosition.inSeconds / totalDuration.inSeconds * 100;
          return progressPercentage > 50;
        }
      }
      return false;
    }
  }

  void _checkSkipIntroVisibility() {
    if (widget.currentEpisode?.time?.startTime == null ||
        widget.currentEpisode?.time?.startTime == '') return;

    try {
      final skipTime = int.parse(widget.currentEpisode!.time!.startTime);
      final currentPosition = widget.videoController.value.position;

      if (currentPosition.inSeconds >= skipTime && _showSkipIntro) {
        if (mounted) {
          setState(() {
            _showSkipIntro = false;
          });
        }
      } else if (currentPosition.inSeconds < skipTime && !_showSkipIntro) {
        if (mounted) {
          setState(() {
            _showSkipIntro = true;
          });
        }
      }
    } catch (e) {
      print('Error parsing skip time: $e');
    }
  }

  void _showControlsAndStartTimer() {
    if (mounted) {
      setState(() {
        _isVisible = true;
      });
      _startHideTimer();
    }
  }

  void _handleTap() {
    _showControlsAndStartTimer();
  }

  void _togglePlayPause() {
    _showControlsAndStartTimer();
    final isPlaying = widget.videoController.value.isPlaying;
    setState(() {
      isPlaying
          ? widget.videoController.pause()
          : widget.videoController.play();
    });
  }

  void _seekForward() {
    _showControlsAndStartTimer();
    final pos = widget.videoController.value.position;
    final dur = widget.videoController.value.duration;
    final target = pos + const Duration(seconds: 30);
    widget.videoController.seekTo(target < dur ? target : dur);
  }

  void _seekBackward() {
    _showControlsAndStartTimer();
    final pos = widget.videoController.value.position;
    final target = pos - const Duration(seconds: 30);
    widget.videoController.seekTo(
      target > Duration.zero ? target : Duration.zero,
    );
  }

  Future<void> _onSeekBarChangedStart(double value) async {
    await HapticFeedback.selectionClick();
    _sliderAnimationController.forward();
    if (mounted) {
      setState(() {
        _isDragging = true;
        _dragProgress = value;
      });
    }
  }

  Future<void> _onSeekBarChangedUpdate(double value) async {
    await HapticFeedback.selectionClick();
    if (mounted) {
      setState(() {
        _dragProgress = value;
      });
    }
  }

  Future<void> _onSeekBarChangedEnd(double value) async {
    await HapticFeedback.lightImpact();
    _sliderAnimationController.reverse();
    final duration = widget.videoController.value.duration;
    final position = Duration(
      milliseconds: (duration.inMilliseconds * value).round(),
    );
    widget.videoController.seekTo(position);

    if (mounted) {
      setState(() {
        _isDragging = false;
        _currentProgress = value;
      });
    }
    _showControlsAndStartTimer();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours == '00' ? '$minutes:$seconds' : '$hours:$minutes:$seconds';
  }

  Widget _buildNextEpisodeCover() {
    int nextEpisodeIndex = widget.currentEpisodeIndex + 1;

    if (nextEpisodeIndex >= widget.episodes.length) {
      nextEpisodeIndex = widget.episodes.length - 1;
    }

    final nextEpisode = widget.episodes[nextEpisodeIndex];

    if (nextEpisode.longCover != null && nextEpisode.longCover!.isNotEmpty) {
      return Image.network(
        nextEpisode.longCover!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderCover();
        },
      );
    } else {
      return _buildPlaceholderCover();
    }
  }

  Widget _buildPlaceholderCover() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(Icons.movie, color: Colors.grey[500], size: 30),
    );
  }

  Widget _buildSkipIntroButton() {
    return AnimatedOpacity(
      opacity: _showSkipIntro ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      onEnd: () {
        if (!_showSkipIntro) {
          setState(() {});
        }
      },
      child: AnimatedScale(
        scale: _showSkipIntro ? 1.0 : 0.8,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: GestureDetector(
          onTap: _showSkipIntro
              ? () async {
                  await HapticFeedback.lightImpact();
                  _showControlsAndStartTimer();
                  widget.onSkipIntro();
                }
              : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                width: 150,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0x32818181),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0x40E0E3E7), width: 1),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getSkipIntroText(),
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: FlutterFlowTheme.of(
                                context,
                              ).titleSmallFamily,
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                              useGoogleFonts: !FlutterFlowTheme.of(
                                context,
                              ).titleSmallIsCustom,
                            ),
                      ),
                      Icon(
                        Icons.fast_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdCountdownButton() {
    return AnimatedOpacity(
      opacity: widget.showAdCountdown ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: AnimatedScale(
        scale: widget.showAdCountdown ? 1.0 : 0.8,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              width: 150,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0x32818181),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0x40E0E3E7), width: 1),
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: 150 * (widget.adCountdownSeconds / 10),
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0x34E0E3E7),
                      borderRadius: BorderRadius.only(
                        bottomLeft: const Radius.circular(20),
                        bottomRight: widget.adCountdownSeconds >= 10
                            ? const Radius.circular(20)
                            : const Radius.circular(0),
                        topLeft: const Radius.circular(20),
                        topRight: widget.adCountdownSeconds >= 10
                            ? const Radius.circular(20)
                            : const Radius.circular(0),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "${Localizations.localeOf(context).languageCode == 'en' ? 'Ad in' : 'Kwamamaza'} ${widget.adCountdownSeconds}s",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitSkipIntroButton() {
    return AnimatedOpacity(
      opacity: _showSkipIntro ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      onEnd: () {
        if (!_showSkipIntro) {
          setState(() {});
        }
      },
      child: AnimatedScale(
        scale: _showSkipIntro ? 1.0 : 0.8,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: GestureDetector(
          onTap: _showSkipIntro
              ? () async {
                  await HapticFeedback.lightImpact();
                  _showControlsAndStartTimer();
                  widget.onSkipIntro();
                }
              : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                width: 230,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0x32818181),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0x40E0E3E7), width: 1),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getSkipIntroText(),
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: FlutterFlowTheme.of(
                                context,
                              ).titleSmallFamily,
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                              useGoogleFonts: !FlutterFlowTheme.of(
                                context,
                              ).titleSmallIsCustom,
                            ),
                      ),
                      Icon(
                        Icons.fast_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitAdCountdownButton() {
    return AnimatedOpacity(
      opacity: widget.showAdCountdown ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: AnimatedScale(
        scale: widget.showAdCountdown ? 1.0 : 0.8,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              width: 230,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0x32818181),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0x40E0E3E7), width: 1),
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: 230 * (widget.adCountdownSeconds / 10),
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0x34E0E3E7),
                      borderRadius: BorderRadius.only(
                        bottomLeft: const Radius.circular(20),
                        bottomRight: widget.adCountdownSeconds >= 10
                            ? const Radius.circular(20)
                            : const Radius.circular(0),
                        topLeft: const Radius.circular(20),
                        topRight: widget.adCountdownSeconds >= 10
                            ? const Radius.circular(20)
                            : const Radius.circular(0),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "${Localizations.localeOf(context).languageCode == 'en' ? 'Ad in' : 'Kwamamaza'} ${widget.adCountdownSeconds}s",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLandscapeAdCountdownButton() {
    return SafeArea(
      top: false,
      bottom: false,
      left: true,
      right: false,
      child: AnimatedOpacity(
        opacity: widget.showAdCountdown ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: AnimatedScale(
          scale: widget.showAdCountdown ? 1.0 : 0.8,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0x32818181),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0x40E0E3E7), width: 1),
                ),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: 200 * (widget.adCountdownSeconds / 10),
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0x34E0E3E7),
                        borderRadius: BorderRadius.only(
                          bottomLeft: const Radius.circular(20),
                          bottomRight: widget.adCountdownSeconds >= 10
                              ? const Radius.circular(20)
                              : const Radius.circular(0),
                          topLeft: const Radius.circular(20),
                          topRight: widget.adCountdownSeconds >= 10
                              ? const Radius.circular(20)
                              : const Radius.circular(0),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "${Localizations.localeOf(context).languageCode == 'en' ? 'Ad in' : 'Kwamamaza'} ${widget.adCountdownSeconds}s",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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

  Widget _buildLandscapeSkipIntroButton() {
    return SafeArea(
      top: false,
      bottom: false,
      left: true,
      right: false,
      child: AnimatedOpacity(
        opacity: _showSkipIntro ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        onEnd: () {
          if (!_showSkipIntro) {
            setState(() {});
          }
        },
        child: AnimatedScale(
          scale: _showSkipIntro ? 1.0 : 0.8,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: GestureDetector(
            onTap: _showSkipIntro
                ? () async {
                    await HapticFeedback.lightImpact();
                    _showControlsAndStartTimer();
                    widget.onSkipIntro();
                  }
                : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0x32818181),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Color(0x40E0E3E7), width: 1),
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getSkipIntroText(),
                          style:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: FlutterFlowTheme.of(
                                      context,
                                    ).titleSmallFamily,
                                    color: Colors.white,
                                    fontSize: 15,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    useGoogleFonts: !FlutterFlowTheme.of(
                                      context,
                                    ).titleSmallIsCustom,
                                  ),
                        ),
                        Icon(
                          Icons.fast_forward_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitNextEpisodeButton() {
    return AnimatedOpacity(
      opacity: widget.showNextEpisodeCountdown ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: AnimatedScale(
        scale: widget.showNextEpisodeCountdown ? 1.0 : 0.8,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: GestureDetector(
          onTap: widget.onPlayNextEpisodeNow,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                width: 230,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0x32818181),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0x40E0E3E7), width: 1),
                ),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: 230 * (widget.nextEpisodeCountdownSeconds / 10),
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0x341FDF67),
                        borderRadius: BorderRadius.only(
                          bottomLeft: const Radius.circular(20),
                          bottomRight: widget.nextEpisodeCountdownSeconds >= 10
                              ? const Radius.circular(20)
                              : const Radius.circular(0),
                          topLeft: const Radius.circular(20),
                          topRight: widget.nextEpisodeCountdownSeconds >= 10
                              ? const Radius.circular(20)
                              : const Radius.circular(0),
                        ),
                      ),
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            Localizations.localeOf(context).languageCode == 'en'
                                ? 'Next Episode'
                                : 'Indi Episode',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.skip_next_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
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

  Widget _buildLandscapeNextEpisodeButton() {
    return AnimatedOpacity(
      opacity: widget.showNextEpisodeCountdown ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: AnimatedScale(
        scale: widget.showNextEpisodeCountdown ? 1.0 : 0.8,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: GestureDetector(
          onTap: widget.onPlayNextEpisodeNow,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0x32818181),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0x40E0E3E7), width: 1),
                ),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: 200 * (widget.nextEpisodeCountdownSeconds / 10),
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0x341FDF67),
                        borderRadius: BorderRadius.only(
                          bottomLeft: const Radius.circular(20),
                          bottomRight: widget.nextEpisodeCountdownSeconds >= 10
                              ? const Radius.circular(20)
                              : const Radius.circular(0),
                          topLeft: const Radius.circular(20),
                          topRight: widget.nextEpisodeCountdownSeconds >= 10
                              ? const Radius.circular(20)
                              : const Radius.circular(0),
                        ),
                      ),
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            Localizations.localeOf(context).languageCode == 'en'
                                ? 'Next Episode'
                                : 'Indi Episode',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.skip_next_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
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

  // Portrait mode buttons (top center)
  Widget _buildPortraitTopButtons() {
    if (widget.showNextEpisodeCountdown) {
      return _buildPortraitNextEpisodeButton();
    } else if (widget.showAdCountdown) {
      return _buildPortraitAdCountdownButton();
    } else {
      return _buildPortraitSkipIntroButton();
    }
  }

  String _getSkipIntroText() {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'en' ? 'Skip Intro' : 'Taruka Indirimbo';
  }

  // Build the locked episode controls (only "Click To Pay" button)
  Widget _buildLockedEpisodeControls(bool isFullScreenMode) {
    final buttonWidth = isFullScreenMode ? 200.0 : double.infinity;
    final buttonHeight = isFullScreenMode ? 50.0 : 60.0;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: isFullScreenMode ? 120 : 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.9), Colors.transparent],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // "Click To Pay" button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isFullScreenMode ? 0 : 16,
                vertical: 16,
              ),
              child: GestureDetector(
                onTap: () {
                  widget.onSubscribe?.call();
                },
                child: Container(
                  width: buttonWidth,
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    color: Color(0xCC1FDF67),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0x67FFFFFF), width: 1),
                  ),
                  child: Center(
                    child: Text(
                      Localizations.localeOf(context).languageCode == 'en'
                          ? 'Click To Pay'
                          : 'Kwishyura',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: FlutterFlowTheme.of(
                              context,
                            ).bodyMediumFamily,
                            color:
                                FlutterFlowTheme.of(context).primaryBackground,
                            fontSize: isFullScreenMode ? 15 : 18,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            useGoogleFonts: !FlutterFlowTheme.of(
                              context,
                            ).bodyMediumIsCustom,
                          ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: isFullScreenMode ? 20 : 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.videoController.value.isInitialized) {
      return const SizedBox.shrink();
    }

    // Check if should show locked controls
    final shouldShowLockedControls = _shouldShowLockedControls();

    // If episode is locked, show only the "Click To Pay" button
    if (shouldShowLockedControls) {
      final isFullScreenMode = widget.isFullScreen;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: Container(
          color: Colors.transparent,
          child: AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Stack(
              children: [
                // Top controls (back button and fullscreen only)
                Positioned(
                  top: !widget.isFullScreen ? 30 : 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: isFullScreenMode ? 50 : 20),
                        // Back button
                        Row(
                          children: [
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                              child: GestureDetector(
                                onTap: () async {
                                  await HapticFeedback.lightImpact();
                                  widget.onBack();
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Color(0x32818181),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Color(0x40E0E3E7),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.chevron_left_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                        Spacer(),
                        // Fullscreen button
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Color(0x32818181),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Color(0x40E0E3E7),
                                      width: 1,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      widget.isFullScreen
                                          ? Icons.fullscreen_exit
                                          : Icons.fullscreen,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () async {
                                      await HapticFeedback.lightImpact();
                                      _showControlsAndStartTimer();
                                      widget.onToggleFullscreen();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: isFullScreenMode ? 50 : 20),
                      ],
                    ),
                  ),
                ),
                // Locked episode controls (only "Click To Pay" button)
                _buildLockedEpisodeControls(isFullScreenMode),
              ],
            ),
          ),
        ),
      );
    }

    // Rest of existing build method for non-locked episodes
    final value = widget.videoController.value;
    final progress = _isDragging ? _dragProgress : _currentProgress;
    final displayPosition = _isDragging
        ? Duration(
            milliseconds:
                (_totalDuration.inMilliseconds * _dragProgress).round(),
          )
        : _currentPosition;

    final screenWidth = MediaQuery.of(context).size.width;
    final showMuteButton = screenWidth > 450;

    final isMovie = widget.category == "Filme";
    final moreText = Localizations.localeOf(context).languageCode == 'en'
        ? (isMovie ? 'More' : 'More')
        : (isMovie ? 'Izindi' : 'Izindi');
    final videoText = Localizations.localeOf(context).languageCode == 'en'
        ? 'Episode'
        : 'Filme';

    final bool isFullScreenMode = widget.isFullScreen;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: Container(
        color: Colors.transparent,
        child: AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Stack(
            children: [
              // Top controls (back button, quality selector, mute, fullscreen)
              Positioned(
                top: !widget.isFullScreen ? 30 : 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // ← Starting space
                      SizedBox(width: isFullScreenMode ? 50 : 20),

                      // Back button
                      Row(
                        children: [
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                            child: GestureDetector(
                              onTap: () async {
                                await HapticFeedback.lightImpact();
                                widget.onBack();
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(0x32818181),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Color(0x40E0E3E7),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.chevron_left_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),

                      // Quality selector in center
                      Expanded(
                        child: Center(
                          child: widget.currentEpisode != null
                              ? QualitySelector(
                                  currentEpisode: widget.currentEpisode!,
                                  currentQuality: widget.currentQuality,
                                  onQualityChanged: widget.onQualityChanged,
                                )
                              : Container(),
                        ),
                      ),

                      // Mute and fullscreen buttons
                      Row(
                        children: [
                          if (showMuteButton)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Color(0x32818181),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Color(0x40E0E3E7),
                                      width: 1,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      widget.isMuted
                                          ? Icons.volume_off
                                          : Icons.volume_up,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () async {
                                      await HapticFeedback.lightImpact();
                                      _showControlsAndStartTimer();
                                      widget.onToggleMute();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(width: 10),
                          // Fullscreen button
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(0x32818181),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Color(0x40E0E3E7),
                                    width: 1,
                                  ),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    widget.isFullScreen
                                        ? Icons.fullscreen_exit
                                        : Icons.fullscreen,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    await HapticFeedback.lightImpact();
                                    _showControlsAndStartTimer();
                                    widget.onToggleFullscreen();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ← End space
                      SizedBox(width: isFullScreenMode ? 50 : 20),
                    ],
                  ),
                ),
              ),

              // Skip Intro/Ad Countdown buttons - ONLY IN PORTRAIT MODE at top center
              if (!isFullScreenMode)
                Positioned(
                  top: !widget.isFullScreen ? 110 : 80,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    child: Center(child: _buildPortraitTopButtons()),
                  ),
                ),

              // Center play controls
              Positioned.fill(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedControlButton(
                        icon: Icons.replay_30,
                        onTap: _seekBackward,
                        size: 50,
                      ),
                      SizedBox(width: 32),
                      AnimatedControlButton(
                        icon: value.isPlaying ? Icons.pause : Icons.play_arrow,
                        onTap: _togglePlayPause,
                        size: 70,
                      ),
                      SizedBox(width: 32),
                      AnimatedControlButton(
                        icon: Icons.forward_30,
                        onTap: _seekForward,
                        size: 50,
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: isFullScreenMode
                      ? 160
                      : 280, // Fixed height to prevent shifting
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Top section - Different layout for portrait vs landscape
                      Container(
                        height: 90, // Fixed height for top section
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left side - Skip intro/Ad countdown/Next episode buttons
                              if (widget.showNextEpisodeCountdown &&
                                  isFullScreenMode)
                                _buildLandscapeNextEpisodeButton()
                              else if (widget.showAdCountdown &&
                                  isFullScreenMode)
                                _buildLandscapeAdCountdownButton()
                              else if (_showSkipIntro && isFullScreenMode)
                                _buildLandscapeSkipIntroButton()
                              else
                                Container(
                                  width: 1, // Maintain layout spacing
                                  height: 50,
                                ),

                              // Right side - More videos card (ONLY in landscape mode)
                              if (widget.hasMultipleEpisodes &&
                                  isFullScreenMode)
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                    0,
                                    0,
                                    40,
                                    0,
                                  ),
                                  child: AnimatedMoreVideosCard(
                                    onTap: widget.onShowMoreVideos,
                                    moreText: moreText,
                                    videoText: videoText,
                                    coverImage: _buildNextEpisodeCover(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Portrait mode More Videos card (ONLY in portrait mode)
                      if (!isFullScreenMode && widget.hasMultipleEpisodes)
                        Container(
                          height: 90,
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              16,
                              8,
                              16,
                              8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedMoreVideosCard(
                                  onTap: widget.onShowMoreVideos,
                                  moreText: moreText,
                                  videoText: videoText,
                                  coverImage: _buildNextEpisodeCover(),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Progress slider
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isFullScreenMode ? 40 : 8,
                        ),
                        child: AnimatedBuilder(
                          animation: _sliderHeightAnimation,
                          builder: (context, child) {
                            return SliderTheme(
                              data: SliderThemeData(
                                trackHeight: _sliderHeightAnimation.value,
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: _isDragging ? 10 : 7,
                                ),
                                overlayShape: RoundSliderOverlayShape(
                                  overlayRadius: _isDragging ? 16 : 12,
                                ),
                                activeTrackColor: FlutterFlowTheme.of(
                                  context,
                                ).primary,
                                inactiveTrackColor: Colors.white38,
                                thumbColor: Colors.white,
                                overlayColor: Colors.white.withOpacity(0.2),
                              ),
                              child: Slider(
                                value: progress.clamp(0.0, 1.0),
                                onChangeStart: _onSeekBarChangedStart,
                                onChangeEnd: _onSeekBarChangedEnd,
                                onChanged: _onSeekBarChangedUpdate,
                              ),
                            );
                          },
                        ),
                      ),

                      // Video info and time
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isFullScreenMode ? 50 : 18,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    widget.category,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${_formatDuration(displayPosition)} / ${_formatDuration(_totalDuration)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({
    super.key,
    this.width,
    this.height,
    this.customCallBack,
    this.movieId,
    this.userId,
    this.language,
  });

  final double? width;
  final double? height;
  final Future Function(dynamic action)? customCallBack;
  final String? movieId;
  final String? userId;
  final String? language;

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  PageController _seasonPageController = PageController();
  PageController _bottomSheetPageController = PageController();
  bool _isSeasonButtonAnimating = false;
  double _seasonButtonScale = 1.0;
  bool _isLoading = true;
  bool _isDataLoading = true;
  String? _error;
  int _currentSeasonIndex = 0;
  int _currentEpisodeIndex = 0;
  bool _isMuted = false;
  bool _isFullScreen = false;
  bool _isBottomSheetOpen = false;
  String _currentQuality = "MID";
  bool _isSystemFallback = false;
  bool _isInitialLoad = true;

  // track locked content state
  bool _showLockedContent = false;
  String? _lockedAdUrl;

  // Ad tracking variables
  Map<String, List<bool>> _watchedAds = {};
  bool _showAd = false;
  bool _wasPlayingBeforeAd = false;
  Duration _positionBeforeAd = Duration.zero;
  Timer? _adTriggerTimer;
  Timer? _adCountdownTimer;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _seasonScrollController = ScrollController();
  bool _isAdBottomSheetOpen = false;

  // Ad tracking variables
  int _currentAdIndex = 0;
  bool _showAdCountdown = false;
  int _adCountdownSeconds = 10;
  List<int> _adIntervals = [20, 50, 70];
  int _nextAdIntervalIndex = 0;

  // Auto-next episode variables
  bool _showNextEpisodeCountdown = false;
  int _nextEpisodeCountdownSeconds = 10;
  Timer? _nextEpisodeCountdownTimer;
  bool _isNextEpisodeTriggered = false;

  // Add loading screen state
  bool _showLoadingScreen = true;
  Timer? _loadingScreenTimer;

  CinemaDataResponse? _cinemaData;
  List<ApiEpisodeData> _currentEpisodes = [];
  ApiEpisodeData? _currentPlayingEpisode;

  @override
  void initState() {
    super.initState();
    _isInitialLoad = true;
    _loadUserQualityPreference();
    _fetchCinemaData();
    _setPortraitMode();
    // Start loading screen timer
    _startLoadingScreenTimer();
  }

  @override
  void dispose() {
    print('🛑 VideoPlayer dispose called - cleaning up timers');

    _loadingScreenTimer?.cancel();
    _progressSaveTimer?.cancel();
    _videoPlayerController?.removeListener(_videoListener);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _scrollController.dispose();
    _adTriggerTimer?.cancel();
    _adCountdownTimer?.cancel();
    _nextEpisodeCountdownTimer?.cancel();
    _seasonPageController.dispose();
    _bottomSheetPageController.dispose();
    _seasonScrollController.dispose();
    _setPortraitMode();

    _videoPlayerController?.pause();

    super.dispose();
  }

  void _startLoadingScreenTimer() {
    _loadingScreenTimer = Timer(Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showLoadingScreen = false;
        });
      }
    });
  }

  void _loadUserQualityPreference() {
    final userQuality = FFAppState().userQualityChoice ?? "MID";
    setState(() {
      _currentQuality = userQuality;
      _isSystemFallback = false;
    });
  }

  bool _isQualityAvailable(String quality) {
    final url = _getQualityUrl(quality);
    return url.isNotEmpty && url.startsWith('http') && url.length > 10;
  }

  String _getFallbackQuality(String preferredQuality) {
    final qualityOrder = ["HD", "MID", "LOW"];
    final startIndex = qualityOrder.indexOf(preferredQuality);
    if (startIndex == -1) return "MID";

    for (int i = startIndex; i < qualityOrder.length; i++) {
      if (_isQualityAvailable(qualityOrder[i])) {
        return qualityOrder[i];
      }
    }

    for (int i = startIndex - 1; i >= 0; i--) {
      if (_isQualityAvailable(qualityOrder[i])) {
        return qualityOrder[i];
      }
    }

    return "MID";
  }

  String _getQualityUrl(String quality) {
    if (_currentEpisodes.isEmpty ||
        _currentEpisodeIndex >= _currentEpisodes.length) {
      return '';
    }

    final currentEpisode = _currentEpisodes[_currentEpisodeIndex];
    switch (quality) {
      case "HD":
        return currentEpisode.video?.hdVideo ?? '';
      case "MID":
        return currentEpisode.video?.midVideo ?? '';
      case "LOW":
        return currentEpisode.video?.lowVideo ?? '';
      default:
        return '';
    }
  }

  void _showNoQualityAvailableError() {
    setState(() {
      _error = "No video qualities available for this content.";
      _isLoading = false;
    });
  }

  bool _loadEpisodeFromContinueWatching() {
    try {
      final continueWatchingList = FFAppState().continueWatchingMovies;

      print('🔍 LOOKING FOR CONTINUE WATCHING: movieId=${widget.movieId}');

      for (int i = 0; i < continueWatchingList.length; i++) {
        final continueEpisode = continueWatchingList[i];

        if (continueEpisode.movieId == widget.movieId) {
          final continueSeasonIndex =
              continueEpisode.position?.seasonIndex ?? 0;
          final continueEpisodeIndex =
              continueEpisode.position?.episodeIndex ?? 0;
          final continueEpisodeId = continueEpisode.episodeId;
          final progressSeconds =
              continueEpisode.continueWatching?.inMinutes ?? 0;

          print(
            '   Found in continue: season=$continueSeasonIndex, episode=$continueEpisodeIndex, episodeId=$continueEpisodeId, progress=${progressSeconds}s',
          );

          if (continueSeasonIndex < _cinemaData!.data.episodes.length) {
            final seasonEpisodes =
                _cinemaData!.data.episodes[continueSeasonIndex];

            if (continueEpisodeIndex < seasonEpisodes.length) {
              final apiEpisode = seasonEpisodes[continueEpisodeIndex];

              if (apiEpisode.episodeId == continueEpisodeId) {
                print(
                  '✅ EPISODE MATCH CONFIRMED: Loading season $continueSeasonIndex, episode $continueEpisodeIndex',
                );

                setState(() {
                  _currentSeasonIndex = continueSeasonIndex;
                  _currentEpisodeIndex = continueEpisodeIndex;
                });

                _updateCurrentEpisodes();
                _moveMovieToTopInContinueWatching();

                return true;
              } else {
                print(
                  '❌ EpisodeId mismatch: continue=${continueEpisodeId}, api=${apiEpisode.episodeId}',
                );
              }
            } else {
              print(
                '❌ Episode index $continueEpisodeIndex not found in season $continueSeasonIndex',
              );
            }
          } else {
            print('❌ Season index $continueSeasonIndex not found');
          }
        }
      }

      print(
        '❌ No valid continue watching found, starting from season 0, episode 0',
      );
      return false;
    } catch (e) {
      print('Error loading episode from continue watching: $e');
      return false;
    }
  }

  bool _isAdCheckSuppressed = false;

  void _startAdCountdown() {
    // Check if episode has adStatus enabled
    if (_currentEpisodes.isEmpty ||
        _currentEpisodeIndex >= _currentEpisodes.length ||
        !_currentEpisodes[_currentEpisodeIndex].adstatus) {
      return;
    }

    // Check if there are available ads (excluding last one)
    final availableAds = _cinemaData != null && _cinemaData!.ads.length > 1
        ? _cinemaData!.ads.sublist(0, _cinemaData!.ads.length - 1)
        : [];

    if (availableAds.isEmpty) {
      print('⏩ No ads available for countdown');
      return;
    }

    if (_showAdCountdown) return;

    setState(() {
      _showAdCountdown = true;
      _adCountdownSeconds = 10;
    });

    _adCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _adCountdownSeconds--;
      });

      if (_adCountdownSeconds <= 0) {
        timer.cancel();
        _triggerAd();
      }
    });
  }

  void _checkAdTrigger() {
    // Check if episode has adStatus enabled and is not locked
    if (_currentEpisodes.isEmpty ||
        _currentEpisodeIndex >= _currentEpisodes.length ||
        !_currentEpisodes[_currentEpisodeIndex].adstatus ||
        _currentEpisodes[_currentEpisodeIndex].locked) {
      // Add locked check
      return;
    }

    // For locked movies (isSeason = false), check if progress > 50%
    if (!_cinemaData!.isSeason &&
        _currentEpisodes.isNotEmpty &&
        _currentEpisodeIndex < _currentEpisodes.length &&
        _currentEpisodes[_currentEpisodeIndex].locked) {
      final currentEpisode = _currentEpisodes[_currentEpisodeIndex];
      final String episodeKey =
          '${currentEpisode.movieId}_${currentEpisode.episodeId}';

      if (_videoPlayerController != null &&
          _videoPlayerController!.value.isInitialized) {
        final totalDuration = _videoPlayerController!.value.duration;
        final currentPosition = _videoPlayerController!.value.position;

        if (totalDuration.inSeconds > 0) {
          final progressPercentage =
              currentPosition.inSeconds / totalDuration.inSeconds * 100;

          if (progressPercentage > 50) {
            // Mark all ads as completed for locked movies after 50%
            if (!_watchedAds.containsKey(episodeKey)) {
              _watchedAds[episodeKey] = List.filled(3, false);
            }

            for (int i = 0; i < 3; i++) {
              if (!_watchedAds[episodeKey]![i]) {
                _watchedAds[episodeKey]![i] = true;
                print('✅ Marked ad interval $i as completed for locked movie');
              }
            }
            _nextAdIntervalIndex = 3;
            _cancelAdCountdown();
            return;
          }
        }
      }
    }

    if (_isAdCheckSuppressed ||
        _cinemaData == null ||
        _cinemaData!.ads.isEmpty ||
        _showAd ||
        _isAdBottomSheetOpen ||
        _currentEpisodes.isEmpty ||
        _videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized) {
      return;
    }

    final currentEpisode = _currentEpisodes[_currentEpisodeIndex];
    final String episodeKey =
        '${currentEpisode.movieId}_${currentEpisode.episodeId}';

    if (!_watchedAds.containsKey(episodeKey)) {
      _watchedAds[episodeKey] = List.filled(3, false);
    }

    final totalDuration = _videoPlayerController!.value.duration;
    final currentPosition = _videoPlayerController!.value.position;

    if (totalDuration.inSeconds > 0) {
      final progressPercentage =
          currentPosition.inSeconds / totalDuration.inSeconds * 100;

      if (_nextAdIntervalIndex < 3) {
        final nextAdPercentage = _adIntervals[_nextAdIntervalIndex];
        final adRegionStart = nextAdPercentage;
        final adRegionEnd =
            _nextAdIntervalIndex == 2 ? 100 : nextAdPercentage + 29;

        if (progressPercentage >= adRegionStart &&
            progressPercentage <= adRegionEnd &&
            !_watchedAds[episodeKey]![_nextAdIntervalIndex]) {
          if (_nextAdIntervalIndex == 2) {
            final timeRemaining = totalDuration - currentPosition;
            if (timeRemaining.inSeconds < 30) {
              print('⏩ Skipping post-ad: less than 30 seconds remaining');
              _watchedAds[episodeKey]![2] = true;
              _nextAdIntervalIndex = 3;
              _cancelAdCountdown();
              return;
            }
          }

          if (!_showAdCountdown) {
            _startAdCountdown();
          }
        } else if (_showAdCountdown &&
            (progressPercentage < adRegionStart ||
                progressPercentage > adRegionEnd)) {
          _cancelAdCountdown();
        }
      }

      _checkSeekBackIntoAdRegions(progressPercentage, episodeKey);
    }
  }

  void _cancelAdCountdown() {
    _adCountdownTimer?.cancel();
    setState(() {
      _showAdCountdown = false;
      _adCountdownSeconds = 10;
    });
  }

  void _triggerAd() {
    // Check if episode has adStatus enabled
    if (_currentEpisodes.isEmpty ||
        _currentEpisodeIndex >= _currentEpisodes.length ||
        !_currentEpisodes[_currentEpisodeIndex].adstatus) {
      print('⏩ Ad skipped: episode adStatus is false');
      _skipAd();
      return;
    }

    if (_cinemaData == null ||
        _cinemaData!.ads.isEmpty ||
        _showAd ||
        _isAdBottomSheetOpen) {
      return;
    }

    final currentEpisode = _currentEpisodes[_currentEpisodeIndex];
    final String episodeKey =
        '${currentEpisode.movieId}_${currentEpisode.episodeId}';

    // Check if this is the post-ad interval and skip if less than 30 seconds remaining
    if (_nextAdIntervalIndex == 2) {
      if (_videoPlayerController != null &&
          _videoPlayerController!.value.isInitialized) {
        final totalDuration = _videoPlayerController!.value.duration;
        final currentPosition = _videoPlayerController!.value.position;
        if (totalDuration.inSeconds > 0) {
          final timeRemaining = totalDuration - currentPosition;
          if (timeRemaining.inSeconds < 30) {
            print('⏩ Skipping post-ad: less than 30 seconds remaining');
            _watchedAds[episodeKey]![2] = true;
            _nextAdIntervalIndex = 3;
            _cancelAdCountdown();
            return;
          }
        }
      }
    }

    // Get available ads (all except the last one)
    final availableAds = _cinemaData!.ads.length > 1
        ? _cinemaData!.ads.sublist(0, _cinemaData!.ads.length - 1)
        : [];

    // If no ads available after excluding the last one, skip ad
    if (availableAds.isEmpty) {
      print('⏩ No ads available (excluding last ad)');
      _skipAd();
      return;
    }

    // Select ad from available ads using round-robin
    final totalAds = availableAds.length;
    final adIndex =
        (_currentEpisodeIndex * 3 + _nextAdIntervalIndex) % totalAds;
    final adUrl = availableAds[adIndex];

    print(
      '✅✅ Showing ad $adIndex (interval $_nextAdIntervalIndex) for episode $_currentEpisodeIndex',
    );
    print('📺 Ad URL: $adUrl');
    print('🎬 Episode adStatus: ${currentEpisode.adstatus}');

    _wasPlayingBeforeAd = _videoPlayerController!.value.isPlaying;
    _positionBeforeAd = _videoPlayerController!.value.position;

    _watchedAds[episodeKey]![_nextAdIntervalIndex] = true;

    _videoPlayerController!.pause();

    setState(() {
      _showAd = true;
      _isAdBottomSheetOpen = true;
      _showAdCountdown = false;
    });

    _showAdBottomSheet([adUrl]);
  }

  void _handleAdAction(String action) {
    switch (action) {
      case "back":
        _handleBackButton();
        break;

      case "subscribe":
        widget.customCallBack?.call({
          "action": "subscribeButton",
          "data": widget.movieId,
        });
        break;

      case "skipAd":
        _onAdComplete();
        break;
    }
  }

  void _showAdBottomSheet(List<String> adUrls) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black87,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: AdPlayer(
          adUrls: adUrls,
          onAction: (String action) {
            Navigator.of(context).pop();
            _handleAdAction(action);
          },
          movieId: widget.movieId ?? '',
          customCallBack: widget.customCallBack,
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _isAdBottomSheetOpen = false;
        });
      }
    });
  }

  void _onAdComplete() {
    _nextAdIntervalIndex++;

    setState(() {
      _showAd = false;
      _isAdBottomSheetOpen = false;
    });

    _videoPlayerController!.seekTo(_positionBeforeAd);

    if (_wasPlayingBeforeAd) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted && _videoPlayerController != null) {
          _videoPlayerController!.play();
        }
      });
    }
  }

  void _skipAd() {
    _cancelAdCountdown();
    _nextAdIntervalIndex++;

    // If we're skipping because adStatus is false, mark all ads as watched
    if (_currentEpisodes.isNotEmpty &&
        _currentEpisodeIndex < _currentEpisodes.length &&
        !_currentEpisodes[_currentEpisodeIndex].adstatus) {
      final currentEpisode = _currentEpisodes[_currentEpisodeIndex];
      final String episodeKey =
          '${currentEpisode.movieId}_${currentEpisode.episodeId}';

      if (_watchedAds.containsKey(episodeKey)) {
        for (int i = 0; i < 3; i++) {
          _watchedAds[episodeKey]![i] = true;
        }
      }
      _nextAdIntervalIndex = 3;
    }
  }

  bool _shouldShowAds() {
    return _currentEpisodes.isNotEmpty &&
        _currentEpisodeIndex < _currentEpisodes.length &&
        _currentEpisodes[_currentEpisodeIndex].adstatus &&
        _cinemaData != null &&
        _cinemaData!.ads.length > 1; // At least 2 ads (we exclude the last one)
  }

  void _handleSubscribe() {
    widget.customCallBack?.call({
      "action": "subscribeButton",
      "data": widget.movieId,
    });
  }

  // AUTO-NEXT EPISODE METHODS
  void _checkAutoNextEpisode() {
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized ||
        _currentEpisodes.isEmpty ||
        _isNextEpisodeTriggered ||
        _showAd ||
        _isAdBottomSheetOpen) {
      return;
    }

    final currentEpisode = _currentEpisodes[_currentEpisodeIndex];
    final totalDuration = _videoPlayerController!.value.duration;
    final currentPosition = _videoPlayerController!.value.position;

    if (totalDuration.inSeconds == 0) return;

    // Parse end time from episode data
    int endTimeSeconds = 0;
    try {
      endTimeSeconds = currentEpisode.time?.endTime == '' ||
              currentEpisode.time?.endTime == '0'
          ? 0
          : int.parse(currentEpisode.time?.endTime ?? '0');
    } catch (e) {
      print('Error parsing end time: $e');
      return;
    }

    final double totalVideoSeconds = totalDuration.inSeconds.toDouble();
    final double currentPercentage =
        (currentPosition.inSeconds / totalVideoSeconds) * 100;

    // Check if video has ended/stopped (current position >= duration)
    final bool hasVideoEnded = currentPosition >= totalDuration;

    bool shouldShowCountdown = false;
    String triggerReason = '';

    if (endTimeSeconds == 0) {
      // Case 1: endTime is empty or "0" - trigger when video has ended
      if (hasVideoEnded) {
        shouldShowCountdown = true;
        triggerReason = 'Video ended (no endTime provided)';
      }
    } else {
      // Case 2: endTime has a value
      final double endTimePercentage =
          (endTimeSeconds / totalVideoSeconds) * 100;

      if (endTimePercentage >= 70) {
        // Case 2a: endTime is at least 70% of total - trigger countdown when reached endTime
        final Duration endTimePosition = Duration(seconds: endTimeSeconds);
        final bool hasReachedEndTime = currentPosition >= endTimePosition;

        if (hasReachedEndTime && !_showNextEpisodeCountdown) {
          shouldShowCountdown = true;
          triggerReason =
              'Reached endTime: ${endTimeSeconds}s (${endTimePercentage.toStringAsFixed(1)}%)';
        }
      } else {
        // Case 2b: endTime is below 70% - assume data error, trigger when video has ended
        if (hasVideoEnded) {
          shouldShowCountdown = true;
          triggerReason =
              'Video ended (endTime ${endTimeSeconds}s too low, using fallback)';
        }
      }
    }

    // Show countdown
    if (shouldShowCountdown && !_showNextEpisodeCountdown) {
      _startNextEpisodeCountdown();
      print('🚀 Starting next episode countdown - $triggerReason');
    }

    // If user seeks back before the trigger point, cancel countdown
    if (endTimeSeconds == 0 ||
        (endTimeSeconds > 0 && (endTimeSeconds / totalVideoSeconds) < 0.7)) {
      // For Case 1 and Case 2b: cancel if video not ended
      if (!hasVideoEnded && _showNextEpisodeCountdown) {
        _cancelNextEpisodeCountdown();
        print('⏪ Cancelled next episode countdown - video not ended');
      }
    } else {
      // For Case 2a: cancel if before endTime
      final Duration endTimePosition = Duration(seconds: endTimeSeconds);
      if (currentPosition < endTimePosition && _showNextEpisodeCountdown) {
        _cancelNextEpisodeCountdown();
        print(
          '⏪ Cancelled next episode countdown - before endTime ${endTimeSeconds}s',
        );
      }
    }
  }

  void _startNextEpisodeCountdown() {
    if (_showNextEpisodeCountdown) return;

    setState(() {
      _showNextEpisodeCountdown = true;
      _nextEpisodeCountdownSeconds = 10;
      _isNextEpisodeTriggered = true;
    });

    _nextEpisodeCountdownTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _nextEpisodeCountdownSeconds--;
      });

      if (_nextEpisodeCountdownSeconds <= 0) {
        timer.cancel();
        _playNextEpisodeAutomatically();
      }
    });
  }

  void _cancelNextEpisodeCountdown() {
    _nextEpisodeCountdownTimer?.cancel();
    setState(() {
      _showNextEpisodeCountdown = false;
      _nextEpisodeCountdownSeconds = 10;
      _isNextEpisodeTriggered = false;
    });
  }

  void _playNextEpisodeAutomatically() {
    _cancelNextEpisodeCountdown();
    _playNextEpisode();
  }

  void _skipNextEpisodeCountdown() {
    _cancelNextEpisodeCountdown();
  }

  void _resetAutoNextState() {
    _cancelNextEpisodeCountdown();
    setState(() {
      _isNextEpisodeTriggered = false;
    });
  }

  void _checkSeekBackIntoAdRegions(
    double progressPercentage,
    String episodeKey,
  ) {
    for (int i = 0; i < 3; i++) {
      final adRegionStart = _adIntervals[i];
      final adRegionEnd = i == 2 ? 100 : _adIntervals[i] + 29;

      if (progressPercentage >= adRegionStart &&
          progressPercentage <= adRegionEnd &&
          !_watchedAds[episodeKey]![i] &&
          i != _nextAdIntervalIndex) {
        _nextAdIntervalIndex = i;
        if (!_showAdCountdown) {
          _startAdCountdown();
        }
        break;
      }
    }
  }

  void _checkSeekPastAdIntervals() {
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized) return;

    final currentEpisode = _currentEpisodes[_currentEpisodeIndex];
    final String episodeKey =
        '${currentEpisode.movieId}_${currentEpisode.episodeId}';

    if (!_watchedAds.containsKey(episodeKey)) {
      _watchedAds[episodeKey] = List.filled(3, false);
    }

    final totalDuration = _videoPlayerController!.value.duration;
    final currentPosition = _videoPlayerController!.value.position;

    if (totalDuration.inSeconds > 0) {
      final progressPercentage =
          currentPosition.inSeconds / totalDuration.inSeconds * 100;

      for (int i = 0; i < 3; i++) {
        final regionEnd = i == 2 ? 100 : _adIntervals[i] + 29;

        if (progressPercentage > regionEnd &&
            !_watchedAds[episodeKey]![i] &&
            i >= _nextAdIntervalIndex) {
          _watchedAds[episodeKey]![i] = true;
          _nextAdIntervalIndex = i + 1;

          _cancelAdCountdown();
        }
      }

      if (_videoPlayerController!.value.position >=
          _videoPlayerController!.value.duration) {
        for (int i = 0; i < 3; i++) {
          if (!_watchedAds[episodeKey]![i]) {
            _watchedAds[episodeKey]![i] = true;
          }
        }
        _nextAdIntervalIndex = 3;
        _cancelAdCountdown();
      }
    }
  }

  Timer? _progressSaveTimer;

  void _videoListener() {
    if (!mounted || _videoPlayerController == null) return;

    final bool isFinished = _videoPlayerController!.value.position >=
        _videoPlayerController!.value.duration;

    _updateContinueWatching();

    // Only check for ad trigger if episode has adStatus enabled and ads are available
    if (_shouldShowAds() && !_isAdBottomSheetOpen && !_showAd) {
      _checkAdTrigger();
    }

    // Check for auto-next episode
    if (!_isAdBottomSheetOpen && !_showAd) {
      _checkAutoNextEpisode();
    }

    // Check if user seeked past an ad interval
    if (_shouldShowAds()) {
      _checkSeekPastAdIntervals();
    }

    if (isFinished && !_isLoading) {
      if (_videoPlayerController!.value.position ==
          _videoPlayerController!.value.duration) {
        _playNextEpisode();
      }
    }
  }

  void _checkAndRemoveFromContinueWatching(
    ApiEpisodeData currentEpisode,
    double progressPercentage,
  ) {
    try {
      if (!_cinemaData!.isSeason && progressPercentage >= 80) {
        _removeFromContinueWatching();
        return;
      }

      if (_cinemaData!.isSeason && progressPercentage >= 80) {
        final isLastEpisode = _isLastEpisodeOfAllSeasons(currentEpisode);
        if (isLastEpisode) {
          _removeFromContinueWatching();
        }
      }
    } catch (e) {
      print('Error checking remove condition: $e');
    }
  }

  bool _isLastEpisodeOfAllSeasons(ApiEpisodeData currentEpisode) {
    try {
      if (_cinemaData == null) return false;

      final lastSeasonIndex = _cinemaData!.data.episodes.length - 1;
      final lastSeasonEpisodes = _cinemaData!.data.episodes[lastSeasonIndex];

      if (lastSeasonEpisodes.isNotEmpty) {
        final lastEpisode = lastSeasonEpisodes.last;
        return currentEpisode.episodeId == lastEpisode.episodeId;
      }

      return false;
    } catch (e) {
      print('Error checking last episode: $e');
      return false;
    }
  }

  void _moveMovieToTopInContinueWatching() {
    try {
      final continueWatchingList = List<EpisodesStruct>.from(
        FFAppState().continueWatchingMovies,
      );

      int foundIndex = -1;
      for (int i = 0; i < continueWatchingList.length; i++) {
        if (continueWatchingList[i].movieId == widget.movieId) {
          foundIndex = i;
          break;
        }
      }

      if (foundIndex != -1 && foundIndex != 0) {
        final episode = continueWatchingList.removeAt(foundIndex);
        continueWatchingList.insert(0, episode);

        FFAppState().update(() {
          FFAppState().continueWatchingMovies = continueWatchingList;
        });

        print(
          '⬆️ Moved movie ${widget.movieId} from index $foundIndex to index 0',
        );
      }
    } catch (e) {
      print('Error moving movie to top: $e');
    }
  }

  void _removeFromContinueWatching() {
    try {
      final continueWatchingList = List<EpisodesStruct>.from(
        FFAppState().continueWatchingMovies,
      );
      final initialCount = continueWatchingList.length;

      continueWatchingList.removeWhere(
        (episode) => episode.movieId == widget.movieId,
      );

      FFAppState().update(() {
        FFAppState().continueWatchingMovies = continueWatchingList;
      });

      print(
        '🗑️ Removed movie ${widget.movieId} from continue watching (removed ${initialCount - continueWatchingList.length} entries)',
      );
    } catch (e) {
      print('Error removing from continue watching: $e');
    }
  }

  void _saveProgressToContinueWatching(
    ApiEpisodeData currentEpisode,
    int seconds,
    int percentage,
  ) {
    try {
      final continueWatchingList = List<EpisodesStruct>.from(
        FFAppState().continueWatchingMovies,
      );

      // Convert ApiEpisodeData to EpisodesStruct with updated progress
      final episodeToSave = currentEpisode.toEpisodesStruct();

      // Update the continue watching progress
      final updatedEpisode = EpisodesStruct(
        movieId: episodeToSave.movieId,
        episodeId: episodeToSave.episodeId,
        title: episodeToSave.title,
        episode: episodeToSave.episode,
        partName: episodeToSave.partName,
        longCover: episodeToSave.longCover,
        image: episodeToSave.image,
        type: episodeToSave.type,
        position: episodeToSave.position,
        continueWatching: ContinueWatchingStruct(
          inMinutes: seconds,
          inPercentage: percentage.toDouble(),
        ),
        video: episodeToSave.video,
        size: episodeToSave.size,
        time: episodeToSave.time,
        liked: episodeToSave.liked,
        addedToList: episodeToSave.addedToList,
        viewed: episodeToSave.viewed,
        locked: episodeToSave.locked,
        adstatus: episodeToSave.adstatus,
        isSeason: episodeToSave.isSeason,
        server: episodeToSave.server,
        xr: episodeToSave.xr,
        description: episodeToSave.description,
      );

      // Remove any existing entry for this movie
      continueWatchingList.removeWhere(
        (episode) => episode.movieId == widget.movieId,
      );

      // Insert at the beginning
      continueWatchingList.insert(0, updatedEpisode);

      // Keep only the latest 15 entries
      if (continueWatchingList.length > 15) {
        continueWatchingList.removeRange(15, continueWatchingList.length);
      }

      FFAppState().update(() {
        FFAppState().continueWatchingMovies = continueWatchingList;
      });

      print(
        '💾 Progress saved: ${currentEpisode.title} - $seconds seconds ($percentage%) - Added to index 0',
      );
      print(
        '📊 Continue watching list now has ${continueWatchingList.length} items',
      );
    } catch (e) {
      print('Error saving progress: $e');
    }
  }

  void _updateContinueWatching() {
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized ||
        _currentPlayingEpisode == null) {
      return;
    }

    final currentEpisode = _currentPlayingEpisode!;

    // Skip progress saving for locked episodes
    if (currentEpisode.locked) {
      print('⏸️ Progress saving stopped: Episode is locked');
      return;
    }

    final currentPosition = _videoPlayerController!.value.position;
    final totalDuration = _videoPlayerController!.value.duration;

    if (totalDuration.inSeconds == 0) return;

    final progressPercentage =
        (currentPosition.inSeconds / totalDuration.inSeconds) * 100;
    final percentageInt = progressPercentage.clamp(1, 100).toInt();

    // Check if this is a locked movie (isSeason = false) and progress > 50%
    if (!_cinemaData!.isSeason &&
        currentEpisode.locked &&
        progressPercentage > 50) {
      print('⏸️ Progress saving stopped: Locked movie reached 50%');
      return;
    }

    final shouldSave = _progressSaveTimer == null ||
        !_progressSaveTimer!.isActive ||
        currentPosition.inSeconds % 5 == 0;

    if (shouldSave) {
      _saveProgressToContinueWatching(
        currentEpisode,
        currentPosition.inSeconds,
        percentageInt,
      );

      _progressSaveTimer?.cancel();
      _progressSaveTimer = Timer(Duration(seconds: 5), () {});
    }

    if (progressPercentage >= 80) {
      _checkAndRemoveFromContinueWatching(currentEpisode, progressPercentage);
    }
  }

  Future<void> _handleBackButton() async {
    if (_isAdBottomSheetOpen) {
      Navigator.of(context).pop();
      setState(() {
        _isAdBottomSheetOpen = false;
        _showAd = false;
      });

      _videoPlayerController!.seekTo(_positionBeforeAd);
      if (_wasPlayingBeforeAd) {
        _videoPlayerController!.play();
      }
    } else if (_isFullScreen) {
      await _toggleFullscreen();
      await Future.delayed(const Duration(milliseconds: 300));
    }

    await widget.customCallBack?.call({"action": "backButton", "data": ""});
  }

  Future<void> _setLandscapeMode() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _setPortraitMode() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  Future<void> _toggleFullscreen() async {
    if (_isFullScreen) {
      await _setPortraitMode();
      setState(() {
        _isFullScreen = false;
      });
    } else {
      await _setLandscapeMode();
      setState(() {
        _isFullScreen = true;
      });
    }
  }

  Future<void> _playEpisode(int index) async {
    if (index == _currentEpisodeIndex) return;

    setState(() {
      _isLoading = true;
      _currentEpisodeIndex = index;
      _currentPlayingEpisode = _currentEpisodes[index];
      _nextAdIntervalIndex = 0;
      _showAdCountdown = false;
      _showLoadingScreen = true; // Show loading screen for new episode
    });

    // Mark all ads as completed for locked episodes
    if (_currentEpisodes[index].locked) {
      final currentEpisode = _currentEpisodes[index];
      final String episodeKey =
          '${currentEpisode.movieId}_${currentEpisode.episodeId}';

      if (!_watchedAds.containsKey(episodeKey)) {
        _watchedAds[episodeKey] = List.filled(3, false);
      }

      for (int i = 0; i < 3; i++) {
        _watchedAds[episodeKey]![i] = true;
      }
      _nextAdIntervalIndex = 3;
      print('✅ All ads marked as completed for locked episode');
    }

    _resetAutoNextState();
    _adCountdownTimer?.cancel();
    _loadingScreenTimer?.cancel();
    await _initializePlayer();

    if (_isBottomSheetOpen && mounted) {
      setState(() {});
    }
  }

  Future<void> _playNextEpisode() async {
    if (_currentEpisodeIndex < _currentEpisodes.length - 1) {
      setState(() {
        _isLoading = true;
        _currentEpisodeIndex++;
        _currentPlayingEpisode = _currentEpisodes[_currentEpisodeIndex];
        _nextAdIntervalIndex = 0;
        _showAdCountdown = false;
      });

      _adCountdownTimer?.cancel();
      await _initializePlayer();
    } else {
      if (_cinemaData!.isSeason &&
          _currentSeasonIndex < _cinemaData!.data.episodes.length - 1) {
        setState(() {
          _currentSeasonIndex++;
          _currentEpisodeIndex = 0;
          _currentPlayingEpisode = _currentEpisodes[0];
          _nextAdIntervalIndex = 0;
          _showAdCountdown = false;
          _updateCurrentEpisodes();
        });

        _adCountdownTimer?.cancel();
        await _initializePlayer();
      } else {
        _handleBackButton();
      }
    }
  }

  Future<void> _toggleMute() async {
    await HapticFeedback.lightImpact();
    setState(() {
      _isMuted = !_isMuted;
      _videoPlayerController?.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _onQualityChanged(String newQuality) {
    if (!_isQualityAvailable(newQuality)) {
      final fallbackQuality = _getFallbackQuality(newQuality);

      if (!_isQualityAvailable(fallbackQuality)) {
        _showNoQualityAvailableError();
        return;
      }

      setState(() {
        _currentQuality = fallbackQuality;
        _isSystemFallback = true;
      });

      _reloadVideoWithNewQuality();
      return;
    }

    FFAppState().update(() {
      FFAppState().userQualityChoice = newQuality;
    });

    setState(() {
      _currentQuality = newQuality;
      _isSystemFallback = false;
    });

    _reloadVideoWithNewQuality();
  }

  String? _getVideoUrlForQuality(ApiEpisodeData episode, String quality) {
    switch (quality) {
      case "HD":
        return episode.video?.hdVideo;
      case "MID":
        return episode.video?.midVideo;
      case "LOW":
        return episode.video?.lowVideo;
      default:
        return episode.video?.midVideo;
    }
  }

  String _getVideoUrlForCurrentQuality(ApiEpisodeData episode) {
    return _getVideoUrlForQuality(episode, _currentQuality) ?? '';
  }

  Future<void> _reloadVideoWithNewQuality() async {
    if (_currentEpisodes.isEmpty ||
        _currentEpisodeIndex >= _currentEpisodes.length) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final currentEpisode = _currentEpisodes[_currentEpisodeIndex];
    final String videoPath = _getVideoUrlForCurrentQuality(currentEpisode);

    if (videoPath.isEmpty) {
      final anyAvailableQuality = _getFallbackQuality("MID");

      if (!_isQualityAvailable(anyAvailableQuality)) {
        _showNoQualityAvailableError();
        return;
      }

      setState(() {
        _currentQuality = anyAvailableQuality;
        _isSystemFallback = true;
      });

      _reloadVideoWithNewQuality();
      return;
    }

    try {
      _videoPlayerController?.removeListener(_videoListener);
      await _videoPlayerController?.dispose();
      _chewieController?.dispose();

      final Duration? currentPosition = _videoPlayerController?.value.position;

      _videoPlayerController = VideoPlayerController.network(videoPath);
      await _videoPlayerController!.initialize();
      _videoPlayerController!.addListener(_videoListener);

      if (currentPosition != null) {
        await _videoPlayerController!.seekTo(currentPosition);
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        autoInitialize: true,
        allowedScreenSleep: false,
        showControls: false,
        //aspectRatio: MediaQuery.of(context).size.width / MediaQuery.of(context).size.height,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading $_currentQuality quality: $e');

      final nextQuality = _getFallbackQuality(_currentQuality);
      if (nextQuality != _currentQuality && _isQualityAvailable(nextQuality)) {
        setState(() {
          _currentQuality = nextQuality;
          _isSystemFallback = true;
        });
        _reloadVideoWithNewQuality();
      } else {
        setState(() {
          _error =
              "Failed to load video. Please check your connection and try again.";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchCinemaData() async {
    setState(() {
      _isDataLoading = true;
      _error = null;
    });

    try {
      final response = await _fetchWithRetry(
        "https://api.rebamovie.com/cinemaData",
        {
          "method": "POST",
          "headers": {
            "Content-Type": "application/json",
            "Content-Language": "1.0.1",
          },
          "body": json.encode({
            "MovieId": widget.movieId,
            "userId": widget.userId,
            "deviceType": "IOS",
          }),
        },
        4,
        1000,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        _cinemaData = CinemaDataResponse.fromJson(jsonResponse);

        _updateCurrentEpisodes();

        if (_currentEpisodes.isNotEmpty) {
          await _initializePlayer();
        } else {
          setState(() {
            _error = "No episodes available";
            _isLoading = false;
            _isDataLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = "Error loading data: $e";
        _isLoading = false;
        _isDataLoading = false;
      });
    }
  }

  Future<http.Response> _fetchWithRetry(
    String url,
    Map<String, dynamic> options,
    int retries,
    int delay,
  ) async {
    for (int i = 0; i < retries; i++) {
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: Map<String, String>.from(options['headers'] ?? {}),
          body: options['body'],
        );

        if (response.statusCode == 200) {
          return response;
        }
      } catch (e) {
        print('Attempt ${i + 1} failed: $e');
      }

      if (i < retries - 1) {
        await Future.delayed(Duration(milliseconds: delay));
      }
    }
    throw Exception('All retry attempts failed');
  }

  void _updateCurrentEpisodes() {
    if (_cinemaData != null && _cinemaData!.data.episodes.isNotEmpty) {
      if (_currentSeasonIndex < _cinemaData!.data.episodes.length) {
        _currentEpisodes = _cinemaData!.data.episodes[_currentSeasonIndex];
      }
    }

    setState(() {
      _isDataLoading = false;
    });
  }

  void _onSeasonChanged(int newSeasonIndex) {
    setState(() {
      _currentSeasonIndex = newSeasonIndex;
      _currentEpisodeIndex = 0;
      _currentPlayingEpisode = null;
      _nextAdIntervalIndex = 0;
      _updateCurrentEpisodes();
    });

    if (_currentEpisodes.isNotEmpty) {
      _playEpisode(0);
    }
  }

  Future<void> _initializePlayer() async {
    if (_currentEpisodes.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _nextAdIntervalIndex = 0;
      _showAdCountdown = false;
      _showLoadingScreen =
          true; // Show loading screen when initializing new episode
    });

    _adCountdownTimer?.cancel();
    _loadingScreenTimer?.cancel();

    if (_isInitialLoad) {
      final shouldLoadFromContinue = _loadEpisodeFromContinueWatching();

      if (!shouldLoadFromContinue) {
        setState(() {
          _currentSeasonIndex = 0;
          _currentEpisodeIndex = 0;
          _currentPlayingEpisode = _currentEpisodes[0];
        });
        _updateCurrentEpisodes();
      } else {
        if (_currentEpisodeIndex < _currentEpisodes.length) {
          _currentPlayingEpisode = _currentEpisodes[_currentEpisodeIndex];
        }
      }
    } else {
      if (_currentEpisodeIndex < _currentEpisodes.length) {
        _currentPlayingEpisode = _currentEpisodes[_currentEpisodeIndex];
      }
    }

    final currentEpisode = _currentEpisodes[_currentEpisodeIndex];
    final String videoPath = _getVideoUrlForCurrentQuality(currentEpisode);

    if (videoPath.isEmpty) {
      setState(() {
        _error = "No video file path found for this episode.";
        _isLoading = false;
        _showLoadingScreen = false;
      });
      return;
    }

    _videoPlayerController?.removeListener(_videoListener);
    await _videoPlayerController?.dispose();
    _chewieController?.dispose();

    try {
      _videoPlayerController = VideoPlayerController.network(videoPath);

      // Start loading screen timer when video starts loading
      _startLoadingScreenTimer();

      await _videoPlayerController!.initialize();
      _videoPlayerController!.addListener(_videoListener);

      final continueWatchingPosition = _getContinueWatchingPosition(
        currentEpisode,
      );

      print('🎬 LOADING EPISODE:');
      print(
        '   Season: ${_currentSeasonIndex}, Episode: ${_currentEpisodeIndex}',
      );
      print('   EpisodeId: ${currentEpisode.episodeId}');
      print('   Continue position: ${continueWatchingPosition.inSeconds}s');
      print('   Is initial load: $_isInitialLoad');

      if (_isInitialLoad && continueWatchingPosition > Duration.zero) {
        await _videoPlayerController!.seekTo(continueWatchingPosition);
        print(
          '▶️ RESUMED from continue watching at ${continueWatchingPosition.inSeconds} seconds',
        );
      } else if (_isInitialLoad) {
        print('🔄 STARTING from beginning (no continue watching data)');
      } else {
        print('🔄 STARTING from beginning (manual episode change)');
      }

      _isInitialLoad = false;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        autoInitialize: true,
        allowedScreenSleep: false,
        showControls: false,
        //aspectRatio: MediaQuery.of(context).size.width / MediaQuery.of(context).size.height,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          // Hide loading screen on error
          if (mounted) {
            setState(() {
              _showLoadingScreen = false;
            });
          }
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });

      // Hide loading screen when video starts playing
      _videoPlayerController!.addListener(() {
        if (_videoPlayerController!.value.isPlaying && _showLoadingScreen) {
          if (mounted) {
            setState(() {
              _showLoadingScreen = false;
            });
          }
        }
      });
    } catch (e) {
      setState(() {
        _error = "Error initializing video: $e";
        _isLoading = false;
        _showLoadingScreen = false;
      });
    }
  }

  Duration _getContinueWatchingPosition(ApiEpisodeData currentEpisode) {
    try {
      final continueWatchingList = FFAppState().continueWatchingMovies;

      print('🔍 CHECKING CONTINUE POSITION FOR:');
      print('   movieId: ${widget.movieId}');
      print('   episodeId: ${currentEpisode.episodeId}');

      for (final continueEpisode in continueWatchingList) {
        print(
          '   Checking: movieId=${continueEpisode.movieId}, episodeId=${continueEpisode.episodeId}, progress=${continueEpisode.continueWatching?.inMinutes}s',
        );

        if (continueEpisode.movieId == widget.movieId &&
            continueEpisode.episodeId == currentEpisode.episodeId) {
          final continueMinutes =
              continueEpisode.continueWatching?.inMinutes ?? 0;
          print('✅ FOUND CONTINUE POSITION: ${continueMinutes} seconds');
          return Duration(seconds: continueMinutes);
        }
      }

      print('❌ NO CONTINUE POSITION FOUND');
      return Duration.zero;
    } catch (e) {
      print('Error getting continue watching position: $e');
      return Duration.zero;
    }
  }

  // Rest of your existing methods for bottom sheet, scrolling, etc.
  void _showMoreVideosBottomSheet() {
    if (_currentEpisodes.length > 1 || _cinemaData!.isSeason) {
      setState(() {
        _isBottomSheetOpen = true;
      });

      final audioWaveData = AudioWaveData()..togglePlayPause();

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ChangeNotifierProvider<AudioWaveData>.value(
          value: audioWaveData,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToActiveEpisode();
              });

              return SizedBox(
                height: 250,
                child: _buildMoreVideosBottomSheet(setModalState),
              );
            },
          ),
        ),
      ).then((_) {
        audioWaveData.togglePlayPause();
        if (mounted) {
          setState(() {
            _isBottomSheetOpen = false;
          });
        }
      });
    }
  }

  void _scrollToActiveEpisode() {
    if (_scrollController.hasClients && _currentEpisodes.isNotEmpty) {
      final String currentEpisodeId = _currentPlayingEpisode?.episodeId ?? '';

      int activeIndexInCurrentSeason = -1;

      for (int i = 0; i < _currentEpisodes.length; i++) {
        if (_currentEpisodes[i].episodeId == currentEpisodeId) {
          activeIndexInCurrentSeason = i;
          break;
        }
      }

      if (activeIndexInCurrentSeason != -1) {
        final double episodeWidth = 250 + 8;
        final double scrollPosition = activeIndexInCurrentSeason * episodeWidth;
        final double viewportWidth = MediaQuery.of(context).size.width;

        double targetOffset =
            scrollPosition - (viewportWidth / 2) + (episodeWidth / 2);
        targetOffset = targetOffset.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );

        _scrollController.animateTo(
          targetOffset,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.jumpTo(0);
      }
    }
  }

  void _closeBottomSheet() {
    Navigator.of(context).pop();
  }

  void _scrollLeft() {
    final double currentPosition = _scrollController.offset;
    final double scrollAmount = 280;
    final double newPosition = currentPosition - scrollAmount;

    _scrollController.animateTo(
      newPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    final double currentPosition = _scrollController.offset;
    final double scrollAmount = 280;
    final double newPosition = currentPosition + scrollAmount;

    _scrollController.animateTo(
      newPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollSeasonsLeft() {
    final double currentPosition = _seasonScrollController.offset;
    final double scrollAmount = 280;
    final double newPosition = currentPosition - scrollAmount;

    _seasonScrollController.animateTo(
      newPosition.clamp(0.0, _seasonScrollController.position.maxScrollExtent),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollSeasonsRight() {
    final double currentPosition = _seasonScrollController.offset;
    final double scrollAmount = 280;
    final double newPosition = currentPosition + scrollAmount;

    _seasonScrollController.animateTo(
      newPosition.clamp(0.0, _seasonScrollController.position.maxScrollExtent),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () async {
        await HapticFeedback.lightImpact();
        onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0x32818181),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0x40E0E3E7), width: 1),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEpisodeItems() {
    List<Widget> items = [];

    final String currentEpisodeId = _currentPlayingEpisode?.episodeId ?? '';

    for (int i = 0; i < _currentEpisodes.length; i++) {
      final episode = _currentEpisodes[i];

      final bool isActive = episode.episodeId == currentEpisodeId;

      items.add(
        AnimatedEpisodeCard(
          episode: episode,
          isActive: isActive,
          onEpisodeSelected: _playEpisode,
          index: i,
          onCloseBottomSheet: _closeBottomSheet,
          seasonIndex: _currentSeasonIndex,
        ),
      );

      if (i < _currentEpisodes.length - 1) {
        items.add(SizedBox(width: 8));
      }
    }

    items.insert(0, SizedBox(width: 16));
    items.add(SizedBox(width: 16));

    return items;
  }

  List<Widget> _buildSeasonItems([StateSetter? setModalState]) {
    List<Widget> items = [];

    for (int i = 0; i < _cinemaData!.data.seasons.length; i++) {
      final seasonName = _cinemaData!.data.seasons[i];

      final bool isActive = i == _currentSeasonIndex;

      items.add(
        _buildAnimatedSeasonCard(
          seasonIndex: i,
          seasonName: seasonName,
          setModalState: setModalState,
          isActive: isActive,
        ),
      );

      if (i < _cinemaData!.data.seasons.length - 1) {
        items.add(SizedBox(width: 16));
      }
    }

    items.insert(0, SizedBox(width: 16));
    items.add(SizedBox(width: 16));

    return items;
  }

  Widget _buildEpisodesPage() {
    return Container(
      width: double.infinity,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: _buildEpisodeItems(),
              ),
            ),
          ),
          if (_currentEpisodes.length > 1)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                bottom: false,
                right: false,
                left: true,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                  child: Center(
                    child: SizedBox(
                      height: 50,
                      child: _buildNavigationButton(
                        icon: Icons.arrow_back_ios,
                        onTap: _scrollLeft,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_currentEpisodes.length > 1)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                bottom: false,
                left: false,
                right: true,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 8, 0),
                  child: Center(
                    child: SizedBox(
                      height: 50,
                      child: _buildNavigationButton(
                        icon: Icons.arrow_forward_ios,
                        onTap: _scrollRight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSeasonsPage([StateSetter? setModalState]) {
    return Container(
      width: double.infinity,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
            child: SingleChildScrollView(
              controller: _seasonScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: _buildSeasonItems(setModalState),
              ),
            ),
          ),
          if (_cinemaData!.data.seasons.length > 1)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                bottom: false,
                right: false,
                left: true,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                  child: Center(
                    child: SizedBox(
                      height: 50,
                      child: _buildNavigationButton(
                        icon: Icons.arrow_back_ios,
                        onTap: _scrollSeasonsLeft,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_cinemaData!.data.seasons.length > 1)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                bottom: false,
                left: false,
                right: true,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 8, 0),
                  child: Center(
                    child: SizedBox(
                      height: 50,
                      child: _buildNavigationButton(
                        icon: Icons.arrow_forward_ios,
                        onTap: _scrollSeasonsRight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNextEpisodeCover() {
    int nextEpisodeIndex = _currentEpisodeIndex + 1;

    if (nextEpisodeIndex >= _currentEpisodes.length) {
      nextEpisodeIndex = _currentEpisodes.length - 1;
    }

    final nextEpisode = _currentEpisodes[nextEpisodeIndex];

    if (nextEpisode.longCover != null && nextEpisode.longCover!.isNotEmpty) {
      return Image.network(
        nextEpisode.longCover!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderCover();
        },
      );
    } else {
      return _buildPlaceholderCover();
    }
  }

  Widget _buildAnimatedSeasonCard({
    required int seasonIndex,
    required String seasonName,
    StateSetter? setModalState,
    bool isActive = false,
  }) {
    String? seasonCover;
    if (_cinemaData!.data.episodes.length > seasonIndex &&
        _cinemaData!.data.episodes[seasonIndex].isNotEmpty) {
      final firstEpisode = _cinemaData!.data.episodes[seasonIndex].first;
      seasonCover = firstEpisode.longCover.isNotEmpty
          ? firstEpisode.longCover
          : firstEpisode.image.isNotEmpty
              ? firstEpisode.image
              : firstEpisode.noImage;
    }

    return AnimatedSeasonCard(
      seasonIndex: seasonIndex,
      seasonName: seasonName,
      seasonCover: seasonCover,
      isActive: isActive,
      onSeasonSelected: (index) async {
        setState(() {
          _currentSeasonIndex = index;
          _updateCurrentEpisodes();
        });

        if (setModalState != null) {
          setModalState(() {});
        }

        await Future.delayed(Duration(milliseconds: 700));

        if (mounted) {
          await _bottomSheetPageController.animateToPage(
            0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );

          _scrollController.jumpTo(0);

          if (setModalState != null) {
            setModalState(() {});
          }
        }
      },
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.movie, color: Colors.grey[600], size: 40),
    );
  }

  Widget _buildMoreVideosBottomSheet([StateSetter? setModalState]) {
    final isMovie = !_cinemaData!.isSeason;
    return Container(
      height: 500,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.9),
            Colors.black,
          ],
          stops: [0.0, 0.3, 1.0],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_cinemaData!.isSeason)
                    _buildSeasonSelectorButton(setModalState)
                  else
                    Text(
                      'More Movies',
                      style:
                          FlutterFlowTheme.of(context).headlineMedium.override(
                                fontFamily: FlutterFlowTheme.of(
                                  context,
                                ).headlineMediumFamily,
                                color: Colors.white,
                                fontSize: 22,
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(
                                  context,
                                ).headlineMediumIsCustom,
                              ),
                    ),
                  SafeArea(
                    top: false,
                    bottom: false,
                    left: true,
                    right: false,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 24),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _bottomSheetPageController,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                children: [
                  _buildEpisodesPage(),
                  _buildSeasonsPage(setModalState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonSelectorButton([StateSetter? setModalState]) {
    final currentSeason = _cinemaData!.data.seasons[_currentSeasonIndex];
    final isOnSeasonsPage = _bottomSheetPageController.hasClients &&
        _bottomSheetPageController.page?.round() == 1;

    return SafeArea(
      top: false,
      bottom: false,
      left: true,
      right: false,
      child: GestureDetector(
        onTap: () async {
          if (_isSeasonButtonAnimating) return;
          final updateState = setModalState ?? setState;
          updateState(() {
            _isSeasonButtonAnimating = true;
            _seasonButtonScale = 0.85;
          });
          await HapticFeedback.lightImpact();
          if (isOnSeasonsPage) {
            _bottomSheetPageController.animateToPage(
              0,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          } else {
            _bottomSheetPageController.animateToPage(
              1,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
          Future.delayed(Duration(milliseconds: 200), () {
            if (mounted) {
              updateState(() {
                _seasonButtonScale = 1.0;
              });
            }
          });
          Future.delayed(Duration(milliseconds: 700), () {
            if (mounted) {
              updateState(() {
                _isSeasonButtonAnimating = false;
              });
            }
          });
        },
        child: AnimatedScale(
          scale: _seasonButtonScale,
          duration: Duration(milliseconds: 200),
          child: Container(
            width: 200,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isOnSeasonsPage ? "Back to Episodes" : currentSeason,
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleSmallFamily,
                          color: Colors.white,
                          fontSize: 14,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          useGoogleFonts: !FlutterFlowTheme.of(
                            context,
                          ).titleSmallIsCustom,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Icon(
                    isOnSeasonsPage ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Add the loading screen widget
  Widget _buildLoadingScreen() {
    final currentEpisode = _currentPlayingEpisode;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return _VideoLoadingScreen(
      episode: currentEpisode!,
      isLandscape: isLandscape,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showLoadingScreen && _currentPlayingEpisode != null) {
      return _buildLoadingScreen();
    }

    if (_showAd) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Preparing ad...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    if (_isDataLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Loading ...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _fetchCinemaData,
                    child: const Text('Retry'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _handleBackButton,
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading || _chewieController == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Loading ...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    final currentEpisode = _currentEpisodeIndex < _currentEpisodes.length
        ? _currentEpisodes[_currentEpisodeIndex]
        : null;

    final isMovie = !_cinemaData!.isSeason;
    final hasMultipleEpisodes =
        _currentEpisodes.length > 1 || _cinemaData!.isSeason;

    final isEpisodeLocked = currentEpisode?.locked ?? false;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.black,
            child: Chewie(controller: _chewieController!),
          ),
          if (_videoPlayerController != null &&
              _videoPlayerController!.value.isInitialized &&
              !_isBottomSheetOpen)
            Positioned.fill(
              child: CustomDownloadControls(
                videoController: _videoPlayerController!,
                title: currentEpisode?.title ?? 'rebaMovie',
                category: isMovie
                    ? "Filme"
                    : (currentEpisode?.position?.seasonIndex != null
                        ? "S0${currentEpisode!.position!.seasonIndex + 1} EP${currentEpisode!.episode} ${currentEpisode!.partName}"
                        : "Episode"),
                isMuted: _isMuted,
                isFullScreen: _isFullScreen,
                onBack: _handleBackButton,
                onSkipIntro: () {
                  if (currentEpisode?.time?.startTime != null ||
                      currentEpisode?.time?.startTime != '') {
                    final currentPosition =
                        _videoPlayerController!.value.position;
                    int skipTime = int.parse(currentEpisode!.time!.startTime);
                    final newPosition =
                        currentPosition + Duration(seconds: skipTime);
                    final totalDuration =
                        _videoPlayerController!.value.duration;
                    _videoPlayerController!.seekTo(
                      newPosition < totalDuration ? newPosition : totalDuration,
                    );
                  }
                },
                onToggleMute: _toggleMute,
                onToggleFullscreen: _toggleFullscreen,
                onShowMoreVideos: _showMoreVideosBottomSheet,
                hasMultipleEpisodes: hasMultipleEpisodes,
                episodes: _currentEpisodes,
                currentEpisodeIndex: _currentEpisodeIndex,
                currentQuality: _currentQuality,
                onQualityChanged: _onQualityChanged,
                showAdCountdown: _showAdCountdown,
                adCountdownSeconds: _adCountdownSeconds,
                onSkipAd: _skipAd,
                currentEpisode: currentEpisode,
                // NEW PARAMETERS FOR AUTO-NEXT
                showNextEpisodeCountdown: _showNextEpisodeCountdown,
                nextEpisodeCountdownSeconds: _nextEpisodeCountdownSeconds,
                onSkipNextEpisodeCountdown: _skipNextEpisodeCountdown,
                onPlayNextEpisodeNow: _playNextEpisodeAutomatically,
                // NEW PARAMETERS FOR LOCKED CONTENT
                isSeason: _cinemaData?.isSeason ?? false, // Pass isSeason
                isEpisodeLocked: isEpisodeLocked,
                // Add subscribe callback
                onSubscribe: () {
                  widget.customCallBack?.call({
                    "action": "subscribeButton",
                    "data": widget.movieId,
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
