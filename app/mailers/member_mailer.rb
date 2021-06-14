class MemberMailer < ApplicationMailer

    def send_form(current_user, phone, message)
        @current_user = current_user
        @phone = phone
        @message = message
        mail(to: "italo_1002@live.com", subject: "Mensagem enviada pelo formulário da Farol")
    end
end
