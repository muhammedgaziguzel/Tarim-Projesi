import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const TarimKredisiApp());
}

class TarimKredisiApp extends StatelessWidget {
  const TarimKredisiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kredi Hesaplama',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green,
          secondary: Colors.lightGreen,
          background: const Color(0xFFF5F2E8),
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const TarimKredisiEkrani(),
    );
  }
}

// Models
class KrediTuru {
  final String adi;
  final double faizOrani;
  final int minVade;
  final int maxVade;
  final double minBakiye;
  final double maxBakiye;
  final String aciklama;

  const KrediTuru({
    required this.adi,
    required this.faizOrani,
    required this.minVade,
    required this.maxVade,
    required this.minBakiye,
    required this.maxBakiye,
    required this.aciklama,
  });
}

class KrediHesaplama {
  final KrediTuru krediTuru;
  final double talep;
  final int vade;
  final double aylikTaksit;
  final double toplamOdeme;
  final double toplamFaiz;

  KrediHesaplama({
    required this.krediTuru,
    required this.talep,
    required this.vade,
  })  : aylikTaksit = _hesaplaAylikTaksit(talep, krediTuru.faizOrani, vade),
        toplamOdeme =
            _hesaplaAylikTaksit(talep, krediTuru.faizOrani, vade) * vade,
        toplamFaiz =
            (_hesaplaAylikTaksit(talep, krediTuru.faizOrani, vade) * vade) -
                talep;

  static double _hesaplaAylikTaksit(
      double anapara, double yillikFaizOrani, int vadeSuresi) {
    // Aylık faiz oranı hesaplama
    double aylikFaizOrani = (yillikFaizOrani / 100) / 12;

    // Aylık eşit taksit hesaplama formülü
    double taksit = anapara *
        aylikFaizOrani *
        pow((1 + aylikFaizOrani), vadeSuresi) /
        (pow((1 + aylikFaizOrani), vadeSuresi) - 1);

    return taksit;
  }

  // Yardımcı fonksiyon: üs alma
  static double pow(double base, int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }
}

class TarimKredisiEkrani extends StatefulWidget {
  const TarimKredisiEkrani({super.key});

  @override
  State<TarimKredisiEkrani> createState() => _TarimKredisiEkraniState();
}

class _TarimKredisiEkraniState extends State<TarimKredisiEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _bakiyeController = TextEditingController();
  final _vadeController = TextEditingController();

  bool _formSubmitted = false;
  KrediHesaplama? _hesaplananKredi;
  int _selectedIndex = 0;

  final List<KrediTuru> _krediTurleri = [
    const KrediTuru(
      adi: 'Standart Kredi',
      faizOrani: 5.0,
      minVade: 3,
      maxVade: 24,
      minBakiye: 5000,
      maxBakiye: 50000,
      aciklama:
          'Küçük ve orta ölçekli ihtiyaçlar için standart faiz oranlı temel kredi.',
    ),
    const KrediTuru(
      adi: 'Ekipman Kredisi',
      faizOrani: 4.5,
      minVade: 6,
      maxVade: 36,
      minBakiye: 10000,
      maxBakiye: 150000,
      aciklama: 'Ekipman alımları ve yükseltmeleri için özel finansman çözümü.',
    ),
    const KrediTuru(
      adi: 'Premium Kredi',
      faizOrani: 3.0,
      minVade: 12,
      maxVade: 48,
      minBakiye: 20000,
      maxBakiye: 250000,
      aciklama:
          'Uzun vadeli ve daha avantajlı faiz oranlı özel müşteri kredisi.',
    ),
    const KrediTuru(
      adi: 'Yatırım Kredisi',
      faizOrani: 4.0,
      minVade: 12,
      maxVade: 60,
      minBakiye: 50000,
      maxBakiye: 500000,
      aciklama:
          'Büyük yatırımlar ve projeler için uzun vadeli finansman desteği.',
    ),
  ];

  KrediTuru get _secilenKrediTuru => _krediTurleri[_selectedIndex];

  final _paraFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  @override
  void dispose() {
    _bakiyeController.dispose();
    _vadeController.dispose();
    super.dispose();
  }

  void _hesaplaKredi() {
    if (_formKey.currentState!.validate()) {
      double talep = double.parse(
          _bakiyeController.text.replaceAll('.', '').replaceAll(',', '.'));
      int vade = int.parse(_vadeController.text);

      setState(() {
        _formSubmitted = true;
        _hesaplananKredi = KrediHesaplama(
          krediTuru: _secilenKrediTuru,
          talep: talep,
          vade: vade,
        );
      });
    }
  }

  String _formatCurrency(double value) {
    return _paraFormat.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2E8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kredi Türünü Seçin',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildKrediTuruList(),
                        const SizedBox(height: 20),
                        _buildKrediDetaylari(),
                        const SizedBox(height: 20),
                        _buildKrediForm(),
                        const SizedBox(height: 20),
                        _buildHesaplaButton(),
                        const SizedBox(height: 20),
                        if (_formSubmitted && _hesaplananKredi != null)
                          _buildKrediSonuc(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFF5F2E8),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            '© ${DateTime.now().year} Kredi Hesaplama',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKrediTuruList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _krediTurleri.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                  _formSubmitted = false;
                });
              },
              child: Card(
                elevation: isSelected ? 4 : 1,
                color: isSelected ? Colors.green : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.green.shade700
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _krediTurleri[index].adi,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Faiz: %${_krediTurleri[index].faizOrani}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKrediDetaylari() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _secilenKrediTuru.adi,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _secilenKrediTuru.aciklama,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Faiz Oranı:', '%${_secilenKrediTuru.faizOrani}'),
            _buildInfoRow('Kredi Limiti:',
                '${_formatCurrency(_secilenKrediTuru.minBakiye)} - ${_formatCurrency(_secilenKrediTuru.maxBakiye)}'),
            _buildInfoRow('Vade Aralığı:',
                '${_secilenKrediTuru.minVade} - ${_secilenKrediTuru.maxVade} ay'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKrediForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kredi Bilgileri',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bakiyeController,
          decoration: InputDecoration(
            labelText: 'Kredi Tutarı',
            suffixText: '₺',
            hintText: _formatCurrency(_secilenKrediTuru.minBakiye)
                .replaceAll('₺', ''),
            prefixIcon: const Icon(Icons.account_balance_wallet),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _CurrencyInputFormatter(),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen kredi tutarını giriniz';
            }

            try {
              final double amount =
                  double.parse(value.replaceAll('.', '').replaceAll(',', '.'));
              if (amount < _secilenKrediTuru.minBakiye) {
                return 'Minimum tutar: ${_formatCurrency(_secilenKrediTuru.minBakiye)}';
              }
              if (amount > _secilenKrediTuru.maxBakiye) {
                return 'Maksimum tutar: ${_formatCurrency(_secilenKrediTuru.maxBakiye)}';
              }
            } catch (e) {
              return 'Lütfen geçerli bir tutar giriniz';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _vadeController,
          decoration: InputDecoration(
            labelText: 'Vade Süresi',
            suffixText: 'Ay',
            hintText:
                '${_secilenKrediTuru.minVade} - ${_secilenKrediTuru.maxVade}',
            prefixIcon: const Icon(Icons.calendar_today),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen vade süresini giriniz';
            }

            try {
              final int vade = int.parse(value);
              if (vade < _secilenKrediTuru.minVade) {
                return 'Minimum vade: ${_secilenKrediTuru.minVade} ay';
              }
              if (vade > _secilenKrediTuru.maxVade) {
                return 'Maksimum vade: ${_secilenKrediTuru.maxVade} ay';
              }
            } catch (e) {
              return 'Lütfen geçerli bir vade süresi giriniz';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildHesaplaButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _hesaplaKredi,
        icon: const Icon(Icons.calculate),
        label: const Text(
          'HESAPLA',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildKrediSonuc() {
    return Card(
      elevation: 3,
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hesaplama Sonuçları',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            _buildSonucRow(
                'Kredi Tutarı:', _formatCurrency(_hesaplananKredi!.talep)),
            _buildSonucRow('Vade:', '${_hesaplananKredi!.vade} ay'),
            _buildSonucRow('Aylık Taksit:',
                _formatCurrency(_hesaplananKredi!.aylikTaksit)),
            const Divider(height: 24),
            _buildSonucRow(
                'Toplam Faiz:', _formatCurrency(_hesaplananKredi!.toplamFaiz)),
            _buildSonucRow('Toplam Geri Ödeme:',
                _formatCurrency(_hesaplananKredi!.toplamOdeme),
                isBold: true),
            const SizedBox(height: 20),
            const Text(
              '* Bu hesaplama bilgi amaçlıdır. Kesin kredi şartları, ön onaydan sonra belirlenecektir.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Kredi başvurunuz gönderildi! Ekibimiz en kısa sürede sizinle iletişime geçecektir.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle),
                label: const Text(
                  'BAŞVUR',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSonucRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 16,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: isBold ? Colors.green.shade800 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Only keep digits
    String onlyDigits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Format with thousand separators
    final formatter = NumberFormat('#,###', 'tr_TR');
    String formatted = formatter.format(int.parse(onlyDigits));

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}