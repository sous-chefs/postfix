# encoding: utf-8
# Copyright:: Copyright (c) 2012, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node['postfix']['hash_maps'].each do |file, content|
  execute "update-postmap-#{file}" do
    command "postmap #{file}"
    environment PATH: "#{ENV['PATH']}:/opt/omni/bin:/opt/omni/sbin" if platform_family?('omnios')
    action :nothing
  end

  template file do
    source 'hash_maps.erb'
    variables(map: content)
    notifies :run, "execute[update-postmap-#{file}]"
    notifies :restart, 'service[postfix]'
  end
end