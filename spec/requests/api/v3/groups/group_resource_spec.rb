#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2021 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See docs/COPYRIGHT.rdoc for more details.
#++

require 'spec_helper'
require 'rack/test'

describe 'API v3 Group resource', type: :request, content_type: :json do
  include Rack::Test::Methods
  include API::V3::Utilities::PathHelper

  subject(:response) { last_response }

  shared_let(:project) { FactoryBot.create(:project) }
  let(:group) do
    FactoryBot.create(:group,
                      member_in_project: project,
                      member_through_role: role)
  end
  let(:role) { FactoryBot.create(:role, permissions: permissions) }
  let(:permissions) { [:view_members] }
  let(:members) do
    FactoryBot.create_list(:user, 2)
  end

  current_user do
    FactoryBot.create(:user,
                      member_in_project: project,
                      member_through_role: role)
  end

  describe 'GET api/v3/groups/:id' do
    before do
      get get_path
    end

    context 'having the necessary permission' do
      let(:get_path) { api_v3_paths.group group.id }

      it 'responds with 200 OK' do
        expect(subject.status)
          .to eq(200)
      end

      it 'responds with the correct group resource including the members' do
        expect(subject.body)
          .to be_json_eql('Group'.to_json)
          .at_path('_type')

        expect(subject.body)
          .to be_json_eql(group.name.to_json)
          .at_path('name')

        expect(JSON::parse(subject.body).dig(:_links, :members, :id))
          .to match_array members.map(&:id)
      end
    end

    context 'requesting nonexistent group' do
      let(:get_path) { api_v3_paths.group 9999 }

      it_behaves_like 'not found' do
        let(:id) { 9999 }
        let(:type) { 'Group' }
      end
    end

    context 'not having the necessary permission' do
      let(:permissions) { [] }
      let(:get_path) { api_v3_paths.group group.id }

      it_behaves_like 'not found' do
        let(:id) { group.id }
        let(:type) { 'Group' }
      end
    end
  end
end
