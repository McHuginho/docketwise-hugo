# app.rb
require 'sinatra'
require_relative 'lib/usuarios' # Traemos tu lógica de negocio
require 'prawn'

# Configuración para que sepa dónde buscar archivos
set :bind, '0.0.0.0'

# RUTA 1: La página de inicio
# app.rb

# Reemplaza el get '/' antiguo por este nuevo:
get '/' do
  # 1. Le pedimos a la clase que nos de la lista completa
  @lista_completa = Solicitante.all
  
  # 2. Renderizamos la vista de inicio
  erb :index
end

# RUTA 2: Una página dinámica
get '/prueba' do
  # Aquí podemos escribir código Ruby normal
  hora_actual = Time.now.strftime("%H:%M:%S")
  
  "<h2>Status del Sistema</h2>
   <p>La hora del servidor es: <strong>#{hora_actual}</strong></p>
   <p>Si recargas esta página, la hora cambiará.</p>
   <a href='/'>Volver al inicio</a>"
end

# RUTA 3: ¡Conexión con tu Base de Datos!
# app.rb (Solo cambia esta parte)

# app.rb

# Fíjate en el cambio: agregamos /:id
get '/usuarios/:id' do
  # 'params' es un hash especial que captura lo que pongas en la URL
  id_solicitado = params[:id]
  
  # Buscamos usando ese ID dinámico
  @usuario = Solicitante.find(id_solicitado)
  
  if @usuario
    erb :perfil
  else
    "<h1>Error 404</h1><p>El usuario con ID #{id_solicitado} no existe.</p>"
  end
end

# app.rb

# 1. Ruta para MOSTRAR el formulario (GET)
get '/nuevo' do
  erb :nuevo
end

# 2. Ruta para PROCESAR el formulario (POST)
post '/registrar' do
  # Sinatra captura lo que escribieron en los inputs usando 'name'
  # <input name="id_form"> llega como params[:id_form]
  
  id_recibido = params[:id_form]
  nombre_recibido = params[:nombre_form]
  
  # Usamos tu clase Ruby para guardar (Active Record Manual)
  nuevo_usuario = Solicitante.new(id_recibido, nombre_recibido, false) # False = Empieza no aprobado
  nuevo_usuario.save
  
  # Finalmente, redirigimos al perfil del usuario recién creado
  redirect "/usuarios/#{id_recibido}"
end

# ACCIÓN 1: Cambiar Status (Toggle)
post '/usuarios/:id/toggle' do
  usuario = Solicitante.find(params[:id])
  
  if usuario
    # Si está true lo volvemos false, y viceversa (Lógica booleana)
    nuevo_estado = !usuario.aprobado 
    usuario.update_status(nuevo_estado)
  end
  
  # Recargamos la misma página para ver el cambio
  redirect "/usuarios/#{params[:id]}"
end

# ACCIÓN 2: Borrar usuario
post '/usuarios/:id/borrar' do
  usuario = Solicitante.find(params[:id])
  
  if usuario
    usuario.destroy
  end
  
  # Como ya no existe, no podemos quedarnos aquí. Nos vamos al inicio.
  redirect "/"
end

get '/usuarios/:id/descargar' do
  @usuario = Solicitante.find(params[:id])

  # Le decimos al navegador que esto NO es HTML, es un PDF
  content_type 'application/pdf'
  attachment "expediente_#{@usuario.nombre}.pdf" # Para que lo descargue en vez de abrirlo

  # Generamos el documento
  pdf = Prawn::Document.new
  pdf.text "DOCKETWISE (Versión Hugo)", size: 20, style: :bold, align: :center
  pdf.move_down 20
  pdf.text "Expediente Oficial de Inmigración", align: :center
  pdf.move_down 50

  pdf.text "ID del Solicitante: #{@usuario.id}"
  pdf.text "Nombre Completo: #{@usuario.nombre}", size: 16
  pdf.text "Estado Actual: #{@usuario.aprobado ? 'APROBADO' : 'EN REVISIÓN'}", color: @usuario.aprobado ? [0, 100, 0, 0] : [100, 0, 0, 0]

  pdf.move_down 50
  pdf.text "Firma del Oficial: _______________________"

  # Enviamos el PDF al navegador
  pdf.render
end