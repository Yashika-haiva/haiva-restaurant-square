import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../service/api_service.dart';
import '../service/storage_service.dart';
import '../shared/consts.dart';
import '../shared/enum.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _controller;
  String? _selectedProvider = "Twilio";
  String? _selectedPhoneNumber;
  String? _selectedTwilioPhoneNumber;
  bool areAllFieldsFilled = false;
  bool isNumberNotNull = false;
  bool isTwilioActive = false;
  List<Map<String, dynamic>> availableHaivaPhoneNumbers = [];
  List<String> availableTwilioPhoneNumbers = [];
  bool _isFieldsVisible = true;
  var agentConfigs = {};
  String formattedBalance = "\$0.00";

  final TextEditingController _accountSidController = TextEditingController();
  final TextEditingController _authTokenController = TextEditingController();

  void checkFieldsFilled() {
    if (_accountSidController.text.isNotEmpty &&
        _authTokenController.text.isNotEmpty) {
      setState(() {
        areAllFieldsFilled = true;
      });
    } else {
      setState(() {
        areAllFieldsFilled = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener(() {
      if (!_controller.indexIsChanging) {}
    });
    getHaivaNumbers();
    getAgentTemplate();
    getBalance();
  }

  getAgentTemplate() async {
    final response = await APIService().getAgentTemplates();
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final List responseBody = decodedResponse;
      for (var template in responseBody) {
        String templateName = template['templateName'];
        String producer = template['serviceProvider']['producer'];
        if (templateName == "Agent for Restaurants" && producer == 'square') {
          agentConfigs = template['agentConfigObject'];
        }
      }
    }
  }

  getBalance() async {
    final responseForBalance = await APIService().getBalance();
    if (responseForBalance.statusCode == 200) {
      final decodedResponseForBalance =
          jsonDecode(utf8.decode(responseForBalance.bodyBytes));
      final responseBodyForAgent = decodedResponseForBalance;
      setState(() {
        final balance = responseBodyForAgent['availableBalance'] ?? 0.00;
        formattedBalance = balance.toStringAsFixed(2);
      });
    }
  }

  getHaivaNumbers() async {
    final response = await APIService().getAvailableHaivaNumbers();

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final List responseBody = decodedResponse;
      setState(() {
        // Store the phone numbers with their isLinked status
        availableHaivaPhoneNumbers = responseBody.map((item) {
          return {
            'phoneNumber': item['phoneNumber'],
            'isLinked': item['isLinked'],
          };
        }).toList();
      });
    }
  }

  callSnackBar(response, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            '$text',
            style: const TextStyle(color: whiteColor),
          ),
        ),
        backgroundColor:
            (response.statusCode == 201 || response.statusCode == 200)
                ? successColor
                : errorColor,
      ),
    );
  }

  checkTwilioConnection(String authToken, String sid) async {
    final response = await APIService().checkTwilioConnection(authToken, sid);
    if (response.statusCode == 200) {
      callSnackBar(response, "Connection Success");
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final responseBody = decodedResponse;
      if (responseBody["status"] == "active") {
        setState(() {
          agentConfigs['agent_configs']['telephony_configs']['account_sid'] =
              sid;
          agentConfigs['agent_configs']['telephony_configs']['auth_token'] =
              authToken;
          agentConfigs['agent_configs']['telephony_configs']
              ['is_connection_verified'] = true;
          isTwilioActive = true;
          _isFieldsVisible = false;
        });
        getTwilioNumbers(authToken, sid);
      } else {
        agentConfigs['agent_configs']['telephony_configs']['account_sid'] = sid;
        agentConfigs['agent_configs']['telephony_configs']['auth_token'] =
            authToken;
        agentConfigs['agent_configs']['telephony_configs']
            ['is_connection_verified'] = false;
      }
    }
  }

  getTwilioNumbers(String authToken, String sid) async {
    final response = await APIService().getTwilioNumbers(authToken, sid);
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final responseBody = decodedResponse["phone_numbers"];
      setState(() {
        // Store the phone numbers with their isLinked status
        availableTwilioPhoneNumbers = responseBody
            .map<String>((item) => item['phone_number'] as String)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // getAgentTemplate();
    List<Widget> tabBarViews = [
      SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Choose a number purchased through Haiva or buy a new number",
                    style: TextStyle(fontSize: 14, color: secondaryColor),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    dropdownColor: whiteColor,
                    onTap: () async {
                      await getHaivaNumbers();
                    },
                    isExpanded: true,
                    value: _selectedPhoneNumber,
                    onChanged: (String? newValue) {
                      setState(() {
                        agentConfigs['agent_configs']['telephony_configs']
                            ['phone_number'] = newValue;
                        StorageService().createAndUpdateKeyValuePairInStorage(
                            "phone_number", newValue);
                        agentConfigs['agent_configs']['telephony_configs']
                            ['account_sid'] = '';
                        agentConfigs['agent_configs']['telephony_configs']
                            ['auth_token'] = '';
                        agentConfigs['agent_configs']['telephony_configs']
                            ['is_connection_verified'] = false;
                        _selectedPhoneNumber = newValue;
                      });
                      isNumberThere();
                    },
                    hint: const Text(
                      "Select Phone Number",
                      style: textStyleS14W400,
                    ),
                    items: availableHaivaPhoneNumbers.isEmpty
                        ? [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text(
                                'No available numbers',
                                style: textStyleS14W400,
                              ),
                            ),
                          ]
                        : availableHaivaPhoneNumbers
                            .map<DropdownMenuItem<String>>((
                            Map<String, dynamic> value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value['phoneNumber'],
                              enabled: value['isLinked'] ?? false,
                              child: Text(
                                value['phoneNumber'],
                                style: TextStyle(
                                  color: value['isLinked'] ?? false
                                      ? blackColor
                                      : disabledColor,
                                ),
                              ),
                            );
                          }).toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    onPressed: _openBuyNumberDialog,
                    child: Text(
                      "Buy Number",
                      style: textStyleS14W400.copyWith(color: whiteColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Visibility(
                          visible: _isFieldsVisible,
                          child: Column(
                            children: [
                              const Text(
                                'Connect your Twilio account to access your phone numbers. Enter your Twilio credentials to connect.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: secondaryColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Account SID',
                                    textAlign: TextAlign.start,
                                  )),
                              TextField(
                                onChanged: (text) {
                                  checkFieldsFilled();
                                },
                                controller: _accountSidController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'ACXXXXX',
                                  hintStyle: const TextStyle(
                                    color: hintTextColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                      color: primaryColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                      color: primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                      color: primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Align(
                                  alignment: Alignment.topLeft,
                                  child: Text('Auth Token')),
                              TextField(
                                onChanged: (text) {
                                  checkFieldsFilled();
                                },
                                controller: _authTokenController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Enter your Auth Token',
                                  hintStyle: const TextStyle(
                                    color: hintTextColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                      color: primaryColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                      color: primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                      color: primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: areAllFieldsFilled
                                    ? () {
                                        checkTwilioConnection(
                                          _authTokenController.value.text,
                                          _accountSidController.value.text,
                                        );
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  minimumSize: const Size(double.infinity, 40),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.link, color: whiteColor),
                                    SizedBox(width: 8),
                                    Text('Establish a connection'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isTwilioActive) const SizedBox(height: 16),
                        if (isTwilioActive)
                          DropdownButton<String>(
                            dropdownColor: whiteColor,
                            isExpanded: true,
                            value: _selectedTwilioPhoneNumber,
                            onChanged: (String? newValue) {
                              setState(() {
                                agentConfigs['agent_configs']
                                        ['telephony_configs']['phone_number'] =
                                    newValue;
                                StorageService()
                                    .createAndUpdateKeyValuePairInStorage(
                                        "phone_number", newValue);
                                _selectedTwilioPhoneNumber = newValue;
                              });
                              isNumberThere();
                            },
                            hint: const Text("Select Phone Number"),
                            items: availableTwilioPhoneNumbers.isEmpty
                                ? [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('No available numbers'),
                                    ),
                                  ]
                                : availableTwilioPhoneNumbers
                                    .map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                          ),
                        if (isTwilioActive)
                          Center(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _isFieldsVisible = !_isFieldsVisible;
                                });
                              },
                              child: Text(
                                _isFieldsVisible
                                    ? "Hide Twilio Connection"
                                    : "Show Twilio Connection",
                                style: textStyleS16W600.copyWith(
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Telephony',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        elevation: 10,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "\$$formattedBalance",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        "Telephony Provider",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      Tooltip(
                        message: 'Select the preferred telephony provider.',
                        child: Icon(Icons.info, color: Colors.blue, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    dropdownColor: whiteColor,
                    isExpanded: true,
                    value: _selectedProvider,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedProvider = newValue;
                      });
                    },
                    items: <String>['Twilio'].map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style:
                              const TextStyle(color: blackColor, fontSize: 14),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        "Phone Number Configuration",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      Tooltip(
                        message:
                            'Select the Twilio phone number to enable call functionality.',
                        child: Icon(Icons.info, color: Colors.blue, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TabBar(
                    indicator: const BoxDecoration(
                      color: primaryLightColor,
                      border: Border(
                        bottom: BorderSide(
                          color: primaryColor,
                          width: 4.0,
                        ),
                      ),
                    ),
                    labelColor: primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: primaryColor,
                    indicatorWeight: 4,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(
                        child: Text(
                          "My Haiva Numbers",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Connect to Twilio",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                    controller: _controller,
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(controller: _controller, children: tabBarViews),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: isNumberNotNull
                ? () {
                    context.push('/${Routes.voiceOptions.name}',
                        extra: {'agentData': agentConfigs});
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: const Size(double.infinity, 40),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Proceed to Voice Options'),
                SizedBox(width: 8),
                Icon(Icons.arrow_circle_right_outlined, color: whiteColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  isNumberThere() {
    if (_selectedPhoneNumber != null || _selectedTwilioPhoneNumber != null) {
      setState(() {
        isNumberNotNull = true;
      });
    } else {
      setState(() {
        isNumberNotNull = false;
      });
    }
  }

  void _openBuyNumberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const BuyDialog();
      },
    );
  }
}

class BuyDialog extends StatefulWidget {
  const BuyDialog({super.key});

  @override
  State<BuyDialog> createState() => _BuyDialogState();
}

class _BuyDialogState extends State<BuyDialog> {
  String? _selectedPhoneNumberToBuy;
  String selectedCountryCode = "US";
  final TextEditingController _digitController = TextEditingController();
  List<String> availablePhoneNumbersToBuy = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrSearchAvailableNumbers("twilio", selectedCountryCode, '');
  }

  getOrSearchAvailableNumbers(
    String provider,
    String country,
    String searchTerm,
  ) async {
    final response = await APIService().getOrSearchAvailableNumbersToBuy(
      provider,
      country,
      searchTerm,
    );
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final List responseBody = decodedResponse['numbers'];
      setState(() {
        availablePhoneNumbersToBuy = responseBody
            .map<String>((item) => item['number'] as String)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: whiteColor,
      backgroundColor: whiteColor,
      title: const Text("Buy Phone Number"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose your country and, if desired, specify a pattern. For example, If you're looking for numbers in the United Kingdom starting with '750', type '750' and the results will show as '44750XXXXXXX'",
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 10),
            const Divider(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CountryCodePicker(
                    onChanged: (countryCode) {
                      setState(() {
                        selectedCountryCode = countryCode.code!;
                      });
                      getOrSearchAvailableNumbers(
                        "twilio",
                        selectedCountryCode,
                        '',
                      );
                    },
                    initialSelection: 'US',
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                    showDropDownButton: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 4),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _digitController,
                        decoration: InputDecoration(
                          hintText: 'Digits',
                          hintStyle: const TextStyle(
                            color: hintTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: const BorderSide(color: primaryColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: const BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: const BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                    ),
                    onPressed: () {
                      getOrSearchAvailableNumbers(
                        "twilio",
                        selectedCountryCode,
                        _digitController.value.text,
                      );
                    },
                    child: const Icon(Icons.search, color: whiteColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButton<String>(
                dropdownColor: whiteColor,
                menuMaxHeight: 184,
                isExpanded: true,
                value: _selectedPhoneNumberToBuy,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPhoneNumberToBuy = newValue;
                  });
                },
                hint: const Text(
                  "Select Phone Number",
                  style: textStyleS14W400,
                ),
                items: availablePhoneNumbersToBuy.isEmpty
                    ? [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('No available numbers'),
                        ),
                      ]
                    : availablePhoneNumbersToBuy
                        .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Align(
              alignment: Alignment.centerLeft, child: Text("Cancel")),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: const Size(double.infinity, 40),
          ),
          onPressed: (_selectedPhoneNumberToBuy != null)
              ? () {
                  checkCreditsAndCallBuyNumberAPI();
                }
              : null,
          child: const Text("Buy Number"),
        ),
      ],
    );
  }

  checkCreditsAndCallBuyNumberAPI() async {
    final response = await APIService().checkCredits();
    if (response.statusCode == 200) {
      buyNumberOnCredits();
    } else if (response.statusCode == 400) {
      _openInsufficientCreditsDialog();
    }
  }

  buyNumberOnCredits() async {
    final requestBody = {"phone_number": _selectedPhoneNumberToBuy};
    final response = await APIService().buyHaivaNumbers(requestBody);
    if (response.statusCode == 200) {
      onBuySuccess();
    }
  }

  onBuySuccess() {
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Number successfully Purchased',
          style: TextStyle(color: whiteColor),
        ),
        backgroundColor: errorColor,
      ),
    );
  }

  void _openInsufficientCreditsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const InsufficientCreditsDialog();
      },
    );
  }
}

class InsufficientCreditsDialog extends StatefulWidget {
  const InsufficientCreditsDialog({super.key});

  @override
  State<InsufficientCreditsDialog> createState() =>
      _InsufficientCreditsDialogState();
}

class _InsufficientCreditsDialogState extends State<InsufficientCreditsDialog> {
  final TextEditingController creditAmountController = TextEditingController();
  bool areAllFieldsFilled = false;

  void checkFieldsFilled() {
    if (creditAmountController.text.isNotEmpty) {
      setState(() {
        areAllFieldsFilled = true;
      });
    } else {
      setState(() {
        areAllFieldsFilled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: whiteColor,
      backgroundColor: whiteColor,
      title: const Text("Insufficient Credits"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const ColoredBox(
              color: primaryLightColor,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Your account does not have sufficient credits to complete this purchase. Free credits cannot be applied for this transaction.",
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Divider(
              height: 2,
              color: blackColor,
            ),
            const SizedBox(height: 10),
            TextField(
              onChanged: (text) {
                checkFieldsFilled();
              },
              keyboardType: TextInputType.number,
              controller: creditAmountController,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Enter Payment Amount *',
                hintStyle: const TextStyle(
                  color: hintTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: areAllFieldsFilled
              ? () {
                  addCreditsAPI(creditAmountController.value.text);
                }
              : null,
          child: const Text("Add to Credits"),
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri launchingUrl = Uri.parse(url);
    if (!await launchUrl(launchingUrl)) {
      throw Exception('Could not launch $url');
    }
    popDialog();
  }

  popDialog() {
    context.pop();
  }

  addCreditsAPI(amount) async {
    final response = await APIService().addCredits(amount);
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final responseBodyUrl = decodedResponse["url"];
      _launchURL(responseBodyUrl);
    } else if (response.statusCode == 400) {
      callSnackBar(response);
    }
  }

  callSnackBar(response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Credits Not added. Status: ${response.statusCode}',
          style: const TextStyle(color: whiteColor),
        ),
        backgroundColor: errorColor,
      ),
    );
  }
}
