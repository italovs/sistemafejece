class MemberMailer < ApplicationMailer

    def send_form(current_user, phone, message)
        @current_user = current_user
        @phone = phone
        @message = message
        mail(to: "gabrie1s.3050vss@gmail.com", subject: "Mensagem enviada pelo formulário da Farol")
    end
end
