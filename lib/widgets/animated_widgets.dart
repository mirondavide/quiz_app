import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// Premium Animated Button with Multiple Visual States
class PremiumAnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool enabled;
  final bool hapticFeedback;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final double? elevation;
  final Duration animationDuration;
  final bool glowEffect;
  
  const PremiumAnimatedButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.enabled = true,
    this.hapticFeedback = true,
    this.boxShadow,
    this.gradient,
    this.elevation,
    this.animationDuration = AppTheme.animationMedium,
    this.glowEffect = false,
  }) : super(key: key);

  @override
  _PremiumAnimatedButtonState createState() => _PremiumAnimatedButtonState();
}

class _PremiumAnimatedButtonState extends State<PremiumAnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _glowController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: AppTheme.defaultCurve,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.glowEffect) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enabled) {
      setState(() => _isPressed = true);
      _scaleController.forward();
      if (widget.hapticFeedback) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enabled) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
      widget.onPressed?.call();
    }
  }

  void _onTapCancel() {
    if (widget.enabled) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding ?? EdgeInsets.symmetric(
                horizontal: AppTheme.spacingL,
                vertical: AppTheme.spacingM,
              ),
              decoration: BoxDecoration(
                gradient: widget.gradient ?? AppTheme.primaryGradient,
                color: widget.gradient == null ? 
                    (widget.backgroundColor ?? AppTheme.primaryColor) : null,
                borderRadius: widget.borderRadius ?? 
                    BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: widget.glowEffect ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(
                      0.3 + (_glowAnimation.value * 0.4)
                    ),
                    blurRadius: 15 + (_glowAnimation.value * 10),
                    offset: Offset(0, 5 + (_glowAnimation.value * 3)),
                  )
                ] : (widget.boxShadow ?? AppTheme.buttonShadow),
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

// Enhanced Slide-in Animation with Stagger Support
class SlideInAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset? offset;
  final Curve curve;
  final bool fadeIn;
  
  const SlideInAnimation({
    Key? key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppTheme.animationSlow,
    this.offset,
    this.curve = AppTheme.smoothCurve,
    this.fadeIn = true,
  }) : super(key: key);

  @override
  _SlideInAnimationState createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: widget.offset ?? Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: widget.fadeIn ? FadeTransition(
            opacity: _fadeAnimation,
            child: widget.child,
          ) : widget.child,
        );
      },
    );
  }
}

// Premium Pulsing Effect Widget
class PulsingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double maxScale;
  final bool autoStart;
  final Color? glowColor;
  
  const PulsingWidget({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.maxScale = 1.05,
    this.autoStart = true,
    this.glowColor,
  }) : super(key: key);

  @override
  _PulsingWidgetState createState() => _PulsingWidgetState();
}

class _PulsingWidgetState extends State<PulsingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 1.0,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    if (widget.autoStart) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            decoration: widget.glowColor != null ? BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor!.withOpacity(
                    0.3 + (_animation.value - 1.0) * 2
                  ),
                  blurRadius: 20 + (_animation.value - 1.0) * 40,
                  spreadRadius: -5,
                ),
              ],
            ) : null,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// Enhanced Animated Counter with Smooth Transitions
class AnimatedCounter extends StatefulWidget {
  final int value;
  final TextStyle? textStyle;
  final Duration duration;
  final String prefix;
  final String suffix;
  final Curve curve;
  
  const AnimatedCounter({
    Key? key,
    required this.value,
    this.textStyle,
    this.duration = AppTheme.animationMedium,
    this.prefix = '',
    this.suffix = '',
    this.curve = AppTheme.defaultCurve,
  }) : super(key: key);

  @override
  _AnimatedCounterState createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0,
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(
        begin: _previousValue.toDouble(),
        end: widget.value.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix}${_animation.value.round()}${widget.suffix}',
          style: widget.textStyle,
        );
      },
    );
  }
}

// Legacy widgets for backward compatibility
class AnimatedButton extends PremiumAnimatedButton {
  const AnimatedButton({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    bool hapticFeedback = true,
  }) : super(
    key: key,
    child: child,
    onPressed: onPressed,
    backgroundColor: backgroundColor,
    borderRadius: borderRadius,
    hapticFeedback: hapticFeedback,
  );
}

class PulsingButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? glowColor;
  
  const PulsingButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.glowColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: PulsingWidget(
        child: child,
        glowColor: glowColor,
      ),
    );
  }
}