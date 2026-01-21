# app.rb
require 'sinatra'
require_relative 'lib/usuarios' # Traemos tu lógica de negocio

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