# == Schema Information
#
# Table name: conductor_weight_histories
#
#  id          :integer         not null, primary key
#  group_name  :string(255)
#  option_name :string(255)
#  weight      :decimal(8, 2)
#  computed_at :datetime
#

class Conductor::WeightHistory < ActiveRecord::Base
  set_table_name "conductor_weight_histories"
end
