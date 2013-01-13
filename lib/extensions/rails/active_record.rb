module ActiveRecordExtensions
  extend ActiveSupport::Concern

  module ClassMethods

    def find_all(ids)
      models = self.find(ids).map {|model| [model.id, model]}.to_h
      ids.map {|id| models[id]}
    end

  end

end

ActiveRecord::Base.send(:include, ActiveRecordExtensions)