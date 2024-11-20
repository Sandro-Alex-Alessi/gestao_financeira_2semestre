import 'dart:convert'; // Para trabalhar com JSON
import 'package:flutter/material.dart'; // Biblioteca do Flutter para UI
import 'package:http/http.dart' as http; // Biblioteca para realizar requisições HTTP

class DollarQuoteScreen extends StatefulWidget {
  @override
  _DollarQuoteScreenState createState() => _DollarQuoteScreenState();
}

class _DollarQuoteScreenState extends State<DollarQuoteScreen> {
  double? _dollarQuote; // Armazena a cotação do dólar

  // Chamada inicial para buscar a cotação do dólar
  @override
  void initState() {
    super.initState();
    _fetchDollarQuote(); // Obtém a cotação do dólar quando a tela é carregada
  }

  // Função para buscar a cotação do dólar usando a API
  Future<void> _fetchDollarQuote() async {
    final response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));
    
    // Verifica se a requisição foi bem-sucedida
    if (response.statusCode == 200) {
      final data = json.decode(response.body); // Decodifica a resposta JSON
      setState(() {
        _dollarQuote = data['rates']['BRL']; // Atualiza a cotação do dólar
      });
    } else {
      throw Exception('Falha ao carregar a cotação'); // Lança erro se a requisição falhar
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.deepPurple; // Cor do tema

    return Scaffold(
      appBar: AppBar(
        title: Text('Cotação do Dólar'), // Título da AppBar
        backgroundColor: themeColor, // Cor de fundo da AppBar
      ),
      body: Center(
        // Exibe a cotação ou um indicador de carregamento
        child: _dollarQuote == null
            ? CircularProgressIndicator() // Carregando enquanto a cotação não é obtida
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Cotação do Dólar (USD para BRL)', // Texto explicativo
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: themeColor),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'R\$ ${_dollarQuote!.toStringAsFixed(2)}', // Exibe a cotação formatada
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: themeColor.shade700),
                  ),
                ],
              ),
      ),
    );
  }
}
