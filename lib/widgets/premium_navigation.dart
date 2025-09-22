import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class PremiumNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<PremiumNavItem> items;

  const PremiumNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  State<PremiumNavigationBar> createState() => _PremiumNavigationBarState();
}

class _PremiumNavigationBarState extends State<PremiumNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _onItemTap(int index) {
    if (index != widget.currentIndex) {
      HapticFeedback.lightImpact();
      _rippleController.forward().then((_) {
        _rippleController.reset();
      });
      widget.onTap(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusLarge),
          topRight: Radius.circular(AppTheme.radiusLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusLarge),
          topRight: Radius.circular(AppTheme.radiusLarge),
        ),
        child: Container(
          height: 75,
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM,
            vertical: AppTheme.spacingS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: widget.items.asMap().entries.map((entry) {
              int index = entry.key;
              PremiumNavItem item = entry.value;
              bool isSelected = index == widget.currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onItemTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return ScaleTransition(
                        scale: isSelected ? _scaleAnimation : 
                               Tween<double>(begin: 1.0, end: 1.0).animate(_animationController),
                        child: Container(
                          height: 60,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon container with background
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Ripple effect
                                  if (isSelected)
                                    AnimatedBuilder(
                                      animation: _rippleAnimation,
                                      builder: (context, child) {
                                        return Container(
                                          width: 32 + (_rippleAnimation.value * 8),
                                          height: 32 + (_rippleAnimation.value * 8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor.withOpacity(
                                              0.2 * (1 - _rippleAnimation.value),
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        );
                                      },
                                    ),
                                  
                                  // Main icon container
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      gradient: isSelected 
                                          ? AppTheme.primaryGradient
                                          : null,
                                      color: isSelected 
                                          ? null 
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: isSelected ? [
                                        BoxShadow(
                                          color: AppTheme.primaryColor.withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                      ] : null,
                                    ),
                                    child: Icon(
                                      item.icon,
                                      color: isSelected 
                                          ? Colors.white 
                                          : AppTheme.textLight,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: 4),
                              
                              // Label
                              AnimatedDefaultTextStyle(
                                duration: Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected 
                                      ? FontWeight.w600 
                                      : FontWeight.w500,
                                  color: isSelected 
                                      ? AppTheme.primaryColor 
                                      : AppTheme.textLight,
                                ),
                                child: Text(
                                  item.label,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class PremiumNavItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const PremiumNavItem({
    required this.icon,
    required this.label,
    this.onTap,
  });
}

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final double elevation;

  const PremiumAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: backgroundColor == null ? AppTheme.backgroundGradient : null,
        color: backgroundColor,
      ),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM,
            vertical: AppTheme.spacingS,
          ),
          child: Row(
            children: [
              // Leading widget
              if (leading != null) 
                leading!
              else
                SizedBox(width: 40), // Spacer when no leading widget
              
              // Title
              Expanded(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingL,
                      vertical: AppTheme.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              
              // Actions
              if (actions != null && actions!.isNotEmpty)
                Row(children: actions!)
              else
                SizedBox(width: 40), // Spacer when no actions
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}

class FloatingNavButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const FloatingNavButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  State<FloatingNavButton> createState() => _FloatingNavButtonState();
}

class _FloatingNavButtonState extends State<FloatingNavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onPressed();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: widget.backgroundColor == null 
                      ? AppTheme.primaryGradient 
                      : null,
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.backgroundColor ?? AppTheme.primaryColor)
                          .withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: widget.foregroundColor ?? Colors.white,
                  size: 24,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}