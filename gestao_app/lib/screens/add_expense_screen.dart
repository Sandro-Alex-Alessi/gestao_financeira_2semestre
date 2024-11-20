import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>(); // Chave global para o formulário
  String _description = ''; // Descrição da transação
  double _amount = 0.0; // Valor da transação
  DateTime _selectedDate = DateTime.now(); // Data da transação, inicializada com a data atual
  String _selectedType = 'expense'; // Tipo da transação (gasto por padrão)

  // Função para salvar a transação no banco
  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Salva os dados no estado
      Expense newExpense = Expense(
        description: _description,
        amount: _amount,
        date: _selectedDate,
        type: _selectedType, // Tipo da transação (gasto ou receita)
      );
      await DatabaseHelper().insertExpense(newExpense); // Insere a transação no banco
      Navigator.pop(context, true); // Retorna à tela anterior
    }
  }

  // Função para abrir o seletor de data
  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple, // Cor do cabeçalho
              onPrimary: Colors.white, // Cor do texto no cabeçalho
              onSurface: Colors.deepPurple, // Cor do texto no calendário
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate; // Atualiza a data selecionada
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.deepPurple; // Cor do tema

    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Despesa ou Receita'),
        backgroundColor: themeColor, // Cor do AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Associa o formulário à chave global
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Informe os dados da transação',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              // Campo para descrição da transação
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: themeColor),
                  ),
                ),
                onSaved: (value) => _description = value!, // Salva a descrição
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Informe uma descrição'; // Validação obrigatória
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Campo para valor da transação
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Valor',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: themeColor),
                  ),
                ),
                keyboardType: TextInputType.number, // Entrada numérica
                onSaved: (value) => _amount = double.parse(value!),
                validator: (value) {
                  if (value!.isEmpty || double.tryParse(value) == null) {
                    return 'Informe um valor válido'; // Validação de valor numérico
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Seletor de data
              GestureDetector(
                onTap: _pickDate, // Abre o seletor de data ao tocar
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14.0,
                    horizontal: 12.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: themeColor),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Data: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.calendar_today, color: themeColor), // Ícone de calendário
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Seletor de tipo de transação (gasto ou receita)
              DropdownButtonFormField<String>(
                value: _selectedType, // Valor atual do tipo
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue!; // Atualiza o tipo de transação
                  });
                },
                items: <String>['expense', 'income']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value == 'expense' ? 'Gasto' : 'Receita'),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Tipo de Transação',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Selecione o tipo de transação'; // Validação de tipo selecionado
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Botão de salvar transação
              ElevatedButton.icon(
                onPressed: _saveExpense, // Salva a transação
                icon: Icon(
                  Icons.save,
                  color: Colors.black, // Cor do ícone
                ),
                label: Text(
                  'Salvar Transação',
                  style: TextStyle(color: Colors.black), // Cor do texto
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
