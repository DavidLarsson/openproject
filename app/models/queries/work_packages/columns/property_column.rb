#-- encoding: UTF-8

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

class Queries::WorkPackages::Columns::PropertyColumn < Queries::WorkPackages::Columns::WorkPackageColumn
  def caption
    WorkPackage.human_attribute_name(name)
  end

  class_attribute :property_columns

  self.property_columns = {
    id: {
      sortable: "#{WorkPackage.table_name}.id",
      groupable: false
    },
    project: {
      association: 'project',
      sortable: "name",
      groupable: 'project_id'
    },
    subject: {
      sortable: "#{WorkPackage.table_name}.subject"
    },
    type: {
      association: 'type',
      sortable: "position",
      groupable: 'type_id'
    },
    parent: {
      association: 'ancestors_relations',
      default_order: 'asc',
      sortable: false
    },
    status: {
      association: 'status',
      sortable: "position",
      highlightable: true,
      groupable: 'status_id'
    },
    priority: {
      association: 'priority',
      sortable: "position",
      default_order: 'desc',
      highlightable: true,
      groupable: 'priority_id'
    },
    author: {
      association: 'author',
      sortable: ["lastname",
                 "firstname",
                 "id"],
      groupable: 'author_id'
    },
    assigned_to: {
      association: 'assigned_to',
      sortable: ["lastname",
                 "firstname",
                 "id"],
      groupable: 'assigned_to_id'
    },
    responsible: {
      association: 'responsible',
      sortable: ["lastname",
                 "firstname",
                 "id"],
      groupable: 'responsible_id'
    },
    updated_at: {
      sortable: "#{WorkPackage.table_name}.updated_at",
      default_order: 'desc'
    },
    category: {
      association: 'category',
      sortable: "name",
      groupable: 'category_id'
    },
    fixed_version: {
      association: 'fixed_version',
      sortable: ["name"],
      default_order: 'desc',
      groupable: 'fixed_version_id'
    },
    start_date: {
      # Put empty start_dates in the far future rather than in the far past
      sortable: ["CASE WHEN #{WorkPackage.table_name}.start_date IS NULL
                  THEN 1
                  ELSE 0 END",
                 "#{WorkPackage.table_name}.start_date"]
    },
    due_date: {
      highlightable: true,
      # Put empty due_dates in the far future rather than in the far past
      sortable: ["CASE WHEN #{WorkPackage.table_name}.due_date IS NULL
                  THEN 1
                  ELSE 0 END",
                 "#{WorkPackage.table_name}.due_date"]
    },
    estimated_hours: {
      sortable: "#{WorkPackage.table_name}.estimated_hours",
      summable: true
    },
    spent_hours: {
      sortable: false,
      summable: false
    },
    done_ratio: {
      sortable: "#{WorkPackage.table_name}.done_ratio",
      groupable: true,
      if: ->(*) { !WorkPackage.done_ratio_disabled? }
    },
    created_at: {
      sortable: "#{WorkPackage.table_name}.created_at",
      default_order: 'desc'
    }
  }

  def self.instances(_context = nil)
    property_columns.map do |name, options|
      next unless !options[:if] || options[:if].call

      new(name, options.except(:if))
    end.compact
  end
end
