#-- encoding: UTF-8

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

class WorkPackages::SettingsController < ::ApplicationController
  layout 'admin'
  before_action :require_admin
  current_menu_item :index do
    :work_packages_setting
  end

  def index
    render 'work_packages/settings/work_package_tracking'
  end

  def edit
    if params[:settings]
      Settings::UpdateService
        .new(user: current_user)
        .call(settings: permitted_params.settings.to_h)

      flash[:notice] = I18n.t(:notice_successful_update)
      redirect_to action: 'index'
    end
  end

  def default_breadcrumb
    t(:label_work_package_tracking)
  end

  def show_local_breadcrumb
    true
  end
end
