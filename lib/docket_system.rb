class DocketSystem
    @@intancia_unica = nil

    private_class_method :new

    def self.instance
        @@intancia_unica ||= new
    end

    def initialize
        @estado = "Abierto"
        puts "🔧 Sistema Docketwise inicializando: #{@estado}"
    end

    def cerrar_oficina
        @estado = "Cerrado"
        puts "⚠️ La oficina ha cerrado. No se aceptan más trámites."
    end

    def abrir_oficina
        @estado = "Abierto"
        puts "✅ La oficina está abierta nuevamente."
    end

    def estado_actual
        @estado
    end
end