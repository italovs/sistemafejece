class MemberMailer < ApplicationMailer

    def send_form(current_user, phone, message)
        @current_user = current_user
        @phone = phone
        @message = message
        mail(to: "joaogabriel9086@gmail.com", subject: "Mensagem enviada pelo formulário da Farol")
    end
end
