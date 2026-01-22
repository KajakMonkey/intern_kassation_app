import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/config/constants/product_type.dart';
import 'package:intern_kassation_app/routing/navigator.dart';
import 'package:intern_kassation_app/ui/core/extensions/buildcontext_extension.dart';
import 'package:intern_kassation_app/ui/core/extensions/navigation_extension.dart';
import 'package:intern_kassation_app/ui/core/ui/dialog/app_dialog.dart';
import 'package:intern_kassation_app/ui/discard/widgets/steps/discard_reason_step.dart';
import 'package:intern_kassation_app/ui/discard/widgets/steps/employee_step.dart';
import 'package:intern_kassation_app/ui/discard/widgets/steps/image_step.dart';
import 'package:intern_kassation_app/ui/discard/widgets/steps/note_step.dart';
import 'package:intern_kassation_app/ui/discard/widgets/steps/overview_step.dart';
import 'package:intern_kassation_app/ui/discard/widgets/steps/unknown_step.dart';
import 'package:intern_kassation_app/utils/extensions/date_extension.dart';
import 'package:intern_kassation_app/ui/discard/cubit/discard_cubit.dart';
import 'package:intern_kassation_app/ui/discard/models/models_index.dart';

class DiscardFormScreen extends StatefulWidget {
  const DiscardFormScreen({
    super.key,
    required this.salesId,
    required this.worktop,
    required this.productType,
    required this.productGroup,
    required this.productionOrder,
  });

  final String salesId;
  final String worktop;
  final ProductType productType;
  final String productGroup;
  final String productionOrder;

  @override
  State<DiscardFormScreen> createState() => _DiscardFormScreenState();
}

class _DiscardFormScreenState extends State<DiscardFormScreen> {
  late final PageController _pageController;
  late final List<DiscardFormStep> _steps;
  var _currentPage = 0;

  late final List<StepNavigationConfig?> _stepNavConfigs;

  late StepNavigationConfig _navConfig;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _steps = DiscardFormConfig.getStepsForProduct(widget.productType);
    _stepNavConfigs = List.generate(_steps.length, (i) => _steps[i].defaultConfig);
    _navConfig = _steps[0].defaultConfig;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      final String formattedDate = now.formatDate();
      context.read<DiscardCubit>().onInitinalData(
        salesId: widget.salesId,
        productionOrder: widget.productionOrder,
        worktop: widget.worktop,
        productType: widget.productType,
        dateTime: now,
        date: formattedDate,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isFirstStep => _currentPage == 0;
  bool get _isLastStep => _currentPage == _steps.length - 1;

  void _onStepNavConfigChanged(int index, StepNavigationConfig config) {
    _stepNavConfigs[index] = config;
    if (_currentPage == index) _updateNavConfig(config);
  }

  void _updateNavConfig(StepNavigationConfig config) {
    if (_navConfig != config) {
      setState(() => _navConfig = config);
    }
  }

  void _goToNextPage() {
    if (_currentPage < _steps.length - 1) {
      context.unfocus();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      context.unfocus();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _handleExitRequest();
    }
  }

  Future<void> _handleExitRequest() async {
    final confirmed = await context.showConfirmationDialog(
      title: context.l10n.discard_changes_title,
      content: context.l10n.discard_changes_message,
      highlightCancelButton: true,
    );

    if (confirmed && mounted) {
      context.maybePop();
    }
  }

  void _onSubmit() async {
    final result = await context.showConfirmationDialog(
      title: context.l10n.submit_discard_title,
      content: context.l10n.submit_discard_message,
      confirmText: context.l10n.submit,
      cancelText: context.l10n.cancel,
    );
    if (!result) return;

    if (context.mounted) {
      _updateNavConfig(
        _navConfig.copyWith(
          isLoading: true,
          canProceed: false,
        ),
      );
      // ignore: use_build_context_synchronously
      context.read<DiscardCubit>().submitForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DiscardCubit, DiscardState>(
      listenWhen: (previous, current) => previous.submitState != current.submitState,
      listener: (context, state) {
        state.submitState.maybeWhen(
          success: () {
            context.goNamed(Routes.scan.name);
          },
          failure: (failure) {
            _updateNavConfig(
              _navConfig.copyWith(
                isLoading: false,
                canProceed: true,
              ),
            );
            context.navigator.pushTechnicalDetailsPage(failure);
          },
          submitting: () {
            _updateNavConfig(
              _navConfig.copyWith(
                isLoading: true,
                canProceed: false,
              ),
            );
          },
          orElse: () {},
        );
      },
      child: AppScaffold(
        appBar: AppBar(
          title: Text('${widget.productionOrder} - ${widget.productType.code}'),
          automaticallyImplyLeading: false,
          leading: _navConfig.showAppBarBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _navConfig.isLoading ? null : _goToPreviousPage,
                )
              : null,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(8),
            child: _ProgressHeader(currentPage: _currentPage, totalSteps: _steps.length),
          ),
        ),
        padding: EdgeInsets.zero,
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            if (_isFirstStep) {
              _handleExitRequest();
            } else {
              _goToPreviousPage();
            }
          },
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    final saved = _stepNavConfigs[index];
                    if (saved != null) {
                      _updateNavConfig(saved);
                    } else {
                      _updateNavConfig(_steps[index].defaultConfig);
                    }
                  },
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    return _buildStepContent(_steps[index], index);
                  },
                ),
              ),

              if (_navConfig.showBottomButtons)
                _BottomNavigationButtons(
                  config: _navConfig,
                  isFirstStep: _isFirstStep,
                  onBack: _goToPreviousPage,
                  onNext: _isLastStep ? _onSubmit : _goToNextPage,
                ),
            ],
          ),
        ),
        floatingActionButton: _navConfig.showFab && _navConfig.canProceed
            ? _NavigationFab(
                config: _navConfig,
                onPressed: _isLastStep ? _onSubmit : _goToNextPage,
              )
            : null,
      ),
    );
  }

  Widget _buildStepContent(DiscardFormStep step, int index) {
    final isLastStep = _steps.indexOf(step) == _steps.length - 1;

    return switch (step) {
      DiscardFormStep.employeeId => EmployeeIdStep(
        onNext: _goToNextPage,
        onNavConfigChanged: (value) => _onStepNavConfigChanged(index, value),
      ),
      DiscardFormStep.discardReason => DiscardReasonStep(
        onNext: _goToNextPage,
        onNavConfigChanged: (value) => _onStepNavConfigChanged(index, value),
      ),
      DiscardFormStep.images => ImageStep(
        onNext: _goToNextPage,
        onNavConfigChanged: (value) => _onStepNavConfigChanged(index, value),
      ),
      DiscardFormStep.note => NoteStep(
        onNext: _goToNextPage,
        onNavConfigChanged: (value) => _onStepNavConfigChanged(index, value),
      ),
      DiscardFormStep.overview => OverviewStep(
        onSubmit: _onSubmit,
        onNavConfigChanged: (value) => _onStepNavConfigChanged(index, value),
        isLastStep: isLastStep,
      ),
      // will only be used if this widget is somehow called with an invalid productType.
      DiscardFormStep.unknown => UnknownStep(
        onNavConfigChanged: (value) => _onStepNavConfigChanged(index, value),
        isLastStep: isLastStep,
        productGroup: widget.productGroup,
      ),
    };
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.currentPage,
    required this.totalSteps,
  });

  final int currentPage;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final progress = (currentPage + 1) / totalSteps;

    return Column(
      children: [
        LinearProgressIndicator(value: progress, minHeight: 8),
      ],
    );
  }
}

class _NavigationFab extends StatelessWidget {
  const _NavigationFab({
    required this.config,
    required this.onPressed,
  });

  final StepNavigationConfig config;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: config.canProceed && !config.isLoading ? onPressed : null,
      child: config.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(config.fabIcon),
    );
  }
}

class _BottomNavigationButtons extends StatelessWidget {
  const _BottomNavigationButtons({
    required this.config,
    required this.isFirstStep,
    required this.onBack,
    required this.onNext,
  });

  final StepNavigationConfig config;
  final bool isFirstStep;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (!isFirstStep || config.showAppBarBackButton) ...[
              Expanded(
                child: IconButton.outlined(
                  onPressed: config.isLoading ? null : onBack,
                  icon: Icon(config.backButtonIcon),
                ),
              ),
              Gap.vm,
            ],
            const Expanded(child: SizedBox.shrink()),
            Expanded(
              child: IconButton.outlined(
                onPressed: config.canProceed && !config.isLoading ? onNext : null,
                icon: config.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(config.nextButtonIcon),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
