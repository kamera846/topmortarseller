import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:topmortarseller/model/bank_model.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/model/customer_bank_model.dart';
import 'package:topmortarseller/screen/home_screen.dart';
import 'package:topmortarseller/services/bank_api.dart';
import 'package:topmortarseller/services/customer_bank_api.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/util/loading_item.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';
import 'package:topmortarseller/widget/form/button/text_button.dart';
import 'package:topmortarseller/widget/form/textfield/text_field.dart';
import 'package:topmortarseller/widget/modal/loading_modal.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

BankModel defaultBank = const BankModel(
    idBank: '-1', namaBank: '== Pilih Bank ==', isBca: '-1', swiftBank: '-1');

class NewTukangScreen extends StatefulWidget {
  const NewTukangScreen({
    super.key,
    this.userData,
    this.rekeningId = "-1",
    required this.onSuccess,
  });

  final ContactModel? userData;
  final String rekeningId;
  final Function(bool? state) onSuccess;

  @override
  State<NewTukangScreen> createState() => _NewTukangScreenState();
}

class _NewTukangScreenState extends State<NewTukangScreen> {
  SharedPreferences? prefs;
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
  bool? isSkipCreateBank = false;

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  void _getUserData() async {
    setState(() => isSelectBankLoading = true);
    final data = widget.userData ?? await getContactModel();
    setState(() => _userData = data);
    final initPrefs = await SharedPreferences.getInstance();
    setState(() {
      prefs = initPrefs;
      isSkipCreateBank = prefs!
          .getBool('${_userData!.idContact!}-${GlobalEnum.skipCreateBank}');
    });
    _getBanks();
  }

  _getBanks() async {
    List<BankModel>? items = [];
    items = await BankApiService().banks(
        onError: (e) => showSnackBar(context, e),
        onCompleted: () {
          if (widget.rekeningId == '-1') {
            setState(() => isSelectBankLoading = false);
          }
        });

    setState(() {
      items?.insert(0, defaultBank);
      options = items!;
    });

    if (widget.rekeningId != '-1') {
      _getUserBank(widget.rekeningId);
    }
  }

  void _getUserBank(String rekeningId) async {
    final myBanks = await CustomerBankApiService().banks(
      idContact: _userData!.idContact!,
      onSuccess: (msg) {},
      onError: (e) => showSnackBar(context, e),
      onCompleted: () => setState(() => isSelectBankLoading = false),
    );

    if (myBanks != null) {
      final bankItem = myBanks[0];
      final selectedOptionIndex =
          options.indexWhere((element) => element.idBank == bankItem.idBank);
      if (selectedOptionIndex != -1) {
        setState(() {
          _selectedBank = options[selectedOptionIndex];
          _noRekeningController.text = bankItem.toAccount!;
          _nameRekeningController.text = bankItem.toName!;
        });
      }
    }
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
    return;
    // final bankId = _selectedBank?.idBank;
    // final noRek = _noRekeningController.text;
    // final nameRek = _nameRekeningController.text;

    // setState(() {
    //   _selectedErrorText = Validator.bankDropdown(bankId);
    //   _noRekeningErrorText = Validator.isRequired(noRek);
    //   _nameRekeningErrorText = Validator.isRequired(nameRek);
    // });

    // if (_selectedErrorText != null ||
    //     _noRekeningErrorText != null ||
    //     _nameRekeningErrorText != null) {
    //   return;
    // }
    // showCupertinoDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return MInfoModal(
    //       contentName: 'Pengecekan Ulang',
    //       contentDescription: 'Pastikan data yang anda masukkan sudah benar!',
    //       contentIcon: Icons.warning_rounded,
    //       contentIconColor: cPrimary100,
    //       cancelText: 'Batal',
    //       onCancel: () {
    //         Navigator.of(context).pop();
    //       },
    //       confirmText: 'Lanjutkan',
    //       onConfirm: () async {
    //         Navigator.of(context).pop();
    //         setState(() => isLoading = true);
    //         submitSaveRekening();
    //       },
    //     );
    //   },
    // );
  }

  void submitSaveRekening() async {
    final bankId = _selectedBank?.idBank;
    final noRek = _noRekeningController.text;
    final nameRek = _nameRekeningController.text;

    if (widget.rekeningId != '-1') {
      await CustomerBankApiService().editBank(
        rekeningId: widget.rekeningId,
        idContact: _userData!.idContact!,
        idBank: bankId!,
        nameRek: nameRek,
        noRek: noRek,
        onSuccess: (msg) {
          showSnackBar(context, msg);
          widget.onSuccess(true);
        },
        onError: (e) {
          showSnackBar(context, e);
          widget.onSuccess(false);
        },
        onCompleted: () {
          setState(() => isLoading = false);
          goBack();
        },
      );
      return;
    }

    final CustomerBankModel? myBank = await CustomerBankApiService().newBank(
      idContact: _userData!.idContact!,
      idBank: bankId!,
      nameRek: nameRek,
      noRek: noRek,
      onSuccess: (msg) {
        showSnackBar(context, msg);
        widget.onSuccess(true);
      },
      onError: (e) {
        showSnackBar(context, e);
        widget.onSuccess(false);
      },
      onCompleted: () => setState(() => isLoading = false),
    );

    if (myBank != null) {
      if (isSkipCreateBank == null || isSkipCreateBank == false) {
        _skipCreateBank();
      } else {
        goBack();
      }
    }
  }

  void _skipCreateBank() async {
    prefs!
        .setBool('${_userData!.idContact!}-${GlobalEnum.skipCreateBank}', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => HomeScreen(
          userData: _userData,
        ),
      ),
    );
  }

  void goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Tukang'),
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
                      _selectedErrorText = null;
                    });
                  },
                ),
                MTextField(
                  controller: _noRekeningController,
                  label: 'Nomor Rekening atau E-Wallet',
                  keyboardType: TextInputType.number,
                  errorText: _noRekeningErrorText,
                  onChanged: (value) {
                    setState(() {
                      _noRekeningErrorText = null;
                    });
                  },
                ),
                MTextField(
                  controller: _nameRekeningController,
                  label: 'Nama Pemilik',
                  helper:
                      'Pastikan nama sesuai dengan nama pemilik pada Bank atau E-Wallet anda untuk menghindari terjadinya error.',
                  errorText: _nameRekeningErrorText,
                  onChanged: (value) {
                    setState(() {
                      _nameRekeningErrorText = null;
                    });
                  },
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
                if (!isSelectBankLoading)
                  MElevatedButton(
                    title: 'Simpan Rekening',
                    isFullWidth: true,
                    // enabled: isValidForm ? true : false,
                    onPressed: _saveRekening,
                  ),
                if (prefs != null &&
                    (isSkipCreateBank == null || isSkipCreateBank == false))
                  MTextButton(
                    title: 'Atur Nanti',
                    onPressed: _skipCreateBank,
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
                    color: cDark300,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500),
              ),
              widget.isLoading
                  ? const LoadingItem(
                      margin: EdgeInsets.only(bottom: 12),
                    )
                  : Semantics(
                      label: 'Dropdown Bank & E-Wallet',
                      child: DropdownButtonFormField<BankModel>(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        dropdownColor: cWhite,
                        value: widget.selectedBank,
                        onChanged: (BankModel? value) {
                          widget.onChange(value!);
                        },
                        items: widget.options.map((BankModel bank) {
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
                      ),
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
