
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/agent_theme.dart';
import 'core/routes.dart';
import 'service/auth_service.dart';
import 'shared/provider/agent_provider.dart';

class Square extends StatelessWidget {
  const Square({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AgentProvider(),
      child: Consumer<AgentProvider>(
        builder: (context, agentProvider, child) {
          return MultiProvider(
            providers: [Provider<AuthService>(create: (_) => AuthService())],
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: "Square",
              theme: agentTheme,
              routerConfig: squareAppRoutes,
            ),
          );
        },
      ),
    );
  }
}
