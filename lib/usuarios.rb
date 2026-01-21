require_relative 'base_de_datos'

module Aprobable
    def aprobar_visa(solicitante)
        # Solo imprime: "El Cónsul [nombre] ha aprobado la visa de [nombre_solicitante]"
         # Pista: usa self.nombre para el cónsul y solicitante.nombre
        puts "El Cónsul #{self.nombre} ha aprobado la visa de #{solicitante.nombre}"
    end
end

class Persona 
    attr_reader :nombre

    def initialize(nombre)
        @nombre = nombre
    end

end

class Solicitante < Persona
    attr_reader :id
    attr_accessor :aprobado

    def initialize(id, nombre, aprobado = false)
        if nombre == ""
            raise "No puedes crear un solicitante sin nombre!"
        end

        super(nombre)

        @id = id
        @aprobado = aprobado
    end

    def save
        #Inserta dentro de la tabla solicitantes los datos id, nombre y aprobado, los cuales te daré
        # después. Ejecutamos nuestro sql por la base de datos con las variables id, nombre y 0
        sql = "INSERT INTO solicitantes (id, nombre, aprobado) VALUES (?, ?, ?)"
        # Llamamos a la BD para ejecutar NUESTRO sql
        BaseDeDatos.instance.ejecutar(sql, [@id, @nombre, 0])
        puts "💾 #{@nombre} se ha guardado en la base de datos."
    end

    def update_status(nuevo_status)
        @aprobado = nuevo_status # Actualizamos el objeto en memoria RAM
        valor_sql = nuevo_status ? 1 : 0
        
        sql = "UPDATE solicitantes SET aprobado = ? WHERE id = ?"
        BaseDeDatos.instance.ejecutar(sql, [valor_sql, @id])
        puts "🔄 Status de #{@nombre} actualizado en DB."
    end

    def destroy
    sql = "DELETE FROM solicitantes WHERE id = ?"
    BaseDeDatos.instance.ejecutar(sql, [@id])
    puts "🗑️ #{@nombre} eliminado para siempre."
  end
  
  # 4. Método de Clase para buscar (Factory Method)
  # Se usa así: Solicitante.find(101)
  def self.find(id_buscado)
    filas = BaseDeDatos.instance.ejecutar("SELECT * FROM solicitantes WHERE id = ?", [id_buscado])
    return nil if filas.empty?
    
    data = filas.first
    # Reconstruimos el objeto: id, nombre, aprobado (convertido a boolean)
    return Solicitante.new(data[0], data[1], data[2] == 1)
  end

  # lib/usuarios.rb

  # ... otros métodos ...

  # Método para traer TODOS los registros (SELECT *)
  def self.all
    sql = "SELECT * FROM solicitantes"
    filas = BaseDeDatos.instance.ejecutar(sql)
    
    # filas es un array de arrays: [[1, "Hugo", 0], [2, "Allie", 0]...]
    # Tenemos que convertir cada fila fea en un Objeto Solicitante bonito.
    
    # Este truco de Ruby se llama "Mapeo":
    lista_de_objetos = filas.map do |fila|
      Solicitante.new(fila[0], fila[1], fila[2] == 1)
    end
    
    return lista_de_objetos
  end
  
# ... fin de la clase ...
end

class Consul < Persona
    include Aprobable
end