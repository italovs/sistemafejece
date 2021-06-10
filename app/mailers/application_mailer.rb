# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@farol_fejece.com'
  layout 'mailer'
end
