# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'farol.fejece@gmail.com'
  layout 'mailer'
end
