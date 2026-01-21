require 'sqlite3'

class BaseDeDatos
  @@instancia = nil
  private_class_method :new
  
  def self.instance
    @@instancia ||= new
  end

  def initialize
    @db = SQLite3::Database.new "docketwise.db"
    # La creación de tabla la dejamos aquí por orden
    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS solicitantes (
        id INTEGER PRIMARY KEY,
        nombre VARCHAR(255),
        aprobado BOOLEAN
      );
    SQL
  end

  # Este método es la "tubería" que usarán los objetos para mandar SQL
  def ejecutar(sql, params = [])
    @db.execute(sql, params)
  end
end