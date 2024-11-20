import 'package:sqflite/sqflite.dart'; // Biblioteca para lidar com banco de dados SQLite.
import 'package:path/path.dart'; // Biblioteca para manipular caminhos de arquivos.
import '../models/expense.dart'; // Modelo de dados para representar uma despesa.

class DatabaseHelper {
  // Singleton para garantir que só exista uma instância da classe.
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  // Factory para retornar a única instância da classe.
  factory DatabaseHelper() {
    return _instance;
  }

  // Getter que inicializa o banco de dados, se necessário.
  Future<Database> get database async {
    if (_database != null) return _database!; // Retorna o banco já inicializado.

    _database = await _initDatabase(); // Inicializa o banco se ainda não existe.
    return _database!;
  }

  // Inicialização do banco de dados no caminho apropriado.
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expenses.db'); // Define o caminho do banco.
    return await openDatabase(
      path,
      version: 1, // Define a versão do banco.
      onCreate: _onCreate, // Chama a função para criar a tabela na primeira execução.
    );
  }

  // Criação da tabela 'expenses' no banco de dados.
  Future _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT, -- Identificador único para cada despesa.
        description TEXT,                     -- Descrição da despesa.
        amount REAL,                          -- Valor da despesa.
        date TEXT,                            -- Data da despesa.
        type TEXT                             -- Tipo: 'despesa' ou 'receita'.
      )
    ''');
  }

  // Insere uma nova despesa no banco.
  Future<int> insertExpense(Expense expense) async {
    Database db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  // Busca todas as despesas armazenadas no banco.
  Future<List<Expense>> getExpenses() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('expenses');
    return result.map((map) => Expense.fromMap(map)).toList(); // Converte os resultados para objetos Expense.
  }

  // Remove uma despesa com base no ID.
  Future<int> deleteExpense(int id) async {
    Database db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]); // Condição para deletar a despesa.
  }
}
