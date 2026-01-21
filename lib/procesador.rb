class ProcesadorDeVisas
    def initialize
        @cola = []
    end

    def encolar(solicitante)
        @cola.push(solicitante)
        puts "⏳ #{solicitante.nombre} ha entrado en la lista de espera."
    end

    def procesar_siguiente(consul)
        if @cola.empty?
            puts "No hay más personas en la fila. El cónsul puede descansar."
        else
            candidato = @cola.shift
            consul.aprobar_visa(candidato)
        end
    end
end