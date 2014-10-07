require 'rails_helper'

module OpenStax
  module Api
    module V1
      describe AbstractSearchRepresenter do

        before(:all) do
          john_doe = FactoryGirl.create :user, name: "John Doe",
                                               username: "doejohn",
                                               email: "john@doe.com"
          jane_doe = FactoryGirl.create :user, name: "Jane Doe",
                                               username: "doejane",
                                               email: "jane@doe.com"
          jack_doe = FactoryGirl.create :user, name: "Jack Doe",
                                               username: "doejack",
                                               email: "jack@doe.com"
          @john_hash = JSON.parse(UserRepresenter.new(john_doe).to_json)
          @jane_hash = JSON.parse(UserRepresenter.new(jane_doe).to_json)
          @jack_hash = JSON.parse(UserRepresenter.new(jack_doe).to_json)

          100.times do
            u = FactoryGirl.build(:user)
            u.save unless u.name =~ /\A[\w]* doe[\w]*\z/i
          end
        end

        it "represents search results" do
          outputs = SearchUsers.call('last_name:dOe').outputs
          response = JSON.parse(UserSearchRepresenter.new(outputs).to_json)
          total_count = response['total_count']
          items = response['items']

          expect(total_count).to eq 3
          expect(items).to include(@john_hash)
          expect(items).to include(@jane_hash)
          expect(items).to include(@jack_hash)

          outputs = SearchUsers.call('first_name:jOhN last_name:DoE').outputs
          response = JSON.parse(UserSearchRepresenter.new(outputs).to_json)
          total_count = response['total_count']
          items = response['items']

          expect(total_count).to eq 1
          expect(items).to include(@john_hash)
          expect(items).not_to include(@jane_hash)
          expect(items).not_to include(@jack_hash)

          outputs = SearchUsers.call('first_name:JoHn,JaNe last_name:dOe').outputs
          response = JSON.parse(UserSearchRepresenter.new(outputs).to_json)
          total_count = response['total_count']
          items = response['items']

          expect(total_count).to eq 2
          expect(items).to include(@john_hash)
          expect(items).to include(@jane_hash)
          expect(items).not_to include(@jack_hash)
        end

        it "represents ordered results" do
          outputs = SearchUsers.call('username:DoE', order_by: 'cReAtEd_At AsC, iD')
                               .outputs
          response = JSON.parse(UserSearchRepresenter.new(outputs).to_json)
          total_count = response['total_count']
          items = response['items']

          expect(total_count).to eq 3
          expect(items[0]).to eq @john_hash
          expect(items[1]).to eq @jane_hash
          expect(items[2]).to eq @jack_hash

          outputs = SearchUsers.call('username:dOe', order_by: 'CrEaTeD_aT dEsC, Id DeSc')
                               .outputs
          response = JSON.parse(UserSearchRepresenter.new(outputs).to_json)
          total_count = response['total_count']
          items = response['items']

          expect(total_count).to eq 3
          expect(items[0]).to eq @jack_hash
          expect(items[1]).to eq @jane_hash
          expect(items[2]).to eq @john_hash
        end

    it "represents paginated results" do
      user_count = User.count

      outputs = SearchUsers.call('').outputs
      response = JSON.parse(UserSearchRepresenter.new(outputs).to_json)
      total_count = response['total_count']
      items = response['items']

      expect(total_count).to eq user_count
      expect(items.count).to eq user_count

      outputs = SearchUsers.call('', per_page: 20).outputs
      response = JSON.parse(UserSearchRepresenter.new(outputs).to_json)
      total_count = response['total_count']
      items = response['items']

      expect(total_count).to eq user_count
      expect(items.count).to eq 20

        for page in 1..5
          outputs = SearchUsers.call('', page: page, per_page: 20).outputs
          response = JSON.parse(UserSearchRepresenter.new(outputs).to_json)
          total_count = response['total_count']
          items = response['items']

          expect(total_count).to eq user_count
          expect(items.count).to eq 20
        end

        outputs = SearchUsers.call('', page: 1000, per_page: 20).outputs
        response = JSON.parse(UserSearchRepresenter.new(outputs).to_json)
        total_count = response['total_count']
        items = response['items']

        expect(total_count).to eq user_count
        expect(items.count).to eq 0
      end

      end
    end
  end
end
