import 'package:flutter/material.dart';
import 'package:haivazoho/src/service/agent_data_provider.dart';
import 'package:haivazoho/src/service/web_view_auth.dart';
import 'package:provider/provider.dart';

import 'core/agent_theme.dart';
import 'core/routes.dart';

class Square extends StatelessWidget {
  const Square({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AgentDataProvider(),
      child: Consumer<AgentDataProvider>(
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
