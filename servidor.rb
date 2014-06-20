# myapp.rb
require 'sinatra'
require 'digest'
require 'data_mapper'

set :public_folder, 'public'
set :environment, :development
DataMapper.setup(:default, 'mysql://'+ENV['OPENSHIFT_MYSQL_DB_USERNAME']+':'+ENV['OPENSHIFT_MYSQL_DB_PASSWORD']+'@'+ENV['OPENSHIFT_MYSQL_DB_HOST']+':'+ENV['OPENSHIFT_MYSQL_DB_PORT']+'/'+ENV['OPENSHIFT_APP_NAME'])

class Imagen
  include DataMapper::Resource
  property :id, Serial
  property :titulo, Text
  property :url, Text
  property :descripcion, Text
  property :created_at, DateTime
end

DataMapper.finalize
Imagen.auto_upgrade!

get '/' do
	@imagenes = Imagen.all
	erb :index
end

get '/subirarchivo' do
	erb :subirarchivo
end

post '/upload' do
	md5 = Digest::MD5.new
	md5.update '' + Time.now.to_s
	archivo = Array.new 
	archivo = params['imagen'][:filename].rpartition(".")
	punto = '.'
	ubicacionroot = File.dirname(__FILE__) +'/public/uploads/'
	nombre = md5.to_s+punto+archivo[2].to_s
  File.open(ubicacionroot + params['imagen'][:filename], "w") do |f|
    f.write(params['imagen'][:tempfile].read)
	end	
	File.rename(ubicacionroot + params['imagen'][:filename], ubicacionroot + nombre)
	ubicacion = 'uploads/' + nombre
	Imagen.create(titulo: params[:titulo], url: ubicacion, descripcion: params[:descripcion], created_at: Time.now)
  redirect "/"
end