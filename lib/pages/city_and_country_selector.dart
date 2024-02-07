import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';

class CityAndCountrySelector extends StatefulWidget {
  final Function callback;
  const CityAndCountrySelector({super.key, required this.callback});

  @override
  _CityAndCountrySelectorState createState() => _CityAndCountrySelectorState();
}

class _CityAndCountrySelectorState extends State<CityAndCountrySelector> {
  String countryValue = "";
  String stateValue = "";
  String cityValue = "";
  String address = "";

  @override
  Widget build(BuildContext context) {
    // GlobalKey<CSCPickerState> _cscPickerKey = GlobalKey();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Select Location"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  widget.callback("");
                  Navigator.pop(context);
                },
                child: const Text(
                  "See Current Location Weather?",
                  style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              const Text(
                "or",
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(
                height: 32,
              ),
              CSCPicker(
                showStates: true,
                showCities: true,
                flagState: CountryFlag.DISABLE,
                dropdownDecoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300, width: 1)),
                disabledDropdownDecoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Colors.grey.shade300,
                    border: Border.all(color: Colors.grey.shade300, width: 1)),
                countrySearchPlaceholder: "Country",
                stateSearchPlaceholder: "State",
                citySearchPlaceholder: "City",

                countryDropdownLabel: "*Country",
                stateDropdownLabel: "*State",
                cityDropdownLabel: "*City",
                defaultCountry: CscCountry.India,

                ///Disable country dropdown (Note: use it with default country)
                //disableCountry: true,

                ///Country Filter [OPTIONAL PARAMETER]

                // countryFilter: const [
                //   CscCountry.India,
                //   CscCountry.United_States,
                //   CscCountry.Canada
                // ],

                selectedItemStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),

                dropdownHeadingStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),

                dropdownItemStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),

                dropdownDialogRadius: 10.0,

                searchBarRadius: 10.0,

                onCountryChanged: (value) {
                  setState(() {
                    countryValue = value;
                  });
                },

                onStateChanged: (value) {
                  setState(() {
                    stateValue = value ?? "";
                  });
                },

                onCityChanged: (value) {
                  setState(() {
                    cityValue = value ?? "";
                  });
                },
              ),
              const SizedBox(
                height: 16,
              ),

              ///print newly selected country state and city in Text Widget
              MaterialButton(
                  onPressed: () {
                    if (cityValue.isNotEmpty) {
                      setState(() {
                        address = "$cityValue, $stateValue, $countryValue";
                      });
                      widget.callback(cityValue);
                      Navigator.pop(context);
                    }
                  },
                  color: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text(
                    "Show Weather",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  )),
              const SizedBox(
                height: 32,
              ),
              if (cityValue.isEmpty)
                const Text(
                  "Please select city !",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.red),
                )
            ],
          ),
        ),
      ),
    );
  }
}
