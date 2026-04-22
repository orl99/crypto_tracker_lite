import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_tracker_lite/l10n/app_localizations.dart';
import '../bloc/locale_bloc.dart';
import '../pages/profile_page.dart';
import '../pages/favorites_page.dart';
import '../theme/app_colors.dart';

class SideMenuDrawer extends StatelessWidget {
  const SideMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Drawer(
      backgroundColor: AppColors.card,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 250,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.card,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(color: AppColors.gold, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://practicaltyping.com/wp-content/uploads/2019/06/Hinata.PNG.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bryan Vazquez',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email_outlined, color: Colors.grey[400], size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'bryan@correo.com',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.star,
            iconColor: AppColors.gold,
            borderColor: AppColors.gold.withValues(alpha: 0.3),
            text: l10n.favorites,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesPage()));
            },
          ),
          const SizedBox(height: 16),
          _buildDrawerItem(
            icon: Icons.person,
            iconColor: AppColors.blue,
            borderColor: AppColors.blue.withValues(alpha: 0.3),
            text: l10n.profile,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
          ),
          const SizedBox(height: 16),
          _buildDrawerItem(
            icon: Icons.settings,
            iconColor: Colors.grey,
            borderColor: Colors.grey.withValues(alpha: 0.3),
            text: l10n.settings,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 24),
          // ── Language Selector ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gradientStart,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.2), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.language, color: AppColors.warning, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l10n.language,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  BlocBuilder<LocaleBloc, LocaleState>(
                    builder: (context, state) {
                      return DropdownButton<Locale>(
                        value: state.locale,
                        dropdownColor: AppColors.card,
                        underline: const SizedBox.shrink(),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        items: [
                          DropdownMenuItem(
                            value: const Locale('es'),
                            child: Text(l10n.spanish, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          ),
                          DropdownMenuItem(
                            value: const Locale('en'),
                            child: Text(l10n.english, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          ),
                        ],
                        onChanged: (locale) {
                          if (locale != null) {
                            context.read<LocaleBloc>().add(ChangeLocale(locale));
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.gradientStart,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
