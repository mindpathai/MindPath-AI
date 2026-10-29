import 'package:flutter/material.dart';

import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/theme/app_typography.dart';
import 'package:mindpath_ai/widgets/form_message.dart';
import 'package:mindpath_ai/widgets/line_icon.dart';

/// The design's `.field`: a screen-coloured box (radius 15, 1px line
/// border) with a small uppercase label above the value.
///
/// Stays quiet until first blurred, then validates on every change.
/// Set [isPassword] for an obscured field with a show/hide toggle.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.isPassword = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final bool isPassword;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focus = FocusNode();
  bool _touched = false;
  bool _obscured = true;

  // Material draws a floating label at 75% of its style, so the label
  // style is scaled up by 1/0.75 to render at exactly 11.5px.
  static const double _floatingScale = 0.75;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focus.hasFocus && !_touched) setState(() => _touched = true);
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hidden = widget.isPassword && _obscured;
    final label = AppTypography.fieldLabel;
    final labelStyle = label.copyWith(
      fontSize: label.fontSize! / _floatingScale,
      letterSpacing: label.letterSpacing! / _floatingScale,
    );

    return TextFormField(
      controller: widget.controller,
      focusNode: _focus,
      validator: widget.validator,
      errorBuilder: (context, error) => ErrorLine(error),
      autovalidateMode: _touched
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
      keyboardType: widget.isPassword
          ? TextInputType.visiblePassword
          : widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      obscureText: hidden,
      enableSuggestions: !widget.isPassword,
      autocorrect: !widget.isPassword,
      onFieldSubmitted: widget.onSubmitted,
      style: AppTypography.field.copyWith(
        letterSpacing: hidden ? AppSpace.s3 : null,
      ),
      cursorColor: AppColors.pine,
      decoration: InputDecoration(
        labelText: widget.label.toUpperCase(),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: labelStyle,
        floatingLabelStyle: labelStyle,
        filled: true,
        fillColor: AppColors.screen,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpace.s15,
          vertical: AppSpace.s13,
        ),
        border: const _FieldBorder(),
        enabledBorder: const _FieldBorder(),
        focusedBorder: const _FieldBorder(
          borderSide: BorderSide(
            color: AppColors.pine,
            width: AppSizes.outline,
          ),
        ),
        errorBorder: const _FieldBorder(
          borderSide: BorderSide(color: AppColors.clay),
        ),
        focusedErrorBorder: const _FieldBorder(
          borderSide: BorderSide(
            color: AppColors.clay,
            width: AppSizes.outline,
          ),
        ),
        errorMaxLines: 2,
        suffixIcon: widget.isPassword
            ? IconButton(
                tooltip: hidden ? 'Show password' : 'Hide password',
                icon: LineIcon(
                  hidden ? LineGlyphs.eye : LineGlyphs.eyeOff,
                  color: AppColors.ink3,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
      ),
    );
  }
}

/// A full rounded-rectangle border that, unlike [OutlineInputBorder],
/// keeps the floating label inside the box instead of notching the line.
class _FieldBorder extends InputBorder {
  const _FieldBorder({
    super.borderSide = const BorderSide(
      color: AppColors.edge,
      width: AppSizes.hairline,
    ),
  });

  RRect _shape(Rect rect) =>
      RRect.fromRectAndRadius(rect, const Radius.circular(AppRadius.field));

  @override
  bool get isOutline => false;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderSide.width);

  @override
  _FieldBorder copyWith({BorderSide? borderSide}) =>
      _FieldBorder(borderSide: borderSide ?? this.borderSide);

  @override
  _FieldBorder scale(double t) => _FieldBorder(borderSide: borderSide.scale(t));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_shape(rect));

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_shape(rect).deflate(borderSide.width));

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    canvas.drawRRect(
      _shape(rect).deflate(borderSide.width / 2),
      borderSide.toPaint(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is _FieldBorder && other.borderSide == borderSide;

  @override
  int get hashCode => borderSide.hashCode;
}
