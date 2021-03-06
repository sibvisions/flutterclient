import 'package:flutter/material.dart';

import '../../../models/state/routes/arguments/settings_page_arguments.dart';
import '../../../models/state/routes/routes.dart';
import '../../../services/remote/cubit/api_cubit.dart';
import '../../../util/translation/app_localizations.dart';

showGoToSettingsDialog(BuildContext context, ApiError error) async {
  final bool canPop = ModalRoute.of(context)!.settings.name != '/';
  await showDialog(
      context: context,
      barrierDismissible: canPop,
      builder: (context) {
        return AlertDialog(
          title: Text(
              AppLocalizations.of(context)!.text('${error.failure.title}')),
          content: Text(
              AppLocalizations.of(context)!.text('${error.failure.message}')),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.settings, (route) => false,
                      arguments: SettingsPageArguments(
                          canPop: canPop, hasError: true));
                },
                child: Text(AppLocalizations.of(context)!.text('To Settings'))),
          ],
        );
      });
}
