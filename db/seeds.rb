# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


Admin.create(email: 'admin@gti.com', password: 'voagti')
Member.create(email: 'member@gti.com', password: '123123')


JuniorEnterprise.create(name: 'GTi', description: 'Ases, mestres, guerreiros e exploradores do espaço')
9.times do |i|
  JuniorEnterprise.create(name: "EJ #{i}", description: "A #{i+2}ª melhor EJ")
end