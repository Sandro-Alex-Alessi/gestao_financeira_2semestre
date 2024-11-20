class Expense {
  int? id; // Identificador único da despesa, opcional (pode ser null para novas despesas).
  String description; // Descrição da despesa ou receita.
  double amount; // Valor da despesa ou receita.
  DateTime date; // Data em que a despesa ou receita foi registrada.
  String type; // Tipo de transação: 'expense' para gasto e 'income' para receita.

  // Construtor da classe Expense, que inicializa os campos necessários.
  Expense({
    this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.type, // Novo parâmetro que define se é despesa ou receita.
  });

  // Método para converter um objeto Expense em um Map, para salvar no banco de dados.
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Armazena o id da despesa.
      'description': description, // Armazena a descrição.
      'amount': amount, // Armazena o valor.
      'date': date.toIso8601String(), // Armazena a data como string no formato ISO 8601.
      'type': type, // Armazena o tipo (despesa ou receita).
    };
  }

  // Método para criar um objeto Expense a partir de um Map (usado ao recuperar dados do banco).
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'], // Recupera o id do Map.
      description: map['description'], // Recupera a descrição.
      amount: map['amount'], // Recupera o valor.
      date: DateTime.parse(map['date']), // Converte a data de string para DateTime.
      type: map['type'] ?? 'expense', // Se 'type' for null, o valor padrão será 'expense'.
    );
  }
}
