import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeModeControllerProvider);
    final cacheSettingsAsync = ref.watch(cacheSettingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          // Theme Settings
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Appearance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text("System"),
                  icon: Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text("Light"),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text("Dark"),
                  icon: Icon(Icons.dark_mode),
                ),
              ],
              selected: {themeModeAsync.value ?? ThemeMode.system},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                ref
                    .read(themeModeControllerProvider.notifier)
                    .setThemeMode(newSelection.first);
              },
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Date Format",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Consumer(
              builder: (context, ref, child) {
                final formatAsync = ref.watch(dateFormatControllerProvider);
                return formatAsync.when(
                  data: (currentFormat) => SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'dd/MM/yyyy',
                        label: Text("DD/MM/YYYY"),
                      ),
                      ButtonSegment(
                        value: 'yyyy/MM/dd',
                        label: Text("YYYY/MM/DD"),
                      ),
                    ],
                    selected: {currentFormat},
                    onSelectionChanged: (Set<String> newSelection) {
                      ref
                          .read(dateFormatControllerProvider.notifier)
                          .setDateFormat(newSelection.first);
                    },
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, s) => Text("Error: $e"),
                );
              },
            ),
          ),
          const Divider(),

          // Analytics Settings
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Analytics",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final windowAsync = ref.watch(
                analyticsSettingsControllerProvider,
              );
              return windowAsync.when(
                data: (weeks) => ListTile(
                  title: const Text("Weekday Analysis Window"),
                  subtitle: Text("Calculate stats based on last $weeks weeks"),
                  trailing: DropdownButton<int>(
                    value: weeks,
                    items: const [
                      DropdownMenuItem(value: 4, child: Text("4 Weeks")),
                      DropdownMenuItem(value: 6, child: Text("6 Weeks")),
                      DropdownMenuItem(value: 8, child: Text("8 Weeks")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref
                            .read(analyticsSettingsControllerProvider.notifier)
                            .setWindow(val);
                      }
                    },
                  ),
                ),
                loading: () => const SizedBox(
                  height: 50,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, s) => Text("Error: $e"),
              );
            },
          ),
          const Divider(),

          // Cache Settings
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Cache Management",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          cacheSettingsAsync.when(
            data: (settings) => Column(
              children: [
                ListTile(
                  title: const Text("Automatic Cache Clearing"),
                  subtitle: Text(
                    "Frequency: ${_getFrequencyLabel(settings.frequency)}",
                  ),
                  trailing: DropdownButton<String>(
                    value: settings.frequency,
                    items: const [
                      DropdownMenuItem(value: 'never', child: Text("Never")),
                      DropdownMenuItem(
                        value: 'week',
                        child: Text("Every Week"),
                      ),
                      DropdownMenuItem(
                        value: 'month',
                        child: Text("Every Month"),
                      ),
                      DropdownMenuItem(
                        value: 'year',
                        child: Text("Every Year"),
                      ),
                      DropdownMenuItem(
                        value: 'custom',
                        child: Text("Custom Days"),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref
                            .read(cacheSettingsControllerProvider.notifier)
                            .updateFrequency(val);
                      }
                    },
                  ),
                ),
                if (settings.frequency == 'custom')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        const Text("Clear every "),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            initialValue: settings.customDays.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              final days = int.tryParse(val);
                              if (days != null && days > 0) {
                                ref
                                    .read(
                                      cacheSettingsControllerProvider.notifier,
                                    )
                                    .updateCustomDays(days);
                              }
                            },
                          ),
                        ),
                        const Text(" days"),
                      ],
                    ),
                  ),
                ListTile(
                  title: const Text("Manual Clear Cache"),
                  subtitle: const Text("Select a date to clear cache before"),
                  trailing: const Icon(Icons.delete_sweep),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );

                    if (date != null) {
                      if (!context.mounted) return;
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Confirm Clear Cache"),
                          content: Text(
                            "Are you sure you want to clear cache files older than ${DateFormat.yMMMd().format(date)}?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text(
                                "Clear",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        try {
                          await ref
                              .read(cacheServiceProvider.notifier)
                              .clearCacheBefore(date);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Cache cleared successfully"),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error clearing cache: $e"),
                              ),
                            );
                          }
                        }
                      }
                    }
                  },
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text("Error: $e")),
          ),
          const Divider(),

          // About Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "About",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text("Privacy Policy"),
            subtitle: const Text("Read our privacy policy"),
            onTap: () async {
              final Uri url = Uri.parse(
                'https://sarangnaik26.github.io/Platterlytics/',
              );
              try {
                if (!await launchUrl(url)) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Could not launch privacy policy"),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error launching privacy policy: $e"),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  String _getFrequencyLabel(String val) {
    switch (val) {
      case 'week':
        return 'Weekly';
      case 'month':
        return 'Monthly';
      case 'year':
        return 'Yearly';
      case 'custom':
        return 'Custom';
      case 'never':
        return 'Never';
      default:
        return val;
    }
  }
}
