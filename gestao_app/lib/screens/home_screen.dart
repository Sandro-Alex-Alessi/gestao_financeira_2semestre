import 'package:flutter/material.dart';
import 'add_expense_screen.dart';
import '../database/database_helper.dart';
import '../models/expense.dart';
import 'dollarQuoteScreen.dart'; // Import da tela de cotação do dólar
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variáveis para armazenar despesas e totais
  List<Expense> _expenses = [];
  double _totalIncomeDay = 0.0;
  double _totalExpenseDay = 0.0;
  double _totalIncomeMonth = 0.0;
  double _totalExpenseMonth = 0.0;
  double _totalIncomeYear = 0.0;
  double _totalExpenseYear = 0.0;

  // Inicializa a tela carregando as despesas
  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  // Calcula os totais de entrada e saída para diferentes períodos
  void _calculateTotals() {
    final now = DateTime.now();
    setState(() {
      _totalIncomeDay = _calculateTotalForDay(_expenses, now, 'income');
      _totalExpenseDay = _calculateTotalForDay(_expenses, now, 'expense');
      _totalIncomeMonth = _calculateTotalForMonth(_expenses, now, 'income');
      _totalExpenseMonth = _calculateTotalForMonth(_expenses, now, 'expense');
      _totalIncomeYear = _calculateTotalForYear(_expenses, now, 'income');
      _totalExpenseYear = _calculateTotalForYear(_expenses, now, 'expense');
    });
  }

  // Calcula o total para o dia
  double _calculateTotalForDay(List<Expense> expenses, DateTime date, String type) {
    return expenses
        .where((expense) =>
            expense.date.year == date.year &&
            expense.date.month == date.month &&
            expense.date.day == date.day &&
            expense.type == type)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  // Calcula o total para o mês
  double _calculateTotalForMonth(List<Expense> expenses, DateTime date, String type) {
    return expenses
        .where((expense) =>
            expense.date.year == date.year &&
            expense.date.month == date.month &&
            expense.type == type)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  // Calcula o total para o ano
  double _calculateTotalForYear(List<Expense> expenses, DateTime date, String type) {
    return expenses
        .where((expense) => expense.date.year == date.year && expense.type == type)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  // Carrega as despesas do banco de dados
  Future<void> _loadExpenses() async {
    List<Expense> expenses = await DatabaseHelper().getExpenses();
    setState(() {
      _expenses = expenses;
    });
    _calculateTotals(); // Recalcula os totais após carregar as despesas
  }

  // Navega para a tela de adicionar despesa
  void _addExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddExpenseScreen()),
    );
    if (result == true) {
      _loadExpenses(); // Recarrega as despesas após adicionar
    }
  }

  // Remove a despesa selecionada
  void _removeExpense(int id) async {
    await DatabaseHelper().deleteExpense(id);
    _loadExpenses(); // Recarrega as despesas após a remoção
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.deepPurple; // Cor do tema

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agenda Financeira',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: themeColor, // Cor de fundo da AppBar
      ),
      body: Column(
        children: [
          // Cabeçalho com totais financeiros
          Container(
            color: themeColor.shade100,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Resumo Financeiro',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeColor.shade700,
                  ),
                ),
                SizedBox(height: 8),
                _buildCompactSummary(themeColor), // Exibe o resumo compactado
              ],
            ),
          ),
          // Lista de despesas
          Expanded(
            child: _expenses.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma transação cadastrada ainda!',
                      style: TextStyle(fontSize: 16, color: themeColor.shade700),
                    ),
                  )
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 12.0,
                        ),
                        child: ListTile(
                          title: Text(
                            expense.description,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'R\$ ${expense.amount.toStringAsFixed(2)} - ${_formatDate(expense.date)}\nTipo: ${expense.type == 'expense' ? 'Despesa' : 'Receita'}',
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: themeColor),
                            onPressed: () => _removeExpense(expense.id!),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _addExpense, // Adiciona uma nova despesa
            child: Icon(Icons.add),
            backgroundColor: themeColor,
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DollarQuoteScreen()), // Navega para a tela de cotação do dólar
              );
            },
            icon: Icon(Icons.attach_money),
            label: Text('Ver Dólar'),
            backgroundColor: themeColor,
          ),
        ],
      ),
    );
  }

  // Cria o resumo compactado com totais por período
  Widget _buildCompactSummary(MaterialColor color) {
    return Column(
      children: [
        _buildSummaryRow('Hoje', _totalIncomeDay, _totalExpenseDay, color),
        _buildSummaryRow('Mês', _totalIncomeMonth, _totalExpenseMonth, color),
        _buildSummaryRow('Ano', _totalIncomeYear, _totalExpenseYear, color),
      ],
    );
  }

  // Cria cada linha do resumo financeiro
  Widget _buildSummaryRow(String period, double income, double expense, MaterialColor color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Fundo branco para cada linha
          borderRadius: BorderRadius.circular(8.0), // Bordas arredondadas
          boxShadow: [
            BoxShadow(
              color: color.shade100, // Sombras para contraste
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              period, // Exibe o período (Hoje, Mês, Ano)
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color.shade800,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Entrada: R\$ ${income.toStringAsFixed(2)}', // Exibe a entrada
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.green.shade700,
                  ),
                ),
                Text(
                  'Saída: R\$ ${expense.toStringAsFixed(2)}', // Exibe a saída
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Formata a data para exibição
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
