require 'rails_helper'
require 'cancan/matchers'

describe Canard::Abilities, '#match_creators' do
  let(:acting_match_creator) { User.create(roles: %w(match_creator)) }
  subject(:match_creator_ability) { Ability.new(acting_match_creator) }

#   # Define your ability tests thus;
#   describe 'on MatchCreator' do
#     let(:match_creator) { FactoryGirl.create(match_creator) }
#
#     it { is_expected.to be_able_to(:index,   MatchCreator) }
#     it { is_expected.to be_able_to(:show,    match_creator) }
#     it { is_expected.to be_able_to(:read,    match_creator) }
#     it { is_expected.to be_able_to(:new,     match_creator) }
#     it { is_expected.to be_able_to(:create,  match_creator) }
#     it { is_expected.to be_able_to(:edit,    match_creator) }
#     it { is_expected.to be_able_to(:update,  match_creator) }
#     it { is_expected.to be_able_to(:destroy, match_creator) }
#   end
#   # on MatchCreator
end
