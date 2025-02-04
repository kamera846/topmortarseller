import 'package:flutter/material.dart';
import 'package:topmortarseller/model/product_model.dart';
import 'package:topmortarseller/util/colors/color.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<ProductModel> items = [];
  bool _showOverlay = false;
  ProductModel? _selectedItem;

  @override
  void initState() {
    items.add(const ProductModel(
      idProduk: '1',
      namaProduk: 'TOP MORTAR THINBED',
      hargaProduk: '67500',
      idCity: '1',
      stok: '200',
      imageProduk:
          'https://topmortar.com/wp-content/uploads/2018/11/TOP-THINBED-696x1096.png',
    ));
    items.add(const ProductModel(
      idProduk: '1',
      namaProduk: 'TOP MORTAR ACIAN',
      hargaProduk: '72500',
      idCity: '1',
      stok: '250',
      imageProduk:
          'https://topmortar.com/wp-content/uploads/2019/05/TOP-KERAMIK-696x1096.png',
    ));
    items.add(const ProductModel(
      idProduk: '1',
      namaProduk: 'TOP MORTAR PLASTER',
      hargaProduk: '95000',
      idCity: '1',
      stok: '150',
      imageProduk:
          'https://topmortar.com/wp-content/uploads/2021/10/top-kalender.jpeg',
    ));
    items.add(const ProductModel(
      idProduk: '4',
      namaProduk: 'TOP MORTAR THINBED',
      hargaProduk: '67500',
      idCity: '1',
      stok: '200',
      imageProduk:
          'https://topmortar.com/wp-content/uploads/2018/11/TOP-THINBED-696x1096.png',
    ));
    items.add(const ProductModel(
      idProduk: '5',
      namaProduk: 'TOP MORTAR ACIAN',
      hargaProduk: '72500',
      idCity: '1',
      stok: '250',
      imageProduk:
          'https://topmortar.com/wp-content/uploads/2019/05/TOP-KERAMIK-696x1096.png',
    ));
    items.add(const ProductModel(
      idProduk: '6',
      namaProduk: 'TOP MORTAR PLASTER',
      hargaProduk: '95000',
      idCity: '1',
      stok: '150',
      imageProduk:
          'https://topmortar.com/wp-content/uploads/2021/10/top-kalender.jpeg',
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: cWhite,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('Katalog Produk'),
            centerTitle: false,
            backgroundColor: cWhite,
            foregroundColor: cDark100,
          ),
          body: GridView(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 5,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            children: [
              for (final item in items)
                Card(
                  color: cWhite,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedItem = item;
                        _showOverlay = true;
                      });
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                              color: cDark600,
                              width: double.infinity,
                              height: double.infinity,
                              child: Image.network(
                                item.imageProduk ?? '',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.namaProduk ?? '',
                                      ),
                                      Text(
                                        'Rp. ${item.hargaProduk}',
                                        style: const TextStyle(
                                            color: cPrimary400,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Stok ${item.stok}',
                                    style: const TextStyle(color: cDark200),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
        if (_showOverlay && _selectedItem != null)
          OverlayItem(
            selectedItem: _selectedItem,
            onSubmit: () {
              setState(() {
                _selectedItem = null;
                _showOverlay = false;
              });
            },
            onClose: () {
              setState(() {
                _selectedItem = null;
                _showOverlay = false;
              });
            },
          )
      ],
    );
  }
}

class OverlayItem extends StatefulWidget {
  const OverlayItem(
      {super.key,
      required this.selectedItem,
      required this.onSubmit,
      required this.onClose});

  final ProductModel? selectedItem;
  final Function() onSubmit;
  final Function() onClose;

  @override
  State<OverlayItem> createState() => _OverlayItemState();
}

class _OverlayItemState extends State<OverlayItem> {
  final _itemCountController = TextEditingController();

  @override
  void initState() {
    _itemCountController.text = '1';
    super.initState();
  }

  @override
  void dispose() {
    _itemCountController.dispose();
    super.dispose();
  }

  void minusCountItem(int value) {
    var countNow = int.parse(_itemCountController.text);
    if (countNow > 0) {
      var countMinus = countNow - value;
      if (countMinus < 0) {
        setState(() {
          _itemCountController.text = '0';
        });
      } else {
        setState(() {
          _itemCountController.text = '$countMinus';
        });
      }
    }
  }

  void plusCountItem(int value) {
    var countNow = int.parse(_itemCountController.text);
    setState(() {
      _itemCountController.text = '${countNow + value}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        padding: const EdgeInsets.all(24),
        color: cDark100.withOpacity(0.5),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.selectedItem!.imageProduk ?? '',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Rp. ${widget.selectedItem!.hargaProduk}',
                    style: const TextStyle(
                        color: cPrimary400,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.selectedItem!.namaProduk ?? '',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Stok ${widget.selectedItem!.stok}',
                    style: const TextStyle(color: cDark200),
                  ),
                  // Text(
                  //   'Rp. ${widget.selectedItem!.hargaProduk}',
                  //   style: const TextStyle(
                  //       color: cPrimary400,
                  //       fontSize: 18,
                  //       fontWeight: FontWeight.bold),
                  // ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton.filled(
                        onPressed: () => minusCountItem(2),
                        icon: const Icon(Icons.exposure_minus_2),
                      ),
                      IconButton.filled(
                        onPressed: () => minusCountItem(1),
                        icon: const Icon(Icons.exposure_minus_1),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _itemCountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide: const BorderSide(
                                  color: cDark100,
                                  width: 1,
                                )),
                          ),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: () => plusCountItem(1),
                        icon: const Icon(Icons.exposure_plus_1),
                      ),
                      IconButton.filled(
                        onPressed: () => plusCountItem(2),
                        icon: const Icon(Icons.exposure_plus_2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cPrimary200,
                      foregroundColor: cWhite,
                      iconColor: cWhite,
                      overlayColor: cWhite,
                      shadowColor: cDark600,
                    ),
                    onPressed: widget.onSubmit,
                    child: const SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Tambahkan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
