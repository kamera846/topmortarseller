import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:topmortarseller/model/bank_model.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/model/customer_bank_model.dart';
import 'package:topmortarseller/services/bank_api.dart';
import 'package:topmortarseller/services/customer_bank.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/loading_item.dart';
import 'package:topmortarseller/util/validator/validator.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';
import 'package:topmortarseller/widget/form/textfield/text_field.dart';
import 'package:topmortarseller/widget/modal/info_modal.dart';
import 'package:topmortarseller/widget/modal/loading_modal.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

BankModel defaultBank = const BankModel(
    idBank: '-1', namaBank: '== Pilih Bank ==', isBca: '-1', swiftBank: '-1');

class NewRekeningScreen extends StatefulWidget {
  const NewRekeningScreen({
    super.key,
    this.userData,
  });

  final ContactModel? userData;

  @override
  State<NewRekeningScreen> createState() => _NewRekeningScreenState();
}

class _NewRekeningScreenState extends State<NewRekeningScreen> {
  ContactModel? _userData;
  List<BankModel> options = [];
  BankModel? _selectedBank;
  final _noRekeningController = TextEditingController();
  final _nameRekeningController = TextEditingController();
  // final _ownerNameController = TextEditingController();

  String? _selectedErrorText;
  String? _noRekeningErrorText;
  String? _nameRekeningErrorText;
  // String? _ownerNameErrorText;

  bool isValidForm = false;
  bool isSelectBankLoading = true;
  bool isLoading = false;

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  void _getUserData() async {
    setState(() => isSelectBankLoading = true);
    final data = widget.userData ?? await getContactModel();
    setState(() => _userData = data);
    _getBanks();
  }

  _getBanks() async {
    List<BankModel>? items = [];
    items = await BankApiService().banks(
        onError: (e) => showSnackBar(context, e),
        onCompleted: () {
          setState(() => isSelectBankLoading = false);
        });

    setState(() {
      items?.insert(0, defaultBank);
      options = items!;
    });
  }

  // void _checkOwnerName() {
  //   if (_selectedBank == null || _selectedBank?.idBank == '-1') {
  //     setState(() {
  //       _selectedErrorText = 'Pilih Bank Anda';
  //     });
  //     return;
  //   } else {
  //     setState(() {
  //       _selectedErrorText = null;
  //     });
  //   }

  //   if (_noRekeningController.text.isEmpty) {
  //     setState(() {
  //       _noRekeningErrorText = 'Anda belum mengisi kolom nomor rekening!';
  //       // _ownerNameController.text = '';
  //       // _ownerNameErrorText = null;
  //     });
  //     return;
  //   } else {
  //     setState(() {
  //       _noRekeningErrorText = null;
  //       // _ownerNameController.text = '';
  //       // _ownerNameErrorText = null;
  //     });
  //   }

  //   if (_noRekeningController.text == '12345') {
  //     setState(() {
  //       _noRekeningErrorText = null;
  //       // _ownerNameController.text = 'Mochammad Rafli Ramadani';
  //       // _ownerNameErrorText = null;
  //       isValidForm = true;
  //     });
  //   } else {
  //     setState(() {
  //       _noRekeningErrorText = null;
  //       // _ownerNameController.text = '';
  //       // _ownerNameErrorText =
  //       'Tidak dapat menemukan nomor rekening atau e-wallet.';
  //     });
  //   }
  // }

  void _saveRekening() async {
    final bankId = _selectedBank?.idBank;
    final noRek = _noRekeningController.text;
    final nameRek = _nameRekeningController.text;

    setState(() {
      _selectedErrorText = Validator.bankDropdown(bankId);
      _noRekeningErrorText = Validator.isRequired(noRek);
      _nameRekeningErrorText = Validator.isRequired(nameRek);
    });

    if (_selectedErrorText != null ||
        _noRekeningErrorText != null ||
        _nameRekeningErrorText != null) {
      return;
    }
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return MInfoModal(
          contentName: 'Pengecekan Ulang',
          contentDescription: 'Pastikan data yang anda masukkan sudah benar!',
          contentIcon: Icons.warning_rounded,
          contentIconColor: cPrimary100,
          cancelText: 'Batal',
          onCancel: () {
            Navigator.of(context).pop();
          },
          confirmText: 'Lanjutkan',
          onConfirm: () async {
            setState(() => isLoading = true);
            final CustomerBankModel? myBank =
                await CustomerBankApiService().newBank(
              idContact: _userData!.idContact!,
              idBank: bankId!,
              nameRek: nameRek,
              noRek: noRek,
              onSuccess: (msg) => showSnackBar(context, msg),
              onError: (e) => showSnackBar(context, e),
              onCompleted: () => setState(() => isLoading = false),
            );

            if (myBank != null) {
              print('My Bank: ${json.encode(myBank.toJson())}');
            }

            goBack();
          },
        );
      },
    );
  }

  void goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Rekening Baru'),
      ),
      body: Stack(
        children: [
          Padding(
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
                  isLoading: isSelectBankLoading,
                  selectedBank: _selectedBank ?? defaultBank,
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
                  onChanged: (value) {},
                ),
                MTextField(
                  controller: _nameRekeningController,
                  label: 'Nama Pemilik',
                  helper:
                      'Pastikan nama sesuai dengan nama pemilik pada Bank atau E-Wallet anda untuk menghindari terjadinya error.',
                  errorText: _nameRekeningErrorText,
                  onChanged: (value) {},
                ),
                // MElevatedButton(
                //   title: 'Cek Nama Pemilik',
                //   onPressed: _checkOwnerName,
                // ),
                // const SizedBox(height: 12),
                // if (_ownerNameController.text.isNotEmpty)
                //   Container(
                //     width: double.infinity,
                //     padding: const EdgeInsets.all(16),
                //     decoration: BoxDecoration(
                //       color: Theme.of(context).scaffoldBackgroundColor,
                //       borderRadius: BorderRadius.circular(8),
                //       border: Border.all(width: 1, color: cDark400),
                //     ),
                //     child: Text(
                //       _ownerNameController.text,
                //       textAlign: TextAlign.center,
                //       style: Theme.of(context)
                //           .textTheme
                //           .titleMedium!
                //           .copyWith(color: cDark200, fontWeight: FontWeight.bold),
                //     ),
                //   ),
                // if (_ownerNameErrorText != null && _ownerNameErrorText!.isNotEmpty)
                //   Text(
                //     _ownerNameErrorText!,
                //     style: const TextStyle(color: cPrimary100),
                //   ),
                Expanded(
                  child: Container(),
                ),
                MElevatedButton(
                  title: 'Simpan Rekening',
                  isFullWidth: true,
                  // enabled: isValidForm ? true : false,
                  onPressed: _saveRekening,
                ),
              ],
            ),
          ),
          if (isLoading) const LoadingModal()
        ],
      ),
    );
  }
}

class SelectBankField extends StatefulWidget {
  const SelectBankField({
    super.key,
    required this.onChange,
    required this.options,
    required this.isLoading,
    required this.selectedBank,
    this.errorText,
  });

  final Function(BankModel) onChange;
  final List<BankModel> options;
  final BankModel selectedBank;
  final bool isLoading;
  final String? errorText;

  @override
  State<SelectBankField> createState() => _SelectBankFieldState();
}

class _SelectBankFieldState extends State<SelectBankField> {
  @override
  Widget build(BuildContext context) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nama Bank atau E-Wallet',
                style: TextStyle(
                    color: cDark300, fontSize: 11, fontWeight: FontWeight.w500),
              ),
              widget.isLoading
                  ? const LoadingItem(
                      margin: EdgeInsets.only(bottom: 12),
                    )
                  : DropdownButtonFormField<BankModel>(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      dropdownColor: cWhite,
                      value: widget.selectedBank,
                      onChanged: (BankModel? value) {
                        widget.onChange(value!);
                      },
                      items: widget.options
                          .map<DropdownMenuItem<BankModel>>((BankModel bank) {
                        return DropdownMenuItem<BankModel>(
                          value: bank,
                          child: Text(
                            bank.namaBank!,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color: cDark200,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                          ),
                        );
                      }).toList(),
                    )
            ],
          ),
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
