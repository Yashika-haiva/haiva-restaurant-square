import 'package:go_router/go_router.dart';
import 'package:haivazoho/src/screens/helpers/agent_chat.dart';
import 'package:haivazoho/src/screens/payment_success.dart';
import 'package:haivazoho/src/service/payment_service.dart';
import '../core/request_permissions.dart';

import '../screens/connect_provider.dart';
import '../screens/dashboard.dart';
import '../screens/deploy_agent.dart';
import '../screens/forms/login.dart';
import '../screens/helpers/agent_call.dart';
import '../screens/helpers/agent_voice.dart';
import '../screens/helpers/edit_profile.dart';
import '../screens/helpers/initial_loader.dart';
import '../screens/home.dart';
import '../screens/import_provider.dart';
import '../screens/profile.dart';
import '../screens/re_deploy_agent.dart';
import '../screens/voice_options.dart';
import '../service/storage_service.dart';
import '../shared/enum.dart';

final GoRouter squareAppRoutes = GoRouter(
  restorationScopeId: 'valet_route_restore',
  initialLocation: '/',
  routes: <GoRoute>[
    GoRoute(
      name: 'initial',
      path: '/',
      builder: (context, state) => const InitialLoader(),
    ),
    GoRoute(
      name: Routes.requestPermissions.name,
      path: '/${Routes.requestPermissions.name}',
      redirect: (context, state) async => await loginAuth(false, false),
      builder: (context, state) => const RequestPermissions(),
    ),
    GoRoute(
      name: Routes.login.name,
      path: '/${Routes.login.name}',
      redirect: (context, state) async => await loginAuth(false, false),
      builder: (context, state) => const Login(),
    ),
    GoRoute(
      name: Routes.import.name,
      path: "/${Routes.import.name}",
      redirect: (context, state) async => await loginAuth(true, false),
      builder: (context, state) => const ImportProvider(),
    ),
    GoRoute(
      name: Routes.connect.name,
      path: "/${Routes.connect.name}",
      redirect: (context, state) async => await loginAuth(true, false),
      builder: (context, state) => const ConnectProvider(),
    ),
    GoRoute(
      name: Routes.home.name,
      path: "/${Routes.home.name}",
      redirect: (context, state) async => await loginAuth(true, true),
      builder: (context, state) => const Home(),
    ),
    GoRoute(
      name: Routes.paymentSuccess.name,
      path: "/${Routes.paymentSuccess.name}",
      redirect: (context, state) async => await loginAuth(true, true),
      builder: (context, state) => const PaymentSuccessPage(),
    ),
    GoRoute(
      name: Routes.profile.name,
      path: "/${Routes.profile.name}",
      redirect: (context, state) async => await loginAuth(true, true),
      builder: (context, state) => const Profile(),
    ),
    GoRoute(
      name: Routes.editProfile.name,
      path: "/${Routes.editProfile.name}",
      redirect: (context, state) async => await loginAuth(true, true),
      builder: (context, state) => const EditProfile(),
    ),
    GoRoute(
      name: Routes.dashboard.name,
      path: "/${Routes.dashboard.name}",
      redirect: (context, state) async => await loginAuth(true, true),
      builder: (context, state) => const Dashboard(),
    ),
    GoRoute(
      name: Routes.payment.name,
      path: "/${Routes.payment.name}",
      redirect: (context, state) async => await loginAuth(true, true),
      builder: (context, state) => const PaymentScreen(),
    ),
    GoRoute(
      name: Routes.voiceOptions.name,
      path: "/${Routes.voiceOptions.name}",
      redirect: (context, state) async => await loginAuth(true, true),
      builder: (context, state) {
        var extras = state.extra as Map<String, dynamic>;
        dynamic agentData = extras['agentData'];
        return VoiceOptions(
          agentData: agentData,
        );
      },
    ),
    GoRoute(
      name: Routes.agentChat.name,
      path: "/${Routes.agentChat.name}",
      redirect: (context, state) async => await loginAuth(true, true),
      builder: (context, state) {
        var extras = state.extra as Map<String, dynamic>;
        dynamic agentId = extras['agentId'];
        return ChatViewScreen(agentId: agentId);
      },
    ),
    GoRoute(
      name: Routes.agentCall.name,
      path: "/${Routes.agentCall.name}",
      redirect: (context, state) async => await loginAuth(true, true),
      builder: (context, state) {
        var extras = state.extra as Map<String, dynamic>;
        dynamic agentId = extras['agentId'];
        return CallViewScreen(agentId: agentId);
      },
    ),
    GoRoute(
      name: Routes.agentVoice.name,
      path: "/${Routes.agentVoice.name}",
      redirect: (context, state) async => await loginAuth(true, true),
      builder: (context, state) {
        var extras = state.extra as Map<String, dynamic>;
        dynamic agentId = extras['agentId'];
        return VoiceViewScreen(agentId: agentId);
      },
    ),
    GoRoute(
      name: Routes.deployAgent.name,
      path: "/${Routes.deployAgent.name}",
      redirect: (context, state) async => await loginAuth(true, true),
      builder: (context, state) {
        var extras = state.extra as Map<String, dynamic>;
        dynamic agentData = extras['agentData'];
        dynamic deployData = extras['deployData'];
        return DeployAgent(
          agentData: agentData,
          deployData: deployData,
        );
      },
    ),
    GoRoute(
      name: Routes.reDeploAgent.name,
      path: "/${Routes.reDeploAgent.name}",
      redirect: (context, state) async => await loginAuth(true, true),
      builder: (context, state) {
        var extras = state.extra as Map<String, dynamic>;
        dynamic agentData = extras['agentData'];
        dynamic agentId = extras['agentId'];
        return ReDeployAgent(
          agentData: agentData,
          agentId: agentId,
        );
      },
    ),
  ],
);

loginAuth(bool isLoggedIn, bool isConnected) async {
  if (isConnected) {
    if (await StorageService().connectToken == null) {
      if (isLoggedIn) {
        if (await StorageService().token == null) {
          return '/${Routes.login.name}';
        }
      } else {
        return '/${Routes.import.name}';
      }
    }
  } else if (isLoggedIn) {
    if (await StorageService().token == null) {
      return '/${Routes.login.name}';
    }
  } else {
    if (await StorageService().token != null) {
      String isLogin =
          await StorageService().getValueFromStorage('isFirstLogin') ?? "false";
      if (isLogin == "false") {
        StorageService()
            .createAndUpdateKeyValuePairInStorage('isFirstLogin', 'true');
      }
      if (await StorageService().connectToken != null) {
        bool isAgentExist =
            await StorageService().getValueFromStorage("agentId") != null;
        if (isAgentExist) {
          return '/${Routes.dashboard.name}';
        } else {
          return '/${Routes.home.name}';
        }
      } else {
        return '/${Routes.import.name}';
      }
    }
  }
  return null;
}
