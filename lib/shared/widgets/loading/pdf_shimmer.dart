import 'package:flitpdf/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class PdfShimmer extends StatefulWidget {
  const PdfShimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE7EBF0),
    this.highlightColor = const Color(0xFFF8FAFC),
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  @override
  State<PdfShimmer> createState() => _PdfShimmerState();
}

class _PdfShimmerState extends State<PdfShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            final double width = bounds.width <= 0 ? 1 : bounds.width;
            final double shimmerPosition = (_controller.value * 2) - 1;

            return LinearGradient(
              begin: Alignment(-1.4 + shimmerPosition, -0.25),
              end: Alignment(1.4 + shimmerPosition, 0.25),
              colors: <Color>[
                widget.baseColor,
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
                widget.baseColor,
              ],
              stops: const <double>[0.0, 0.35, 0.5, 0.65, 1.0],
              transform: _SlidingGradientTransform(width * shimmerPosition),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.slidePercent);

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(slidePercent, 0, 0);
  }
}

class PdfShimmerBox extends StatelessWidget {
  const PdfShimmerBox({
    super.key,
    this.width,
    this.height = 10,
    this.radius = 12,
    this.margin,
    this.color = const Color(0xFFE4E9EF),
    this.value, // optional for determinate progress
  });

  final double? width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final double? value; // null = indeterminate

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      margin: margin,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: LinearProgressIndicator(
          value: value, // if null → animated
          minHeight: height,
          backgroundColor: color,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }
}

class PdfLoadingOverlay extends StatelessWidget {
  const PdfLoadingOverlay({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Container(
          color: Colors.black.withValues(alpha: 0.18),
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const PdfShimmerBox(
                    margin: EdgeInsets.symmetric(vertical: 4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImagePreviewLoading extends StatelessWidget {
  const ImagePreviewLoading({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return PdfShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE4E9EF),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            color: AppColors.textSecondary,
            size: 32,
          ),
        ),
      ),
    );
  }
}
