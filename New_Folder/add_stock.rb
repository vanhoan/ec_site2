#! /usr/local/bin/ruby
# coding: utf-8

require File.join(Rails.root, "/extras/np_thor")

class AddStock < NpThor
  # executeをデフォルトにする
  default_task :execute

  # このクラスの説明
  desc "execute [OPTION]", ""

  def execute
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.debug "----- Start batch -----"
    code = measure{ succeed? } ? BATCH_SUCCESS : BATCH_FAILURE
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.debug "Result: #{code == BATCH_SUCCESS ? 'SUCCESS' : 'FAILURE'}"
    Rails.logger.debug "----- End batch -----"
    exit code
  end

  # Thorコマンドとして認識しないブロック
  no_commands do
    def succeed?
      Rails.logger = Logger.new("log/#{self.class.to_s.underscore}.log-#{DateTime.now.strftime("%Y%m%d")}")
      ActiveRecord::Base.logger = Rails.logger
      addRule = Master::AddRule.new
      return addRule.do_add_stock?
    end

  end
end

AddStock.start unless ENV["RAILS_ENV"] == "test"
