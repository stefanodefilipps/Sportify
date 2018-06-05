FactoryBot.define do
    factory :user do
        nome    "Stefano"
        cognome "De Filippis"
        nick    "stfn"
    end
    factory :team do
        nome            "cogiorgio"
    end
    factory :membro do
        ruolo           "P"
    end
end