RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

FactoryBot.define do
    factory :user do
        nome    "Stefano"
        cognome "De Filippis"
        nick    "stfn"
    end
    factory :team do
        nome            "team_prova"
    end
    factory :membro do
        ruolo           "P"
    end
end