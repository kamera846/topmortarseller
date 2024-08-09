import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';
import 'package:topmortarseller/widget/form/textfield/text_field.dart';

class NewRekeningScreen extends StatefulWidget {
  const NewRekeningScreen({super.key});

  @override
  State<NewRekeningScreen> createState() => _NewRekeningScreenState();
}

class _NewRekeningScreenState extends State<NewRekeningScreen> {
  final List<String> options = [
    '== Pilih Bank ==',
    '1 PT. BCA (Bank Central Asia) TBK',
    '2 BNI (PT. Bank Nasional Indonesia)',
    '3 PT. BCA (Bank Central Asia) TBK',
    '4 BNI (PT. Bank Nasional Indonesia)',
    '5 PT. BCA (Bank Central Asia) TBK',
    '6 BNI (PT. Bank Nasional Indonesia)',
    '7 PT. BCA (Bank Central Asia) TBK',
    '8 BNI (PT. Bank Nasional Indonesia)',
  ];
  String? _selectedBank = '== Pilih Bank ==';
  final _noRekeningController = TextEditingController();
  final _ownerNameController = TextEditingController();

  String? _selectedErrorText;
  String? _noRekeningErrorText;
  String? _ownerNameErrorText;

  bool isValidForm = false;

  void _checkOwnerName() {
    if (_selectedBank == options[0]) {
      setState(() {
        _selectedErrorText = 'Pilih Bank Anda';
      });
      return;
    } else {
      setState(() {
        _selectedErrorText = null;
      });
    }

    if (_noRekeningController.text.isEmpty) {
      setState(() {
        _noRekeningErrorText = 'Anda belum mengisi kolom nomor rekening!';
        _ownerNameController.text = '';
        _ownerNameErrorText = null;
      });
      return;
    } else {
      setState(() {
        _noRekeningErrorText = null;
        _ownerNameController.text = '';
        _ownerNameErrorText = null;
      });
    }

    if (_noRekeningController.text == '12345') {
      setState(() {
        _noRekeningErrorText = null;
        _ownerNameController.text = 'Mochammad Rafli Ramadani';
        _ownerNameErrorText = null;
        isValidForm = true;
      });
    } else {
      setState(() {
        _noRekeningErrorText = null;
        _ownerNameController.text = '';
        _ownerNameErrorText =
            'Tidak dapat menemukan nomor rekening atau e-wallet.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Rekening Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Rekening anda akan digunakan sebagai tujuan transfer dari promo-promo kami.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SelectBankField(
              options: options,
              errorText: _selectedErrorText,
              onChange: (value) {
                setState(() {
                  _selectedBank = value;
                });
              },
            ),
            MTextField(
                controller: _noRekeningController,
                label: 'Nomor Rekening atau E-Wallet',
                keyboardType: TextInputType.number,
                errorText: _noRekeningErrorText,
                onChanged: (value) {}),
            MElevatedButton(
              title: 'Cek Nama Pemilik',
              onPressed: _checkOwnerName,
            ),
            const SizedBox(height: 12),
            if (_ownerNameController.text.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(width: 1, color: cDark400),
                ),
                child: Text(
                  _ownerNameController.text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: cDark200, fontWeight: FontWeight.bold),
                ),
              ),
            if (_ownerNameErrorText != null && _ownerNameErrorText!.isNotEmpty)
              Text(
                _ownerNameErrorText!,
                style: const TextStyle(color: cPrimary100),
              ),
            Expanded(
              child: Container(),
            ),
            MElevatedButton(
              title: 'Simpan Rekening',
              isFullWidth: true,
              enabled: isValidForm ? true : false,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class SelectBankField extends StatefulWidget {
  const SelectBankField({
    super.key,
    required this.onChange,
    required this.options,
    this.errorText,
  });

  final Function(String) onChange;
  final List<String> options;
  final String? errorText;

  @override
  State<SelectBankField> createState() => _SelectBankFieldState();
}

class _SelectBankFieldState extends State<SelectBankField> {
  @override
  Widget build(BuildContext context) {
    String selectedValue = widget.options[0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
            border: Border.all(
              color: cDark400,
              width: 1,
            ),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              'Nama Bank atau E-Wallet',
              style: TextStyle(
                  color: cDark300, fontSize: 11, fontWeight: FontWeight.w500),
            ),
            DropdownButtonFormField(
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              dropdownColor: cWhite,
              value: selectedValue,
              onChanged: (String? newValue) {
                setState(() {
                  selectedValue = newValue!;
                  widget.onChange(newValue);
                });
              },
              items:
                  widget.options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: cDark200,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                  ),
                );
              }).toList(),
            )
          ]),
        ),
        if (widget.errorText != null)
          Text(
            widget.errorText ?? '',
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: cPrimary100),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}
