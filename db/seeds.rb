# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Rails.logger.debug '##### SEEDS #####'

acoes = [
  'Semeando', 'Plantando', 'Colhendo', 'Programando', 'Codando', 'Fazendo deploy de',
  'Debuggando', 'Em reunião com', 'Indo buscar', 'Pensando em', 'Fazendo cosplay de',
  'Fritando', 'Dançando com', 'Jogando RPG com', 'Pilotando a nave com', 'Estudando sobre',
  'Vacinando', 'Virando jacaré com', 'No Dota com', 'Update sem where em',
  'Fazendo pair programming com'
]
ejs = [
  'Accont', 'Acens', 'ADM Soluções', 'Agronômica', 'Alquimista', 'Ambienteia', 'Atêlie Se7e', 'CEOS',
  'Ciclo', 'Conalimentos', 'Concretiza', 'Construtiva', 'Consultec', 'Container', 'Diferencial', 'Dual',
  'Edifica', 'Ej7', 'EjEPRO', 'Ejudi', 'Emzootec', 'Engene', 'EPRO', 'FASJUS', 'Geocapta', 'Geomaps',
  'GTi', 'Harpia', 'Impact', 'Include', 'Index', 'Inova', 'Inovale', 'Inove', 'Insight Jr', 'Ipharma',
  'Mata Branca', 'Mecaniza', 'Metal Soluções', 'Polifarma', 'Premium', 'Proativa', 'Progresso', 'Projetta',
  'Proteus', 'Psyquê FAS', 'Rastro', 'Retec', 'Tecsys', 'Unijus', 'Vale jr', 'Autotech'
]

Rails.logger.debug "#{acoes.sample} EJs..."

ejs.each do |ej|
  JuniorEnterprise.create(name: ej)
end
JuniorEnterprise.create(name: 'FEJECE', id: 0, description: "Os piratas!")

case Rails.env
when 'development'
  file = URI.open('https://storage.googleapis.com/farol-fejece/fotos/user.png')
  admin = Admin.create(email: 'admin@gti.com',
                       password: 'voagti')
  admin.profile_picture.attach(io: file, filename: 'user.png', content_type: 'image/png')
    

when 'production'
  file = URI.open('https://storage.googleapis.com/farol-fejece/fotos/user.png')
  admin = Admin.create(email: 'admin@gti.com',
                       password: 'voagti')
  admin.profile_picture.attach(io: file, filename: 'user.png', content_type: 'image/png')

end



Rails.logger.debug "#{acoes.sample} Categorias..."
categorias = ['Time', 'Marketing', 'Projetos', 'Liderança', 'Organização']
categorias.each do |c|
  Category.create(name: c, description: "Sobre #{c}")
end



Rails.logger.debug '##### FIM #####'
