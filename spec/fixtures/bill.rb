module DataMapper
  module Validations
    module Fixtures

      # Simple class that represents a bill. This example was
      # chosen because bills sometimes need corrections while
      # keeping the originals
      class Bill
        include DataMapper::Resource

        property :id,                   DataMapper::Property::Serial

        # property to make sure the resource is marked as dirty
        property :has_correction,       DataMapper::Property::Boolean

        # convenience association to be able to get to the original
        # bill if this is the correction
        has 1, :original,   :model => 'BillCorrection'

        # Keep track of the amount of time the valid hook is called
        attr_accessor :valid_hook_call_count

        def valid?(context = :default)
          @valid_hook_call_count ||= 0
          @valid_hook_call_count += 1
          super
        end
      end

      # correction of a bill creates a new bill which keeps an
      # association to the original bill
      class BillCorrection
        include DataMapper::Resource

        property :id,                     DataMapper::Property::Serial

        belongs_to :original_bill,   :model => 'Bill'
        belongs_to :correction_bill, :model => 'Bill'

        def self.build_from(original, intermediary = nil)
          correction = Bill.new
          correction.original = self.new(:original_bill => original, :correction_bill => correction )
          correction
        end

        def save
          if save_result = super
            original_bill.has_correction = true
            # suppose we want to bypass validation for some reason
            original_result = original_bill.save!
          end
          save_result && original_result
        end
      end
    end
  end
end

