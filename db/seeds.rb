# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


Admin.create(email: 'admin@gti.com', password: 'voagti')

JuniorEnterprise.create(name: 'GTi', description: 'Ases, mestres, guerreiros e exploradores do espaço')
9.times do |i|
  JuniorEnterprise.create(name: "EJ #{i}", description: "A #{i+2}ª melhor EJ")
end

Member.create(email: 'member@gti.com', password: '123123', junior_enterprise_id: 1, validated: true)

#3 membros comuns
3.times do |i|

end

ejs = Set.new(1..10)
#5 membros que desejam ser diretores
5.times do |i|
  ej_id = ejs.to_a.sample
  ejs = ejs.delete(ej_id)
  Member.create(name: "membro#{i+1}", email: "quero_ser_diretor_#{i}@gti.com", password: '123123', junior_enterprise_id: ej_id, validated: nil)
end

#5 diretores de EJ
5.times do |i|
  ej_id = ejs.to_a.sample
  ejs = ejs.delete(ej_id)
  Member.create(name: "membro#{i+6}", email: "diretor_#{i}@gti.com", password: '123123', junior_enterprise_id: ej_id, validated: true)
end