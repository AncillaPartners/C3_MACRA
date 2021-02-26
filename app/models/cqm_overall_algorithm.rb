class CqmOverallAlgorithm < ApplicationRecord
  has_many  :requirements

  SIMPLE_AVERAGE_ID = 1
  WEIGHTED_AVERAGE_ID = 2
  SUM_NUMERATORS_ID = 3
  OVERALL_STRATUM_ONLY_ID = 4
end
