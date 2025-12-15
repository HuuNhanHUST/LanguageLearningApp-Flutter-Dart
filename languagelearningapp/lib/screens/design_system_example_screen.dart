import 'package:flutter/material.dart';
import '../core/design_system.dart';

/// Example Screen - Demo cách sử dụng Design System
/// 
/// Screen này minh họa:
/// - AppColors
/// - AppSpacing
/// - AppTextStyles
/// - AppDecorations
class DesignSystemExampleScreen extends StatelessWidget {
  const DesignSystemExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Demo'),
        // AppBar tự động dùng theme từ AppTheme
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================================================================
            // SECTION 1: COLORS
            // ================================================================
            Text(
              '🎨 Colors',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _ColorChip('Primary', AppColors.primary),
                _ColorChip('Success', AppColors.success),
                _ColorChip('Warning', AppColors.warning),
                _ColorChip('Error', AppColors.error),
                _ColorChip('Info', AppColors.info),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // ================================================================
            // SECTION 2: TYPOGRAPHY
            // ================================================================
            Text(
              '✍️ Typography',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: AppDecorations.containerLight(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Display Large', style: AppTextStyles.displayLarge),
                  Text('Headline Medium', style: AppTextStyles.headlineMedium),
                  Text('Title Large', style: AppTextStyles.titleLarge),
                  Text('Body Medium (Serif)', style: AppTextStyles.bodyMedium),
                  Text('Label Large', style: AppTextStyles.labelLarge),
                  Text('Caption', style: AppTextStyles.caption),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // ================================================================
            // SECTION 3: CARDS
            // ================================================================
            Text(
              '🎁 Card Decorations',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Basic Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: AppDecorations.card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Card',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Card với border nhẹ và shadow',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Primary Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: AppDecorations.cardPrimary(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Primary Card',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Card với primary border - dùng cho highlight',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Gradient Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: AppDecorations.cardGradient(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gradient Card',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textOnDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Card với gradient background',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textOnDark,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // ================================================================
            // SECTION 4: SEMANTIC CONTAINERS
            // ================================================================
            Text(
              '📦 Semantic Containers',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: AppDecorations.containerSuccess(),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Success Container',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: AppDecorations.containerWarning(),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Warning Container',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: AppDecorations.containerError(),
              child: Row(
                children: [
                  const Icon(Icons.error, color: AppColors.error),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Error Container',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // ================================================================
            // SECTION 5: BUTTONS
            // ================================================================
            Text(
              '🔘 Buttons',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Elevated Button (sử dụng theme mặc định)
            ElevatedButton(
              onPressed: () {},
              child: const Text('Elevated Button'),
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            // Outlined Button (sử dụng theme mặc định)
            OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined Button'),
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            // Text Button (sử dụng theme mặc định)
            TextButton(
              onPressed: () {},
              child: const Text('Text Button'),
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            // Custom Button với success color
            ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              icon: const Icon(Icons.check),
              label: const Text('Success Button'),
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            // Custom Button với warning color
            ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
              ),
              icon: const Icon(Icons.warning),
              label: const Text('Warning Button'),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // ================================================================
            // SECTION 6: INPUT FIELDS
            // ================================================================
            Text(
              '📝 Input Fields',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            
            // TextField với decoration từ theme
            TextField(
              decoration: AppDecorations.input(
                labelText: 'Username',
                hintText: 'Enter your username',
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            TextField(
              decoration: AppDecorations.input(
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // ================================================================
            // SECTION 7: TEXT CONTENT (OCR Style)
            // ================================================================
            Text(
              '📖 Text Content (OCR Style)',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: AppDecorations.containerLight(),
              constraints: const BoxConstraints(
                maxHeight: AppSpacing.scrollableMaxHeight,
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  'This is an example of readable text with serif font. '
                  'The line height is set to 2.0 for comfortable reading. '
                  'Letter spacing and word spacing are optimized. '
                  'This style is perfect for displaying OCR recognized text.\n\n'
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                  'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                  'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // ================================================================
            // SECTION 8: CHIPS
            // ================================================================
            Text(
              '🏷️ Chips',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                Chip(
                  label: const Text('Offline'),
                  avatar: const Icon(Icons.offline_bolt, size: 18),
                  backgroundColor: AppColors.successBackground,
                ),
                Chip(
                  label: const Text('Online'),
                  avatar: const Icon(Icons.wifi, size: 18),
                  backgroundColor: AppColors.infoBackground,
                ),
                Chip(
                  label: const Text('Processing'),
                  avatar: const Icon(Icons.sync, size: 18),
                  backgroundColor: AppColors.warningBackground,
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}

// Helper Widget - Color Chip
class _ColorChip extends StatelessWidget {
  final String label;
  final Color color;
  
  const _ColorChip(this.label, this.color);
  
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: AppTextStyles.labelSmall),
      avatar: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
