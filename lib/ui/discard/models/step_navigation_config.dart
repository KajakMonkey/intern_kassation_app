import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'step_navigation_config.freezed.dart';

@freezed
sealed class StepNavigationConfig with _$StepNavigationConfig {
  const factory StepNavigationConfig({
    @Default(true) bool showAppBarBackButton,
    @Default(true) bool showFab,
    @Default(Icons.arrow_forward) IconData fabIcon,
    @Default(true) bool canProceed,
    @Default(false) bool isLoading,
    @Default(false) bool showBottomButtons,
    @Default(Icons.arrow_forward) IconData nextButtonIcon,
    @Default(Icons.arrow_back) IconData backButtonIcon,
  }) = _StepNavigationConfig;

  const StepNavigationConfig._();

  static const standard = StepNavigationConfig();
  static const standardNoFab = StepNavigationConfig(showFab: false);
  static const submit = StepNavigationConfig(
    nextButtonIcon: Icons.check,
    showFab: false,
    showBottomButtons: false,
  );
}

/* /// Configuration for how a step handles navigation.
@freezed
class StepNavigationConfig {
  const StepNavigationConfig({
    this.showAppBarBackButton = true,
    this.showFab = true,
    this.fabIcon = Icons.arrow_forward,
    this.canProceed = true,
    this.isLoading = false,
    this.showBottomButtons = false,
    this.nextButtonIcon = Icons.arrow_forward,
    this.backButtonIcon = Icons.arrow_back,
  });

  /// Show the AppBar back button (default: true)
  final bool showAppBarBackButton;

  /// Show the floating action button for next action (default: true)
  final bool showFab;
  final IconData fabIcon;

  /// Show bottom row buttons instead of FAB (default: false)
  final bool showBottomButtons;
  final IconData nextButtonIcon;
  final IconData backButtonIcon;

  /// Whether the next action is enabled
  final bool canProceed;

  /// Show loading indicator
  final bool isLoading;

  /// Preset: Standard step with AppBar back + FAB next
  static const standard = StepNavigationConfig();

  static const standardNoFab = StepNavigationConfig(showFab: false);

  /// Preset: Overview/Submit step with bottom buttons
  static const submit = StepNavigationConfig(nextButtonIcon: Icons.check, showFab: false, showBottomButtons: false);

  StepNavigationConfig copyWith({
    bool? showAppBarBackButton,
    bool? showFab,
    IconData? fabIcon,
    bool? showBottomButtons,
    IconData? nextButtonIcon,
    IconData? backButtonIcon,
    bool? canProceed,
    bool? isLoading,
  }) {
    return StepNavigationConfig(
      showAppBarBackButton: showAppBarBackButton ?? this.showAppBarBackButton,
      showFab: showFab ?? this.showFab,
      fabIcon: fabIcon ?? this.fabIcon,
      showBottomButtons: showBottomButtons ?? this.showBottomButtons,
      nextButtonIcon: nextButtonIcon ?? this.nextButtonIcon,
      backButtonIcon: backButtonIcon ?? this.backButtonIcon,
      canProceed: canProceed ?? this.canProceed,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  String toString() =>
      'StepNavigationConfig(showAppBarBackButton: $showAppBarBackButton, showFab: $showFab, fabIcon: $fabIcon, showBottomButtons: $showBottomButtons, nextButtonIcon: $nextButtonIcon, backButtonIcon: $backButtonIcon, canProceed: $canProceed, isLoading: $isLoading)';
}
 */
