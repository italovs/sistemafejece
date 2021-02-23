# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'open-uri'


puts "##### SEEDS #####"

acoes = [
  "Semeando", "Plantando", "Colhendo", "Programando", "Codando", "Fazendo deploy de", 
  "Debuggando", "Em reunião com", "Indo buscar", "Pensando em", "Fazendo cosplay de",
  "Fritando", "Dançando com", "Jogando RPG com", "Pilotando a nave com", "Estudando sobre",
  "Vacinando", "Virando jacaré com", "No Dota com", "Update sem where em",
  "Fazendo pair programming com"
]
puts "#{acoes.sample} EJs..."
JuniorEnterprise.create(name: 'GTi', description: 'Ases, mestres, guerreiros e exploradores do espaço')
9.times do |i|
  JuniorEnterprise.create(name: "EJ #{i}", description: "A #{i+2}ª melhor EJ")
end
puts "#{acoes.sample} Membros..."

file = open('https://storage.googleapis.com/farol-fejece-test/fotos/user.png')
member = Member.create(
          email: 'member@gti.com',
          password: '123123',
          junior_enterprise_id: 1,
          validated: nil)
member.profile_picture.attach(io: file, filename: "user.png", content_type: 'image/png')
ejs = Set.new(2..10)


case Rails.env
when "development"
  admin = Admin.create(email: 'admin@gti.com',
            password: 'voagti',
            )
  #admin.profile_picture.attach(io: File.open('app/assets/images/user.png'),filename: 'user.png', content_type:"image/png")

  4.times do |i|
    ej_id = ejs.to_a.sample
    ejs = ejs.delete(ej_id)
    member=Member.create(
      name: "membro#{i+2}",
      email: "quero_ser_diretor_#{i}@gti.com",
      password: '123123',
      junior_enterprise_id: ej_id,
      validated: nil)
      #member.profile_picture.attach(io: File.open('app/assets/images/user.png'),filename: 'user.png', content_type:"image/png")
  end


when "production"
  admin = Admin.create(email: 'admin@gti.com',
  password: 'voagti',
  )
  #admin.profile_picture.attach(io:file,filename:'user.png',content_type:'image/png')

  4.times do |i|
    ej_id = ejs.to_a.sample
    ejs = ejs.delete(ej_id)
    member=Member.create(
      name: "membro#{i+2}",
      email: "quero_ser_diretor_#{i}@gti.com",
      password: '123123',
      junior_enterprise_id: ej_id,
      validated: nil)
      #member.profile_picture.attach(io:file,filename:'user.png',content_type:'image/png')
  end
end







#5 membros que desejam ser diretores


#5 diretores de EJ
5.times do |i|
  ej_id = ejs.to_a.sample
  ejs = ejs.delete(ej_id)
  Member.create(name: "membro#{i+6}", email: "diretor_#{i}@gti.com", password: '123123', junior_enterprise_id: ej_id, validated: true)
end

puts "#{acoes.sample} Categorias..."
categorias = ["Time", "Marketing", "Projetos", "Liderança", "Organização"]
categorias.each do |c|
  Category.create(name: c, description: "Sobre "+c)
end

puts "##### FIM #####"