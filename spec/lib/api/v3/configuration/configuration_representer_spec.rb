#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2018 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
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

describe ::API::V3::Configuration::ConfigurationRepresenter do
  include ::API::V3::Utilities::PathHelper

  let(:represented) { Setting }
  let(:current_user) do
    FactoryBot.build_stubbed(:user).tap do |user|
      allow(user)
        .to receive(:preference)
        .and_return(FactoryBot.build_stubbed(:user_preference))
    end
  end
  let(:embed_links) { false }
  let(:representer) do
    described_class.new(represented, current_user: current_user, embed_links: embed_links)
  end

  context 'generation' do
    subject { representer.to_json }

    describe '_links' do
      it_behaves_like 'has an untitled link' do
        let(:link) { 'self' }
        let(:href) { api_v3_paths.configuration }
      end

      context 'userPreferences' do
        context 'if logged in' do
          it_behaves_like 'has an untitled link' do
            let(:link) { 'userPreferences' }
            let(:href) { api_v3_paths.my_preferences }
          end
        end

        context 'if not logged in' do
          let(:current_user) { FactoryBot.build_stubbed(:anonymous) }

          it_behaves_like 'has an untitled link' do
            let(:link) { 'userPreferences' }
            let(:href) { api_v3_paths.my_preferences }
          end
        end
      end
    end

    it 'indicates its type' do
      is_expected.to be_json_eql('Configuration'.to_json).at_path('_type')
    end

    it 'indicates maximumAttachmentFileSize in Bytes' do
      allow(Setting).to receive(:attachment_max_size).and_return('1024')
      is_expected.to be_json_eql((1024 * 1024).to_json).at_path('maximumAttachmentFileSize')
    end

    it 'indicates perPageOptions as array of integers' do
      allow(Setting).to receive(:per_page_options).and_return('1, 50 ,   100  ')
      is_expected.to be_json_eql([1, 50, 100].to_json).at_path('perPageOptions')
    end

    describe '_embedded' do
      context 'userPreferences' do
        context 'if embedding' do
          let(:embed_links) { true }

          it 'embedds the user preferences' do
            is_expected
              .to be_json_eql('UserPreferences'.to_json)
              .at_path('_embedded/userPreferences/_type')
          end
        end

        context 'if not embedding' do
          it 'embedds the user preferences' do
            is_expected
              .not_to have_json_path('_embedded/userPreferences/_type')
          end
        end
      end
    end
  end
end
