json.partial! 'v1/assessments/assessment', 
  assessment: @assessment

json.number_of_requests Assessments::Permission.new(@assessment).requested.count